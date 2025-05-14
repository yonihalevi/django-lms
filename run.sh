#!/bin/bash

# Load base env variables
if [ -f ".env.example" ]; then
  source .env.example
else
  echo "Missing .env.example"
  exit 1
fi

# Export variables for Docker Compose and Django
export DB_NAME=$DB_NAME
export DB_USER=$DB_USER
export DB_PASSWORD=$DB_PASSWORD
export DJANGO_SUPERUSER_USERNAME=admin
export DJANGO_SUPERUSER_EMAIL=admin@example.com
export DJANGO_SUPERUSER_PASSWORD=admin@1
export EMAIL_HOST_USER=EMAIL_HOST_USER
export EMAIL_HOST_PASSWORD=EMAIL_HOST_PASSWORD
export EMAIL_HOST=$EMAIL_HOST
export EMAIL_PORT=$EMAIL_PORT
export EMAIL_USE_TLS=$EMAIL_USE_TLS
export EMAIL_FROM_ADDRESS=$EMAIL_FROM_ADDRESS

#create env
python3.8 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip && pip install -r requirements.txt 

# Get Minikube IP
MINIKUBE_IP=$(minikube ip)

# Export updated environment pointing to Minikube services
export DB_HOST=localhost
export REDIS_URL="redis://10.107.206.119:6379/0"

# Optional: Echo what's going on
echo "Connecting to PostgreSQL at $DB_HOST:5432"
echo "Using Redis at $REDIS_URL"

# Run Django migrations
echo "Running Django migrations..."
python manage.py migrate
# Create superuser if needed
echo "Creating superuser..."
python manage.py createsuperuser --noinput || echo "Superuser may already exist."



# Run development server
echo "Starting Django development server..."
python manage.py runserver
