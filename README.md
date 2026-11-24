# Dotfiles

Personal Hyprland, Waybar, Rofi, Kitty, Waypaper, and Zsh configuration, managed with [chezmoi](https://www.chezmoi.io/).

These are personal configs, not a one-command installer. Review and adapt them for your machine before applying.

## What's included

- Hyprland configuration and helper scripts
- Waybar panel and styling
- Rofi launcher and theme
- Kitty terminal
- Waypaper settings
- Zsh startup, aliases, functions, and history search that leaves the cursor at the end of the recalled command

Wallpaper files are not included. The wallpaper picker looks in `~/Pictures/Wallpapers` and `/usr/share/wallpapers`.

## Core software

Install the equivalent packages for your distribution:

- Hyprland and `hyprland-huiutils` (the Lua configuration uses the helper library)
- Waybar, Rofi, Kitty, Hyprpaper, Waypaper, and Hypridle
- Hyprland and GTK XDG desktop portal backends, plus `xdg-desktop-portal`
- `hyprpolkitagent`
- `wl-clipboard`, `grim`, and `slurp` for clipboard and screenshots
- NetworkManager applet and connection editor
- `brightnessctl`, WirePlumber (`wpctl`), and `systemctl` for media, brightness, and idle actions
- Firefox and Nautilus for the browser and file manager keybindings
- Zsh, Starship, Zinit, fzf, zoxide, and fastfetch for the shell configuration
- JetBrainsMono Nerd Font and the Bibata Modern Ice cursor theme

The Waybar battery module expects battery `BAT0` and adapter `ADP0`. Change these names if your hardware uses different power-supply names. The Hyprland monitor rule currently targets `eDP-1`; change it for a different display. The cursor startup command also expects `Bibata-Modern-Ice` to be installed.

## Ubuntu notes

Hyprland packaging and version availability depend on the Ubuntu release. Check the [official Hyprland installation guide](https://wiki.hypr.land/getting-started/installation/) and use the instructions for your exact Ubuntu version. Do not use Fedora package names such as `akmod-nvidia` on Ubuntu. Install NVIDIA drivers through Ubuntu's recommended driver tooling when needed; NVIDIA/Wayland behavior depends on the driver and system configuration.

Ubuntu package names can differ from Fedora names, and some components may not be available in the enabled Ubuntu repositories on older releases. Avoid mixing random PPAs or build instructions from different Hyprland versions: Hyprland and its companion libraries need compatible versions. If a component is unavailable, follow its upstream installation instructions for the Ubuntu release rather than substituting a Fedora command.

For a laptop with NVIDIA graphics, test the Ubuntu-provided Hyprland and driver combination before copying additional NVIDIA environment variables or kernel-module setup from another distro.

## Before applying on another computer

Some tracked settings currently contain this machine's absolute `/home/bassel` paths, and the idle script is invoked using one of them. Replace those paths with `$HOME`-based paths (or portable relative paths) before applying this repo under another username. Review these files in particular:

- `dot_config/hypr/hypridle.conf`
- `dot_config/rofi/config.rasi`
- `dot_config/waypaper/config.ini`

Also review the monitor name and Waybar battery names above. Then preview changes before applying:

```sh
chezmoi init <YOUR_GITHUB_USERNAME>
chezmoi diff
chezmoi apply
```

Install packages before applying the configs, then log into the Hyprland session. Keep this repository private if it contains personal details you do not want public.

## Optional tools

Neovim, Vim, Yazi, VLC, htop/btop, Cargo, Node.js/npm, and Lua are personal tools rather than requirements for starting the configured desktop. Install them only if you want those tools too.
