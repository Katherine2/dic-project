
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
    
   parameter real    dv_pixel_1 = 0.5;  //Set the expected photodiode current
   parameter real    dv_pixel_2 = 0.6;  
   parameter real    dv_pixel_3 = 0.7;
   parameter real    dv_pixel_4 = 0.8;
   
   PIXEL_SENSOR #(.dv_pixel(dv_pixel_1)) PS1 (VBN1, RAMP, RESET, ERASE, EXPOSE, READ_1, DATA[7:0]);
   PIXEL_SENSOR #(.dv_pixel(dv_pixel_2)) PS2 (VBN1, RAMP, RESET, ERASE, EXPOSE, READ_2, DATA[7:0]);
   PIXEL_SENSOR #(.dv_pixel(dv_pixel_3)) PS3 (VBN1, RAMP, RESET, ERASE, EXPOSE, READ_3, DATA[7:0]);
   PIXEL_SENSOR #(.dv_pixel(dv_pixel_4)) PS4 (VBN1, RAMP, RESET, ERASE, EXPOSE, READ_4, DATA[7:0]);
   
endmodule //PIXEL_ARRAY
    
