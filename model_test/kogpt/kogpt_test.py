import torch
from transformers import AutoTokenizer, GPT2LMHeadModel

def chatbot(text):
    # input sentence : "질문" / 응답
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

if __name__ == "__main__":
    # GPU를 사용하려면 모델을 CUDA로 이동
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

    save_model_path = "./kogpt_model/"
    model_name = 'song_emotion_chatbot'
    tokenizer = AutoTokenizer.from_pretrained(save_model_path + model_name, bos_token='</s>', eos_token='</s>', pad_token='<pad>')

    # GPT2 모델 초기화
    model = GPT2LMHeadModel.from_pretrained('skt/kogpt2-base-v2')

    # 모델의 가중치 로드
    model.load_state_dict(torch.load(save_model_path + 'kogpt2_model.pth', map_location=device))
    model.to(device)

    print('Model loaded successfully')

    while True:
        sent = input('\nQuestion: ')  # '요즘 기분이 우울한 느낌이에요'
        data = chatbot(sent)
        data = data.split('</s')

        if '종료' in sent:
            break

        print(f'{sent}')
        print(f'response: {data[0]}')
        print('-' * 50)