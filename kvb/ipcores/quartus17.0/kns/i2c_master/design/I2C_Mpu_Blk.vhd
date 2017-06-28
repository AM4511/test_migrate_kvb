---------------------------------------------------------------------------
--  >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
---------------------------------------------------------------------------
--  Copyright (c) 2004 - 2009 by Lattice Semiconductor Corporation      
-- 
---------------------------------------------------------------------------
-- Permission:
--
--   Lattice Semiconductor grants permission to use this code for use
--   in synthesis for any Lattice programmable logic product.  Other
--   use of this code, including the selling or duplication of any
--   portion is strictly prohibited.
--
-- Disclaimer:
--
--   This VHDL or Verilog source code is intended as a design reference
--   which illustrates how these types of functions can be implemented.
--   It is the user's responsibility to verify their design for
--   consistency and functionality through the use of formal
--   verification methods.  Lattice Semiconductor provides no warranty
--   regarding the use or functionality of this code.
---------------------------------------------------------------------------
--
--    Lattice Semiconductor Corporation
--    5555 NE Moore Court
--    Hillsboro, OR 97124
--    U.S.A
--
--    TEL: 1-800-Lattice (USA and Canada)
--    503-268-8001 (other locations)
--
--    web: http://www.latticesemi.com/
--    email: techsupport@latticesemi.com
-- 
---------------------------------------------------------------------------
-- 
--  Name:  I2C_Mpu_Blk.vhd
-- 
--  Description:  Interface between the microprocessor and the I2C Master
--              Controller
-- 
-- Code Revision History :
---------------------------------------------------------------------------
-- Ver: | Author	    |Mod. Date	    |Changes Made:
-- V1.0 | 				|2004           |Initial ver
-- V1.1 | CM            |2009           |remove signals not being used    
-- R.CARICKHOFF         |2012           |Added fifo data buffer
---------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity MPU_to_I2C is
  port(MPU_CLK            : in std_logic;                       -- Main Clock
       Rst_L              : in std_logic;                       -- Main Reset, active low
       CS_L               : in std_logic;                       -- Chip select, active low
       Addr_Bits          : in std_logic_vector(2 downto 0);    -- Address bits A0, A1, A2. Used for register sel
	    DIN                : in std_logic_vector(7 downto 0);    -- Data bus input
       WEN                : in std_logic;                       -- write enable active low
       REN                : in std_logic;                       -- read enable active low
       Read_Buffer        : in std_logic_vector(7 downto 0);    -- I2C Data Read in
       Status             : in std_logic_vector(4 downto 0);    -- Status part of Command_Status Reg Contains:
                                                                -- I2C_Bus_Busy(4), Error(3), Abort_Ack(2), Lost_Arb(1), Done(0)
                                                                -- Does not include: Trans_Buf_Full, Trans_Buf_Empty, 
                                                                -- and Recieve_Buf_Empty
       TBE_Set            : in std_logic;                       -- TBE_Set flag, set Trans_Buf_Empty to empty                                                                   
       RBF_Set            : in std_logic;                       -- RBF_Set flag, set Read_Buff_Full  to full                                                                    
       Iack_Clear         : in std_logic;                       -- Clears the Iack
       Go_Clear           : in std_logic;                       -- Clears Go Bit
       Low_Address_Reg    : out std_logic_vector(7 downto 0);   -- Low order Address bits for I2C Slave
       Upper_Address_Reg  : out std_logic_vector(2 downto 0);   -- High order Address bits for I2C Slave
       Byte_Count_Reg     : out std_logic_vector(7 downto 0);   -- I2C Transaction Byte Count
       Command_Reg        : out std_logic_vector(7 downto 0);   -- CMD part of Command_Status Reg Contains:
                                                                -- Go, Abort, I2C_Mode, Done_IE.
       Trans_Buffer       : out std_logic_vector(7 downto 0);   -- Holds Data for I2C Write transaction
       Trans_Buffer_Empty : out std_logic;                      -- 0 indicates that the trans buffer is empty
       Read_Buffer_Full   : out std_logic;                      -- 0 indicates that the read buffer is not full
       Iack               : out std_logic;                      -- interrupt acknowledge
       DOUT               : out std_logic_vector(7 downto 0));  -- Data bus output NOTE: Data(7) is MSB                         
end MPU_to_I2C;

architecture MPU_to_I2C_Behave of MPU_to_I2C is
signal tbe            : std_logic;
signal rbf            : std_logic;
signal TBE_Set1       : std_logic;
signal RBF_Set1       : std_logic;
signal write_pulse    : std_logic;
signal state             : std_logic_vector(1 downto 0);

