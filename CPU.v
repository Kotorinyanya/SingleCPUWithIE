module CPU(Clk, Clrn, Inst, Dread, Iaddr, Wmem, Dwirte, Daddr, Intr, Inta, Pcsrc, npc, V);
	input Clk, Clrn, Intr;
	input [31:0] Inst, Dread;
	output [31:0] Iaddr, Daddr, Dwirte;
	output Wmem;
	output Inta;

    output [31:0] npc;
    wire [31:0] p4, adr, res, ra, alu_mem, alua, alub, D, Cause_tmp, pppc, EPC_tmp;
    wire [4:0] reg_dest, wn;
    wire [3:0] aluc;
    output [2:0] Pcsrc;
    wire zero, wreg, regrt, reg2reg, shift, aluqb, jal, se;
    output V;
    wire [1:0] Mfc0;
    wire Mtc0;
	wire [31:0] cau;
	wire Wcau, Wsta, Wepc;
	wire [31:0] Ibase;

    wire [31:0] Cause, Status, EPC;
    
	ControlUnit CU (Inst[31:26], Inst[5:0], zero,
					Wmem, wreg, regrt, reg2reg, aluc,
                    shift, aluqb, Pcsrc, jal, se, V, Mfc0, Mtc0,
					Inst, cau, Wcau, Wsta, Wepc, Status, Intr, Inta, Ibase);

	wire [31:0] sa = {27'b0 , Inst[10:6]};  

	wire e = se & Inst[15];

	//符号拓展的符号?��?
	wire [15:0] sign = {16{e}};

	wire [31:0] offset = {sign[13:0], Inst[15:0], 2'b00}; 
		 
    wire [31:0] immdiate = {sign , Inst[15:0]}; 

	//按�??��时钟上升沿执行命令
	dff32 ip (npc , Clk , Clrn , Iaddr); 

	cla32 pcplus4(Iaddr , 32'h4 , 1'b0 , p4);

	// 条件?��?支?��?令跳转地?��?
	cla32 br_adr(p4, offset, 1'b0, adr);

	// j 或�?? jal
	wire [31:0] jpc = {p4[31:28] , Inst[25:0],2'b00}; 

	// 写使能端
	assign wn = reg_dest | {5{jal}}; 
	RegFile rf (Inst[25:21], Inst[20:16], D, wn,
	                wreg, Clk, Clrn, ra, Daddr);               
			
    // jr?��?跳转地?��?
	MUX2X32 alu_a (ra , sa , shift , alua);
	MUX2X32 alu_b (Daddr, immdiate, aluqb, alub);

	ALU alu(alua, alub, aluc, Dwirte, zero, V);
	
	MUX2X5 reg_wn (Inst[15:11], Inst[20:16], regrt, reg_dest);

	MUX2X32 res_mem(Dwirte, Dread, reg2reg , alu_mem);

	//jal ?��?用
	MUX2X32 link(alu_mem,  p4 , jal , res);
	
	// added for write Cause/Status/EPC to registers in REGFILE 
	MUX4X32 IE_link(res, Status, Cause, EPC, Mfc0, D);
	// added for wirte registers in REGFILE to Cause/Status/EPC
	MUX2X32 C_link(cau, Daddr, Mtc0, Cause_tmp);
	dff32_w write_C(Cause_tmp, Clk, Clrn, Wcau, Cause);
	dff32_w write_S(Dwirte, Clk, Clrn, Wsta, Status);
	MUX2X32 S1_link(Iaddr, p4, Inta, pppc);
	MUX2X32 S2_link(pppc, Daddr, Mtc0, EPC_tmp);
	dff32_w write_E(EPC_tmp, Clk, Clrn, Wepc, EPC);

	// added epc and base
	MUX8X32 nextpc(p4, adr, ra, jpc, Ibase, EPC, 32'h0, 32'h0, Pcsrc, npc); //Ibase = 5'h54 (5'h15 x 4)

endmodule
