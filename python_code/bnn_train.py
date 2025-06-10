import numpy as np
import tensorflow as tf
from tensorflow import keras
from keras.datasets import mnist 
from keras.models import Sequential 
from keras.layers import Dense, Input 
import larq as lq  # bnn library
import random
random.seed(0) # random seed for reproducibility
np.random.seed(0) # random seed for reproducibility
tf.random.set_seed(0) # random seed for reproducibility

# loading MNİST dataset (60.000 training and 10.000 test images)
(train_images, train_labels), (test_images, test_labels) = mnist.load_data()

# Reshaping images to add a single dimension (28x28 grayscale)
train_images = train_images.reshape((60000, 28 * 28))
test_images = test_images.reshape((10000, 28 * 28))

# normalizing pixel values to be between -1 and 1 for binarization 
train_images, test_images = train_images / 127.5 - 1, test_images / 127.5 - 1

# defining the common settings for binarized layers
kwargs = dict(
    input_quantizer="ste_sign",  # Straight-Through Estimator based sign activation for binarization 
    kernel_quantizer="ste_sign",  # Binarizes weights (-1 or 1)
    kernel_constraint="weight_clip"  # clamps weights between -1 and 1
)

# İnitializing a Sequential model with 3 binarized dense layers
model = Sequential([
    # INPUT LAYER + HIDDEN LAYER 1
    lq.layers.QuantDense(128, input_shape=(28*28,), use_bias=False, **kwargs), # Input: 784 features, Output: 128 binary activations
    tf.keras.layers.BatchNormalization(scale=False), # Applies normalization to the results of the previous layer

    # HIDDEN LAYER 2
    lq.layers.QuantDense(64, use_bias=False, **kwargs), # Input: 128 features, Output: 64 binary activations
    tf.keras.layers.BatchNormalization(scale=False), # Applies normalization to the results of the previous layer

    # OUTPUT LAYER
    lq.layers.QuantDense(10, use_bias=False, **kwargs), # Maps the 64 features to 10 classes (digits 0–9)
    tf.keras.layers.BatchNormalization(scale=False), # Normalizes the final 10 outputs.
])

# compiling the model with custom optimizer and categorical crossentropy loss
lr_schedule = tf.keras.optimizers.schedules.ExponentialDecay(
    initial_learning_rate=0.001,
    decay_steps=1000,
    decay_rate=0.96,
    staircase=True
)

model.compile(
    optimizer=tf.keras.optimizers.Adam(learning_rate=lr_schedule),
    loss='sparse_categorical_crossentropy',
    metrics=['accuracy']
)

# Training the model for 15 epochs with a batch size of 64
model.fit(train_images, train_labels, batch_size=64, epochs=15)

# saving the trained model
model.save('mnist_model.h5')

# evaluating model performance on test data
test_loss, test_acc = model.evaluate(test_images, test_labels)

# Printing final test accuracy
print(f"Test accuracy {test_acc * 100:.2f} %")