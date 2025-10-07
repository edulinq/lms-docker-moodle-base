#!/bin/bash

readonly WORK_DIR=/work

function main() {
    trap exit SIGINT

    cd "${WORK_DIR}"

    local exit_status=0

    echo "TODO"


    return ${exist_status}
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"
