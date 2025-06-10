import numpy as np
import h5py
import os

# Transpose and save a binary matrix as a .mem file
def transpose_and_save_mem(binary_matrix, filename):
    num_rows, num_cols = binary_matrix.shape
    transposed = binary_matrix.T.astype(str)

    with open(filename, "w") as f:
        for row in transposed:
            f.write("".join(row) + "\n")

    print(f"Saved transposed .mem file: {filename} ({num_cols}x{num_rows} → {num_rows}x{num_cols})")

# Load model and extract weights and thresholds
with h5py.File("mnist_model.h5", "r") as f:
    weight_paths = {
        "dense_kernel": "model_weights/quant_dense/quant_dense/kernel:0",
        "dense_1_kernel": "model_weights/quant_dense_1/quant_dense_1/kernel:0",
        "dense_2_kernel": "model_weights/quant_dense_2/quant_dense_2/kernel:0"
    }

    bn_paths = {
        "dense_kernel": "model_weights/batch_normalization/batch_normalization",
        "dense_1_kernel": "model_weights/batch_normalization_1/batch_normalization_1",
        "dense_2_kernel": "model_weights/batch_normalization_2/batch_normalization_2"
    }

    epsilon = 1e-5  # default for BatchNorm

    for name, path in weight_paths.items():
        data = f[path][()]

        # Binarization
        if np.all(np.isin(data, [-1, 0, 1])):
            binarized = (data > 0).astype(int)  # +1 → 1, -1 or 0 → 0
        else:
            binarized = (data >= 0).astype(int)  # fallback

        # Save transposed .mem
        mem_filename = f"{name}_transposed.mem"
        transpose_and_save_mem(binarized, mem_filename)

        #Handle BatchNorm thresholds
        try:
            bn_base = bn_paths[name]
            beta = f[f"{bn_base}/beta:0"][()]
            moving_mean = f[f"{bn_base}/moving_mean:0"][()]
            moving_var = f[f"{bn_base}/moving_variance:0"][()]

            float_thresh = moving_mean - beta * np.sqrt(moving_var + epsilon)
            threshold = np.round(float_thresh).astype(int)

            with open(f"{name}_thresholds.mem", "w") as tf:
                for val in threshold:
                    if val < 0:
                        val = (1 << 11) + val  # two's complement
                    tf.write(f"{val:011b}\n")

            print(f"Saved threshold file: {name}_thresholds.mem")

        except KeyError as e:
            print(f"[!] Could not find BatchNorm data for {name}: {e}")
