#!/bin/bash

# Check if the desired number of replicas is passed
if [ -z "$1" ]; then
  echo "Usage: $0 <number_of_replicas>"
  exit 1
fi

# Scale the API service
docker-compose up -d --scale app=$1
