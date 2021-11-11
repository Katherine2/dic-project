 //------------------------------------------------------------
   // Readout from databus
   //------------------------------------------------------------
   logic [7:0] pixelDataOut;
   always_ff @(posedge clk or posedge reset) begin
      if(reset) begin
         pixelDataOut = 0;
      end
      else begin
         if(read_1)
           pixelDataOut <= pixData;
      end
   end

   //------------------------------------------------------------
   // Testbench stuff
   //------------------------------------------------------------
   initial
     begin
        reset = 1;

        #clk_period  reset=0;

        $dumpfile("pixelSensor_tb.vcd");
        $dumpvars(0,pixelSensor_tb);

        #sim_end
          $stop;


     end
