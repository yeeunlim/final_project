import pandas as pd
from tqdm import tqdm
import torch
from transformers import AutoTokenizer, GPT2LMHeadModel, AdamW
import os
import warnings
warnings.filterwarnings('ignore')

# 데이터 경로 및 샘플링 개수 설정
dir_path = './data/'
EPOCHS = 3
batch_size = 4

# tokenizer/model 가져오기 (skt/kogpt2-base-v2)
tokenizer = AutoTokenizer.from_pretrained('skt/kogpt2-base-v2', bos_token='</s>', eos_token='</s>', pad_token='<pad>')
model = GPT2LMHeadModel.from_pretrained('skt/kogpt2-base-v2')

# 데이터를 토크나이즈하는 함수
def tokenize_df():
    chatbot_df = pd.read_excel(dir_path + '감성대화말뭉치(train+val)_송영숙_싱글턴_완성.xlsx')
    print(chatbot_df.shape)
    # 질문, 레이블 응답 문장을 불러옵니다.
    for question, response in zip(chatbot_df.question.to_list(), chatbot_df.response.to_list()):
        # 문장의 BOS token : </s>
        bos_token = [tokenizer.bos_token_id]
        # 문장의 EOS 토큰
        eos_token = [tokenizer.eos_token_id]
        # 문장 구조 : BOS + 질문 + (토큰으로 구분) + 응답 + EOS
        sentence = tokenizer.encode('<unused0>' + question + '<unused1>' + response)

        yield bos_token + sentence + eos_token

def collate_fn(batch):
    # batch에서 가장 긴 문장을 기준으로 zero-padding을 진행합니다.
    max_length = max(len(sample) for sample in batch)
    batch_padded = [sample + [tokenizer.pad_token_id] * (max_length - len(sample)) for sample in batch]
    return torch.tensor(batch_padded)

def fit_model(dataset, optimizer):
    model.train()
    for epoch in range(EPOCHS):
        train_loss = 0

        for batch in tqdm(dataset):
            inputs = batch.to(torch.device('cuda' if torch.cuda.is_available() else 'cpu'))
            optimizer.zero_grad()
            outputs = model(inputs, labels=inputs)
            loss = outputs.loss
            train_loss += loss.item()
            loss.backward()
            optimizer.step()

        print(f"Epoch {epoch + 1}, Loss: {train_loss / len(dataset)}")

# 메인 코드
if __name__ == "__main__":
    # 감성말뭉치 & 송영숙 데이터 합치기 
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    model.to(device)
    optimizer = AdamW(model.parameters(), lr=3e-5, eps=1e-08)

    # Dataset 만들기
    dataset = list(tokenize_df())

    dataloader = torch.utils.data.DataLoader(dataset, batch_size=batch_size, collate_fn=collate_fn, shuffle=True)

    fit_model(dataloader, optimizer)

    # 모델을 학습 후 저장
    model_path = './kogpt_model/'

    # .pth 파일로 모델 저장
    torch.save(model.state_dict(), model_path + 'kogpt2_model.pth')

    print('Model saved to kogpt2_model.pth')
