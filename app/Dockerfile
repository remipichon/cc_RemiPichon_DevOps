FROM node:12.13.1-alpine3.10

ADD api/ /root/
WORKDIR /root
RUN npm install

EXPOSE 3000

CMD node server.js
