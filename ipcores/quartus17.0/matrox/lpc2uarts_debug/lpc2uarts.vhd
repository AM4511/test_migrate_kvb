-----------------------------------------------------------------------
-- $HeadURL:$
-- $Author: amarchan $
-- $Revision: 16534 $
-- $Date: 2016-07-25 15:44:38 -0400 (Mon, 25 Jul 2016) $
-----------------------------------------------------------------------
-- Name:        lpc2uarts.vhd
-- Type:        Module
-- Project:     KVB
--
-- DESCRIPTION: LPC bridge to uarts (4 X UART)
--              This file contains 4 UARTS from the IRIS3 Project
-----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity lpc2uarts is
  port (

    ---------------------------------------------------------------------------
    -- Low Pin Count (LPC) Interface
    ---------------------------------------------------------------------------
    lpc_clk     : in    std_logic;
    lpc_reset_n : in    std_logic;
    lpc_frame_n : in    std_logic;
    lpc_ad      : inout std_logic_vector(3 downto 0);
    serirq      : inout std_logic;

    ---------------------------------------------------------------------------
    -- UARTs I/F
    ---------------------------------------------------------------------------
    ser_rx     : in  std_logic_vector(3 downto 0);
    ser_tx     : out std_logic_vector(3 downto 0);
    ser4_rts_n : out std_logic
    );
end lpc2uarts;