--internal registers necessary for feedback
signal laddr          : std_logic_vector(7 downto 0);
signal upaddr         : std_logic_vector(2 downto 0);
signal bcnt           : std_logic_vector(7 downto 0);
signal cmd            : std_logic_vector(7 downto 0);

constant data_addr    : std_logic_vector(2 downto 0) := "000";
constant low_addr     : std_logic_vector(2 downto 0) := "001";
constant up_addr      : std_logic_vector(2 downto 0) := "010";
constant command      : std_logic_vector(2 downto 0) := "100";
constant byte_cnt     : std_logic_vector(2 downto 0) := "101";
constant iack_st      : std_logic_vector(2 downto 0) := "110";

signal temp_data      : std_logic_vector(7 downto 0);
signal trans_fifo_wen : std_logic;
signal trans_fifo_ren : std_logic;
signal fifo_rst       : std_logic; 
signal trans_fifo_empty : std_logic; 
signal trans_fifo_full : std_logic;
signal read_fifo_wen   : std_logic; 
signal read_fifo_ren   : std_logic; 
signal read_fifo_out   : std_logic_vector(7 downto 0); 
signal read_fifo_empty : std_logic; 
signal read_fifo_full  : std_logic;
signal Abort           : std_logic;
signal abort1          : std_logic;
signal abort2          : std_logic;
signal read1           : std_logic;
signal read2           : std_logic;
signal Bus_Busy        : std_logic;
signal bus_busy1       : std_logic;
signal Xfer_Done       : std_logic;
signal fifo_error      : std_logic;
signal I2C_RW_Bit      : std_logic;

component fifo8x8
    port (
        data: in  std_logic_vector(7 downto 0); 
        clock: in  std_logic; 
        wrreq: in  std_logic; 
        rdreq: in  std_logic; 
        aclr: in  std_logic; 
        q: out  std_logic_vector(7 downto 0); 
        empty: out  std_logic; 
        full: out  std_logic);
end component;

begin

Trans_Buffer_Empty <= trans_fifo_empty;
Read_Buffer_Full   <= not read_fifo_empty; -- this signal not used
DOUT <= temp_data when CS_L = '0' and REN = '0' else "00000000";  
Low_Address_Reg   <= laddr;
Upper_Address_Reg <= upaddr;
Command_Reg       <= cmd;
Byte_Count_Reg    <= bcnt;
Abort             <= cmd(6);
Bus_Busy          <= Status(4);
Xfer_Done         <= Status(0);
I2C_RW_Bit        <= laddr(0);

fifo_cntl: process (MPU_CLK, Rst_L, Abort, TBE_Set, RBF_Set, Bus_Busy)
begin
	if (rising_edge(MPU_CLK)) then
		if (Rst_L= '0') then
			abort1 <= '0';
			abort2 <= '0';
			TBE_Set1 <= '0';
			RBF_Set1 <= '0';
			bus_busy1 <= '0';
		else
			abort1 <= Abort;
			abort2 <= Abort1;
			TBE_Set1 <= TBE_Set;
			RBF_Set1 <= RBF_Set;
			bus_busy1 <= Bus_Busy;
		end if;	
    fifo_rst <= (abort1 and not abort2) or (not Rst_L);
	end if;
end process;

trans_fifo_ren <= ((TBE_Set and not TBE_Set1) or (Bus_Busy and not bus_busy1)) and not I2C_RW_Bit;
read_fifo_wen <= (RBF_Set and not RBF_Set1) and I2C_RW_Bit;

-- reading data register
read_fifo_renb: process (MPU_CLK, Rst_L, CS_L, REN, Addr_Bits)
begin
	if (rising_edge(MPU_CLK)) then
		if (Rst_L= '0') then
			read1 <= '0';
			read2 <= '0';
		else
			read1 <= not CS_L and not REN and not Addr_Bits(2) and not Addr_Bits(1) and not Addr_Bits(0);
			read2 <= read1;
		end if;			
	end if;
end process;

read_fifo_ren <= read1 and not read2;

trans_fifo: fifo8x8 
   port map (
        data => Din, 
        clock => MPU_CLK, 
        wrreq => trans_fifo_wen, 
        rdreq => trans_fifo_ren, 
        aclr => fifo_rst, 
        q => Trans_Buffer, 
        empty => trans_fifo_empty, 
        full => trans_fifo_full);

read_fifo: fifo8x8 
   port map (
        data => Read_Buffer, 
        clock => MPU_CLK, 
        wrreq => read_fifo_wen, 
        rdreq => read_fifo_ren, 
        aclr => fifo_rst, 
        q => read_fifo_out, 
        empty => read_fifo_empty, 
        full => read_fifo_full);

