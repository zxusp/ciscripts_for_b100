

function init_logs() {    
    rm -rf ${LOGS_PATH}
    mkdir -p ${LOGS_PATH}
}


function copy_push_logs() {
    local target_dir=${WORKSPACE}/logs_for_b100/logs/${GERRIT_CHANGE_NUMBER}

    mkdir -p ${target_dir}
    pushd ${target_dir} || return 1

    git reset --hard
    git pull
    git rm -rf *
    cp -r ${LOGS_PATH}/* ${target_dir}/
    git add .
    git commit -m "Build ${BUILD_NUMBER} logs for ${GERRIT_BRANCH} change ${GERRIT_CHANGE_NUMBER}:${GERRIT_PATCHSET_NUMBER}"
    git push
    popd
}

function save_logs() {
    local result=0
    if [ -n "${GERRIT_CHANGE_NUMBER}" ]; then 
      copy_push_logs || return 1
    else
      echo None Gerrit Change Skip Save Logs
    fi
    return ${result}
}


function install_devstack() {
    local result=0
    pushd ${DEVSTACK_PATH}

    mkdir -p ${LOGS_PATH}/devstack
    cp ${SCRIPTS_PATH}/local.conf ./
    cp ./local.conf ${LOGS_PATH}/devstack

    ${DRY_RUN} ./unstack.sh >${LOGS_PATH}/devstack/unstack.log 2>&1
    ${DRY_RUN} ./clean.sh >${LOGS_PATH}/devstack/clean.log 2>&1

    # clean all logs 
    rm -rf ${STACK_PATH}/logs/* 
    echo Devstack Cleaned

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

function run_smoke_tempest() {
    local result=0
    mkdir -p ${LOGS_PATH}/tempest
    pushd ${TEMPEST_PATH}

    ${DRY_RUN} tox -e smoke >${LOGS_PATH}/tempest/smoke.log 2>&1
    result=$?
    popd
    return ${result}
}

function run_storage_tempest() {
    local result=0
    mkdir -p ${LOGS_PATH}/tempest
    pushd ${TEMPEST_PATH}

    ${DRY_RUN} tox -e integrated-storage >${LOGS_PATH}/tempest/storage.log 2>&1
    result=$?

    popd
    return ${result}
}

