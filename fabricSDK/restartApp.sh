#!/bin/bash
docker stop fabricsdk_api_1
docker rm fabricsdk_api_1
docker rmi api:1.0
docker-compose up -d
docker logs fabricsdk_api_1
 