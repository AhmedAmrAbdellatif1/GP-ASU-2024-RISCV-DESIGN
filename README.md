# RISC-V Processor Design - Graduation Project

## Overview
This project focuses on the design and implementation of a pipelined RISC-V 64-bit base I instruction architecture using SystemVerilog.

### Team Members
- [Ahmed Amr Abdellatif](https://www.linkedin.com/in/ahmed-amr-abdellatif/) - Verification
- [Rana Mohamed Abdullah](mailto:rana.abdalluh.1d@gmail.com) - Verification
- [Abdelrahman Mohamed Abdelhalim](mailto:abdomohamed1961@gmail.com) - Verification
- [Bishoy Emad William](https://www.linkedin.com/in/bishoy-emad-527812227/) - Design
- [Hebatallah Hesham Sayed](https://www.linkedin.com/in/hebatallah-hesham-a68818240/) - Design
- [Omar EzzEldin Mohamed](mailto:omarezzeldin121@gmail.com) - Design

## Repository Structure
The GitHub repository contains the following directories and files:

- `/design`: Contains the SystemVerilog implementation of the RISC-V processor.
- `/testbench`: Includes the testbench files to verify the functionality of the designed processor.
- `/docs`: Supplementary documentation explaining the architecture, design decisions, and test results.

## Design Files

### 1. `design/README.md`
This file provides an overview of the design, including:
- Introduction to the RISC-V architecture.
- Key components and modules implemented in SystemVerilog.
- Pipeline stages and their functionalities.

### 2. `design/rv64i_processor.sv`
The main SystemVerilog file contains the implementation of the pipelined RISC-V 64-bit processor.

### 3. `design/module1.sv`, `design/module2.sv`, ...
Description of individual modules or components, such as ALU, control unit, register file, etc., if present.

## Testbench Files

### 1. `testbench/README.md`
An explanation of the testbench structure and methodology used for verification.

### 2. `testbench/test_cases/`
Directory containing various test cases used to validate the functionality of the processor.

### 3. `testbench/simulation_results/`
Contains the output logs or reports generated from simulations.

## Documentation

### 1. `docs/Design_Documentation.pdf`
A comprehensive document detailing:
- Detailed architecture of the RISC-V processor.
- Design choices and justifications.
- Performance analysis and optimizations.

### 2. `docs/Test_Results_Report.pdf`
Reports on test results including:
- Coverage analysis.
- Performance metrics.
- Issues encountered and their resolutions.

## Instructions for Review

To review our RISC-V processor design, follow these steps:

1. Start with the `design/README.md` file for an overview of the architecture and design.
2. Review the main design file (`rv64i_processor.sv`) for the complete implementation.
3. Explore individual modules or components in the `/design` directory if needed.
4. Refer to the `/testbench` directory and its README for details on testbench setup and execution.
5. For a deeper understanding, refer to the documentation in the `/docs` directory.

## Conclusion

Thank you for reviewing our project! Should you require any further information or clarification, please don't hesitate to contact our team.
