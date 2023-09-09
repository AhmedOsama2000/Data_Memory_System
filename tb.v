module testbench;

	parameter DATA_WIDTH = 32; 		  
	parameter ADDR_WIDTH = 10;  		   // Address Size (Word Addressable)

	reg  			      CLK;
	reg  				  rst_n;
	reg 				  MemRead;
	reg  				  MemWrite;
	reg [ADDR_WIDTH-1:0]  WordAddress;
	reg [DATA_WIDTH-1:0]  DataIn;
 
	wire                  Stall;
	wire [DATA_WIDTH-1:0] DataOut;

	integer i;
	localparam test_case_read  = 4;
	localparam test_case_write = 8;

	// DUT 
	data_memory_system DUT (
		.CLK(CLK),
		.rst_n(rst_n),
		.MemRead(MemRead),
		.MemWrite(MemWrite),
		.WordAddress(WordAddress),
		.DataIn(DataIn),
		.Stall(Stall),
		.DataOut(DataOut)
	);

	always begin
		CLK = !CLK;
		#1;
	end

	initial begin
		CLK         = 1'b0;
		rst_n       = 1'b0;
		MemRead     = 1'b0;
		MemWrite    = 1'b0;
		WordAddress = 10'b0;
		DataIn      = 32'b0;
		repeat (5) @(negedge CLK);
		rst_n = 1'b1;
		// Initialize the Main Memory
		for (i = 0; i < 1024; i = i + 1) begin
			DUT.Main_MEM.D_MEM[i] = $random;
		end

		// Test Different Load Cases
		// One miss , Three hits
		for (i = 0; i < test_case_read; i = i + 1) begin
			MemRead     = 1'b1;
			WordAddress = i;
			repeat (4) @(negedge CLK);
		end

		MemRead = 1'b0;
		repeat (5) @(negedge CLK);

		// Test Different Store Cases
		// Test Write-around in Case of Miss/ Write-through in case of hit
		for (i = 0; i < test_case_write; i = i + 1) begin
			MemWrite    = 1'b1;
			WordAddress = i;
			DataIn      = $random;
			repeat (4) @(negedge CLK);
		end


		repeat (5) @(negedge CLK);
		$stop;

	end


endmodule