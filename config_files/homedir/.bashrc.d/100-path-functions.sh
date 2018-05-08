# convert a windows path to a WSL one
function w2lpath() {
  # either piped in from stdin or using the arguments
  if [ $# -eq 0 ] ; then
    i=$(cat < /dev/stdin)
  else
    i="$1"
  fi
  echo $(readlink -f "$(sed -e 's|^\([A-Z]\):|/mnt/\L\1|' -e 's|\\|/|g' <<< "$i")")
}

# convert a WSL path to a Windows one
function l2wpath() {
  # either piped in from stdin or using the arguments
  if [ $# -eq 0 ] ; then
    i=$(cat < /dev/stdin)
  else
    i="$1"
  fi
  # expand relative paths
  target_path=$(readlink -f "$i")

  # patch ~ to $WINHOME
  if grep -q "^/home/" <<< "$target_path"; then
      target_path=$(sed "s|^$HOME|$WINHOME|g" <<< "$target_path")
  fi
  if grep -q "^/mnt/[a-z]" <<< "$target_path"; then
      echo $(sed -e 's|^\(/mnt/\([a-z]\)\)\(.*\)|\U\2:\E\3|' -e 's|/|\\|g' <<< "$target_path")
  else
      echo "failed to parse path"
      exit 1
  fi
}

export -f w2lpath
export -f l2wpath