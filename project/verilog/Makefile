
ps:
	iverilog -g2012 -o pixelSensor -c pixelSensor.fl
	vvp -n pixelSensor
	
rungray:
	iverilog  -g2012 -o my_gray_design -c graycounter.fl
	vvp -n my_gray_design

synth:
	yosys counter.ys
	
	
pa:
	iverilog -g2012 -o pixelArray -c pixelArray.fl
	vvp -n pixelArray
