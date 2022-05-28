module mux2_1(
    input wire d0,
    input wire d1,
    input wire sel,
    output wire q
);

    wire tmp1, tmp2, tmp3;

    always @ (*) begin
        tmp1 = d0 & sel;
        tmp2 = d1 & (~sel);
    end

    always @ (*) begin
        tmp3 = tmp1 | tmp2;
        q = tmp3;
    end

endmodule