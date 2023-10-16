FROM python:3.8-alpine

RUN pip install --upgrade pip 
RUN apk add curl --no-cache # for health checks 
RUN addgroup -S webapp && adduser -S -G webapp webapp # -r creates system accounts

COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt 

WORKDIR /app
COPY . /app/
VOLUME [ "/app" ]

USER webapp
EXPOSE 5000
CMD ["python3", "app.py"]

