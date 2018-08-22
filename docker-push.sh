#!/bin/bash
#
# File:         docker-push.sh
# Created:      100818
# Description:  description for docker-push.sh
#

### FUNCTIONS ###

 docker_hub()
 {
  typeset target="$1"

  [ -z "$DOCKER_PASSWORD" -o -z "$DOCKER_USERNAME" ] && { echo "docker_hub: Docker environment not set-up correctly"; return 1; }
  echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
  rc=$?
  [ $rc -ne 0 ] && { echo "docker_hub: Docker hub login failed with rc = $rc"; return $rc; }

  [ ! -z "$target" ] && { docker push "$target"; return $?; }
  return 0
 }


### ENV ###

 image="$1"

### MAIN ###

 docker_hub "$image"

### EOF ###
