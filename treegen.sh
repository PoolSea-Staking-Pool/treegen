#!/bin/sh

docker run --rm -v $PWD/out:/out vunderwaffle/treegen /treegen -o /out "$@"
