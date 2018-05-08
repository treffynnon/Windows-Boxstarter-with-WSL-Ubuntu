# SSH config - we must copy because the windows FS is loaded as executable and OpenSSH
## Load putty agent into WSL (Pageant needs to be running)
eval $("$WINHOME/weasel-pageant/weasel-pageant" -r)

# will refuse to load a config that doesn't have the correct permissions set
mkdir -p ~/.ssh
rsync --quiet --chmod=0644 "$WINHOME/.ssh/config" ~/.ssh/
# ensure we're getting linux line endings so we don't get ^M when tab completing etc inside WSL
dos2unix --keepdate --quiet ~/.ssh/config

# git config
git config --global include.path "$WINHOME/.gitconfig"
git config --global core.excludesfile "$(git config -f $WINHOME/.gitconfig core.excludesfile | w2lpath)"
git config --global core.attributesfile "$WINHOME/.gitattributes"