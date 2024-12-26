#!/bin/bash

STFU="/dev/null"
buildDirName="build"

function mkcompile
{
    if [ -f "CMakeLists.txt" ]; then
        if [ ! -d ${buildDirName} ]; then
            mkdir ${buildDirName}
        fi
        pushd ${buildDirName} > ${STFU}
        returnVal=0
        cmake ..
        returnVal=$?
        if [ ${returnVal} -eq 0 ]; then 
            make -j $(nproc --all)
            returnVal=$?
        fi
        popd > ${STFU}
        return ${returnVal}
    else 
        printf "CMakeLists.txt not found...\n"
        return 1
    fi
}
function mkrun
{
    if [ -d ${buildDirName} ]; then
        executables=$(find ${buildDirName} -maxdepth 1 -type f -executable -printf "%p\n")
        numExecutables=$(wc -l <<< "${executables}")
        if [ ${numExecutables} -eq 1 ]; then
            printf "Executing: ${executables##*/}\n"
            printf "Executable size: %'d\n" $(wc -c < ${executables})
            ./${executables}
            printf "\n"
            return $?
        else
            printf "Invalid number of executables found (${numExecutables})...\n"
        fi
    else
        printf "Build directory not found...\n"
        return 1
    fi
}
function mkclear
{
    if [ -d ${buildDirName} ]; then
        rm -r ${buildDirName}
    else
        printf "Nothing to remove...\n"
    fi
}
function mkall
{
    mkcompile
    if [ $? -eq 0 ]; then
        tree --noreport -I "${buildDirName}" .
        mkrun
    fi
}
