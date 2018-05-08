___tmuxattach() {
    echo "> $1"
    pkill -STOP -P "$3" -U "$UID" -x "$2"
    tmux send-keys -t "$1" C-m "source" Space "$WSL_BASEPATH/.bashrc.d/_helpers/tmux_attach.sh" Space "'$SSH_AUTH_SOCK'" C-m
    pkill -CONT -P "$3" -U "$UID" -x "$2"
}
export -f ___tmuxattach

#___tmuxattach() {
#    echo "> $1"
#    tmux send-keys -t "$1" C-z "export SSH_AUTH_SOCK='$SSH_AUTH_SOCK'" C-m "echo 'Environment patched'" C-m "fg &> /dev/null" C-m
#}
#export -f ___tmuxattach

attachtmux() {
  echo "Patching panes:"
  target_panes=$(tmux list-panes -a -F "#{pane_id}=#{pane_current_command}=#{pane_pid}" | grep -vP '^%[0-9]+=(ssh|tmux|screen)=')
  if hash parallel 2> /dev/null; then
    parallel -j4 --no-notice --no-run-if-empty --colsep '=' ___tmuxattach ::: "$target_panes"
  else
    while read -r pane_data; do
      ___tmuxattach $(echo "$pane_data" | sed 's/=/ /g')
    done <<< "$target_panes"
  fi
  echo "Finished patching"

  echo "Attaching session"
  tmux attach $@
}

patchtmuxenv() {
  echo "Patching current tmux pane"
  new=$(tmux show-environment SSH_AUTH_SOCK | cut -d '=' -f 2)
  colordiff -a <(echo "$SSH_AUTH_SOCK") <(echo "$new")
  export SSH_AUTH_SOCK="$new"
  echo "Finished patching"
}

listtmuxpanes() {
  headerrow="Window name=Window # (id)=Pane # (id)=Running (PID)"
  tmuxformat="#{window_name}=#{window_index} (#{window_id})=#{pane_index} (#{pane_id})=#{pane_current_command} (#{pane_pid})"
  ( echo "$headerrow"; tmux list-panes -a -F "$tmuxformat" ) | cat | column -s '=' -t
}

export -f attachtmux
export -f patchtmuxenv
export -f listtmuxpanes