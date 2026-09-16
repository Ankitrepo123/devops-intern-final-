FROM nginx:1.27-alpine

ARG BUILD_SHA=unknown

RUN mkdir -p /var/cache/nginx /var/log/nginx /var/run \
    && chown -R nginx:nginx /var/cache/nginx /var/log/nginx /var/run /usr/share/nginx/html

COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html /usr/share/nginx/html/index.html

RUN sed -i "s/BUILD_SHA_PLACEHOLDER/${BUILD_SHA}/g" /usr/share/nginx/html/index.html \
    && chown nginx:nginx /usr/share/nginx/html/index.html

USER nginx

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD wget -q -O - http://127.0.0.1:8080/healthz >/dev/null || exit 1

CMD ["nginx", "-g", "daemon off;"]

