# Download a pinned CMS release at build time; no runtime CDN dependency.
FROM alpine:3.22 AS cms
ARG SVELTIA_CMS_VERSION=0.231.0
RUN apk add --no-cache curl \
    && mkdir -p /cms \
    && curl --fail --show-error --silent --location --retry 3 \
      "https://cdn.jsdelivr.net/npm/@sveltia/cms@${SVELTIA_CMS_VERSION}/dist/sveltia-cms.js" \
      --output /cms/sveltia-cms.js \
    && test -s /cms/sveltia-cms.js

FROM nginx:1.28-alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY public/ /usr/share/nginx/html/
COPY --from=cms /cms/sveltia-cms.js /usr/share/nginx/html/sveltia-cms.js
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget -q -O /dev/null http://127.0.0.1/healthz || exit 1
