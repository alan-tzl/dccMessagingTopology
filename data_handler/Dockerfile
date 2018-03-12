FROM ubuntu:latest

LABEL maintainer "alan.tai@teamzerolabs.com"

# copy required files into img
COPY ./data_handler /app
COPY ./scripts/dumb-init /usr/bin/dumb-init

# run operations
RUN apt-get update -y && \
  apt-get install -y curl python-pip python-dev build-essential && \
  pip install --upgrade pip && \
  cd /app && pip install -r requirements.txt && \
  chmod +x /usr/bin/dumb-init

WORKDIR /app
EXPOSE 8080
ENTRYPOINT ["/usr/bin/dumb-init", "--"]