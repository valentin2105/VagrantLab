# DemoApp


## 2/ Create Demo App

- `mkdir demoapp/`

- `vim app.py`

```
from flask import Flask
from redis import Redis

app = Flask(__name__)
redis = Redis(host='redis', port=6379)

@app.route('/')
def hello():
    count = redis.incr('hits')
        return 'Hello World from k8s ! I have been seen {} times.\n'.format(count)

        if __name__ == "__main__":
            app.run(host="0.0.0.0", port=8000, debug=True)
```


- `vim requirements.txt`


```
flask
redis
```

- `vim Dockerfile`

```
# syntax=docker/dockerfile:1
FROM python:3.8-slim-buster
ADD . /code
WORKDIR /code
RUN pip install -r requirements.txt
CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0"]
```

