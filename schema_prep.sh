#!/bin/bash
yum -y install unzip
cd /home/ec2-user && \
curl -fSL https://github.com/AstunTechnology/iso19139.gemini23/archive/3.10.x.zip -o gemini.zip && \
mkdir schemas && \
unzip gemini.zip -d schemas