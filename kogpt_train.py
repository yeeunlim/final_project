import pandas as pd
from tqdm import tqdm
import tensorflow as tf
from transformers import AutoTokenizer
from transformers import TFGPT2LMHeadModel
import os
os.environ['TF_ENABLE_ONEDNN_OPTS'] = '0'

dir_path = './data/'
sampling_cnt = 5 #분류별 가져올 샘플 개수
EPOCHS = 1
batch_size = 1

# tokenizer/model  가져오기 (skt/kogpt2-base-v2)
tokenizer = AutoTokenizer.from_pretrained('skt/kogpt2-base-v2', bos_token='</s>', eos_token='</s>', pad_token='<pad>')
model = TFGPT2LMHeadModel.from_pretrained('skt/kogpt2-base-v2', from_pt=True)

def get_emotion():
    emotion_df = pd.read_excel(dir_path + '감성대화말뭉치(val+tran_1대화)_답변수정.xlsx')

    # label2 (category)별로 뽑아서 학습하기 위하여
    chatbot_df = pd.DataFrame(columns=emotion_df.columns)  # 결과를 저장할 빈 데이터프레임 생성
    for category, group in emotion_df.groupby('label2'):
        selected_rows = group.sample(n=min(sampling_cnt, len(group)), replace=False)  # 각 그룹에서 최대 30개의 행을 랜덤하게 선택
        chatbot_df = pd.concat([chatbot_df, selected_rows])  # 선택된 행을 결과 데이터프레임에 추가

    return chatbot_df

def get_song_emotion():
    # 송영숙 데이터 챗봇에 추가하기
    song_df = pd.read_excel(dir_path + '송영숙 챗봇 학습용 데이터.xlsx')
    song_df = song_df.dropna()

    # 라벨 없는 행 제거
    song_df = song_df[(song_df['label']==0) | (song_df['label']==1) | (song_df['label']==2) ]

    song = pd.DataFrame(columns=['label', 'Q', 'A']) 
    for label, group in song_df.groupby('label'):
        selected_rows = group.sample(n=min(sampling_cnt, len(group)), replace=False)  # 각 그룹에서 최대 30개의 행을 랜덤하게 선택
        song = pd.concat([song, selected_rows])  # 선택된 행을 결과 데이터프레임에 추가
    song.reset_index()
    song.columns = ['label', 'question', 'response']

    return song

def get_merge_data():
    df1 = get_emotion()  # 감성말뭉치 데이터
    df2 = get_song_emotion() # 송영숙 데이터
    
    # 송영숙 챗봇 데이터와, 감성 말뭉치 합치기
    df1 = df1[['question', 'response']]
    df2 = df2[['question', 'response']]
    song_emotion_df = pd.concat([df2, df1])
    song_emotion_df.reset_index(inplace=True, drop=True)

    return song_emotion_df

def tokenize_df():
    chatbot_df = get_merge_data()

    # 질문, 레이블 응답 문장을 불러옵니다.
    for question, response in zip(chatbot_df.question.to_list(),  chatbot_df.response.to_list()):
        # 문장의 BOS token : </s>
        bos_token = [tokenizer.bos_token_id]
        # 문장의 EOS token : </s>
        eos_token = [tokenizer.eos_token_id]
        # print(question, response)
        #문장 구조 : BOS + 질문 + (토큰으로 구분) + 응답 + EOS
        sentence = tokenizer.encode('<unused0>' + question + '<unused1>' + response)

        yield bos_token + sentence + eos_token

def fit_model(dataset):
    for epoch in tqdm(range(EPOCHS)):
        train_loss = 0

        for batch in tqdm(dataset):
            try:
                with tf.GradientTape() as tape:
                    result = model(batch, labels=batch)
                    loss = result[0]
                    batch_loss = tf.reduce_mean(loss, -1)
                    train_loss += batch_loss

                grads = tape.gradient(batch_loss, model.trainable_variables)
                adam.apply_gradients(zip(grads, model.trainable_variables))

            except Exception as e:
                print("Exception occurred:", str(e))

        print("Epoch {}".format(epoch + 1 ))

# 감성말뭉치 & 송영숙 데이터 합치기 
if __name__ == "__main__":
    adam = tf.keras.optimizers.Adam(learning_rate = 3e-5, epsilon=1e-08)

    # tf dataset 만들기
    # def 함수를 적용한 tf dataset을 만듭니다.
    dataset = tf.data.Dataset.from_generator(tokenize_df, output_types = tf.int32)

    # batch에서 가장 긴 문장을 기준으로 zero-padding을 진행합니다.
    dataset = dataset.padded_batch(batch_size = batch_size, padded_shapes=(None,),
                                padding_values = tokenizer.pad_token_id)
    
    fit_model(dataset)

    # save fine-tuned tokenizer & model
    tokenizer.save_pretrained(dir_path + 'test_song_emotion_chatbot', bos_token='</s>', eos_token='</s>', pad_token='<pad>')
    model.save_pretrained(dir_path + 'test_song_emotion_chatbot')