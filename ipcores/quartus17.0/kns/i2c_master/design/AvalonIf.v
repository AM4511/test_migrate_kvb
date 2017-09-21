// FILE: AvalonIf.v
// DATE: 6/9/2017
//
//  Avalon interface to the I2C Master. It includes FIFO buffers for I2C data
//  write and read.
//
//  The register map is:
//    0 - Data buffer (FIFO)
//      read/write of data following the "Address data" frame. Data is
//      "FIFO'ed" (8 bytes deep) for reads and writes.
//    1 - Control Byte register (write only)
//      [7:1] - Low address
//        [0] - R/W bit (1-read, 0 write)
//    2 - reserved (not implemented)
//    3 - reserved (not implemented)
//    4 - Command (write) / Status (read) register
//          Command  [7] - GO, starts I2C transaction (self clearing)
//          Command  [6] - Abort, stops I2C transaction in progress
//          Command  [5] - noStop (1-no STOP after last byte, 0-normal STOP)
//          Command  [4:3] - I2C mode (11-3.4Mbps, 10-1Mbps,
//                                     01-400kbps, 00-100kbps)
//          Command  [2] - noHangRec (0-hang recover w/Abort, 1-no hang recover)
//          Command  [1] - reserved
//          Command  [0] - Done_IE, enables Done interrupt (1-enable, 0-disable)
//          Status[7] - I2C_Bus_Busy (1-busy, 0-free)
//          Status[6] - Error, I2C transaction eror (1-error, 0-no error)
//          Status[5] - Abort_Ack, Abort completed by I2C controller
//          Status[4] - Lost_Arb, Lost arbitration bit
//          Status[3] - Done, I2C transaction complete (1-done, 0-not done)
//          Status[2] - xFull, xmit FIFO full (1-full, 0-not full)
//          Status[1] - xEmpty, xmit FIFO empty (1-empty, 0-not empty)
//          Status[0] - rEmpty, rcv FIFO empty (1-empty, 0-not empty)
//          ** The Done interrupt is cleared by reading the Status
//    5 - Byte count, number of bytes for the current transaction
//    6 - reserved (not implemented)
//    7 - reserved (not implemented)
//
// Revision History:
//   KP 5/12/17 - add noStop bit to command reg for 24LC04 read support
//   RC 5/31/17 - Changed timing for rrreg to provide read data to host prior 
//                to removing s_waitrequest.
//              - Modified code to inhibit writing to FIFO when full and 
//                reading from FIFO when empty.
//              - Added FIFO counter to keep track of FIFO full and empty. This 
//                allows the FIFO to be loaded with 8 bytes instead of 7.
//   KP 6/9/17  - Fix indents by replacing TABs with spaces.
// ----------------------------------------------------------------------------

module AvalonIf(
    // Avalon Bus
    input            clk,           // system Clock
    input            reset,         // system Reset, active high (asynchronous)
    input      [2:0] s_address,     // address
    input            s_chipselect,  // chip select (upper address decode)
    input            s_read,        // read strobe
    output     [7:0] s_readdata,    // read data bus
    input            s_write,       // write strobe
    input      [7:0] s_writedata,   // write data bus
    output           s_waitrequest, // wait request
    output reg       s_irq,         // Interrupt
    // MainSM signals
    output reg [7:0] xmtData,       // Holds Data for I2C Write transaction
    input      [7:0] rcvData,       // I2C Data Read in
    output reg [7:0] ctrlByte,      // Low order Address bits for I2C Slave
    output reg [7:0] cmdReg,        // CMD part of Command_Status register
    output     [7:0] byteCntReg,    // I2C Transaction Byte Count
    output reg       xFull,         // xmt FIFO Full
    output reg       xEmpty,        // xmt FIFO Empty
    output reg       rFull,         // rcv FIFO Full
    output reg       rEmpty,        // rcv FIFO Empty
    input            xmtRdReq,      // xmt FIFO read request
    input            rcvWrReq,      // rcv FIFO write request
    input            GO_Clear,      // Clears Go Bit
    // -- Status Register bits --
    input            Bus_Busy,      //   7 - Bus_Busy
    input            Error,         //   6 - Error
    input            Abort_Ack,     //   5 - Abort_Ack
    input            Lost_Arb,      //   4 - Lost_Arb
    input            Done,          //   3 - Done
    //
    input            intrn          // interrupt (1 clock wide, active low)
);

// Register Addresses
parameter DATA       = 3'h0;    // read/write data FIFOs
parameter SLAVE_CTRL = 3'h1;    // slave control byte
parameter COMMAND    = 3'h4;
parameter BYTE_CNT   = 3'h5;
//parameter IACK_ST    = 3'h6;

