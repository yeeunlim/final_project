const Map<String, String> emotionResponses = {
  "기쁨": "지금 느끼는 이 긍정적인 감정이 참 좋으시겠어요. 이런 순간은 삶의 큰 선물이니 충분히 즐기세요. 당신의 행복이 주변 사람들에게도 전해질 거예요.",
  "흥분": "무언가 흥분되는 일이 있으신가봐요. 이러한 감정은 우리에게 에너지를 주고 삶에 활력을 불어넣어 줍니다.",
  "만족스러움": "현재의 상황에 매우 만족스러우신 것 같아요. 정말 다행이에요. 앞으로도 이런 상황이 계속되길 바라요.",
  "자신하는": "굳건한 믿음이 느껴지네요. 이런 자신감은 큰 원동력이 되죠. 그 자신감을 바탕으로 더 큰 도전을 해보세요.",
  "뿌듯함": "노력의 결과가 긍정적이라서 뿌듯함을 느끼는 순간이군요. 스스로를 칭찬하며 이 성취를 축하하세요. 이런 순간들이 당신을 더욱 성장시킬 거예요.",
  "설렘": "무언가 기대되는 일이 있으신가 봐요. 이런 감정은 우리를 활기차게 만들죠. 설레는 마음으로 하루를 즐겁게 보내세요.",
  "안도": "마음이 놓이는 순간이네요. 이런 순간에는 평온함을 충분히 느끼며 여유를 즐기세요. 당신의 마음이 계속 편안하기를 바랍니다.",
  "감사함": "주변에 감사한 일이 많으신 것 같아요. 이런 감정은 삶을 더 풍요롭게 만들죠. 감사한 마음을 주변 사람들과 나누면 더 큰 행복을 느낄 수 있을 거예요.",
  "여유로움": "여유로운 시간을 보내고 계신가 봐요. 이런 순간은 스트레스를 해소하고 마음의 평화를 가져다줍니다. 이 여유를 충분히 즐기세요.",
  "편안함": "마음이 편안한 상태를 유지하고 계시다니 좋네요. 이 평온한 상태가 계속되기를 바랍니다. 편안한 마음으로 하루를 보내세요.",
  "무난함": "오늘은 특별한 일 없이 무난한 하루를 보내고 계시군요. 이런 날도 삶의 한 부분입니다. 평범한 날들 속에서 행복을 찾으세요.",
  "당황": "예상치 못한 상황을 겪으셨나 봅니다. 당황스러울 수 있지만, 잠시 깊은 숨을 쉬고 차분히 상황을 정리해보세요. 더 나아질 거예요.",
  "부끄러움": "때로는 부끄러운 일도 있을 수 있습니다. 그런 순간에도 자신을 너무 탓하지 마세요. 누구나 그런 경험을 합니다.",
  "놀람": "갑작스러운 일이 일어나면 놀랄 수 있습니다. 천천히 상황을 정리하고 다시 한 번 생각해보세요. 모든 일이 잘 해결될 거예요.",
  "혼란스러움": "혼란스러운 상황을 겪고 계신가요? 잠시 멈추고 생각을 정리해보세요. 차분하게 하나씩 해결해 나가면 좋을 것 같아요.",
  "걱정": "걱정이 많으신 것 같네요. 혼자가 아니라는 것을 기억하고, 주변 사람들과 고민을 나눠보세요. 함께라면 더 나아질 거예요.",
  "불안": "불안한 감정이 느껴지시나요? 마음을 진정시키고 긍정적인 생각을 가져보세요. 모든 일이 잘 풀릴 거예요.",
  "두려움": "두려움이 느껴질 때는 용기를 내어 조금씩 극복해 나가세요. 당신은 충분히 해낼 수 있습니다. 항상 응원합니다.",
  "불편함": "지금 불편한 감정을 느끼고 계시군요. 잠시 편안한 장소에서 휴식을 취하며 마음을 달래보세요. 당신의 편안함이 중요합니다.",
  "억울함": "억울한 상황을 겪으셨군요. 그런 감정은 정말 힘들 수 있어요. 당신의 이야기를 들어줄 수 있는 사람과 나누며 마음을 조금 덜어내세요. 함께라면 더 나아질 거예요.",
  "부러움": "다른 사람을 보며 부러움을 느끼는 것은 자연스러운 일입니다. 하지만 당신도 충분히 멋진 사람입니다. 스스로의 장점을 다시 한번 생각해보세요.",
  "답답함": "답답한 마음이 드시나요? 잠시 산책을 하거나 마음을 환기시킬 수 있는 활동을 해보세요. 기분이 한결 나아질 거예요.",
  "후회": "과거의 선택에 대해 후회하고 계신 것 같아요. 후회는 누구에게나 있을 수 있는 감정입니다. 중요한 것은 앞으로의 방향입니다. 더 나은 결정을 위해 스스로를 용서하고 나아가세요.",
  "죄책감": "죄책감을 느끼고 계시다니 마음이 무겁겠어요. 용서를 구하고 스스로를 용서하세요. 앞으로 더 잘할 수 있을 거예요.",
  "괴로움": "괴로운 상황을 겪고 계시다니 안타깝네요. 이 힘든 시간을 이겨내며 더욱 강해질 수 있을 거예요.",
  "지침": "지치신 것 같아요. 잠시 모든 것을 내려놓고 휴식을 취해보세요. 충분히 쉴 자격이 있습니다.",
  "무기력": "무기력을 느끼고 계신가요? 작은 일부터 시작해보세요. 성취감을 느낄 수 있을 거예요.",
  "허무함": "허무함을 느끼고 계시다니 마음이 무겁네요. 때로는 모든 것이 의미 없게 느껴질 수 있습니다. 자신의 가치를 다시 생각해보세요. 당신은 소중한 존재이며, 많은 것을 이룰 수 있습니다.",
  "좌절감": "좌절감을 느끼고 계시군요. 다시 일어설 힘을 모아보세요. 당신은 충분히 해낼 수 있습니다.",
  "자괴감": "자괴감을 느끼고 계시다니 마음이 많이 무거우시겠어요. 스스로에게 너무 가혹하지 않기를 바랍니다. 우리는 모두 실수할 수 있고, 중요한 것은 그 실수에서 배우는 것입니다. 자신을 용서하고 더 나은 미래를 향해 나아가세요.",
  "짜증": "지금 뭔가가 많이 마음에 들지 않으시군요. 잠시 짜증나는 일은 잊고 다른 집중할 수 있는 활동을 찾아보세요. 부정적인 감정을 해소할 수 있을 거예요.",
  "혐오": "무언가가 싫은 감정이 충분히 들 수 있어요. 잠시 그 상황에서 벗어나 당신이 좋아하는 것들에 더 집중해보세요.",
  "불쾌함": "불쾌한 감정이 드시다니 마음이 많이 불편하시겠어요. 그런 감정을 느낄 때는 잠시 멈추고 편안한 장소에서 휴식을 취해보세요. 마음을 진정시키고, 긍정적인 에너지를 되찾으세요.",
  "분노": "분노는 우리에게 큰 에너지를 주기도 하지만, 잘못된 방향으로 흘러갈 수도 있습니다. 감정이 격해질 때는 잠시 거리를 두고 상황을 다시 바라보는 것도 도움이 됩니다.",
  "슬픔": "슬픔을 느끼고 계시다니 마음이 아프네요. 충분히 울고 나면 마음이 한결 가벼워질 거예요. 가까운 사람과 마음을 나누세요.",
  "우울함": "우울한 감정이 드시나요? 주변에 도움을 요청하고 마음을 나누어보세요. 함께라면 더 나아질 거예요.",
  "속상함": "속상한 일이 있으신가요? 마음을 진정시키고 차분하게 생각해보세요. 시간이 지나면 나아질 거예요.",
  "실망": "실망을 느끼고 계시다니 마음이 무겁겠어요. 하지만 너무 실망하지 마세요. 모든 경험은 우리에게 배움을 주고, 더 나은 선택을 할 수 있게 합니다.",
  "외로움": "외로움을 느끼고 계시군요. 가까운 사람에게 연락해보세요. 혼자가 아니라는 것을 기억하세요. 제가 언제나 곁에 있을게요.",
  "Unknown": "감정을 인식할 수 없습니다."
};