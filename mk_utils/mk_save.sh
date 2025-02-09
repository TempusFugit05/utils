#!/usr/bin/env bash

export mksave
function mksave()
{ 
    # git add .
    commit_message=""
    echo "Commit message: "
    read commit_message
    
    if [ -z "${commit_message}" ]; then
        echo "Need commit message..."
        return
    fi

    commit_title=""
    echo "Commit title: "
    read commit_title
    
    title_file_name="title.txt"
    script_path="/home/tempus/programs/utils/mk_utils"
    title_file_path="${script_path}/${title_file_name}"
    
    if [ -z ${commit_title} ]; then
        if [ -f "${title_file_path}" ]; then
            commit_title="$(cat ${title_file_path})"
            echo "Using existing title ${commit_title}."
        else
            echo "Need a commit title."
            return
        fi

    else
        echo "${commit_title}" > ${title_file_path}
    fi

    git add .
    git commit -m "${commit_title}" -m "${commit_message}"
    git push
}
