FROM node:18-alpine AS build
WORKDIR /app
COPY . .

# 构建时注入环境变量（由 docker-compose 传参，覆盖 .env 默认值）
ARG VUE_APP_SUBCONVERTER_DEFAULT_BACKEND
ARG VUE_APP_MYURLS_DEFAULT_BACKEND
ENV VUE_APP_SUBCONVERTER_DEFAULT_BACKEND=$VUE_APP_SUBCONVERTER_DEFAULT_BACKEND
ENV VUE_APP_MYURLS_DEFAULT_BACKEND=$VUE_APP_MYURLS_DEFAULT_BACKEND

RUN yarn install
RUN yarn build

FROM nginx:1.24-alpine
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD [ "nginx", "-g", "daemon off;" ]
