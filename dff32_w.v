module dff32_w(D, Clock, We, Q);	 
	input Clock, We;
	input [31:0] D;
	output reg [31:0] Q;
	always @(posedge Clock or negedge Reset) begin
		if(We) Q <= D;
	end
endmodule
