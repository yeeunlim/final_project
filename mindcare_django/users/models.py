from django.contrib.auth.models import AbstractUser
from django.db import models

# class User(AbstractUser):
#     email = models.EmailField(unique=True)

#     USERNAME_FIELD = 'email'
#     REQUIRED_FIELDS = []

# 최희정 수정
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager
from django.db import models

class CustomUserManager(BaseUserManager):
    def create_user(self, username, email, name, nickname, birthdate, password=None):
        if not username:
            raise ValueError('Users must have a username')
        if not email:
            raise ValueError('Users must have an email address')

        user = self.model(
            username=username,
            email=self.normalize_email(email),
            name=name,
            nickname=nickname,
            birthdate=birthdate,
        )

        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, username, email, name, nickname, birthdate, password=None):
        user = self.create_user(
            username=username,
            email=email,
            name=name,
            nickname=nickname,
            birthdate=birthdate,
            password=password,
        )
        user.is_admin = True
        user.save(using=self._db)
        return user


class CustomUser(AbstractBaseUser):
    id = models.AutoField(primary_key=True)
    username = models.CharField(max_length=30, unique=True)
    email = models.EmailField(unique=True)
    name = models.CharField(max_length=50)
    nickname = models.CharField(max_length=30, unique=True)
    birthdate = models.CharField(max_length=8, help_text="8자리로 입력하세요")

    is_active = models.BooleanField(default=True)
    is_admin = models.BooleanField(default=False)

    objects = CustomUserManager()

    USERNAME_FIELD = 'username'
    REQUIRED_FIELDS = ['email', 'name', 'nickname', 'birthdate']

    def __str__(self):
        return self.username

    @property
    def is_staff(self):
        return self.is_admin
