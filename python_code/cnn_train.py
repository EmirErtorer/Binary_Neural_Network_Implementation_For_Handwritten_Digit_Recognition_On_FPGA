import numpy as np
import tensorflow as tf
from tensorflow import keras
from keras.datasets import mnist
from keras.models import Sequential
from keras.layers import Conv2D, MaxPooling2D, Flatten, Dense, Dropout
from keras.utils import to_categorical

# Setting random seeds for reproducibility
np.random.seed(0)
tf.random.set_seed(0)

# Loading and preprocessing MNIST data
(train_images, train_labels), (test_images, test_labels) = mnist.load_data()

# Reshapeing to (28, 28, 1) and normalizing pixel values
train_images = train_images.reshape((60000, 28, 28, 1)).astype("float32") / 255.0
test_images = test_images.reshape((10000, 28, 28, 1)).astype("float32") / 255.0

# Defining the CNN model
model = Sequential([
    Conv2D(32, kernel_size=(3, 3), activation='relu', input_shape=(28, 28, 1)),
    MaxPooling2D(pool_size=(2, 2)),

    Conv2D(64, kernel_size=(3, 3), activation='relu'),
    MaxPooling2D(pool_size=(2, 2)),

    Flatten(),
    Dense(128, activation='relu'),
    Dropout(0.5),  # Regularization
    Dense(10, activation='softmax') 
])

# compiling with standard Adam optimizer and sparse categorical loss
model.compile(
    optimizer=tf.keras.optimizers.Adam(learning_rate=0.001),
    loss='sparse_categorical_crossentropy',
    metrics=['accuracy']
)

# Training the model
model.fit(train_images, train_labels, batch_size=64, epochs=10, validation_split=0.1)

# Evaluation
test_loss, test_acc = model.evaluate(test_images, test_labels)
print(f"Test accuracy: {test_acc * 100:.2f} %")

# Saving the model
model.save("cnn_mnist_model.h5")
