

function init_logs() {    
    rm -rf ${LOGS_PATH}
    mkdir -p ${LOGS_PATH}
}

function save_logs() {
    local result=0
    if [ -n "${GERRIT_CHANGE_NUMBER}" ]; then 
      echo TODO arch logs to git hub
    else
      echo None Gerrit Change Skip Save Logs
    fi
    return ${result}
}


function install_devstack() {
    local result=0
    pushd ${DEVSTACK_PATH}
    
    ${DRY_RUN} ./clean.sh
    mkdir -p ${LOGS_PATH}/devstack
    cp ${SCRIPTS_PATH}/local.conf ./
    cp ./local.conf ${LOGS_PATH}/devstack

    ${DRY_RUN} ${SCRIPTS_PATH}/install_with_gerrit.sh >${LOGS_PATH}/devstack/install.log 2>&1

    result=$?
    popd
    return ${result}
}

function check_devstack() {
    local result
    pushd ${DEVSTACK_PATH}

    ${DRY_RUN} ./run_tests.sh >${LOGS_PATH}/devstack/check.log 2>&1
    result=$?

    popd
    return ${result}
}

function run_tempest() {
    local result=0
    mkdir -p ${LOGS_PATH}/tempest
    pushd ${TEMPEST_PATH}

    ${DRY_RUN} tox -e smoke >${LOGS_PATH}/tempest/smoke.log 2>&1
    result=$?
    if [ ${result} -eq 0 ]; then
        ${DRY_RUN} tox -e integrated-storage >${LOGS_PATH}/tempest/storage.log 2>&1
        result=$?
    fi

    popd
    return ${result}
}





