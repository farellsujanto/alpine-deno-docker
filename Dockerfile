FROM frolvlad/alpine-glibc:alpine-3.11_glibc-2.31

ENV DENO_VERSION=1.0.5

RUN apk add --virtual .download --no-cache curl \
 && curl -fsSL https://github.com/denoland/deno/releases/download/v${DENO_VERSION}/deno-x86_64-unknown-linux-gnu.zip \
         --output deno.zip \
 && unzip deno.zip \
 && rm deno.zip \
 && chmod 777 deno \
 && mv deno /bin/deno \
 && apk del .download

RUN addgroup -g 1993 -S deno \
 && adduser -u 1993 -S deno -G deno \
 && mkdir /deno-dir/ \
 && chown deno:deno /deno-dir/

ENV DENO_DIR /deno-dir/
ENTRYPOINT ["deno"]

EXPOSE 1993

WORKDIR /app

USER deno

COPY deps.ts .
RUN deno cache deps.ts

COPY main.ts .
ADD . .
RUN deno cache main.ts

CMD ["run", "--allow-net", "main.ts"]