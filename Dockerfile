FROM ruby:2.6.5-alpine

RUN apk add --upgrade libsodium alpine-sdk

RUN gem install stellar-sdk

RUN cd /app/horizon-wrapper/ && bundle

ADD . /app

WORKDIR /app
