#! /usr/bin/env bash
function join { local IFS="$1"; shift; echo "$*"; }

# Learn Windows identity
WINUSER=$(cmd.exe /C echo %USERNAME%) # need to trim line ending off of this
WINHOME="/mnt/c/Users/$WINUSER"

# Re-mount the drive with metadata (mappings from Windows to Linux file permissions)
cd / # need to move out of /mnt/c if we're in there otherwise we'll hold the mount open
sudo pkill -9 'weasel-pageant' # kill any binaries being run from /mnt/c - however unlikely
sudo umount /mnt/c
sudo mount -t drvfs C: /mnt/c -o 'metadata,uid=1000,gid=1000,umask=0022,fmask=0011'

# Bring Ubuntu's apt-get up to date
sudo apt-get update
sudo apt-get upgrade -y

# Taken from list of installed packages using the following
# apt list --installed | grep -v 'automatic'
sudo apt-get install -y \
  wget curl tmux rsync \
  vim xsel dos2unix git colordiff \
	bzip2 coreutils linux-tools-common build-essential \
	fonts-hack-ttf fonts-ubuntu-font-family-console

# vim setup
## vim8 for Ubuntu 16.04
# sudo add-apt-repository ppa:jonathonf/vim
# sudo apt update
# sudo apt install vim

## install pathogen
mkdir -p ~/.vim/autoload ~/.vim/bundle && \
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

## minimal config
echo 'execute pathogen#infect()' >> ~/.vimrc
echo 'syntax on' >> ~/.vimrc
'filetype plugin indent on' >> ~/.vimrc

## editorconfig for vim via pathogen
cd ~/.vim/bundle && \
git clone https://github.com/editorconfig/editorconfig-vim.git

# configure tmux
## install plugin manager
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
echo "run '~/.tmux/plugins/tpm/tpm'" >> ~/.tmux.conf
tmux source ~/.tmux.conf

# Set Linux permissions on user directories (essentially removing executable from most files)
# Excludes anything in directories listed below
ignored_directories_list=(
  'node_modules'
  'bin' '.bin' 'dist' 'build'
  '.git'
)
# and any files with the extensions listed below
executable_extensions_list=( 
  'bashrc' 'Xresources' '[czkf]?sh'
  'exe' 'bat' 'ps1' 'cmd' 'com' 'bin' 'run'
  'jar' 'vb[se]?' 'vbscript'
  'i[pn]f' 'msi' 'lnk' 'reg' 'sc[tr]'
  'ws[fh]?'
)

# joins and wraps the ignored directories (-path '*/.git/*' -o) for the find command - sed trims the final -o off the end
ignored_directories=$(printf -- "-path '*/%s/*' -o\n" "${ignored_directories_list[@]}" | sed 's/ -o$//g')
exclude_extensions=$(join , ${executable_extensions_list[@]})

find "$WINHOME/Desktop" "$WINHOME/Documents" "$WINHOME/Downloads" "$WINHOME/Pictures" \
    \( $ignored_directories \) -prune -o \
	-type f -regextype egrep -not -regex ".*\.($exclude_extensions)\$" \
	-execdir chmod 0664 '{}' \+