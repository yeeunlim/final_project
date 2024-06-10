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
    
# class CustomLoginView(LoginView):
#     def post(self, request, *args, **kwargs):
#         username = request.data.get("username")
#         password = request.data.get("password")
#         user = authenticate(request, username=username, password=password)
#         if user is not None:
#             login(request, user)
#             refresh = RefreshToken.for_user(user)
#             return Response({'status': 'success', 'access_token': str(refresh.access_token)}, status=status.HTTP_200_OK)
#         return Response({'status': 'error', 'message': 'Invalid credentials'}, status=status.HTTP_401_UNAUTHORIZED)


from rest_framework_simplejwt.tokens import RefreshToken
from dj_rest_auth.views import LoginView
from rest_framework.permissions import IsAuthenticated

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