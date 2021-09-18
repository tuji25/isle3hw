module load_hazard (
    input [1:0] op1,
    input [2:0] op2,
    input [3:0] op3,
    input [1:0] regsrc_2_3,
    input [2:0] reg1, reg2, dest,
    output hazard
);

    // LOAD or not
    wire mem_read;

    function res_mem_read;
        input [1:0] regsrc_2_3;
        begin
            case (regsrc_2_3)
                2'b01: res_mem_read = 1'b1; 
                default: res_mem_read = 1'b0;
            endcase
        end
    endfunction

    assign mem_read = res_mem_read(regsrc_2_3);

    function reg1_hazard;
        input mem_read;
        input [2:0] reg1, dest;
        input [1:0] op1;
        input [3:0] op3;
        begin
            if (mem_read == 1'b1
                && dest != 3'b000
                && dest == reg1
                && ((op1 == 2'b11 && (op3 == 4'b0000 || op3 == 4'b0001 || op3 == 4'b0010 || op3 == 4'b0011 || op3 == 4'b0100 || op3 == 4'b0101 || op3 == 4'b0110 || op3 == 4'b1110))
                    || op1 == 2'b01) // ADD, SUB, AND, OR, XOR, CMP, MOV, JAL, ST
            ) begin
                reg1_hazard = 1'b1;
            end else begin
                reg1_hazard = 1'b0;
            end
        end
    endfunction

    function reg2_hazard;
        input mem_read;
        input [2:0] reg2, dest;
        input [1:0] op1;
        input [2:0] op2;
        input [3:0] op3;
        begin
            if (mem_read == 1'b1
                && dest != 3'b000
                && dest == reg2
                && ((op1 == 2'b11 && (op3 == 4'b0000 || op3 == 4'b0001 || op3 == 4'b0010 || op3 == 4'b0011 || op3 == 4'b0100 || op3 == 4'b0101 || op3 == 4'b1000 || op3 == 4'b1001 || op3 == 4'b1010 || op3 == 4'b1011)) // ADD, SUB, AND, OR , XOR, CMP, SLL, SLR, SRL, SRA
                    || op1 == 2'b00 // LD
                    || op1 == 2'b01 // ST
                    || (op1 == 2'b10 && (op2 == 3'b001 || op2 == 3'b010)) // ADDI, COMPI
                    )
            ) begin
                reg2_hazard = 1'b1;
            end else begin
                reg2_hazard = 1'b0;
            end
        end
    endfunction

    assign hazard = reg1_hazard(mem_read, reg1, dest, op1, op3) || reg2_hazard(mem_read, reg2, dest, op1, op2, op3);
endmodule