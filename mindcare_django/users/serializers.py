# from dj_rest_auth.registration.serializers import RegisterSerializer
# from rest_framework import serializers
# from .models import CustomUser

        
# 최희정 추가
from dj_rest_auth.registration.serializers import RegisterSerializer
from rest_framework import serializers
from .models import CustomUser

class CustomRegisterSerializer(RegisterSerializer):
    name = serializers.CharField(required=True)
    nickname = serializers.CharField(required=True)
    birthdate = serializers.CharField(required=True)

    class Meta:
        model = CustomUser
        fields = ('username', 'email', 'password1', 'password2', 'name', 'nickname', 'birthdate')

    def get_cleaned_data(self):
        data = super().get_cleaned_data()
        data.update({
            'name': self.validated_data.get('name', ''),
            'nickname': self.validated_data.get('nickname', ''),
            'birthdate': self.validated_data.get('birthdate', ''),
        })
        return data

    def validate(self, data):
        # 기존의 유효성 검사 로직을 포함하여 추가 필드도 포함되도록 합니다.
        data = super().validate(data)
        data['name'] = self.initial_data.get('name')
        data['nickname'] = self.initial_data.get('nickname')
        data['birthdate'] = self.initial_data.get('birthdate')

        print('vali: ', data)
        return data

    def save(self, request):
        user = super().save(request)
        user.name = self.validated_data.get('name')
        user.nickname = self.validated_data.get('nickname')
        user.birthdate = self.validated_data.get('birthdate')
        user.save()
        return user