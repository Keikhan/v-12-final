#!/usr/bin/env bash
# exit on error
set -o errexit

echo "Starting build process..."

# Print environment information
echo "Python version:"
python --version
echo "Current directory: $(pwd)"
echo "Directory contents:"
ls -la

# Install dependencies
echo "Installing dependencies..."
pip install -r requirements.txt
echo "Installed packages:"
pip list

# Create necessary directories
echo "Creating directories..."
mkdir -p staticfiles
mkdir -p media

# Set proper permissions
echo "Setting permissions..."
chmod -R 755 staticfiles
chmod -R 755 media

# Collect static files
echo "Collecting static files..."
python manage.py collectstatic --no-input || {
    echo "Warning: collectstatic failed, but continuing..."
}

# Make migrations
echo "Making migrations..."
python manage.py makemigrations

# Apply migrations
echo "Applying migrations..."
python manage.py migrate

# Create superuser
echo "Creating superuser..."
python manage.py shell << END
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(username='admin').exists():
    User.objects.create_superuser('admin', 'admin@example.com', 'admin')
END

# Final directory check
echo "Final directory structure:"
ls -la
echo "Static files directory:"
ls -la staticfiles/
echo "Media directory:"
ls -la media/

echo "Build process completed."
