# !wget --no-check-certificate \
#     https://storage.googleapis.com/laurencemoroney-blog.appspot.com/rps.zip \
#     -0 /tmp/rps.zip                                                                           # The way to get the data

# !wget --no-check-certificate \
#     https://storage.googleapis.com/laurencemoroney-blog.appspot.com/rps-test-set.zip \
#     -0 /tmp/rps-test-set.zip

import os
import zipfile
from keras.models import Sequential
from keras.layers import Dense, Embedding, LSTM, GRU, Flatten, Dropout, Lambda
from keras.layers.embeddings import Embedding
import tensorflow as tf
import keras

local_zip = '/tmp/rps.zip'
zip_ref = zipfile.Zipfile(local_zip, 'r')
zip_ref.extractall('/tmp/')
zip_ref.close()

local_zip = '/tmp/res-test-set.zip'
zip_ref = zipfile.Zipfile(local_zip, 'r')
zip_ref.extractall('/tmp/')
zip_ref.close()

TRAINING_DIR = "tmp/rps/"
training_datagen = ImageDataGenerator(rescale = 1./255)

train_generator = training_datagen.flow_from_directory(
    TRAINING_DIR,
    target_size(150, 150),
    class_mode = 'categorical'
)

validation_generator = validation_datagen.flow_from_directory(
    VALIDATION_DIR,
    target_size = (150, 150),
    class_mode = 'categorical'
)

model = tf.keras.models.Sequential([
    tf.keras.layers.Conv2D(64, (3, 3), activation = 'relu', input_shape(150, 150, 3)),
    tf.keras.layers.MaxPooling2D(2, 2),
    tf.keras.layers.Conv2D(64, (3, 3), activation = 'relu'),
    tf.keras.layers.MaxPooling2D(2, 2),
    tf.keras.layers.Conv2D(128, (3, 3), activation = 'relu'),
    tf.keras.layers.MaxPooling2D(2, 2),
    tf.keras.layers.Conv2D(128, (3, 3), activation = 'relu'),
    tf.keras.layers.MaxPooling2D(2, 2),

    tf.keras.layers.Flatten(),
    tf.keras.layers.Dropout(0.5),

    tf.keras.layers.Dense(512, activation = 'relu'),
    tf.keras.layers.Dense(3, activation = 'softmax')
])

history = model.fit_generator(train_generator, epoch = 25,
    validation_data = validation_generator,
    verbose = 1
)

classes = model.predict(image, batch_size = 10)

# Scissors-hires1.png         [[0.0.1.]]
# Paper6.png                  [[1.0.0.]]
# Scissors1.png               [[0.0.1.]]
# Scissors3.png               [[0.0.1.]]
# Scissors2.png               [[0.0.1.]]
# Scissors9.png               [[0.0.1.]]
# Rock7.png                   [[0.1.0.]]
# Rock9.png                   [[0.1.0.]]
# Rock8.png                   [[0.1.0.]]
# Paper-hires1.png            [[1.0.0.]]
# Rock4.png                   [[0.1.0.]]
# Paper5.png                  [[1.0.0.]]
# Rock2.png                   [[0.1.0.]]
# Paper9.png                  [[1.0.0.]]