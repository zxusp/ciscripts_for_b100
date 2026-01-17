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
TEMPEST_PATH=/opt/stack/tempest
LOGS_PATH=${WORKSPACE}/logs


function main() {
    if [-z "${WOKSPACE}"]; then
        echo "WORKSPACE is not set!"
        exit 1
    fi

    if init_logs; then
        echo_summary_msg "# CI for B100"
        echo_summary_msg " Build ${BUILD_NUMBER} start for Branch ${GERRIT_BRANCH} Change ${GERRIT_CHANGE_NUMBER}:${GERRIT_PATCHSET_NUMBER}."
        echo_summary_msg "## Init"
        echo_summary_datetime "init logs success"
    else    
        echo_summary_datetime "init logs failure"
        return 1
    fi

    echo_summary_msg "## Install Devstack"

    if install_devstack; then
        echo_summary_datetime "install devstack success!"
    else
        echo_summary_datetime "install devstack failure!"
        save_logs
        return 1
    fi

    if check_devstack; then
        echo_summary_datetime "devstack self check success!"
    else 
        echo_summary_datetime "devstack self check failure!"
        save_logs
        return 1
    fi

    echo_summary_msg "## Run Tempest"
    if run_smoke_tempest; then
        echo_summary_datetime "run smoke tempest success!"
    else
        echo_summary_datetime "run smoke tempest failure!"
        save_logs
        return 1
    fi
    if run_storage_tempest; then
        echo_summary_datetime "run storage tempest success!"
    else
        echo_summary_datetime "run storage tempest failure!"
        save_logs
        return 1
    fi


    echo_summary_msg "## Finish"
    echo_summary_datetime "build ${BUILD_NUMBER} end success!"
    save_logs
    return 0
}

main
