#
# ~/.bash_profile
#

# Set full path to a image into the conf directory into a file
# called by feh to set the background image
# 
# @param string /path/to/image/file
# @return string msg with result
#
# i.g.
# set-wallpaper ~/Images/anbyM3.png
set-wallpaper() {
if [ -f "$1" ] && [[ "$1" =~ \.(png|jpg|jpeg|gif|bmp|tiff|webp)$ ]]; then
  readlink -f "$1" > ~/.config/i3/wallpaper.txt
  echo -e "\e[32mWallpaper set successfully!\e[0m"
else
  echo -e "\e[31mInvalid File\e[0m" >&2
fi
}

# Enable autocomplete for the set-wallpaper function
_set_wallpaper_completions() {
  local cur=${COMP_WORDS[COMP_CWORD]}
  local IFS=$'\n'

    # If the current word is empty or contains a path
    if [[ -z "$cur" || "$cur" == */* ]]; then
      # Complete directories and image files
#      COMPREPLY=($(compgen -f -X '!*.*(@(png|jpg|jpeg|gif|bmp|tiff|webp)|/)' -- "$cur"))
      COMPREPLY=($(compgen -f -- "$cur"))

    else
      # Complete only directories in the current folder
      COMPREPLY=($(compgen -d -- "$cur"))
    fi

    # If there's only one completion and it's a directory, add a trailing slash
    if [[ ${#COMPREPLY[@]} -eq 1 && -d "${COMPREPLY[0]}" ]]; then
      COMPREPLY[0]="${COMPREPLY[0]}/"
    fi
  }

# Register the completion function
complete -o nospace -F _set_wallpaper_completions set-wallpaper

