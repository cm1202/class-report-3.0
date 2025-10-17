module chu_gpo
    #(parameter W = 8)
   (
    input  logic clk,
    input  logic reset,
    input  logic cs,
    input  logic read,
    input  logic write,
    input  logic [4:0] addr,
    input  logic [31:0] wr_data,
    output logic [31:0] rd_data,
    output logic [W-1:0] dout
   );

   localparam int ADDR_DATA  = 5'h00;
   localparam int ADDR_SPEED = 5'h01;

   logic [W-1:0] buf_reg;      // LED pattern
   logic [31:0] speed_reg;     // clock cycles
   logic [31:0] blink_counter; // cycle counter
   logic blink_state;          
   logic wr_en_data;
   logic wr_en_speed;

   assign wr_en_data  = cs && write && (addr == ADDR_DATA);
   assign wr_en_speed = cs && write && (addr == ADDR_SPEED);

   always_ff @(posedge clk, posedge reset) begin
      if (reset)
         buf_reg <= '0;
      else if (wr_en_data)
         buf_reg <= wr_data[W-1:0];
   end

   // speed 
   always_ff @(posedge clk, posedge reset) begin
      if (reset)
         speed_reg <= 0;
      else if (wr_en_speed)
         speed_reg <= wr_data;
   end

   // blink state machine
   always_ff @(posedge clk, posedge reset) begin
      if (reset) begin
         blink_counter <= 0;
         blink_state <= 1'b1;
      end 
      else if (wr_en_speed) begin
         blink_counter <= 0;
         blink_state <= 1'b1;
      end 
      else if (speed_reg == 0) begin
         blink_counter <= 0;
         blink_state <= 1'b1;
      end 
      else if (blink_counter >= speed_reg) begin
         blink_counter <= 0;
         blink_state <= ~blink_state;  
      end 
      else begin
         blink_counter <= blink_counter + 1;
      end
   end


   always_comb begin
      if (cs && read) begin
         case (addr)
            ADDR_DATA:  rd_data = {{(32-W){1'b0}}, buf_reg};
            ADDR_SPEED: rd_data = speed_reg;
            default:    rd_data = 0;
         endcase
      end 
      else begin
         rd_data = 0;
      end
   end

   
   //blink behavior, off (all zero) if no behavior
   assign dout = blink_state ? buf_reg : {W{1'b0}};
endmodule
       



