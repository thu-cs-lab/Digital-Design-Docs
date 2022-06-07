module rr_priority_encoder (
  input [3:0] request,
  input [1:0] last_user,
  output valid,
  output [1:0] user
);
  reg valid_comb;
  reg [1:0] user_comb;

  always @ (*) begin
    // default
    valid_comb = 1'b0;
    user_comb = 2'd0;

    // naive way
    if (last_user == 2'd3) begin
      case (request)
        4'bxxx1: begin
          valid_comb = 1'b1;
          user_comb = 2'd0;
        end
        4'bxx10: begin
          valid_comb = 1'b1;
          user_comb = 2'd1;
        end
        4'bx100: begin
          valid_comb = 1'b1;
          user_comb = 2'd2;
        end
        4'b1000: begin
          valid_comb = 1'b1;
          user_comb = 2'd3;
        end
      endcase
    end else if (last_user == 2'd0) begin
      case (request)
        4'bxx1x: begin
          valid_comb = 1'b1;
          user_comb = 2'd1;
        end
        4'bx10x: begin
          valid_comb = 1'b1;
          user_comb = 2'd2;
        end
        4'b100x: begin
          valid_comb = 1'b1;
          user_comb = 2'd3;
        end
        4'b0001: begin
          valid_comb = 1'b1;
          user_comb = 2'd0;
        end
      endcase
    end else if (last_user == 2'd1) begin
      case (request)
        4'bx1xx: begin
          valid_comb = 1'b1;
          user_comb = 2'd2;
        end
        4'b10xx: begin
          valid_comb = 1'b1;
          user_comb = 2'd3;
        end
        4'b00x1: begin
          valid_comb = 1'b1;
          user_comb = 2'd0;
        end
        4'b0010: begin
          valid_comb = 1'b1;
          user_comb = 2'd1;
        end
      endcase
    end else if (last_user == 2'd2) begin
      case (request)
        4'b1xxx: begin
          valid_comb = 1'b1;
          user_comb = 2'd3;
        end
        4'b0xx1: begin
          valid_comb = 1'b1;
          user_comb = 2'd0;
        end
        4'b0x10: begin
          valid_comb = 1'b1;
          user_comb = 2'd1;
        end
        4'b0100: begin
          valid_comb = 1'b1;
          user_comb = 2'd2;
        end
      endcase
    end

  end

  assign valid = valid_comb;
  assign user = user_comb;

endmodule

module rr_arbiter (
  input clock,
  input reset,

  input [3:0] request,
  output valid,
  output [1:0] user
);
  reg [1:0] user_reg;
  reg valid_reg;

  reg [1:0] user_comb;
  reg [1:0] priority_encoder_user_comb;
  
  rr_priority_encoder rr_priority_encoder_inst (
    .request(request),
    .last_user(user_reg),
    .valid(valid),
    .user(priority_encoder_user_comb)
  );

  // sequential
  always @ (posedge clock) begin
    if (reset) begin
      user_reg <= 2'd0;
      valid_reg <= 1'b0;
    end else begin
      valid_reg <= valid;
      if (!valid_reg && valid) begin
        // case 1: non valid -> valid
        user_reg <= priority_encoder_user_comb;
      end else if (valid_reg && valid && request[user_reg]) begin
        // case 2: persist
      end else if (valid_reg && valid && !request[user_reg]) begin
        // case 3: next user
        user_reg <= priority_encoder_user_comb;
      end
    end
  end

  // combinatorial
  always @ (*) begin
    // default
    user_comb = 2'b0;
    if (!valid_reg && valid) begin
      // case 1: non valid -> valid
      user_comb = priority_encoder_user_comb;
    end else if (valid_reg && valid && request[user_reg]) begin
      // case 2: persist
      user_comb = user_reg;
    end else if (valid_reg && valid && !request[user_reg]) begin
      // case 3: next user
      user_comb = priority_encoder_user_comb;
    end
  end

  assign user = user_comb;

endmodule