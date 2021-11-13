//====================================================================
//        Copyright (c) 2021 Carsten Wulff Software, Norway
// ===================================================================
// Created       : wulff at 2021-7-21
// ===================================================================
//  The MIT License (MIT)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//
//====================================================================

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

module pixelArray_tb;

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

   //Digital signals
   logic              erase;
   logic              expose;
   logic              read_1;
   logic              read_2;
   logic              read_3;
   logic              read_4;
   tri[7:0]           pixData; 

   //Instanstiate the pixel array
   PIXEL_ARRAY PA(anaBias1, anaRamp, anaReset, erase,expose, read_1, read_2, read_3, read_4, pixData);
 
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

   logic               convert;
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

        $dumpfile("pixelArray_tb.vcd");
        $dumpvars(0,pixelArray_tb);
        
        fo = $fopen("PixelArray.txt","w");
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
