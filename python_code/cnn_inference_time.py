import numpy as np
import tensorflow as tf
import time
from tensorflow.keras.datasets import mnist

np.random.seed(0)
tf.random.set_seed(0)

# Disabling GPU for CPU only benchmark
tf.config.experimental.set_visible_devices([], "GPU")

# Configurable batch size
batch_size = 1

# Load model
model = tf.keras.models.load_model("cnn_mnist_model.h5")

# Loading and prepare testing images
(_, _), (test_images, _) = mnist.load_data()
x = test_images[:batch_size].reshape(batch_size, 28, 28, 1).astype("float32") / 255.0
x_tensor = tf.convert_to_tensor(x)

# Graph-compiled inference function
@tf.function
def infer(x):
    return model(x, training=False)

# Warm-up for fair timing
_ = infer(x_tensor)

# Timed inference
num_runs = 100
timings = []
for _ in range(num_runs):
    t0 = time.perf_counter_ns()
    _ = infer(x_tensor)
    timings.append(time.perf_counter_ns() - t0)

# Print statistics
def print_stats(label, timings_ns, batch):
    arr = np.asarray(timings_ns)
    mean_total = arr.mean()
    std_total = arr.std()
    min_total = arr.min()
    max_total = arr.max()

    mean_per_img = mean_total / batch
    print(f"\n{label} Benchmark over {len(arr)} runs (batch size = {batch})")
    print("-----------------------------------------------------------------------")
    print(f"Mean total: {mean_total:.0f} ns ({mean_total / 1e6:.3f} ms)")
    print(f"Per image : {mean_per_img:.0f} ns ({mean_per_img / 1e6:.3f} ms)")
    print(f"Std Dev   : {std_total:.0f} ns")
    print(f"Min       : {min_total:.0f} ns")
    print(f"Max       : {max_total:.0f} ns")

    print("Individual Latencies (ms):")
    ms_latencies = arr / 1e6
    for i in range(0, len(ms_latencies), 10):
        print(", ".join(f"{lat:.3f}" for lat in ms_latencies[i:i+10]))

# Output results
print_stats("CNN Inference (CPU)", timings, batch_size)
