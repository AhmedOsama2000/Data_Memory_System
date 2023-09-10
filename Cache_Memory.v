module Cache_Memory #(
	parameter DATA_WIDTH = 32, 		  
	parameter ADDR_WIDTH = 10,  		   // Address Size (Word Addressable)
	parameter BLOCKS_NUM = 32,  		   // Number of Block Lines
	parameter INDEX      = $clog2(BLOCKS_NUM), 
	parameter OFFSET     = 2,              // To choose which word
	parameter TAG        = ADDR_WIDTH - INDEX - OFFSET
)
(
	input  wire 	              rst_n,
	input  wire 	              CLK,
	input  wire                   block_wr,
	input  wire                   Mem_Wr,
	input  wire                   Mem_Rd,
	// Address Encapsulation
	input  wire [ADDR_WIDTH-1:0]  Address,

	input  wire [DATA_WIDTH-1:0]  Data_in,   // From Processor While Writing

	input  wire [DATA_WIDTH-1:0]  cache_in0, // From Main Memory in case of miss
	input  wire [DATA_WIDTH-1:0]  cache_in1,
	input  wire [DATA_WIDTH-1:0]  cache_in2,
	input  wire [DATA_WIDTH-1:0]  cache_in3,

	// To Controller
	output reg                    Miss,
	// Data Out
	output reg  [DATA_WIDTH-1:0]  Data_out    
);

integer i;

// Address Mapping
wire [INDEX-1:0]     index_mapping;
wire [TAG-1:0]       tag_mapping; 
wire [OFFSET-1:0]    offset_mapping; 

reg [TAG-1:0] tag   [BLOCKS_NUM-1:0];
reg 		  valid [BLOCKS_NUM-1:0];

assign offset_mapping = Address[OFFSET-1:0];
assign index_mapping  = Address[ADDR_WIDTH-TAG-1:ADDR_WIDTH-TAG-INDEX];
assign tag_mapping    = Address[ADDR_WIDTH-1:ADDR_WIDTH-TAG];

assign tag_out   = tag[index_mapping];
assign valid_out = valid[index_mapping];

reg [DATA_WIDTH-1:0] cache_word0 [BLOCKS_NUM-1:0];
reg [DATA_WIDTH-1:0] cache_word1 [BLOCKS_NUM-1:0];
reg [DATA_WIDTH-1:0] cache_word2 [BLOCKS_NUM-1:0];
reg [DATA_WIDTH-1:0] cache_word3 [BLOCKS_NUM-1:0];

always @(posedge CLK,negedge rst_n) begin
	if (!rst_n) begin
		for (i = 0;i < BLOCKS_NUM;i = i + 1) begin
			valid[i]       <= 1'b0;
			tag[i]         <= 'b0;
			cache_word0[i] <= 'b0;
			cache_word1[i] <= 'b0;
			cache_word2[i] <= 'b0;
			cache_word3[i] <= 'b0;
		end
	end
	else if (block_wr) begin
		cache_word0[index_mapping] <= cache_in0;
		cache_word1[index_mapping] <= cache_in1;
		cache_word2[index_mapping] <= cache_in2;
		cache_word3[index_mapping] <= cache_in3;
		valid[index_mapping]       <= 1'b1;
		tag[index_mapping]         <= tag_mapping;
	end
	else if (Mem_Wr && !Miss) begin
		if (offset_mapping == 2'b00) begin      // Write in first word
			cache_word0[index_mapping] <= Data_in;
		end 
		else if (offset_mapping == 2'b01) begin // Write in second word
			cache_word1[index_mapping] <= Data_in;
		end
		else if (offset_mapping == 2'b10) begin // Write in third word
			cache_word2[index_mapping] <= Data_in;
		end
		else begin                         // Write in Fourth word
			cache_word3[index_mapping] <= Data_in;
		end
	end

end

// Detect a Miss Signal
always @(*) begin
	if (Mem_Wr || Mem_Rd) begin
		if ((tag[index_mapping] != tag_mapping) || !valid[index_mapping]) begin
			Miss = 1'b1;
		end
		else begin
			Miss = 1'b0;
		end
	end
	else begin
		Miss = 1'b0;
	end
end

always @(*) begin
	if (offset_mapping == 2'b00) begin
		Data_out = cache_word0[index_mapping];
	end
	else if (offset_mapping == 2'b01) begin
		Data_out = cache_word1[index_mapping];
	end
	else if (offset_mapping == 2'b10) begin
		Data_out = cache_word2[index_mapping];
	end
	else begin
		Data_out = cache_word3[index_mapping];
	end
end

endmodule