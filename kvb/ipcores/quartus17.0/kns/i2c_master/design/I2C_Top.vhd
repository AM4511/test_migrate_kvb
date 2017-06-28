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
--  Name: I2C_Top.vhd  
-- 
--  Description: Top-level module of the I2C Master Controller design
--      This design is intended to be used as a master controller
--      for a I2C Bus. The user will use this module to read or
--      write from the a I2C Bus.
--
--  Code Revision History :
---------------------------------------------------------------------------
-- Ver: | Author		|Mod. Date	    |Changes Made:
-- V1.0 | 				|2004           |Initial ver
-- V1.1 | CM        	|2009           |remove signals not being used
--                                   |remove delay module, not being used  
-- R.CARICKHOFF      |2012           |Added fifo data buffer
-- R.CARICKHOFF      |2015           |Added Avalon Interface
-- R.CARICKHOFF		05/24/2016		 |Disable SCL when I2C not active
--
-- I2C COMMAND STATUS REGISTER (READ ONLY)
-- 	7 – BUS BUSY
--    6 – TRANSACTION ERROR
--    5 – ABORT COMPLETED BY CONTROLLER
--    4 – LOST ARBITRATION BIT
--    3 – TRANSACTION DONE
--		2 – TRANSMIT BUFFER FULL
--    1 – TRANSMIT BUFFER EMPTY
--    0 – RECEIVE BUFFER EMPTY
---------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity I2C_top is
  port(SDA        	: inout std_logic;              -- Serial Data Line of the I2C bus
       SCL        	: inout std_logic;              -- Serial Clock Line of the I2C bus
       clk     		: in std_logic;                 -- 125mhz clock (8nsec) 
       reset    		: in std_logic;                 
       s_chipselect	: in std_logic;                 
       s_address  	: in std_logic_vector(2 downto 0);  
       s_write       : in std_logic;                 
       s_read        : in std_logic;                 
	    s_writedata   : in std_logic_vector(7 downto 0); 
       s_readdata    : out std_logic_vector(7 downto 0);                          
		 s_waitrequest : out std_logic;
       s_irq         : out std_logic);
end I2C_top;

architecture behave of I2C_top is

-- Local signal names
signal Clock			: std_logic;					  -- MPU Clock 
signal Reset_L    	: std_logic;                 -- Reset, active low
signal CS_L       	: std_logic;                 -- Chip select, active low
signal A          	: std_logic_vector(2 downto 0);  -- Address bits for register selection
signal WEN        	: std_logic;                 -- write enable active low
signal REN        	: std_logic;                 -- read enable active low
signal DIN        	: std_logic_vector(7 downto 0); -- data bus input
signal INTR_L     	: std_logic; 					  -- one clock low active pulse
signal DOUT       	: std_logic_vector(7 downto 0); -- data bus output NOTE: Data(7) is MSB   
signal ready_reset 	: std_logic;  
signal ready1 			: std_logic;  
signal ready2 			: std_logic;  
signal ready3 			: std_logic;  
signal ready4 			: std_logic;  

--I2C Control Signals
signal Start_Enable          : std_logic;
signal Stop_Enable           : std_logic;
signal Start_Det_Bit         : std_logic;
signal Stop_Det_Bit          : std_logic;
signal SDA_EN_1              : std_logic; -- start bit
signal SDA_EN_2              : std_logic; -- data bits
signal SDA_EN_3              : std_logic; -- stop bit

signal SDA_EN_1_out          : std_logic; -- start bit delayed
signal SDA_EN_2_out          : std_logic; -- data bits delayed
signal SDA_EN_3_out          : std_logic; -- stop bit delayed

signal SCL_CK                : std_logic;
signal SCL_synch             : bit;
signal SDA_synch             : bit;
signal Bit_Count             : std_logic_vector(2 downto 0);
signal Bit_Count_Enable      : std_logic;
signal Byte_Count_Enable     : std_logic;
signal Bit_Count_Flag        : std_logic;
signal Byte_Count_Flag       : std_logic;
signal Trans_Buf_Empty_Set   : std_logic;
signal Read_Buf_Full_Set     : std_logic;
signal Iack_Clear            : std_logic;
signal Go_Clear              : std_logic;
signal Trans_Buffer_Empty    : std_logic;
signal Read_Buffer_Full      : std_logic;  -- this signal not used
signal abits                 : std_logic_vector(2 downto 0);

