import torch

# Kobert
bertmodel_emotion = None
bertmodel_background = None
model_emotion = None
model_background = None
tokenizer_kobert = None
emotion_category = None
background_category = None
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

# KoGPT2
tokenizer_kogpt2 = None
model_kogpt2 = None