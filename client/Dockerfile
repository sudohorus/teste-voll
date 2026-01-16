FROM node:16

WORKDIR /app

RUN mkdir -p /app/node_modules && chown -R node:node /app

USER node

COPY --chown=node:node package*.json ./
RUN npm install

COPY --chown=node:node . .

EXPOSE 8080

CMD ["npm", "run", "serve"]
