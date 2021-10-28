module test;

  /* Make a reset that pulses once. */
  reg reset = 0;
  initial begin
     # 17 reset = 1;
     # 11 reset = 0;
     # 29 reset = 1;
     # 11 reset = 0;
     # 1 start = 1;
     # 20000 $stop;
  end

  /* Make a regular pulsing clock. */
  reg clk = 0;
  always #5 clk = !clk;

  wire [7:0] valuegray;
  reg enable=1;
  data_io c1 (valuegray, clk, reset, enable);
  
  logic     start = 0;

  int       fg;
  int       i;

  always @(valuegray) begin
     if(start)
        if(enable)
	   for (i=0;i<8;i=i+1) begin
	      $fwrite(fg,"%b\n",valuegray);
	   end
  end
 
  initial
    begin
       fg = $fopen("graycounter.csv","w");    
       $dumpfile("test.vcd");
       $dumpvars(0,test);
       #20100 $fclose(fg);       
    end
endmodule // test
