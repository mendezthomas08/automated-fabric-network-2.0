FROM node:12.22
WORKDIR /usr/src/app
COPY . .
RUN apt-get update || : && apt-get install python -y
RUN npm install
EXPOSE 4000
CMD node app.js