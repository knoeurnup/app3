FROM node:8
#RUN apt-get update \
#   && apt-get install -y ffmpeg \
#    && apt-get install -y --allow-unauthenticated \
#        libc6-dev \
#        libgdiplus \
#        libx11-dev \
#     && rm -rf /var/lib/apt/lists/*

# Define build arguments
ARG APP_VERSION

WORKDIR /usr/src/app
COPY package.json ./
RUN npm install
COPY . .
EXPOSE 8080
CMD [ "node", "index.js" ]
