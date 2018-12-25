module Main(Clk, Clrn, inst, addr, aluout, memout, Intr, Inta, Pcsrc, npc, V);
	input Clk, Clrn, Intr;
	output [31:0] inst, addr, aluout, memout;
	output Inta;
    output [31:0] npc;
    output [2:0] Pcsrc;
    output V;
	wire [31:0] data;
	wire        wmem;	
	INSTMEM imem(addr, inst);
	CPU cpu (Clk, Clrn, inst, memout, addr, wmem, aluout, data, Intr, Inta, Pcsrc, npc, V);
	DATAMEM dmem(Clk, memout, data, aluout, wmem);
endmodule
