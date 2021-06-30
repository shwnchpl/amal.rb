#!/bin/bash

cc -I./include/ ./src/foo.c ./src/bar.c ./src/main.c \
    ./src/bas/bas.c -o ./sample.separate
cc ./sample-amalgam.c -o ./sample.amalgam
