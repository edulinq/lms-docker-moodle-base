#!/bin/bash

readonly WORK_DIR=/work

function main() {
    trap exit SIGINT

    cd "${WORK_DIR}"

    local exit_status=0

    # Start MariaDB manually in the background.
    mysqld_safe &

    # Wait for MariaDB to be ready.
    until mysqladmin ping --silent; do
        echo "Waiting for database server to start..."
        sleep 2
    done

    # Start Apache in Foreground
    exec apachectl -D FOREGROUND

    return ${exit_status}
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"
