module data_memory_system #(
	parameter DATA_WIDTH = 32, 		  
	parameter ADDR_WIDTH = 10
)
(
	input  wire  			     CLK,
	input  wire  				 rst_n,
	input  wire 				 MemRead,
	input  wire  				 MemWrite,
	input  wire [ADDR_WIDTH-1:0] WordAddress,
	input  wire [DATA_WIDTH-1:0] DataIn,
 
	output wire                  Stall,
	output wire [DATA_WIDTH-1:0] DataOut
);

// internal signals
wire [DATA_WIDTH-1:0] cache_in0_int;
wire [DATA_WIDTH-1:0] cache_in1_int;
wire [DATA_WIDTH-1:0] cache_in2_int;
wire [DATA_WIDTH-1:0] cache_in3_int;

wire                  block_wr_int;
wire                  Miss_int;
wire                  EnMain_Rd_int;
wire                  Ready_int;

Controller ctrl (
	.rst_n(rst_n),
	.CLK(CLK),
	.Mem_Wr(MemWrite),
	.Mem_Rd(MemRead),
	.Miss(Miss_int),
	.Ready(Ready_int),
	.block_wr(block_wr_int),
	.EnMain_Rd(EnMain_Rd_int),
	.stall(Stall)
);

Cache_Memory cache (
	.rst_n(rst_n),
	.CLK(CLK),
	.block_wr(block_wr_int),
	.Address(WordAddress),
	.Data_in(DataIn), 
	.Mem_Rd(MemRead),
	.Mem_Wr(MemWrite),
	.cache_in0(cache_in0_int),
	.cache_in1(cache_in1_int),
	.cache_in2(cache_in2_int),
	.cache_in3(cache_in3_int),
	.Miss(Miss_int),
	.Data_out(DataOut)  
);

Main_Memory Main_MEM (
	.rst_n(rst_n),
	.CLK(CLK),
	.Mem_Wr(MemWrite),
	.EnMain_Rd(EnMain_Rd_int),
	.Address(WordAddress),
	.Data_in(DataIn),
	.cache_in0(cache_in0_int),
	.cache_in1(cache_in1_int),
	.cache_in2(cache_in2_int),
	.cache_in3(cache_in3_int),
	.Ready(Ready_int)   
);

endmodule