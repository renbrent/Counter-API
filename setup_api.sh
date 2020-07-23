#!/user/bin/env bash
#
# Nginx and REST API

# Spawns REST_API servers
echo "Building REST_API servers..."
for ((i = 1; i <= $1; i++)); do
# Create directory for REST_API.py servers
mkdir host$i
# Create REST_API python file
cat > host$i/host$i.py << EOF
import threading,time, uuid
from flask import Flask, jsonify, request
from flask_uuid import FlaskUUID

counter_uuid = ""

info = {
    "hostname": "host$i"
}

host_counter = {
    "counter": 1,
    "to": 0
}

stop_thread = False

app = Flask(__name__)
FlaskUUID(app)

# HTTP GET / will return hostname
@app.route("/", methods=["GET"])
def host():
    return jsonify(info["hostname"])

# HTTP POST to send the counter limit
@app.route("/counter", methods=["POST", "GET"])
def counter():
    global counter_uuid
    to = request.args.get('to', default = -1, type = int)
    if to >= 0:
        host_counter["to"] = to
        threading.Thread(target=counting).start()
        counter_uuid = uuid.uuid4()
        return str(counter_uuid)
    elif to == -1 and counter_uuid != "":
        return str(counter_uuid)
    else:
        return "Invalid Number"

# With the generated UUID the app returns a json object
@app.route("/counter/<uuid:counter_uuid>")
def count(counter_uuid):
    return jsonify(host_counter)

# Threading function that counts every second
def counting():
    global host_counter
    global stop_thread
    while True:
        host_counter["counter"] += 1
        if host_counter["counter"] >= host_counter["to"]:
            host_counter["counter"] = 1
        time.sleep(1)
        if stop_thread:
            break

# Stop Thread and reset counter
@app.route("/counter/<uuid:counter_uuid>/stop")
def stop(counter_uuid):
    global stop_thread
    global host_counter
    stop_thread = True
    host_counter = {
        "counter": 1,
        "to": 0
    }
    return jsonify(host_counter)


if __name__ == "__main__":
    app.run(host="0.0.0.0")
EOF

# Create Dockerfile
cat > host$i/Dockerfile << EOF
FROM python:3
EXPOSE 5000
WORKDIR /host$i
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD python ./host$i.py 
EOF

cat > host$i/requirements.txt << EOF
flask
Flask-UUID
EOF
done

echo "Building Nginx Config File"
# Create NGINX config file
mkdir nginx
cat > nginx/nginx.conf << EOF
worker_processes 1;
pid /run/nginx.pid;
events {}
http {
    upstream host {
$(for ((i = 1; i <= $1; i++)); do
echo "        server host${i};"
echo "        server home_host${i}_1:5000;"  
done
) 
    }
    server {
        listen 80;

        server_name host.com;

        location / {
            proxy_pass http://host;
        }
    }
}

EOF

# Create NGINX docker
cat > nginx/Dockerfile << EOF
FROM nginx
RUN rm /etc/nginx/conf.d/default.conf
COPY ./nginx.conf /etc/nginx/nginx.conf
EOF

echo "Building docker-compose.yml"
# Create docker compose file
cat > docker-compose.yml << EOF
version: '3'

services:
    nginx:
        build: nginx
        container_name: nginx
        depends_on:
$(for ((i=1;i<=$1;i++)); do
echo "            - host$i"
done
)
        ports:
            - 80:80
$(for ((i=1;i<=$1;i++)); do
echo "    host$i:"
echo "      build: host$i"
done
)
EOF

echo "Done"
read