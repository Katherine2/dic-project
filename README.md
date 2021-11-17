# dic_project

This repository contains all of the code used for our final project in the Design of Integrated Circuits (TFE-4152)class at NTNU.

The repo is seperated in two parts:

1. The spice folder contains all the SPICE circuits and test benches that simulate the analog parts of the design
2. The verilog folder contains all the SystemVerilog files and test benches that simulate the digital parts of the design 

In the Verilog section, there are a few important files: 
1. pixelSensor.v which depicts the digital functionality of a single pixel sensor
2. PixelArray.v which creates a 2x2 array of pixel sensors 
3. State_Machine.v which describes the finite state machine that dictates how the pixel array works
4. stateMachine_tb.v which is the test bench that tests runs the simulation for the entire pixel array controlled by the state machine
5. StateMachine.txt and stateMachine_tb.vcd which are the outputs of the simulation run in the test bench. The text file has the output values of the pixels and the vcd file can be used to visualize the behaviour of each signal in GTKwave
The other files were used as intermediate testing and are not necessary for the functionning of the project
