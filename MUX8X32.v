module MUX8X32(A0, A1, A2, A3, A4, A5, A6, A7, S, Y);
    input [31:0] A0, A1, A2, A3, A4, A5, A6, A7;
    input [2:0] S;
    output [31:0] Y;
    assign Y = (S == 3'b000)? A0 :
                 (S == 3'b001)? A1 :
	             (S == 3'b010)? A2 : 
	             (S == 3'b011)? A3 :
                 (S == 3'b100)? A4 :
                 (S == 3'b101)? A5 :
                 (S == 3'b110)? A6 :
                 A7;
endmodule
