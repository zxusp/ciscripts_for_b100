#!/bin/bash

function cur_dir() {
    cd $(dirname $0)
    pwd
}
export SCRIPTS_PATH=$(cur_dir)
echo scripts path is ${SCRIPTS_PATH}

. ${SCRIPTS_PATH}/utils.sh
. ${SCRIPTS_PATH}/libs.sh


DEVSTACK_PATH=${HOME}/devstack
STACK_PATH=/opt/stack
TEMPEST_PATH=${STACK_PATH}/tempest
LOGS_PATH=${WORKSPACE}/logs


function main() {
    if [ -z "${WORKSPACE}" ]; then
        echo "WORKSPACE is not set!"
        exit 1
    fi

    if init_logs; then
        echo_summary_msg "# CI for B100"
        echo_summary_msg "  Build ${BUILD_NUMBER} started for Branch ${GERRIT_BRANCH}, Change ${GERRIT_CHANGE_NUMBER}:${GERRIT_PATCHSET_NUMBER}.  "
        echo_summary_msg "## Initialization"
        echo_summary_datetime "Log initialization successful!  "
    else    
        echo_summary_datetime "Log initialization failed!  "
        goto :end_failure
    fi

    echo_summary_msg "## Install DevStack"
    echo_summary_datetime "  Installing DevStack...  "

    if install_devstack; then
        echo_summary_datetime "DevStack installation completed successfully!  "
    else
        echo_summary_datetime "DevStack installation failed!  "
        goto :end_failure
    fi

    if check_devstack; then
        echo_summary_datetime "DevStack self-check passed!  "
    else 
        echo_summary_datetime "DevStack self-check failed!  "
        goto :end_failure
    fi

    echo_summary_msg "## Run Tempest"
    echo_summary_datetime "Running Tempest tests...  "

    if run_smoke_tempest; then
        echo_summary_datetime "Smoke Tempest tests completed successfully!  "
    else
        echo_summary_datetime "Smoke Tempest tests failed!  "
        goto :end_failure
    fi
    if run_storage_tempest; then
        echo_summary_datetime "Storage Tempest tests completed successfully!  "
    else
        echo_summary_datetime "Storage Tempest tests failed!  "
        goto :end_failure
    fi

# end success
    echo_summary_msg "## Finish"
    echo_summary_datetime "Build ${BUILD_NUMBER} completed successfully!  "
    save_logs
    return 0

# end failure
:end_failure
    echo_summary_msg "## Finish"
    echo_summary_datetime "Build ${BUILD_NUMBER} failed!  "
    save_logs
    return 1
}

main
