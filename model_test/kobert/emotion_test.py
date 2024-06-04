import torch
from transformers import AdamW, BertModel
from kobert_model.classifier import BERTClassifier, kobert_input
from kobert_model.dataloader import WellnessTextClassificationDataset
from kobert_tokenizer import KoBERTTokenizer
import torch.nn as nn
import random

# KoBERT 모델 로드
bertmodel = BertModel.from_pretrained('skt/kobert-base-v1', return_dict=False)

def load_wellness_answer():
    root_path = "./kobert_감정_전처리"
    category_path = f"{root_path}/data/wellness_dialog_category_감정.txt"
    # answer_path = f"{root_path}/data/wellness_dialog_answer_감정.txt"
    c_f = open(category_path, 'r', encoding='utf-8')
    # a_f = open(answer_path, 'r')

    category_lines = c_f.readlines()
    # answer_lines = a_f.readlines()

    category = {}
    # answer = {}
    for line_num, line_data in enumerate(category_lines):
        data = line_data.split('    ')
        category[data[1][:-1]] = data[0]

    # for line_num, line_data in enumerate(answer_lines):
    #     data = line_data.split('    ')
    #     keys = answer.keys()
    #     if (data[0] in keys):
    #         answer[data[0]] += [data[1][:-1]]
    #     else:
    #         answer[data[0]] = [data[1][:-1]]

    # return category, answer
    return category

if __name__ == "__main__":
    root_path = "."
    checkpoint_path = f"{root_path}/checkpoint"
    save_ckpt_path = f"{checkpoint_path}/kobert-wellness-text-classification_감정.pth"

    # 답변과 카테고리 불러오기
    # category, answer = load_wellness_answer()
    category = load_wellness_answer()

    ctx = "cuda" if torch.cuda.is_available() else "cpu"
    device = torch.device(ctx)

    # 저장한 Checkpoint 불러오기
    checkpoint = torch.load(save_ckpt_path, map_location=device)

    model = BERTClassifier(bertmodel, num_labels=39)  # num_labels 추가
    model.load_state_dict(checkpoint['model_state_dict'])

    model.to(ctx)
    model.eval()

    tokenizer = KoBERTTokenizer.from_pretrained('skt/kobert-base-v1')

    while True:
        sent = input('\nQuestion: ')  # '요즘 기분이 우울한 느낌이에요'
        if '종료' in sent:
            break

        data = kobert_input(tokenizer, sent, device, 512)

        # 모델에 입력하여 출력값 얻기
        output = model(**data)

        # 로짓 값 추출
        logits = output[0]
        # 소프트맥스 적용
        softmax_logits = torch.softmax(logits, dim=-1)
        
        # 각 클래스의 확률 값 출력
        for i, prob in enumerate(softmax_logits[0]):
            print(f"Class {i} ({category[str(i)]}): {prob:.2f}")
        
        # 최댓값 인덱스 및 값 추출
        max_index = torch.argmax(softmax_logits).item()
        max_index_value = softmax_logits[0, max_index].item()

        print(f'Max index: {max_index} ({category[str(max_index)]}), softmax value: {max_index_value}')
        print('-' * 50)

        # answer_list = answer[category[str(max_index)]]
        # answer_len = len(answer_list) - 1
        # answer_index = random.randint(0, answer_len)
        # print(f'Answer: {answer_list[answer_index]}, index: {max_index}, softmax_value: {max_index_value}')
