# vtiger-dev

This the right image for your Vtiger Development Environment.

## Installation

#### Step 1 - Change base image in your `Dockerfile`

Add to your Dockerfile `FROM javanile/vtiger-dev:7.1.0` instead of `FROM javanile/vtiger:7.1.0`

#### Step 2 - Add `docker-host` service on your `docker-compose.yml` (required for XDebug)

If you want use XDebug add the following service on `docker-compose.yml` to enable host machine routing of xdebug remote machine

```yaml
services:
  .
  .
  docker-host:
    image: qoomon/docker-host
    cap_add: [ 'NET_ADMIN', 'NET_RAW' ]
    restart: on-failure   
```
