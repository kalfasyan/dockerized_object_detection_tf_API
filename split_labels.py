import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split

df = pd.read_csv('./data/helmet_labels.csv')

train, test = train_test_split(df, test_size=0.2, random_state=42)

train.to_csv('./data/train_labels.csv')
test.to_csv('./data/test_labels.csv')
