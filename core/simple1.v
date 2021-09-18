module simple1 (
    input clock, reset, exec // reset and exec is negative logic
);

    // wire for input pins
    wire reset_sig, exec_sig, exec_reset, reset_core;

    // wire for instruction memory
    wire [15:0] PC_addr, inst; 

    // wire for data memory
    wire [15:0] mem_addr, mem_write_data, mem_read_data;
    wire mem_write;
	 
	// wire for PLL
	wire pll_clock_80MHz, pll_clock_2kHz;
	 
	// PLL 
	PLL pll(.inclk0(clock), .c0(pll_clock_80MHz), .c1(pll_clock_2kHz));

    // solve chattering problem
    chattering cr(
        .clock(pll_clock_2kHz),
        .in(~ reset),
        .out(reset_sig)
    );

    execution e1(
        .clock(pll_clock_2kHz),
        .exec(~ exec),
        .exec_sig(exec_sig),
        .exec_reset(exec_reset)
    );

    assign reset_core = reset_sig | exec_reset;

    // core
    simple1_core core(
        .clock(pll_clock_80MHz),
        .reset(reset_core),
        .PC_addr(PC_addr),
        .inst(inst),
        .mem_addr(mem_addr),
        .mem_write_data(mem_write_data),
        .mem_write(mem_write),
        .mem_read_data(mem_read_data)
    );

    // instruction memory
    instruction_mem im(
        .address(PC_addr[11:0]),
        .clock(~ pll_clock_80MHz),
        .data(16'b0000_0000_0000_0000),
        .wren(1'b0),
        .q(inst)
    );

    // data memory
    RAM memory(
        .address(mem_addr[11:0]),
        .clock(~ pll_clock_80MHz),
        .data(mem_write_data),
        .wren(mem_write),
        .q(mem_read_data)
    );
endmodule