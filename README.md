# Circuit_Solver
This is an implementation of a circuit solver using node method. As input you should fill a .txt file. The function will get the address of input and output files (.txt).
Each line in the input file should specify properties of onlu one element. Acceptable elements are resistors, capacitors, inductors, coupled Inductor, dependent sources, and independent sources, and the symbols are R, C, L, ML, V or I (voltage or current), and CSVC/VSVC or CSCC/VSCC (voltage/current source voltage/current controlled) respectively.<br />
For most elements you should use the <Name><Element><node1><node2><dependence><value> format (with spaces in between). Name of the element can be anything. the elemets symbols explaind in above. Node1 and node2 are numbers of nodes that the element lie in between, and value is value of the element. Also, it's important to always have a 0 node.<br />
For some elements there are some differences which I explained in below:<br />
  - Coupled Inductor: there should be four nodes instead of two for the first and the second branchs' first and second nodes respectively. Then there should be L<sub>11</sub>
  - part 2: panorama with five key frames <br />
  - part 3: projecting video to refrence frame's plan <br />
  - part 4: creating background panorama <br />
  - part 5: creating background video <br />
  - part 6: creating foreground video <br />
  - part 7: creating wider video <br />
  - part 8: creating shakeless video <br />
