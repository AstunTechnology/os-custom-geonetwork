FROM maven:3.8-amazoncorretto-8

RUN apt-get update && apt-get install -y firefox wget

RUN wget https://github.com/mozilla/geckodriver/releases/download/v0.31.0/geckodriver-v0.31.0-linux64.tar.gz -O geckodriver.tar.gz
RUN tar xzvf geckodriver.tar.gz
RUN rm geckodriver.tar.gz

RUN mv geckodriver /usr/bin/geckodriver

