#!/bin/bash
chmod +x nxserver.sh
NAME=nm
docker build -t ${NAME} .
docker stop ${NAME} && docker rm ${NAME}

docker run \
  -d \
  --name ${NAME} \
  --hostname zaks \
  -p 4001:4000 \
  -p 2222:22 \
  --cap-add=SYS_PTRACE \
  ${NAME}
