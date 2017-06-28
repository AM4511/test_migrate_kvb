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
--  Name:   I2C_Clk_Blk.vhd
-- 
--  Description: Generate SCL clock line for the I2C bus
-- 
--  Code Revision History :
---------------------------------------------------------------------------
-- Ver: | Author			|Mod. Date	|Changes Made:
-- V1.0 | 				|2004           |Initial ver
---------------------------------------------------------------------------



library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity I2C_Clock_Generator is
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

end I2C_Clock_Generator;


architecture Clk_Gen_Behave of I2C_Clock_Generator is
signal count : integer range 0 to 1249;
signal Reset : std_logic;
constant cnt_f_ck2 : integer := cnt_f_lo - 10;
constant cnt_s_ck2 : integer := cnt_s_lo - 10;

begin

 Reset <= '0' when RST_L = '0' or Abort = '1' else '1';
 
 counter:process(MPU_CLK,Reset,Mode)
 begin
  if(Reset = '0') then
   count <= 0;
  elsif (rising_edge(MPU_CLK)) then    
    if ((Mode = '0') and (count >= cnt_s_lo)) then     --     std roll over 
        count <= 0;
    elsif ((Mode = '1') and (count >= cnt_f_lo)) then  --     fast roll over 
        count <= 0;
    else                                              --     count
        count <= count + 1;
    end if;
  end if;
 end process;
     
 std_fast:process(MPU_CLK,Reset,count,Mode)
 begin
  if(Reset = '0') then
   SCL_CK    <= '0';
   SCL_CK2 <= '0';
  elsif (rising_edge(MPU_CLK)) then    
    if((Mode = '1') and (count = cnt_f_lo)) then
        SCL_CK    <= '1';
        SCL_CK2   <= '0';    
    elsif((Mode = '0') and (count = cnt_s_lo)) then
        SCL_CK    <= '1';
        SCL_CK2   <= '0';    
    elsif((Mode = '1') and (count = cnt_f_hi)) then
        SCL_CK <= '0';
    elsif((Mode = '0') and (count = cnt_s_hi)) then
        SCL_CK <= '0';    
    elsif((Mode = '1') and (count = cnt_f_ck2)) then
        SCL_CK2 <= '1';
    elsif((Mode = '0') and (count = cnt_s_ck2)) then
        SCL_CK2 <= '1';    
    end if;
  end if;  
 end process;
end Clk_Gen_Behave;
       
--------------------------------- E O F --------------------------------------
