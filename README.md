# vtiger-dev

This is the right image for your **VDE** (Vtiger Development Environment)

## Installation

#### Step 1 - Change base image in your `Dockerfile`

Add to your Dockerfile `FROM javanile/vtiger-dev:7.1.0` instead of `FROM javanile/vtiger:7.1.0`

#### Step 2 - Add `xdebug` service on your `docker-compose.yml` (required for XDebug)

If you want use XDebug add the following service on `docker-compose.yml` to enable host machine routing of xdebug remote machine

```yaml
services:
  .
  .
  xdebug:
    image: javanile/xdebug
    cap_add: [ 'NET_ADMIN', 'NET_RAW' ]
    restart: on-failure   
```

**NOTICE:** _In addiction add `xdebug` in section `links` of your `vtiger` service._

## How to use

This image will be used for Debugging

### Debugging

This image was provided with ad Debug tool for file inside container (generally not visible by developer)

#### Test if debug works

Run the following command with expected output (it keep alive during development)

```
$ docker-compose exec vtiger debug 
Preparing 'debug' directory...
Add your file settings on 'debug/Debugfile'
Watching for debug... (Stop with [Ctrl+C])
```

**NOTICE:** _If you want more control try to edit the file `debug/Debugfile` and add the following line._

Your are ready to change your files in the IDE (eg. `config.inc.php`) and keep-alive debug console

```
Preparing 'debug' directory...
Add your file names on '.debug/.debugfile'
Watching for debug... (Stop with [Ctrl+C])
> Updated: config.inc.php
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
