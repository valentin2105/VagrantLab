# syntax=docker/dockerfile:1
FROM reg.ntl.nc/proxy/library/python:3.9-alpine
WORKDIR /code
ADD requirements.txt requirements.txt
RUN pip install -r requirements.txt
ADD . /code
CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0"]
