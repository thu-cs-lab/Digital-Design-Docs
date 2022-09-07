module priority_encoder (
  input [3:0] request,
  output valid,
  output [1:0] user
);
  reg valid_comb;
  reg [1:0] user_comb;

  always @ (*) begin
    // default
    valid_comb = 1'b0;
    user_comb = 2'd0;

    // cases
    casez (request)
      4'b???1: begin
        valid_comb = 1'b1;
        user_comb = 2'd0;
      end
      4'b??10: begin
        valid_comb = 1'b1;
        user_comb = 2'd1;
      end
      4'b?100: begin
        valid_comb = 1'b1;
        user_comb = 2'd2;
      end
      4'b1000: begin
        valid_comb = 1'b1;
        user_comb = 2'd3;
      end
    endcase

  end

  assign valid = valid_comb;
  assign user = user_comb;
endmodule