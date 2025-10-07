# LMS Docker Image - Moodle Base

A [Docker](https://en.wikipedia.org/wiki/Docker_(software)) image running an instance of
[Moodle Learning Management System (LMS)](https://en.wikipedia.org/wiki/Instructure).
This image has an blank instance of Moodle,
with the only additional information being the server owner account:
 - Email/Username: `server-owner@test.edulinq.org`
 - Password: `server-owner`

## Usage

The docker image is fairly standard, and does not require special care when building:

For example, you can build an image with the tag `lms-docker-canvas-base` using:
```sh
docker build -t lms-docker-canvas-base .
```

Refer to the [Dockerfile](./Dockerfile) to see any arguments that can be passed
(such as the server owner's credentials).

Once built, the container can be run using standard options.
Moodle uses port 8080 by default, so that port should be passed through:
```sh
# Using the previously built image.
docker run --rm -it -p 8080:8080 --name canvas lms-docker-canvas-base

# Using the pre-built image.
docker run --rm -it -p 8080:8080 --name canvas ghcr.io/edulinq/lms-docker-canvas-base
```

## Licensing

This repository is provided under the MIT licence (see [LICENSE](./LICENSE)).
Moodle LMS is covered under the [GPL-3.0 license](https://github.com/moodle/moodle/blob/main/COPYING.txt).
