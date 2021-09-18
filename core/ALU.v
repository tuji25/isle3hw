module ALU (
    input [15:0] data1, data2,
    input [3:0] shamt, op,
    output [15:0] res,
    output S, Zero, C, V
    );

    wire [16:0] bus_from_result_with_carry;

    function [16:0] result_with_carry;
    input [3:0] shamt, op;
    input [15:0] data1, data2;
    begin 
        case (op)
            0: result_with_carry = data2 + data1; // ADD
            1: result_with_carry = data2 - data1; // SUB
            2: result_with_carry = data2 & data1; // AND
            3: result_with_carry = data2 | data1; // OR
            4: result_with_carry = data2 ^ data1; // XOR
            5: result_with_carry = data2 - data1; // CMP
            6: result_with_carry = data1; // MOV
            8: result_with_carry = {1'b0, data2}<<shamt; // SLL
            9: // SLR
                if (shamt == 0) begin
                    result_with_carry = data2;
                end else begin
                    result_with_carry = {1'b0, (data2<<shamt) | (data2>>(16-shamt))};
                end
            10: // SRL
                if (shamt == 0) begin
                    result_with_carry = data2;
                end else begin
                    result_with_carry = {data2[shamt-1], data2>>shamt};
                end
            11: // SRA
                if (shamt == 0) begin
                    result_with_carry = data2;
                end else begin	
                    result_with_carry = {data2[shamt-1], $signed(data2)>>>shamt};
                end
            default: result_with_carry = 17'b0_0000_0000_0000_0000; // 7(reserved), 12(IN), 13(OUT), 14(reserved), 15(HLT)
        endcase
    end
	 endfunction

    function carry;
    input [3:0] shamt, op;
    input result_with_carry_16;
    begin 
        case (op)
            0: carry = result_with_carry_16; // ADD
            1: carry = result_with_carry_16; // SUB
            2: carry = 0; // AND
            3: carry = 0; // OR
            4: carry = 0; // XOR
            5: carry = result_with_carry_16; // CMP
            6: carry = 0; // MOV
            8: // SLL
                if (shamt == 0) begin
                    carry = 0;
                end else begin
                    carry = result_with_carry_16;
                end
            9: carry = 0; // SLR
            10: // SRL
                if (shamt == 0) begin
                    carry = 0;
                end else begin
                    carry = result_with_carry_16;
                end
            11: // SRA
                if (shamt == 0) begin
                    carry = 0;
                end else begin
                    carry = result_with_carry_16;
                end
            12: carry = 0; // IN
            13: carry = 0; // OUT
            default: carry = 0; // 7(reserved), 14(reserved), 15(HLT)
        endcase
    end
	 endfunction

    function overflow;
    input [3:0] op;
    input data1_15, data2_15, result_with_carry_15;
    begin 
        case (op)
            0: //ADD
                if ((data2_15 == 0 && data1_15 == 0 && result_with_carry_15 == 1) || (data2_15 == 1 && data1_15 == 1 && result_with_carry_15 == 0)) begin
                    overflow = 1; 
                end else begin
                    overflow = 0;
                end 
            1: //SUB
                if ((data2_15 == 0 && data1_15 == 1 && result_with_carry_15 == 1) || (data2_15 == 1 && data1_15 == 0 && result_with_carry_15 == 0)) begin
                    overflow = 1; 
                end else begin
                    overflow = 0;
                end 
            2: //AND
                overflow = 0;
            3: //OR
                overflow = 0;
            4: // XOR
                overflow = 0;
            5:  //CMP
                if ((data2_15 == 0 && data1_15 == 1 && result_with_carry_15 == 1) || (data2_15 == 1 && data1_15 == 0 && result_with_carry_15== 0)) begin
                    overflow = 1; 
                end else begin
                    overflow = 0;
                end 
            6: // MOV
                overflow = 0;
            8: // SLL
                overflow = 0;
            9: // SLR
                overflow = 0;
            10: // SRL
                overflow = 0;
            11: // SRA
                overflow = 0;
            12: // IN
                overflow = 0;
            13: // OUT
                overflow = 0;
            default: // 7(reserved), 14(reserved), 15(HLT)
                overflow = 0;
        endcase
    end
	 endfunction
	 
	 function zero;
	 input [15:0] bus_from_result_with_carry_15_0;
	 begin
		if (bus_from_result_with_carry_15_0 == 0) begin
			zero = 1;
		end else begin 
			zero = 0;
		end
	 end
	 endfunction 

    assign bus_from_result_with_carry = result_with_carry(shamt, op, data1, data2);

    assign res = bus_from_result_with_carry[15:0];
    assign S = bus_from_result_with_carry[15];
    assign Zero = zero(bus_from_result_with_carry[15:0]);
    assign C = carry(shamt, op, bus_from_result_with_carry[16]);
    assign V = overflow(op, data1[15], data2[15], bus_from_result_with_carry[15]);

endmodule