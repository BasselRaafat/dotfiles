-- Small Hyprland setup for Hyprland 0.57+.

local mod = "SUPER"

-- Use 125% scaling on the built-in display.
hl.monitor({ output = "eDP-1", scale = 1.25 })

hl.config({
    input = {
        kb_layout = "us",
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = {
            natural_scroll = true,
            tap_to_click = true,
            disable_while_typing = true,
        },
    },
    general = {
        gaps_in = 0,
        gaps_out = 0,
        border_size = 2,
        ["col.active_border"] = "rgba(00000000)",
        ["col.inactive_border"] = "rgba(484c50ff)",
        layout = "dwindle",
    },
    decoration = {
        rounding = 0,
        active_opacity = 1.0,
        inactive_opacity = 0.95,
        shadow = { enabled = true, range = 4, render_power = 3 },
        blur = { enabled = false },
    },
    animations = { enabled = false },
    dwindle = {
        force_split = 2,
        preserve_split = true,
    },
    misc = { disable_hyprland_logo = true, disable_splash_rendering = true },
    cursor = { enable_hyprcursor = true },
    gestures = {
        workspace_swipe_distance = 200,
        workspace_swipe_cancel_ratio = 0.25,
    },
})

-- Start one bar, wallpaper service, idle manager, and authentication agent.
hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("sh -c 'sleep 1; waypaper --restore --backend hyprpaper --folder $HOME/Pictures/Wallpapers'")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("hyprctl setcursor Bibata-Modern-Ice 24")
    hl.exec_cmd("systemctl --user start hyprpolkitagent.service")
    hl.exec_cmd("nm-applet --indicator")
end)

-- Apps and session controls.
hl.bind(mod .. " + RETURN", hl.dsp.exec_cmd("kitty"))
hl.bind(mod .. " + SPACE", hl.dsp.exec_cmd("rofi -show drun"))
hl.bind(mod .. " + B", hl.dsp.exec_cmd("firefox"))
hl.bind(mod .. " + W", hl.dsp.exec_cmd("waypaper --backend hyprpaper --folder $HOME/Pictures/Wallpapers"))
hl.bind(mod .. " + Q", hl.dsp.window.close())
hl.bind(mod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mod .. " + V", hl.dsp.layout("togglesplit"))
hl.bind(mod .. " + SHIFT + SPACE", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + E", hl.dsp.exec_cmd("nautilus"))
hl.bind("Print", hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | wl-copy --type image/png"))
hl.bind(mod .. " + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(mod .. " + M", hl.dsp.exec_cmd("hyprctl dispatch exit"))

-- Laptop media and backlight keys.
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%-"))
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"))
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 5%+"))

local function focus_adjacent_workspace(step)
    local active = hl.get_active_workspace()
    local current = active and active.id or 1
    local target = current + step
    if target < 1 then return end

    -- Allow moving to an existing workspace from an empty one, but do not
    -- create a new workspace unless the current workspace is occupied.
    if step > 0 and hl.get_workspace(target) == nil
        and #(hl.get_workspace_windows(current) or {}) == 0 then
        return
    end

    hl.dispatch(hl.dsp.focus({ workspace = target }))
end

hl.bind(mod .. " + H", function() focus_adjacent_workspace(-1) end)
hl.bind(mod .. " + L", function() focus_adjacent_workspace(1) end)

-- Keep numbered workspaces compact when an empty workspace disappears.
local compacting_workspaces = false
local compaction_pending = false
local function compact_workspaces()
    if compacting_workspaces then return end

    local workspaces = {}
    for _, workspace in ipairs(hl.get_workspaces() or {}) do
        if type(workspace.id) == "number" and workspace.id > 0 and not workspace.special then
            table.insert(workspaces, workspace)
        end
    end
    table.sort(workspaces, function(a, b) return a.id < b.id end)

    compacting_workspaces = true
    for new_id, workspace in ipairs(workspaces) do
        if workspace.id ~= new_id then
            hl.dispatch(hl.dsp.workspace.change_id({ workspace = workspace.id, id = new_id }))
        end
    end
    compacting_workspaces = false
end

local function schedule_workspace_compaction()
    if compacting_workspaces or compaction_pending then return end
    compaction_pending = true
    hl.timer(function()
        compaction_pending = false
        compact_workspaces()
    end, { timeout = 100, type = "oneshot" })
end

hl.on("workspace.removed", function(removed)
    if removed then schedule_workspace_compaction() end
end)
hl.on("workspace.active", function(workspace)
    if workspace then schedule_workspace_compaction() end
end)

local function move_window_adjacent_workspace(step)
    if not hl.get_active_window() then return end
    local active = hl.get_active_workspace()
    local current = active and active.id or 1

    if step < 0 and current == 1 then
        -- Insert a fresh workspace 1, shifting existing numbered workspaces up.
        local workspaces = {}
        for _, workspace in ipairs(hl.get_workspaces() or {}) do
            if type(workspace.id) == "number" and workspace.id > 0 and not workspace.special then
                table.insert(workspaces, workspace)
            end
        end
        table.sort(workspaces, function(a, b) return a.id > b.id end)

        compacting_workspaces = true
        for _, workspace in ipairs(workspaces) do
            if workspace.id < 2147483647 then
                hl.dispatch(hl.dsp.workspace.change_id({ workspace = workspace.id, id = workspace.id + 1 }))
            end
        end
        compacting_workspaces = false
        hl.dispatch(hl.dsp.window.move({ workspace = 1 }))
        schedule_workspace_compaction()
        return
    end

    local target = current + step
    if target < 1 then return end

    if step > 0 and hl.get_workspace(target) == nil
        and #(hl.get_workspace_windows(current) or {}) <= 1 then
        -- Don't leave a trailing empty workspace behind when moving its only
        -- window farther to the right.
        return
    end

    hl.dispatch(hl.dsp.window.move({ workspace = target }))
    schedule_workspace_compaction()
end

-- Three-finger horizontal touchpad swipe switches workspaces.
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

hl.bind(mod .. " + SHIFT + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + SHIFT + J", hl.dsp.focus({ direction = "down" }))
hl.bind(mod .. " + SHIFT + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + SHIFT + L", hl.dsp.focus({ direction = "right" }))

-- Move the focused window within the current workspace.
hl.bind(mod .. " + ALT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mod .. " + ALT + J", hl.dsp.window.move({ direction = "down" }))
hl.bind(mod .. " + ALT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(mod .. " + ALT + L", hl.dsp.window.move({ direction = "right" }))

-- Move the focused window to the previous/next workspace.
hl.bind(mod .. " + CTRL + H", function()
    move_window_adjacent_workspace(-1)
end)
hl.bind(mod .. " + CTRL + L", function()
    move_window_adjacent_workspace(1)
end)

-- Super+number changes workspace; Super+Shift+number sends the window there.
for i = 1, 3 do
    hl.bind(mod .. " + " .. i, hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end
