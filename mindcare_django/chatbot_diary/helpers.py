from kobert.kobert import classify_emotion, classify_background
import global_vars

def analyze_text(diary_text):
    print("Starting text analysis...")
    sentences = diary_text.split('\n')
    sentences = [sentence.strip() for sentence in sentences if sentence.strip()]
    print(f"Sentences: {sentences}")

    if not sentences:
        raise ValueError("No sentences found in diary text")

    emotion_counts = {emotion: 0 for emotion in global_vars.emotion_category.values()}
    background_counts = {background: 0 for background in global_vars.background_category.values()}
    total_sentences = len(sentences)

    for sentence in sentences:
        max_emotion = classify_emotion(sentence)
        max_background = classify_background(sentence)
        print(f"Sentence: {sentence}")
        print(f"Classified Emotion: {max_emotion}")
        print(f"Classified Background: {max_background}")
        emotion_counts[max_emotion] += 1
        background_counts[max_background] += 1

    emotion_distribution = {emotion: (count / total_sentences) * 100 for emotion, count in emotion_counts.items() if count > 0}
    background_distribution = {background: (count / total_sentences) * 100 for background, count in background_counts.items() if count > 0}

    most_felt_emotion = max(emotion_counts, key=emotion_counts.get)
    most_thought_background = max(background_counts, key=background_counts.get)

    print(f"Emotion Distribution: {emotion_distribution}")
    print(f"Background Distribution: {background_distribution}")
    print(f"Most Felt Emotion: {most_felt_emotion}")
    print(f"Most Thought Background: {most_thought_background}")

    return {
        "emotion_distribution": emotion_distribution,
        "background_distribution": background_distribution,
        "most_felt_emotion": most_felt_emotion,
        "most_thought_background": most_thought_background,
    }
