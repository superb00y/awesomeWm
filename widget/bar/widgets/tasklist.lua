---------------------------------
-- This is the tasklist widget --
---------------------------------

-- Awesome Libs
local awful = require("awful")
local wibox = require("wibox")
local dpi = require("beautiful").xresources.apply_dpi
local gears = require("gears")
local color = require("src.theme.colors")

local list_update = function(widget, buttons, label, data, objects)
	widget:reset()
	for _, object in ipairs(objects) do
		local task_widget = wibox.widget({
			{
				{
					{
						{
							nil,
							{
								id = "icon",
								resize = true,
								widget = wibox.widget.imagebox,
							},
							nil,
							layout = wibox.layout.align.horizontal,
							id = "layout_icon",
						},
						forced_width = dpi(33),
						margins = dpi(2),
						widget = wibox.container.margin,
						id = "margin",
					},
					{
						text = "",
						align = "center",
						valign = "center",
						visible = true,
						widget = wibox.widget.textbox,
						id = "title",
					},
					layout = wibox.layout.fixed.horizontal,
					id = "layout_it",
				},
				right = dpi(5),
				left = dpi(5),
				widget = wibox.container.margin,
				id = "container",
			},
			bg = color["BlackA"],
			fg = color["White"],
			shape = function(cr, width, height)
				gears.shape.partially_rounded_rect(cr, width, height, false, false, true, true, 5)
			end,
			widget = wibox.container.background,
		})

		local task_tool_tip = awful.tooltip({
			objects = { task_widget },
			mode = "inside",
			preferred_alignments = "middle",
			preferred_positions = "bottom",
			margins = dpi(10),
			gaps = 0,
			delay_show = 1,
		})

		local function create_buttons(buttons, object)
			if buttons then
				local btns = {}
				for _, b in ipairs(buttons) do
					local btn = awful.button({
						modifiers = b.modifiers,
						button = b.button,
						on_press = function()
							b:emit_signal("press", object)
						end,
						on_release = function()
							b:emit_signal("release", object)
						end,
					})
					btns[#btns + 1] = btn
				end
				return btns
			end
		end

		task_widget:buttons(create_buttons(buttons, object))

		local text, _ = label(object, task_widget.container.layout_it.title)
		if object == client.focus then
			if text == nil or text == "" then
				task_widget.container.layout_it.title:set_margins(0)
			else
				local text_full = text:match(">(.-)<")
				if text_full then
					if object.class == nil then
						text = object.name
					else
						text = object.class:sub(1, 20)
					end
					task_tool_tip:set_text(text_full)
					task_tool_tip:add_to_object(task_widget)
				else
					task_tool_tip:remove_from_object(task_widget)
				end
			end
			task_widget:set_bg(color["BlackA"])
			task_widget:set_fg(color["White"])
			task_widget.container.layout_it.title:set_text(text)
		else
			task_widget.container.layout_it.title:set_text("")
		end
		task_widget.container.layout_it.margin.layout_icon.icon:set_image(Get_icon(user_vars.icon_theme, object))
		widget:add(task_widget)
		widget:set_spacing(dpi(6))

		-- --#region Hover_signal
		-- local old_wibox, old_cursor, old_bg
		-- task_widget:connect_signal("mouse::enter", function()
		-- 	old_bg = task_widget.bg
		-- 	if object == client.focus then
		-- 		task_widget.bg = "#dddddd3d"
		-- 	else
		-- 		task_widget.bg = "#3A475C3d"
		-- 	end
		-- 	local w = mouse.current_wibox
		-- 	if w then
		-- 		old_cursor, old_wibox = w.cursor, w
		-- 		w.cursor = "hand1"
		-- 	end
		-- end)

		-- task_widget:connect_signal("button::press", function()
		-- 	if object == client.focus then
		-- 		task_widget.bg = "#ffffff3a"
		-- 	else
		-- 		task_widget.bg = "#3A475C3a"
		-- 	end
		-- end)

		-- task_widget:connect_signal("button::release", function()
		-- 	if object == client.focus then
		-- 		task_widget.bg = "#ffffff3d"
		-- 	else
		-- 		task_widget.bg = "#3A475C3d"
		-- 	end
		-- end)

		-- task_widget:connect_signal("mouse::leave", function()
		-- 	task_widget.bg = old_bg
		-- 	if old_wibox then
		-- 		old_wibox.cursor = old_cursor
		-- 		old_wibox = nil
		-- 	end
		-- end)
		-- --#endregion
	end
	return widget
end

return function(s)
	return awful.widget.tasklist(
		s,
		awful.widget.tasklist.filter.currenttags,
		awful.util.table.join(
			awful.button({}, 1, function(c)
				if c == client.focus then
					c.minimized = true
				else
					c.minimized = false
					if not c:isvisible() and c.first_tag then
						c.first_tag:view_only()
					end
					c:emit_signal("request::activate")
					c:raise()
				end
			end),
			awful.button({}, 3, function(c)
				c:kill()
			end)
		),
		{},
		list_update,
		wibox.layout.fixed.horizontal()
	)
end
