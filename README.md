# Binary Neural Network Implementation for Handwritten Digit Recognition on FPGA

This project implements a Binary Neural Network (BNN) trained on the MNIST dataset and deploys it on a Xilinx Artix-7 FPGA for real-time handwritten digit recognition. The model uses binarized weights and activations to enable efficient inference using only XNOR and popcount operations. The entire inference pipeline is implemented in Verilog, with all training and preprocessing performed in Python using TensorFlow and Larq.

---

## 1. Project Structure

```
.
├── python_code/                 # All Python scripts: training, benchmarking, export
├── trained_models/             # Contains trained .h5 models (BNN and CNN)
├── model_weights/              # Generated .mem files for ROMs
├── data/                       # MNIST test images (binarized .mem format)
├── docs/                       # Thesis report, diagrams, supplementary materials
├── diagrams/                   # All architectural and flow diagrams
├── bnn_inference_on_fpga/      # Vivado project folder
```

---

## 2. Environment Setup (Python + Larq + TensorFlow)

This project requires **Python 3.10**, **TensorFlow 2.15.0**, and **Larq 0.13.3**, which are the latest compatible versions. Larq does not support newer versions of TensorFlow.

### macOS / Linux / Windows Setup

1. **Create and activate a virtual environment:**

```bash
python3.10 -m venv venv
source venv/bin/activate        # On macOS/Linux
venv\Scripts\activate.bat       # On Windows
```

2. **Install required packages:**

```bash
pip install tensorflow==2.15.0
pip install larq==0.13.3
```

3. **Verify installation:**

```bash
python -c "import tensorflow as tf; import larq as lq; print(tf.__version__, lq.__version__)"
# Expected output: 2.15.0 0.13.3
```

---

## 3. Training and Benchmarking Pipeline

All scripts are located in the `python_code/` directory.

### Step-by-Step Execution:

1. **Train the BNN:**

```bash
python bnn_train.py
```

- Trains a 3-layer BNN using Larq and TensorFlow.
- Saves the model as `mnist_model.h5`.

2. **Train a reference CNN (for benchmarking only):**

```bash
python cnn_train.py
```

- Trains a standard CNN to compare performance and accuracy with the BNN.
- Saves the model as `cnn_mnist_model.h5`.

3. **Benchmark BNN Inference Time (CPU):**

```bash
python bnn_inference_time.py
```

- Benchmarks inference speed for batch size = 100 using TensorFlow graph mode.

4. **Benchmark CNN Inference Time (CPU):**

```bash
python cnn_inference_time.py
```

- Benchmarks traditional CNN latency for comparison.

---

## 4. Generating ROM Files for FPGA

1. **Extract weights and thresholds from the trained BNN:**

```bash
python extract_learned_parameters.py
```

- Generates `.mem` files:
  - `dense_kernel_transposed.mem`
  - `dense_1_kernel.mem`
  - `dense_2_kernel.mem`
  - Threshold files for first two layers

2. **Convert test images into binarized `.mem` format:**

```bash
python test_images_mem.py
```

- Saves 10 examples for each digit in `/test_images/` folder as `d{digit}_img_{index}.mem`.

---

## 5. Vivado Project Setup

Path to Vivado project:
```
/bnn_inference_on_fpga/bnn_inference_on_fpga.xpr
```

### Option A: Open Existing Vivado Project

You can open the project directly:

```bash
vivado bnn_inference_on_fpga.xpr
```

This will automatically load:
- Design sources
- Simulation sources
- Constraint files (`constraints.xdc`)
- IP configuration

### Option B: Create Project from Scratch (if needed)

1. Open Vivado and create a new project.
2. Add the following Verilog source files:
    - `bnn_top.v`
    - `bnn_inference.v`
    - `model_rom.v`
    - `image_rom.v`
    - `seven_segment_decoder.v`
3. Add testbench:
    - `bnn_top_tb.v`
4. Add constraints:
    - `constraints.xdc` (for pin mapping and clock)
5. Set the top module to `bnn_top`.

---

## 6. Simulation, Synthesis and Implementation

### 6.1 Simulation

1. Open Vivado > Flow Navigator > **Run Simulation > Run Behavioral Simulation**
2. Verify waveform:
   - FSM transitions
   - Layer outputs
   - Predicted digit

### 6.2 Synthesis

1. Flow Navigator > **Run Synthesis**
2. Inspect resource usage and timing summary.

### 6.3 Implementation

1. Flow Navigator > **Run Implementation**
2. Confirm successful timing closure (target: 80 MHz).

### 6.4 Bitstream Generation

1. Flow Navigator > **Generate Bitstream**
2. Output `.bit` file will be created for FPGA flashing.

---

## 7. Hardware Deployment

- Target Board: **Digilent Nexys A7-100T**
- Frequency: **80 MHz** (based on post-implementation timing)
- Output: **4-digit 7-segment display** showing the predicted digit (0–9)

Use Vivado Hardware Manager to flash the `.bit` file to your board.

---

## 8. Acknowledgments

This project was developed as part of a graduation thesis at Yeditepe University, Department of Computer Engineering, under the supervision of **Prof. Dr. Cem Ünsalan**.


