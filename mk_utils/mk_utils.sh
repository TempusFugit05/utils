#!/bin/bash

export mkcompile mkclear mkrun mkall

STFU="/dev/null"
buildDirName="build"
CMAKE_ARGS=""

function get_cmake_args()
{
    while ! [ $# -eq 0 ]; do
        case $1 in
            -cmake_args=*)
                ARGS=$@
                ARGS="${ARGS#-cmake_args=*}"
                ARGS="${ARGS%-make_args*}"
                CMAKE_ARGS=$ARGS
                return
            ;;
            *)
                shift 1
            ;;
        esac
    done
}

function mkcompile()
{
    if [ -f "CMakeLists.txt" ]; then
        if [ ! -d ${buildDirName} ]; then
            mkdir ${buildDirName}
        fi
        pushd ${buildDirName} > ${STFU}
        returnVal=0
        get_cmake_args $@
        echo "$CMAKE_ARGS"
        cmake .. ${CMAKE_ARGS} 
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
        numExecutables=0
        if [ -n "${executables}" ]; then
            numExecutables=$(wc -l <<< "${executables}")
        fi
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

function mkall()
{
    if [[ $1 == "--test=true" ]]; then
        mkcompile "-cmake_args=-Dtest=true"
    elif [[ $1 == "--test=false" ]]; then
        mkcompile "-cmake_args=-Dtest=false"
    else
        mkcompile $@
    fi

    if [ $? -eq 0 ]; then
        tree --noreport -I "${buildDirName}" .
        mkrun
    fi
}
