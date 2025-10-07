# LMS Docker Image - Moodle Base

A [Docker](https://en.wikipedia.org/wiki/Docker_(software)) image running an instance of
[Moodle Learning Management System (LMS)](https://en.wikipedia.org/wiki/Moodle).
This image has an blank instance of Moodle,
with the only additional information being the server owner account:
 - Username: `server-owner`
 - Email: `server-owner@test.edulinq.org`
 - Password: `server-owner`

## Usage

The docker image is fairly standard, and does not require special care when building:

For example, you can build an image with the tag `lms-docker-moodle-base` using:
```sh
docker build -t lms-docker-moodle-base .
```

Refer to the [Dockerfile](./Dockerfile) to see any arguments that can be passed
(such as the server owner's credentials).

Once built, the container can be run using standard options.
Moodle uses port 80 by default, so that port should be passed through
(or translated to an unpriveleged port):
```sh
# Using the previously built image.
docker run --rm -it -p 80:8080 --name moodle lms-docker-moodle-base

# Using the pre-built image.
docker run --rm -it -p 80:8080 --name moodle ghcr.io/edulinq/lms-docker-moodle-base
```

## Licensing

This repository is provided under the MIT licence (see [LICENSE](./LICENSE)).
Moodle LMS is covered under the [GPL-3.0 license](https://github.com/moodle/moodle/blob/main/COPYING.txt).
