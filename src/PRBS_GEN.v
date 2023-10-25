`ifndef _PRBS_GEN
`define _PRBS_GEN

module PRBS_GEN #(
    parameter PRBS_TYPE = 7
    
)(
    input   clk,
    input   rst,
    
    // Inputs
    input   prbs_en,
    
    // Outputs
    output [31:0]   gen_shift_reg,
    output          dout_vld,
    output          dout	
    
);

//--------------------
// Parameters & signals
//--------------------
    reg         PRBS_EN_REG;
    reg         DOUT_VLD_REG;
    reg [31:0]  PRBS_REG;
    reg         XOR_OUT;
    
    wire [2:0]  PRBS_PARAM;
    assign PRBS_PARAM = PRBS_TYPE;
     
//--------------------
// Main
//--------------------

// Delay
    always @ (posedge clk or negedge rst)
        if (!rst)
            PRBS_EN_REG <= 1'b0;
        else
            PRBS_EN_REG <= prbs_en;
            
    always @ (posedge clk or negedge rst)
        if (!rst)
            DOUT_VLD_REG <= 1'b0;
        else
            DOUT_VLD_REG <= PRBS_EN_REG;
    
    always @ (posedge clk or negedge rst)
        if (!rst) begin
            case (PRBS_TYPE)
                3'd0: PRBS_REG <= 32'h7; 		 
                3'd1: PRBS_REG <= 32'h7F; 		
                3'd2: PRBS_REG <= 32'h1FF; 	
                3'd3: PRBS_REG <= 32'h7FF; 
                3'd4: PRBS_REG <= 32'h7FFF; 
                3'd5: PRBS_REG <= 32'h1FFFF; 
                3'd6: PRBS_REG <= 32'h7FFFFF; 
                3'd7: PRBS_REG <= 32'h7FFFFFFF; 
                default: PRBS_REG <= 0;
            endcase
        end else if (PRBS_EN_REG) begin
            PRBS_REG[0] <= XOR_OUT;
            PRBS_REG[31:1] <= PRBS_REG[30:0];
        end
        
    always @ (*) 
        case (PRBS_TYPE)
            3'd0: XOR_OUT = PRBS_REG[2]  ^ PRBS_REG[0]; 
            3'd1: XOR_OUT = PRBS_REG[6]  ^ PRBS_REG[0];  
            3'd2: XOR_OUT = PRBS_REG[8]  ^ PRBS_REG[4]; 
            3'd3: XOR_OUT = PRBS_REG[10] ^ PRBS_REG[8];  
            3'd4: XOR_OUT = PRBS_REG[14] ^ PRBS_REG[0]; 
            3'd5: XOR_OUT = PRBS_REG[16] ^ PRBS_REG[2];  
            3'd6: XOR_OUT = PRBS_REG[22] ^ PRBS_REG[17]; 
            3'd7: XOR_OUT = PRBS_REG[31] ^ PRBS_REG[21] ^ PRBS_REG[1] ^ PRBS_REG[0];
            default: XOR_OUT = 0;
        endcase
    
//--------------------
// Output
//--------------------
    assign gen_shift_reg = PRBS_REG;
    assign dout_vld = DOUT_VLD_REG;
    assign dout = DOUT_VLD_REG ? XOR_OUT : 1'b0;
    
endmodule
`endif // _PRBS_GEN
