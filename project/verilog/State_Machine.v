
   parameter real    dv_pixel = 0.5;  //Set the expected photodiode current (0-1)
     
     //Analog signals
   logic              anaBias1;
   logic              anaRamp;
   logic              anaReset;

   //Tie off the unused lines
   assign anaReset = 1;

   //Digital
   logic              erase;
   logic              expose;
   logic              read_1;
   logic              read_2;
   logic              read_3;
   logic              read_4;
   tri[7:0]          pixData; //  We need this to be a wire, because we're tristating it
   
   
   PIXEL_ARRAY  #(.dv_pixel(dv_pixel))  PA (anaBias1, anaRamp, anaReset, erase,expose, read_1, read_2, read_3, read_4, pixData);
 
   
   //------------------------------------------------------------
   // State Machine
   //------------------------------------------------------------
   parameter ERASE=0, EXPOSE=1, CONVERT=2, READ=3, IDLE=4;

   logic               convert;
   logic               convert_stop;
   logic [2:0]         state,next_state;   //States
   integer           counter;            //Delay counter in state machine

   integer check; //to check which pixel is read
   
   //State duration in clock cycles
   parameter integer c_erase = 5;
   parameter integer c_expose = 255;
   parameter integer c_convert = 255;
   parameter integer c_read = 5;

assign check=1;

   // Control the output signals
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
        READ: begin
           case(check)
           	1: begin
           	    erase <= 0;
           	    read_1 <= 1;
           	    expose <= 0;
           	    convert <= 0;
           	2: begin
           	    erase <= 0;
           	    read_2 <= 1;
           	    expose <= 0;
           	    convert <= 0;
           	3: begin
           	    erase <= 0;
           	    read_3 <= 1;
           	    expose <= 0;
           	    convert <= 0;
           	4: begin
           	    erase <= 0;
           	    read_4 <= 1;
           	    expose <= 0;
           	    convert <= 0;
           end
         /*
         	if(check == 1){
           	    erase <= 0;
           	    read_1 <= 1;
           	    expose <= 0;
           	    convert <= 0;
           	}
         	else if(check == 2){
           	    erase <= 0;
           	    read_2 <= 1;
           	    expose <= 0;
           	    convert <= 0;
           	}
         	else if(check == 3){
           	    erase <= 0;
           	    read_3 <= 1;
           	    expose <= 0;
           	    convert <= 0;
           	}
         	else if(check == 4){
           	    erase <= 0;
           	    read_4 <= 1;
           	    expose <= 0;
           	    convert <= 0;
           	}
           	*/
         		
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
         counter  = 0;
         convert  = 0;
      end
      else begin
         case (state)
           ERASE: begin
              if(counter == c_erase) begin
                 next_state <= EXPOSE;
                 state <= IDLE;
              end
           end
           EXPOSE: begin
              if(counter == c_expose) begin
                 next_state <= CONVERT;
                 state <= IDLE;
              end
           end
           CONVERT: begin
              if(counter == c_convert) begin
                 next_state <= READ;
                 state <= IDLE;
              end
           end
           READ:
             if(counter == c_read) begin
                state <= IDLE;
                if(check==5)
                   next_state <= ERASE;
                   check=1;
                else 
                   next_state <= READ;
                   check=check+1;
             end
           IDLE:
             state <= next_state;
         endcase // case (state)
         if(state == IDLE)
           counter = 0;
         else
           counter = counter + 1;
      end
   end // always @ (posedge clk or posedge reset)
