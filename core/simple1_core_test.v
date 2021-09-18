module simple1_core_test(
    input clock, reset, exec,

    // IO not yet(maybe DMA method)
    // input [15:0] in, 
    // output [15:0] out,

    output [15:0] PC_addr,
    input [15:0] inst,

    output [15:0] mem_addr,
    output [15:0] mem_write_data,
    output mem_write,
    input [15:0] mem_read_data,
	 
	/*
     * for debug
     *
     */

    // registers
	output [15:0] r1_out, r2_out, r3_out, r4_out, r5_out, r6_out, r7_out,

    output [15:0] IR_out,

    output mem_write_2_3_out, regDst_out, regWrite_2_3_out,
    output [1:0] regsrc_2_3_out,

    output [2:0] dest_3_4_out,
    output [15:0] DR_3_4_out,
    output mem_write_3_4_out, regWrite_3_4_out,
    output [1:0] regsrc_3_4_out,

    output [2:0] dest_4_5_out,
    output [15:0] DR_4_5_out, MDR_out,
    output regWrite_4_5_out,
    output [1:0] regsrc_4_5_out,

    //controll signals
    output op_ALUsrc_out, op_memWrite_out, op_regDst_out, op_regWrite_out, 
    output [1:0] op_regsrc_out,
    output [3:0] ALUop_out
);

