#!/bin/bash

# Step 1: Create a Python 3.8 virtual environment named 'venv'
echo "Creating Python 3.8 virtual environment..."
python3.8 -m venv venv

# Step 2: Activate the virtual environment
echo "Activating virtual environment..."
source venv/bin/activate

# Step 3: Install requirements.txt in the virtual environment
echo "Installing packages from requirements.txt..."
pip install -r requirements.txt

# Step 4: Run docker-compose up -d
echo "Starting Docker containers..."
docker-compose up -d

# Step 5: Create a Postgres database called dj_lms
echo "Waiting for PostgreSQL to start..."
sleep 10  # Wait for the database container to be fully ready
echo "Creating database dj_lms..."
docker exec -it $(docker-compose ps -q db) psql -U postgres -c "CREATE DATABASE dj_lms;"

# Step 6: Run Django migrations
cp .env.example .env
echo "Running Django migrations..."
python manage.py migrate

# Step 7: Create a Django superuser with username 'admin' and password 'admin@1'
echo "Creating Django superuser..."
echo "from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.filter(username='admin').exists() or User.objects.create_superuser('admin', 'admin@example.com', 'admin@1')" | python manage.py shell

# Step 8: Inform the user to start the Django server
echo "Setup complete! You can now start the Django server with the following command:"
echo "source venv/bin/activate && python manage.py runserver"
