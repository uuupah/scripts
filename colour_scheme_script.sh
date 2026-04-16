#!/usr/bin/env bash

homedir="/home/uuu"

hextohsl() {
  echo $(magick xc:"$1" -colorspace HSL -format "%[pixel:u]" info: | sed 's/hsl(//;s/%)//g;s/)//' | awk -F',' '{printf "%.0f,%.0f,%.0f\n", $1, $2, $3}')
}

# depth 8 gives you single precision (6 character) hex
hsltohex() {
  echo $(magick canvas:"hsl($1,$2%,$3%)" -depth 8 -format "%[hex:u]" info:)
}

#TODO check that the schemes folder is here and if not clone it in
#TODO allow for pywal or tinty to generate colours

base16schemes=$(ls -w 1 "${homedir}/scripts/schemes/base16" | sed 's/\.yaml//g' | sed 's/^/[bs16] /g')
base24schemes=$(ls -w 1 "${homedir}/scripts/schemes/base24" | sed 's/\.yaml//g' | sed 's/^/[bs24] /g')
customschemes=$(ls -w 1 "${homedir}/.config/colours/custom_base16" | sed 's/\.yaml//g' | sed 's/^/[cstm] /g')

# TODO this requires a little more fuss to make custom schemes work
schemes="${base16schemes}
${base24schemes}
${customschemes}"

selectedscheme=$(printf '%s/n' "$schemes" | tofi) || exit 0

# prompt user for a theme color
themecoloroptions="gray
foreground
white
red
orange
yellow
green
cyan
blue
magenta
special"

# *16 for the character height, +10 for the padding and border on tofi
height=$(($((12*16))+10))

themecolor=$(printf "%s\n" "$themecoloroptions" | tofi --prompt-text "sel: " --height "$height" --num-results "13")

# TODO set a default themecolour if one isnt selected - probably just blue

themetype=$(echo ${selectedscheme} | cut -c1-6)
echo themetype ${themetype}

case "$themetype" in
  "[bs16]")
  themelocation=${homedir}/scripts/schemes/base16/$(echo $selectedscheme | cut -c 8-).yaml
  ;;
  "[bs24]")
  themelocation=${homedir}/scripts/schemes/base24/$(echo $selectedscheme | cut -c 8-).yaml
  ;;
  "[cstm]")
  themelocation=${homedir}/.config/colours/custom_base16/$(echo $selectedscheme | cut -c 8-).yaml
  ;;
esac

echo themelocation ${themelocation}

base00=$(cat "${themelocation}" | yq .palette.base00)
base01=$(cat "${themelocation}" | yq .palette.base01)
base02=$(cat "${themelocation}" | yq .palette.base02)
base03=$(cat "${themelocation}" | yq .palette.base03)
base04=$(cat "${themelocation}" | yq .palette.base04)
base05=$(cat "${themelocation}" | yq .palette.base05)
base06=$(cat "${themelocation}" | yq .palette.base06)
base07=$(cat "${themelocation}" | yq .palette.base07)
base08=$(cat "${themelocation}" | yq .palette.base08)
base09=$(cat "${themelocation}" | yq .palette.base09)
base0A=$(cat "${themelocation}" | yq .palette.base0A)
base0B=$(cat "${themelocation}" | yq .palette.base0B)
base0C=$(cat "${themelocation}" | yq .palette.base0C)
base0D=$(cat "${themelocation}" | yq .palette.base0D)
base0E=$(cat "${themelocation}" | yq .palette.base0E)
base0F=$(cat "${themelocation}" | yq .palette.base0F)

IFS=',' read -r -a blackhsl <<< "$(hextohsl "$black")"

blacksatstep=1
blacklumstep=3

# TODO figure out the rest of the background colours using magick colorize instead of hsl hacking
backgrounddim="#$(magick xc:"${base00}" -fill black -colorize 22% -depth 8 -format "%[hex:u]" info:)"
background0="#$(hsltohex "${blackhsl[0]}" $((${blackhsl[1]}+($blacksatstep*4))) $((${blackhsl[2]}-($blacklumstep*4))))"
background1="#$(hsltohex "${blackhsl[0]}" $((${blackhsl[1]}+($blacksatstep*3))) $((${blackhsl[2]}-($blacklumstep*3))))"
background2="#$(hsltohex "${blackhsl[0]}" $((${blackhsl[1]}+($blacksatstep*2))) $((${blackhsl[2]}-($blacklumstep*2))))"
background3="#$(hsltohex "${blackhsl[0]}" $((${blackhsl[1]}+$blacksatstep)) $((${blackhsl[2]}-$blacklumstep)))"
background4="#$black"
background5="#$(hsltohex "${blackhsl[0]}" $((${blackhsl[1]}-blacksatstep)) $((${blackhsl[2]}+blacklumstep)))"

# these are not quite there but theyre pretty damn close
backgroundred="#$(magick xc:"${base08}" -fill "${backgrounddim}" -colorize 75% -depth 8 -format "%[hex:u]" info:)"
backgroundgreen="#$(magick xc:"${base0B}" -fill "${backgrounddim}" -colorize 75% -depth 8 -format "%[hex:u]" info:)"
backgroundyellow="#$(magick xc:"${base0A}" -fill "${backgrounddim}" -colorize 75% -depth 8 -format "%[hex:u]" info:)"
backgroundblue="#$(magick xc:"${base0D}" -fill "${backgrounddim}" -colorize 75% -depth 8 -format "%[hex:u]" info:)"

darkestbackground= #TODO base11 or generated
dimbackground="$backgrounddim" #TODO base10 or generated
background="$base00" #base00
lightbackground="$base01"
grey="$base03" #base03
lightgrey="$base04" #base04
foreground="$base05" #base05
black="$base02" #base02
red="$base08" #base08
orange="$base09" #base09
yellow="$base0A" #base0A
green="$base0B" #base0B
cyan="$base0C" #base0C
blue="$base0D" #base0D
magenta="$base0E" #base0E
white="$base06" #base06
brightblack="$base02" #TODO
brightred="$base08" #TODO base12
brightyellow="$base0A" #TODO base13
brightgreen="$base0B" #TODO base14
brightcyan="$base0C" #TODO base15
brightblue="$base0D" #TODO base16
brightmagenta="$base0E" #TODO base17
brightwhite="$base06" #TODO
dimblack="$base02" #TODO
dimred="$backgroundred" #generated
dimyellow="$backgroundyellow" #generated
dimgreen="$backgroundgreen" #generated
dimcyan="$backgroundblue" #TODO
dimblue="$backgroundblue" #generated
dimmagenta="$backgroundblue" #TODO
dimwhite="$base06" #TODO

# TODO 🚨 BAD SOLUTION ALERT 🚨
case "$themecolor" in
  "gray")
  basethemecolor=${base03}
  ;;
  "foreground")
  basethemecolor=${base05}
  ;;
  "white")
  basethemecolor=${base06}
  ;;
  "red")
  basethemecolor=${base08}
  ;;
  "orange")
  basethemecolor=${base09}
  ;;
  "yellow")
  basethemecolor=${base0A}
  ;;
  "green")
  basethemecolor=${base0B}
  ;;
  "cyan")
  basethemecolor=${base0C}
  ;;
  "blue")
  basethemecolor=${base0D}
  ;;
  "magenta")
  basethemecolor=${base0E}
  ;;
  "special")
  basethemecolor=${base0F}
  ;;
