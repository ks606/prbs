`timescale 1ns/1ps
//`include "PRBS_GEN.v"
//`include "PRBS_RX.v"
module PRBS_TB;
    parameter PRBS_TYPE = 7;
    parameter BIT_CNT_WIDTH = 10;
    parameter ERR_CNT_WIDTH = 10;
//	parameter FIFO_BITS = 1;
//	parameter FIFO_SIZE = 1024;
    
    logic sys_clk = 0;
    logic sys_rst = 0;
    
    logic tx_clk = 0;
    logic tx_rst = 0;
    logic tx_prbs_en = 0;		
    logic tx_dout_vld;
    logic tx_dout;
    
    logic rx1_clk = 0;
    logic rx1_rst = 0;	
    logic rx1_dout_vld;
    logic rx1_dout;
    
    logic rx2_clk = 0;
    logic rx2_rst = 0;
    logic rx2_dout_vld;
    logic rx2_dout;
    
    PRBS_TX #(
        .PRBS_TYPE(PRBS_TYPE)
    )_PRBS_TX(
        .clk        (tx_clk), 
        .rst        (tx_rst),
        
        // Inputs
        .prbs_en    (tx_prbs_en), 
        
        // Outputs
        .dout_vld   (tx_dout_vld),
        .dout       (tx_dout)
    );
    
    logic       FIFO1_WR_CLK;
    logic       FIFO1_RD_CLK;
    logic       FIFO1_RST;
    logic       FIFO1_WR_EN;
    logic       FIFO1_RD_EN;
    logic       FIFO1_DIN;
    logic       FIFO1_DOUT_VLD;
    logic [7:0] FIFO1_DOUT;
    logic       FIFO1_EMPTY;
    logic       FIFO1_FULL;
    logic       FIFO1_WR_ACK;
    logic [9:0] FIFO1_WR_CNT;
    logic [9:0]	FIFO1_RD_CNT;
    
    assign FIFO1_WR_CLK = tx_clk;
    assign FIFO1_RD_CLK = rx1_clk;
    assign FIFO1_RST    = sys_rst;
    assign FIFO1_WR_EN  = tx_dout_vld;
    assign FIFO1_RD_EN  = 1'b1;
    assign FIFO1_DIN    = tx_dout;
    
    FIFO_2CLK
    _FIFO1(
        .rst            (!FIFO1_RST),
        
        // write
        .wr_clk	        (FIFO1_WR_CLK),
        .wr_en          (FIFO1_WR_EN),
        .din            ({FIFO1_DIN, 7'b0000_000}),
        
        // read
        .rd_clk         (FIFO1_RD_CLK),
        .rd_en          (FIFO1_RD_EN),
        .valid          (FIFO1_DOUT_VLD),
        .dout           (FIFO1_DOUT),
        
        .wr_ack         (FIFO1_WR_ACK),
        .full           (FIFO1_FULL),
        .empty          (FIFO1_EMPTY),
        
        .wr_data_count  (FIFO1_WR_CNT),
        .rd_data_count  (FIFO1_RD_CNT)
    );
    
    logic       FIFO2_WR_CLK;
    logic       FIFO2_RD_CLK;
    logic       FIFO2_RST;
    logic       FIFO2_WR_EN;
    logic       FIFO2_RD_EN;
    logic       FIFO2_DIN;
    logic       FIFO2_DOUT_VLD;
    logic [7:0] FIFO2_DOUT;
    logic       FIFO2_EMPTY;
    logic       FIFO2_FULL;
    logic       FIFO2_WR_ACK;
    logic [9:0]	FIFO2_WR_CNT;
    logic [9:0]	FIFO2_RD_CNT;
    
    assign FIFO2_RST    = sys_rst;
    assign FIFO2_WR_CLK = tx_clk;
    assign FIFO2_RD_CLK = rx2_clk;
    assign FIFO2_WR_EN  = tx_dout_vld;
    assign FIFO2_RD_EN  = 1'b1;
    assign FIFO2_DIN    = tx_dout;
    
    FIFO_2CLK
    _FIFO2(
        .rst            (!FIFO2_RST),
        
        // write section
        .wr_clk         (FIFO2_WR_CLK),
        .wr_en	        (FIFO2_WR_EN),
        .din            ({FIFO2_DIN, 7'b0000_000}),
        
        // read section
        .rd_clk         (FIFO2_RD_CLK),
        .rd_en          (FIFO2_RD_EN),
        .valid          (FIFO2_DOUT_VLD),
        .dout           (FIFO2_DOUT),
        
        .wr_ack	        (FIFO2_WR_ACK),
        .full           (FIFO2_FULL),
        .empty          (FIFO2_EMPTY),

        .wr_data_count  (FIFO2_WR_CNT),
        .rd_data_count  (FIFO2_RD_CNT)
    );	
    
    logic                       RX1_BIT_CNT_FULL;
    logic [BIT_CNT_WIDTH-1:0]   RX1_BIT_CNT;
    logic [ERR_CNT_WIDTH-1:0]   RX1_ERR_CNT;
    logic [9:0]                 RX1_SYNC_CNT;
    logic                       RX1_DIN_VLD;
    logic                       RX1_DIN;
    logic                       RX1_DOUT_XOR;
    
    assign RX1_DIN_VLD = FIFO1_DOUT_VLD;
    assign RX1_DIN = FIFO1_DOUT[7];
    
    PRBS_RX #(
        .PRBS_TYPE      (PRBS_TYPE),
        .BIT_CNT_WIDTH  (BIT_CNT_WIDTH),
        .ERR_CNT_WIDTH  (ERR_CNT_WIDTH)
    )_PRBS_RX1(
        .clk            (rx1_clk),
        .rst            (rx1_rst),
        
        // Input
        .din_vld        (RX1_DIN_VLD),
        .din            (RX1_DIN),
    
        // Output
        .bit_cnt        (RX1_BIT_CNT),
        .bit_cnt_full   (RX1_BIT_CNT_FULL),
        .err_cnt        (RX1_ERR_CNT),
        .dout_vld       (rx1_dout_vld),
        .dout           (rx1_dout),
        
        .sync_cnt       (RX1_SYNC_CNT),
        .dout_xor       (RX1_DOUT_XOR)
    );
    
    logic                       RX2_BIT_CNT_FULL;
    logic [BIT_CNT_WIDTH-1:0]   RX2_BIT_CNT;
    logic [ERR_CNT_WIDTH-1:0]   RX2_ERR_CNT;
    logic [9:0]                 RX2_SYNC_CNT;
    logic                       RX2_DIN_VLD;
    logic                       RX2_DIN;
    logic                       RX2_DOUT_XOR;
    
    assign RX2_DIN_VLD = FIFO2_DOUT_VLD;
    assign RX2_DIN = FIFO2_DOUT[7];
    
    PRBS_RX #(
        .PRBS_TYPE      (PRBS_TYPE),
        .BIT_CNT_WIDTH  (BIT_CNT_WIDTH),
        .ERR_CNT_WIDTH  (ERR_CNT_WIDTH)
    )_PRBS_RX2(
        .clk            (rx2_clk),
        .rst            (rx2_rst),
        
        // Inputs
        .din_vld        (RX2_DIN_VLD),
        .din            (RX2_DIN),
    
        // Outputs
        .bit_cnt        (RX2_BIT_CNT),
        .bit_cnt_full   (RX2_BIT_CNT_FULL),
        .err_cnt        (RX2_ERR_CNT),
        .dout_vld       (rx2_dout_vld),
        .dout           (rx2_dout),
        
        .sync_cnt       (RX2_SYNC_CNT),
        .dout_xor       (RX2_DOUT_XOR)
    );
    
    always #20 sys_clk = !sys_clk;
    always #10 sys_rst = 1;
    
    always #20 tx_clk = !tx_clk;
    always #1  tx_rst = 1;
    
    always #31 rx1_clk = !rx1_clk;
    always #10 rx1_rst = 1;
    
    always #1.3 rx2_clk = !rx2_clk;
    always #10  rx2_rst = 1;
    
    always @ (posedge sys_clk)
        tx_prbs_en <= !tx_prbs_en;
    
endmodule
