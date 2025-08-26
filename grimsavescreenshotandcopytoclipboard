#! /bin/bash

SCREENSHOTFILE=$(xdg-user-dir PICTURES)/screenshots/screenshot_$(date +%Y_%m_%d_%H_%M_%S).png

hyprctl keyword decoration:dim_inactive false
grim -g "$(slurp -d -b D3C6AA55 -c D3C6AA)" $SCREENSHOTFILE
wl-copy < $SCREENSHOTFILE && notify-send "screenshot copied to clipboard" -i $SCREENSHOTFILE
hyprctl keyword decoration:dim_inactive true