// REGS / WIRES   

    // REGS / WIRES   

    // register file and the reset signal
    wire [15:0] r0; // General register 0 (zero register)
    reg [15:0] r1; // General register 1
    reg [15:0] r2; // General register 2
    reg [15:0] r3; // General register 3
    reg [15:0] r4; // General register 4
    reg [15:0] r5; // General register 5
    reg [15:0] r6; // General register 6
    reg [15:0] r7; // General register 7
    wire reset_r1, reset_r2, reset_r3, reset_r4, reset_r5, reset_r6, reset_r7; // reset signal

    // /p1 pipeline registers
    reg [15:0] PC; // Program counter
    wire reset_PC; // reset signal
    wire preserve_PC; // preserve the value of PC

    // p1/p2 pipeline registers and the reset signal
    reg [15:0] IR; // Instruction Register
    reg [15:0] PC_1_2; // PC
    reg [15:0] PC_plus_1_2; // register for PC+1
    wire reset_IR, reset_PC_1_2, reset_PC_plus_1_2; // reset signal
    wire preserve_read_register; // preserve the value of p1/p2 pipeline register

    // p2/p3 pipeline registers and the reset signal
    reg [15:0] PC_plus_2_3; // PC+1
    reg [2:0] reg1; // register to write (inst[13:11])
    reg [2:0] reg2; // register to write (inst[10:8])
    reg [15:0] AR_2_3; // Content of register inst[13:11] rs
    reg [15:0] BR; // Content of register inst[10:8] rd
    reg [3:0] shift_bits; // the number of bits of the shift operation
    reg [15:0] immediate_2_3; // immediate number
    reg op_ALUsrc_2_3; // control signals
    reg [3:0] ALUop_2_3; // control signals
    reg mem_write_2_3, regDst, regWrite_2_3; // control signal
    reg [1:0] regsrc_2_3; // control signal
    wire reset_PC_plus_2_3, reset_reg1, reset_reg2, reset_AR_2_3, reset_BR, reset_shift_bits, reset_immediate_2_3, reset_op_ALUsrc_2_3, 
    reset_ALUop_2_3, reset_mem_write_2_3, reset_regDst, reset_regWrite_2_3, reset_regsrc_2_3; // reset signal

    // p3/p4 pipeline registers and the reset signal
    reg [15:0] PC_plus_3_4; // PC+1
    reg [2:0] dest_3_4; // register to write 
    reg [15:0] AR_3_4; // Content of register inst[13:11] rs
    reg [15:0] immediate_3_4; // immediate number
    reg [15:0] DR_3_4; // Result of ALU
    reg mem_write_3_4, regWrite_3_4; // control signal
    reg [1:0] regsrc_3_4; // control signals
    wire reset_PC_plus_3_4, reset_dest_3_4, reset_AR_3_4, reset_immediate_3_4, reset_DR_3_4, reset_mem_write_3_4, reset_regWrite_3_4, reset_regsrc_3_4;  // reset signal

    // p4/p5 pipeline registers and the reset signal
    reg [15:0] PC_plus_4_5; // PC+1
    reg [2:0] dest_4_5; // register to write
    reg [15:0] immediate_4_5; // immediate number 
    reg [15:0] DR_4_5; // Result of ALU
    reg [15:0] MDR; // Content of RAM
    reg regWrite_4_5; // control signal
    reg [1:0] regsrc_4_5; // control signal
    wire reset_PC_plus_4_5, reset_dest_4_5, reset_immediate_4_5, reset_DR_4_5, reset_MDR, reset_regWrite_4_5, reset_regsrc_4_5; // reset signal

    // p1 stage wires 
    wire [15:0] PC_plus_in;
    wire [15:0] PCsrc_in;
    wire [15:0] PC_in; // line from MUX_PCsrc to PC

    // p2 stage wires 
    wire [15:0] IR_in; // line from memData to instruction_fetch
    wire [15:0] PC_1_2_in; // line to PC_1_2
    wire [15:0] PC_plus_1_2_in; // line to PC_plus_1_2
    wire [15:0] immediate_in; // line to immediate
    wire [15:0] r1_in; // line to read_register
    wire [15:0] r2_in; // line to read_register
    wire [15:0] r3_in; // line to read_register
    wire [15:0] r4_in; // line to read_register
    wire [15:0] r5_in; // line to read_register
    wire [15:0] r6_in; // line to read_register
    wire [15:0] r7_in; // line to read_register
    wire [15:0] AR_in; // line from read_register to AR
    wire [15:0] BR_in; // line from read_register to BR
    wire [15:0] branch_addr; // branch address
    wire branch_stall; // control signal
    wire load_stall; // control signal
    wire op_ALUsrc; // Control signals
    wire [3:0] ALUop; // Control signals
    wire op_memWrite, op_regDst, op_regWrite; // Control signals
    wire [1:0] op_regsrc;
    wire [1:0] op_PCsrc; // Control signals

    // p3 stage wires 
    wire [1:0] forwardA_in, forwardB_in; // MUX_forwardA, MUX_forwardB
    wire [2:0] dest_in; // line from MUX_regDst to dest_3_4
    wire [15:0] dataA, dataB; // data after forwarding process
    wire [15:0] ALUsrc; // line from MUX_ALUsrc to ALU

    // p4 stage wires 
    reg S = 1'b0; // Condition codes
	reg Zero = 1'b0; // Condition codes
	reg C = 1'b0; // Condition codes
	reg V = 1'b0; // Condition codes
    wire reset_Condition; // reset signal
    wire [15:0] DR_in; // line from ALU to DR
    wire S_in, Zero_in, C_in, V_in; // line from ALU to S, Zero, C, V

    // p5 stage wires 
    wire [15:0] writeData_in; // line from MUX_regsrc to write_register and MUX_PCsrc
    wire regwrite_r0, regwrite_r1, regwrite_r2, regwrite_r3, regwrite_r4, regwrite_r5, regwrite_r6, regwrite_r7; 
        // decoded regWrite 



