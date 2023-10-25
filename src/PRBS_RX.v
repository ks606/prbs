`ifndef _PRBS_RX
`define _PRBS_RX

`timescale 1 ns/1 ps
module PRBS_RX #(parameter 
    PRBS_TYPE     = 7,
    BIT_CNT_WIDTH = 3,
    ERR_CNT_WIDTH = 3
    
)(
    input   clk,
    input   rst,
    
// Inputs
    input   din_vld,
    input   din,
    
// Outputs
    output [BIT_CNT_WIDTH-1:0]      bit_cnt,
    output                          bit_cnt_full,
    output [ERR_CNT_WIDTH-1:0]      err_cnt,
    output                          dout_vld,
    output                          dout,
    
// test outputs
    output [9:0]    sync_cnt,
    output          dout_xor
    
);

//--------------------
// Parameters & signals
//--------------------
    reg [BIT_CNT_WIDTH-1:0]			BIT_CNT_REG;
    reg [9:0]						SYNC_CNT_REG;
    
    reg 							BIT_CNT_FULL_REG;
    reg [ERR_CNT_WIDTH-1:0]			ERR_CNT_REG;	
    
    wire [2:0] 						PRBS_PARAM;
    
    assign PRBS_PARAM = PRBS_TYPE;

//--------------------
// Main
//--------------------

// Delay
    reg DIN_VLD_REG;
    reg DIN_REG;
    
    always @ (posedge clk or negedge rst)
        if (!rst) begin
            DIN_VLD_REG  <= 1'b0;
            DIN_REG		<= 1'b0;
        end
        else begin
            DIN_VLD_REG  <= din_vld;
            DIN_REG		<= din;
        end

// Input bit counter
    reg [31:0] DIN_CNT;
    reg [31:0] DIN_CNT_COEF;
        
    always @ (*)
        case (PRBS_PARAM)
            3'd0: DIN_CNT_COEF = 32'd7; 
            3'd1: DIN_CNT_COEF = 32'd127;	
            3'd2: DIN_CNT_COEF = 32'd511;
            3'd3: DIN_CNT_COEF = 32'd2047; 	
            3'd4: DIN_CNT_COEF = 32'd32767; 
            3'd5: DIN_CNT_COEF = 32'd131071; 
            3'd6: DIN_CNT_COEF = 32'd8388607; 
            3'd7: DIN_CNT_COEF = 32'd4294967295; 
        endcase
        
    always @ (posedge clk or negedge rst)
        if (!rst)
            DIN_CNT <= 32'h0000_0000;
        else if (DIN_CNT == DIN_CNT_COEF)
            DIN_CNT <= 32'h0000_0001;
        else if (DIN_VLD_REG)
            DIN_CNT <= DIN_CNT + 1'b1;
    
// Shift register
    reg [31:0]  DIN_SHIFT_REG;
    reg [31:0]  DIN_FRAME_REG;
    reg         SYNC_FLAG;
    reg	        XOR_OUT;
    
    always @ (posedge clk or negedge rst)
        if (!rst) begin
            DIN_SHIFT_REG <= 32'h0000_0000;
        end else if (SYNC_FLAG && DIN_VLD_REG) begin
                DIN_SHIFT_REG[0] <= XOR_OUT;
                DIN_SHIFT_REG[31:1] <= DIN_SHIFT_REG[30:0];
        end else if (DIN_VLD_REG) begin
                DIN_SHIFT_REG[0] <= DIN_REG;
                DIN_SHIFT_REG[31:1] <= DIN_SHIFT_REG[30:0];
        end
        
    always @ (*)
        case (PRBS_PARAM)
            3'd0: XOR_OUT = DIN_SHIFT_REG[2]  ^ DIN_SHIFT_REG[0]; 
            3'd1: XOR_OUT = DIN_SHIFT_REG[6]  ^ DIN_SHIFT_REG[0];  
            3'd2: XOR_OUT = DIN_SHIFT_REG[8]  ^ DIN_SHIFT_REG[4];  
            3'd3: XOR_OUT = DIN_SHIFT_REG[10] ^ DIN_SHIFT_REG[8];  
            3'd4: XOR_OUT = DIN_SHIFT_REG[14] ^ DIN_SHIFT_REG[0];  
            3'd5: XOR_OUT = DIN_SHIFT_REG[16] ^ DIN_SHIFT_REG[2];  
            3'd6: XOR_OUT = DIN_SHIFT_REG[22] ^ DIN_SHIFT_REG[17];
            3'd7: XOR_OUT = DIN_SHIFT_REG[31] ^ DIN_SHIFT_REG[21] ^ DIN_SHIFT_REG[1] ^ DIN_SHIFT_REG[0];
            default: XOR_OUT = 0;
        endcase
        
// Sync counter
    always @ (posedge clk or negedge rst)
        if (!rst) begin 
            SYNC_CNT_REG <= 0;
        end else if (DIN_VLD_REG) begin
            if (DIN_REG == XOR_OUT)
                SYNC_CNT_REG <= SYNC_CNT_REG + 1'b1;
            else
                SYNC_CNT_REG <= 0;
        end
    
    always @ (posedge clk or negedge rst)
        if (!rst)
            SYNC_FLAG <= 0;
        else if (SYNC_CNT_REG == 100)
            SYNC_FLAG <= 1'b1;
    
// Error/data counters
    always @ (posedge clk or negedge rst)
        if (!rst)
            BIT_CNT_REG <= 32'h0000_0000;
        else if (DIN_VLD_REG)
            BIT_CNT_REG <= BIT_CNT_REG + 1'b1;

    always @ (posedge clk or negedge rst)
        if (!rst)
            BIT_CNT_FULL_REG <= 1'b0;
        else if (BIT_CNT_REG == 2**BIT_CNT_WIDTH-1)
            BIT_CNT_FULL_REG <= 1'b1;
        else
            BIT_CNT_FULL_REG <= 1'b0;
        
// Error counter	
    wire ERR_EN;
    assign ERR_EN = (DIN_REG ^ XOR_OUT) ? 1 : 0; 
        
    always @ (posedge clk or negedge rst)
        if (!rst)
            ERR_CNT_REG <= 32'h0000_0000;
        else if (ERR_EN && DIN_VLD_REG)
            ERR_CNT_REG <= ERR_CNT_REG + 1'b1;
        else if (BIT_CNT_FULL_REG)
            ERR_CNT_REG <= 32'h0000_0000;
    
    reg DOUT_VLD_REG;
    
    always @ (posedge clk or negedge rst)
        if (!rst)
            DOUT_VLD_REG <= 1'b0;
        else
            DOUT_VLD_REG <= din_vld;
    
//--------------------
// Output
//--------------------
    assign dout = SYNC_FLAG ? XOR_OUT : 1'b0; //GEN_DOUT : 1'b0;
    assign dout_vld = SYNC_FLAG ? DOUT_VLD_REG : 1'b0;
    assign bit_cnt = BIT_CNT_REG;
    assign bit_cnt_full = BIT_CNT_FULL_REG;
    assign err_cnt = ERR_CNT_REG;
    
    assign dout_xor = XOR_OUT;
    assign sync_cnt = SYNC_CNT_REG;
    
endmodule

`endif // _PRBS_RX