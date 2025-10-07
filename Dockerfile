FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

ENV MOODLE_DB_NAME=moodle
ENV MOODLE_DB_USER=moodleuser
ENV MOODLE_DB_PASSWORD=moodlepass

ENV MOODLE_ADMIN_USER=server-owner
ENV MOODLE_ADMIN_PASSWORD=server-owner
ENV MOODLE_ADMIN_EMAIL=server-owner@test.edulinq.org

ENV MOODLE_VERSION=v5.0.1

USER root

WORKDIR /work

# Install the base/build packages before the main dependency packages.
RUN \
    apt-get update \
    && apt-get install -y \
        # Convenience \
        vim \
        # Base Tooling \
        build-essential \
        cron \
        curl \
        git \
        sudo \
        unzip \
        wget \
        # Python \
        python3 \
        python3-pip \
        # Apache \
        apache2 \
        libapache2-mod-php \
        php \
        php-curl \
        php-gd \
        php-intl \
        php-mbstring \
        php-mysql \
        php-xml \
        php-zip \
        # Database \
        mariadb-server \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

# Clone Moodle Repo
RUN \
    git clone https://github.com/moodle/moodle.git \
    && cd moodle \
    && git checkout $MOODLE_VERSION

# Setup Permissions
RUN \
    mkdir -p /var/www/moodledata /var/www/html/moodle \
    && chown -R www-data:www-data /var/www/moodledata \
    && chown -R www-data:www-data /var/www/html/moodle

# Max Input Vars 5000
COPY moodle-custom.ini /etc/php/8.3/apache2/conf.d/99-moodle.ini
COPY moodle-custom.ini /etc/php/8.3/cli/conf.d/99-moodle.ini

# Initialize Moodle
COPY scripts/initialize.sh /work
RUN /work/initialize.sh

COPY scripts/entrypoint.sh /work
ENTRYPOINT ["/work/entrypoint.sh"]
