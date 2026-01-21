FROM amacneil/dbmate:2.29

WORKDIR /app

RUN apk add --no-cache bash

COPY run.sh .
RUN chmod +x run.sh

COPY migrations ./migrations

ENTRYPOINT ["./run.sh"]
