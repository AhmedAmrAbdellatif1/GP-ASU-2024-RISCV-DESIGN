# RISC-V (RV64IMAC) Design Graduation Project

Welcome to the repository for the RTL design codes of the RISC-V architecture capable of running the Linux operating system. This project was completed as part of a graduation thesis at the Electronics & Communications Department, Faculty of Engineering, Ain Shams University.

### Team Members
- [Ahmed Amr Abdellatif](https://www.linkedin.com/in/ahmed-amr-abdellatif/)
- [Rana Mohamed Abdullah](mailto:rana.abdalluh.1d@gmail.com)
- [Abdelrahman Mohamed Abdelhalim](mailto:abdomohamed1961@gmail.com)
- [Bishoy Emad William](https://www.linkedin.com/in/bishoy-emad-527812227/)
- [Hebatallah Hesham Sayed](https://www.linkedin.com/in/hebatallah-hesham-a68818240/)
- [Omar EzzEldin Mohamed](mailto:omarezzeldin121@gmail.com)

## Introduction

This project focuses on the design and implementation of a RISC-V architecture to support the Linux operating system. The RISC-V architecture is chosen due to its open-source nature and extensibility, making it suitable for academic and industrial applications.

![5-stages Pipelined RV64IMC-Machine Mode](https://github.com/AhmedAmrAbdellatif1/GP-RV64IMAC/assets/140100601/850d0061-5a62-4c1a-830f-8a1933185309)

## Objectives and Scope

### Objectives

1. **Identify RISC-V Extensions**: Determine the necessary RISC-V extensions (RV64IMAC) and privilege levels (M and S modes) required to support the Linux OS.
2. **Design Architecture**: Develop the architecture and block diagram for the RV64I base instruction set and integrate the required extensions (M, C, A).
3. **RTL Development**: Create the RTL design for the RV64IMAC architecture, including features such as L1 data and instruction caches.
4. **Peripheral Integration**: Add and integrate essential peripherals, like the UART, to support system functionality.
5. **Verification**: Utilize open-source tools to verify the system’s behavior and correctness.
6. **FPGA Prototyping**: Prototype the designed system on an FPGA for practical testing and validation.

### Scope

- Detailed development of the Pipelined RV64IMAC architecture.
- RTL implementation, incorporating L1 caches, CSRs, and privilege modes.
- Designing and integrating essential peripherals like the UART.
- Verification and testing using RISCV-DV and other tools.
- FPGA prototyping, including synthesis, timing constraints, and performance evaluation.

## Architecture Design

The architecture design includes the development of the RV64I base instruction set and the integration of the necessary extensions (M, C, A). The design also includes creating a pipelined version of the architecture.

## RTL Implementation

The RTL implementation involves translating the architectural design into RTL code. This includes incorporating features such as L1 data and instruction caches and Control and Status Registers (CSRs).

## Peripheral Integration

Peripheral integration involves adding essential peripherals, such as the UART, to ensure the designed architecture can interact with external devices and handle communication tasks necessary for running an OS.

## Verification

Verification is done using open-source tools from CHIPS Alliance to ensure the system's behavior and correctness. Verification ensures that the designed system operates as intended and meets the specified requirements.

## FPGA Prototyping

FPGA prototyping involves implementing the designed system on an FPGA and generating a bitstream for practical testing and validation. This step allows for real-world testing and performance evaluation, providing insights into the feasibility of running Linux on the designed architecture.

## Documentation

Comprehensive documentation is provided, detailing the design, implementation, verification, and prototyping processes, along with a comparison with existing RISC-V cores and suggestions for future work.

[Graduation Project Thesis](https://drive.google.com/file/d/1HYaxwctf71etvR4QhIf5rDlQkh__jxif/view?usp=drive_link)
