# Dotfiles

Personal Hyprland, Waybar, Rofi, Kitty, Waypaper, and Zsh configuration, managed with [chezmoi](https://www.chezmoi.io/).

These are personal configs, not a universal installer. Review and adapt the hardware-specific settings before applying them.

## What's included

- Hyprland config and helper scripts
- Waybar panel and styling
- Rofi launcher and theme
- Kitty terminal
- Waypaper settings
- Zsh startup, aliases, functions, and history search that leaves the cursor at the end of recalled commands

Wallpapers are not included. The wallpaper picker searches `~/Pictures/Wallpapers` and `/usr/share/wallpapers`.

## Install dependencies

### Ubuntu 26.10

Hyprland's official guide recommends the Ubuntu archive package on 26.10. Enable Universe, update package metadata, and install the desktop components:

```sh
sudo add-apt-repository universe
sudo apt update
sudo apt install \
  hyprland hyprland-guiutils hypridle hyprpaper hyprpolkitagent \
  waybar rofi kitty \
  xdg-desktop-portal xdg-desktop-portal-hyprland xdg-desktop-portal-gtk \
  wl-clipboard grim slurp \
  network-manager-gnome nm-connection-editor \
  brightnessctl wireplumber \
  firefox nautilus \
  zsh starship fzf zoxide fastfetch \
  fonts-jetbrains-mono python3-pipx python3-gi python3-platformdirs \
  python3-pil python3-screeninfo
```

Install Waypaper and its Hyprpaper backend:

```sh
pipx install waypaper
```

The Zsh config bootstraps Zinit and its plugins on the first shell startup. It expects Starship, fzf, and zoxide to be installed as packages above.

Ubuntu 26.04 and older releases may have an outdated Hyprland package or lack some components. Check the [official Hyprland installation guide](https://wiki.hypr.land/getting-started/installation/) for the exact Ubuntu release before installing; don't add arbitrary PPAs or mix packages built for different Hyprland versions.

### Fedora

Enable a Hyprland package source suitable for your Fedora release first. Then install the desktop and shell packages (some Hyprland ecosystem packages may not be in Fedora's default repositories):

```sh
sudo dnf install \
  hyprland hyprland-guiutils hypridle hyprpaper hyprpolkitagent \
  waybar rofi kitty \
  xdg-desktop-portal xdg-desktop-portal-hyprland xdg-desktop-portal-gtk \
  wl-clipboard grim slurp \
  NetworkManager-applet nm-connection-editor \
  brightnessctl wireplumber \
  firefox nautilus \
  zsh starship fzf zoxide fastfetch \
  jetbrains-mono-fonts python3-pipx
```

Waypaper can be installed with `pipx` and uses Hyprpaper as its wallpaper backend:

```sh
pipx install waypaper
```

If Waypaper's Python dependencies fail to build on Fedora, install the Fedora `cairo-gobject-devel` package first, as noted in [Waypaper's install guide](https://anufrievroman.gitbook.io/waypaper/installation).

### Optional NVIDIA driver

NVIDIA is not configured by this dotfiles repo. On Ubuntu, use Ubuntu's driver tool if the computer has NVIDIA graphics:

```sh
sudo ubuntu-drivers install
```

On Fedora, install the NVIDIA driver using the instructions for the Fedora release and its enabled RPM Fusion/COPR setup. Do not use Fedora's `akmod-nvidia` package name on Ubuntu.

## Before applying on another computer

Some tracked files still contain this machine's `/home/bassel` absolute paths. Replace them with portable paths before applying under another username. Review:

- `dot_config/hypr/hypridle.conf`
- `dot_config/rofi/config.rasi`
- `dot_config/waypaper/config.ini`
- `dot_zsh/dot_zshrc` (Starship config path)

Hardware-specific values also need review:

- The Hyprland monitor rule targets `eDP-1` and sets scale to `1.25`.
- The Waybar battery module expects `BAT0` and `ADP0`.
- The cursor command expects the `Bibata-Modern-Ice` cursor theme.
- The wallpaper folder defaults to `~/Pictures/Wallpapers`.

On a new machine, install dependencies, install/configure your cursor theme and wallpapers, then preview and apply the configs:

```sh
chezmoi init <YOUR_GITHUB_USERNAME>
chezmoi diff
chezmoi apply
```

Log out and choose the Hyprland session at the login screen. Keep this repo private if it contains personal details you do not want public.

## Optional tools

Neovim, Vim, Yazi, VLC, htop/btop, Cargo, Node.js/npm, and Lua are personal tools, not requirements for the configured desktop.
