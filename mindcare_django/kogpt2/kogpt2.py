import torch
from transformers import AutoTokenizer, GPT2LMHeadModel
from django.conf import settings

# 토큰 상수 정의
BOS = '</s>'
EOS = '</s>'
PAD = '<pad>'

# 모델 및 토크나이저 초기화
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
save_model_path = settings.BASE_DIR / 'kogpt2/'
model_name = 'kogpt2_model.pth'

tokenizer = None
model = None

def initialize_kogpt2_model():
    global tokenizer, model
    
    if tokenizer is None:
        tokenizer = AutoTokenizer.from_pretrained("skt/kogpt2-base-v2", bos_token=BOS, eos_token=EOS, pad_token=PAD)

    if model is None:
        model = GPT2LMHeadModel.from_pretrained('skt/kogpt2-base-v2')
        state_dict = torch.load(save_model_path / model_name, map_location=device)
        model.load_state_dict(state_dict)
        model.to(device)
        model.eval()

def chatbot(text):
    sentence = '<unused0>' + text + '<unused1>'
    tokenized = [tokenizer.bos_token_id] + tokenizer.encode(sentence)
    tokenized = torch.tensor([tokenized]).to(device)
    
    # 질문 문장으로 "레이블 + 응답" 토큰 생성
    result = model.generate(tokenized, min_length=15, max_length=50, repetition_penalty=1.3,
                            do_sample=True, no_repeat_ngram_size=5, temperature=0.01,
                            top_k=2)
    output = tokenizer.decode(result[0].tolist())
    response = output.split('<unused1> ')[1]
    return response
