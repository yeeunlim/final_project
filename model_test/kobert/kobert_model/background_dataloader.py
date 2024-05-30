import torch
from torch import nn
import torch.nn.functional as F
import torch.optim as optim
from torch.utils.data import Dataset, DataLoader
import numpy as np
np.bool = np.bool_
from tqdm import tqdm, tqdm_notebook

from kobert_tokenizer import KoBERTTokenizer

from transformers import AdamW
from transformers.optimization import get_cosine_schedule_with_warmup

# 웰니스 텍스트 분류를 위한 데이터셋 클래스 정의
class WellnessTextClassificationDataset(Dataset):
    def __init__(self,
                 file_path="./data/wellness_dialog_for_text_classification_배경.txt",  # 데이터 파일 경로
                 num_label=25,  # 레이블의 수
                 device='cpu',  # 디바이스 설정 (기본값: CPU)
                 max_seq_len=512,  # KoBERT 최대 시퀀스 길이
                 tokenizer=None  # 토크나이저 (기본값: None)
                 ):
        self.file_path = file_path  # 파일 경로 저장
        self.device = device  # 디바이스 저장
        self.data = []  # 데이터를 저장할 리스트 초기화
        self.tokenizer = KoBERTTokenizer.from_pretrained('skt/kobert-base-v1')

        # 파일 열기
        file = open(self.file_path, 'r', encoding='utf-8')

        # 파일에서 한 줄씩 읽어오기
        while True:
            line = file.readline()  # 한 줄 읽기
            if not line:  # 더 이상 읽을 줄이 없으면 종료
                break
            datas = line.split("    ")  # 탭으로 분리하여 데이터 추출
            index_of_words = self.tokenizer.encode(datas[0])  # 문장을 토큰화하여 인덱스 리스트로 변환
            token_type_ids = [0] * len(index_of_words)  # 토큰 타입 ID 초기화
            attention_mask = [1] * len(index_of_words)  # 어텐션 마스크 초기화

            # 패딩 길이 계산
            padding_length = max_seq_len - len(index_of_words)

            # 제로 패딩 추가
            index_of_words += [0] * padding_length
            token_type_ids += [0] * padding_length
            attention_mask += [0] * padding_length

            # 레이블 설정
            label = int(datas[1][:-1])  # 레이블 값을 정수로 변환

            # 데이터를 딕셔너리 형태로 저장
            data = {
                'input_ids': torch.tensor(index_of_words).to(self.device),  # 입력 ID 텐서로 변환 후 디바이스에 저장
                'token_type_ids': torch.tensor(token_type_ids).to(self.device),  # 토큰 타입 ID 텐서로 변환 후 디바이스에 저장
                'attention_mask': torch.tensor(attention_mask).to(self.device),  # 어텐션 마스크 텐서로 변환 후 디바이스에 저장
                'labels': torch.tensor(label).to(self.device)  # 레이블 텐서로 변환 후 디바이스에 저장
            }

            self.data.append(data)  # 데이터를 리스트에 추가

        file.close()  # 파일 닫기

    # 데이터셋의 길이를 반환하는 메서드
    def __len__(self):
        return len(self.data)

    # 주어진 인덱스에 해당하는 데이터를 반환하는 메서드
    def __getitem__(self, index):
        item = self.data[index]
        return item

tokenizer = KoBERTTokenizer.from_pretrained('skt/kobert-base-v1')

# 데이터셋 클래스 테스트
if __name__ == "__main__":
    dataset = WellnessTextClassificationDataset()  # 데이터셋 객체 생성
    print(dataset)  # 데이터셋 정보 출력


