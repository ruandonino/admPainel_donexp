# STEP 1 building your app
FROM node:alpine as builder
RUN apk update && apk add --no-cache make git
# a) Create app directory
WORKDIR /app
# b) Create app/nginx directory and copy default.conf to it
WORKDIR /app/nginx
COPY nginx/conf.d/default.conf /app/nginx/
# c) Install app dependencies
COPY package.json package-lock.json /app/
RUN cd /app && npm set progress=false && npm install
# d) Copy project files into the docker image and build your app
COPY .  /app

#RUN cd /app/node_modules/admin-lte/plugins/overlayScrollbars/css && ls
#RUN cd /app && npm install admin-lte@^3.1 && npm run ng build 
RUN cd /app && ls && npm run ng build --prod

# STEP 2 build a small nginx image
FROM nginx:alpine
# a) Remove default nginx code
RUN rm -rf /usr/share/nginx/html/*
# b) From 'builder' copy your site to default nginx public folder
COPY --from=builder /app/dist/adminLTE-app /usr/share/nginx/html
# c) copy your own default nginx configuration to the conf folder
RUN rm -rf /etc/nginx/conf.d/default.conf
COPY --from=builder /app/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]