module MUX_ALUsrc(
    input [15:0] AR, d,
    input op,
    output [15:0] src
    );

    function [15:0] res_src;
        input [15:0] AR, d;
        input op; 
        begin
            case (op)
                1'b0: res_src = AR;
                1'b1: res_src = d;
                default: res_src = d;
            endcase
        end
    endfunction

    assign src = res_src(AR, d, op);
endmodule 



