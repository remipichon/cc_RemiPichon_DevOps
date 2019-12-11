FROM node:12.13.1-alpine3.10

# first add package to resolve dependecies on a separate layer
ADD api/package.json /root/package.json
WORKDIR /root
RUN npm install

# then add the whole app
ADD api/ /root/

EXPOSE 3000

CMD node server.js
