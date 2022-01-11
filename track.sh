#!/bin/sh

BUILD_TRACKER="http://127.0.0.1:8000/build"

get_linux_uuid () {
    build_tracker="$HOME/.build_tracker"
    if test -f "$build_tracker"; then
        uuid=$(<$build_tracker)
    else
        cat /proc/sys/kernel/random/uuid > "$build_tracker"
    fi 
}

get_darwin_system_info () {
    uuid="$(ioreg -rd1 -c IOPlatformExpertDevice | awk '/IOPlatformUUID/ { split($0, line, "\""); printf("%s\n", line[4]); }')"
    mem="$(sysctl hw.memsize |awk '{print int($2/1024^3)}')"
    cpu="$(sysctl -n machdep.cpu.brand_string)"
}

get_windows_system_info () {
    uuid=""
    mem=""
    cpu=""
}

get_linux_system_info () {
    get_linux_uuid
    mem="$(grep 'VmallocTotal' /proc/meminfo | awk '{print int($2/1024^3+0.5)}')"
    cpu="$(grep 'model name' /proc/cpuinfo | uniq | cut -d':' -f2 | tr -d ' ')"
}

get_unknown_system_info () {
    uuid=""
    uname="unknown"
    mem=""
    cpu=""
}

uname="$(uname -s)"

case "$uname" in
    Darwin*)
        get_darwin_system_info
        ;;
    Linux*)
        get_linux_system_info
        ;;
    CYGWIN*|MINGW*|MSYS*|Windows*)
        get_windows_system_info
        ;;
    *)
        get_unknown_system_info
        ;;
esac

echo "$MAVEN_OPTS"

build_name="[INFO] Building"
build_name_reactor="[INFO] Reactor Summary for"
build_result="[INFO] BUILD"
build_time="[INFO] Total time:"
build_finished_at="[INFO] Finished at:"

# open report
report='{"submodules":['

while read LINE; do

    echo "$LINE"
    LINE=$(echo $LINE | sed -r "s/\x1B\[[0-9;]*[JKmsu]//g" | tr -d '\r')
    final=0

    if [[ "$LINE" = "$build_name"* && -z "$module_build_name" ]]; then
        echo "Reading modules build name"
        module_build_name=$(echo $LINE | cut -d' ' -f3- | tr -d ':')
        echo "$module_build_name"
        continue
    elif [[ "$LINE" = "$build_name_reactor"* && -z "$module_build_name" ]]; then
        echo "Reading reactor module build name"
        module_build_name=$(echo $LINE | cut -d' ' -f5- | tr -d ':')
        echo "$module_build_name"
        continue
    fi

    if [[ "$LINE" = "$build_result"* ]]; then
        echo "Reading module build result"
        module_build_result=$(echo $LINE | sed -E 's/.*(SUCCESS|FAILURE).*/\1/')
        echo
        continue
    fi

    if [[ "$LINE" = "$build_time"* ]]; then
        echo "Reading buld_time"
        module_build_time=$(echo $LINE | cut -d' ' -f4- | tr -d ' ')
        echo "$module_build_time"
        continue
    fi

    if [[ "$LINE" = "$build_finished_at"* ]]; then
        echo "Reading module build finished at"
        module_build_finished_at=$(echo $LINE | cut -d' ' -f4)
        echo "$module_build_finished_at"
        continue
    fi

    hit=$(echo $LINE |grep -oE '^\[INFO\](.*)(SUCCESS|FAILURE|SKIPPED).*')
    if [ ! -z "$hit" ]; then
        hit=$(echo $hit | cut -d' ' -f2-)
        module=$(echo $hit | awk -F'(SUCCESS|FAILURE|SKIPPED)' '{print $1}' | sed -E 's/[[:blank:]\.]*$//')
        submodule_build_time=$(echo $hit | awk -F'(SUCCESS|FAILURE|SKIPPED)' '{print $2}' | tr -d ' []')
        result=$(echo $hit | sed -nE 's/.*(SUCCESS|FAILURE|SKIPPED).*/\1/p')
        report+="{"
        report+="\"module\": \"$module\","
        report+="\"build_time\": \"$submodule_build_time\","
        report+="\"result\": \"$result\""
        report+="},"
    fi

done < /dev/stdin

# remove trailing comma after list of submodules
report=$(echo $report | sed 's/,$//')

# close list of submodules
report+="],"

# add build information
report+="\"module\": \"$module_build_name\","
report+="\"result\": \"$module_build_result\","
report+="\"build_time\": \"$module_build_time\","
report+="\"finished_at\": \"$module_build_finished_at\","
report+="\"maven_opts\": \"$MAVEN_OPTS\","
report+="\"uname\": \"$uname\","
report+="\"uuid\": \"$uuid\","
report+="\"cpu\": \"$cpu\","
report+="\"mem\": $mem"

# close report
report+="}"

echo "$report"

# finally post result to build tracker
status_code=$(curl --write-out %{http_code} -sS --output build_tracker.log -X POST -H "Content-Type: application/json" -d "$report" "$BUILD_TRACKER")

build_tracking="[\033[1;35mBUILD TRACKING\033[0m]"
build_tracking_success="\033[1;32mSUCCESS\033[0m"
build_tracking_failure="\033[1;31mFAILED\033[0m"
if [[ "$status_code" -eq 200 ]] ; then
  build_id=$(cat build_tracker.log | cut -d':' -f 2 | cut -d',' -f 1)
  echo "${build_tracking} ${build_tracking_success} - build #${build_id} - Thanks! 👍"
elif [[ "$status_code" -eq 000 ]]; then
  echo "${build_tracking} ${build_tracking_failure} - curl connection error"
else
  echo "${build_tracking} ${build_tracking_failure} $status_code"
  cat build_tracker.log
fi
