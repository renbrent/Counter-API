#!/bin/bash

# Query all counters
for container_id in $(docker ps -q --filter "ancestor=app"); do
  echo "Container ID: $container_id"
  docker exec $container_id curl -s http://localhost:5000/counter
done
