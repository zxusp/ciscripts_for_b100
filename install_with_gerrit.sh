#!/bin/bash

# 使用参数扩展设置默认值
export GERRIT_BRANCH="${GERRIT_BRANCH:-master}"

# 设置CINDER_BRANCH
if [ "${GERRIT_PROJECT}" = "openstack/cinder" ]; then
    export CINDER_BRANCH="${GERRIT_REFSPEC:-$GERRIT_BRANCH}"
else
    export CINDER_BRANCH="$GERRIT_BRANCH"
fi

# 设置CINDER_BRANCH
if [ "${GERRIT_PROJECT}" = "openstack/os-brick" ]; then
    export OS_BRICK_BRANCH="${GERRIT_REFSPEC:-$GERRIT_BRANCH}"
else
    export OS_BRICK_BRANCH="$GERRIT_BRANCH"
fi

# 显示结果
echo "GERRIT_BRANCH: $GERRIT_BRANCH"
echo "CINDER_BRANCH: $CINDER_BRANCH"
echo "OS_BRICK_BRANCH: $OS_BRICK_BRANCH"


./stack.sh
