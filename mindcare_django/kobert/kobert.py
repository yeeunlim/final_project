import torch
from transformers import BertModel
from .classifier import BERTClassifier, kobert_input
from kobert_tokenizer import KoBERTTokenizer
from django.conf import settings
from pathlib import Path
import global_vars  # 전역 변수 모듈 임포트

# 전역 변수 정의는 global_vars에서 가져옴
global_vars.device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

def initialize_kobert_models():
    global global_vars

    root_path = settings.BASE_DIR / 'kobert/'
    emotion_model = 'kobert-wellness-text-classification_감정.pth'
    background_model = 'kobert-wellness-text-classification_배경.pth'

    if global_vars.bertmodel_emotion is None:
        global_vars.bertmodel_emotion = BertModel.from_pretrained('skt/kobert-base-v1', return_dict=False)
        global_vars.model_emotion = BERTClassifier(global_vars.bertmodel_emotion, num_labels=39)

    if global_vars.bertmodel_background is None:
        global_vars.bertmodel_background = BertModel.from_pretrained('skt/kobert-base-v1', return_dict=False)
        global_vars.model_background = BERTClassifier(global_vars.bertmodel_background, num_labels=25)

    # 감정 모델 가중치 로드
    emotion_checkpoint = torch.load(root_path / emotion_model, map_location=global_vars.device)
    global_vars.model_emotion.load_state_dict(emotion_checkpoint['model_state_dict'])
    global_vars.model_emotion.to(global_vars.device)
    global_vars.model_emotion.eval()

    # 배경 모델 가중치 로드
    background_checkpoint = torch.load(root_path / background_model, map_location=global_vars.device)
    global_vars.model_background.load_state_dict(background_checkpoint['model_state_dict'])
    global_vars.model_background.to(global_vars.device)
    global_vars.model_background.eval()

    # KoBERT 토크나이저 로드
    if global_vars.tokenizer_kobert is None:
        global_vars.tokenizer_kobert = KoBERTTokenizer.from_pretrained('skt/kobert-base-v1')

def classify_emotion(sentence):
    if global_vars.emotion_category is None:
        print("Emotion categories not loaded")
        return None

    print(f"Classifying emotion for sentence: {sentence}")
    data = kobert_input(global_vars.tokenizer_kobert, sentence, global_vars.device, 512)
    print(f"Input data: {data}")
    
    # 모델에 입력하여 출력값 얻기
    with torch.no_grad():
        output = global_vars.model_emotion(**data)
    
    # 로짓 값 추출
    logits = output[0]
    print(f"Logits: {logits}")

    # 소프트맥스 적용
    softmax_logits = torch.softmax(logits, dim=-1)
    print(f"Softmax logits: {softmax_logits}")
    
    # 각 클래스의 확률 값 계산
    emotion_probs = {global_vars.emotion_category[str(i)]: softmax_logits[0][i].item() for i in range(len(global_vars.emotion_category))}
    print(f"Emotion probabilities: {emotion_probs}")
    
    # 가장 큰 확률을 가진 감정 찾기
    max_emotion = max(emotion_probs, key=emotion_probs.get)
    
    return max_emotion

def classify_background(sentence):
    if global_vars.background_category is None:
        print("Background categories not loaded")
        return None

    print(f"Classifying background for sentence: {sentence}")
    data = kobert_input(global_vars.tokenizer_kobert, sentence, global_vars.device, 512)
    print(f"Input data: {data}")
    
    # 모델에 입력하여 출력값 얻기
    with torch.no_grad():
        output = global_vars.model_background(**data)
    
    # 로짓 값 추출
    logits = output[0]
    print(f"Logits: {logits}")
    
    # 소프트맥스 적용
    softmax_logits = torch.softmax(logits, dim=-1)
    print(f"Softmax logits: {softmax_logits}")
    
    background_probs = {global_vars.background_category[str(i)]: softmax_logits[0][i].item() for i in range(len(global_vars.background_category))}
    print(f"Background probabilities: {background_probs}")
    
    max_background = max(background_probs, key=background_probs.get)
    
    return max_background
