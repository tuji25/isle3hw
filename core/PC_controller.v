module PC_controller (
    input [1:0] op1,
    input [2:0] op2,
    input [3:0] op3,
    input [2:0] cond,
    input S, Zero, C, V,
    output [1:0] PCsrc,
    output stall
);
    wire condition;

    // condition check
    function res_condition;
        input [2:0] cond;
        input S, Zero, C, V;
        begin
            if ((cond == 3'b000 && Zero == 1'b1)
                || (cond == 3'b001 && (S ^ V) == 1'b1)
                || (cond == 3'b010 && (Zero | (S ^ V)) ==  1'b1)
                || (cond == 3'b011 && (~ Zero) == 1'b1)) begin

                res_condition = 1'b1;

            end else begin
                res_condition = 1'b0;    
            end
        end
    endfunction

    // PCsrc
    function [1:0] res_PCsrc;
        input [1:0] op1;
        input [2:0] op2;
        input [3:0] op3;
        input condition;
        begin
            if ((op1 == 2'b10 && op2 == 3'b100)
                || (op1 == 2'b10 && op2 == 3'b111 && condition == 1'b1)) begin // JAL and branch
                res_PCsrc = 2'b01;
            end else if (op1 == 2'b11 && op3 == 4'b1110) begin // JALR
                res_PCsrc = 2'b10; 
            end else begin
                res_PCsrc = 2'b00;
            end
        end
    endfunction

    function res_stall;
        input [1:0] PCsrc;
        begin
            case (PCsrc)
                2'b01: res_stall = 1'b1;
                2'b10: res_stall = 1'b1; 
                default: res_stall = 1'b0;
            endcase
        end
    endfunction

    assign condition = res_condition(cond, S, Zero, C, V);
    assign PCsrc = res_PCsrc(op1, op2, op3, condition);
    assign stall = res_stall(PCsrc);

endmodule