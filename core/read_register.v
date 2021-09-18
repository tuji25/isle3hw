module read_register (
    input [2:0] address1, address2,
    input [15:0] register0, register1, register2, register3, register4, register5, register6, register7,
    output [15:0] res1, res2
);

    function [15:0] mux (
        input [2:0] address,
        input [15:0] data0, data1, data2, data3, data4, data5, data6, data7
    );

        case (address)
            3'd0: mux = data0;
            3'd1: mux = data1;
            3'd2: mux = data2;
            3'd3: mux = data3;
            3'd4: mux = data4;
            3'd5: mux = data5;
            3'd6: mux = data6;
            3'd7: mux = data7;
        endcase
    endfunction 

    assign res1 = mux(address1, register0, register1, register2, register3, register4, register5, register6, register7);
    assign res2 = mux(address2, register0, register1, register2, register3, register4, register5, register6, register7);
endmodule