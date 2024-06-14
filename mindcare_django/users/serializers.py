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

        if CustomUser.objects.filter(username=data['username']).exists():
            raise serializers.ValidationError("Username is already in use.")
        if CustomUser.objects.filter(nickname=data['nickname']).exists():
            raise serializers.ValidationError("Nickname is already in use.")
        if CustomUser.objects.filter(nickname=data['email']).exists():
            raise serializers.ValidationError("Email is already in use.")        
        return data

    def create(self, validated_data):
        user = CustomUser.objects.create_user(**validated_data)
        return user
    
        # print('vali: ', data)
        # return data

    def save(self, request):
        user = super().save(request)
        user.name = self.validated_data.get('name')
        user.nickname = self.validated_data.get('nickname')
        user.birthdate = self.validated_data.get('birthdate')
        user.save()
        return user
    
class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = CustomUser
        fields = ['username', 'email', 'name', 'nickname', 'birthdate']

# class PasswordChangeSerializer(serializers.Serializer):
#     old_password = serializers.CharField(required=True)
#     new_password = serializers.CharField(required=True)

#     def validate_new_password(self, value):
#         validate_password(value)
#         return value
    
class UserUpdateSerializer(serializers.Serializer):
    email = serializers.CharField(required=True)
    name = serializers.CharField(required=True)
    nickname = serializers.CharField(required=True)
    birthdate = serializers.CharField(required=True)
    current_password = serializers.CharField(required=False)
    new_password = serializers.CharField(required=False)

    def validate_nickname(self, value):
        user = self.context['request'].user
        if CustomUser.objects.filter(nickname=value).exclude(id=user.id).exists():
            raise serializers.ValidationError("Nickname is already in use.")
            # raise serializers.ValidationError({"Nickname": "Nickname is already in use."})
        return value

    def validate_email(self, value):
        user = self.context['request'].user
        if CustomUser.objects.filter(email=value).exclude(id=user.id).exists():
            raise serializers.ValidationError("Email is already in use.")
            # raise serializers.ValidationError({"email": "email is already in use."})
        return value
    
    def validate_current_password(self, value):
        if value:
            user = self.context['request'].user
            if not user.check_password(value):
                # raise serializers.ValidationError({"current_password1": "Current password is incorrect."})
                raise serializers.ValidationError("Current password is incorrect.")
        return value

    def validate(self, data):
        if data.get('new_password') and not data.get('current_password'):
            raise serializers.ValidationError("Current password is required to set a new password.")
            # raise serializers.ValidationError({"current_password2": "Current password is required to set a new password."})
        return data

    def update(self, instance, validated_data):
        instance.email = validated_data.get('email', instance.email)
        instance.name = validated_data.get('name', instance.name)
        instance.nickname = validated_data.get('nickname', instance.nickname)
        instance.birthdate = validated_data.get('birthdate', instance.birthdate)
        if 'new_password' in validated_data:
            instance.set_password(validated_data['new_password'])
        instance.save()
        return instance
    
class UsernameCheckSerializer(serializers.Serializer):
    username = serializers.CharField()