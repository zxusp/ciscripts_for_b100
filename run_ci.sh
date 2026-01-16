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
    if ! init_logs; then
        echo "init logs failure"
        return 1
    fi

    if install_devstack; then
        echo "install devstack success!"
    else
        echo "install devstack failure!"
        save_logs
        return 1
    fi

    if check_devstack; then
        echo "devstack self check success!"
    else 
        echo "devstack self check failure!"
        save_logs
        return 1
    fi

    if run_tempest; then
        echo "run tempest success!"
    else
        echo "run tempest failure!"
        save_logs
        return 1
    fi

    save_logs
    return 0
}


main
