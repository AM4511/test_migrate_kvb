// FILE: MasterSM.v  
// DATE: 9 June 2017
//
//  The Master State Machine block controls all I2C bus functions and serves
//  as the interface between the host interface and the I2C bus. It is
//  a master only, and has no slave capability. It supports the I2C multi
//  master feature with the inclusion of arbitration logic. Four speed modes
//  are supported.
//      + Standard-mode - 100kbps
//      + Fast-mode - 400kbps
//      + Fast-mode Plus - 1Mbps
//      + High-speed mode - 3.4Mbps
//  SCL clock synchronization and stretching are supported.
//  
//  SDA output is delayed from the clock edge to meet setup/hold times for
//  various slave devices.
//  
//  References:
//    NXP UM10204 I2C-bus Specification and User Manual
//    Lattice RD1005 I2C Master Controller
//    AT24C32E Datasheet
//    IDT 89HP0508P Datasheet
//
//  Revision History :
//    RC 5/31/17 - Added separate SDA hold times for each mode. 
//    KP 6/5/17  - Fix multi-byte Read bug which caused I2C bus hang. SDA
//                 stayed low, because the last read byte was not NACK'ed.
//    KP 6/7/17  - Add bus hang recovery feature to output 9 SCL cycles with
//                 SDA not being driven.
//    KP 6/9/17  - Fix indents by replacing TABs with spaces.
// ****************************************************************************

module MainSM(
    input           clk,        // system clock 
    input           reset,      // system reset, active high
    // I2C Bus Interface
    input           SCL_in,     // I2C clock from I2C bus
    output reg      SCL_out,    // I2C clock to I2C bus
    input           SDA_in,     // I2C serial data from I2C bus
    output          SDA_out,    // I2C serial data to I2C bus
    // Host CPU Interface
    input     [7:0] xmtData,    // I2C xmt data byte from xmtFIFO
    output    [7:0] rcvData,    // I2C rcv data byte to rcvFIFO
    input     [7:0] ctrlByte,   // 1 - Control byte for I2C Slave
    input     [7:0] cmdReg,     // 4 - Command_Status Reg (commands)
    input     [7:0] byteCntReg, // 5 - Byte Count Reg
    input           xFull,      // xmt FIFO Full
    input           xEmpty,     // xmt FIFO Empty
    input           rFull,      // rcv FIFO Full
    input           rEmpty,     // rcv FIFO Empty
    output reg      xmtRdReq,   // xmt FIFO read request
    output reg      rcvWrReq,   // rcv FIFO write request
    output reg      GO_Clear,   // cmd register GO bit auto clear
    //   Status register bits
    output reg      Bus_Busy,   //   7 - Bus_Busy (1-busy, 0-free)
    output reg      Error,      //   6 - Error
    output reg      Abort_Ack,  //   5 - Abort_Ack
    output reg      Lost_Arb,   //   4 - Lost Arbitration
    output reg      Done,       //   3 - Done
    //
    output reg      intrn       // Interrupt Request to host interface
);

parameter CLK_RATE = 125;   // system clock rate in MHz

// ****************** SCL Timing Parameters for various Modes ****************
//
// The Serial Clock has a period of div_X_tc divider counts. The clock rises
// at 1/4 of the terminal count and falls at about 3/4 of the terminal count.
// In Fast Mode the minimum low time is 1.3usec for some EEPROM devices.
//
//   div_X_tc = CLK_RATE (MHz) * 1000 / I2C Clock rate (kHz)
//
//   Standard-mode counter constants (100kHz)
parameter TC_STD = (CLK_RATE * 1000)/100;   // I2C clock divider + 1
parameter HI_STD = (CLK_RATE * 1000)/200;   // rising edge at 1/2 period
parameter LO_STD = TC_STD;                  // falling edge at the end

//   Fast-mode counter constants (400kHz)
parameter TC_FAST = (CLK_RATE * 1000)/400;  // I2C clock divider + 1
parameter HI_FAST = (TC_FAST*1300)/2500;    // at period - 1.3usec
parameter LO_FAST = TC_FAST;                // falling edge at the end

