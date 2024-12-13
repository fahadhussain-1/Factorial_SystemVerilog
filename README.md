# Factorial Calculator in SystemVerilog

This repository contains a SystemVerilog-based implementation of a 32-bit factorial calculator. The project is divided into three main modules: `datapath`, `FSM` (Finite State Machine), and `top`. These modules work together to compute the factorial of a number using an iterative approach.

## Features
- **Datapath Module:** Handles arithmetic operations and register management.
- **FSM Module:** Controls the flow of operations using a state machine.
- **Top Module:** Integrates the datapath and FSM modules and provides the testbench.

## Modules
### 1. Datapath
The `datapath` module performs the following tasks:
- Maintains registers to store intermediate results.
- Provides multiplexers for selecting inputs to the ALU.
- Implements an ALU capable of subtraction and multiplication operations.
- Compares intermediate results to determine completion of the factorial calculation.

### 2. FSM (Finite State Machine)
The `FSM` module:
- Controls the states of the system: multiplication, subtraction, comparison, and completion.
- Generates control signals for the `datapath` based on the current state.

### 3. Top Module
The `top` module:
- Integrates the `datapath` and `FSM` modules.
- Provides a simple testbench for simulating the operation of the factorial calculator.

## File Structure
- `datapath.sv`: Contains the datapath module.
- `FSM.sv`: Contains the FSM module.
- `top.sv`: Contains the top-level module and testbench.

## Simulation
This project is designed to be simulated using any standard SystemVerilog simulator, such as ModelSim, XSIM, or Verilator.

### Steps to Simulate
1. Clone this repository:
   ```bash
   git clone https://github.com/fahadhussain-1/Factorial_SystemVerilog.git
   ```
2. Open the project in your SystemVerilog simulation environment.
3. Compile the files in the following order:
   - `datapath.sv`
   - `FSM.sv`
   - `top.sv`
4. Run the simulation.
5. Observe the results and waveforms.

## Control Signals
The following control signals are used in the design:
- **`a_sel` and `b_sel`**: Select inputs for the ALU.
- **`op_sel`**: Chooses between subtraction (`1`) and multiplication (`0`).
- **`w_sel`**: Selects which register to write to.
- **`w_en`**: Enables writing to the selected register.

## Example Test Case
The testbench provided in the `top` module initializes the system and calculates the factorial of 5.

### Output
The result of the calculation is stored in the `Result` output of the `datapath` module.
![image](https://github.com/user-attachments/assets/80a60e25-800d-4804-b63b-3841ca62c209)

## Dependencies
- A SystemVerilog simulation environment.

## Future Enhancements
- Extend the design to handle larger numbers.
- Integrate this design with FPGA for hardware verification.

## Contact
For any queries, reach out to:
- **Fahad Hussain** (Engineer) - [chipengineer.fahad@gmail.com](mailto:chipengineer.fahad@gmail.com)


