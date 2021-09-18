module execution (
    input clock, exec,
    output exec_sig,
    output reg exec_reset
);
    
    reg exec_sig0, exec_sig1, exec_sig2, exec_sig3, exec_sig4;

    always @(posedge clock) begin
        exec_sig0 <= exec;
    end

    always @(posedge clock) begin
        exec_sig1 <= exec_sig0;
    end

    always @(posedge clock) begin
        exec_sig2 <= exec_sig1;
    end

    always @(posedge clock) begin
        exec_sig3 <= exec_sig2;
    end

    always @(posedge clock) begin
        exec_sig4 <= exec_sig3;
    end

    assign exec_sig = exec_sig0;

    always @(posedge clock) begin
        if (exec_sig0 == 1'b1 && exec_sig1 == 1'b0) begin
            exec_reset <= 1'b1;
        end else if ((exec_sig0 & exec_sig1 & exec_sig2 & exec_sig3 & exec_sig4) == 1'b1) begin
            exec_reset <= 1'b0;
        end else begin
            exec_reset <= exec_reset;
        end
    end
endmodule