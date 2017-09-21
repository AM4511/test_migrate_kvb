// FILE: I2C_Master.v  
// DATE: 9 June 2017
//
//  This is the top level module of the I2C Master Controller. It can be used
//  to read or write from the a I2C Bus.
//
//  The code is based on the I2C Master described in the Lattice app note
//  RD1005, "I2C Master Controller". The following features have been changed:
//    - Added fifo data buffer
//    - Bus interface is Avalon Interface
//    - Disable SCL when I2C not active
//
//  Revision History :
//   KP 6/9/17  - Fix indents by replacing TABs with spaces.
// ****************************************************************************

module I2C_Master(
    inout           SDA,            // I2C Serial Data
    inout           SCL,            // I2C Serial Clock
    input           clk,            // System clock
    input           reset,          // asynchronous reset (active high)
    // Avalon Interface (already in "clk" domain)
    input     [2:0] s_address,      // address
    input           s_chipselect,   // chip select (upper address decode)
    input           s_read,         // read strobe
    output    [7:0] s_readdata,     // read data bus
    input           s_write,        // write strobe
    input     [7:0] s_writedata,    // write data bus
    output          s_waitrequest,  // wait request
    output          s_irq           // interrupt request
    );

parameter CLK_RATE = 125;   // System clock frequency in MHz

// *** Declarations ***
wire        SCL_out;
wire        SCL_in;
wire        SDA_out;
wire        SDA_in;
//
wire  [7:0] xmtData;    // I2C transmit data from XMT FIFO
wire  [7:0] rcvData;    // I2C receive data to RCV FIFO
wire  [7:0] ctrlByte;   // I2C Control Byte
wire  [7:0] cmdReg;     // command register
wire  [7:0] byteCntReg; // I2C data byte count
wire        xFull;      // xmt FIFO Full
wire        xEmpty;     // xmt FIFO Empty
wire        rFull;      // rcv FIFO Full
wire        rEmpty;     // rcv FIFO Empty
wire        xmtRdReq;   // xmt FIFO read request
wire        rcvWrReq;   // rcv FIFO write request
wire        GO_Clear;   // handshake for self clearing GO bit
//   Status Register Bits
wire        Bus_Busy;
wire        Error;
wire        Abort_Ack;
wire        Lost_Arb;
wire        Done;
//
wire        intrn;


//****************************************************************************
// SCL and SDA I/O (chip peripheral)
//****************************************************************************
I2C_BusIF busif(
    .SCL        (SCL),      // Serial Clock (I2C bus connection)
    .SDA        (SDA),      // Serial Data (I2C bus connection)
    .SCL_out    (SCL_out),  // clock output control from MainSM
    .SCL_in     (SCL_in),   // clock from I2C bus
    .SDA_out    (SDA_out),  // data output control from MainSM
    .SDA_in     (SDA_in)    // data from I2C bus
);

//****************************************************************************
// Host CPU Interface (Avalon bus)
//****************************************************************************
AvalonIf avalon(
    .clk            (clk),      // system clock
    .reset          (reset),    // system reset (async, active high)
    // Avalon bus
    .s_address      (s_address),    // address
    .s_chipselect   (s_chipselect), // chip select
    .s_read         (s_read),   // read enable
    .s_readdata     (s_readdata),
    .s_write        (s_write),  // write enable
    .s_writedata    (s_writedata),  // write data
    .s_waitrequest  (s_waitrequest),
    .s_irq          (s_irq),
    // MainSM interface
    .xmtData        (xmtData),  // I2C transmit data from XMT FIFO
    .rcvData        (rcvData),  // I2C receive data to RCV FIFO
    .ctrlByte       (ctrlByte), // I2C Control Byte
    .cmdReg         (cmdReg),   // command register
    .byteCntReg     (byteCntReg),   // I2C data byte count
    .xFull          (xFull),    // xmt FIFO Full
    .xEmpty         (xEmpty),   // xmt FIFO Empty
    .rFull          (rFull),    // rcv FIFO Full
    .rEmpty         (rEmpty),   // rcv FIFO Empty
    .xmtRdReq       (xmtRdReq), // xmt FIFO read request
    .rcvWrReq       (rcvWrReq), // rcv FIFO write request
    .GO_Clear       (GO_Clear), // handshake for self clearing GO bit
    //   Status Inputs
    .Bus_Busy       (Bus_Busy),
    .Error          (Error),
    .Abort_Ack      (Abort_Ack),
    .Lost_Arb       (Lost_Arb),
    .Done           (Done),

    .intrn          (intrn)
    );

//****************************************************************************
// Main I2C State Machine
//****************************************************************************
MainSM #(.CLK_RATE(CLK_RATE)) main(
    .clk        (clk),
    .reset      (reset),
    .SCL_in     (SCL_in),
    .SCL_out    (SCL_out),
    .SDA_in     (SDA_in),
    .SDA_out    (SDA_out),
    //
    .xmtData    (xmtData),  // I2C transmit data from XMT FIFO
    .rcvData    (rcvData),  // I2C receive data to RCV FIFO
    .ctrlByte   (ctrlByte), // I2C Control Byte
    .cmdReg     (cmdReg),   // command register
    .byteCntReg (byteCntReg),   // I2C data byte count
    .xFull      (xFull),    // xmt FIFO Full
    .xEmpty     (xEmpty),   // xmt FIFO Empty
    .rFull      (rFull),    // rcv FIFO Full
    .rEmpty     (rEmpty),   // rcv FIFO Empty
    .xmtRdReq   (xmtRdReq), // xmt FIFO read request
    .rcvWrReq   (rcvWrReq), // rcv FIFO write request
    .GO_Clear   (GO_Clear), // handshake for self clearing GO bit
    .Bus_Busy   (Bus_Busy), // statusReg[7]
    .Error      (Error),    // statusReg[6]
    .Abort_Ack  (Abort_Ack),    // statusReg[5]
    .Lost_Arb   (Lost_Arb), // statusReg[4]
    .Done       (Done),     // statusReg[3]
    .intrn      (intrn)
    );

endmodule

