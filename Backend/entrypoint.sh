#!/bin/sh

echo "Running database migrations..."
python manage.py migrate

echo "Checking superuser..."

#Check if a superuser exists

python manage.py shell -c "
from conduit.apps.authentication.models import User
import os
if not User.objects.filter(is_superuser=True).exists():
    User.objects.create_superuser(
        'admin', 
        'admin@example.com',
        os.environ.get('DJANGO_SUPERUSER_PASSWORD', 'securepass')
        )
        "

echo "Starting application..."
exec gunicorn --bind 0.0.0.0:8000 conduit.wsgi:application