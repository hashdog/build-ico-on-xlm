FROM ruby:2.6.5-alpine

RUN apk add --upgrade libsodium alpine-sdk

RUN gem install stellar-sdk

ADD . /app

WORKDIR /app

RUN cd horizon-wrapper/ && bundle
