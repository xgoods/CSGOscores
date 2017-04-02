#!/bin/bash

i=1
sp="/-\|"
echo -n ' '
echo "program running"
while true;do  printf "\b${sp:i++%${#sp}:1}";done &
./getCSGO.sh # or do something else here
kill $!; trap 'kill $!' SIGTERM
echo done