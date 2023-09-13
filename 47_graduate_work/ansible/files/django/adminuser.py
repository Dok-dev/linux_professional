from django.contrib.auth import get_user_model
User = get_user_model()
try:
    User.objects.create_superuser('admin', 'dev@email.ru', '12345678X')
except Exception:
    print('User already exist')