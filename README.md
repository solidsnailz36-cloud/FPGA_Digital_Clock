# FPGA_Digital_Clock
FPGA Digital Clock  
A multi-functional digital clock implemented on FPGA using Verilog HDL.  
 Features 
- ⏰ Real-time clock display (HH:MM:SS)
- ⏱️ Stopwatch mode (up to 99:59:59)
- ⏲️ Countdown timer with buzzer alert
- 🔔 Alarm function
- 🖥️ 6-digit 7-segment display with dynamic scanning
- 🎮 5-key input with debouncing 

**Key Contributions:**

- **System Architecture**: Completed top-level module integration, designed 6 functional sub-modules, implemented 50MHz to 1Hz/1kHz clock division

- **Key Processing**: Implemented 20ms hardware debouncing algorithm and edge detection circuit, supporting 5-key independent trigger and mode switching

- **Core Control Logic**: Designed 4-state Finite State Machine (FSM) enabling four operating modes: normal time, stopwatch, countdown, and alarm setting

- **Display Driver**: Applied dynamic scanning technology, driving 6-digit 7-segment display with only 13 signal lines at 166Hz refresh rate, achieving stable flicker-free display

- **Peripheral Control**: Implemented 500Hz buzzer driver with 10-second timer control for countdown completion and alarm notification

**Tools**: Quartus II, ModelSim, Verilog HDL

## Technical Challenges & Solutions

1. **Key Debouncing**: Implemented a 20ms counter-based debouncing circuit to eliminate mechanical switch jitter

2. **Dynamic Scanning**: Utilized 1kHz clock to drive 6-digit 7-segment display, reducing I/O pins from 42 to 13

3. **Countdown Borrow Logic**: Designed and implemented borrow handling logic for hour, minute, and second cascaded decrement operations

## Simulation & Verification

- Functional simulation coverage >90%
- All waveform verification passed

## Hardware Resources

- Logic Elements: ~430 LEs
- Registers: ~80
- Maximum Frequency: >50MHz
