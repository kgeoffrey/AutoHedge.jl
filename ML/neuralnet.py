## dependancies

import numpy as np
import pandas as pd
import math
import scipy.stats as si
import datetime
import random
import matplotlib.pyplot as plt

from sklearn import preprocessing
from sklearn.model_selection import train_test_split
from keras.optimizers import Adam
from sklearn.preprocessing import MinMaxScaler
from keras.models import Sequential
from keras.layers import Activation, Dense, Dropout
from keras.models import load_model
from keras import backend as K

def prepare_data(df):
    df['spot_price'] = df['spot_price']/df['strike_price']
    df['option_price'] = df['option_price']/df['strike_price']
    # df[['spot_price','option_price']].div(df['strike_price'], axis=1)
    df = df.drop('strike_price', 1)
    return df
    
def create_test_train_set(df):
    X = df[(df.columns)[:-1]]
    y = df[(df.columns)[-1]]
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.10, random_state=42)
    return X_train, X_test, y_train, y_test
    
def coeff_determination(y_true, y_pred):
    SS_res =  K.sum(K.square(y_true-y_pred)) 
    SS_tot = K.sum(K.square(y_true-K.mean(y_true))) 
    return (1-SS_res/(SS_tot + K.epsilon()))
    
## run createdata.py first 
data = pd.read_csv('optionprice.csv')
data = data.dropna()
data = prepare_data(data)
X_train, X_test, y_train, y_test = create_test_train_set(data)

## Model specification
model = Sequential()
model.add(Dense(500, input_dim=4, activation="relu"))
model.add(Dense(400, activation="relu")))
model.add(Dense(200, activation="relu"))
model.add(Dense(100, activation="relu"))
model.add(Dense(1))
model.compile(loss='mse', optimizer=Adam(lr=0.00001), metrics=[coeff_determination])
history = model.fit(X_train,y_train,epochs=200,batch_size=1000, verbose=1)
# model.save("model1.h5")

## Accuracy on testing set 
print("[INFO] evaluating on testing set...")
(loss, mae) = model.evaluate(X_test, y_test,batch_size=100, verbose=1)
print("[INFO] loss={:.12f}, R^2: {:.4f}".format(loss,mae))

# recovers prices from the 'data' pd.Dataframe
def test_predictions(number):
    print(X_test.loc[X_test.index[number]])
    new1 = np.array(X_test.loc[X_test.index[number]])
    new1 = (new1).reshape(4,1)
    new1 = np.transpose(new1)
    pred = model.predict(new1)
    scale = data['strike_price'].loc[X_test.index[number]]
    print('strike price:', scale)
    print('stock price:', scale*X_test.loc[X_test.index[number]][0])
    print('real price:', (y_test.values[number])*scale, 'pred price:', pred*scale)
    
test_predictions("provide ID for option here")

## Plotting Loss and R^2 over epochs
plt.plot(history.history['coeff_determination'])
plt.title('model coeff_determination')
plt.ylabel('coeff_determination')
plt.xlabel('epoch')
plt.legend(['train', 'test'], loc='upper left')
plt.show()
# "Loss"
plt.plot(history.history['loss'])
plt.title('model loss')
plt.ylabel('loss')
plt.xlabel('epoch')
plt.legend(['train', 'validation'], loc='upper left')
plt.show()
