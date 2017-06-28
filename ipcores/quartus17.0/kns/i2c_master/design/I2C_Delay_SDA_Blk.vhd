---------------------------------------------------------------------------
--  >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
---------------------------------------------------------------------------
--  Copyright (c) 1999 - 2009 by Lattice Semiconductor Corporation      
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
--  Name:  I2C_Delay_SDA_Blk.vhd 
-- 
--  Description: Delays the SDA to meet setup and hold times
-- 
--
-- Code Revision History :
---------------------------------------------------------------------------
-- Ver  | Author       | Mod. Date | Changes Made:
---------------------------------------------------------------------------
-- 1.0  | RCARICKHOFF  | 06/24/16  | Create
--------------------------------------------------------------------------- 


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity Delay_SDA is
  port(MPU_CLK     : in std_logic;
       Rst_L       : in std_logic;                       
       SDA_EN      : in std_logic;
       SDA_EN_Out  : out std_logic);
end Delay_SDA;

architecture Delay_Behave of Delay_SDA is

signal count    : integer range 0 to 30;
signal sda_en1  : std_logic;
signal sda_en2  : std_logic;
signal sda_pls  : std_logic;
signal sda_sav  : std_logic;

constant DELAY_TIME  : integer := 22; -- 8ns * (22 + 3) = 200ns

begin

process(MPU_CLK, RST_L, SDA_EN) 
 begin                      
   if(RST_L = '0') then
     sda_en1 <= '0';
     sda_en2 <= '0';
   elsif (rising_edge(MPU_CLK)) then  
     sda_en1 <= SDA_EN;
     sda_en2 <= sda_en1;
   end if;
 end process;

sda_pls <= sda_en1 xor sda_en2;
 
Delay: process(MPU_CLK, RST_L, SDA_EN) 
 begin                      
   if(RST_L = '0') then
     count <= 0;
     sda_sav <= '0'; 
     SDA_EN_Out <= '0';
   elsif (rising_edge(MPU_CLK)) then  
     if (sda_pls = '1') then  
       count <= 0;
       sda_sav <= SDA_EN;
     elsif (count = DELAY_TIME) then
       SDA_EN_out <= sda_sav;
     else                    --     count
       count <= count + 1;
     end if;
   end if;
 end process;

end Delay_Behave;

--------------------------------- E O F --------------------------------------
