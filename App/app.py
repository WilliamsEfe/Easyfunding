from flask import Flask
from datetime import datetime

app = Flask(__name__)


@app.route('/')
def home():
    current_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    return ('Current date and time: ' +
            current_time)


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
