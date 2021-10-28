module data_io(data, clk, reset, write_enable);

   parameter WIDTH = 8;

   input               clk, reset;
   inout [WIDTH-1 : 0] counter_data;
   
   inout [WIDTH-1 : 0] inv_counter_data;
   
   input 		write_enable;
   output [WIDTH-1 : 0] data;
   
   logic [WIDTH-1 : 0]  counter_data;
   logic [WIDTH-1 : 0]  data;
   wire                 clk, reset;
   
   logic [WIDTH-1 : 0]  q;

   always @(posedge clk or posedge reset) begin
      if (reset)
        q <= 0;
      else begin
         q <= q + 1;
      end
      counter_data <= {q[WIDTH-1], q[WIDTH-1:1] ^ q[WIDTH-2:0]};
   end
   not(inv_counter_data,counter_data);
   notif1 N1(data, inv_counter_data, write_enable);

endmodule //data_io