esac

# alacritty
alacrittyconfig="[colors.primary]
foreground = \"$foreground\"
background = \"$background\"

[colors.normal]
black = \"$black\"
red = \"$red\"
green = \"$green\"
yellow = \"$yellow\"
blue = \"$blue\"
magenta = \"$magenta\"
cyan = \"$cyan\"
white = \"$white\"

[colors.bright]
black = \"$brightblack\"
red = \"$brightred\"
green = \"$brightgreen\"
yellow = \"$brightyellow\"
blue = \"$brightblue\"
magenta = \"$brightmagenta\"
cyan = \"$brightcyan\"
white = \"$brightwhite\"

[colors.dim]
black = \"$dimblack\"
red = \"$dimred\"
green = \"$dimgreen\"
yellow = \"$yellow\"
blue = \"$dimblue\"
magenta = \"$dimmagenta\"
cyan = \"$dimcyan\"
white = \"$dimwhite"\"

rm ${homedir}/.config/alacritty/themes/uuu.toml
touch ${homedir}/.config/alacritty/themes/uuu.toml
printf "${alacrittyconfig}" >> ${homedir}/.config/alacritty/themes/uuu.toml
# i dont love the below as a solution but it works to force a refresh on the alacritty config
printf " " >> ${homedir}/.config/alacritty/alacritty.toml
truncate -s-1 ${homedir}/.config/alacritty/alacritty.toml

# waybar (this feels dodgy but it works)
# TODO 🚨 FIX THE HOVER FIELDS 🚨
waybarconfig="@define-color bg ${background};
@define-color fg ${foreground};
@define-color im ${red};"

printf "${waybarconfig}" | tee ${homedir}/.config/waybar/colors.css > /dev/null

# niri
niriconfig="output \"*\" {
	background-color \"${background}\"
} 

layout {
	border {
		active-color \"${green}\"
		inactive-color \"${background}\"
		urgent-color \"${red}\"
	}
}

overview {
	backdrop-color \"${background}\"
}"

printf "${niriconfig}" > ${homedir}/.config/niri/colors.kdl

# tofi
toficonfig="background-color=${background}
text-color=${foreground}
border-color=${foreground}
selection-color=${background}
selection-background=${foreground}"

rm ${homedir}/.config/tofi/themes/uuu
touch ${homedir}/.config/tofi/themes/uuu
printf "${toficonfig}" >> ${homedir}/.config/tofi/themes/uuu

# dunst
dunstconfig="
[global]
    frame_color = \"${foreground}\"

[urgency_low]
    background = \"${background}\"
    foreground = \"${foreground}\"
    highlight = \"${green}\"

[urgency_normal]
    background = \"${background}\"
    foreground = \"${foreground}\"
    highlight = \"${green}\"

[urgency_critical]
    background = \"${backgroundred}\"
    foreground = \"${foreground}\"
    highlight = \"${brightred}\""

printf "${dunstconfig}" > ${homedir}/.config/dunst/dunstcolors
${homedir}/.config/dunst/dunstcombiner
killall dunst
notify-send -u low "dunst test" "low urgency"
notify-send -u normal "dunst test" "normal urgency"
notify-send -t 10000 -u critical "dunst test" "critical urgency"

# sddm
# sddmconfig="background=\"${background}\"
# foreground=\"${foreground}\"
# dim=\"${black}\""

sddmconfig="background=\"#000000\"
foreground=\"#D3D3D3\"
dim=\"#888888\""

cat ${homedir}/.config/sddm/themerules.conf > /usr/share/sddm/themes/uuusddm/theme.conf
printf "${sddmconfig}" >> /usr/share/sddm/themes/uuusddm/theme.conf

echo basethemecolor "$basethemecolor"

# gtk
gtk2config="gtk-color-scheme = \"text_color:${foreground}
base_color:${dimbackground}
fg_color:${foreground}
bg_color:${dimbackground}
selected_fg_color:${foreground}
selected_bg_color:${basethemecolor}
titlebar_fg_color:${foreground}
titlebar_bg_color:${background}
menu_color:${lightbackground}
tooltip_fg_color:${foreground}
tooltip_bg_color:${black}
link_color:${cyan}
visited_link_color:${magenta}\""

gtk3config="@define-color base00 ${base00};
@define-color base01 ${base01};
@define-color base02 ${base02};
@define-color base03 ${base03};
@define-color base04 ${base04};
@define-color base05 ${base05};
@define-color base06 ${base06};
@define-color base07 ${base07};
@define-color base08 ${base08};
@define-color base09 ${base09};
@define-color base0A ${base0A};
@define-color base0B ${base0B};
@define-color base0C ${base0C};
@define-color base0D ${base0D};
@define-color base0E ${base0E};
@define-color base0F ${base0F};

@define-color theme_color ${basethemecolor};"

printf "${gtk2config}" > "${homedir}/.themes/uuu/colorsrc"
printf "${gtk3config}" > "${homedir}/.themes/uuu/colors.css"

theme=$(gsettings get org.gnome.desktop.interface gtk-theme)
gsettings set org.gnome.desktop.interface gtk-theme ''
sleep 1
gsettings set org.gnome.desktop.interface gtk-theme $theme

# slurp
slurpconfig="#!/usr/bin/env bash
marquee=${foreground:1}
background=${foreground:1}55
text=${foreground:1}"

printf "${slurpconfig}" > "${homedir}/.config/slurp/colours.sh"

#TODO hyprlock

#TODO hyprland borders

#TODO firefox / librewolf
# # "theme color" overused
# # url bar grey is too light and doesnt fit theme (i think)
# # text too white

#TODO bat

