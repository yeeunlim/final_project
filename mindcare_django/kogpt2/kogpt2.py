import torch
from transformers import AutoTokenizer, GPT2LMHeadModel
from django.conf import settings
from pathlib import Path
import global_vars  # 전역 변수 모듈 임포트

# 전역 변수 정의는 global_vars에서 가져옴
global_vars.device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

# 토큰 상수 정의
BOS = '</s>'
EOS = '</s>'
PAD = '<pad>'

def initialize_kogpt2_model():
    global global_vars

    save_model_path = settings.BASE_DIR / 'kogpt2/'
    model_name = 'kogpt2_model.pth'

    if global_vars.tokenizer_kogpt2 is None:
        global_vars.tokenizer_kogpt2 = AutoTokenizer.from_pretrained("skt/kogpt2-base-v2", bos_token=BOS, eos_token=EOS, pad_token=PAD)

    if global_vars.model_kogpt2 is None:
        global_vars.model_kogpt2 = GPT2LMHeadModel.from_pretrained('skt/kogpt2-base-v2')
        state_dict = torch.load(save_model_path / model_name, map_location=global_vars.device)
        global_vars.model_kogpt2.load_state_dict(state_dict)
        global_vars.model_kogpt2.to(global_vars.device)
        global_vars.model_kogpt2.eval()

def chatbot(text):
    sentence = '<unused0>' + text + '<unused1>'
    tokenized = [global_vars.tokenizer_kogpt2.bos_token_id] + global_vars.tokenizer_kogpt2.encode(sentence)
    tokenized = torch.tensor([tokenized]).to(global_vars.device)
    
    # 질문 문장으로 "레이블 + 응답" 토큰 생성
    result = global_vars.model_kogpt2.generate(tokenized, min_length=15, max_length=50, repetition_penalty=1.3,
                                               do_sample=True, no_repeat_ngram_size=5, temperature=0.01,
                                               top_k=2)
    output = global_vars.tokenizer_kogpt2.decode(result[0].tolist())
    response = output.split('<unused1> ')[1]
    response = response.replace('</s>', '')
    return response
