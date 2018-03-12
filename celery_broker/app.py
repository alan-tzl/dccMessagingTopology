# -*- coding: utf-8 -*-
from flask import Flask, request, Response
from celery import Celery
from email.mime.text import MIMEText

import json
import smtplib
import requests

app = Flask(__name__)

# config. of celery with redis
app.config['CELERY_BROKER_URL'] = 'redis://172.99.0.2:6379/0'
app.config['CELERY_RESULT_BACKEND'] = 'redis://172.99.0.2:6379/0'
celery = Celery(app.name, broker=app.config['CELERY_BROKER_URL'])
celery.conf.update(app.config)

@celery.task()
def send_async_email(email_msg):
    ''' Background task to send an email with Flask-Mail. '''
    with app.app_context():
        # 1.
        msg = MIMEText('Testing some Mailgun awesomness by flask-based celery app')
        msg['Subject'] = "Flask Data Pipeline (Background Job)"
        msg['From']    = "Catalina Labs <gogistics@gogistics-tw.com>"
        msg['To']      = "<destination-email-1>, <destination-email-2>"
        s = smtplib.SMTP('smtp.mailgun.org', 587)
        s.login('postmaster@gogistics-tw.com', '<pwd>')
        s.sendmail(msg['From'], msg['To'], msg.as_string())
        s.quit()

        # 2.
        # resp = requests.post(
        #     "https://api.mailgun.net/v3/gogistics-tw.com/messages",
        #     auth=("api", "<api-key>"),
        #     data={"from": "Catalina Labs <mailgun@gogistics-tw.com>",
        #           "to": ["<destination-email-1>", "<destination-email-2>"],
        #           "subject": "Flask Data Pipeline",
        #           "text": "Testing some flask-based data pipeline!"})
        # app.logger.info(resp.text)

@app.route('/')
def default():
    msg ={'hello': 'flask'}
    send_async_email.delay(json.dumps(msg))
    return 'Dockerized flask-based Celery...'

@app.route('/dilbert', methods=['GET', 'POST'])
def dilbert():
    if request.method == 'POST':
        username = request.values.get('user', 'NA')
        pwd = request.values.get('pwd', 'NA')

        message = {'username': username, 'pwd': pwd}
        resp = Response(response = json.dumps(message), status = 200, mimetype = 'application/json')
        return resp
    else:
        name = request.args.get('name', 'NA')

        message = {'name': name}
        resp = Response(response = json.dumps(message), status = 200, mimetype = 'application/json')
        return resp

if __name__ == '__main__':
    app.run(debug=True,host='0.0.0.0',port=8080)