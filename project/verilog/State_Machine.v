   
module stateMachine(
   input logic clk,
   input logic reset,
   output logic erase,
   output logic expose,
   output logic convert,
   output logic read_1,
   output logic read_2,
   output logic read_3,
   output logic read_4
);
   
   //------------------------------------------------------------
   // Gray Counter
   //------------------------------------------------------------

   output [7 : 0] gray_counter; //8 bit Gray Counter

   logic [7 : 0]  gray_counter;
   logic [7 : 0]  q;
   logic counter_reset =0;
  
   always @(posedge clk or posedge counter_reset) begin
      if (counter_reset)
        q <= 0;
      else begin
        q <= q + 1;
      end
      gray_counter <= {q[7], q[7:1] ^ q[6:0]};
   end
   
   //------------------------------------------------------------
   // State Machine
   //------------------------------------------------------------
   parameter ERASE=0, EXPOSE=1, CONVERT=2, READ_1=3, READ_2=4, READ_3=5, READ_4=6, IDLE=7;

   logic               convert_stop;
   logic [2:0]         state,next_state;   //States
   
   //State duration in clock cycles
   parameter integer c_erase = 5;
   parameter integer c_expose = 255;
   parameter integer c_convert = 255;
   parameter integer c_read = 5;

   //Control the output signals
   always_ff @(negedge clk ) begin
      case(state)
        ERASE: begin
           erase <= 1;
           read_1 <= 0;
           read_2 <= 0;
           read_3 <= 0;
           read_4 <= 0;
           expose <= 0;
           convert <= 0;
        end
        EXPOSE: begin
           erase <= 0;
           read_1 <= 0;
           read_2 <= 0;
           read_3 <= 0;
           read_4 <= 0;
           expose <= 1;
           convert <= 0;
        end
        CONVERT: begin
           erase <= 0;
           read_1 <= 0;
           read_2 <= 0;
           read_3 <= 0;
           read_4 <= 0;
           expose <= 0;
           convert = 1;
        end
        READ_1: begin
           erase <= 0;
           read_1 <= 1;
           read_2 <= 0;
           read_3 <= 0;
           read_4 <= 0;
           expose <= 0;
           convert <= 0;
        end
        READ_2: begin
           erase <= 0;
           read_1 <= 0;
           read_2 <= 1;
           read_3 <= 0;
           read_4 <= 0;
           expose <= 0;
           convert <= 0;
        end
	READ_3: begin
           erase <= 0;
           read_1 <= 0;
           read_2 <= 0;
           read_3 <= 1;
           read_4 <= 0;
           expose <= 0;
           convert <= 0;
        end
	READ_4: begin
           erase <= 0;
           read_1 <= 0;
           read_2 <= 0;
           read_3 <= 0;
           read_4 <= 1;
           expose <= 0;
           convert <= 0;
        end
        IDLE: begin
           erase <= 0;
           read_1 <= 0;
           read_2 <= 0;
           read_3 <= 0;
           read_4 <= 0;
           expose <= 0;
           convert <= 0;
        end
      endcase // case (state)
   end // always @ (state)

   // Control the state transitions
   always_ff @(posedge clk or posedge reset) begin
      if(reset) begin
         state = IDLE;
         next_state = ERASE;
         gray_counter  = 0;
         convert  = 0;
      end
      else begin
         case (state)
           ERASE: begin
              if(gray_counter == c_erase) begin
                 next_state <= EXPOSE;
                 state <= IDLE;
              end
           end
           EXPOSE: begin
              if(gray_counter == c_expose) begin
                 next_state <= CONVERT;
                 state <= IDLE;
              end
           end
           CONVERT: begin
              if(gray_counter == c_convert) begin
                 next_state <= READ_1;
                 state <= IDLE;
              end
           end
           READ_1:
             if(gray_counter == c_read) begin
                state <= IDLE;
                next_state <= READ_2;
             end
           READ_2:
             if(gray_counter == c_read) begin
                state <= IDLE;
                next_state <= READ_3;
             end
           READ_3:
             if(gray_counter == c_read) begin
                state <= IDLE;
                next_state <= READ_4;
             end
           READ_4:
             if(gray_counter == c_read) begin
                state <= IDLE;
                next_state <= ERASE;
             end
           IDLE:
             state <= next_state;
         endcase // case (state)
         
         if(state == IDLE)
           counter_reset=1;
           
         else
           counter_reset=0;
      end
   end // always @ (posedge clk or posedge reset)

endmodule //end module statemachine 
