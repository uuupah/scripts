#! /bin/bash
# TODO set defaults
# TODO make a screenshots folder if it doesnt exist
source ~/.config/slurp/colours.sh

SCREENSHOTFILE=$(xdg-user-dir PICTURES)/screenshots/screenshot_$(date +%Y_%m_%d_%H_%M_%S).png

hyprctl keyword decoration:dim_inactive false
echo $marquee
echo $background
grim -g "$(slurp -d -b $background  -c $marquee)" $SCREENSHOTFILE
wl-copy < $SCREENSHOTFILE && notify-send "screenshot copied to clipboard" -i $SCREENSHOTFILE
hyprctl keyword decoration:dim_inactive true
