import torch
from transformers import BertModel
from .classifier import BERTClassifier, kobert_input
from kobert_tokenizer import KoBERTTokenizer
from django.conf import settings

# 모델 경로 및 디바이스 설정
root_path = settings.BASE_DIR / 'kobert/'
emotion_model = 'kobert-wellness-text-classification_감정.pth'
background_model = 'kobert-wellness-text-classification_배경.pth'
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

# KoBERT 모델 및 토크나이저 초기화
bertmodel = None
model_emotion = None
model_background = None
tokenizer = None

def initialize_kobert_models():
    global bertmodel, model_emotion, model_background, tokenizer

    if bertmodel is None:
        bertmodel = BertModel.from_pretrained('skt/kobert-base-v1', return_dict=False)
        model_emotion = BERTClassifier(bertmodel, num_labels=39)
        model_background = BERTClassifier(bertmodel, num_labels=25)

    # 감정 모델 가중치 로드
    emotion_checkpoint = torch.load(root_path / emotion_model, map_location=device)
    model_emotion.load_state_dict(emotion_checkpoint['model_state_dict'])
    model_emotion.to(device)
    model_emotion.eval()

    # 배경 모델 가중치 로드
    background_checkpoint = torch.load(root_path / background_model, map_location=device)
    model_background.load_state_dict(background_checkpoint['model_state_dict'])
    model_background.to(device)
    model_background.eval()

    # KoBERT 토크나이저 로드
    if tokenizer is None:
        tokenizer = KoBERTTokenizer.from_pretrained('skt/kobert-base-v1')

# 감정, 배경 카테고리 불러오기
def load_wellness_answer(filename):
    path = root_path / filename
    with open(path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    category = {}
    for line_num, line_data in enumerate(lines):
        data = line_data.split('    ')
        category[data[1][:-1]] = data[0]

    return category
    
emotion_category = load_wellness_answer("wellness_dialog_category_감정.txt")
background_category = load_wellness_answer("wellness_dialog_category_배경.txt")

# 감정 코멘트 불러오기
def load_emotion_responses(filename):
    path = root_path / filename
    with open(path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    emotion_responses = {}
    for line in lines:
        parts = line.split('\t')
        if len(parts) == 2:
            emotion = parts[0].strip()
            response = parts[1].strip()
            emotion_responses[emotion] = response
    
    return emotion_responses

emotion_responses = load_emotion_responses("emotion_responses.txt")

def classify_emotion(sentence):
    data = kobert_input(tokenizer, sentence, device, 512)
    
    # 모델에 입력하여 출력값 얻기
    output = model_emotion(**data)
    
    # 로짓 값 추출
    logits = output[0]

    # 소프트맥스 적용
    softmax_logits = torch.softmax(logits, dim=-1)
    
    # 각 클래스의 확률 값 출력
    emotion_probs = {emotion_category[str(i)]: softmax_logits[0][i].item() for i in range(len(emotion_category))}
    
    # 가장 큰 확률을 가진 감정 찾기
    max_emotion = max(emotion_probs, key=emotion_probs.get)
    
    return emotion_probs, max_emotion

def classify_background(sentence):
    data = kobert_input(tokenizer, sentence, device, 512)
    
    # 모델에 입력하여 출력값 얻기
    output = model_background(**data)
    
    # 로짓 값 추출
    logits = output[0]
    
    # 소프트맥스 적용
    softmax_logits = torch.softmax(logits, dim=-1)
    
    # 각 클래스의 확률 값 출력
    background_probs = {background_category[str(i)]: softmax_logits[0][i].item() for i in range(len(background_category))}
    
    # 가장 큰 확률을 가진 배경 찾기
    max_background = max(background_probs, key=background_probs.get)
    
    return background_probs, max_background
