#!/bin/bash
set -e

## Settings
debug_dir=debug
debugfile=Debugfile
target_dir=/var/www/html
watch_dir=/app/${debug_dir}

inotifywait=inotifywait
if [[ "$@" == *"--polling"* ]]; then
    inotifywait=inotifywait-polling
else
    echo "NOTICE: Use '--polling' due to unsupported MS Windows filesystem."
fi

## Create watch_dir
if [[ ! -d ${watch_dir} ]]; then
    mkdir ${watch_dir}
fi

## Create debugfile
if [[ ! -f ${watch_dir}/${debugfile} ]]; then
    echo '# Debugfile' > ${watch_dir}/${debugfile}
    echo '*' >> ${watch_dir}/${debugfile}
fi

## Copy all source files on
echo "Preparing 'debug' directory..."
cp -RL /var/www/html/* ${watch_dir}
find * -type f -not -path "${debug_dir}/*" > ${watch_dir}/.debugignore
while IFS= read file || [[ -n "${file}" ]]; do
    rm -f ${watch_dir}/${file}
done < ${watch_dir}/.debugignore
chmod -R 777 ${watch_dir}
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
echo "Add your file settings on 'debug/Debugfile'"
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
                cp ${directory}${current_file} ${target_dir}/${exact_file}
            fi
        done < ${watch_dir}/${debugfile}
    fi
    #echo ">>> ${filename}"
done
