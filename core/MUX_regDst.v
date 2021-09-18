module MUX_regDst(
    input [2:0] rs, rd,
    input op,
    output [2:0] dst
    );

    function [2:0] res_dst;
        input [2:0] rs, rd;
        input op;
        begin
            case (op) 
                1'b0: res_dst = rs;
                1'b1: res_dst = rd;
                default: res_dst = 3'b000;
            endcase
        end
    endfunction

    assign dst = res_dst(rs, rd, op);
endmodule