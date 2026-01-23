FROM amacneil/dbmate:2.29

WORKDIR /app

RUN apk add --no-cache bash

COPY run.sh .
RUN chmod +x run.sh

COPY --chown=1000:1000 ./migrations /app/migrations

USER 1000

ENTRYPOINT ["./run.sh"]
