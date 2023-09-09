module Main_Memory #(
	parameter DATA_WIDTH = 32,  		// (Word Addressable)
	parameter DEPTH      = 1024, 		// Number of Block Lines
	parameter ADDR_WIDTH = $clog2(DEPTH)
)
(
	// Input
	input  wire 	   			 rst_n,
	input  wire 	   			 CLK,
	input  wire        			 Mem_Wr,
	input  wire        			 EnMain_Rd,
	input  wire [ADDR_WIDTH-1:0] Address,
	input  wire [DATA_WIDTH-1:0] Data_in,

	// Output
	output reg  [DATA_WIDTH-1:0] cache_in0,
	output reg  [DATA_WIDTH-1:0] cache_in1,
	output reg  [DATA_WIDTH-1:0] cache_in2,
	output reg  [DATA_WIDTH-1:0] cache_in3,
	output reg                   Ready          
);

integer i;
reg [1:0] op_count;

reg [DATA_WIDTH-1:0] D_MEM [DEPTH-1:0];

always @(posedge CLK,negedge rst_n) begin

	if (!rst_n) begin
		for (i = 0;i < DEPTH;i = i + 1) begin
			D_MEM[i] <= 1'b0;
		end
		cache_in0 <= 'b0;
		cache_in1 <= 'b0;
		cache_in2 <= 'b0;
		cache_in3 <= 'b0;
		Ready     <= 1'b0;
		op_count  <= 2'b00;
	end
	else if (Mem_Wr) begin
		if (op_count == 2'b11) begin
			D_MEM[Address] <= Data_in;
			Ready          <= 1'b1;
			op_count       <= 2'b00;
		end
		else begin
			op_count <= op_count + 1'b1;
			Ready    <= 1'b0;
		end
	end
	else if (EnMain_Rd) begin
		if (op_count == 2'b01) begin
			cache_in0 <= D_MEM[{Address[9:2],2'b00}];
			cache_in1 <= D_MEM[{Address[9:2],2'b01}];
			cache_in2 <= D_MEM[{Address[9:2],2'b10}];
			cache_in3 <= D_MEM[{Address[9:2],2'b11}];
			Ready          <= 1'b1;
			op_count       <= 2'b00;
		end
		else begin
			op_count <= op_count + 1'b1;
			Ready    <= 1'b0;
		end
	end
	else begin
		Ready  <= 1'b0;
	end

end

endmodule