//   Fast-mode Plus counter constants (1MHz)
parameter TC_FASTP = (CLK_RATE * 1000)/1000; // I2C clock divider + 1
parameter HI_FASTP = (CLK_RATE * 1000)/2000; // rising edge at 1/2 period
parameter LO_FASTP = TC_FASTP;              // falling edge at the end

//   High-speed mode counter constants (3.4MHz)
parameter TC_HS = (CLK_RATE * 1000)/3400;  // I2C clock divider + 1
parameter HI_HS = (CLK_RATE * 1000)/6800;  // rising edge at 1/2 period
parameter LO_HS = TC_HS;                   // falling edge at the end

// ****************** SDA Timing Parameters for various Modes ***************
//
parameter tSDAH_STD   = 25; // SDA hold time in system clock periods
parameter tSDAH_FAST  = 25; // SDA hold time in system clock periods
parameter tSDAH_FASTP = 15; // SDA hold time in system clock periods
parameter tSDAH_HS    = 2;  // SDA hold time in system clock periods
parameter tSDAS = 2;  // SDA sample time from SCL high in system clk periods

// ********************* Register and Wire Declarations *********************
// Sync flops
reg         SCL_in1;
reg         SCL_in2;
reg         SCL_in3;
reg         SCL_in4;
reg         SDA_in1;
reg         SDA_in2;
reg         rstn1;
reg         rstn;

reg [10:0]  divCnt; // clock divide counter
reg [10:0]  divTC;  // SCL clock divider terminal count value
reg [10:0]  sclHi;  // SCL low-to-high count transition value
reg [10:0]  sclLo;  // SCL high-to-low count transition value
reg [10:0]  sdaSamp; // SDA sample count compare value
reg [10:0]  sdaHold; // SDA hold time compare value

// Command Register bits
wire        GO        = cmdReg[7];
wire        Abort     = cmdReg[6];
wire        noStop    = cmdReg[5];
wire [1:0]  Mode      = cmdReg[4:3];
wire        noHangRec = cmdReg[2];
//wire      cmdReg1   = cmdReg[1];
wire        Done_IE   = cmdReg[0];

wire        RW_bit  = ctrlByte[0];

reg   [2:0] mainSt;     // main state machine state
reg         dataXfer;   // Transfer byte (0-control byte, 1-data byte)

reg         startDet;   // START condition detect
reg         stopDet;    // STOP condition detect
reg         armStrtDet; // pre-condition to START detection
reg         armStopDet; // pre-condition to STOP detection

reg         sdaMismatch;    // lost arbitration detection flag

//reg       xmtr;       // Transmitter flag (1-Transmitter, 0-Receiver)
reg         stopSCL;    // SCL output control (1-stop, 0-run)

reg  [3:0] bitCnt;  // bit counter for each byte of I2C transaction
reg  [7:0] byteCnt; // byte counter for an I2C transaction

reg  [7:0] rcvSR;
assign rcvData = rcvSR;
reg  [7:0] xmtSR;
assign SDA_out = xmtSR[7];

reg hangRecovDone;  // hang recovery done flag

// ****************** I2C State Machine State Definitions ******************

parameter IDLE  = 5'h00;    // I2C master is inactive
parameter START = 5'h01;    // START sequence
parameter XFER  = 5'h02;    // data transfer
parameter ACK   = 5'h03;    // ACK bit
parameter STOP  = 5'h04;    // STOP sequence
parameter RECOV = 5'h05;    // hang recovery

// ********************* State Machine Functional Code *********************

// Sync flops (two stages each to minimize metastability)
always @(posedge clk) begin
    SCL_in1 <= SCL_in;      // SCL_in shall not be used anywhere else!
    SCL_in2 <= SCL_in1;     // SCL_in1 shall not be used anywhere else!
    SCL_in3 <= SCL_in2;
    SCL_in4 <= SCL_in3;
    SDA_in1 <= SDA_in;      // SDA_in shall not be used anywhere else!
    SDA_in2 <= SDA_in1;     // SDA_in1 shall not be used anywhere else!
    rstn1 <= !reset;
    rstn <= rstn1;
end

