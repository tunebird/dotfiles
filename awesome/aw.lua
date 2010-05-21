---------------------------------
--    "Awesome Config file"   ---
--     Andrew Watson 2010     ---
---------------------------------
--
-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")


-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init(awful.util.getdir("config") .. "/themes/zenburn/theme.lua")

-- Andrew's widgets ( must require AFTER setting theme location
require("wi")

icon_theme = awful.util.getdir("config") .. "/themes/icons/"

-- This is used later as the default terminal and editor to run.
terminal = "urxvt"
browser = "chromium"
instant_messenger = "pidgin"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor
musicinit = "sudo /etc/rc.d/mpd start && mpc pause && sudo /etc/rc.d/mpdas start"

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Function aliases to save space in keymaps
local exec = awful.util.spawn
local sexec = awful.util.spawn_with_shell


local hostname = io.popen('hostname'):read()


-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.floating,                 --1
    awful.layout.suit.tile,                     --2
    awful.layout.suit.tile.left,                --3
    awful.layout.suit.tile.bottom,              --4
    awful.layout.suit.tile.top,                 --5
    awful.layout.suit.fair,                     --6
    awful.layout.suit.fair.horizontal,          --7
    awful.layout.suit.spiral,                   --8
    awful.layout.suit.spiral.dwindle,           --9
    awful.layout.suit.max,                      --10
    awful.layout.suit.max.fullscreen,           --11
    awful.layout.suit.magnifier                 --12
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {
    names   = {   "main", "www", "rss",
                  "im", "music", "python",
                  7, 8, 9 },
    layout  = {   layouts[2], layouts[2], layouts[2],   -- 1, 2, 3
                  layouts[1], layouts[1], layouts[6],   -- 4, 5, 6
                  layouts[2], layouts[8], layouts[12]   -- 7, 8, 9
}}

for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag(tags.names, s, tags.layout)
    awful.tag.setproperty(tags[s][4], "mwfact", 0.13)
    awful.tag.setproperty(tags[s][7], "hide", true)
    awful.tag.setproperty(tags[s][8], "hide", true)
    awful.tag.setproperty(tags[s][9], "hide", true)
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/aw.lua" },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({
    items = {
        { "awesome", myawesomemenu, beautiful.awesome_icon },
        { "-------------", "" },
        { "open terminal", terminal, icon_theme .. "apps/terminal.png" },
        { "vim", terminal .. " -e vim", icon_theme .. "apps/vim32x32.png" },
        { "chromium", browser, icon_theme .. "apps/chromium.png" },
        { "thunar", "thunar", icon_theme .. "apps/filemanager.png" },
        { "calib screens", "/home/andrew/scripts/calib_displays" },
        { "-------------", "" },
        { "suspend", "sudo pm-suspend" },
        { "shutdown", "sudo halt" },
        { "reboot", "sudo reboot" },
        { "reboot to Windows", "sudo /home/andrew/scripts/reboot_to_windows.sh" },
      }
})

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })
-- }}}







-- {{{ Wibox
--
-- Create a textclock widget
mytextclock = awful.widget.textclock({ align = "right" })




-- {{{  NAUGHTY Notifications


-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a wibox for each screen and add it
mywibox = {}
mywibox_bottom = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 5, awful.tag.viewnext),
                    awful.button({ }, 4, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if not c:isvisible() then
                                                  awful.tag.viewonly(c:tags()[1])
                                              end
                                              client.focus = c
                                              c:raise()
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })
    mywibox_bottom[s] = awful.wibox({ position = "bottom", screen = s })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
            mylauncher,
            mytaglist[s],
            mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
        mylayoutbox[s],
        mytextclock,
                separator, weatherwidget, spacer,
                separator, updatewidget, updateicon,
                separator, wmailwidget, wmailicon,
                separator, volwidget, volicon,
                hostname == "fenrir" and separator or nil,
                hostname == "fenrir" and batwidget or nil,
                hostname == "fenrir" and baticon or nil, 
                hostname == "fenrir" and separator or nil,
                hostname == "fenrir" and wifiwidget or nil,
                hostname == "fenrir" and wifiicon or nil, 

        s == screen.count() and mysystray or nil, -- systray only on last screen
        mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }
    mywibox_bottom[s].widgets = {
        {
            mpdicon, mpdwidget, 
            layout = awful.widget.layout.horizontal.leftright
        },
        separator, ipwidget, spacer,
        separator, localipwidget, spacer,
        separator, hostnamewidget, spacer,
        separator, upicon, netwidget, dnicon,
        --separator, fs.h.widget, fs.r.widget, fsicon,
        separator, cpugraph.widget, cpuicon,
        separator, memtext, spacer, memicon, 
        separator, lokiwidget,
        layout = awful.widget.layout.horizontal.rightleft
    }
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true})        end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),
                --
    -- {{{ Multimedia keys
    awful.key({}, "Print", function () exec("scrot -e 'mv $f ~/screenshots/ 2>/dev/null'") end),
    awful.key({}, "#171", function () exec("mpc next") end),
    awful.key({}, "#172", function () exec("mpc toggle") end),
    awful.key({}, "#173", function () exec("mpc prev") end),
    awful.key({}, "#174", function () exec("mpc stop") end),
    awful.key({}, "#179", function () exec(terminal .. " -e ncmpcpp") end),
    awful.key({}, "#121", function () exec("amixer -q set Master toggle") end),
    awful.key({}, "#122", function () exec("amixer -q set Master 2-") end),
    awful.key({}, "#123", function () exec("amixer -q set Master 2+") end),
    -- }}}
    
    -- {{{ Custom app launchers
    awful.key({ modkey,           }, "b", function () exec(browser) end),
    awful.key({ modkey,           }, "i", function () exec(instant_messenger) end),
    awful.key({ modkey,           }, "v", function () exec(terminal .. " -e vim") end),
    awful.key({ modkey,           }, "p", function () exec(musicinit) end),
    awful.key({ modkey, "Control" }, "p", function () exec("sudo pm-suspend")  end),
    -- global mpc controls
    awful.key({ modkey, "Shift"   }, "p", function () exec("mpc toggle")  end),
    -- TODO : fix + key not working...
    awful.key({ modkey,           }, "+", function () exec("mpc volume +5")  end),
    awful.key({ modkey, "Shift"   }, "-", function () exec("mpc volume -5")  end),
    -- }}}

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "n",      function (c) c.minimized = not c.minimized    end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "Pidgin" },
      properties = { tag = tags[1][4], floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    -- Set browser to always map on tags number 2 of right-most screen
     { rule = { class = "Chromium" },
       properties = { tag = tags[screen.count()][2] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
-- vim:ts=4 sw=4 sts=4 et
