module ControlUnit(Op, Func, Z, Wmem, Wreg, Regrt, Reg2reg, Aluc, Shift,
					Aluqb, Pcsrc, jal, Se, V, Mfc0, Mtc0, Inst, Cause,
					Wcau, Wsta, Wepc, Sta, Intr, Inta, Ibase);
	
	input [5:0] Op, Func;
	input Z;
	input V;
	output [3:0] Aluc;
	output [2:0] Pcsrc;
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
	i_ori | i_or | i_xori | i_lw  | i_lui | i_jal | i_mfc0;
	assign Regrt  = i_addi | i_andi | i_ori | i_xori | i_lw | i_lui | i_mfc0 | i_mtc0;
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
	assign Wsta = (i_mtc0 & (Inst[15:11] == 5'b11100))?1:0;
    assign Mfc0 = (i_mfc0 == 1 & Inst[15:11] == 5'b11100) ? 2'b01 :     // Status
                (i_mfc0 == 1 & Inst[15:11] == 5'b11101) ? 2'b10 :       // Cause
                (i_mfc0 == 1 & Inst[15:11] == 5'b11110) ? 2'b11 :       // EPC
                                                          2'b00;
   assign Mtc0 = ((Intr == 1 & Sta[9] == 1) | (V == 1 & Sta[9] == 1))?0:1;                                                       
   assign Inta = (Intr == 1 & Sta[9] == 1)?1:0;
   assign Wepc = ((Intr == 1 & Sta[9] == 1) | (V == 1 & Sta[9] == 1))?1:0;
   assign Wcau = ((Intr == 1 & Sta[9] == 1) | (V == 1 & Sta[9] == 1))?1:0;
   assign Cause = (Intr == 1 & Sta[9] == 1) ? 32'b0 :
                  (V == 1 & Sta[9] == 1) ? 32'b100 :
                                            32'b1;
   assign Pcsrc[2] = ((Intr == 1 & Sta[9] == 1) | (V == 1 & Sta[9] == 1) | i_eret)?1:0;
   assign Pcsrc[1] = i_jr | i_j | i_jal;
   assign Pcsrc[0] = i_beq & Z | i_bne&~Z | i_j | i_jal | i_eret;
   assign Ibase = 32'h54;   //5'h15   //Note: faild attemption: calculate base in CU
                    
endmodule
