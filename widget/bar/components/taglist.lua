local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")
local helpers = require("helpers")
local rubato = require("modules.rubato")
local dpi = beautiful.xresources.apply_dpi

local function gettaglist(s)
  local tag = awful.widget.taglist({
    screen = s,
    filter = awful.widget.taglist.filter.all,
    style = {
      shape = helpers.rrect(5),
    },
    layout = {
      spacing = dpi(5),
      layout = wibox.layout.fixed.vertical,
    },
    buttons = {
      awful.button({}, 1, function(t)
        t:view_only()
      end),
      awful.button({}, 3, function(t)
        awful.tag.viewtoggle(t)
      end),
      awful.button({}, 4, function(t)
        awful.tag.viewprev(t.screen)
      end),
      awful.button({}, 5, function(t)
        awful.tag.viewnext(t.screen)
      end),
    },
    widget_template = {
      {
        markup = "",
        widget = wibox.widget.textbox,
      },
      id = "background_role",
      forced_height = dpi(60),
      forced_width = dpi(60),
      widget = wibox.container.background,
      create_callback = function(self, tag)
        self.animate = rubato.timed({
          duration = 0.15,
          subscribed = function(h)
            self:get_children_by_id("background_role")[1].forced_height = h
          end,
        })

        self.update = function()
          if tag.selected then
            self.animate.target = dpi(60)
          elseif #tag:clients() > 0 then
            self.animate.target = dpi(25)
          else
            self.animate.target = dpi(13)
          end
        end

        self.update()
      end,
      update_callback = function(self)
        self.update()
      end,
    },
  })

  local taglist = wibox.widget({
    {
      {
        tag,
        margins = dpi(7),
        widget = wibox.container.margin,
      },
      bg = beautiful.bg_dark,
      shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, 5)
      end,
      widget = wibox.container.background,
    },
    direction = "east",
    widget = wibox.container.rotate,
  })

  helpers.hoverCursor(taglist)

  return taglist
end

return gettaglist
