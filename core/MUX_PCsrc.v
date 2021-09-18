module MUX_PCsrc (
    input [15:0] PC_plus, branch_addr, regs,
    input [1:0] op,
    output [15:0] src
);

    function [15:0] res_src;
        input [15:0] PC_plus, branch_addr, regs;
        input [1:0] op;
        begin
            case (op)
                2'b00: res_src = PC_plus;
                2'b01: res_src = branch_addr;
                2'b10: res_src = regs; 
                default: res_src = PC_plus;
            endcase
        end
    endfunction
    
    assign src = res_src(PC_plus, branch_addr, regs, op);
endmodule