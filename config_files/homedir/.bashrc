function source_d_files() {
    for FILE in $(find "$1" -maxdepth 1 -type f -print | sort)
    do
        source $FILE
    done
}

export WINUSER=$(cmd.exe /C echo %USERNAME% | tr -d "\r")
export WINHOME="/mnt/c/Users/$WINUSER"
export WSL_BASEPATH="$WINHOME/wsl_setup"

source_d_files "$WSL_BASEPATH/config_files/homedir/.bashrc.d"
xrdb -merge "$WSL_BASEPATH/config_files/homedir/.Xresources"

cd "$WINHOME"