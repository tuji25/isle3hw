module MUX_preserve (
    input [15:0] now, next,
    input op,
    output [15:0] src
);

    function [15:0] res_preserve;
        input [15:0] now, next;
        input op;
        begin
            case (op)
                1'b0: res_preserve = next;
                1'b1: res_preserve = now;
                default: res_preserve = next;
            endcase
		  end
    endfunction
	 
    assign src = res_preserve(now, next, op);
endmodule