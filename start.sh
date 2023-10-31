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
BACKEND_PORT=$(echo "$BACKEND_PORT" | tr -d '\n\r')
VARNISH_TTL=$(echo "$VARNISH_TTL" | tr -d '\n\r') || "5s"
VARNISH_GRACE=$(echo "$VARNISH_GRACE" | tr -d '\n\r') || "2s"

# Create the default.vcl file with the desired content
cat <<EOF > default.vcl
vcl 4.1;

import std;

include "hit-miss.vcl";

backend default {
    .host = "$BACKEND_DOMAIN_NAME";
    .port = "$BACKEND_PORT";
}

sub vcl_backend_response {
	# We first set TTLs valid for most of the content we need to cache
	set beresp.ttl = $VARNISH_TTL;
	set beresp.grace = $VARNISH_GRACE;
}
EOF

echo "The default.vcl file has been successfully created."

# Launch docker-compose
docker compose up -d