architecture struct of lpc2uarts is

  attribute ASYNC_REG  : string;
  attribute mark_debug : string;


  component lpc_target is
    port (
      lpc_clk             : in  std_logic;
      lpc_reset_n         : in  std_logic;
      lpc_frame_n         : in  std_logic;
      lpc_ad              : out std_logic_vector(3 downto 0);
      lpc_ad_in_ff        : in  std_logic_vector(3 downto 0);
      lpc_reset_out       : out std_logic;
      local_address       : out std_logic_vector(31 downto 0);
      local_memory_not_io : out std_logic;
      local_read          : out std_logic;
      local_write         : out std_logic;
      local_write_data    : out std_logic_vector(7 downto 0);
      local_read_data     : in  std_logic_vector(7 downto 0);
      local_address_hit   : in  std_logic;
      local_access_done   : in  std_logic
      );
  end component;


  ------------------------------------------------------------------------------
  -- 
  ------------------------------------------------------------------------------
  component uart_bridge_24mhz is
    generic (
      UART_ADDRESS : std_logic_vector(15 downto 0)
      );
    port (
      local_clk           : in     std_logic;
      local_reset         : in     std_logic;
      local_address       : in     std_logic_vector(31 downto 0);
      local_memory_not_io : in     std_logic;
      local_read          : in     std_logic;
      local_write         : in     std_logic;
      local_write_data    : in     std_logic_vector(7 downto 0);
      local_read_data     : out    std_logic_vector(7 downto 0);
      local_address_hit   : buffer std_logic;
      local_access_done   : buffer std_logic;
      clk_24MHz           : in     std_logic;
      uart_clk            : buffer std_logic := '0';
      uart_CS_n           : buffer std_logic;                     -- enable
      uart_Rd_n           : out    std_logic;                     -- read
      uart_Wr_n           : out    std_logic;                     -- write
      uart_A              : out    std_logic_vector(2 downto 0);  -- address
      uart_D_In           : out    std_logic_vector(7 downto 0);  -- data in 
      uart_D_Out          : in     std_logic_vector(7 downto 0)   -- data out
      );
  end component;


  ------------------------------------------------------------------------------
  -- 
  ------------------------------------------------------------------------------
  component uart_16550 is
    port (
      ---------------------------------------------------------------------
      -- Register interface
      ---------------------------------------------------------------------
      MR_n  : in  std_logic;                     -- reset
      XIn   : in  std_logic;                     -- clock
      RClk  : in  std_logic;                     -- connected to BAUD_OUT
      CS_n  : in  std_logic;                     -- enable
      Rd_n  : in  std_logic;                     -- read
      Wr_n  : in  std_logic;                     -- write
      A     : in  std_logic_vector(2 downto 0);  -- address
      D_In  : in  std_logic_vector(7 downto 0);  -- data in 
      D_Out : out std_logic_vector(7 downto 0);  -- data out

      ---------------------------------------------------------------------
      -- Connector interface
      ---------------------------------------------------------------------
      SIn                 : in  std_logic;  -- IN EIA RX DATA / RCV CL DATA
      CTS_n               : in  std_logic;  -- IN EIA CLR TO SND
      DSR_n               : in  std_logic;  -- IN EIA DATA SET RDY
      RI_n                : in  std_logic;  -- IN EIA RI
      DCD_n               : in  std_logic;  -- IN EIA CARRIER DET (RLSD)
      SOut                : out std_logic;  -- OUT EIA TX DATA
      RTS_n               : out std_logic;  -- OUT EIA RTS
      DTR_n               : out std_logic;  -- OUT EIA DTR
      OUT1_n              : out std_logic;  -- NC  
      OUT2_n              : out std_logic;  -- Interrupt Line Output Enable (active low)
      transmission_active : out std_logic;  -- Allow auto-txen under RS485
      BaudOut             : out std_logic;  -- connected to RCLK
      Intr                : out std_logic   -- Interrupt
      );
  end component;


  component lpc_serirq is
    generic(
      IRQ_LSB : natural := 3;
      IRQ_MSB : natural := 5
      );
    port (
      lpc_clk : in std_logic;
      lpc_reset        : in  std_logic;
      serirq_in_ff     : in  std_logic;
      serirq           : out std_logic;
      isa_active_level : in  std_logic_vector(IRQ_LSB to IRQ_MSB);
      isa_irq          : in  std_logic_vector(IRQ_LSB to IRQ_MSB)
      );
  end component;


  -----------------------------------------------------------------------------
  --                            UART MAPPING                                 --
  -----------------------------------------------------------------------------
  -- UART Number  0     1     2     3    
  --
  -- COM port     COM1  COM2  COM3  COM4 
  --
  -- BAR          3F8   2F8   3E8   2E8  
  --
  -- IRQ          4     3     5    10   
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- COM ports base addresses
  -----------------------------------------------------------------------------
  constant NUMB_UART : natural                       := 4;
  constant COM1      : std_logic_vector(15 downto 0) := x"03F8";
  constant COM2      : std_logic_vector(15 downto 0) := x"02F8";
  constant COM3      : std_logic_vector(15 downto 0) := x"03E8";
  constant COM4      : std_logic_vector(15 downto 0) := x"02E8";


  type std3_logic_vector is array (natural range <>) of std_logic_vector(2 downto 0);
  type std8_logic_vector is array (natural range <>) of std_logic_vector(7 downto 0);
  type BAR_ARRAY_TYPE is array (0 to NUMB_UART-1) of std_logic_vector(15 downto 0);

  constant UARTBASEADDR : BAR_ARRAY_TYPE := (COM1, COM2, COM3, COM4);
  constant IRQ_LSB      : natural        := 3;
  constant IRQ_MSB      : natural        := 11;

  -----------------------------------------------------------------------------
  -- Low pin count interface signals (LPC clock domain)
  -----------------------------------------------------------------------------
  signal lpc_ad_out         : std_logic_vector(3 downto 0);
  signal lpc_ad_in          : std_logic_vector(3 downto 0);
  signal lpc_reset_sync     : std_logic;
  signal lpc_local_irq_meta : std_logic_vector(NUMB_UART-1 downto 0);
  signal lpc_local_irq      : std_logic_vector(NUMB_UART-1 downto 0);
  signal lpc_isa_irq        : std_logic_vector(IRQ_LSB to IRQ_MSB) := (others => '0');
  signal lpc_isa_irq_level  : std_logic_vector(IRQ_LSB to IRQ_MSB) := (others => '1');

  -----------------------------------------------------------------------------
  -- Local bus signals (LPC clock domain)
  -----------------------------------------------------------------------------
  signal local_address          : std_logic_vector(31 downto 0);
  signal local_memory_not_io    : std_logic;
  signal local_read             : std_logic;
  signal local_write            : std_logic;
  signal local_writedata        : std_logic_vector(7 downto 0);
  signal local_readdata         : std_logic_vector(7 downto 0);
  signal local_address_hit      : std_logic;
  signal local_access_done      : std_logic;
  signal local_uart_access_done : std_logic_vector(NUMB_UART-1 downto 0);
  signal local_uart_hit         : std_logic_vector(NUMB_UART-1 downto 0);
  signal local_uart_hit_ff      : std_logic_vector(NUMB_UART-1 downto 0);
  signal local_uart_readdata    : std8_logic_vector(NUMB_UART-1 downto 0);

  -----------------------------------------------------------------------------
  -- UART register interface (Baud rate clock domain)
  -----------------------------------------------------------------------------
  signal uart_clk                 : std_logic_vector(NUMB_UART-1 downto 0);
  signal uart_CS_n                : std_logic_vector(NUMB_UART-1 downto 0);
  signal uart_Rd_n                : std_logic_vector(NUMB_UART-1 downto 0);
  signal uart_Wr_n                : std_logic_vector(NUMB_UART-1 downto 0);
  signal uart_A                   : std3_logic_vector(NUMB_UART-1 downto 0);
  signal uart_D_In                : std8_logic_vector(NUMB_UART-1 downto 0);
  signal uart_D_Out               : std8_logic_vector(NUMB_UART-1 downto 0);
  signal uart_transmission_active : std_logic_vector(NUMB_UART-1 downto 0);

  signal uart_baudout      : std_logic_vector(NUMB_UART-1 downto 0);
  signal uart_intr         : std_logic_vector(NUMB_UART-1 downto 0);
  signal uart_intr_FF      : std_logic_vector(NUMB_UART-1 downto 0);
  signal uart_reset_n_meta : std_logic_vector(NUMB_UART-1 downto 0);
  signal uart_reset_n      : std_logic_vector(NUMB_UART-1 downto 0);
  signal uart_rts_n        : std_logic_vector(NUMB_UART-1 downto 0);
  signal uart_out2_n       : std_logic_vector(NUMB_UART-1 downto 0);


  signal serirq_in_ff : std_logic;

  attribute ASYNC_REG of lpc_local_irq_meta : signal is "TRUE";


