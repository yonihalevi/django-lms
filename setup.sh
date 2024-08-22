#!/bin/bash

# Variables
DB_NAME="dj_lms"
DB_USER="postgres"
DB_PASSWORD="example"

# Export variables for Docker Compose and Django
export DB_NAME=$DB_NAME
export DB_USER=$DB_USER
export DB_PASSWORD=$DB_PASSWORD
export DJANGO_SUPERUSER_USERNAME=admin
export DJANGO_SUPERUSER_EMAIL=admin@example.com
export DJANGO_SUPERUSER_PASSWORD=admin@1

# Step 1: Create a Python 3.8 virtual environment named 'venv'
if [ ! -d "venv" ]; then
  echo "Creating Python 3.8 virtual environment..."
  python3.8 -m venv venv
else
  echo "Virtual environment already exists."
fi

# Step 2: Activate the virtual environment
echo "Activating virtual environment..."
source venv/bin/activate

# Step 3: Install requirements.txt in the virtual environment
echo "Upgrading pip to the latest version..."
pip install --upgrade pip

echo "Installing packages from requirements.txt..."
pip install -r requirements.txt

# Step 4: Run docker-compose up -d
echo "Starting Docker containers..."
docker-compose up -d

# Step 5: Wait for PostgreSQL to start and create a database
echo "Waiting for PostgreSQL to start..."
until docker exec -it $(docker-compose ps -q db) psql -U $DB_USER -c '\q' 2>/dev/null; do
  >&2 echo "PostgreSQL is unavailable - sleeping"
  sleep 3
done

echo "Creating database $DB_NAME..."
docker exec -it $(docker-compose ps -q db) psql -U $DB_USER -c "CREATE DATABASE $DB_NAME;"

# Step 6: Run Django migrations
if [ -f ".env.example" ]; then
  cp .env.example .env
  echo ".env file created from .env.example"
else
  echo "Warning: .env.example file not found."
fi

echo "Running Django migrations..."
python manage.py migrate

# Step 7: Create a Django superuser
echo "Creating Django superuser..."
python manage.py createsuperuser --noinput || {
  echo "Failed to create superuser. It may already exist."
}

# Step 8: Inform the user to start the Django server
echo "Setup complete! You can now start the Django server with the following command:"
echo "source venv/bin/activate && python manage.py runserver"
