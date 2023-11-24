FROM ubuntu:20.04
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
 && rm -rf /var/lib/apt/lists/* 
RUN groupadd -r webapp && useradd -r -g webapp webapp # -r creates system accounts
WORKDIR /webapp
COPY . .
RUN pip install -r requirement.txt
USER webapp
EXPOSE 5000
CMD ["python3", "app.py"]