// Write strobe states
parameter IDLE      = 2'h0;
parameter STROBE    = 2'h1;
parameter ENDSTROBE = 2'h2;

reg     rstn1;
reg     rstn;

reg   [1:0] state;
reg     write_pulse;

//internal registers necessary for feedback
reg   [7:0] byteCnt;

reg   [7:0] rcvFIFO [0:7];  // I2C receive data FIFO
reg   [2:0] rLdPtr;         // receive load pointer
reg   [2:0] rUnPtr;         // receive unload pointer
reg   [3:0] rFIFOCnt;       // receive FIFO byte count
reg   [7:0] xmtFIFO [0:7];  // I2C xmit data FIFO
reg   [2:0] xLdPtr;         // xmit load pointer
reg   [2:0] xUnPtr;         // xmit unload pointer
reg   [3:0] xFIFOCnt;       // xmit FIFO byte count

wire  [7:0] Status;         // Status register bits
reg   [7:0] readMux;
reg         xwreq;          // xmit FIFO write request
wire        rrreq;
reg   [7:0] read_fifo_out;
reg         abort1;
reg         abort2;
reg         fifo_error;

reg         ready1;
reg         ready2;
reg         ready3;
reg         ready4;

assign s_readdata = (s_chipselect && s_read) ? readMux : 8'h00;
assign byteCntReg = byteCnt;

// Sync flops (two stages each to minimize metastability)
always @(posedge clk) begin
    rstn1 <= !reset;
    rstn <= rstn1;
end

