#!/bin/bash

protoc --elixir_out=plugins=grpc:./ ./lib/saga/application/*.proto