FROM node:15.11.0-alpine3.10

WORKDIR /app/

COPY package.json /app/package.json
RUN npm install
RUN npm install @vue/cli@3.7.0 -g
COPY . /app

EXPOSE 8080
CMD ["npm", "run", "serve"]