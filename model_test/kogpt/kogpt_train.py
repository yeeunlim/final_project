import pandas as pd
from tqdm import tqdm
import tensorflow as tf
from transformers import AutoTokenizer
from transformers import TFGPT2LMHeadModel
import os

# 환경 변수 설정 (성능 최적화 옵션 비활성화)
os.environ['TF_ENABLE_ONEDNN_OPTS'] = '0'

# 데이터 경로 및 샘플링 개수 설정
dir_path = './data/'
sampling_cnt = 5  # 분류별로 가져올 샘플 개수
EPOCHS = 1  # 학습 에포크 수
batch_size = 1  # 배치 크기

# tokenizer 및 모델 가져오기 (skt/kogpt2-base-v2)
tokenizer = AutoTokenizer.from_pretrained('skt/kogpt2-base-v2', bos_token='</s>', eos_token='</s>', pad_token='<pad>')
model = TFGPT2LMHeadModel.from_pretrained('skt/kogpt2-base-v2', from_pt=True)

# 감성 대화 데이터를 불러오는 함수
def get_emotion():
    emotion_df = pd.read_excel(dir_path + '감성대화말뭉치(val+tran_1대화)_답변수정.xlsx')

    # label2 (category) 별로 샘플링하여 데이터 프레임 생성
    chatbot_df = pd.DataFrame(columns=emotion_df.columns)  # 결과를 저장할 빈 데이터프레임 생성
    for category, group in emotion_df.groupby('label2'):
        selected_rows = group.sample(n=min(sampling_cnt, len(group)), replace=False)  # 각 그룹에서 샘플링
        chatbot_df = pd.concat([chatbot_df, selected_rows])  # 샘플링된 행을 결과 데이터프레임에 추가

    return chatbot_df

# 송영숙 데이터를 불러오는 함수
def get_song_emotion():
    song_df = pd.read_excel(dir_path + '송영숙 챗봇 학습용 데이터.xlsx')
    song_df = song_df.dropna()  # 결측값 제거

    # 라벨 없는 행 제거
    song_df = song_df[(song_df['label']==0) | (song_df['label']==1) | (song_df['label']==2)]

    # 샘플링하여 데이터 프레임 생성
    song = pd.DataFrame(columns=['label', 'Q', 'A']) 
    for label, group in song_df.groupby('label'):
        selected_rows = group.sample(n=min(sampling_cnt, len(group)), replace=False)  # 각 그룹에서 샘플링
        song = pd.concat([song, selected_rows])  # 샘플링된 행을 결과 데이터프레임에 추가
    song.reset_index()
    song.columns = ['label', 'question', 'response']  # 컬럼명 변경

    return song

# 감성 대화 데이터와 송영숙 데이터를 합치는 함수
def get_merge_data():
    df1 = get_emotion()  # 감성 대화 데이터
    df2 = get_song_emotion()  # 송영숙 데이터
    
    # 필요한 컬럼만 선택하여 합치기
    df1 = df1[['question', 'response']]
    df2 = df2[['question', 'response']]
    song_emotion_df = pd.concat([df2, df1])  # 데이터 프레임 합치기
    song_emotion_df.reset_index(inplace=True, drop=True)

    return song_emotion_df

# 데이터를 토크나이즈하는 함수
def tokenize_df():
    chatbot_df = get_merge_data()

    # 질문과 응답 문장을 불러와서 토크나이즈
    for question, response in zip(chatbot_df.question.to_list(), chatbot_df.response.to_list()):
        # 문장의 BOS 토큰
        bos_token = [tokenizer.bos_token_id]
        # 문장의 EOS 토큰
        eos_token = [tokenizer.eos_token_id]
        # 문장 구조: BOS + 질문 + (토큰 구분) + 응답 + EOS
        sentence = tokenizer.encode('<unused0>' + question + '<unused1>' + response)

        yield bos_token + sentence + eos_token

# 모델을 학습시키는 함수
def fit_model(dataset):
    for epoch in tqdm(range(EPOCHS)):  # 설정한 에포크 수만큼 반복
        train_loss = 0

        for batch in tqdm(dataset):  # 데이터셋에서 배치 단위로 데이터 불러오기
            try:
                with tf.GradientTape() as tape:
                    result = model(batch, labels=batch)  # 모델 출력 및 손실 계산
                    loss = result[0]
                    batch_loss = tf.reduce_mean(loss, -1)  # 배치 손실 계산
                    train_loss += batch_loss

                grads = tape.gradient(batch_loss, model.trainable_variables)  # 기울기 계산
                adam.apply_gradients(zip(grads, model.trainable_variables))  # 기울기를 사용하여 모델 업데이트

            except Exception as e:
                print("Exception occurred:", str(e))  # 예외 처리

        print("Epoch {}".format(epoch + 1))

# 메인 코드
if __name__ == "__main__":
    # 옵티마이저 설정
    adam = tf.keras.optimizers.Adam(learning_rate=3e-5, epsilon=1e-08)

    # tf 데이터셋 만들기
    dataset = tf.data.Dataset.from_generator(tokenize_df, output_types=tf.int32)

    # 가장 긴 문장을 기준으로 zero-padding을 진행
    dataset = dataset.padded_batch(batch_size=batch_size, padded_shapes=(None,),
                                   padding_values=tokenizer.pad_token_id)
    
    # 모델 학습
    fit_model(dataset)

    # 모델 저장 경로 설정
    model_path = './kogpt_model/'
    # 파인 튜닝된 토크나이저와 모델 저장
    tokenizer.save_pretrained(model_path + 'song_emotion_chatbot', bos_token='</s>', eos_token='</s>', pad_token='<pad>')
    model.save_pretrained(model_path + 'song_emotion_chatbot')
