module fsm (
  input clock,
  input reset,
  input STB_I,
  input CYC_I,
  input WE_I,
  output [2:0] out
);

  typedef enum logic [2:0] {
    STATE_IDLE = 0,
    STATE_READ = 1,
    STATE_READ_2 = 2,
    STATE_WRITE = 3,
    STATE_WRITE_2 = 4,
    STATE_WRITE_3 = 5,
    STATE_DONE = 6
  } state_t;

  state_t state;

  always_ff @ (posedge clock) begin
    if (reset) begin
      state <= STATE_IDLE;
    end else begin
      case (state)
        STATE_IDLE: begin
          if (STB_I && CYC_I) begin
            if (WE_I) begin
              state <= STATE_WRITE;
            end else begin
              state <= STATE_READ;
            end
          end
        end
        STATE_READ: begin
          state <= STATE_READ_2;
        end
        // ...
      endcase
    end
  end

  assign out = state;

endmodule