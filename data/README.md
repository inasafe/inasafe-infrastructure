InaSAFE data.inasafe.org Dockerfile
===================================

This will build a [docker](http://www.docker.io/) image that runs an [Apache](http://apache.org/) Webserver providing the data synced by the inasafe/btsync image.


### Building the Image ###

```
docker build -t inasafe/data .
```
or use the script
```
docker-build.sh
```

### Running BitTorrent Sync ###

```
docker run -d -p 8082:80 -v /var/docker/volumes/btsync/data:/var/www/ inasafe/data
```
or use the script
```
docker-run.sh
```


`-d` run in detached mode

`-p` expose container port `[public-port]:[container-port]`
> Or host machine forwards everything coming for data.inasafe.org to localhost on port 8082 so we have to set this port for data.inasafe.org.
> If you do not explicitly set a public port, a random open port will be used because the ports are exposed in the Dockerfile

`-v` mount a local directory in the container `[host-dir]:[container-dir]`
> We mount the synced data from the btsync container directly into `/var/wwww` to make the apache configuration easier.