signal SDA1                  : bit;
signal SCL1                  : bit;
signal wcsack                : std_logic;
signal rcsack                : std_logic;

--Register Blocks
signal Command_Reg   : std_logic_vector(7 downto 0);            -- CMD part of Command_Status Reg Contains:
                                                                -- Go, Abort, Iack, I2C_Mode,
                                                                -- I2C_address Size, Trans_IE and Recieve_IE. 
signal Status_Reg    : std_logic_vector(7 downto 0);            -- Status part of Command_Status Reg Contains:
                                                                -- I2C_Bus_Busy(7), Error(6), Abort_Ack(5), Lost_Arb(4), 
                                                                -- Trans_Done(3), Trans_Buf_Empty(1),
                                                                -- and Recieve_Buf_Full(0)
                                                                -- I2C bus busy,and retry count

signal Read_Buffer       : std_logic_vector(7 downto 0);        -- Data for I2C Read transaction
signal Trans_Buffer      : std_logic_vector(7 downto 0);        -- Data for I2C Write transaction
signal Low_Address_Reg   : std_logic_vector(7 downto 0);        -- Low order Address bits for I2C Slave
signal dummy		       : std_logic_vector(2 downto 0);        -- uppder order address bits are not used
signal Byte_Count_Reg    : std_logic_vector(7 downto 0);        -- I2C Transaction Byte Count
  
-- Command Register Bits ( Written from MPU)
signal I2C_GO         : std_logic;
signal I2C_Abort      : std_logic;
signal I2C_Resv5      : std_logic;
signal I2C_Resv4      : std_logic;
signal I2C_Iack       : std_logic;
signal I2C_Mode       : std_logic;
signal I2C_Resv1      : std_logic;
signal I2C_Resv2      : std_logic;
signal I2C_Done_IE    : std_logic;

-- Status Register Bits
signal I2C_Bus_Busy   : std_logic;
signal I2C_Abort_Ack  : std_logic;
signal I2C_Error      : std_logic;
signal I2C_Lost_Arb   : std_logic; -- 0 indicates lost arbitration
signal I2C_Done       : std_logic; 
signal I2C_TB_Full    : std_logic;
signal I2C_TB_Empty   : std_logic;
signal I2C_RB_Empty   : std_logic;      

-- I2C Read/Write Bit
signal I2C_RW_Bit     : std_logic;

signal SCL_i          : std_logic;
signal enbl_xfer      : std_logic;                    
signal GO_flag        : std_logic;    
signal Stop_Delay     : std_logic; 
signal SCL_CK2        : std_logic;  

