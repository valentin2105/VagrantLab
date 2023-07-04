# Swarm Demo

## 1/ Registre

- `docker service create --name registry --publish published=5000,target=5000 registry:2`

- `curl http://localhost:5000/v2/`

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
        return 'Hello World! I have been seen {} times.\n'.format(count)

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

- `vim docker-compose.yml`

```
  services:
  web:
    image: 127.0.0.1:5000/demoapp
    build: .
    ports:
      - "8000:8000"
  redis:
    image: redis:alpine
```


## 3/ Test Demo App

- `docker-compose up -d`

- `curl http://localhost:8000`

- `docker-compose down --volumes`


## 4/ Push app to registry

- `docker-compose push`


## 5/ Deploy app to Swarm


- `docker stack deploy --compose-file docker-compose.yml demoapp`

- `docker stack services demoapp`


## 6/ Cleanup

- `docker stack rm demoapp`

- `docker service rm registry`
