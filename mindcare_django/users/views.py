# from rest_framework import generics, permissions
# from .models import User
# from .serializers import UserProfileSerializer

# class UserProfileView(generics.RetrieveUpdateAPIView):
#     queryset = User.objects.all()
#     serializer_class = UserProfileSerializer
#     permission_classes = [permissions.IsAuthenticated]

#     def get_object(self):
#         return self.request.user


# 최희정 추가
from .serializers import CustomRegisterSerializer
from dj_rest_auth.registration.views import RegisterView
from rest_framework_simplejwt.tokens import RefreshToken

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.contrib.auth import authenticate, login
from dj_rest_auth.views import LoginView

from rest_framework_simplejwt.tokens import RefreshToken
from dj_rest_auth.views import LoginView
from rest_framework.permissions import IsAuthenticated
from .serializers import UserSerializer, UserUpdateSerializer
from django.contrib.auth import update_session_auth_hash

# class CustomRegisterView(RegisterView):
    # def get_response_data(self, user):
    #     data = super().get_response_data(user)
    #     refresh = RefreshToken.for_user(user)
    #     data['refresh'] = str(refresh)
    #     data['access'] = str(refresh.access_token)
    #     return data

class CustomRegisterView(RegisterView):
    serializer_class = CustomRegisterSerializer

    def create(self, request, *args, **kwargs):
        print("#"*50)
        print(request.data)
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        print('*'*20)
        print(serializer.validated_data)  # 유효성 검사 후 데이터 확인
        user = self.perform_create(serializer)


        if user is None:
            print("User creation failed")
        else:
            print("User created successfully:", user)

        headers = self.get_success_headers(serializer.data)
        data = self.get_response_data(user)
        return Response(data, status=status.HTTP_201_CREATED, headers=headers)

    def perform_create(self, serializer):
        user = serializer.save(self.request)
        return user
    


class CustomLoginView(LoginView):
    def post(self, request, *args, **kwargs):
        username = request.data.get("username")
        password = request.data.get("password")
        user = authenticate(request, username=username, password=password)
        if user is not None:
            login(request, user)
            refresh = RefreshToken.for_user(user)
            return Response({
                'status': 'success',
                'access_token': str(refresh.access_token),
                'refresh_token': str(refresh),
            }, status=status.HTTP_200_OK)
        return Response({'status': 'error', 'message': 'Invalid credentials'}, status=status.HTTP_401_UNAUTHORIZED)
    
class LogoutView(APIView):
    permission_classes = (IsAuthenticated,)

    def post(self, request):
        try:
            request.user.auth_token.delete()
        except:
            pass
        return Response({"detail": "Successfully logged out."}, status=status.HTTP_200_OK)

# 회원정보 가져오기
class UserInfoView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user
        serializer = UserSerializer(user)
        return Response(serializer.data)

# 회원 탈퇴
class UserDeleteView(APIView):
    permission_classes = [IsAuthenticated]

    def delete(self, request):
        user = request.user
        user.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)
    
# class PasswordChangeView(APIView):
#     permission_classes = [IsAuthenticated]

#     def post(self, request):
#         serializer = PasswordChangeSerializer(data=request.data)
#         user = request.user
#         if serializer.is_valid():
#             if not user.check_password(serializer.validated_data['old_password']):
#                 return Response({"old_password": ["Wrong password."]}, status=status.HTTP_400_BAD_REQUEST)
#             user.set_password(serializer.validated_data['new_password'])
#             user.save()
#             update_session_auth_hash(request, user)  # 세션 유지
#             return Response(status=status.HTTP_204_NO_CONTENT)
#         return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class UserUpdateView(APIView):
    permission_classes = [IsAuthenticated]

    def put(self, request):
        user = request.user
        serializer = UserUpdateSerializer(data=request.data, context={'request': request})
        if serializer.is_valid():
            serializer.update(user, serializer.validated_data)
            update_session_auth_hash(request, user)  # 세션 유지
            return Response(UserSerializer(user).data)
        print(serializer.errors)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)