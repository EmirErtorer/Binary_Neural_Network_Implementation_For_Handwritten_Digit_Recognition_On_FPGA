import os
import numpy as np
from tensorflow import keras
from keras.datasets import mnist

output_dir = "test_images"
os.makedirs(output_dir, exist_ok=True)

# Load MNIST test dataset
(_, _), (test_images, test_labels) = mnist.load_data()

# Global counter for sequential filenames
global_index = 1

# Loop over each digit from 0 to 9
for digit in range(10):
    count = 0
    for i in range(len(test_images)):
        if test_labels[i] == digit:
            image = test_images[i]

            # Normalize to [-1, 1] and binarize
            image_normalized = image.astype(np.float32) / 127.5 - 1
            image_binary = (image_normalized >= 0).astype(int)
            image_flat = image_binary.flatten()
    
            # Save with a global index and digit prefix
            filename = os.path.join(output_dir, f"d{digit}_img_{global_index}.mem")
            np.savetxt(filename, image_flat, fmt='%d')
            print(f"Saved {filename} (digit {digit})")

            count += 1
            global_index += 1

            if count == 10:
                break