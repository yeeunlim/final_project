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
from .serializers import UserSerializer, UserUpdateSerializer, UsernameCheckSerializer
from django.contrib.auth import update_session_auth_hash
from .models import CustomUser
from rest_framework.permissions import AllowAny

class CustomRegisterView(RegisterView):
    serializer_class = CustomRegisterSerializer

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        if not serializer.is_valid():
            print("Validation failed:", serializer.errors)
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
        user = self.perform_create(serializer)

        if user is None:
            print("User creation failed")
        else:
            print("User created successfully:", user)

        headers = self.get_success_headers(serializer.data)
        data = self.get_response_data(user)
        return Response(data, status=status.HTTP_201_CREATED, headers=headers)

    def perform_create(self, serializer):
        user = serializer.save(request=self.request)
        return user
    
# class CustomRegisterView(RegisterView):
#     serializer_class = CustomRegisterSerializer

#     def create(self, request, *args, **kwargs):
#         serializer = self.get_serializer(data=request.data)
#         serializer.is_valid(raise_exception=True)
#         user = self.perform_create(serializer)


#         if user is None:
#             print("User creation failed")
#         else:
#             print("User created successfully:", user)

#         headers = self.get_success_headers(serializer.data)
#         data = self.get_response_data(user)
#         return Response(data, status=status.HTTP_201_CREATED, headers=headers)

#     def perform_create(self, serializer):
#         user = serializer.save(self.request)
#         return user
    


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




class CheckUserNameView(APIView):
    permission_classes = [AllowAny]  # 이 뷰는 인증이 필요하지 않습니다.

    def post(self, request):
        serializer = UsernameCheckSerializer(data=request.data)
        if serializer.is_valid():
            username = serializer.validated_data['username']
            if CustomUser.objects.filter(username=username).exists():
                return Response({'available': False}, status=status.HTTP_200_OK)
            else:
                return Response({'available': True}, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)