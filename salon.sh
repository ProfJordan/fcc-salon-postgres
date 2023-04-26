#!/bin/bash

# # Log into psql and create 'salon' database
# psql --username=freecodecamp --dbname=postgres << EOF
# CREATE DATABASE salon;
# EOF

# # Connect to 'salon' database and create tables
# psql --username=freecodecamp --dbname=salon << EOF
# CREATE TABLE customers (
#     customer_id SERIAL PRIMARY KEY,
#     name VARCHAR,
#     phone VARCHAR UNIQUE
# );

# CREATE TABLE services (
#     service_id SERIAL PRIMARY KEY,
#     name VARCHAR UNIQUE
# );

# CREATE TABLE appointments (
#     appointment_id SERIAL PRIMARY KEY,
#     customer_id INTEGER REFERENCES customers(customer_id),
#     service_id INTEGER REFERENCES services(service_id),
#     time VARCHAR
# );

# INSERT INTO services (name) VALUES
# ('cut'),
# ('color'),
# ('perm'),
# ('style'),
# ('trim');
# EOF

# Display numbered list of services offered
# echo "Services offered:"
# psql --username=freecodecamp --dbname=salon --tuples-only --command "SELECT CAST(service_id AS integer), name FROM services" | while read row; do
#     service_id=$(echo $row | awk '{print $1}')
#     service_name=$(echo $row | awk '{print $2}')
#     echo "$service_id) $service_name"
# done

# Display numbered list of services offered
# echo "Services offered:"
# for service_id in $(psql --username=freecodecamp --dbname=salon --tuples-only --command "SELECT service_id FROM services WHERE service_id <= 5 ORDER BY service_id"); do
#     service_name=$(psql --username=freecodecamp --dbname=salon --tuples-only --command "SELECT name FROM services WHERE service_id = $service_id")
#     echo "$service_id) $service_name"
# done

PSQL="psql --username=freecodecamp --dbname=salon -t -A -c"

# Display numbered list of services offered
echo "Services offered:"
for service_id in $($PSQL "SELECT service_id FROM services WHERE service_id <= 5 ORDER BY service_id"); do
    service_name=$($PSQL "SELECT TRIM(name) FROM services WHERE service_id = $service_id")
    echo "$service_id) $service_name"
done

# Prompt user for inputs
read -p "Enter the service ID you would like: " SERVICE_ID_SELECTED
while ! [[ "$SERVICE_ID_SELECTED" =~ ^[1-5]$ ]]; do
    echo "Invalid service ID. Please choose a number between 1 and 5."
    read -p "Enter the service ID you would like: " SERVICE_ID_SELECTED
done

read -p "Enter your phone number: " CUSTOMER_PHONE
while ! [[ "$CUSTOMER_PHONE" =~ ^[0-9]{10}$ ]]; do
    echo "Invalid phone number. Please enter a 10-digit phone number with no spaces or dashes."
    read -p "Enter your phone number: " CUSTOMER_PHONE
done

CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
if [ -z "$CUSTOMER_ID" ]; then
    read -p "Enter your name: " CUSTOMER_NAME
    $PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')"
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
fi

read -p "Enter the appointment time: " SERVICE_TIME

# Add appointment to database
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
$PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')"

# Output success message
echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
