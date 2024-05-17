FROM python:3.11.9-slim

WORKDIR /flask

COPY app.py .

RUN pip install flask

CMD ["flask", "run", "--debug"]
