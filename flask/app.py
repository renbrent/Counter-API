from flask import Flask, jsonify, request

app = Flask(__name__)
counter = 0

@app.route('/counter', methods=['GET'])
def get_counter():
    return jsonify(counter=counter)

@app.route('/counter', methods=['POST'])
def add_counter():
    global counter
    counter += 1
    return jsonify(counter=counter)

@app.route('/counter', methods=['DELETE'])
def delete_counter():
    global counter
    counter = 0
    return '', 204


if __name__ == '__name__':
    app.run(host='0.0.0.0', port=5000)