# zed
zedconfig="{
  \"\$schema\": \"https://zed.dev/schema/themes/v0.1.0.json\",
  \"name\": \"uuu\",
  \"author\": \"uuu\",
  \"themes\": [
    {
      \"name\": \"uuu\",
      \"appearance\": \"dark\",
      \"style\": {
        \"border\": \"${backgrounddim}\",
        \"border.variant\": \"${backgrounddim}\",
        \"border.focused\": \"${background}\",
        \"border.selected\": \"${backgrounddim}\",
        \"border.transparent\": \"${backgrounddim}\",
        \"border.disabled\": \"${backgrounddim}\",

        \"elevated_surface.background\": \"${black}\",
        \"surface.background\": \"${background}\",
        \"background\": \"${background}\",

        \"element.background\": \"${backgroundgreen}\",
        \"element.hover\": \"${background}\",
        \"element.active\": null,
        \"element.selected\": \"${lightbackground}\",
        \"element.disabled\": null,

        \"drop_target.background\": \"${black}\",

        \"ghost_element.background\": null,
        \"ghost_element.hover\": \"${background}00\",
        \"ghost_element.active\": null,
        \"ghost_element.selected\": \"${lightbackground}80\",
        \"ghost_element.disabled\": null,

        \"text\": \"${foreground}\",
        \"text.muted\": \"${foreground}60\",
        \"text.placeholder\": null,
        \"text.disabled\": null,
        \"text.accent\": null,

        \"icon\": null,
        \"icon.muted\": null,
        \"icon.disabled\": null,
        \"icon.placeholder\": null,
        \"icon.accent\": null,

        \"status_bar.background\": \"${dimbackground}\",

        \"title_bar.background\": \"${background}\",
        \"title_bar.inactive_background\": \"${background}\",

        \"toolbar.background\": \"${background}\",

        \"tab_bar.background\": \"${dimbackground}\",
        \"tab.inactive_background\": \"${dimbackground}\",
        \"tab.active_background\": \"${background}\",

        \"search.match_background\": null,

        \"panel.background\": \"${background}\",
        \"panel.focused_border\": null,
        \"pane.focused_border_hover\": null,
        \"panel.indent_guide\": \"${grey}\",
        \"panel.indent_guide_active\": \"${grey}\",
        \"panel.indent_guide_hover\": \"${grey}\",

        \"scrollbar.thumb.background\": \"${lightbackground}80\",
        \"scrollbar.thumb.hover_background\": \"${lightbackground}\",
        \"scrollbar.thumb.border\": \"${lightbackground}80\",
        \"scrollbar.track.background\": \"${background}\",
        \"scrollbar.track.border\": \"${background}00\",

        \"editor.foreground\": \"${foreground}\",
        \"editor.background\": \"${background}\",
        \"editor.gutter.background\": \"${background}\",
        \"editor.subheader.background\": null,
        \"editor.active_line.background\": \"${lightbackground}90\",
        \"editor.highlighted_line.background\": null,
        \"editor.line_number\": \"${grey}\",
        \"editor.active_line_number\": \"${foreground}\",
        \"editor.invisible\": null,
        \"editor.wrap_guide\": \"${backgrounddim}\",
        \"editor.active_wrap_guide\": \"${backgrounddim}\",
        \"editor.document_highlight.read_background\": null,
        \"editor.document_highlight.write_background\": null,
        \"editor.indent_guide\": \"${grey}\",
        \"editor.indent_guide_active\": \"${grey}\",

        \"terminal.background\": \"${background}\",
        \"terminal.foreground\": \"${foreground}\",
        \"terminal.bright_foreground\": \"${brightwhite}\",
        \"terminal.dim_foreground\": \"${dimwhite}\",
        \"terminal.ansi.black\": \"${black}\",
        \"terminal.ansi.bright_black\": \"${brightblack}\",
        \"terminal.ansi.dim_black\": \"${dimblack}\",
        \"terminal.ansi.red\": \"${red}\",
        \"terminal.ansi.bright_red\": \"${brightred}\",
        \"terminal.ansi.dim_red\": \"${dimred}\",
        \"terminal.ansi.green\": \"${green}\",
        \"terminal.ansi.bright_green\": \"${brightgreen}\",
        \"terminal.ansi.dim_green\": \"${dimgreen}\",
        \"terminal.ansi.yellow\": \"${yellow}\",
        \"terminal.ansi.bright_yellow\": \"${brightyellow}\",
        \"terminal.ansi.dim_yellow\": \"${dimyellow}\",
        \"terminal.ansi.blue\": \"${blue}\",
        \"terminal.ansi.bright_blue\": \"${brightblue}\",
        \"terminal.ansi.dim_blue\": \"${dimblue}\",
        \"terminal.ansi.magenta\": \"${magenta}\",
        \"terminal.ansi.bright_magenta\": \"${brightmagenta}\",
        \"terminal.ansi.dim_magenta\": \"${dimmagenta}\",
        \"terminal.ansi.cyan\": \"${cyan}\",
        \"terminal.ansi.bright_cyan\": \"${brightcyan}\",
        \"terminal.ansi.dim_cyan\": \"${dimcyan}\",
        \"terminal.ansi.white\": \"${foreground}\",
        \"terminal.ansi.bright_white\": \"${brightwhite}\",
        \"terminal.ansi.dim_white\": \"${dimwhite}\",
        \"link_text.hover\": \"${green}c0\",
        \"conflict\": \"${magenta}a0\",
        \"conflict.background\": null,
        \"conflict.border\": null,
        \"created\": \"${green}a0\",
        \"created.background\": null,
        \"created.border\": null,
        \"deleted\": \"${red}a0\",
        \"deleted.background\": null,
        \"deleted.border\": null,
        \"error\": \"${red}\",
        \"error.background\": \"${dimred}\",
        \"error.border\": null,
        \"hidden\": \"${grey}\",
        \"hidden.background\": null,
        \"hidden.border\": null,
        \"hint\": \"${grey}a0\",
        \"hint.background\": null,
        \"hint.border\": null,
        \"ignored\": \"${foreground}20\",
        \"ignored.background\": null,
        \"ignored.border\": null,
        \"info\": \"${blue}\",
        \"info.background\": \"${blue}20\",
        \"info.border\": null,
        \"modified\": \"${blue}a0\",
        \"modified.background\": null,
        \"modified.border\": null,
        \"predictive\": \"${grey}\",
        \"predictive.background\": null,
        \"predictive.border\": null,
        \"renamed\": null,
        \"renamed.background\": null,
        \"renamed.border\": null,
        \"success\": null,
        \"success.background\": null,
        \"success.border\": null,
        \"unreachable\": null,
        \"unreachable.background\": null,
        \"unreachable.border\": null,
        \"warning\": \"${orange}\",
        \"warning.background\": \"${dimorange}\",
        \"warning.border\": null,
        \"players\": [
          {
            \"cursor\": \"${foreground}\",
            \"selection\": \"${black}\",
            \"background\": \"${black}\"
          }
        ],
        \"syntax\": {
          \"attribute\": {
            \"color\": \"${yellow}\",
            \"font_style\": null,
            \"font_weight\": null
          },
          \"constant\": {
            \"color\": \"${magenta}\",
            \"font_style\": null,
            \"font_weight\": null
          },
          \"constructor\": {
            \"color\": \"${magenta}\",
            \"font_style\": null,
            \"font_weight\": null
          },
          \"comment\": {
            \"color\": \"${grey}a0\",
            \"font_style\": \"italic\",
            \"font_weight\": null
          },
          \"function\": {
            \"color\": \"${green}\",
            \"font_style\": null,
            \"font_weight\": null
          },
          \"keyword\": {
            \"color\": \"${red}\",
            \"font_style\": null,
            \"font_weight\": null
          },
          \"number\": {
            \"color\": \"${magenta}\",
            \"font_style\": null,
            \"font_weight\": null
          },
          \"operator\": {
            \"color\": \"${orange}\",
            \"font_style\": null,
            \"font_weight\": null
          },
          \"property\": {
            \"color\": \"${cyan}\",
            \"font_style\": null,
            \"font_weight\": null
          },
          \"string\": {
            \"color\": \"${yellow}\",
            \"font_style\": null,
            \"font_weight\": null
          },
          \"string.escape\": {
            \"color\": \"${green}\",
            \"font_style\": null,
            \"font_weight\": null
          },
          \"type\": {
            \"color\": \"${blue}\",
            \"font_style\": null,
            \"font_weight\": null
          }
        }
      }
    }
  ]
}"