// Counter compare values for various speed modes (combinational)
always @(Mode) begin
    case(Mode)
    2'b00: begin    // Standard-mode (100kbps)
        divTC = TC_STD;
        sclHi = HI_STD;
        sclLo = LO_STD;
        sdaHold = tSDAH_STD;
     end
    2'b01: begin    // Fast-mode (400kbps)
        divTC = TC_FAST;
        sclHi = HI_FAST;
        sclLo = LO_FAST;
        sdaHold = tSDAH_FAST;
     end
    2'b10: begin    // Fast-mode Plus (1Mbps)
        divTC = TC_FASTP;
        sclHi = HI_FASTP;
        sclLo = LO_FASTP;
        sdaHold = tSDAH_FASTP;
     end
    2'b11: begin    // High-speed mode (3.4Mbps)
        divTC = TC_HS;
        sclHi = HI_HS;
        sclLo = LO_HS;
        sdaHold = tSDAH_HS;
     end
    endcase
    sdaSamp = sclHi + tSDAS;
end

// I2C SCL Clock Generation
//   Clock synchronization and clock streching is implemented here. The state
//   of SCL is monitored and SCL_out is adjusted to hold SCL_out in the high
//   state until the full SCL high time is met. (I2C-bus spec 3.1.7, 3.1.9)
//
//   SCL will not transition low when stopSCL is true. This is done to turn
//   SCL off when the I2C bus is idle. Note that SCL low time and high time
//   minimums are not violated.
//                               ___ 
// stopSCL XX___XXXXXXXXXXXXXXXXX   XXXXXXXXXXXXXXXXX___XXXXXXXXXXXXXXXXX___
//   .........           .............................           .........
// SCL        \_________/                             \_________/         \.
//       sclLo|    sclHi|    sclLo|    sclHi|    sclLo|    sclHi|    sclLo|
//            | SCL period (divTC)|                   |                   |
//
always @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        divCnt <= 11'h000;
        SCL_out  <= 1'b1;
    end else begin
        // *** Clock divider ***
        if(divCnt >= divTC) begin       // roll over at terminal cnt 
            divCnt <= 0;
        end else if(divCnt == sclHi+1'b1) begin
            divCnt <= divCnt + SCL_in;  // don't count if SCL still low
                                        //  (slave maybe stretching clock)
        end else if(divCnt == sclLo) begin
            divCnt <= divCnt + 1'b1;
        end else begin
            divCnt <= divCnt + 1'b1;
        end
        // *** SCL output control ***
        if(divCnt == sclHi) begin
            SCL_out <= 1'b1;    // SCL high
        end else if(divCnt == sclLo) begin
            SCL_out <= stopSCL; // SCL low at when not stopped
        end
    end
end

// I2C Bus Arbitration
//    On rising edge of SCL, arbitration is lost when SDA does not match
//    SDA_out. (I2C-bus spec section 3.1.8)
always @(posedge clk or negedge rstn) begin
    if(rstn == 1'b0) begin
        sdaMismatch <= 1'b0;
    end else begin 
        // rising edge of SCL check for arbitration loss (SDA mismatch)
        if(SCL_in3 && !SCL_in4 && (SDA_in2 != SDA_out)) begin
            sdaMismatch <= (mainSt==XFER) && (dataXfer && !RW_bit || !dataXfer);
        end else if(SCL_in3 && SCL_in4 && (SDA_in2 == SDA_out)) begin
            sdaMismatch <= 1'b0;
        end
    end
end

// Start/Stop Detection
always @(posedge clk or negedge rstn) begin
    if(rstn == 1'b0) begin
        startDet <= 1'b0;
        stopDet <= 1'b0;
        armStrtDet <= 1'b0;
        armStopDet <= 1'b0;
        Bus_Busy <= 1'b0;   // Status[7]
    end else begin
        // Start detected when SDA transations low while SCL is high
        armStrtDet <= SCL_in2 && SDA_in2; // arm when SCL and SDA both high
        if(armStrtDet && SCL_in2 && !SDA_in2)
            startDet <= 1'b1;
        else if(SCL_in2 && SDA_in2)
            startDet <= 1'b0;
        //
        // Stop detected when SDA transitions high while SCL is high
        armStopDet <= SCL_in2 && !SDA_in2; // arm when SCL high and SDA low
        if(armStopDet && SCL_in2 && SDA_in2)
            stopDet <= 1'b1;
        else if(!armStopDet && SCL_in2 && SDA_in2)
            stopDet <= 1'b0;
        //
        // Bus Busy status
        if(startDet) Bus_Busy <= 1'b1;
        else if (stopDet) Bus_Busy <= 1'b0;
        else if (Abort_Ack) Bus_Busy <= 1'b0;
    end
end

// Main State Machine
always @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        Error        <= 1'b0;   // Status[6]
        Abort_Ack    <= 1'b0;   // Status[5]
        Lost_Arb     <= 1'b0;   // Status[4]
        Done         <= 1'b1;   // Status[3]
        mainSt       <= IDLE;
        stopSCL      <= 1'b1;   // put SCL in the idle condition
        xmtRdReq     <= 1'b0;   // xmt FIFO read request
        rcvWrReq     <= 1'b0;   // rcv FIFO write request
        GO_Clear     <= 1'b0;   // clear the command register GO bit
        intrn        <= 1'b1;   // interrupt (active low, 1 clock wide)
        bitCnt       <= 4'h0;   // transfer bit counter
        byteCnt      <= 8'h00;  // transfer byte counter
        dataXfer     <= 1'b0;   // data transfer (0-control, 1-data)
        rcvSR        <= 8'hFF;  // receive shift register to bus idle
        xmtSR        <= 8'hFF;  // transmit shift register to bus idle
        hangRecovDone<= 1'b0;   // clear the hang recovery flag
    end else begin
        case(mainSt)
            IDLE: begin // mainSt=0
                Done <= !GO && Done;
                intrn <= 1'b1;  // arm for the next interrupt
                //
                if(Abort && (noHangRec || hangRecovDone)) begin
                    // Abort_Ack if Recovery not requested OR already done once
                    Abort_Ack <= 1'b1;  // only acknowledge during IDLE
                    Error <= 1'b0;      // clear Errors on Abort during IDLE
                    Lost_Arb <= 1'b0;
                end else begin      // Abort no longer active
                    Abort_Ack <= 1'b0;  // clear acknowledge when Abort=0
                    hangRecovDone <= 1'b0;  // clear when Abort done
                end
                //
                if(divCnt == sdaHold) begin
                    xmtSR <= 8'hFF; // make sure SDA=1 (STOP or noStop)
                end
                //
                if(divCnt==divTC) begin
                    if(GO && !Abort && !Error) begin
                        GO_Clear <= 1'b1;   // clear the GO bit
                        mainSt <= START;    // START when GO at bit time TC
                        dataXfer <= 1'b0;
                    end else if(Abort && !noHangRec && !hangRecovDone) begin
                        xmtSR <= 8'hFF;     // make sure SDA is not driven
                        dataXfer <= 1'b1;   // "Data" transfer
                        byteCnt <= byteCntReg;  // indicate last byte
                        bitCnt <= 4'h0;
                        stopSCL <= 1'b0;    // start SCL
                        mainSt <= RECOV;    // Clear hang with no START, just
                                            //   XFER and NACK.
                    end
                end
             end
            START: begin // mainSt=1
                // SDA START transition
                if(divCnt == sdaHold) begin
                    xmtSR <= 8'h7F; // signal START (SDA falls while SCL=1)
                end
                //
                if(divCnt == divTC) begin
                    GO_Clear <= 1'b0; // done clearing the GO bit
                    if(startDet) begin  // make sure start is detected
                        stopSCL <= 1'b0;
                        mainSt <= XFER;   // transfer is next at bit time end
                    end else begin
                        Error <= 1'b1;    // Error if start not detected
                        stopSCL <= 1'b1;
                        mainSt <= IDLE;   // no START, so return to IDLE
                    end
                end else begin
                    stopSCL <= 1'b0;    // SCL goes low in this bit position
                end
             end
            XFER: begin // mainSt=2
                // Read xmtFIFO for data out transfer
                if(divCnt==0 && dataXfer && !RW_bit && !Abort &&
                    bitCnt == 4'h0) begin
                    xmtRdReq <= 1'b1; // read xFIFO
                end else begin
                    xmtRdReq <= 1'b0;   // 1 clk wide
                end
                // SDA data transfer Control and Sampling
                if(divCnt == sdaHold) begin
                    if(dataXfer == 1'b0) begin  // ** Control Byte **
                        if(bitCnt == 4'h0) begin    // new byte
                            xmtSR <= ctrlByte;  // load xmt SR
                        end else begin
                            xmtSR <= {xmtSR[6:0],1'b1}; // shift xmt SR
                        end
                    end else if(!RW_bit && !Abort) begin // ** Data Write **
                        if(bitCnt == 4'h0) begin    // new byte
                            xmtSR <= xmtData;   // load xmt SR
                        end else begin
                            xmtSR <= {xmtSR[6:0],1'b1}; // shift xmt SR
                        end
                    end else begin          // ** Data Read **
                        xmtSR <= 8'hFF; // let SDA pull-up for reading
                    end
                end else if(divCnt == sdaSamp) begin    // ** Data Read **
                    rcvSR <= {rcvSR[6:0],SDA_in2};   // shift rcv SR
                    if(sdaMismatch) begin  // terminate transfer when lost arb
                        Error <= 1'b1;
                        Lost_Arb <= 1'b1;
                        stopSCL <= 1'b1;
                        Done <= 1'b1;
                        intrn <= !Done_IE;  // allows 0 when Done_IE=1
                        mainSt <= IDLE;
                    end
                end
                // Byte count increment at the end of the SCL period
                if(divCnt == divTC) begin
                    if(bitCnt != 4'h7) begin    // first seven bits
                        bitCnt <= bitCnt + 1'b1;
                    end else begin      // 8th bit
                        bitCnt <= 4'h0; // byte transfer complete
                        mainSt <= ACK;  // move to ACK state
                    end
                end
             end
            ACK: begin  // mainSt=3
                // test ACK when Control Byte OR Data Write AND not Aborting
                if((!dataXfer || !RW_bit) && !(Abort && noHangRec)) begin
                    if(divCnt == sdaHold) begin // release the I2C bus
                        xmtSR <= 8'hFF; // shift in the 8th '1'
                    end else if(divCnt == sdaSamp) begin
                        Error <= SDA_in2;   // set Error on NACK
                    end
                // Send ACK/NACK for Data Read
                end else begin
                    if(divCnt == sdaHold) begin
                        rcvWrReq <= 1'b1;   // load rcvFIFO with Read data
                        if(byteCnt != byteCntReg) begin
                            xmtSR <= 8'h7F; // ACK the read until last byte
                        end else begin
                            xmtSR <= 8'hFF; // NACK the read on last byte
                        end
                    end else begin
                        rcvWrReq <= 1'b0;   // 1 clock wide
                    end
                end
                // Finish ACK bit state
                if(divCnt == divTC) begin
                    if(byteCnt == byteCntReg || Error) begin
                        byteCnt <= 3'h0;
                        dataXfer <= 1'b0;
                        mainSt <= STOP;
                    end else begin
                        byteCnt <= byteCnt + 1'b1;
                        dataXfer <= 1'b1;
                        mainSt <= XFER;
                    end
                end
             end
            STOP: begin // mainSt=4
                if(divCnt == sdaHold) begin // SDA rising while SCL=1
                    xmtSR <= {(noStop && !Error),7'h7F}; // SDA = noStop
                    stopSCL <= 1'b1;     // stop next SCL fall
                end
                // 
                if(divCnt == divTC) begin
                    Done <= 1'b1;
                    intrn <= !Done_IE;  // allows 0 when Done_IE=1
                    mainSt <= IDLE;
                end
             end
            RECOV: begin    // mainSt=5
                // Byte count increment at the end of the SCL period
                if(divCnt == divTC) begin
                    if(bitCnt != 4'h8) begin    // send 8 clocks
                        bitCnt <= bitCnt + 1'b1;
                    end else begin      // 8th bit
                        hangRecovDone <= 1'b1;  // signal done
                        bitCnt <= 4'h0; // bit count complete, clear it
                        mainSt <= ACK;  // move to ACK state
                    end
                end
             end
        endcase
    end
end

endmodule

