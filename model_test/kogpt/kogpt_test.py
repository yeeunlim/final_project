import tensorflow as tf
from transformers import AutoTokenizer
from transformers import TFGPT2LMHeadModel

# 챗봇 함수 정의
def chatbot(text):
    sentence = '<unused0>' + text + '<unused1>'  # 질문 -> <unused0>질문<unused1>
    tokenized = [tokenizer.bos_token_id] + tokenizer.encode(sentence)  # bos토큰 + 토크나이징한 문장
    tokenized = tf.convert_to_tensor([tokenized])  # 텐서로 변환

    # 응답 토큰 생성 -> 질문 + 응답 토큰 반환
    result = model.generate(tokenized, min_length=15, max_length=50, repetition_penalty=1.3,
                            do_sample=True, no_repeat_ngram_size=5, temperature=0.01,
                            top_k=2)

    # 생성된 토큰을 텍스트로 디코딩
    output = tokenizer.decode(result[0].numpy().tolist())

    # 응답 부분 추출
    response = output.split('<unused1> ')[1]

    return response

# 메인 실행 코드
if __name__ == "__main__":
    save_model_path = "./kogpt_model/"  # 모델 저장 경로
    model_name = 'song_emotion_chatbot'  # 모델 이름
    # 토크나이저 불러오기
    tokenizer = AutoTokenizer.from_pretrained(save_model_path + model_name, bos_token='</s>', eos_token='</s>', pad_token='<pad>')
    # 모델 불러오기
    model = TFGPT2LMHeadModel.from_pretrained(save_model_path + model_name)

    while 1:
        sent = input('\nQuestion: ')  # 사용자로부터 질문 입력받기
        data = chatbot(sent)  # 챗봇 함수 호출
        data = data.split('</s')  # 응답 처리

        if '종료' in sent:  # '종료'라는 단어가 입력되면 루프 종료
            break

        # 응답 출력
        print(f'response: {data[0]}')
        print('-' * 50)