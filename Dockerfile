FROM ruby:2.6.5-alpine

RUN apk add --upgrade libsodium alpine-sdk

ADD . /app

WORKDIR /app

RUN bundle
