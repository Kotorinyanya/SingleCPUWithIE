module INSTMEM(Addr, Inst); 
	input  [31:0] Addr;
	output [31:0] Inst;
	wire [31:0] Ram [0:31];
	assign Ram[5'h00] = 32'b01000000000010101110000000000000; //mfc0 R10, Status	//Enable IE handling
    assign Ram[5'h01] = 32'b00110101010010100000001000000000; //ori R10, R10, 512
    assign Ram[5'h02] = 32'b01000000100010101110000000000000; //mtc0 R10, Status
	assign Ram[5'h03] = 32'h3C018008; //lui R1 , 0x8008
	assign Ram[5'h04] = 32'h3C028000; //lui R2 , 0x8000
	assign Ram[5'h05] = 32'h00221820; //add R3 , R1 , R2	//Arithmetic overflow expection
	assign Ram[5'h06] = 32'h10220001; //beq R2 , R1 , 1
	assign Ram[5'h07] = 32'h00222020;  //add R4 , R1 , R2
	assign Ram[5'h08] = 32'h00223025;  // or R6 , R1 , R2
    assign Ram[5'h09] = 32'h00222022;  // sub R4 , R1 , R2
    assign Ram[5'h0a] = 32'h00221826; //xor R3 , R1 , R2
    assign Ram[5'h0b] = 32'h00021880; //sll R3 , R2 , 2
    assign Ram[5'h0c] = 32'h00021882; //srl R3 , R2 , 2
    assign Ram[5'h0d] = 32'h00021883; //sra R3 , R2 , 2
    assign Ram[5'h0e] = 32'h20231234; //addi R3 , R1,0x1234
    assign Ram[5'h0f] = 32'h302300EF; //andi R3 , R1,0xef
    assign Ram[5'h10] = 32'h342300EF; //ori   R3 , R1,0xef
    assign Ram[5'h11] = 32'h382300EF; //xori  R3 , R1,0xef
    assign Ram[5'h12] = 32'had420004; //sw R2 , 1(R10)
    assign Ram[5'h13] = 32'h8d420004; //lw R2 , 1(R10)
    assign Ram[5'h14] = 32'h0c000016; //jar 16
	
	// reserved for IE handling
	assign Ram[5'h15] = 32'b01000000000010111110100000000000; //mfc0 R11, Cause		//Cause 11101; Status 11100; EPC 11110
	assign Ram[5'h16] = 32'b00000011111111111111100000100110; //xor R31, R31, R31 
	assign Ram[5'h17] = 32'b00010011111010110000000000000011; //beq R31, R11, 3	//Jump to interrupt handling
    assign Ram[5'h18] = 32'b00000000001000010000100000100110; //xor R1, R1, R1		//Expection handling
    assign Ram[5'h19] = 32'b00000000010000100001000000100110; //xor R2, R2, R2
    assign Ram[5'h1a] = 32'b00001000000000000000000000011110; //j 0x1e (eret)	
	assign Ram[5'h1b] = 32'b01000000000010101110000000000000; //mfc0 R10, Status	//Interrupt handling
    assign Ram[5'h1c] = 32'b00110001010010100000000000000000; //andi R10, R10, 0  //Disable IE handling
    assign Ram[5'h1d] = 32'b01000000100010101110000000000000; //mtc0 R10, Status
	assign Ram[5'h1e] = 32'b01000010000000000000000000011000; //eret
    
	assign Inst = Ram[Addr[6:2]];
endmodule
