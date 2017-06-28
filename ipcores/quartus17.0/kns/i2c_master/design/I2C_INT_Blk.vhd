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
--  Name:  I2C_INT_Blk.vhd
-- 
--  Description:  Initalize Interupt and ACK signals
--
--  Code Revision History :
---------------------------------------------------------------------------
-- Ver: | Author		|Mod. Date	Changes Made:
-- V1.0 | 				|2004       Initial ver
-- R.CARICKHOFF     	2012       	Generate pulse interrupt when transfer done
-- R.CARICKHOFF		2016			Added Done_IE to enable interrupt	
---------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity Int_Ctrl_Block is
  port(MPU_CLK             : in std_logic;                        -- MPU clock
       RST_L               : in std_logic;                        -- Global reset
       abort               : in std_logic;                        -- abort 
       I2C_Done_IE         : in std_logic;                        -- Transfer Done interrupt enable from MPU
       I2C_Bus_Busy        : in std_logic;                        -- Transfer Bus Busy
       INTR_L              : out std_logic);                      -- Interrupt Request to MPU
end Int_Ctrl_Block;

architecture Int_Behave of Int_Ctrl_Block is

signal reset  : std_logic;
signal intr1  : std_logic;
signal intr2  : std_logic;
signal intr3  : std_logic;
signal intr   : std_logic;

begin

  reset <= '0' when RST_L = '0' or abort = '1' else '1';
    
  process(MPU_CLK,reset,I2C_Bus_Busy,I2C_Done_IE)
  begin
    if(rising_edge(MPU_CLK)) then
	    if(reset = '0') then
			intr1 <= '0';
			intr2 <= '0';
			intr3 <= '0';
			intr  <= '0';
		else
			intr1 <= I2C_Bus_Busy;
			intr2 <= intr1;
			intr3 <= intr2;
			intr  <= not intr1 and intr3 and I2C_Done_IE;
		end if;
    end if;  
  end process; 
  	    
  INTR_L <= not intr;  -- generate low active interrupt pulse    
end Int_Behave;

--------------------------------- E O F --------------------------------------
