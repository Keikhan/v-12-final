#!/usr/bin/env bash
# exit on error
set -o errexit

# Install dependencies
pip install -r requirements.txt

# Create necessary directories
mkdir -p staticfiles
mkdir -p media

# Set proper permissions
chmod -R 755 staticfiles
chmod -R 755 media

# Collect static files (with error handling)
python manage.py collectstatic --no-input || {
    echo "Warning: collectstatic failed, but continuing..."
}

# Make migrations
python manage.py makemigrations

# Apply migrations
python manage.py migrate

# Create superuser if it doesn't exist
python manage.py shell << END
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(username='admin').exists():
    User.objects.create_superuser('admin', 'admin@example.com', 'admin')
END

# Print environment for debugging
echo "Current directory: $(pwd)"
echo "Directory contents:"
ls -la
echo "Python version:"
python --version
echo "Installed packages:"
pip list