// WIRING

    /*
     * wiring of reset signals
     */
    
    // general registers
    assign reset_r1 = reset;
    assign reset_r2 = reset;
    assign reset_r3 = reset;
    assign reset_r4 = reset;
    assign reset_r5 = reset;
    assign reset_r6 = reset;
    assign reset_r7 = reset;
	 
	 // condition codes
	 assign reset_Condition = reset;

    // PC
    assign reset_PC = reset;

    // p1/p2
    assign reset_IR = reset | branch_stall;
    assign reset_PC_1_2 = reset | branch_stall;
    assign reset_PC_plus_1_2 = reset | branch_stall;

    // p2/p3
    assign  reset_PC_plus_2_3 = reset;
    assign  reset_reg1 = reset;
    assign  reset_reg2 = reset;
    assign  reset_AR_2_3 = reset;
    assign  reset_BR = reset;
    assign  reset_shift_bits = reset;
    assign  reset_immediate_2_3 = reset;
    assign  reset_op_ALUsrc_2_3  = reset | load_stall;
    assign  reset_ALUop_2_3 = reset | load_stall;
    assign  reset_mem_write_2_3 = reset | load_stall;
    assign  reset_regDst = reset | load_stall;
    assign  reset_regWrite_2_3 = reset | load_stall;
    assign  reset_regsrc_2_3 = reset | load_stall;

    // p3/p4
    assign  reset_PC_plus_3_4 = reset;
    assign  reset_dest_3_4 = reset;
    assign  reset_AR_3_4 = reset;
    assign  reset_immediate_3_4 = reset;
    assign  reset_DR_3_4 = reset;
    assign  reset_mem_write_3_4 = reset;
    assign  reset_regWrite_3_4 = reset;
    assign  reset_regsrc_3_4 = reset;

    // p4/p5
    assign  reset_PC_plus_4_5 = reset;
    assign  reset_dest_4_5 = reset;
    assign  reset_immediate_4_5 = reset;
    assign  reset_DR_4_5 = reset;
    assign  reset_MDR = reset;
    assign  reset_regWrite_4_5 = reset;
    assign  reset_regsrc_4_5 = reset;

    /*
     * wiring of preserve signals
     */
    // for LOAD data hazard
    assign preserve_PC = load_stall;
    assign preserve_read_register = load_stall;

    /* 
     * ============================================================
     * p1 stage: instruction fetch
     */
    MUX_preserve preserve1( // preserve PC
        .now(PC),
        .next(PC_plus_in),
        .op(preserve_PC),
        .src(PCsrc_in)
    );

	MUX_PCsrc pcsrc(
        .PC_plus(PCsrc_in), 
        .branch_addr(branch_addr), 
        .regs(AR_in),
        .op(op_PCsrc), 
        .src(PC_in)
        );
    
    always @(posedge clock or posedge reset_PC) begin
        if (reset_PC == 1'b1) begin
            PC <= 16'b0000_0000_0000_0000;
        end else begin
            PC <= PC_in;
        end
    end

    assign PC_addr = PC; // path to the instruction memory 
    
    assign PC_plus_in = PC + 16'b0000_0000_0001; // increment PC

    /* 
     * wiring of p1/p2 pipeline register
     */

    MUX_preserve preserve2(
        .now(IR),
        .next(inst),
        .op(preserve_read_register),
        .src(IR_in)
    );

    MUX_preserve preserve3(
        .now(PC_1_2),
        .next(PC),
        .op(preserve_read_register),
        .src(PC_1_2_in)
    );

    MUX_preserve preserve4(
        .now(PC_plus_1_2),
        .next(PC_plus_in),
        .op(preserve_read_register),
        .src(PC_plus_1_2_in)
    );

    always @(posedge clock or posedge reset_IR) begin
        if (reset_IR == 1'b1) begin
            IR <= 16'b0000_0000_0000_0000;
        end else begin
            IR <= IR_in;
        end
    end

    always @(posedge clock or posedge reset_PC_1_2) begin
        if (reset_PC_1_2 == 1'b1) begin
            PC_1_2 <= 16'b0000_0000_0000_0000; 
        end else begin
            PC_1_2 <= PC_1_2_in;
        end
    end

    always @(posedge clock or posedge reset_PC_plus_1_2) begin
        if (reset_PC_plus_1_2 == 1'b1) begin
            PC_plus_1_2 <= 16'b0000_0000_0000_0000;
        end else begin
            PC_plus_1_2 <= PC_plus_1_2_in;
        end
    end

    /*
     * ============================================================
     * p2 stage: read register
     */
    // Controller
    core_controller ctr(
        .op1(IR[15:14]), 
        .op2(IR[13:11]), 
        .op3(IR[7:4]), 
        .ALUsrc(op_ALUsrc), 
        .memWrite(op_memWrite), 
        .regDst(op_regDst), 
        .regWrite(op_regWrite), 
        .regsrc(op_regsrc), 
        .ALUop(ALUop)
    );
    
    PC_controller PCctr(
        .op1(IR[15:14]),
        .op2(IR[13:11]),
        .op3(IR[7:4]),
        .cond(IR[10:8]),
        .S(S),
        .Zero(Zero),
        .C(C),
        .V(V),
        .PCsrc(op_PCsrc),
        .stall(branch_stall)
    );

    load_hazard lh(
        .op1(IR[15:14]),
        .op2(IR[13:11]), 
        .op3(IR[7:4]),
        .regsrc_2_3(regsrc_2_3),
        .reg1(IR[13:11]),
        .reg2(IR[10:8]),
        .dest(reg1),
        .hazard(load_stall)
    );
    
    MUX_read_register MUX_read_register1( // to read and write register simultaneously
        .r1(r1), 
        .r2(r2),
        .r3(r3),
        .r4(r4),
        .r5(r5),
        .r6(r6),
        .r7(r7),
        .writeData(writeData_in),
        .regwrite_r1(regwrite_r1),
        .regwrite_r2(regwrite_r2),
        .regwrite_r3(regwrite_r3),
        .regwrite_r4(regwrite_r4),
        .regwrite_r5(regwrite_r5),
        .regwrite_r6(regwrite_r6),
        .regwrite_r7(regwrite_r7),
        .r1_src(r1_in),
        .r2_src(r2_in),
        .r3_src(r3_in),
        .r4_src(r4_in),
        .r5_src(r5_in),
        .r6_src(r6_in),
        .r7_src(r7_in)
    );

    read_register ID(
    .address1(IR[13:11]), 
    .address2(IR[10:8]), 
    .register0(r0), 
    .register1(r1_in), 
    .register2(r2_in), 
    .register3(r3_in), 
    .register4(r4_in), 
    .register5(r5_in), 
    .register6(r6_in), 
    .register7(r7_in), 
    .res1(AR_in), 
    .res2(BR_in)
    );

    assign immediate_in = {{8{IR[7]}}, IR[7:0]}; // sign extension

    assign branch_addr = PC_1_2 + immediate_in;

    /*
     * wiring of p2/p3 pipeline register
     */
    always @(posedge clock or posedge reset_PC_plus_2_3) begin
        if (reset_PC_plus_2_3 == 1'b1) begin
            PC_plus_2_3 <= 16'b0000_0000_0000_0000;
        end else begin
            PC_plus_2_3 <= PC_plus_1_2;
        end
    end

    always @(posedge clock or posedge reset_reg1) begin
        if (reset_reg1 == 1'b1) begin
            reg1 <= 3'b000;
        end else begin
            reg1 <= IR[13:11];
        end
    end

    always @(posedge clock or posedge reset_reg2) begin
        if (reset_reg2 == 1'b1) begin
            reg2 <= 3'b000;
        end else begin
            reg2 <= IR[10:8];
        end
    end
    
    always @(posedge clock or posedge reset_AR_2_3) begin
        if (reset_AR_2_3 == 1'b1) begin
            AR_2_3 <= 16'b0000_0000_0000_0000;
        end else begin
            AR_2_3 <= AR_in;
        end
    end

    always @(posedge clock or posedge reset_BR) begin
        if (reset_BR == 1'b1) begin
            BR <= 16'b0000_0000_0000_0000;
        end else begin
            BR <= BR_in;
        end
    end

    always @(posedge clock or posedge reset_shift_bits) begin
        if (reset_shift_bits == 1'b1) begin
            shift_bits <= 4'b0000;
        end else begin
            shift_bits <= IR[3:0];
        end
    end

    always @(posedge clock or posedge reset_immediate_2_3) begin
        if (reset_immediate_2_3 == 1'b1) begin
            immediate_2_3 <= 16'b0000_0000_0000_0000;
        end else begin
            immediate_2_3 <= immediate_in;
        end
    end

    always @(posedge clock or posedge reset_op_ALUsrc_2_3) begin
        if (reset_op_ALUsrc_2_3 == 1'b1) begin
            op_ALUsrc_2_3 <= 1'b0;
        end else begin
            op_ALUsrc_2_3 <= op_ALUsrc;
        end
    end

    always @(posedge clock or posedge reset_ALUop_2_3) begin
        if (reset_ALUop_2_3 == 1'b1) begin
            ALUop_2_3 <= 4'b0000;
        end else begin
            ALUop_2_3 <= ALUop;
        end
    end

    always @(posedge clock or posedge reset_mem_write_2_3) begin
        if (reset_mem_write_2_3 == 1'b1) begin
            mem_write_2_3 <= 1'b0;
        end else begin
            mem_write_2_3 <= op_memWrite;
        end
    end

    always @(posedge clock or posedge reset_regsrc_2_3) begin
        if (reset_regsrc_2_3 == 1'b1) begin
            regsrc_2_3 <= 2'b00;
        end else begin
            regsrc_2_3 <= op_regsrc;
        end
    end

    always @(posedge clock or posedge reset_regDst) begin
        if (reset_regDst == 1'b1) begin
            regDst <= 1'b0;
        end else begin
            regDst <= op_regDst;
        end
    end

    always @(posedge clock or posedge reset_regWrite_2_3) begin
        if (reset_regWrite_2_3 == 1'b1) begin
            regWrite_2_3 <= 1'b0;
        end else begin
            regWrite_2_3 <= op_regWrite;
        end
    end

    /*
     * ============================================================
     * p3 stage: operation
     */
    forwarding_unit forwarding(
        .regWrite_3_4(regWrite_3_4),
        .regWrite_4_5(regWrite_4_5),
        .reg1(reg1),
        .reg2(reg2),
        .dest_3_4(dest_3_4),
        .dest_4_5(dest_4_5),
        .forwardA(forwardA_in),
        .forwardB(forwardB_in)
    );

    MUX_forward MUX_forwardA(
        .register(AR_2_3),
        .data_before1(DR_3_4),
        .data_before2(writeData_in),
        .op(forwardA_in),
        .src(dataA)
    );

    MUX_forward MUX_forwardB(
        .register(BR),
        .data_before1(DR_3_4),
        .data_before2(writeData_in),
        .op(forwardB_in),
        .src(dataB)
    );
    
    MUX_regDst MUX_regDst1(
        .rs(reg1), 
        .rd(reg2), 
        .op(regDst), 
        .dst(dest_in)
        );
    
    MUX_ALUsrc alusrc(
        .AR(dataA), 
        .d(immediate_2_3), 
        .op(op_ALUsrc_2_3), 
        .src(ALUsrc)
        );
    ALU EX(
        .data1(ALUsrc),
        .data2(dataB),  
        .shamt(shift_bits), 
        .op(ALUop_2_3), 
        .res(DR_in), 
        .S(S_in), 
        .Zero(Zero_in), 
        .C(C_in), 
        .V(V_in)
        );

    always @(posedge clock or posedge reset_Condition) begin
        if (reset_Condition == 1'b1) begin
            S <= 1'b0;
            Zero <= 1'b0;
            C <= 1'b0;
            V <= 1'b0;
        end else begin
            S <= S_in;
            Zero <= Zero_in;
            C <= C_in;
            V <= V_in;
        end
    end

    /*
     * wiring of p3/p4 pipeline register
     */
    always @(posedge clock or posedge reset_PC_plus_3_4) begin
        if (reset_PC_plus_3_4 == 1'b1) begin
            PC_plus_3_4 <= 16'b0000_0000_0000_0000;
        end else begin
            PC_plus_3_4 <= PC_plus_2_3;
        end
    end

    always @(posedge clock or posedge reset_dest_3_4) begin
        if (reset_dest_3_4 == 1'b1) begin
            dest_3_4 <= 3'b000;
        end else begin
            dest_3_4 <= dest_in;
        end
    end

    always @(posedge clock or posedge reset_AR_3_4) begin
        if (reset_AR_3_4 == 1'b1) begin
            AR_3_4 <= 16'b0000_0000_0000_0000;
        end else begin
            AR_3_4 <= AR_2_3;
        end
    end

    always @(posedge clock or posedge reset_immediate_3_4) begin
        if (reset_immediate_3_4 == 1'b1) begin
            immediate_3_4 <= 16'b0000_0000_0000_0000;
        end else begin
            immediate_3_4 <= immediate_2_3;
        end
    end

    always @(posedge clock or posedge reset_DR_3_4) begin
        if (reset_DR_3_4 == 1'b1) begin
            DR_3_4 <= 16'b0000_0000_0000_0000;
        end else begin
            DR_3_4 <= DR_in;
        end
    end

    always @(posedge clock or posedge reset_mem_write_3_4) begin
        if (reset_mem_write_3_4 == 1'b1) begin
            mem_write_3_4 <= 1'b0;
        end else begin
            mem_write_3_4 <= mem_write_2_3;
        end
    end

    always @(posedge clock or posedge reset_regsrc_3_4) begin
        if (reset_regsrc_3_4 == 1'b1) begin
            regsrc_3_4 <= 2'b00;
        end else begin
            regsrc_3_4 <= regsrc_2_3;
        end
    end

    always @(posedge clock or posedge reset_regWrite_3_4) begin
        if (reset_regWrite_3_4 == 1'b1) begin
            regWrite_3_4 <= 1'b0;
        end else begin
            regWrite_3_4 <= regWrite_2_3;
        end
    end
    
    /*
     * ============================================================
     * p4 stage: memory access
     */

    assign mem_addr = DR_3_4;
    assign mem_write_data = AR_3_4;
    assign mem_write = mem_write_3_4;
    
    /*
     * wiring of p4/p5 pipeline register
     */

    always @(posedge clock or posedge reset_PC_plus_4_5) begin
        if (reset_PC_plus_4_5 == 1'b1) begin
            PC_plus_4_5 <= 16'b0000_0000_0000_0000;
        end else begin
            PC_plus_4_5 <= PC_plus_3_4;
        end
    end

    always @(posedge clock or posedge reset_dest_4_5) begin
        if (reset_dest_4_5 == 1'b1) begin
            dest_4_5 <= 3'b000;
        end else begin
            dest_4_5 <= dest_3_4;
        end
    end

    always @(posedge clock or posedge reset_immediate_4_5) begin
        if (reset_immediate_4_5 == 1'b1) begin
            immediate_4_5 <= 16'b0000_0000_0000_0000;
        end else begin
            immediate_4_5 <= immediate_3_4;
        end
    end

    always @(posedge clock or posedge reset_MDR) begin
        if (reset_MDR == 1'b1) begin
            MDR <= 16'b0000_0000_0000_0000;
        end else begin
            MDR <= mem_read_data;
        end
    end

    always @(posedge clock or posedge reset_DR_4_5) begin
        if (reset_DR_4_5 == 1'b1) begin
            DR_4_5 <= 16'b0000_0000_0000_0000;
        end else begin
            DR_4_5 <= DR_3_4;
        end
    end

    always @(posedge clock or posedge reset_regsrc_4_5) begin
        if (reset_regsrc_4_5 == 1'b1) begin
            regsrc_4_5 <= 2'b00;
        end else begin
            regsrc_4_5 <= regsrc_3_4;
        end
    end

    always @(posedge clock or posedge reset_regWrite_4_5) begin
        if (reset_regWrite_4_5 == 1'b1) begin
            regWrite_4_5 <= 1'b0;
        end else begin
            regWrite_4_5 <= regWrite_3_4;
        end
    end
    
    /*
     * ============================================================
     * p5 stage: write register
     */
    MUX_regsrc regsrc(
        .DR(DR_4_5), 
        .MDR(MDR), 
        .immediate(immediate_4_5),
        .PC_plus(PC_plus_4_5),
        .op(regsrc_4_5), 
        .src(writeData_in)
        );
    write_register WD(
        .address(dest_4_5), 
        .write(regWrite_4_5), 
        .register0(regwrite_r0), 
        .register1(regwrite_r1), 
        .register2(regwrite_r2), 
        .register3(regwrite_r3), 
        .register4(regwrite_r4), 
        .register5(regwrite_r5), 
        .register6(regwrite_r6), 
        .register7(regwrite_r7)
        );    
        
    assign r0 = 16'b0000_0000_0000_0000; // zero register

    always @(posedge clock or posedge reset_r1) begin
        if (reset_r1 == 1'b1) begin
            r1 <= 16'b0000_0000_0000_0000;
        end else begin
            r1 <= (regwrite_r1 ? writeData_in : r1);
        end
    end

    always @(posedge clock or posedge reset_r2) begin
        if (reset_r2 == 1'b1) begin
            r2 <= 16'b0000_0000_0000_0000;
        end else begin
            r2 <= (regwrite_r2 ? writeData_in : r2);
        end
    end

    always @(posedge clock or posedge reset_r3) begin
        if (reset_r3 == 1'b1) begin
            r3 <= 16'b0000_0000_0000_0000;
        end else begin
            r3 <= (regwrite_r3 ? writeData_in : r3);
        end
    end

    always @(posedge clock or posedge reset_r4) begin
        if (reset_r4 == 1'b1) begin
            r4 <= 16'b0000_0000_0000_0000;
        end else begin
            r4 <= (regwrite_r4 ? writeData_in : r4);
        end
    end

    always @(posedge clock or posedge reset_r5) begin
        if (reset_r5 == 1'b1) begin
            r5 <= 16'b0000_0000_0000_0000;
        end else begin
            r5 <= (regwrite_r5 ? writeData_in : r5);
        end
    end

    always @(posedge clock or posedge reset_r6) begin
        if (reset_r6 == 1'b1) begin
            r6 <= 16'b0000_0000_0000_0000;
        end else begin
            r6 <= (regwrite_r6 ? writeData_in : r6);
        end
    end

    always @(posedge clock or posedge reset_r7) begin
        if (reset_r7 == 1'b1) begin
            r7 <= 16'b0000_0000_0000_0000;
        end else begin
            r7 <= (regwrite_r7 ? writeData_in : r7); 
        end
    end


	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 /*
	  * ======================================================================================================
	  * for debug
	  * ======================================================================================================
	  */
	  
	// general registers
    assign r1_out = r1;
	assign r2_out = r2;
	assign r3_out = r3;
	assign r4_out = r4;
	assign r5_out = r5;
	assign r6_out = r6;
	assign r7_out = r7;
	 
	// p1/p2
	assign IR_out = IR;
	 
	// p2/p3
    assign mem_write_2_3_out = mem_write_2_3;
    assign regDst_out = regDst;
    assign regWrite_2_3_out = regWrite_2_3;
	assign regsrc_2_3_out = regsrc_2_3;
	 
	// p3/p4
    assign dest_3_4_out = dest_3_4;
	assign DR_3_4_out = DR_3_4;
    assign mem_write_3_4_out = mem_write_3_4;
	assign regWrite_3_4_out = regWrite_3_4;
    assign regsrc_3_4_out = regsrc_3_4;
	 
	// p4/p5
    assign dest_4_5_out = dest_4_5;
	assign DR_4_5_out = DR_4_5;
    assign MDR_out = MDR;
	assign regWrite_4_5_out = regWrite_4_5;
    assign regsrc_4_5_out = regsrc_4_5;

    // core_controller
    assign op_ALUsrc_out = op_ALUsrc;
    assign op_memWrite_out = op_memWrite;
    assign op_regDst_out = op_regDst;
    assign op_regWrite_out = op_regWrite;
    assign op_regsrc_out = op_regsrc;
    assign ALUop_out = ALUop;

endmodule