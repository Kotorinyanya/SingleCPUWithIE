module test_main();
    reg Clock;
	reg Reset;
	wire[31:0] inst;
	wire[31:0] addr;
	wire[31:0] aluout;
	wire[31:0] memout;
	wire[2:0] Pcsrc;
	wire[31:0] npc;
	reg Intr;
	wire Inta;
	wire V;
    Main main(.Clk(Clock), .Clrn(Reset), .inst(inst), .addr(addr), .aluout(aluout), .memout(memout), .Intr(Intr), .Inta(Inta), .Pcsrc(Pcsrc), .npc(npc), .V(V));
    initial begin
        $dumpfile("test.vcd");  
        $dumpvars(0,test_main);
		Clock = 0;
		Reset = 0;
		Intr = 0;

		#40 Reset <= 1;

		#1000 $finish();
	end
	
	always #20 Clock = ~Clock;
	always #640 Intr = ~Intr;
	always #680 Intr = ~Intr;
	always #940 Intr = ~Intr;
endmodule