# openjdk-docker-build-tools
Dockerfiles and build scripts for generating maven Docker Images related to OpenJDK. Currently this builds maven images with hotspot and Eclipse OpenJ9 on Ubuntu.

# License
The Dockerfiles and associated scripts found in this project are licensed under the [Apache License 2.0.](https://www.apache.org/licenses/LICENSE-2.0.html).

# Build and push the Images to DockerHub

```
# 1. Clone this github repo
     $ git clone https://github.com/AdoptOpenJDK/openjdk-docker-build-tools

# 2. Build images and tag them appropriately
     $ cd openjdk-docker-build-tools
     $ ./build_tools_all.sh
```

# Dependencies
This repo is dependent on the [openjdk-docker](https://github.com/AdoptOpenJDK/openjdk-docker) repo. There is some level common code in both the repos. The main reason is to maintain a clean separation between the Maven and the JVM Docker image builds and layers.
