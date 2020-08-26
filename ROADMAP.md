


Use this
```
# host.docker.internal does not work on Linux yet: https://github.com/docker/for-linux/issues/264
# Workaround:
# ip -4 route list match 0/0 | awk '{print $3 " host.docker.internal"}' >> /etc/hosts \
``` 
