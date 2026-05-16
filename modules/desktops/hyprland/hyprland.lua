-- Hyprland Lua configuration (generated from Nix via replaceVars)
-- https://wiki.hypr.land/Configuring/Start/

local hostName = "@hostName@"

------------------
---- MONITORS ----
------------------

@monitors@

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
	general = {
		border_size = 2,
		gaps_in = 3,
		gaps_out = 6,
		col = {
			active_border = "0x99@active@",
			inactive_border = "0x66@inactive@",
		},
		resize_on_border = true,
		hover_icon_on_border = false,
		layout = "dwindle",
	},
	decoration = {
		rounding = 6,
		active_opacity = 1,
		inactive_opacity = 1,
		fullscreen_opacity = 1,
	},
	animations = {
		enabled = false,
	},
	input = {
		kb_layout = "pl",
		kb_options = "caps:escape",
		follow_mouse = 2,
		repeat_delay = 250,
		numlock_by_default = true,
		accel_profile = "flat",
		sensitivity = 0.8,
		natural_scroll = false,
		@touchpad@
	},
	dwindle = {
		force_split = 2,
		preserve_split = true,
	},
	misc = {
		disable_hyprland_logo = true,
		disable_splash_rendering = true,
		mouse_move_enables_dpms = true,
		mouse_move_focuses_monitor = true,
		key_press_enables_dpms = true,
		background_color = "0x@bg@",
	},
	debug = {
		damage_tracking = 2,
	},
})

---------------
---- INPUT ----
---------------

@gestures@

---------------------
---- KEYBINDINGS ----
---------------------

local terminal = "@terminal@"
local hyprctl = "@hyprctl@"

