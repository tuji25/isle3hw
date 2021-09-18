module chattering (
    input clock, in,
    output reg out 
);
    always @(posedge clock) begin
        out <= in;
    end
endmodule