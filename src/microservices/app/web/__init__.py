import requests
from flask import Flask, jsonify, render_template
import time

app = Flask(__name__)


@app.route('/')
def index():
    return jsonify({
        "message": "Automate all the things!",
        "timestamp": int(time.time())
    })
