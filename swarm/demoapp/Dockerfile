# syntax=docker/dockerfile:1
FROM reg.ntl.nc/library/python:3.9-alpine
ADD . /code
WORKDIR /code
RUN pip install -r requirements.txt
CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0"]

