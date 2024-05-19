FROM python:3.11.9-slim

WORKDIR /flask

COPY app.py .

RUN pip install flask && apt-get update && apt-get install -y curl

CMD ["flask", "run", "--host=0.0.0.0"]