printf "${zedconfig}" > "${homedir}/.config/zed/themes/uuu.json"

# yazi
yaziconfig="[mgr]
cwd = { fg = \"${base0C}\" }

hovered = { reversed = true }
preview_hoverd = { underline = true }

find_keyword = { bold = true, fg = \"${base0A}\" }
find_position = { fg = \"${base0E}\" }

marker_copied = { fg = \"${base0B}\", bg = \"${base0B}\" }
marker_cut = { fg = \"${base08}\", bg = \"${base08}\" }
marker_selected = { fg = \"${base0A}\", bg = \"${base0A}\" }

tab_inactive = { fg = \"${base05}\" }
tab_active = { fg = \"${base00}\", bg = \"${base05}\"}

count_copied = { fg = \"${base00}\", bg = \"${base0B}\" }
count_cut = { fg = \"${base00}\", bg = \"${base08}\" }
count_selected = { fg = \"${base00}\", bg = \"${base0A}\" }

border_style = { fg = \"${base0D}\" }

[mode]
normal_main = { fg = \"${base00}\", bg = \"${base0D}\", bold = true }
normal_alt = { fg = \"${base0D}\", bg = \"${base02}\" }

select_alt = { fg = \"${base0E}\", bg = \"${base02}\" }
select_main = { fg = \"${base00}\", bg = \"${base0E}\", bold = true }

unset_main = { fg = \"${base00}\", bg = \"${base08}\", bold = true }
unset_alt = { fg = \"${base08}\", bg = \"${base02}\" }

[status]
perm_exec = { fg = \"${base0B}\" }
perm_read = { fg = \"${base0A}\" }
perm_sep = { fg = \"${base0C}\" }
perm_type = { fg = \"${base0D}\" }
perm_write = { fg = \"${base08}\" }

progress_error = { fg = \"${base08}\", bg = \"${base00}\" }
progress_label = { fg = \"${base05}\", bg = \"${base00}\" }
progress_normal = { fg = \"${base05}\", bg = \"${base00}\" }

[pick]
active = { fg = \"${base0E}\" }
border = { fg = \"${base0D}\" }
inactive = { fg = \"${base05}\" }

[task]
title = { fg = \"${base0D}\" }
border = { fg = \"${base0D}\" }
hovered = { fg = \"${base05}\", bg = \"${base02}\" }

[input]
border = { fg = \"${base0D}\" }
selected = { bg = \"${base02}\" }

[help]
desc = { fg = \"${base05}\" }
on = { fg = \"${base0C}\" }
run = { fg = \"${base0E}\" }
hovered = { reversed = true, bold = true }
footer = { fg = \"${base02}\", bg = \"${base05}\" }

[which]
mask = { bg = \"${base02}\" }
desc = { fg = \"${base05}\" }
cand = { fg = \"${base0C}\" }
rest = { fg = \"${base0F}\" }

separator_style = { fg = \"${base04}\" }

[notify]
title_info = { fg = \"${base0C}\" }
title_warn = { fg = \"${base0A}\" }
title_error = { fg = \"${base08}\" }

[filetype]
rules = [
  { mime = \"image/*\", fg = \"${base0C}\" },
  { mime = \"{audio, video}/*\", fg = \"${base0A}\" },

  { mime = \"application/{pdf,doc,rtf}\", fg = \"${base0B}\" },

  { mime = \"application/{{zip,rar,7z*,tar,gzip,xz,zstd,bzip*,lzma,compress,archive,cpio,arj,xar,ms-cab*},\", fg = \"${base0E}\" },

  { mime = \"inode/directory\", fg = \"${base0D}\" },
  { mime = \"*\", fg = \"${base05}\" },
]"

printf "${yaziconfig}" > "${homedir}/.config/yazi/flavors/theme.toml"

# obsidian
obsidianconfig=":root {
  --dimbackground: ${base00};
  --base00: ${base00};
  --base01: ${base01};
  --base02: ${base02};
  --base03: ${base03};
  --base04: ${base04};
  --base05: ${base05};
  --base06: ${base06};
  --base07: ${base07};
  --base08: ${base08};
  --base09: ${base09};
  --base0A: ${base0A};
  --base0B: ${base0B};
  --base0C: ${base0C};
  --base0D: ${base0D};
  --base0E: ${base0E};
}"
printf "${obsidianconfig}" > "${homedir}/sync-obsidian/.obsidian/themes/uuu/themecolors.css"
${homedir}/sync-obsidian/.obsidian/themes/uuu/theme_combiner.sh

#TODO vscode
# 🚨 EXTREMELY BAD CODE ALERT 🚨
# cat $HOME/.config/VSCodium/User/settings.json | \
# jq 'del( ."workbench.colorCustomizations")' | \
# jq '. += {"workbench.colorCustomizations":{}}' | \
# jq '."workbench.colorCustomizations" += {"activityBar.background": "#ffffff"}'

vswindowconfig="// Base colors
\"foreground\": \"${base05}\", //5
\"disabledForeground\": \"${base04}\", //4
\"widget.shadow\": \"${base00}\", //0
\"selection.background\": \"${base0D}\", //D
\"descriptionForeground\": \"${base03}\", //3
\"errorForeground\": \"${base08}\", //8
\"icon.foreground\": \"${base04}\", //4

// Text colors
\"textBlockQuote.background\": \"${base01}\", //1
\"textBlockQuote.border\": \"${base0D}\", //D
\"textCodeBlock.background\": \"${base00}\", //0
\"textLink.activeForeground\": \"${base0C}\", //C
\"textLink.foreground\": \"${base0D}\", //D
\"textPreformat.foreground\": \"${base0D}\", //D
\"textSeparator.foreground\": \"#f0f\",

// Action colors
\"toolbar.hoverBackground\": \"${base02}\", //2
\"toolbar.activeBackground\": \"${base03}\", //3

// Button control
\"button.background\": \"${base0D}\", //D
\"button.foreground\": \"${base07}\", //7
\"button.hoverBackground\": \"${base04}\", //4
\"button.secondaryForeground\": \"${base07}\", //7
\"button.secondaryBackground\": \"${base0E}\", //E
\"button.secondaryHoverBackground\": \"${base04}\", //4
\"checkbox.background\": \"${base00}\", //0
\"checkbox.foreground\": \"${base05}\", //5

// Dropdown control
\"dropdown.background\": \"${base00}\", //0
\"dropdown.listBackground\": \"${base00}\", //0
\"dropdown.foreground\": \"${base05}\", //5

// Input control
\"input.background\": \"${base00}\", //0
\"input.foreground\": \"${base05}\", //5
\"input.placeholderForeground\": \"${base03}\", //3
\"inputOption.activeBackground\": \"${base02}\", //2
\"inputOption.activeBorder\": \"${base09}\", //9
\"inputOption.activeForeground\": \"${base05}\", //5
\"inputValidation.errorBackground\": \"${base08}\", //8
\"inputValidation.errorForeground\": \"${base05}\", //5
\"inputValidation.errorBorder\": \"${base08}\", //8
\"inputValidation.infoBackground\": \"${base0D}\", //D
\"inputValidation.infoForeground\": \"${base05}\", //5
\"inputValidation.infoBorder\": \"${base0D}\", //D
\"inputValidation.warningBackground\": \"${base0A}\", //A
\"inputValidation.warningForeground\": \"${base05}\", //5
\"inputValidation.warningBorder\": \"${base0A}\", //A

// Scrollbar control
\"scrollbar.shadow\": \"${base01}\", //1
\"scrollbarSlider.activeBackground\": \"${base04}\", //4
\"scrollbarSlider.background\": \"${base02}\", //2
\"scrollbarSlider.hoverBackground\": \"${base03}\", //3

// Badge
\"badge.background\": \"${base00}\", //0
\"badge.foreground\": \"${base05}\", //5

// Progress bar
\"progressBar.background\": \"${base03}\", //3

// Lists and trees
\"list.activeSelectionBackground\": \"${base02}\", //2
\"list.activeSelectionForeground\": \"${base05}\", //5
\"list.dropBackground\": \"${base07}\", //7
\"list.focusBackground\": \"${base02}\", //2
\"list.focusForeground\": \"${base05}\", //5
\"list.highlightForeground\": \"${base07}\", //7
\"list.hoverBackground\": \"${base03}\", //3
\"list.hoverForeground\": \"${base05}\", //5
\"list.inactiveSelectionBackground\": \"${base02}\", //2
\"list.inactiveSelectionForeground\": \"${base05}\", //5
\"list.inactiveFocusBackground\": \"${base02}\", //2
\"list.invalidItemForeground\": \"${base08}\", //8
\"list.errorForeground\": \"${base08}\", //8
\"list.warningForeground\": \"${base0A}\", //A
\"listFilterWidget.background\": \"${base00}\", //0
\"listFilterWidget.noMatchesOutline\": \"${base08}\", //8
\"list.filterMatchBackground\": \"${base02}\", //2
\"tree.indentGuidesStroke\": \"${base05}\", //5

// Activity Bar
\"activityBar.background\": \"${base00}\", //0
\"activityBar.foreground\": \"${base05}\", //5
\"activityBar.inactiveForeground\": \"${base03}\", //3
\"activityBarBadge.background\": \"${base0D}\", //D
\"activityBarBadge.foreground\": \"${base07}\", //7
\"activityBar.activeBackground\": \"${base02}\", //2

// Side Bar
\"sideBar.background\": \"${base01}\", //1
\"sideBar.foreground\": \"${base05}\", //5
\"sideBar.dropBackground\": \"${base02}\", //2
\"sideBarTitle.foreground\": \"${base05}\", //5
\"sideBarSectionHeader.background\": \"${base03}\", //3
\"sideBarSectionHeader.foreground\": \"${base05}\", //5

//Minimap
\"minimap.findMatchHighlight\": \"${base0A}\", //A
\"minimap.selectionHighlight\": \"${base02}\", //2
\"minimap.errorHighlight\": \"${base08}\", //8
\"minimap.warningHighlight\": \"${base0A}\", //A
\"minimap.background\": \"${base00}\", //0
\"minimap.selectionOccurrenceHighlight\": \"${base03}\", //3
\"minimapGutter.addedBackground\": \"${base0B}\", //B
\"minimapGutter.modifiedBackground\": \"${base0E}\", //E
\"minimapGutter.deletedBackground\": \"${base08}\", //8

// Editor Groups & Tabs
\"editorGroup.dropBackground\": \"${base02}\", //2
\"editorGroupHeader.noTabsBackground\": \"${base01}\", //1
\"editorGroupHeader.tabsBackground\": \"${base01}\", //1
\"editorGroup.emptyBackground\": \"${base00}\", //0
\"editorGroup.dropIntoPromptForeground\": \"${base05}\", //5
\"editorGroup.dropIntoPromptBackground\": \"${base00}\", //0
\"tab.activeBackground\": \"${base00}\", //0
\"tab.unfocusedActiveBackground\": \"${base00}\", //0
\"tab.activeForeground\": \"${base05}\", //5
\"tab.inactiveBackground\": \"${base01}\", //1
\"tab.inactiveForeground\": \"${base03}\", //3
\"tab.unfocusedActiveForeground\": \"${base04}\", //4
\"tab.unfocusedInactiveForeground\": \"${base03}\", //3
\"tab.hoverBackground\": \"${base02}\", //2
\"tab.unfocusedHoverBackground\": \"${base02}\", //2
\"tab.activeModifiedBorder\": \"${base0D}\", //D
\"tab.inactiveModifiedBorder\": \"${base0D}\", //D
\"tab.unfocusedActiveModifiedBorder\": \"${base0D}\", //D
\"tab.unfocusedInactiveModifiedBorder\": \"${base0D}\", //D
\"editorPane.background\": \"${base00}\", //0

// Editor colors
\"editor.background\": \"${base00}\", //0
\"editor.foreground\": \"${base05}\", //5
\"editorLineNumber.foreground\": \"${base03}\", //3
\"editorLineNumber.activeForeground\": \"${base04}\", //4
\"editorCursor.foreground\": \"${base05}\", //5
\"editor.selectionBackground\": \"${base02}\", //2
\"editor.inactiveSelectionBackground\": \"${base02}\", //2
\"editor.selectionHighlightBackground\": \"${base01}\", //1
\"editor.wordHighlightBackground\": \"${base02}\", //2
\"editor.wordHighlightStrongBackground\": \"${base03}\", //3
\"editor.findMatchBackground\": \"${base0A}\", //A
\"editor.findMatchHighlightBackground\": \"${base09}\", //9
\"editor.findRangeHighlightBackground\": \"${base01}\", //1
\"searchEditor.findMatchBackground\": \"${base0A}\", //A
\"editor.hoverHighlightBackground\": \"${base02}\", //2
\"editor.lineHighlightBackground\": \"${base01}\", //1
\"editorLink.activeForeground\": \"${base0D}\", //D
\"editor.rangeHighlightBackground\": \"${base01}\", //1
\"editorWhitespace.foreground\": \"${base03}\", //3
\"editorIndentGuide.background\": \"${base03}\", //3
\"editorIndentGuide.activeBackground\": \"${base04}\", //4
\"editorInlayHint.background\": \"${base01}\", //1
\"editorInlayHint.foreground\": \"${base05}\", //5
\"editorInlayHint.typeBackground\": \"${base01}\", //1
\"editorInlayHint.typeForeground\": \"${base05}\", //5
\"editorInlayHint.parameterBackground\": \"${base01}\", //1
\"editorInlayHint.parameterForeground\": \"${base05}\", //5
\"editorRuler.foreground\": \"${base03}\", //3

/// CodeLens
\"editorCodeLens.foreground\": \"${base02}\", //2

/// Lightbulb
\"editorLightBulb.foreground\": \"${base0A}\", //A
\"editorLightBulbAutoFix.foreground\": \"${base0D}\", //D

/// Bracket matches
\"editorBracketMatch.background\": \"${base02}\", //2

/// Bracket pair colorization
\"editorBracketHighlight.foreground1\": \"${base08}\", //8
\"editorBracketHighlight.foreground2\": \"${base09}\", //9
\"editorBracketHighlight.foreground3\": \"${base0A}\", //A
\"editorBracketHighlight.foreground4\": \"${base0B}\", //B
\"editorBracketHighlight.foreground5\": \"${base0D}\", //D
\"editorBracketHighlight.foreground6\": \"${base0E}\", //E
\"editorBracketHighlight.unexpectedBracket.foreground\": \"${base0F}\", //F

/// Overview ruler
\"editorOverviewRuler.findMatchForeground\": \"${base0A}\", //A
\"editorOverviewRuler.rangeHighlightForeground\": \"${base03}\", //3
\"editorOverviewRuler.selectionHighlightForeground\": \"${base02}\", //2
\"editorOverviewRuler.wordHighlightForeground\": \"${base07}\", //7
\"editorOverviewRuler.wordHighlightStrongForeground\": \"${base0D}\", //D
\"editorOverviewRuler.modifiedForeground\": \"${base0E}\", //E
\"editorOverviewRuler.addedForeground\": \"${base0B}\", //B
\"editorOverviewRuler.deletedForeground\": \"${base08}\", //8
\"editorOverviewRuler.errorForeground\": \"${base08}\", //8
\"editorOverviewRuler.warningForeground\": \"${base0A}\", //A
\"editorOverviewRuler.infoForeground\": \"${base0C}\", //C
\"editorOverviewRuler.bracketMatchForeground\": \"${base06}\", //6

/// Errors and warnings
\"editorError.foreground\": \"${base08}\", //8
\"editorWarning.foreground\": \"${base0A}\", //A
\"editorInfo.foreground\": \"${base0C}\", //C
\"editorHint.foreground\": \"${base0D}\", //D
\"problemsErrorIcon.foreground\": \"${base08}\", //8
\"problemsWarningIcon.foreground\": \"${base0A}\", //A
\"problemsInfoIcon.foreground\": \"${base0C}\", //C

/// Gutter
\"editorGutter.background\": \"${base00}\", //0
\"editorGutter.modifiedBackground\": \"${base0E}\", //E
\"editorGutter.addedBackground\": \"${base0B}\", //B
\"editorGutter.deletedBackground\": \"${base08}\", //8
\"editorGutter.commentRangeForeground\": \"${base04}\", //4
\"editorGutter.foldingControlForeground\": \"${base05}\", //5

// Diff editor colors
\"diffEditor.insertedTextBackground\": \"#bcdf5920\",
\"diffEditor.removedTextBackground\": \"#ff727220\",
\"diffEditor.diagonalFill\": \"${base02}\", //2

// Editor widget colors
\"editorWidget.foreground\": \"${base05}\", //5
\"editorWidget.background\": \"${base00}\", //0
\"editorSuggestWidget.background\": \"${base01}\", //1
\"editorSuggestWidget.foreground\": \"${base05}\", //5
\"editorSuggestWidget.focusHighlightForeground\": \"${base07}\", //7
\"editorSuggestWidget.highlightForeground\": \"${base0D}\", //D
\"editorSuggestWidget.selectedBackground\": \"${base02}\", //2
\"editorSuggestWidget.selectedForeground\": \"${base06}\", //6
\"editorHoverWidget.foreground\": \"${base05}\", //5
\"editorHoverWidget.background\": \"${base01}\", //1
\"debugExceptionWidget.background\": \"${base01}\", //1
\"editorMarkerNavigation.background\": \"${base01}\", //1
\"editorMarkerNavigationError.background\": \"${base08}\", //8
\"editorMarkerNavigationWarning.background\": \"${base0A}\", //A
\"editorMarkerNavigationInfo.background\": \"${base0D}\", //D
\"editorMarkerNavigationError.headerBackground\": \"${base08}\", //8
\"editorMarkerNavigationWarning.headerBackground\": \"${base0A}\", //A
\"editorMarkerNavigationInfo.headerBackground\": \"${base0C}\", //C

// Peek view colors
// "peekView.border": "#f00",
\"peekViewEditor.background\": \"${base01}\", //1
\"peekViewEditorGutter.background\": \"${base01}\", //1
"peekViewEditor.matchHighlightBackground": "{base09}", //9
\"peekViewResult.background\": \"${base00}\", //0
\"peekViewResult.fileForeground\": \"${base05}\", //5
\"peekViewResult.lineForeground\": \"${base03}\", //3
"peekViewResult.matchHighlightBackground": "{base09}", //9
\"peekViewResult.selectionBackground\": \"${base02}\", //2
\"peekViewResult.selectionForeground\": \"${base05}\", //5
\"peekViewTitle.background\": \"${base02}\", //2
\"peekViewTitleDescription.foreground\": \"${base03}\", //3
\"peekViewTitleLabel.foreground\": \"${base05}\", //5

// Merge conflicts colors
\"merge.currentContentBackground\": \"${base0D}\", //D
\"merge.currentHeaderBackground\": \"${base0D}\", //D
\"merge.incomingContentBackground\": \"${base0B}\", //B
\"merge.incomingHeaderBackground\": \"${base0B}\", //B
\"editorOverviewRuler.currentContentForeground\": \"${base0D}\", //D
\"editorOverviewRuler.incomingContentForeground\": \"${base0B}\", //B
\"editorOverviewRuler.commonContentForeground\": \"${base0F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8F}\", //F

// Panel colors
\"panel.background\": \"${base00}\", //0
\"panel.dropBorder\": \"${base01}\", //1
\"panelTitle.activeForeground\": \"${base05}\", //5
\"panelTitle.inactiveForeground\": \"${base03}\", //3

// Status Bar colors
\"statusBar.background\": \"${base0D}\", //D
\"statusBar.foreground\": \"${base07}\", //7
\"statusBar.debuggingBackground\": \"${base09}\", //9
\"statusBar.debuggingForeground\": \"${base07}\", //7
\"statusBar.noFolderBackground\": \"${base0E}\", //E
\"statusBar.noFolderForeground\": \"${base07}\", //7
\"statusBarItem.activeBackground\": \"${base03}\", //3
\"statusBarItem.hoverBackground\": \"${base02}\", //2
\"statusBarItem.prominentForeground\": \"${base07}\", //7
\"statusBarItem.prominentBackground\": \"${base0E}\", //E
\"statusBarItem.prominentHoverBackground\": \"${base08}\", //8
\"statusBarItem.remoteBackground\": \"${base0B}\", //B
\"statusBarItem.remoteForeground\": \"${base07}\", //7
\"statusBarItem.errorBackground\": \"${base08}\", //8
\"statusBarItem.errorForeground\": \"${base07}\", //7
\"statusBarItem.warningBackground\": \"${base0A}\", //A
\"statusBarItem.warningForeground\": \"${base07}\", //7

// Title Bar colors
\"titleBar.activeBackground\": \"${base00}\", //0
\"titleBar.activeForeground\": \"${base05}\", //5
\"titleBar.inactiveBackground\": \"${base01}\", //1
\"titleBar.inactiveForeground\": \"${base03}\", //3

// Menu Bar colors
\"menubar.selectionForeground\": \"${base05}\", //5
\"menubar.selectionBackground\": \"${base01}\", //1
\"menu.foreground\": \"${base05}\", //5
\"menu.background\": \"${base01}\", //1
\"menu.selectionForeground\": \"${base05}\", //5
\"menu.selectionBackground\": \"${base02}\", //2
\"menu.separatorBackground\": \"${base07}\", //7

// Command Center colors
\"commandCenter.foreground\": \"${base05}\", //5
\"commandCenter.activeForeground\": \"${base07}\", //7
\"commandCenter.background\": \"${base00}\", //0
\"commandCenter.activeBackground\": \"${base01}\", //1
// "commandCenter.border": "#ff0000",

// Notification colors
\"notificationCenterHeader.foreground\": \"${base05}\", //5
\"notificationCenterHeader.background\": \"${base01}\", //1
\"notifications.foreground\": \"${base05}\", //5
\"notifications.background\": \"${base02}\", //2
\"notificationLink.foreground\": \"${base0D}\", //D
\"notificationsErrorIcon.foreground\": \"${base08}\", //8
\"notificationsWarningIcon.foreground\": \"${base0A}\", //A
\"notificationsInfoIcon.foreground\": \"${base0D}\", //D

// Banner colors
\"banner.background\": \"${base02}\", //2
\"banner.foreground\": \"${base05}\", //5
\"banner.iconForeground\": \"${base0D}\", //D

// Extensions colors
\"extensionButton.prominentBackground\": \"${base0B}\", //B
\"extensionButton.prominentForeground\": \"${base07}\", //7
\"extensionButton.prominentHoverBackground\": \"${base02}\", //2
\"extensionBadge.remoteBackground\": \"${base09}\", //9
\"extensionBadge.remoteForeground\": \"${base07}\", //7
\"extensionIcon.starForeground\": \"${base0A}\", //A
\"extensionIcon.verifiedForeground\": \"${base0D}\", //D
\"extensionIcon.preReleaseForeground\": \"${base09}\", //9

// Quick picker colors
\"pickerGroup.foreground\": \"${base03}\", //3
\"quickInput.background\": \"${base01}\", //1
\"quickInput.foreground\": \"${base05}\", //5
\"quickInputList.focusBackground\": \"${base03}\", //3
\"quickInputList.focusForeground\": \"${base07}\", //7
\"quickInputList.focusIconForeground\": \"${base07}\", //7

// Keybinding label colors
\"keybindingLabel.background\": \"${base02}\", //2
\"keybindingLabel.foreground\": \"${base05}\", //5

// Keybinding shortcut table colors
\"keybindingTable.headerBackground\": \"${base02}\", //2
\"keybindingTable.rowsBackground\": \"${base01}\", //1

// Integrated terminal colors
\"terminal.background\": \"${base00}\", //0
\"terminal.foreground\": \"${base05}\", //5
\"terminal.ansiBlack\": \"${base00}\", //0
\"terminal.ansiRed\": \"${base08}\", //8
\"terminal.ansiGreen\": \"${base0B}\", //B
\"terminal.ansiYellow\": \"${base0A}\", //A
\"terminal.ansiBlue\": \"${base0D}\", //D
\"terminal.ansiMagenta\": \"${base0E}\", //E
\"terminal.ansiCyan\": \"${base0C}\", //C
\"terminal.ansiWhite\": \"${base05}\", //5
\"terminal.ansiBrightBlack\": \"${base03}\", //3
\"terminal.ansiBrightRed\": \"${base08}\", //8
\"terminal.ansiBrightGreen\": \"${base0B}\", //B
\"terminal.ansiBrightYellow\": \"${base0A}\", //A
\"terminal.ansiBrightBlue\": \"${base0D}\", //D
\"terminal.ansiBrightMagenta\": \"${base0E}\", //E
\"terminal.ansiBrightCyan\": \"${base0C}\", //C
\"terminal.ansiBrightWhite\": \"${base07}\", //7
\"terminalCursor.foreground\": \"${base05}\", //5
"terminalOverviewRuler.cursorForeground": "#ff0000",
"terminalOverviewRuler.findMatchForeground": "#ff0000",

// Debug colors
\"debugToolBar.background\": \"${base01}\", //1
\"debugView.stateLabelForeground\": \"${base07}\", //7
\"debugView.stateLabelBackground\": \"${base0D}\", //D
\"debugView.valueChangedHighlight\": \"${base0D}\", //D
\"debugTokenExpression.name\": \"${base0E}\", //E
\"debugTokenExpression.value\": \"${base05}\", //5
\"debugTokenExpression.string\": \"${base0B}\", //B
\"debugTokenExpression.boolean\": \"${base09}\", //9
\"debugTokenExpression.number\": \"${base09}\", //9
\"debugTokenExpression.error\": \"${base08}\", //8

// Testing colors
\"testing.iconFailed\": \"${base08}\", //8
\"testing.iconErrored\": \"${base0F}\", //F
\"testing.iconPassed\": \"${base0B}\", //B
\"testing.runAction\": \"${base04}\", //4
\"testing.iconQueued\": \"${base0A}\", //A
\"testing.iconUnset\": \"${base04}\", //4
\"testing.iconSkipped\": \"${base0E}\", //E
\"testing.peekHeaderBackground\": \"${base01}\", //1
\"testing.message.error.decorationForeground\": \"${base05}\", //5
\"testing.message.error.lineBackground\": \"${base08}\", //8
\"testing.message.info.decorationForeground\": \"${base05}\", //5
\"testing.message.info.lineBackground\": \"${base0D}\", //D

// Welcome page colors
\"welcomePage.background\": \"${base00}\", //0
\"welcomePage.progress.background\": \"${base03}\", //3
\"welcomePage.progress.foreground\": \"${base0D}\", //D
\"welcomePage.tileBackground\": \"${base01}\", //1
\"welcomePage.tileHoverBackground\": \"${base02}\", //2
\"walkThrough.embeddedEditorBackground\": \"${base00}\", //0

// Git colors
\"gitDecoration.addedResourceForeground\": \"${base0B}\", //B
\"gitDecoration.modifiedResourceForeground\": \"${base0E}\", //E
\"gitDecoration.deletedResourceForeground\": \"${base08}\", //8
\"gitDecoration.renamedResourceForeground\": \"${base0C}\", //C
\"gitDecoration.stageModifiedResourceForeground\": \"${base0E}\", //E
\"gitDecoration.stageDeletedResourceForeground\": \"${base08}\", //8
\"gitDecoration.untrackedResourceForeground\": \"${base09}\", //9
\"gitDecoration.ignoredResourceForeground\": \"${base03}\", //3
\"gitDecoration.conflictingResourceForeground\": \"${base0A}\", //A
\"gitDecoration.submoduleResourceForeground\": \"${base0F}\", //F

// Settings Editor colors
\"settings.headerForeground\": \"${base05}\", //5
\"settings.modifiedItemIndicator\": \"${base0D}\", //D
\"settings.dropdownBackground\": \"${base01}\", //1
\"settings.dropdownForeground\": \"${base05}\", //5
\"settings.checkboxBackground\": \"${base01}\", //1
\"settings.checkboxForeground\": \"${base05}\", //5
\"settings.rowHoverBackground\": \"${base02}\", //2
\"settings.textInputBackground\": \"${base01}\", //1
\"settings.textInputForeground\": \"${base05}\", //5
\"settings.numberInputBackground\": \"${base01}\", //1
\"settings.numberInputForeground\": \"${base05}\", //5
\"settings.focusedRowBackground\": \"${base02}\", //2
\"settings.headerBorder\": \"${base05}\", //5
\"settings.sashBorder\": \"${base05}\", //5

// Breadcrumbs colors
\"breadcrumb.foreground\": \"${base05}\", //5
\"breadcrumb.background\": \"${base01}\", //1
\"breadcrumb.focusForeground\": \"${base06}\", //6
\"breadcrumb.activeSelectionForeground\": \"${base07}\", //7
\"breadcrumbPicker.background\": \"${base01}\", //1

// Snippets colors
\"editor.snippetTabstopHighlightBackground\": \"${base02}\", //2
\"editor.snippetFinalTabstopHighlightBackground\": \"${base03}\", //3

// Symbol Icons colors
\"symbolIcon.arrayForeground\": \"${base05}\", //5
\"symbolIcon.booleanForeground\": \"${base09}\", //9
\"symbolIcon.classForeground\": \"${base0A}\", //A
"symbolIcon.colorForeground": "#f0f",
\"symbolIcon.constantForeground\": \"${base09}\", //9
\"symbolIcon.constructorForeground\": \"${base0D}\", //D
\"symbolIcon.enumeratorForeground\": \"${base09}\", //9
\"symbolIcon.enumeratorMemberForeground\": \"${base0D}\", //D
\"symbolIcon.eventForeground\": \"${base0A}\", //A
\"symbolIcon.fieldForeground\": \"${base08}\", //8
\"symbolIcon.fileForeground\": \"${base05}\", //5
\"symbolIcon.folderForeground\": \"${base05}\", //5
\"symbolIcon.functionForeground\": \"${base0D}\", //D,
\"symbolIcon.interfaceForeground\": \"${base0D}\", //D
"symbolIcon.keyForeground": "#f0f",
\"symbolIcon.keywordForeground\": \"${base0E}\", //E
\"symbolIcon.methodForeground\": \"${base0D}\", //D
\"symbolIcon.moduleForeground\": \"${base05}\", //5
\"symbolIcon.namespaceForeground\": \"${base05}\", //5
\"symbolIcon.nullForeground\": \"${base0F}\", //F
\"symbolIcon.numberForeground\": \"${base09}\", //9
"symbolIcon.objectForeground": "#f0f",
"symbolIcon.operatorForeground": "#f0f",
"symbolIcon.packageForeground": "#f0f",
\"symbolIcon.propertyForeground\": \"${base05}\", //5
"symbolIcon.referenceForeground": "#f0f",
\"symbolIcon.snippetForeground\": \"${base05}\", //5
\"symbolIcon.stringForeground\": \"${base0B}\", //B
\"symbolIcon.structForeground\": \"${base0A}\", //A
\"symbolIcon.textForeground\": \"${base05}\", //5
"symbolIcon.typeParameterForeground": "#f0f",
"symbolIcon.unitForeground": "#f0f",
\"symbolIcon.variableForeground\": \"${base08}\", //8

// Debug Icons colors
\"debugIcon.breakpointForeground\": \"${base08}\", //8
\"debugIcon.breakpointDisabledForeground\": \"${base04}\", //4
\"debugIcon.breakpointUnverifiedForeground\": \"${base02}\", //2
\"debugIcon.breakpointCurrentStackframeForeground\": \"${base0A}\", //A
\"debugIcon.breakpointStackframeForeground\": \"${base0F}\", //F
\"debugIcon.startForeground\": \"${base0B}\", //B
\"debugIcon.pauseForeground\": \"${base0D}\", //D
\"debugIcon.stopForeground\": \"${base08}\", //8
\"debugIcon.disconnectForeground\": \"${base08}\", //8
\"debugIcon.restartForeground\": \"${base0B}\", //B
\"debugIcon.stepOverForeground\": \"${base0D}\", //D
\"debugIcon.stepIntoForeground\": \"${base0C}\", //C
\"debugIcon.stepOutForeground\": \"${base0E}\", //E
\"debugIcon.continueForeground\": \"${base0B}\", //B
\"debugIcon.stepBackForeground\": \"${base0F}\", //F
\"debugConsole.infoForeground\": \"${base05}\", //5
\"debugConsole.warningForeground\": \"${base0A}\", //A
\"debugConsole.errorForeground\": \"${base08}\", //8
\"debugConsole.sourceForeground\": \"${base05}\", //5
\"debugConsoleInputIcon.foreground\": \"${base05}\", //5

// Notebook colors
\"notebook.editorBackground\": \"${base00}\", //0
\"notebook.cellBorderColor\": \"${base03}\", //3
\"notebook.cellHoverBackground\": \"${base01}\", //1
\"notebook.cellToolbarSeparator\": \"${base02}\", //2
\"notebook.cellEditorBackground\": \"${base00}\", //0
\"notebook.focusedCellBackground\": \"${base02}\", //2
\"notebook.focusedCellBorder\": \"${base0D}\", //D
\"notebook.focusedEditorBorder\": \"${base0D}\", //D
\"notebook.inactiveFocusedCellBorder\": \"${base03}\", //3
\"notebook.selectedCellBackground\": \"${base02}\", //2
\"notebookStatusErrorIcon.foreground\": \"${base08}\", //8
\"notebookStatusRunningIcon.foreground\": \"${base0C}\", //C
\"notebookStatusSuccessIcon.foreground\": \"${base0B}\", //B

// Chart colors
\"charts.foreground\": \"${base05}\", //5
\"charts.lines\": \"${base05}\", //5
\"charts.red\": \"${base08}\", //8
\"charts.blue\": \"${base0D}\", //D
\"charts.yellow\": \"${base0A}\", //A
\"charts.orange\": \"${base09}\", //9
\"charts.green\": \"${base0B}\", //B
\"charts.purple\": \"${base0E}\", //E

// Ports Colors

\"ports.iconRunningProcessForeground\": \"${base09}\" //9"
printf "${vswindowconfig}" > vscode