--============================================================================
--Component Declarations
--============================================================================
component MPU_to_I2C 
  port(MPU_CLK            : in std_logic;                       -- Main Clock
       Rst_L              : in std_logic;                       -- Main Reset, active low
       CS_L               : in std_logic;                       -- Chip select, active low
       Addr_Bits          : in std_logic_vector(2 downto 0);    -- Address bits A0, A1, A2. Used for register sel
       WEN                : in std_logic;                       -- write enable active low
       REN                : in std_logic;                       -- read enable active low
	    DIN                : in std_logic_vector(7 downto 0);    -- Data bus input
       Read_Buffer        : in std_logic_vector(7 downto 0);    -- I2C Data Read in
       Status             : in std_logic_vector(4 downto 0);    -- Status part of Command_Status Reg Contains:
                                                                -- I2C_Bus_Busy, Abort_Ack, Lost_Arb, Error,Done
                                                                -- Does not include: Trans_Buf_Empty,
                                                                -- and Recieve_Buf_Full
       TBE_Set            : in std_logic;                       -- TBE_Set flag, set Trans_Buf_Empty to empty                                                                   
       RBF_Set            : in std_logic;                       -- RBF_Set flag, set Read_Buff_Full  to full                                                                    
       Iack_Clear         : in std_logic;                       -- Clears the Iack
       Go_Clear           : in std_logic;                       -- Clears Go Bit
       Low_Address_Reg    : out std_logic_vector(7 downto 0);   -- Low order Address bits for I2C Slave 
       Upper_Address_Reg  : out std_logic_vector(2 downto 0);   -- High order Address bits for I2C Slave
       Byte_Count_Reg     : out std_logic_vector(7 downto 0);   -- I2C Transaction Byte Count
       Command_Reg        : out std_logic_vector(7 downto 0);   -- CMD part of Command_Status Reg Contains:
                                                                -- Go, Abort,Iack, I2C_Mode,
                                                                -- I2C_address Size, Trans_IE and Recieve_IE. 
       Trans_Buffer       : out std_logic_vector(7 downto 0);    -- Holds Data for I2C Write transaction
       Trans_Buffer_Empty : out std_logic;                      -- 0 indicates that the trans buffer is empty
       Read_Buffer_Full   : out std_logic;                      -- 0 indicates that the read buffer is not full
       Iack               : out std_logic;                      -- interrupt acknowledge
       DOUT               : out std_logic_vector(7 downto 0));  -- Data bus output (NOTE: Data(7) is MSB                         
end component;

component I2C_Main 
  port(MPU_CLK           : in std_logic;                        -- MP Clock 
       Rst_L             : in std_logic;                        -- Main Reset, active low
       SCL               : in bit;                              -- I2C F/S mode Clock
       SDA               : in bit;                              -- SDA
       Bit_Count         : in std_logic_vector(2 downto 0);     -- Bit count for I2C packets
       Bit_Cnt_Flag      : in std_logic;                        -- Bit Count overflow flag
       Byte_Cnt_Flag     : in std_logic;                        -- Byte Count overflow flag
       Trans_Buffer      : in std_logic_vector(7 downto 0);     -- Data from MPU for I2C Write
       Low_Address_Reg   : in std_logic_vector(7 downto 0);     -- Low order Address bits for I2C Slave
       Lost_Arb          : in std_logic;                        -- Lost Arbitration Bit
       Start_Det         : in std_logic;                        -- I2C Start Detect
       Stop_Det          : in std_logic;                        -- I2C Stop Detect       
       Command_Reg       : in std_logic_vector(1 downto 0);     -- CMD part of Command_Status Reg Contains:
                                                                -- Go, Abort Does not include:I2C_Mode, 
                                                                --  I2C_address Size, Iack,Trans_IE and Recieve_IE.      
       Status            : out std_logic_vector(3 downto 0);    -- Status part of Command_Status Reg Contains:
                                                                -- I2C_Bus_Busy(3), Abort_Ack(2), Error(1), Done(0)
                                                                -- Does not include:Trans_Buf_Empty, Recieve_Buf_Full,
                                                                -- Lost_Arb. Lost Arb comes from arbiter
       Read_Buffer       : out std_logic_vector(7 downto 0);    -- I2C read data byte                                                                   
       Bit_Cnt_EN        : out std_logic;                       -- Bit count enable
       Byte_Cnt_EN       : out std_logic;                       -- Byte count enable
       Start_EN          : out std_logic;                       -- Start enable
       Stop_EN           : out std_logic;                       -- Stop enable
       SDA_EN1           : out std_logic;                       -- SDA enable for data bits
       TBE_Set           : out std_logic;                       -- set Transmit_Buffer_Empty flag for MPU block
       RBF_Set           : out std_logic;                       -- set Recieve_Buffer_Full flag for MPU block
       Go_Clear          : out std_logic;                      -- Request to clear go bit
       WCS_Ack           : out std_logic;
       RCS_Ack           : out std_logic);
end component;

component Synch_Block 
  port(MPU_CLK     : in std_logic;                       
       Rst_L       : in std_logic;                       
       SCL         : in bit;
       SDA         : in bit;
       SCL_synch   : out bit;
       SDA_synch  : out bit);
end component;

component I2C_Clock_Generator 
  generic (cnt_f_hi: integer := 156;   --                         fast   count hi time
           cnt_f_lo: integer := 311;   -- 400KHz at 125Mhz clk    fast   count lo time
           cnt_s_hi: integer := 625;   -- 								std.   count hi time
           cnt_s_lo: integer := 1249); -- 100KHz at 125Mhz clk    std.   count lo time
  port(MPU_CLK    : in std_logic;                       -- MP Clock 
       Rst_L      : in std_logic;                       -- Main Reset, active low
       Mode       : in std_logic;                       -- I2C mode from command register
       Abort      : in std_logic;                       -- abort from command register
       SCL_CK2    : out std_logic;                      -- Serial clock pulse
       SCL_CK     : out std_logic);                     -- Serial Clock Line of the I2C bus
end component;

component Counter_Block
  port(MPU_CLK        : in std_logic;                     -- MP Clock 
       Rst_L          : in std_logic;                     -- Main Reset, active low
       SCL            : in bit;                           -- SCL
       Abort          : in std_logic;                     -- Abort
       Byte_Cnt_EN    : in std_logic;                     -- Byte Count Enable
       Bit_Cnt_EN     : in std_logic;                     -- Bit Count Enable
       go             : in std_logic;                     -- go bit for restarts
       Byte_Count_Reg : in std_logic_vector(7 downto 0);  -- Byte Count Register setup from MPU
       Bit_Count      : out std_logic_vector(2 downto 0);  -- Bit Count 
       Bit_Cnt_Flag   : out std_logic;                     -- Bit Count overflow flag
       Byte_Cnt_Flag  : out std_logic);                    -- Byte Count overflow flag
end component;

component Arbitrator 
  port(MPU_CLK       : in std_logic;                    -- MPU Clock
       Rst_L         : in std_logic;                    -- Main I2C Reset
       SCL           : in bit;                          -- I2C Clock for f/s mode 
       SDA           : in bit;                          -- I2C data bus for f/s mode
       SDA_EN1       : in std_logic;                    -- sda enable
       SDA_EN2       : in std_logic;                    -- sda enable
       SDA_EN3       : in std_logic;                    -- sda enable
       WCS_Ack       : in std_logic;                    -- Write State Ack Bit
       RCS_Ack       : in std_logic;                    -- Read State Ack Bit
       Lost_ARB      : out std_logic);                  -- Lost Arbitration bit
end component;

component Int_Ctrl_Block 
  port(MPU_CLK             : in std_logic;                        -- MPU clock
       RST_L               : in std_logic;                        -- Global reset
       abort               : in std_logic;                        -- abort 
       I2C_Done_IE         : in std_logic;                        -- Done interrupt enable from MPU
       I2C_Bus_Busy        : in std_logic;                        -- Tranfer busy
       INTR_L              : out std_logic);                      -- Interrupt Request to MPU
end component;

component Start_Generator 
  port(MPU_CLK       : in std_logic;                    -- MPU Clock
       Rst_L         : in std_logic;                    -- Main Reset
       Start_Enable  : in std_logic;                    -- Start Enable, activates start gen process
       SCL           : in bit;                          -- I2C Clock for f/s mode 
       SDA           : in bit;                          -- I2C data bus for f/s mode        
       SDA_EN2       : out std_logic);                  -- sda enable
end component;

component Start_Detect 
  port(MPU_CLK       : in std_logic;                    -- MPU Clock
       Rst_L         : in std_logic;                    -- Main Reset
       SCL           : in bit;                          -- I2C Clock for f/s mode 
       SDA           : in bit;                          -- I2C data bus for f/s mode        
       Start_Det     : out std_logic);                  -- start detection bit
end component;

component Stop_Generator 
  port(MPU_CLK       : in std_logic;                    -- MPU Clock
       Rst_L         : in std_logic;                    -- Main Reset
       Stop_Enable   : in std_logic;                    -- Stop Enable, activates stop gen process
       SCL           : in bit;                          -- I2C Clock for f/s mode 
       SDA           : in bit;                          -- I2C data bus for f/s mode        
       SDA_EN3       : out std_logic);                  -- sda enable
end component;

component Stop_Detect 
  port(MPU_CLK       : in std_logic;                    -- MPU Clock
       Rst_L         : in std_logic;                    -- Main Reset
       SCL           : in bit;                          -- I2C Clock for f/s mode 
       SDA           : in bit;                          -- I2C data bus for f/s mode        
       Stop_Det      : out std_logic);                  -- stop detection bit
end component;

component Delay_SDA 
  port(MPU_CLK     : in std_logic;
       Rst_L       : in std_logic;                       
       SDA_EN      : in std_logic;
       SDA_EN_Out  : out std_logic);
end component;

begin
--======================================================================================
-- Avalon Interface conversion done here
--======================================================================================
Clock 						<= clk;
Reset_L 						<= not reset;
CS_L 							<= not s_chipselect;
A(2 downto 0)				<= s_address(2 downto 0);
WEN 							<= not s_write;
REN      					<= not s_read;
DIN(7 downto 0) 			<= s_writedata(7 downto 0); 
s_readdata(7 downto 0)  <= DOUT(7 downto 0);
s_waitrequest				<= (s_write or s_read) and ((s_write and not ready4) or (s_read and not ready3)); 
                      
ready_reset 				<= ((not s_write) and (not s_read)) or reset;
  
process(clk,ready_reset,s_write,s_read)
  begin
		if(ready_reset = '1') then
			ready1 <= '0';
			ready2 <= '0';
			ready3 <= '0';
			ready4 <= '0';
		elsif clk'event and clk = '1' then
			if (s_write = '1' or s_read = '1') then
				ready1 <= '1';
				ready2 <= ready1;
				ready3 <= ready2;
				ready4 <= ready3;
			end if;
		end if;
end process; 

-- reading status register after irq
process (clk, reset, s_chipselect, s_read, abits)
begin
	if (reset = '1') then
		s_irq <= '0';
	elsif clk'event and clk = '1' then
		if (INTR_L = '0') then
			s_irq <= '1'; -- set irq
		elsif (s_chipselect = '1' and s_read = '1' and abits = "100") then
			s_irq <= '0'; -- reset irq
		end if;			
	end if;
end process;

--=======================================================================================
-- Key Register signal assignments: GO, Abort, and Mode
--=======================================================================================
I2C_GO         <= Command_Reg(7);
I2C_Abort      <= Command_Reg(6);
I2C_Resv5      <= Command_Reg(5);
I2C_Resv4      <= Command_Reg(4);
I2C_Mode       <= Command_Reg(3);
I2C_Resv2      <= Command_Reg(2);
I2C_Resv1      <= Command_Reg(1);
I2C_Done_IE    <= Command_Reg(0);
I2C_RW_Bit     <= Low_Address_Reg(0);

--Status Register Assignments
I2C_Bus_Busy   <= Status_Reg(7); -- comes from I2C_Main   
I2C_Error      <= Status_Reg(6); -- comes from I2C_Main 
I2C_Abort_Ack  <= Status_Reg(5); -- comes from I2C_Main    
I2C_Lost_Arb   <= Status_Reg(4); -- comes from Arbitrator  
I2C_Done       <= Status_Reg(3); -- comes from I2C_Main   
I2C_TB_Full    <= Status_Reg(2); -- found in MPU_to_I2C
I2C_TB_Empty   <= Status_Reg(1); -- found in MPU_to_I2C
I2C_RB_Empty   <= Status_Reg(0); -- found in MPU_to_I2C      

process(clk, reset, I2C_GO, Start_Det_Bit, Stop_Enable, SCL_i, Stop_Delay)
 begin
   if(reset = '1') then
     enbl_xfer <= '0';
     GO_flag <= '0';
     Stop_Delay <= '0';
   elsif(rising_edge(clk)) then 
     if(I2C_GO = '1') then  
       GO_flag <= '1';
     elsif (GO_flag = '1') then
       if (Start_Det_Bit = '1') then
         enbl_xfer <= '1';
         GO_flag <= '0';
       end if;
     elsif (Stop_Enable = '1' and SCL_i = '1') then
       Stop_Delay <= '1';
       enbl_xfer <= '0';
     elsif (Stop_Delay = '1' and SCL_i = '1' and SCL_CK2 = '1') then
       Stop_Delay <= '0';
     end if;
   end if;
 end process;        

SDA1  <= To_bit(SDA);
SCL1  <= To_bit(SCL_i);
SCL_i <= '0' when SCL_CK = '1' else '1';   -- invert clock

--============================================================================
--SCL, SCLH, SDA, and SDAH drivers
--============================================================================
SCL <= 'Z' when enbl_xfer = '0' else SCL_i;

SDA <= '0' when (SDA_EN_1_out = '1') or (SDA_EN_2_out = '1') or (SDA_EN_3_out = '1') or (Stop_Delay = '1' and I2C_RW_Bit = '0') else 'Z';

--=============================================================================
-- Use for running simulation
--=============================================================================
--SCL <= '1' when enbl_xfer = '0' else SCL_i;

--SDA <= '0' when (SDA_EN_1_out = '1') or (SDA_EN_2_out = '1') or (SDA_EN_3_out = '1') or (Stop_Delay = '1' and I2C_RW_Bit = '0') else '1';

abits <= A;
Iack_Clear <= '0';	-- unused input from previous design; tie off to GND

MPU_to_I2C_1 : MPU_to_I2C port map
               (MPU_CLK                 => Clock,
                Rst_L                   => Reset_L,
                CS_L                    => CS_L,
                Addr_Bits               => abits, 
                WEN                     => WEN,
				    REN                     => REN,
				    DIN                     => DIN,
                Read_Buffer             => Read_Buffer,
                Status(4)               => I2C_Bus_Busy,
                Status(3)               => I2C_Error,
                Status(2)               => I2C_Abort_Ack,
                Status(1)               => I2C_Lost_Arb, 
                Status(0)               => I2C_Done, 
                TBE_Set                 => Trans_Buf_Empty_Set,
                RBF_Set                 => Read_Buf_Full_Set,
                Iack_Clear              => Iack_Clear,
                Go_Clear                => Go_Clear,
                Low_Address_Reg         => Low_Address_Reg,
                Upper_Address_Reg       => dummy,
                Byte_Count_Reg          => Byte_Count_Reg, 
                Command_Reg             => Command_Reg,
                Trans_Buffer            => Trans_Buffer,
                Trans_Buffer_Empty      => Trans_Buffer_Empty,
                Read_Buffer_Full        => Read_Buffer_Full,
                Iack                    => I2C_Iack,
                DOUT=> DOUT);

I2C_Main_1 : I2C_Main port map
               (MPU_CLK           => Clock,
                Rst_L             => Reset_L,
                SCL               => SCL_synch,
                SDA               => SDA_synch,
                Bit_Count         => Bit_Count,
                Bit_Cnt_Flag      => Bit_Count_Flag,
                Byte_Cnt_Flag     => Byte_Count_Flag,
                Trans_Buffer      => Trans_Buffer, 
                Low_Address_Reg   => Low_Address_Reg,
                Lost_Arb          => I2C_Lost_Arb,
                Start_Det         => Start_Det_Bit,
                Stop_Det          => Stop_Det_Bit,
                Command_Reg(1)    => I2C_GO, 
                Command_Reg(0)    => I2C_Abort,
                Status(3 downto 1)  => Status_Reg(7 downto 5),
                Status(0)         => Status_Reg(3),
                Read_Buffer       => Read_Buffer,
                Bit_Cnt_EN        => Bit_Count_Enable,
                Byte_Cnt_EN       => Byte_Count_Enable,
                Start_EN          => Start_Enable,
                Stop_EN           => Stop_Enable,
                SDA_EN1           => SDA_EN_1,
                TBE_Set           => Trans_Buf_Empty_Set,
                RBF_Set           => Read_Buf_Full_Set,
                Go_Clear          => Go_Clear,
                WCS_Ack           => wcsack,
                RCS_Ack           => rcsack);


Synch_1 : Synch_Block port map
              (MPU_CLK => Clock, Rst_L => Reset_L, SCL => SCL1, SDA => SDA1,
               SCL_synch => SCL_synch, SDA_synch => SDA_synch);


I2C_Clock_Gen_1 : I2C_Clock_Generator 
                 generic map
                  (cnt_f_hi => 156,
                   cnt_f_lo => 311, -- 400KHz at 125Mhz clk
                   cnt_s_hi => 625,
                   cnt_s_lo => 1249) -- 100KHz at 125Mhz clk


                 port map
                  (MPU_CLK => Clock,
                   Rst_L   => Reset_L, 
                   Mode    => I2C_Mode, 
                   Abort   => I2C_Abort,
                   SCL_CK2  => SCL_CK2,
                   SCL_CK  => SCL_CK);

Counter_Blk_1 : Counter_Block port map
               (MPU_CLK => Clock, 
                Rst_L   => Reset_L,
                SCL     => SCL_synch, 
                Abort   => Command_Reg(6), 
                Byte_Cnt_EN    => Byte_Count_Enable,
                Bit_Cnt_EN     => Bit_Count_Enable,
                Go             => I2C_GO,
                Byte_Count_Reg => Byte_Count_Reg, 
                Bit_Count      => Bit_Count,
                Bit_Cnt_Flag   => Bit_Count_Flag,
                Byte_Cnt_Flag  => Byte_Count_Flag); 

Arb_1 : Arbitrator port map
       (MPU_CLK  => Clock,
        Rst_L    => Reset_L, 
        SCL      => SCL_synch,
        SDA      => SDA_synch,
        SDA_EN1  => SDA_EN_1,
        SDA_EN2  => SDA_EN_2, 
        SDA_EN3  => SDA_EN_3,
        WCS_Ack  => wcsack,
        RCS_Ack  => rcsack,
        Lost_ARB => status_reg(4));

Int_Ctrl_1 : Int_Ctrl_Block port map
             (MPU_CLK              => Clock,
              RST_L                => Reset_L,
              abort                => I2C_Abort,
              I2C_Done_IE          => I2C_Done_IE,
              I2C_Bus_Busy         => I2C_Bus_busy,
              INTR_L               => INTR_L);

Start_Gen_1: Start_Generator port map
             (MPU_CLK      => Clock, 
              Rst_L        => Reset_L,
              Start_Enable => Start_Enable,
              SCL          => SCL_synch, 
              SDA          => SDA_synch,
              SDA_EN2      => SDA_EN_2);

Start_Det_1: Start_Detect port map
             (MPU_CLK   => Clock, 
              Rst_L     => Reset_L, 
              SCL       => SCL_synch,
              SDA       => SDA_synch,
              Start_Det => Start_Det_Bit);

Stop_Gen_1: Stop_Generator port map
             (MPU_CLK      => Clock, 
              Rst_L        => Reset_L,
              Stop_Enable  => Stop_Enable,
              SCL          => SCL_synch, 
              SDA          => SDA_synch,
              SDA_EN3      => SDA_EN_3);

Stop_Det_1: Stop_Detect port map
             (MPU_CLK   => Clock, 
              Rst_L     => Reset_L, 
              SCL       => SCL_synch,
              SDA       => SDA_synch,
              Stop_Det  => Stop_Det_Bit);

delay_1: Delay_SDA port map
         (MPU_CLK    => Clock,
          Rst_L      => Reset_L,
          SDA_EN     => SDA_EN_1,
          SDA_EN_Out => SDA_EN_1_out);

delay_2: Delay_SDA port map
         (MPU_CLK    => Clock,
          Rst_L      => Reset_L,
          SDA_EN     => SDA_EN_2,
          SDA_EN_Out => SDA_EN_2_out);

delay_3: Delay_SDA port map
         (MPU_CLK    => Clock,
          Rst_L      => Reset_L,
          SDA_EN     => SDA_EN_3,
          SDA_EN_Out => SDA_EN_3_out);
end behave;

--------------------------------- E O F --------------------------------------

