module MUX_regsrc (
    input [15:0] DR, MDR, immediate, PC_plus,
    input [1:0] op,
    output [15:0] src
);

    function [15:0] res_src;
        input [15:0] DR, MDR, immediate, PC_plus;
        input [1:0] op;
        begin
            case (op)
                2'b00: res_src = DR;
                2'b01: res_src = MDR;
                2'b10: res_src = immediate;
                2'b11: res_src = PC_plus; 
                default: res_src = DR;
            endcase
        end
    endfunction

    assign src = res_src(DR, MDR, immediate, PC_plus, op);
    
endmodule