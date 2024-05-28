import tensorflow as tf
from transformers import AutoTokenizer
from transformers import TFGPT2LMHeadModel

def chatbot(text):
    # input sentence : "질문" / 응답
    sentence = '<unused0>' + text + '<unused1>'
    tokenized = [tokenizer.bos_token_id] + tokenizer.encode(sentence)
    tokenized = tf.convert_to_tensor([tokenized])

    # 질문 문장으로 "레이블 + 응답" 토큰 생성
    result = model.generate(tokenized, min_length = 15, max_length = 50, repetition_penalty = 1.3,
                            do_sample = True, no_repeat_ngram_size = 5, temperature = 0.01,
                            top_k = 2)

    output = tokenizer.decode(result[0].numpy().tolist())

    response = output.split('<unused1> ')[1]

    return  response

if __name__ == "__main__":
    save_model_path = "./kogpt_model/"
    model_name = 'song_emotion_chatbot'
    tokenizer = AutoTokenizer.from_pretrained(save_model_path + model_name,  bos_token='</s>', eos_token='</s>', pad_token='<pad>')
    model = TFGPT2LMHeadModel.from_pretrained(save_model_path + model_name)

    while 1:
        sent = input('\nQuestion: ')  # '요즘 기분이 우울한 느낌이에요'
        data = chatbot(sent)
        data = data.split('</s')

        if '종료' in sent:
            break

        print(f'response: {data[0]}')
        print('-' * 50)