// Delay Flip-Flops for edge detection
always @(posedge clk) begin
    if (rstn == 1'b0) begin
        abort1 <= 1'b0;
        abort2 <= 1'b0;
    end else begin
        abort1 <= cmdReg[6];    // Abort from Command register
        abort2 <= abort1;
    end
end

// I2C Transmit FIFO (using registers, not memory blocks)
//
//   xLdPtr is the address of the next write location.
//   xUnPtr is the address of the next read location.
//   xFIFOCnt is the count of the number of bytes in the FIFO.
//   The pointers are incremented on the cycle following the associated write
//   and/or read operation. Read data is registered on the FIFO output and is
//   available on the clock cycle after xmtRdReq is true.
//
always @(posedge clk or negedge rstn) begin
    if(rstn == 1'b0) begin
    xLdPtr <= 3'b0;
    xUnPtr <= 3'b0;
    xEmpty <= 1'b1;     // empty on reset
    xFull  <= 1'b0;     // NOT full on reset
    xmtData <= 8'h00;
    xFIFOCnt <= 4'h0;
    end else begin
        if(abort1 && !abort2) begin // Abort takes precedence
            xLdPtr <= 3'b0;
            xUnPtr <= 3'b0;
            xEmpty <= 1'b1;     // empty on reset
            xFull  <= 1'b0;     // NOT full on reset
            xFIFOCnt <= 4'h0;
        end else begin
            // load - write to the FIFO
            if(xwreq && !xFull) begin
                xmtFIFO[xLdPtr] <= s_writedata;
                xLdPtr <= xLdPtr + 1'b1;
                xFIFOCnt <= xFIFOCnt + 1'b1;
            end
            // unload - read from the FIFO if not Empty
            if(xmtRdReq && !xEmpty) begin
                xmtData <= xmtFIFO[xUnPtr];
                xUnPtr <= xUnPtr + 1'b1;
                xFIFOCnt <= xFIFOCnt - 1'b1;
            end
            // FIFO status
            xEmpty <= xFIFOCnt == 4'h0;  
            xFull  <= xFIFOCnt == 4'h8; 
         end
    end
end

// I2C Receive FIFO (using registers, not memory blocks)
//
//   rLdPtr is the address of the next write location.
//   rUnPtr is the address of the next read location.
//   rFIFOCnt is the count of the number of bytes in the FIFO.
//   The pointers are incremented on the cycle following the associated write
//   and/or read operation. Read data is registered on the FIFO output and is
//   available on the clock cycle after rrreq is true.
//
assign rrreq = s_chipselect && s_read && (s_address == 3'h0) && ready1 && !ready2;
//
always @(posedge clk or negedge rstn) begin
    if(rstn == 1'b0) begin
        rLdPtr <= 3'b0;
        rUnPtr <= 3'b0;
        rEmpty <= 1'b1;     // empty on reset
        rFull  <= 1'b0;     // NOT full on reset
        read_fifo_out <= 8'h00;
        rFIFOCnt <= 4'h0;
    end else begin
        if(abort1 && !abort2) begin // Abort takes precedence
            rLdPtr <= 3'b0;
            rUnPtr <= 3'b0;
            rEmpty <= 1'b1; // empty on reset
            rFull  <= 1'b0; // NOT full on reset
            rFIFOCnt <= 4'h0;
        end else begin
            // load - write to the FIFO
            if(rcvWrReq && !rFull) begin
                rcvFIFO[rLdPtr] <= rcvData;
                rLdPtr <= rLdPtr + 1'b1;
                rFIFOCnt <= rFIFOCnt + 1'b1;
            end
            // unload - read from the FIFO if not Empty
            if(rrreq && !rEmpty) begin
                read_fifo_out <= rcvFIFO[rUnPtr];
                rUnPtr <= rUnPtr + 1'b1;
                rFIFOCnt <= rFIFOCnt - 1'b1;
            end
            // FIFO status
            rEmpty <= rFIFOCnt == 4'h0;  
            rFull  <= rFIFOCnt == 4'h8; 
        end
    end
end

// FIFO error detection
always @(posedge clk or negedge rstn) begin
    if(rstn == 1'b0) begin
        fifo_error <= 1'b0;
    end else begin
        if(abort1 && !abort2) begin // Abort takes precedence
            fifo_error <= 1'b0;
        end else if((xmtRdReq && xEmpty) || (xwreq && xFull) ||
                (rrreq && rEmpty) || (rcvWrReq && rFull)) begin
            fifo_error <= 1'b1; // Error when Read and Empty or Write and Full
        end
    end
end

assign Status = {Bus_Busy, (Error || fifo_error), Abort_Ack, Lost_Arb,
                 Done, xFull, xEmpty, rEmpty};

// Read Registers Mux
always @(s_address, Status, read_fifo_out, ctrlByte, byteCnt) begin
    case(s_address)
        DATA:       readMux <= read_fifo_out;   // s_address = 0
        SLAVE_CTRL: readMux <= ctrlByte;        // s_address = 1
        COMMAND:    readMux <= Status;          // s_address = 4
        BYTE_CNT:   readMux <= byteCnt;         // s_address = 5
        default:    readMux <= 8'h00;
    endcase
end

// Reading status register after irq
always @(posedge clk or negedge rstn) begin
    if(rstn == 1'b0) begin
        s_irq <= 1'b0;
    end else begin
        if (intrn == 1'b0) begin
            s_irq <= 1'b1;  // set irq
        end else if (s_chipselect && s_read && (s_address == 3'h4)) begin
            s_irq <= 1'b0;  // reset irq
        end
    end
end

// Register Interface
always @(posedge clk or negedge rstn) begin
    if(rstn == 1'b0) begin
        xwreq       <= 1'b0;
        ctrlByte     <= 8'h00;
        cmdReg <= 8'h00;
        byteCnt     <= 8'h00;
    end else begin
        // Registr writes
        if(write_pulse == 1'b1) begin 
            case (s_address)
                DATA:       xwreq    <= 1'b1; // write data FIFO (s_address = 0)
                SLAVE_CTRL: ctrlByte <= s_writedata; // 1st byte (s_address = 1)
                COMMAND:    cmdReg   <= s_writedata;          // (s_address = 4)
                BYTE_CNT:   byteCnt  <= s_writedata;          // (s_address = 5)
            endcase
        //
        end else if(GO_Clear) begin
            cmdReg[7] <= 1'b0;
        end else begin
            xwreq <= 1'b0;
        end
    end
end

always @(posedge clk or negedge rstn) begin
    if(rstn == 1'b0) begin
        write_pulse <= 1'b0;
        state <=  IDLE;
    end else begin
        case (state)
            IDLE: begin
                write_pulse <= 1'b0;
                if(s_write && s_chipselect) state <= STROBE;
             end
            STROBE: begin
                write_pulse <= 1'b1;
                state <= (!s_chipselect) ? IDLE : ENDSTROBE;
             end
            ENDSTROBE: begin
                write_pulse <= 1'b0;
                if(!s_chipselect) state <= IDLE;// wait for s_chipselect inactive
             end
            default: begin
                write_pulse <= 1'b0;
                state <= IDLE;
             end
        endcase
    end
 end

// Avalon Wait Request
assign s_waitrequest = !((s_write && ready4) || (s_read && ready3)); 
                      
always @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        ready1 <= 1'b0;
        ready2 <= 1'b0;
        ready3 <= 1'b0;
        ready4 <= 1'b0;
    end else begin 
        if(!s_write && !s_read) begin   // no write or read
            ready1 <= 1'b0;
            ready2 <= 1'b0;
            ready3 <= 1'b0;
            ready4 <= 1'b0;
        end else begin  // write or read is happening
            ready1 <= 1'b1;
            ready2 <= ready1;
            ready3 <= ready2;
            ready4 <= ready3;
        end
    end
end

endmodule