begin


  lpc_isa_irq_level <= (others => '1');

  -----------------------------------------------------------------------------
  -- LPC Address/Data Bidirectional IO management
  -----------------------------------------------------------------------------
  -- Output source of the IO. Tri-state section is controlled in the
  -- lpc_target Module
  lpc_ad <= lpc_ad_out;

  -- Input FF of the bidir IO.
  P_lpc_ad_in : process(lpc_clk)
  begin
    if rising_edge(lpc_clk) then
      lpc_ad_in <= lpc_ad;
    end if;
  end process;


  ------------------------------------------------------------------------------
  -- lpc_target
  ------------------------------------------------------------------------------
  xlpctarget : lpc_target
    port map(
      lpc_clk             => lpc_clk,
      lpc_reset_n         => lpc_reset_n,
      lpc_frame_n         => lpc_frame_n,
      lpc_ad              => lpc_ad_out,
      lpc_ad_in_ff        => lpc_ad_in,
      lpc_reset_out       => lpc_reset_sync,
      local_address       => local_address,
      local_memory_not_io => local_memory_not_io,
      local_read          => local_read,
      local_write         => local_write,
      local_write_data    => local_writedata,
      local_read_data     => local_readdata,
      local_address_hit   => local_address_hit,
      local_access_done   => local_access_done
      );


  -----------------------------------------------------------------------------
  -- Module(s)   : 4 x Bridge + UART
  -- Entities    : uart_bridge_24mhz, uart_16550 from Spider_LPC
  -- Description : 4 x Instantiation of a UART (16550) and its LPC to UART
  --               bridge
  -----------------------------------------------------------------------------
  G_UART : for i in 0 to NUMB_UART-1 generate

    ------------------------------------------------------------------------------
    -- UART Bridge
    ------------------------------------------------------------------------------
    bridge : uart_bridge_24mhz
      generic map(
        UART_ADDRESS => UARTBASEADDR(i)
        )
      port map(
        local_clk           => lpc_clk,
        local_reset         => lpc_reset_sync,
        local_address       => local_address,
        local_memory_not_io => local_memory_not_io,
        local_read          => local_read,
        local_write         => local_write,
        local_write_data    => local_writedata,
        local_read_data     => local_uart_readdata(i),
        local_address_hit   => local_uart_hit(i),
        local_access_done   => local_uart_access_done(i),
        clk_24MHz           => lpc_clk,
        uart_clk            => uart_clk(i),
        uart_CS_n           => uart_CS_n(i),
        uart_Rd_n           => uart_Rd_n (i),
        uart_Wr_n           => uart_Wr_n(i),
        uart_A              => uart_A(i),
        uart_D_In           => uart_D_In(i),
        uart_D_Out          => uart_D_Out(i)
        );


    ------------------------------------------------------------------------------
    -- UART
    ------------------------------------------------------------------------------
    uart : uart_16550
      port map(
        ---------------------------------------------------------------------
        -- Register interface
        ---------------------------------------------------------------------
        MR_n  => uart_reset_n(i),
        XIn   => uart_clk(i),
        RClk  => uart_baudout(i),
        CS_n  => uart_CS_n(i),
        Rd_n  => uart_Rd_n(i),
        Wr_n  => uart_Wr_n(i),
        A     => uart_A(i),
        D_In  => uart_D_In(i),
        D_Out => uart_D_Out(i),

        ---------------------------------------------------------------------
        -- Connector interface
        ---------------------------------------------------------------------
        SIn                 => ser_rx(i),
        CTS_n               => '1',
        DSR_n               => '0',
        RI_n                => '1',
        DCD_n               => '1',
        SOut                => ser_tx(i),
        RTS_n               => uart_rts_n(i),
        DTR_n               => open,
        OUT1_n              => open,
        OUT2_n              => uart_out2_n(i),
        transmission_active => uart_transmission_active(i),
        BaudOut             => uart_baudout(i),
        Intr                => uart_intr(i)
        );


    -----------------------------------------------------------------------------
    -- Synchronous process: P_uart_intr_FF
    -- Clock : uart_clk(i)
    -- Reset : None
    -- Description : Interrupt output enable. The interrupt output is
    --               controlled by setting the UART register MCR(3).
    --               Software legacy driver support. 
    -----------------------------------------------------------------------------
    P_uart_intr_FF : process(uart_clk(i))
    begin
      if rising_edge(uart_clk(i)) then
        if (uart_out2_n(i) = '0') then
          uart_intr_FF(i) <= uart_intr(i);
        else
          uart_intr_FF(i) <= '0';
        end if;
      end if;
    end process;


    -----------------------------------------------------------------------------
    -- Synchronous process: P_uart_reset_n
    -- Clock : uart_clk(0)
    -- Reset : lpc_reset_n (Asynchronous reset : Active low)
    -- Description : Reset resynchronisation on uart_clock
    -----------------------------------------------------------------------------
    -- WARNING CLOCK DOMAIN CROSSING!!!
    -----------------------------------------------------------------------------
    P_uart_reset_n : process(lpc_reset_n, uart_clk(i))
    begin
      if (lpc_reset_n = '0') then
        uart_reset_n_meta(i) <= '0';
        uart_reset_n(i)      <= '0';
      elsif rising_edge(uart_clk(i)) then
        uart_reset_n_meta(i) <= '1';
        uart_reset_n(i)      <= uart_reset_n_meta(i);
      end if;
    end process;


    -----------------------------------------------------------------------------
    -- Synchronous process: P_lpc_local_irq
    -- Src Clock : clk_24MHz
    -- Dst Clock : lpc_clk
    -- Reset : None
    -- Description : Clock domain crossing of the 8 flopped interrupts signal
    --               uart_intr_FF. (See above process)
    -----------------------------------------------------------------------------
    -- WARNING ASYNCHRONOUS CLOCK DOMAIN CROSSING!!!
    -----------------------------------------------------------------------------
    P_lpc_local_irq : process(lpc_clk)
    begin
      if rising_edge(lpc_clk) then
        lpc_local_irq_meta(i) <= uart_intr_FF(i);
        lpc_local_irq(i)      <= lpc_local_irq_meta(i);
      end if;
    end process;

  end generate G_UART;


  -----------------------------------------------------------------------------
  -- COM ports interrupt mapping on the ISA interrupt bus (LPC clock domain)
  -- Note: SERIRQ is active low
  -----------------------------------------------------------------------------
  lpc_isa_irq(4)  <= lpc_local_irq(0);  -- COM1
  lpc_isa_irq(3)  <= lpc_local_irq(1);  -- COM2
  lpc_isa_irq(5)  <= lpc_local_irq(2);  -- COM3
  lpc_isa_irq(10) <= lpc_local_irq(3);  -- COM4


  -----------------------------------------------------------------------------
  -- Module      : xlpc_serirq
  -- Entities    : SERIRQ module from the Spider_LPC project
  -- Description : Module that convert the parallel ISA IRQ bus to a one-bit 
  --               serial stream (SERIRQ protocol)
  -----------------------------------------------------------------------------
  xlpc_serirq : lpc_serirq
    generic map(
      IRQ_LSB => IRQ_LSB,
      IRQ_MSB => IRQ_MSB
      )
    port map(
      lpc_clk          => lpc_clk,
      lpc_reset        => lpc_reset_sync,
      serirq_in_ff     => serirq_in_ff,
      serirq           => serirq,
      isa_active_level => lpc_isa_irq_level,  -- ISA IRQ: All active high interrupts
      isa_irq          => lpc_isa_irq
      );


  -----------------------
  -- SERIAL IRQ OUTPUT --
  -----------------------
  P_serirq_in_ff : process(lpc_clk)  -- Extra FF, in order to push the FF in iob.
  begin
    if rising_edge(lpc_clk) then
      serirq_in_ff <= To_X01(serirq);
    end if;
  end process;


  -----------------------------------------------------------------------------
  -- Combinatorial Flag : local_address_hit
  -- Description        : Indicates that one of the COM port is hit by the
  --                      presented address. 
  -----------------------------------------------------------------------------
  local_address_hit <= '1' when (local_uart_hit /= (local_uart_hit'range => '0')) else
                       '0';


  -----------------------------------------------------------------------------
  -- Synchronous process: P_local_uart_hit_ff
  -- Clock : lpc_clk
  -- Reset : None
  -- Description : Pipeline version of the local_uart_hit bus
  -----------------------------------------------------------------------------
  P_local_uart_hit_ff : process(lpc_clk)
  begin
    if rising_edge(lpc_clk) then

      if (local_address_hit = '1') then
        local_uart_hit_ff <= local_uart_hit;
      end if;
    end if;
  end process;


  -----------------------------------------------------------------------------
  -- Combinatorial process (MUX): P_muxprc
  -- Description : Multiplex the UART register readback value for the
  --               LPC_Target read completion. 
  -----------------------------------------------------------------------------
  P_muxprc : process(local_uart_hit_ff, local_uart_readdata, local_uart_access_done)
  begin
    -- Default values are don't care
    local_readdata    <= (others => '-');
    local_access_done <= '-';

    for i in 0 to NUMB_UART-1 loop
      if (local_uart_hit_ff(i) = '1') then
        local_readdata    <= local_uart_readdata(i);
        local_access_done <= local_uart_access_done(i);
      end if;
    end loop;
  end process;


  -----------------------------------------------------------------------------
  -- Synchronous process: P_uart_RTS_3_n
  -- SRC Clock : uart_clk(3)
  -- DST Clock : clk_24MHz
  -- Reset : none
  -- Description :
  --
  -- 4.1 RS-485 issue:
  -- Amongst the problem, there is the RTS trailing issue with RS-485 ports.
  -- The situation is that KNS software:
  --    1.Turns on RS-485 driver, through RTS signal on RS232 serial port.
  --    2.Transmit a sequence of bytes.
  --    3.Turns off the RS-485 driver.
  -- 
  -- The problem encountered on KNS machine is that the timing between the
  -- end of transmission and the turn off of the driver is anticipated by
  -- software. There is no guarantee that the drive will not be turned off
  -- before the transmission of the last byte.  As the CPU gets faster and
  -- the software is not compensated accordingly, this timing gets violated.
  --
  -- The solution to that problem has already been implemented in GPM
  -- implementation of the LPC UARTs. Matrox UART code already contains the
  -- transmission_active signal, which can be redirected to enable the external
  -- driver through the RTS signal.  This is totally transparent to software.
  -----------------------------------------------------------------------------
  -- WARNING SYNCHRONOUS CLOCK DOMAIN CROSSING FROM uart_clk(3) TO lpc_clk
  -----------------------------------------------------------------------------
  P_uart_RTS_3_n : process(lpc_clk)
  begin
    if rising_edge(lpc_clk) then
      -------------------------------------------------------------------------
      -- On UAQRT/RTS_ assertion we assert synchronously uart_RTS_4_n
      -------------------------------------------------------------------------
      if (uart_rts_n(3) = '0') then
        ser4_rts_n <= '0';
      -------------------------------------------------------------------------
      -- On UAQRT/RTS_ de-assertion, we delay the de-assertion synchronously
      -- of ser4_rts_n until transmission_active(3) is completed. This way we
      -- are sure that all data has exit the UART serializer. 
      -------------------------------------------------------------------------
      elsif (uart_rts_n(3) = '1' and uart_transmission_active(3) = '0') then
        ser4_rts_n <= '1';
      end if;
    end if;
  end process;


end struct;

