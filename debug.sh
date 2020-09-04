#!/bin/bash
set -e

## Settings
workdir="${PWD}"
debug_dir=debug
debugfile=Debugfile
target_dir=/var/www/html
watch_dir=/app/${debug_dir}
build_dir=$(mktemp -d -t vtiger-dev-debug-XXXXXX)

inotifywait=inotifywait
if [[ "$@" == *"--polling"* ]]; then
    inotifywait=inotifywait-polling
else
    echo "NOTICE: Use '--polling' due to unsupported MS Windows filesystem."
fi

echo ""
echo "-------------------"
echo " Vtiger Debug Mode"
echo "-------------------"
echo " - Preparing environment..."

## Create build dir
if [[ ! -d "${build_dir}/${debug_dir}" ]]; then
    mkdir -p "${build_dir}/${debug_dir}"
fi

## Create debugfile
if [[ ! -f "${build_dir}/${debug_dir}/${debugfile}" ]]; then
    echo '# Debugfile' > "${build_dir}/${debug_dir}/${debugfile}"
    echo '*' >> "${build_dir}/${debug_dir}/${debugfile}"
fi

## Copy all source files on build
cp -RL "${target_dir}"/* "${build_dir}/${debug_dir}"
find * -type f -not -path "${debug_dir}/*" > "${build_dir}/${debug_dir}/.debugignore"
while IFS= read line || [[ -n "${line}" ]]; do
    file=$(echo ${line} | tr -d '\r')
    [[ -z "${file}" ]] && continue
    [[ "${file::1}" == "#" ]] && continue
    rm -f "${build_dir}/${debug_dir}/${file}"
done < "${build_dir}/${debug_dir}/.debugignore"
chmod -R 777 "${build_dir}"
cd "${build_dir}"
zip -qq -ro debug.zip "${debug_dir}"
rm -f /app/debug.zip
mv debug.zip /app/debug.zip
chmod 777 /app/debug.zip
rm -fr "${build_dir}"

echo " - Confirm your environment is ready before start:"

echo ""
echo "(1) Install a Chrome extension than configure and enable it for PHPSTORM (See: https://github.com/javanile/vtiger-dev/wiki/Chrome)"
read -p " -> Is it ready? (y/N) " -n 1 -r
[[ $REPLY =~ ^[Yy]$ ]] || exit 1
echo ""

echo ""
echo "(2) Enable PhpStorm to 'Start Listening for PHP Debug Connections' (See: https://github.com/javanile/vtiger-dev/wiki/PhpStorm)"
read -p " -> Is it ready? (y/N) " -n 1 -r
[[ $REPLY =~ ^[Yy]$ ]] || exit 1
echo ""

echo ""
echo "(3) Extract 'debug.zip' file into your project with command 'tar -xv debug.zip' (See: https://github.com/javanile/vtiger-dev/wiki/debug.zip)"
read -p " -> Is it ready? (y/N) " -n 1 -r
[[ $REPLY =~ ^[Yy]$ ]] || exit 1
echo ""

set -f

## Process debugfile
process_debugfile () {
    while IFS= read file || [[ -n "${file}" ]]; do
        file=$(echo "${file}" | tr -d '\r')
        [[ -z "${file}" ]] && continue
        [[ "${file}" == "*" ]] && continue
        [[ "${file::1}" == "#" ]] && continue
        [[ -f ${watch_dir}/${file} ]] && continue
        echo "+ ${file}"
        if [[ ! -f ${target_dir}/${file} ]]; then
            mkdir -p $(dirname ${target_dir}/${file}) && true
            touch ${target_dir}/${file}
            chmod 777 -R $(dirname ${target_dir}/${file})
        fi
        mkdir -p $(dirname ${watch_dir}/${file}) && true
        cp ${target_dir}/${file} ${watch_dir}/${file}
        chmod 777 -R ${watch_dir}
    done < ${watch_dir}/${debugfile}
}

## Files watcher
echo "Add your additional settings on 'debug/Debugfile'"
echo "Watching for debug... (Stop with [Ctrl+C])"
process_debugfile
${inotifywait} -q -r -e moved_to,create,modify -m ${watch_dir} |
while read -r directory events current_file; do
    #echo "${events} ${directory} ${current_file}"
    if [[ "${current_file}" = "${debugfile}" ]]; then
        process_debugfile
    else
        while IFS= read file || [[ -n "${file}" ]]; do
            file=$(echo ${file} | tr -d '\r')
            [[ -z "${file}" ]] && continue
            [[ "${file::1}" == "#" ]] && continue
            if [[ "${directory}${current_file}" = "${watch_dir}/${file}" || ${file} = "*" ]]; then
                exact_file=$(echo "${directory}${current_file}" | sed 's|^'${watch_dir}/'||')
                echo "> Update: ${exact_file}"
                cp "${directory}${current_file}" "${target_dir}/${exact_file}" && true
            fi
        done < ${watch_dir}/${debugfile}
    fi
    #echo ">>> ${filename}"
done
