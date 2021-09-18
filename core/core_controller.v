module core_controller(
    input [1:0] op1,
    input [2:0] op2,
    input [3:0] op3,

    output halt, ALUsrc, memWrite, regDst, regWrite,
    output [1:0] regsrc,
    output [3:0] ALUop
);

    // HALT
    function res_halt;
        input [1:0] op1;
        input [3:0] op3;
        begin
            if (op1 == 2'b11 && op3 == 4'b1111) begin
                res_halt = 1'b1;
            end else begin
                res_halt = 1'b0;
            end
        end
    endfunction

    // ALUsrc
    function res_ALUsrc;
        input [1:0] op1;
        begin
            case (op1) 
                2'b11: res_ALUsrc = 1'b0; // inst[13:11] rs inst[10:8] rd (AR, BR)
                default: res_ALUsrc = 1'b1; // immediate d, inst[10:8] rb
			endcase
        end
    endfunction

    // ALUop
    function [3:0] res_ALUop;
        input [3:0] op3;
        input [2:0] op2;
        input [1:0] op1;
        begin
            if (op1 == 2'b11) begin
                res_ALUop = op3;
            end else if (op1 == 2'b10 && op2 == 3'b000) begin // LI
                res_ALUop = 4'b0110; // MOV
            end else if (op1 == 2'b10 && op2 == 3'b010) begin // CMPI
                res_ALUop = 4'b0101; // CMP
            end else begin
                res_ALUop = 4'b0000; // default is ADD
            end
        end
    endfunction

    // memWrite
    function res_memWrite;
        input [1:0] op1;
        begin
            case (op1) 
                2'b01: res_memWrite = 1'b1; // write to memory
                default: res_memWrite = 1'b0;
            endcase
        end
    endfunction

    // regsrc
    function [1:0] res_regsrc;
        input [1:0] op1;
        input [2:0] op2;
        begin
            if (op1 == 2'b00) begin
                res_regsrc = 2'b01; // LD
            end else if (op1 == 2'b10 && op2 == 3'b000) begin
                res_regsrc = 2'b10; // LI
            end else if (op1 == 2'b10 && op2 == 3'b100) begin
                res_regsrc = 2'b11; // JAL
            end else begin
                res_regsrc = 2'b00;
            end
        end
    endfunction

    // regDst
    function res_regDst;
        input [1:0] op1;
        begin
            case (op1)
                2'b00: res_regDst = 1'b0; // inst[13:11] rs 
                default: res_regDst = 1'b1; // inst[10:8]
            endcase
        end
    endfunction

    // regWrite
    function res_regWrite;
        input [3:0] op3;
        input [2:0] op2;
        input [1:0] op1;
        begin
            if ((op1 == 2'b11 && (op3 == 4'b0000 || op3 == 4'b0001 || op3 == 4'b0010 || op3 == 4'b0011 || op3 == 4'b0100 || op3 == 4'b0110 || op3 == 4'b1000 || op3 == 4'b1001 || op3 == 4'b1010 || op3 == 4'b1011 || op3 == 4'b1110)) // arithmetic operation(without CMP) and JALR
                || op1 == 2'b00 // LOAD
                || (op1 == 2'b10 && (op2 == 3'b000 || op2 == 3'b001|| op2 == 3'b100)) // immediate operation and JAL
            ) begin
            
                res_regWrite = 1'b1;
            
            end else begin
                res_regWrite = 1'b0;
            end 
        end
    endfunction

    assign halt = res_halt(op1, op3);
    assign ALUsrc = res_ALUsrc(op1);
    assign ALUop = res_ALUop(op3, op2, op1);
    assign memWrite = res_memWrite(op1);
    assign regsrc = res_regsrc(op1, op2);
    assign regDst = res_regDst(op1);
    assign regWrite = res_regWrite(op3, op2, op1);

endmodule