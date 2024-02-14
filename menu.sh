#!/bin/bash

# base rofi direcory
ROFI_DIR="$HOME/.config/rofi"
rofi_command="rofi -theme $ROFI_DIR/themes/launcher.rasi -scroll-method 1 -no-lazy-grab -p ssh"

# change input language to us_en so i do not need to change it myself (workd only for gnome obviously)
# in inputSources[n] 'n' should be substituted to number of us input source (indexed from 0)
# find that with 'gsettings get org.gnome.desktop.input-sources sources'
gdbus call --session --dest org.gnome.Shell --object-path /org/gnome/Shell --method org.gnome.Shell.Eval "imports.ui.status.keyboard.getInputSourceManager().inputSources[0].activate()"


# parsing all.txt to three separate arrays.
# example of all.txt string:
# 'IP              :HOSTNAME :SSH COMMAND
# '212.98.160.50   :ns1.bn.by:ssh root@212.98.160.50'
mapfile -t addresses < <(cut -d':' -f1 $ROFI_DIR/all.txt)
mapfile -t hostnames < <(cut -d':' -f2 $ROFI_DIR/all.txt)
mapfile -t commands < <(cut -d':' -f3 $ROFI_DIR/all.txt)


# Passing strings in the form of 'IP\tHOSTNAME\n' to the $rofi_comand.
# It spawns a menu, than gets the second column from chosen string to the $chosen  
chosen=$(paste -d'\t' <(printf "   %s\n" "${addresses[@]}") <(printf "%s\n" "${hostnames[@]}") | $rofi_command -dmenu | awk '{print $2}')


# do nothing if nothing was chosen
if [[ $chosen == "" ]]; then exit; fi


# get index of the chosen address to use later with commands array. Workaround since i did not figure out multidimentional arrays in bash >_<
index=1
for i in "${!hostnames[@]}"; do
    if [[ "${hostnames[$i]}" == "$chosen" ]]; then
        index=$i
        break
    fi
done


# execute command in new tab of guake 
guake --show -n ${hostnames[$index]} -e "${commands[$index]}"





# gnome-terminal in new window
#gnome-terminal --tab -e "${commands[$chosen_command_index]}"

# gnome-terminal in current window as new tab, needs xdotools
#WID=$(xprop -root | grep "_NET_ACTIVE_WINDOW(WINDOW)"| awk '{print $5}')
#xdotool windowfocus $WID
#xdotool key ctrl+shift+t
#wmctrl -i -a $WID
#sleep 1; xdotool type --delay 1 --clearmodifiers "${commands[$chosen_command_index]}"; xdotool key Return;




