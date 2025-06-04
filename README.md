## 📜 Description

This repository hosts the solutions to the exercises proposed in the **[RISC-V ALE Exercise Book](https://riscv-programming.org/ale-exercise-book/book/index.html)** 📖, authored by João Seródio and Edson Borin.

These exercises are part of the curriculum for the discipline **MC404 - Computer Organization and Assembly Language** 💻, ministered by Professor Edson Borin at the University of Campinas (Unicamp) 🏛️ during the second semester of 2024.

The main goal of this repository is to serve as a reference and learning resource for students enrolled in the course, providing a practical approach to understanding the concepts of computer organization and assembly language using the RISC-V architecture. 🚀

## 🧠 Topics/Concepts Covered

This section outlines the main topics and concepts you'll encounter throughout the exercises in this repository:

*   **🛠️ Getting Started:**
    *   Code Generation Tools
    *   Makefiles
*   **🖥️ Simulator Usage:**
    *   Running "Hello World"
    *   Using the Assistant Tool
    *   Debugging Techniques
*   **🔢 Data Representation:**
    *   Number Base Conversion (Binary, Decimal, Hexadecimal)
*   **🧩 Assembly, Object, and Executable Files:**
    *   ELF File Organization/Structure
*   **🔩 Bit Manipulation and Instruction Encoding:**
    *   Bit Masking
    *   Shift Operations
    *   RISC-V Instruction Encoding
*   **👨‍💻 Assembly User-level Programming:**
    *   Mathematical Functions (e.g., Square Root)
    *   Data Processing (e.g., GPS, Hamming Code)
    *   Graphics and Image Manipulation (e.g., Image on Canvas, Image Filtering)
    *   Data Structures (e.g., Linked List Search)
    *   ABI Compliance (e.g., ABI-compliant Linked List Search, ABI-compliant Recursive Binary Tree Search)
*   **⚙️ Assembly System-level Programming:**
    *   Peripheral Access (e.g., Car Control via memory-mapped I/O, Serial Port communication)
    *   Interrupt Handling (e.g., External Interrupts for MIDI Player, Software Interrupts for Car Control)
*   **💡 Complementary Short Exercises:**
    *   ABI (Application Binary Interface) Compliance
    *   Data Organization in Memory
    *   Stack and Frame Pointers

## 📂 Repository Structure

The repository is expected to be organized primarily by the sections or chapters of the **[RISC-V ALE Exercise Book](https://riscv-programming.org/ale-exercise-book/book/index.html)**. 📚

Each major section or chapter will likely have its own directory, containing:
*   The assembly code (`.s` or `.S` files) for the exercises.
*   Associated `Makefile`s for building the projects.
*   Any additional files or resources required for specific exercises (e.g., input data, helper scripts).

This structure aims to keep the solutions organized and easy to navigate, mirroring the progression of the exercise book. 📁
Within each exercise directory, you will typically find the source code and any specific build instructions or notes relevant to that exercise.

## 🤔 How to Use

Here are a few ways you can use this repository:

*   **✅ Reference for Solutions:** If you're stuck on an exercise, you can refer to the solutions here to get an idea or compare your approach.
*   **📖 Learning & Understanding:** Explore the code to deepen your understanding of RISC-V assembly language, specific instructions, and programming techniques.
*   **🔍 Compare Approaches:** See how different problems are tackled and discover various strategies for solving assembly language tasks.
*   **🛠️ Practical Application:** Use the examples as a basis for your own projects or experiments with RISC-V.

**Prerequisites:**
To compile and run the exercises in this repository, you will generally need:
1.  A **RISC-V GNU Toolchain** (compiler, assembler, linker).
2.  The **RISC-V ALE (Assembly Language Environment) Simulator**.

For detailed instructions on setting up these tools, please refer to the **"Getting Started"** section of the **[RISC-V ALE Exercise Book](https://riscv-programming.org/ale-exercise-book/book/index.html)** 📘. The book provides comprehensive guidance on installing and configuring the necessary environment.

Once your environment is set up, you can navigate to specific exercise directories and typically use `make` to compile and `make run` or `make sim` (or similar commands as specified in the exercise's `Makefile` or notes) to execute the programs in the simulator.
