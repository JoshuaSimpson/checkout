FROM node:15.11.0-alpine3.10

WORKDIR /app/

COPY package.json /app/package.json
RUN npm install

#nodemon for hot reloading
RUN npm install nodemon -g
COPY . /app

EXPOSE 3000
CMD [ "nodemon", "-L", "index.js", "3000" ]