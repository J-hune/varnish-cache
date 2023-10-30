#!/bin/bash

# Read variables from the .env file
if [ -f .env ]; then
  source .env
else
  echo "The .env file does not exist."
  exit 1
fi

# Check if the BACKEND_DOMAIN_NAME and BACKEND_PORT variables are defined
if [ -z "$BACKEND_DOMAIN_NAME" ] || [ -z "$BACKEND_PORT" ]; then
  echo "The BACKEND_DOMAIN_NAME and BACKEND_PORT variables must be defined in the .env file."
  exit 1
fi

# Remove unwanted line breaks
BACKEND_DOMAIN_NAME=$(echo "$BACKEND_DOMAIN_NAME" | tr -d '\n\r')

# Create the default.vcl file with the desired content
cat <<EOF > default.vcl
vcl 4.1;

backend default {
    .host = "$BACKEND_DOMAIN_NAME";
    .port = "$BACKEND_PORT";
}
EOF

echo "The default.vcl file has been successfully created."

# Launch docker-compose
docker compose up