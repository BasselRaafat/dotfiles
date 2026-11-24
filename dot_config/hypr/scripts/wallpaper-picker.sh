#!/usr/bin/env bash
set -euo pipefail

selection="$({
    for wallpaper_dir in "$HOME/Pictures/Wallpapers" /usr/share/wallpapers; do
        [[ -d "$wallpaper_dir" ]] || continue
        find "$wallpaper_dir" -type f \
            \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) \
            -print0
    done |
        sort -z |
        while IFS= read -r -d '' path; do
            if [[ "$path" == /usr/share/wallpapers/* ]]; then
                relative_path="${path#/usr/share/wallpapers/}"
                collection="${relative_path%%/*}"
                label="$collection — ${path##*/}"
            else
                label="${path##*/}"
            fi
            # Keep the full path as the selected value, show a friendly name,
            # and let Rofi render the image itself as the row icon.
            printf '%s\0icon\x1f%s\x1fdisplay\x1f%s\n' "$path" "$path" "$label"
        done
} | rofi -dmenu -i -p 'Wallpaper' -show-icons -hover-select \
    -theme-str 'window { width: 80%; } listview { columns: 3; lines: 3; } element { orientation: vertical; } element-icon { size: 8em; }')"

[[ -n "$selection" ]] || exit 0
wallpaper_path="$selection"

hyprctl hyprpaper wallpaper "eDP-1, $wallpaper_path, cover"

cat > "$HOME/.config/hypr/wallpaper-current.conf.tmp" <<EOF
wallpaper {
    monitor = eDP-1
    path = $wallpaper_path
    fit_mode = cover
}
EOF
mv "$HOME/.config/hypr/wallpaper-current.conf.tmp" \
    "$HOME/.config/hypr/wallpaper-current.conf"
