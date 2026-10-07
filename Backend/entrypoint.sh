#!/bin/sh

echo "Waiting for PostgreSQL..."

# Try to connect to PostgreSQL every 2 seconds.
# Wait until the connection is successful before running migrations.
until python -c "
import os
import psycopg2

try:
    psycopg2.connect(
        dbname=os.environ.get('POSTGRES_DB'),
        user=os.environ.get('POSTGRES_USER'),
        password=os.environ.get('POSTGRES_PASSWORD'),
        host=os.environ.get('POSTGRES_HOST', 'database'),
        port=os.environ.get('POSTGRES_PORT', '5432')
    )
except psycopg2.OperationalError:
    raise SystemExit(1)
else:
    raise SystemExit(0)
"
do
    echo "PostgreSQL is not ready yet..."
    sleep 2
done

echo "PostgreSQL is ready."

echo "Running database migrations..."
python manage.py migrate

echo "Checking superuser..."

# Check if a superuser exists.
python manage.py shell -c "
from conduit.apps.authentication.models import User
import os

if not User.objects.filter(is_superuser=True).exists():
    User.objects.create_superuser(
        'admin',
        'admin@example.com',
        os.environ.get('DJANGO_SUPERUSER_PASSWORD')
    )
"

echo "Starting application..."
exec gunicorn --bind 0.0.0.0:8000 conduit.wsgi:application