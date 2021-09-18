module MUX_forward (
    input [15:0] register, data_before1, data_before2,
    input [1:0] op,
    output [15:0] src
);
    function [15:0] res_forwardsrc;
        input [15:0] register, data_before1, data_before2;
        input [1:0] op;
        case (op)
            2'b00: res_forwardsrc = register;
            2'b10: res_forwardsrc = data_before1;
            2'b01: res_forwardsrc = data_before2;
            default: res_forwardsrc = register;
        endcase
    endfunction

    assign src = res_forwardsrc(register, data_before1, data_before2, op);
endmodule