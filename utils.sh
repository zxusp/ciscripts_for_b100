
function echo_summary_datetime() {
    local datetime=$(date '+%Y-%m-%d %H:%M:%S')
    # 尾部有两个空格，保证markdown换行
    echo_summary_msg " ${datetime} $1  "
}

function echo_summary_msg() {
    local readme_file=${LOGS_PATH}/README.md
    echo "$1" >>${readme_file}
    echo "$1"
    return 0
}
