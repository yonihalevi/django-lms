#!/bin/bash

# Load base env variables
if [ -f ".env.example" ]; then
  export $(cat .env.example | xargs)
else
  echo "Missing .env.example"
  exit 1
fi

# Set default values for required variables if not present
export DJANGO_SUPERUSER_USERNAME=${DJANGO_SUPERUSER_USERNAME:-admin}
export DJANGO_SUPERUSER_EMAIL=${DJANGO_SUPERUSER_EMAIL:-admin@example.com}
export DJANGO_SUPERUSER_PASSWORD=${DJANGO_SUPERUSER_PASSWORD:-admin@1}

#create env
python3.8 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip && pip install -r requirements.txt 

# Export updated environment pointing to Minikube services
export DB_HOST=$(minikube ip)
export DB_PORT="3$DB_PORT"
export REDIS_URL="redis://localhost:6379/0"

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
