# RISC-V Processor Implementation
This is an implementation of a RISC-V processor in SystemVerilog. It consists of three phases which I will elaborate on:
## Phase 1:
In this phase, a single-cycle RV32I processor has been implemented. Various types of operations, including logical operations, load, store, and branch instructions, have been implemented in this phase.
## Phase 2:
In this phase, a level 1 (L1) direct-mapped cache has been implemented to eliminate direct access of the CPU to main memory and reduce memory access time. To simulate real-world scenarios, the main memory requires several clock cycles to prepare the response.
## Phase 3:
In this phase, pipelining has been introduced to the project to enhance the speed and efficiency of the processor. It allows multiple instructions to be processed simultaneously, leading to improved throughput, better resource utilization, and reduced execution time for programs.
