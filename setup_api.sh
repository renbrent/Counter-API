#!/bin/bash

docker build -t app ./flask

docker compose up -d