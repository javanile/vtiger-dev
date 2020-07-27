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

In addiction add `docker-host` in section `links` of your `vtiger` service.

## How to use

This image will be used for Debugging

### Debugging

This image was provided with ad Debug tool for file inside container (generally not visible by developer)

#### Test if debug works

Run the following command with expected output (it keep alive during development)

```
$ docker-compose exec vtiger 
Add your file names on '.debug/.debugfile'
Watching for debug... (Stop with [Ctrl+C])
```

Now edit thie file `.debug/.debugfile` and add the following line

```
## Config
config.inc.php
```

After you save you must see it on keep-alive debug console
```
Add your file names on '.debug/.debugfile'
Watching for debug... (Stop with [Ctrl+C])
+ config.inc.php
> config.inc.php
```

Now the file `config.inc.php` is ready and connected to your debugging tool, place your `var_dump($_GET)` everywhere.

Look to your browser if you see something like this

```
array(3) (
    "module" => "Users",
    "action" => "Login",
)
```

It works perfectly.
