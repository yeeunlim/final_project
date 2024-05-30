import torch
import torch.nn as nn
from torch.nn import CrossEntropyLoss, MSELoss

class BERTClassifier(nn.Module):
    def __init__(self, bert, num_labels=24, hidden_size=768, hidden_dropout_prob=0.1):
        super(BERTClassifier, self).__init__()
        self.bert = bert  # BERT 모델
        self.num_labels = num_labels  # 분류할 레이블의 수
        self.dropout = nn.Dropout(hidden_dropout_prob)  # 드롭아웃 확률
        self.classifier = nn.Linear(hidden_size, num_labels)  # 분류기

    def gen_attention_mask(self, token_ids, valid_length):
        # 유효한 토큰 길이를 기반으로 어텐션 마스크를 생성하는 함수
        attention_mask = torch.zeros_like(token_ids)
        for i, v in enumerate(valid_length):
            attention_mask[i][:v] = 1
        return attention_mask.float()

    def forward(self, input_ids=None, attention_mask=None, token_type_ids=None, position_ids=None, head_mask=None, inputs_embeds=None, labels=None):
        # 모델의 순전파 함수
        # BERT 모델의 출력을 얻음
        outputs = self.bert(input_ids, attention_mask=attention_mask, token_type_ids=token_type_ids, position_ids=position_ids, head_mask=head_mask, inputs_embeds=inputs_embeds)
        pooled_output = outputs[1]  # [CLS] 토큰의 출력
        pooled_output = self.dropout(pooled_output)  # 드롭아웃 적용
        logits = self.classifier(pooled_output)  # 분류기를 통과하여 로짓을 얻음
        outputs = (logits,) + outputs[2:]

        if labels is not None:
            # 레이블이 주어진 경우, 손실 계산
            if self.num_labels == 1:
                # 회귀 문제일 경우 MSELoss 사용
                loss_fct = MSELoss()
                loss = loss_fct(logits.view(-1), labels.view(-1))
            else:
                # 분류 문제일 경우 CrossEntropyLoss 사용
                loss_fct = CrossEntropyLoss()
                loss = loss_fct(logits.view(-1, self.num_labels), labels.view(-1))
            outputs = (loss,) + outputs

        return outputs  # (손실), 로짓, (히든 스테이트), (어텐션)


def kobert_input(tokenizer, str, device=None, max_seq_len=512):
    # 문자열을 토큰 인덱스로 변환 (토큰화)
    index_of_words = tokenizer.encode(str)

    # 각 토큰에 대한 타입 인덱스 (BERT에서는 첫 번째 문장과 두 번째 문장을 구분하는 데 사용)
    token_type_ids = [0] * len(index_of_words)

    # 어텐션 마스크 (패딩된 부분은 0, 실제 토큰 부분은 1)
    attention_mask = [1] * len(index_of_words)

    # 패딩 길이 계산 (최대 길이에서 실제 토큰 길이를 뺀 값)
    padding_length = max_seq_len - len(index_of_words)

    # 패딩을 추가하여 최대 길이에 맞춤
    index_of_words += [0] * padding_length
    token_type_ids += [0] * padding_length
    attention_mask += [0] * padding_length

    # 데이터를 텐서로 변환하고, 지정된 디바이스로 이동
    data = {
        'input_ids': torch.tensor([index_of_words]).to(device),  # 토큰 인덱스
        'token_type_ids': torch.tensor([token_type_ids]).to(device),  # 타입 인덱스
        'attention_mask': torch.tensor([attention_mask]).to(device),  # 어텐션 마스크
    }

    # 변환된 데이터를 반환
    return data
