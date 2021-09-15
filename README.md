# Circuit_Solver
This is an implementation of a circuit solver using node method. As input you should fill a .txt file. The function will get the address of input and output files (.txt).
Each line in the input file should specify properties of onlu one element. Acceptable elements are resistors, capacitors, inductors, coupled inductor, dependent sources, and independent sources, and the symbols are R, C, L, ML, V or I (voltage or current), and CSVC/VSVC or CSCC/VSCC (voltage/current source voltage/current controlled) respectively.<br />
For most elements you should use the <Element><Name><node1><node2><value> format (with spaces in between). Name of the element can be anything. the elemets symbols explaind in above. Node1 and node2 are numbers of nodes that the element lie in between, and value is value of the element. Also, it's important to always have a 0 node.<br />
For some elements there are some differences which I explained in below:<br />
  - Coupled inductor: there should be four nodes instead of two for the first and the second branchs' first and second nodes respectively. Then there should be L<sub>11</sub>, L<sub>12</sub>, L<sub>21</sub>, and L<sub>22</sub> which are coupling matrix elements.
  - Voltage dependent sources: after node1 and node2 you should write node3 and node4 which are indicating the voltage controlling the source. The value is the gain of the source.<br />
  - Current dependent sources: after node1 and node2 you should write number of the element (number of the line in which the element is defined) controlling the source. If the element is a coupled inductor you should write 1 or 2 at the end of the line to indicate which brach's current is controlling the source.<br />

There are also 4 examples provided to help you.
