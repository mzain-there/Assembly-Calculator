# 🧮 Scientific Calculator (8086 Assembly - emu8086)

## 📌 Project Overview

This project is a **Scientific Calculator** developed in **8086 Assembly Language** and designed to run on the **emu8086 emulator**. It provides multiple arithmetic and mathematical operations through a simple menu-driven interface.

The program demonstrates low-level programming concepts such as:

* Register manipulation
* Procedure calls
* Stack usage
* Input/output via interrupts
* Arithmetic operations at hardware level

---

## ⚙️ Features

The calculator supports the following operations:

1. **Addition** (A + B)
2. **Subtraction** (A − B)
3. **Multiplication** (A × B)
4. **Division** (A ÷ B)
5. **Modulus** (A MOD B)
6. **Power** (A^B)
7. **Factorial** (A!)
8. **Square Root** (Integer approximation)
9. **Exit Program**

---

## 🖥️ How It Works

### 🔹 Program Flow

1. Program initializes **data segment (DS)**.
2. Displays a **title and menu**.
3. Takes user input (choice).
4. Based on input, jumps to the corresponding operation.
5. Reads numbers (A and/or B).
6. Performs calculation.
7. Displays result.
8. Returns to menu until user exits.

---

## 🔢 Input Handling

* Input is taken **digit-by-digit** using interrupt:

  ```
  INT 21H (AH = 01H)
  ```
* Only numeric values (`0–9`) are accepted.
* Input ends when **Enter (CR = 0Dh)** is pressed.
* ASCII values are converted into integers using:

  ```
  SUB AL, '0'
  ```

---

## 🧠 Core Concepts Used

### 1. Arithmetic Instructions

* `ADD`, `SUB`
* `MUL`, `IMUL`
* `DIV`

### 2. Registers

* `AX`, `BX`, `CX`, `DX`
* `DX:AX` used for large multiplication

### 3. Stack Usage

* `PUSH` / `POP` used in procedures to preserve registers

### 4. Procedures

Modular structure using procedures like:

* `read_A`, `read_B`
* `read_num`
* `print_num`
* `print_result`
* `print_str`

---

## 📐 Operation Details

### ➕ Addition / ➖ Subtraction

Simple arithmetic using `ADD` and `SUB`.

---

### ✖️ Multiplication

* Uses:

  ```
  MUL BX
  ```
* Result stored in:

  ```
  DX:AX
  ```
* Handles large results by printing both high and low parts.

---

### ➗ Division

* Uses:

  ```
  DIV BX
  ```
* Quotient → `AX`
* Remainder → `DX`
* Checks for division by zero.

---

### 🔁 Modulus

* Uses division and returns remainder (`DX`).

---

### 🔺 Power (A^B)

* Repeated multiplication loop:

  ```
  result = result * A
  ```
* Uses `CX` as loop counter.
* Includes overflow detection.

---

### ❗ Factorial (A!)

* Loop from `A → 1`
* Multiplies continuously:

  ```
  AX = AX * CX
  ```
* Handles `0! = 1`
* Detects overflow.

---

### √ Square Root

* Uses **incremental method**:

  ```
  Find i such that i*i ≤ A
  ```
* Returns integer approximation.

---

## ⚠️ Error Handling

The program handles several errors:

* ❌ Division by zero
* ❌ Overflow in multiplication/power/factorial
* ❌ Invalid menu choice

---

## 🧾 Output Display

* Strings printed using:

  ```
  INT 21H (AH = 09H)
  ```
* Numbers printed using custom procedure (`print_num`)
* Multi-digit numbers handled using stack logic

---

## ▶️ How to Run

1. Open **emu8086**
2. Create a new assembly file
3. Paste the code
4. Compile and run
5. Follow on-screen menu instructions

---

## 📊 Limitations

* Works only with **positive integers**
* No floating-point support
* Square root is **approximate**
* Limited to **16-bit register size**
* Large calculations may cause overflow

---

## 🚀 Future Improvements

* Support negative numbers
* Add floating-point operations
* Improve square root using Newton’s method
* Add trigonometric functions (sin, cos, etc.)
* Better UI formatting

---

## 👨‍💻 Author

Developed as a learning project for:

* Assembly Language Programming
* Computer Architecture Concepts

---

## 📎 Conclusion

This project is a great example of how high-level calculator operations can be implemented using **low-level assembly instructions**, helping in understanding how computers perform calculations internally.

---
