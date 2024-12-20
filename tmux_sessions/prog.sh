#!/bin/bash

STFU="/dev/null"
function prog
{
    defaultSessionName="prog"
    mainPaneName="Main"
    cmakePaneName="Cmake"
    extraPaneNameSrc="Lib-Source"
    extraPaneNameInclude="Lib-Include"
    
    sessionName=$defaultSessionName
    
    secondaryPaneSize=20
    numExtraPanes=1
    targetDirectory=$PWD
    changeDirectory=0

    while ! [ $# -eq 0 ]; do 
        case $1 in
            
            -n|--name)
                sessionName="$2"
                shift 2
            ;;
            
            -d|--directory)
                  targetDirectory="$2"
                  shift 2
            ;;
            
            -cd)
                changeDirectory=1
                shift 1
            ;;
            
            -e|--extra)
                numExtraPanes=$2
                shift 2
            ;;

            *)
                echo "Unknown argument '$1'"
                return 1
            ;;
        
        esac
    done

    if tmux has-session -t "$sessionName" 2>$STFU; then
        echo "Attaching to existing session..."
        tmux attach-session -t "$sessionName"
        return 0

    else
        if [ $changeDirectory -eq 1 ]; then
            cd "$targetDirectory"
        else
            pushd "$targetDirectory" > $STFU # pushd to start new panes in the desired directory
        fi
        
        # Create initial panes
        tmux new-session -d -n "main" -s "$sessionName"
        tmux split-window -h
        tmux resize-pane -R $secondaryPaneSize
        
        # Rename panes
        tmux select-pane -t 0 -T "$mainPaneName"
        tmux select-pane -t 1 -T "$cmakePaneName"
        
        # Enter default files 
        if [ -f "main.cpp" ]; then
            tmux send-keys -t ":0.0" "vim main.cpp" Enter
        elif [ -f "main.c" ]; then
            tmux send-keys -t ":0.0" "vim main.c" Enter
        fi
        
        if [ -f "CMakeLists.txt" ]; then
            tmux send-keys -t ":0.1" "vim CMakeLists.txt" Enter
        fi
        
        # Create complimentary panes/windows
        if [ $numExtraPanes -gt 0 ]; then
            for i in $( eval echo {1..$numExtraPanes} ) 
            do
                tmux new-window -t "$sessionName:$1" -n "Extra-$i"
                tmux split-window -h
                
                tmux select-pane -t 0 -T "$extraPaneNameSrc-$i"
                tmux select-pane -t 1 -T "$extraPaneNameInclude-$i"
    
                tmux resize-pane -R $secondaryPaneSize
            done
        fi
        
        if [ $changeDirectory -eq 0 ]; then
            popd > $STFU
        fi
        tmux swap-window -t 0
        tmux attach-session -t "$sessionName"
        return 0
    fi
}
