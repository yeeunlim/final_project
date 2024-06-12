// API URLs
const String baseUrl = 'http://127.0.0.1:8000';
const String chatbotDiaryUrl = '$baseUrl/api/chatbot_diary';
const String userAuthUrl = '$baseUrl/api/auth';
const String htpTestUrl = '$baseUrl/api/htp_test';

// Image URLs
class ImageUrls {
  static const String mainPageBackground = 'https://mindcare-pj.s3.ap-northeast-2.amazonaws.com/images/main_page.jpg';
  static const String loginPageBackground = 'https://mindcare-pj.s3.ap-northeast-2.amazonaws.com/images/log_in.jpg';
  static const String normalRabbit = 'https://mindcare-pj.s3.ap-northeast-2.amazonaws.com/images/normal_rabbit.png';
  static const String angryRabbit = 'https://mindcare-pj.s3.ap-northeast-2.amazonaws.com/images/anger_rabbit.png';
  static const String sadRabbit = 'https://mindcare-pj.s3.ap-northeast-2.amazonaws.com/images/sad_rabbit.png';
  static const String analysisRabbit = 'https://mindcare-pj.s3.ap-northeast-2.amazonaws.com/images/analy_rabbit.png';
  static const String loadingImage = 'https://mindcare-pj.s3.ap-northeast-2.amazonaws.com/images/loading_image.gif';
}