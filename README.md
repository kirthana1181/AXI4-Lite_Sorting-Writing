# AXI4-Lite Slave Peripheral-Based Packet Sorter
In this repository, an AXI4-Lite Protocol Slave Peripheral Transaction has been coded that can receive data packets, validate them based on sorting condition valid or invalid storage. The design of the storage is a simple FIFO, and the validating and sorting takes place using the valid and invalid FIFOs.
**This design implements a custom AXI4-Lite slave peripheral on an FPGA that performs packet validation and classification using simple control logic and FIFO storage.**
# Functionality Overview
Purpose: Receive 32-bit data packets, validate them using a rule, and store them in either a valid or invalid FIFO based on that rule.
# System Behavior
**1. Packet Input (0x00 Address):**
A 32-bit packet is written to this address using the AXI4-Lite write protocol.

Stored temporarily in a buffer or register.

**2. Commit Trigger (0x04 Address):**
Writing to this address triggers the validation and sorting logic for the last received packet.

**3. Validation Rule:**
If the top byte of the packet (bits [31:24]) equals 0xA5, the packet is considered valid.

Otherwise, it is invalid.

**4. Storage:**
- Valid packets go into valid_fifo[0:7]

- Invalid packets go into invalid_fifo[0:7]

Each FIFO holds up to 8 packets (FIFO width: 32 bits, sliced/stored as 8-bit wide chunks).

# AXI4-Lite Protocol Used
The design supports a minimal AXI4-Lite write-only interface, handling the necessary handshaking signals:

- Address Channel: AWVALID, AWREADY, AWADDR

- Write Data Channel: WVALID, WREADY, WDATA

- Write Response Channel: BVALID, BREADY, BRESP

# Key Learnings & Relevance
- Demonstrates AXI4-Lite protocol handling
- Implements basic control logic and sorting
- Introduces FIFO buffer design
- Useful as a building block for more complex systems like filters, classifiers, or preprocessors in embedded systems and SoC designs.

