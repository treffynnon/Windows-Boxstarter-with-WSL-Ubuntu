function source_d_files() {
    for FILE in $(find "$1" -maxdepth 1 -type f -print | sort)
    do
        source $FILE
    done
}

export WSL_BASEPATH="$WINHOME/wsl_setup"
source_d_files "$WSL_BASEPATH/.bashrc.d"

cd "$WINHOME"