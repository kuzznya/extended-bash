#!/bin/bash

./ebash init 5

for ((i=0; i < 10; i++)) ; do
  echo "Starting $i "
  ((n=i))
  ./ebash 'sleep 5s && echo '"$n"
done

./ebash wait_all

./ebash stop
