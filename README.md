# Docker image basic Stata image

## Purpose

This Docker image is meant to isolate and stabilize that environment, and should be portable across
multiple operating system, as long as [Docker](https://docker.com) is available.

> To learn more about the use of containers for research reproducibility, see [Carpentries' docker-introduction](https://carpentries-incubator.github.io/docker-introduction/index.html). For commercial services running containers, see [codeocean.com](https://codeocean.com), [gigantum](https://gigantum.com/), or any of the cloud service providers. For an academic project using containers, see [Whole Tale](https://wholetale.org/).


## Build

### Adjust the needed packages

See the [setup.do](setup.do) file, and update accordingly.


### Build the image

```
docker build  .
```

## Publish the image 

The resulting docker image can be uploaded to [Docker Hub](https://hub.docker.com/), if desired, or any other of the container registries. Find the image ID, this will also have been the output of the `docker build` command.

```
...
Removing intermediate container cb12e70b0154
 ---> 52e8f83a14f8
Successfully built 52e8f83a14f8
```

or list your images:

```
docker images 
```
output:
```
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
<none>              <none>              52e8f83a14f8        25 seconds ago      665MB
<none>              <none>              fb095c3f9ade        31 minutes ago      670MB
<none>              <none>              a919483dbe22        34 minutes ago      107MB
```

Now you can upload it. Set the `TAG` and `IMAGEID` accordingly.

```
IMAGEID=52e8f83a14f8
VERSION=17
TAG=$(date +%F)
MYHUBID=dataeditors
MYIMG=stata${VERSION}
docker tag $IMAGEID $MYHUBID/${MYIMG}:$TAG
docker tag $IMAGEID $MYHUBID/${MYIMG}:latest
docker push $MYHUBID/${MYIMG}
```

We can browse the provided images at [https://hub.docker.com/orgs/dataeditors/repositories](https://hub.docker.com/orgs/dataeditors/repositories):

![Screenshot of repository for dataeditors](assets/docker-hub-dataeditors.png)

## Using the image

Using a pre-built image on [Docker Hub](https://hub.docker.com/repository/docker/dataeditors/) to run a program. 

> NOTE: because Stata is proprietary software, we need to mount a license file. 

> NOTE: We are using a working directory of "/code" here - check the [Dockerfile](Dockerfile) for the precise location.

### To enter interactive stata

```
docker run -it --rm \
  -v $(pwd)/stata.lic.17:/usr/local/stata17/stata.lic \
  -v $(pwd)/code:/code \
  -v $(pwd)/data:/data \
  -v $(pwd)/results:/results \
  dataeditors/${MYIMG} 
```

### Running a program

The docker image has a `ENTRYPOINT` defined, which means it will act as if you were running Stata:


```
docker run -it --rm \
  -v $(pwd)/stata.lic.17:/usr/local/stata17/stata.lic \
  -v $(pwd)/code:/code \
  -v $(pwd)/data:/data \
  -v $(pwd)/results:/results \
  dataeditors/${MYIMG} -b program.do
```
Your program, of course, should reference the `/data` and `/results` directories:

```
global basedir "/"
global data "${basedir}data"
global results "${basedir}results"
// use "${data}/mydata.dta"
// graph export "${results}/figure1.png"
```

### Using the container to build a project-specific docker image

- Adjust the `setup.do` file - list all packages you want installed permanently. 
- Remember to have the `stata.lic.17` file available
- Start your Dockerfile with
```
FROM dataeditors/stata17:2021-04-21
# this makes the copy work
COPY stata.lic.${VERSION} /root/stata.lic
RUN mv $HOME/stata.lic /usr/local/stata${VERSION}/ 
# this runs your code 
COPY code/* /code/
COPY data/* /data/
RUN stata-mp do /code/main.do
```




## NOTE

This entire process could be automated, using [Travis-CI](https://docs.travis-ci.com/user/docker/#pushing-a-docker-image-to-a-registry) or [Github Actions](https://github.com/marketplace/actions/build-and-push-docker-images). Not done yet.
