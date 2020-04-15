transcript on
vlib work

vlog -sv +incdir+./ src./prbs_tb.sv
vlog -v  +incdir+./ src./PRBS_GEN.v
vlog -v  +incdir+./ src./PRBS_RX.v

vsim -t 1ns -voptargs="+acc" prbs_tb -novopt -L xilinxcorelib_ver

add wave 	-radix unsigned		/prbs_tb/PRBS_TYPE
add wave 						/prbs_tb/tx_rst
add wave 						/prbs_tb/tx_clk
add wave 						/prbs_tb/tx_prbs_en
add wave 						/prbs_tb/tx_dout_vld
add wave 						/prbs_tb/tx_dout

# FIFO1
add wave 						/prbs_tb/FIFO1_RST
add wave 						/prbs_tb/FIFO1_WR_CLK
add wave 						/prbs_tb/FIFO1_WR_EN
add wave 						/prbs_tb/FIFO1_DIN
add wave -radix unsigned		/prbs_tb/FIFO1_WR_CNT
add wave 						/prbs_tb/FIFO1_WR_ACK

add wave 						/prbs_tb/FIFO1_RD_CLK
add wave 						/prbs_tb/FIFO1_RD_EN
add wave 						/prbs_tb/FIFO1_DOUT_VLD
add wave 						/prbs_tb/FIFO1_DOUT
add wave -radix unsigned		/prbs_tb/FIFO1_RD_CNT
add wave 						/prbs_tb/FIFO1_FULL
add wave 						/prbs_tb/FIFO1_EMPTY

# RX1
add wave 						/prbs_tb/rx1_rst
add wave 						/prbs_tb/rx1_clk
add wave 						/prbs_tb/RX1_DIN_VLD
add wave 						/prbs_tb/RX1_DIN
add wave 						/prbs_tb/RX1_DOUT_XOR
add wave -radix unsigned		/prbs_tb/RX1_SYNC_CNT
add wave -radix unsigned		/prbs_tb/RX1_BIT_CNT
add wave 						/prbs_tb/RX1_BIT_CNT_FULL
add wave -radix unsigned		/prbs_tb/RX1_ERR_CNT
add wave 						/prbs_tb/rx1_dout_vld
add wave 						/prbs_tb/rx1_dout

# FIFO2
add wave 						/prbs_tb/FIFO2_RST
add wave 						/prbs_tb/FIFO2_WR_CLK
add wave 						/prbs_tb/FIFO2_WR_EN
add wave 						/prbs_tb/FIFO2_DIN
add wave -radix unsigned		/prbs_tb/FIFO2_WR_CNT
add wave 						/prbs_tb/FIFO2_WR_ACK

add wave 						/prbs_tb/FIFO2_RD_CLK
add wave 						/prbs_tb/FIFO2_RD_EN
add wave 						/prbs_tb/FIFO2_DOUT_VLD
add wave 						/prbs_tb/FIFO2_DOUT
add wave -radix unsigned		/prbs_tb/FIFO2_RD_CNT
add wave 						/prbs_tb/FIFO2_FULL
add wave 						/prbs_tb/FIFO2_EMPTY

# RX2
add wave 						/prbs_tb/rx2_rst
add wave 						/prbs_tb/rx2_clk
add wave 						/prbs_tb/RX2_DIN_VLD
add wave 						/prbs_tb/RX2_DIN
add wave 						/prbs_tb/RX2_DOUT_XOR
add wave -radix unsigned		/prbs_tb/RX2_SYNC_CNT
add wave -radix unsigned		/prbs_tb/RX2_BIT_CNT
add wave 						/prbs_tb/RX2_BIT_CNT_FULL
add wave -radix unsigned		/prbs_tb/RX2_ERR_CNT
add wave 						/prbs_tb/rx2_dout_vld
add wave 						/prbs_tb/rx2_dout

configure wave -timelineunits ns
run
wave zoom full