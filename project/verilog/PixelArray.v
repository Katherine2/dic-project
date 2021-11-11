`include ¨pixelSensor.v¨

module PIXEL_ARRAY 
  (
   input logic      VBN1,
   input logic      RAMP,
   input logic      RESET,
   input logic      ERASE,
   input logic      EXPOSE,
   input logic      READ_1,
   input logic      READ_2,
   input logic      READ_3,
   input logic      READ_4,
   inout [7:0] DATA
   );
   
   PIXEL_SENSOR PS1 (VBN1, RAMP, RESET, ERASE, EXPOSE, READ_1, DATA[7:0]);
   PIXEL_SENSOR PS2 (VBN1, RAMP, RESET, ERASE, EXPOSE, READ_2, DATA[7:0]);
   PIXEL_SENSOR PS3 (VBN1, RAMP, RESET, ERASE, EXPOSE, READ_3, DATA[7:0]);
   PIXEL_SENSOR PS4 (VBN1, RAMP, RESET, ERASE, EXPOSE, READ_4, DATA[7:0]);
   
endmodule //PIXEL_ARRAY
    
