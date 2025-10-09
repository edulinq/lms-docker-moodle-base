FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

ENV MOODLE_DB_NAME=moodle
ENV MOODLE_DB_USER=moodleuser
ENV MOODLE_DB_PASS=moodlepass

ENV MOODLE_ADMIN_USER=server-owner
ENV MOODLE_ADMIN_PASS=server-owner
ENV MOODLE_ADMIN_EMAIL=server-owner@test.edulinq.org

ENV MOODLE_VERSION=v5.0.1

ARG MOODLE_PORT=4000

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

# Clone Moodle repo in the web root and checkout the correct version.
RUN \
    rm -rf /var/www/html \
    && git clone https://github.com/moodle/moodle.git /var/www/html \
    && cd /var/www/html \
    && git checkout $MOODLE_VERSION \
    && rm -rf .git

# Set Moodle Port
RUN sed -i "s/:80/:$MOODLE_PORT/" /etc/apache2/sites-available/000-default.conf
RUN sed -i "s/Listen 80/Listen $MOODLE_PORT/" /etc/apache2/ports.conf

# Setup Web Permissions
RUN \
    mkdir -p /work/moodledata \
    && chown -R www-data:www-data /work/moodledata /var/www/html

# Set PHP Configs
COPY config/moodle-custom.ini /etc/php/8.3/apache2/conf.d/99-moodle.ini
COPY config/moodle-custom.ini /etc/php/8.3/cli/conf.d/99-moodle.ini

# Setup Database and Moodle
RUN \
    # Start the DB in the background. \
    mysqld_safe --nowatch \
    # Wait for the DB to be ready. \
    && (until mysqladmin ping --silent; do echo "Waiting for database server to start..." ; sleep 2 ; done) \
    # Create the DB. \
    && mysql -u root -e "CREATE DATABASE IF NOT EXISTS ${MOODLE_DB_NAME} DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" \
    && mysql -u root -e "CREATE USER IF NOT EXISTS '${MOODLE_DB_USER}'@'localhost' IDENTIFIED BY '${MOODLE_DB_PASS}';" \
    && mysql -u root -e "GRANT ALL PRIVILEGES ON ${MOODLE_DB_NAME}.* TO '${MOODLE_DB_USER}'@'localhost';" \
    && mysql -u root -e "FLUSH PRIVILEGES;" \
    && sudo -u www-data /usr/bin/php /var/www/html/admin/cli/install.php \
        --non-interactive \
        --lang=en \
        --wwwroot=http://localhost:$MOODLE_PORT \
        --dataroot=/work/moodledata \
        --dbtype=mariadb \
        --dbhost=localhost \
        --dbname=$MOODLE_DB_NAME \
        --dbuser=$MOODLE_DB_USER \
        --dbpass=$MOODLE_DB_PASS \
        --fullname="EduLinq LMS Docker Moodle" \
        --shortname="EDQ Moodle" \
        --adminuser=$MOODLE_ADMIN_USER \
        --adminpass=$MOODLE_ADMIN_PASS \
        --adminemail=$MOODLE_ADMIN_EMAIL \
        --agree-license \
    # Stop the DB. \
    && mysqladmin shutdown

COPY scripts/entrypoint.sh /work
ENTRYPOINT ["/work/entrypoint.sh"]
