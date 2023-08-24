#!/bin/sh

docker run --rm -v $PWD/out:/out sebas369/treegen /treegen -o /out "$@"
