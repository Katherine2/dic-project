
`timescale 1 ns / 1 ps

//====================================================================
// Testbench for pixelArray
// - clock
// - instanstiate 2x2 pixel array 
// - State machine for controlling 2x2 pixel array
// - Model the ADC
// - Readout of the databus
// - Store the output file 
//====================================================================

module stateMachine_tb;

   //------------------------------------------------------------
   // Testbench clock
   //------------------------------------------------------------
   logic clk =0;
   logic reset =0;
   parameter integer clk_period = 500;
   parameter integer sim_end = clk_period*2400;
   always #clk_period clk=~clk;

   //------------------------------------------------------------
   // Pixel
   //------------------------------------------------------------ 
   //Analog signals
   logic              anaBias1;
   logic              anaRamp;
   logic              anaReset;

   //Tie off the unused lines
   assign anaReset = 1;

   wire erase;
   wire expose;
   wire convert;
   wire read_1;
   wire read_2;
   wire read_3;
   wire read_4;
   
   tri[7:0] pixData;
   
    //Instanstiate the pixel array
   PIXEL_ARRAY PA(anaBias1, anaRamp, anaReset, erase,expose, read_1, read_2, read_3, read_4, pixData);
   
   //Instantiate the state machine
   stateMachine #(.c_erase(5),.c_expose(255),.c_convert(255), .c_read(5)) SM(.clk(clk),.reset(reset),.erase(erase),.expose(expose),.convert(convert), 
   .read_1(read_1),.read_2(read_2),.read_3(read_3),.read_4(read_4));
   
//------------------------------------------------------------
   // DAC and ADC model
   //------------------------------------------------------------
   logic[7:0] data;


   // To replicate the behaviour in analog part
   assign anaRamp = convert ? clk : 0;
   assign anaBias1 = expose ? clk : 0;

   // The bus is read depending on which pixel is to be read
   assign pixData = read_1 | read_2 | read_3 | read_4 ? 8'bZ: data;
   
   always_ff @(posedge clk or posedge reset) begin
      if(reset) begin
         data =0;
      end
      if(convert) begin
         data +=  1;
      end
      else begin
         data = 0;
      end
   end // always @ (posedge clk or reset)

   //------------------------------------------------------------
   // Readout from databus
   //------------------------------------------------------------
   
   logic [31:0] pixelDataOut;
   always_ff @(posedge clk or posedge reset) begin
      if(reset) begin
         pixelDataOut = 0;
      end
      else begin
         if(read_1)
           pixelDataOut[7:0] <= pixData;
         if(read_2)
           pixelDataOut[15:8] <= pixData;
         if(read_3)
           pixelDataOut[23:16] <= pixData;
         if(read_4)
           pixelDataOut[31:24] <= pixData;
      end
   end

   //------------------------------------------------------------
   // Writing to external files
   //------------------------------------------------------------
   int fo,y;
        
   initial
     begin
        reset = 1;

        #clk_period  reset=0;

        $dumpfile("stateMachine_tb.vcd");
        $dumpvars(0,stateMachine_tb);
        
        fo = $fopen("StateMachine.txt","w");
        #sim_end
          for (y = 0; y<8; y=y+1) begin
               $fwrite(fo,"%b",pixelDataOut[y]);
          end
          $fwrite(fo,"\n");
          for (y = 8; y<16; y=y+1) begin
               $fwrite(fo,"%b",pixelDataOut[y]);
          end
          $fwrite(fo,"\n");
          for (y = 16; y<24; y=y+1) begin
               $fwrite(fo,"%b",pixelDataOut[y]);
          end
          $fwrite(fo,"\n");
          for (y = 24; y<32; y=y+1) begin
               $fwrite(fo,"%b",pixelDataOut[y]);
          end

        #sim_end $fclose(fo);
        #sim_end
          $stop;          
     end
     
endmodule // test_bench