hl.bind("SUPER + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + ESCAPE", hl.dsp.exit())
hl.bind("SUPER + S", hl.dsp.exec_cmd("@suspendScript@"))
hl.bind("SUPER + L", hl.dsp.exec_cmd("@hyprlock@"))
hl.bind("SUPER + E", hl.dsp.exec_cmd("@pcmanfm@"))
hl.bind("SUPER + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + SPACE", hl.dsp.exec_cmd("pkill wofi || @wofi@ --show drun"))
hl.bind("SUPER + P", hl.dsp.window.pseudo())
hl.bind("F11", hl.dsp.window.fullscreen())
hl.bind("SUPER + R", hl.dsp.force_renderer_reload())
hl.bind("SUPER + SHIFT + R", hl.dsp.exec_cmd(hyprctl .. " reload"))
hl.bind("SUPER + T", hl.dsp.exec_cmd(terminal .. " -e vi"))
hl.bind(
	"SUPER + K",
	hl.dsp.exec_cmd(hyprctl .. " switchxkblayout keychron-k8-keychron-k8 next")
)
hl.bind("SUPER + D", hl.dsp.exec_cmd("$HOME/.config/hypr/script/toggle-monitor.sh"))
hl.bind("SUPER + left", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + right", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + up", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + down", hl.dsp.focus({ direction = "down" }))
hl.bind("SUPER + SHIFT + left", hl.dsp.window.move({ direction = "left" }))
hl.bind("SUPER + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind("SUPER + SHIFT + up", hl.dsp.window.move({ direction = "up" }))
hl.bind("SUPER + SHIFT + down", hl.dsp.window.move({ direction = "down" }))
hl.bind("SUPER + Z", hl.dsp.layout("togglesplit"))

for i = 1, 10 do
	local key = i % 10
	hl.bind("ALT + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind("ALT + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind("ALT + right", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("ALT + left", hl.dsp.focus({ workspace = "e-1" }))
hl.bind("ALT + SHIFT + right", hl.dsp.window.move({ workspace = "e+1" }))
hl.bind("ALT + SHIFT + left", hl.dsp.window.move({ workspace = "e-1" }))

hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind(
	"SUPER + CTRL + right",
	hl.dsp.window.resize({ x = 60, y = 0, relative = true }),
	{ repeating = true, locked = true }
)
hl.bind(
	"SUPER + CTRL + left",
	hl.dsp.window.resize({ x = -60, y = 0, relative = true }),
	{ repeating = true, locked = true }
)
hl.bind(
	"SUPER + CTRL + up",
	hl.dsp.window.resize({ x = 0, y = -60, relative = true }),
	{ repeating = true, locked = true }
)
hl.bind(
	"SUPER + CTRL + down",
	hl.dsp.window.resize({ x = 0, y = 60, relative = true }),
	{ repeating = true, locked = true }
)

hl.bind("print", hl.dsp.exec_cmd("@grimblast@ --notify --freeze --wait 1 copy area"))
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("@pamixer@ -d 10"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("@pamixer@ -i 10"),
	{ locked = true, repeating = true }
)
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("@pamixer@ -t"), { locked = true })
hl.bind("SUPER_L + c", hl.dsp.exec_cmd("@pamixer@ --default-source -t"), { locked = true })
hl.bind("CTRL + F10", hl.dsp.exec_cmd("@pamixer@ -t"), { locked = true })
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("@pamixer@ --default-source -t"),
	{ locked = true }
)
hl.bind(
	"XF86MonBrightnessDown",
	hl.dsp.exec_cmd("@brightnessctl@ set 10%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86MonBrightnessUp",
	hl.dsp.exec_cmd("@brightnessctl@ set 10%+"),
	{ locked = true, repeating = true }
)

@lidBind@

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

hl.window_rule({
	name = "steam-fullscreen",
	match = { class = "^(steam_app_.*)$" },
	fullscreen = true,
})

hl.window_rule({
	name = "float-volume-control",
	match = { title = "^(Volume Control)$" },
	float = true,
})

hl.window_rule({
	name = "zen-pip-aspect-ratio",
	match = { class = "^(zen)$", title = "^(Picture-in-Picture)$" },
	keep_aspect_ratio = true,
})

hl.window_rule({
	name = "zen-pip-no-border",
	match = { class = "^(zen)$", title = "^(Picture-in-Picture)$" },
	decorate = false,
})

hl.window_rule({
	name = "float-picture-in-picture",
	match = { title = "^(Picture-in-Picture)$" },
	float = true,
})

hl.window_rule({
	name = "size-picture-in-picture",
	match = { title = "(Picture-in-Picture)" },
	size = "24% 24%",
})

hl.window_rule({
	name = "move-picture-in-picture",
	match = { title = "(Picture-in-Picture)" },
	move = "75% 75%",
})

hl.window_rule({
	name = "pin-picture-in-picture",
	match = { title = "^(Picture-in-Picture)$" },
	pin = true,
})

hl.window_rule({
	name = "float-zen-dialog",
	match = { title = "^(zen)$" },
	float = true,
})

hl.window_rule({
	name = "size-zen-dialog",
	match = { title = "(zen)" },
	size = "24% 24%",
})

hl.window_rule({
	name = "move-zen-dialog",
	match = { title = "(zen)" },
	move = "74% 74%",
})

hl.window_rule({
	name = "pin-zen-dialog",
	match = { title = "^(zen)$" },
	pin = true,
})

hl.window_rule({
	name = "kitty-opacity",
	match = { class = "^(kitty)$" },
	opacity = 0.9,
})

hl.window_rule({
	name = "wps-tile",
	match = { initial_title = "^WPS.*" },
	tile = true,
})

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
	-- Background long-running processes (&). monitor-hotplug blocks without it.
	hl.exec_cmd("$HOME/.config/hypr/script/monitor-hotplug.sh &")
	hl.exec_cmd("ln -sf $XDG_RUNTIME_DIR/hypr /tmp/hypr")
	hl.exec_cmd("@hyprlock@")
	hl.exec_cmd("systemctl --user restart hyprpaper.service")
	hl.exec_cmd("@eww@ daemon &")
	hl.exec_cmd("@blueman@ &")
	hl.exec_cmd("@swaync@ &")
	hl.exec_cmd("@polkit@ &")
	@execOnceExtra@
end)
