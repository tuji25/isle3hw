module write_register (
    input [2:0] address,
    input write,
    output register0, register1, register2, register3, register4, register5, register6, register7
);

    wire decout0, decout1, decout2, decout3, decout4, decout5, decout6, decout7;

    function [7:0] dec (
        input [2:0] decin
    );
        begin
            case (decin)
                3'd0: dec = 8'b0000_0001;
                3'd1: dec = 8'b0000_0010;
                3'd2: dec = 8'b0000_0100;
                3'd3: dec = 8'b0000_1000;
                3'd4: dec = 8'b0001_0000;
                3'd5: dec = 8'b0010_0000;
                3'd6: dec = 8'b0100_0000;
                3'd7: dec = 8'b1000_0000;
            endcase
        end
    endfunction

    assign {decout7, decout6, decout5, decout4, decout3, decout2, decout1, decout0} = dec(address);

    assign register0 = decout0 & write;
    assign register1 = decout1 & write;
    assign register2 = decout2 & write;
    assign register3 = decout3 & write;
    assign register4 = decout4 & write;
    assign register5 = decout5 & write;
    assign register6 = decout6 & write;
    assign register7 = decout7 & write;
    
endmodule