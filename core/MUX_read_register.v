module MUX_read_register ( // read and write register simultaneously
    input [15:0] r1, r2, r3, r4, r5, r6, r7, writeData,
    input regwrite_r1, regwrite_r2, regwrite_r3, regwrite_r4, regwrite_r5, regwrite_r6, regwrite_r7,
    output [15:0] r1_src, r2_src, r3_src, r4_src, r5_src, r6_src, r7_src
);
    
    function [15:0] res_r_src;
        input [15:0] r, writeData;
        input regwrite;
        begin
            case (regwrite)
                1'b0: res_r_src = r;
                1'b1: res_r_src = writeData; 
                default: res_r_src = r;
            endcase
        end
    endfunction

    assign r1_src = res_r_src(r1, writeData, regwrite_r1);
    assign r2_src = res_r_src(r2, writeData, regwrite_r2);
    assign r3_src = res_r_src(r3, writeData, regwrite_r3);
    assign r4_src = res_r_src(r4, writeData, regwrite_r4);
    assign r5_src = res_r_src(r5, writeData, regwrite_r5);
    assign r6_src = res_r_src(r6, writeData, regwrite_r6);
    assign r7_src = res_r_src(r7, writeData, regwrite_r7);
endmodule