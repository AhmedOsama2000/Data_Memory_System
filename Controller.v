module Controller (
	input  wire  rst_n,
	input  wire  CLK,
	input  wire	 Mem_Wr,
	input  wire  Mem_Rd,
	input  wire  Miss,
	input  wire  Ready,
	output reg   block_wr,
	output reg   EnMain_Rd,
	output reg	 stall
);

localparam IDLE       = 2'b00;
localparam READ_DATA  = 2'b01;
localparam WRITE_DATA = 2'b10;


// States 
reg [1:0]   CS;
reg [1:0]   NS;

// State Registering
always @(posedge CLK,negedge rst_n) begin
	if(!rst_n) begin
		CS <= IDLE;
	end 
	else begin
		CS <= NS;
	end
end

// States Transition
always @(*) begin
	case (CS)
		IDLE: begin
			if (Mem_Wr) begin
				NS = WRITE_DATA;
			end
			else if (Mem_Rd && Miss) begin
				NS = READ_DATA;
			end
			else begin
				NS = IDLE;
			end
		end
		READ_DATA: begin
			if (Ready) begin
				NS = IDLE;
			end
			else begin
				NS = READ_DATA;
			end
		end
		WRITE_DATA: begin
			if (Ready) begin
				NS = IDLE;
			end
			else begin
				NS = WRITE_DATA;
			end
		end
		default: begin
			NS = IDLE;
		end
	endcase
end

// FSM Output
always @(*) begin
	// Default Values
	stall     = 1'b0;
	EnMain_Rd = 1'b0;
	block_wr  = 1'b0;
	if ((CS == IDLE && Miss) || (CS == IDLE && Mem_Wr)) begin
		stall     = 1'b1;
	end
	else if (CS == READ_DATA && Ready) begin
		block_wr  = 1'b1;
		stall     = 1'b1;
	end
	else if (CS == READ_DATA) begin
		stall     = 1'b1;
		EnMain_Rd = 1'b1;
	end
	else if (CS == WRITE_DATA && !Ready) begin
		stall      = 1'b1;
	end
	else begin
		stall     = 1'b0;
		EnMain_Rd = 1'b0;
	end
end


endmodule