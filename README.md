# FIFO Verilog Implementation

## FIFO Designs in Verilog

This repository contains Verilog implementations of:
- Synchronous FIFO (`fifo_sync.v`)
- Asynchronous FIFO (`fifo_async.v`)

along with testbenches and simulation waveforms for functional verification.

## Features
- Parameterized FIFO design
- Full and empty flag generation
- Synchronous and asynchronous FIFO architectures
- Gray code synchronization for CDC in async FIFO
- Verified using custom testbenches

## Concepts Covered
- FIFO memory architecture
- Clock Domain Crossing (CDC)
- Gray code counters
- RTL design and verification
- Waveform analysis

## Verification
The designs were tested for:
- Reset functionality
- Read/write operations
- FIFO full and empty conditions
- Simultaneous read/write behavior
- Different clock domains (async FIFO)

## Tools Used
- Verilog HDL
- Vivado Simulator
