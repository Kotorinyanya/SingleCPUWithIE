module ControlUnit(Op, Func, Z, Wmem, Wreg, Regrt, Reg2reg, Aluc, Shift,
					Aluqb, Pcsrc, jal, Se, V, Mfc0, Mtc0, Inst, Cause,
					Wcau, Wsta, Wepc, Sta, Intr, Inta, Ibase);
	
	input [5:0] Op, Func;
	input Z;
	input V;
	output [3:0] Aluc;
	output [1:0] Pcsrc;
	output Wmem, Wreg, Regrt, Se, Shift, Aluqb, Reg2reg, jal;
	output [1:0] Mfc0;
	output Mtc0;
	output Wcau, Wsta, Wepc;
	input [31:0] Inst, Sta;
	output [31:0] Cause;
	input Intr;
	output Inta;
	output [31:0] Ibase;
		
	// R型指令
	wire i_add = (Op == 6'b000000 & Func == 6'b100000)?1:0;
	wire i_sub = (Op == 6'b000000 & Func == 6'b100010)?1:0;
	wire i_and = (Op == 6'b000000 & Func == 6'b100100)?1:0;
	wire i_or  = (Op == 6'b000000 & Func == 6'b100101)?1:0;
	wire i_xor = (Op == 6'b000000 & Func == 6'b100110)?1:0;
	wire i_sll = (Op == 6'b000000 & Func == 6'b000000)?1:0;
	wire i_srl = (Op == 6'b000000 & Func == 6'b000010)?1:0;
	wire i_sra = (Op == 6'b000000 & Func == 6'b000011)?1:0;
	wire i_jr  = (Op == 6'b000000 & Func == 6'b001000)?1:0;

	// I型指令
	wire i_addi = (Op == 6'b001000)?1:0;
	wire i_andi = (Op == 6'b001100)?1:0; 
	wire i_ori  = (Op == 6'b001101)?1:0;
	wire i_xori = (Op == 6'b001110)?1:0;
	wire i_lw   = (Op == 6'b100011)?1:0;
	wire i_sw   = (Op == 6'b101011)?1:0;
	wire i_beq  = (Op == 6'b000100)?1:0;
	wire i_bne  = (Op == 6'b000101)?1:0;
	wire i_lui  = (Op == 6'b001111)?1:0;

	// J型指令
	wire i_j    = (Op == 6'b000010)?1:0;
	wire i_jal  = (Op == 6'b000011)?1:0;
	
	// mfc0 mtc0 eret instraction
	wire i_mfc0 = (Op == 6'b010000 & Func == 000000 & Inst[25:21] == 5'b00000)?1:0;
	wire i_mtc0 = (Op == 6'b010000 & Func == 000000 & Inst[25:21] == 5'b00100)?1:0;
	wire i_eret = (Inst == 32'b01000010000000000000000000011000)?1:0;
	
	assign Wreg  = i_add  | i_sub  | i_and | i_or | i_xor  | 
	i_sll | i_srl |i_sra |	i_addi | i_andi | 
	i_ori | i_or | i_xori | i_lw  | i_lui | i_jal;
	assign Regrt  = i_addi | i_andi | i_ori | i_xori |i_lw |i_lui;
	assign jal = i_jal;
	assign Reg2reg  = i_lw;
	assign Shift  = i_sll | i_srl |i_sra;
	assign Aluqb = i_addi | i_andi | i_ori | i_xori | i_lw |
	 i_lui |i_sw;
	assign Se = i_addi | i_lw | i_sw | i_beq | i_bne;
	assign Aluc[3] = i_sra;
	assign Aluc[2] = i_sub |i_or | i_srl | i_sra | i_ori |i_lui;
	assign Aluc[1] = i_xor | i_sll | i_srl | i_sra | i_xori |
	 i_beq | i_bne | i_lui;
	assign Aluc[0] = i_and | i_or | i_sll | i_srl |i_sra |
	 i_andi  | i_ori;
	assign Wmem  = i_sw;

	// add Mfc0
	if (i_mfc == 0) begin
		if (Inst[15:11] == 5'b11100) // Status
			assign Mfc0 = 2'b01;
		else if (Inst[15:11] == 5'b11101) // Cause
			assign Mfc0 = 2'b10;
		else if (Inst[15:11] == 5'b11110) // EPC
			assign Mfc0 = 2'b11;
  	end else begin
		assign Mfc0 = 2'b00;
  	end

	if (Intr == 1 & Sta[9] == 1) begin // Interrupt handling
		assign Inta = 1;
		assign Mtc0 = 0;
		assign Wepc = 1;
		assign Cause = 32'b0;
		assign Wcau = 1;
		assign Pcsrc = 3'b101; // base
		assign Ibase = 5'h1c;
	end else if(V == 1 & Sta[9] == 1) begin // Expection handling
		assign Inta = 0;
		assign Mtc0 = 0;
		assign Wepc = 1;
		assign Cause = 32'b0;
		assign Wcau = 1;
		assign Pcsrc = 3'b101; // base
		assign Ibase = 5'hXX; //TODO
	end else begin // no Interrupt or Expection
		assign Inta = 0;
		assign Mtc0 = 1;
		assign Wepc = 0;
		assign Wcau = 0;
		assign Pcsrc[2] = 0;
		assign Pcsrc[1] = i_jr | i_j | i_jal;
		assign Pcsrc[0] = i_beq & Z | i_bne&~Z | i_j | i_jal;
		assign Ibase = 5'h00;
	end


	// TODO: Wsta, Sta, 

endmodule
