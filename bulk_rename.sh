#!/bin/bash

export bulk_rename

function bulk_rename()
{
    path=$1
    match=$2
    replace=$3
    part_1='s|\<'
    part_2='\>|'
    part_3='|g'
    sed_str=${part_1}${match}${part_2}${replace}${part_3}
    echo ${sed_str}
    find "${path}" \( -type d -name .git -prune \) -o -type f -print0 | xargs -0 sed -i ${sed_str}
}

# function bulk_rename_function()
# {
#     path=$1
#     match=$2
#     replace=$3
#     find "${path}" \( -type d -name .git -prune \) -o -type f -print0 | xargs -0 sed -i 's/\${match}\>/${replace}/g'
# }