fifo_err: process(MPU_CLK, fifo_rst, trans_fifo_ren, trans_fifo_empty, read_fifo_wen, read_fifo_full)
begin
	if(fifo_rst = '1') then
			fifo_error <= '0';
	elsif(rising_edge(MPU_CLK)) then
		if(trans_fifo_ren = '1' and trans_fifo_empty = '1') then
			fifo_error <= '1';
		elsif(read_fifo_wen = '1' and read_fifo_full = '1') then
			fifo_error <= '1';
		end if;
	end if;
end process;

tdata :process(Addr_Bits, Status, fifo_error, read_fifo_out, trans_fifo_full, trans_fifo_empty, read_fifo_empty)
 begin
	if(Addr_Bits = command) then
		temp_data <= Status(4) & (Status(3) or fifo_error) & Status(2 downto 0) & trans_fifo_full & trans_fifo_empty & read_fifo_empty;
	elsif(Addr_Bits = data_addr) then
		temp_data <= read_fifo_out;
	else
		temp_data <= "00000000";
	end if;
 end process;

 MPU :process(MPU_CLK, RST_L, Addr_Bits, DIN, write_pulse,go_clear)
 begin
   if(Rst_L= '0')then
       upaddr     <= "000";
       laddr      <= "00000000";
       cmd        <= "00000000";
       bcnt       <= "00000000";

   elsif(rising_edge(MPU_CLK)) then
     if(write_pulse = '1') then  
       case Addr_Bits is
         when data_addr =>
           trans_fifo_wen <= '1';  
         when low_addr =>
           laddr  <= DIN;
         when up_addr =>
           upaddr <= DIN(2 downto 0);
         when command =>
           cmd    <= DIN;
         when byte_cnt =>
           bcnt   <= DIN;
         when iack_st =>
           laddr  <= laddr;
           upaddr <= upaddr;
           cmd    <= cmd;
           bcnt   <= bcnt; 
         when others =>
           laddr  <= laddr;
           upaddr <= upaddr;
           cmd    <= cmd;
           bcnt   <= bcnt; 
       end case;  

     elsif(go_clear = '1') then
       cmd(7) <= '0';
	   else
		   trans_fifo_wen <= '0';  		
     end if;
   end if;  
 end process;  
 
 pulse_write:process(MPU_CLK,RST_L, CS_L, WEN)
 constant idle  : std_logic_vector(1 downto 0) := "00";
 constant one   : std_logic_vector(1 downto 0) := "01";
 constant two   : std_logic_vector(1 downto 0) := "10"; 
 begin
   if(RST_L = '0') then
     write_pulse <= '0';
     state <=  idle;
   elsif(rising_edge(MPU_CLK)) then
     case state is
       when idle =>
         write_pulse <= '0';
         if(WEN = '0' and CS_L = '0') then
           state <= one;
         else
           state <= idle;      
         end if;
       when one =>
         write_pulse <= '1';
         if(WEN = '0' and CS_L = '0') then
           state <= two;
         else
           state <= idle;
         end if;
       when two =>
         write_pulse <= '0';
         if(CS_L = '1') then
           state <= idle;
         else
           state <= two;
         end if;
       when others =>
         write_pulse <= '0';
         state <= idle;
     end case;
   end if; 
 end process;     

 iack_set: process(Rst_L, MPU_CLK, Iack_Clear)
 begin
  if(Rst_L= '0')then
     Iack    <= '0';
  elsif(rising_edge(MPU_CLK)) then
     if(CS_L = '0' and Addr_Bits = "000") then
        Iack  <= '1'; -- clear interrupt
     elsif(Iack_Clear = '1') then
        Iack  <= '0';
     end if;   
  end if;
 end process;    

 trans_buf_empty: process(MPU_CLK, Rst_L, WEN, TBE_Set)
 begin
  if(Rst_L= '0')then
    tbe <= '0';
  elsif(rising_edge(MPU_CLK)) then
    if(CS_L = '0' and WEN = '0' and Addr_Bits = "000") then
      tbe <= '0'; -- trans buffer has been written to and is now full
   elsif(TBE_Set = '1') then
      tbe <= '1'; -- trans buffer is empty
    end if;
  end if;   
 end process;

 read_buf_full: process(MPU_CLK, Rst_L, REN, RBF_Set)
 begin
  if(Rst_L= '0')then
    rbf <= '0'; 
  elsif(rising_edge(MPU_CLK)) then
    if(CS_L = '0' and REN = '0' and Addr_Bits = "000") then
      rbf <= '0';  -- read buffer has been read and is now empty
    elsif(RBF_Set = '1') then
      rbf <= '1'; -- read buffer is full
    end if;
  end if;   
 end process;

end MPU_to_I2C_Behave;

--------------------------------- E O F --------------------------------------
