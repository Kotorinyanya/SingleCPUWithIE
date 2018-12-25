module dff32_w(D, Clock, Clrn, We, Q);	 
	input Clock, We, Clrn;
	input [31:0] D;
	output reg [31:0] Q;
	always @(posedge Clock or negedge Clrn) begin
		if (Clrn == 0) begin
		  Q <= 0;
		end else if(We) 
		  Q <= D;
	end
endmodule
