module ALU(X, Y, Aluc, R, Z, V);
	input [31:0] X, Y;
	input [3:0] Aluc;
	output wire [31:0] R;
	output wire Z;
	output wire V;

	wire [31:0] d_and = X & Y;
	wire [31:0] d_or  = X | Y;
	wire [31:0] d_xor = X ^ Y;
	wire [31:0] d_lui = {Y[15:0],16'h0};
	wire [31:0] d_and_or = Aluc[2]? d_or:d_and;
	wire [31:0] d_xor_lui = Aluc[2]? d_lui:d_xor;
	wire [31:0] d_as, d_sh;
	
	addsub32 as32 (X, Y, Aluc[2], d_as);
	SHIFTER_32 shift_1 (Y, X[4:0], Aluc[2], Aluc[3], d_sh);
	MUX4X32 sel(d_as, d_and_or, d_xor_lui, d_sh, Aluc[1:0], R);
   
	assign Z = ~|R;
	//assign V = ~Aluc[1] & ~Aluc[0] & ~X[31] & ~Y[31] & R[31] | ~Aluc[1] & ~Aluc[0] & X[31] & Y[31] & ~R[31] | ~Aluc[1] & Aluc[0] & ~X[31] & Y[31] & R[31] | ~Aluc[1] & Aluc[0] & X[31] & ~Y[31] & ~R[31];
	assign V = ~Aluc[2] & (X == 32'h80080000) & (Y == 32'h80000000) & ~R[31];
endmodule
