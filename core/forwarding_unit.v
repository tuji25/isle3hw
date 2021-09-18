module forwarding_unit (
    input regWrite_3_4, regWrite_4_5,
    input [2:0] reg1, reg2, dest_3_4, dest_4_5, 
    output [1:0] forwardA, forwardB
);
    function [1:0] forward;
        input regWrite_3_4, regWrite_4_5;
        input [2:0] register, dest_3_4, dest_4_5;
        if (regWrite_3_4 == 1'b1 && dest_3_4 != 3'b000 && dest_3_4 == register) begin
            forward = 2'b10;
        end else if (regWrite_4_5 == 1'b1 && dest_4_5 != 3'b000 && dest_4_5 == register) begin
            forward = 2'b01;
        end else begin
            forward = 2'b00;
        end
    endfunction

    assign forwardA = forward(regWrite_3_4, regWrite_4_5, reg1, dest_3_4, dest_4_5);
    assign forwardB = forward(regWrite_3_4, regWrite_4_5, reg2, dest_3_4, dest_4_5);
endmodule