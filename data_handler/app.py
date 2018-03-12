# -*- coding: utf-8 -*-
from flask import Flask, request, Response
import json

app = Flask(__name__)

@app.route('/')
def default():
    return 'Dockerized flask-based Data Handler...'

@app.route('/dilbert', methods=['GET', 'POST'])
def dilbert():
    if request.method == 'POST':
        username = request.values.get('user')
        pwd = request.values.get('pwd')

        message = {'username': username, 'pwd': pwd}
        resp = Response(response = json.dumps(message), status = 200, mimetype = 'application/json')
        return resp
    else:
        name = request.args.get('name')

        message = {'name': name}
        resp = Response(response = json.dumps(message), status = 200, mimetype = 'application/json')
        return resp

if __name__ == '__main__':
    app.run(debug=True,host='0.0.0.0',port=8080)