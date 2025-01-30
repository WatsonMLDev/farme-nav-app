local data = require('data.min')
local battery = require('battery.min')
local code = require('code.min')
local image_sprite_block = require('image_sprite_block.min')
local plain_text = require('plain_text.min')

-- Phone to Frame flags
USER_SPRITE = 0x20
DATE_MSG = 0x14
TEXT_MSG = 0x12
CLEAR_MSG = 0x10
TAP_SUBS_MSG = 0x16  -- New message code

-- Frame to Phone flags
TAP_MSG = 0x09

-- Register message parsers
data.parsers[USER_SPRITE] = image_sprite_block.parse_image_sprite_block
data.parsers[CLEAR_MSG] = code.parse_code
data.parsers[TEXT_MSG] = plain_text.parse_plain_text
data.parsers[DATE_MSG] = plain_text.parse_plain_text
data.parsers[TAP_SUBS_MSG] = code.parse_code

-- Main app loop
function app_loop()
    frame.display.text(" ", 1, 1)
    frame.display.show()
    local last_batt_update = 0

    while true do
        rc, err = pcall(function()
            local items_ready = data.process_raw_items()

            if items_ready > 0 then
                if (data.app_data[DATE_MSG] ~= nil and data.app_data[DATE_MSG].string ~= nil) then
                    frame.display.text(data.app_data[DATE_MSG].string, 1, 1)
                    frame.display.show()
                end

                if (data.app_data[TEXT_MSG] ~= nil and data.app_data[TEXT_MSG].string ~= nil) then
                    local i = 1
                    for line in data.app_data[TEXT_MSG].string:gmatch("([^\n]*)\n?") do
                        if line ~= "" then
                            frame.display.text(line, 1, i * 60 + 1)
                            i = i + 1
                        end
                    end
                    frame.display.show()
                end

                if (data.app_data[USER_SPRITE] ~= nil) then
                    -- show the image sprite block
                    local isb = data.app_data[USER_SPRITE]

                    -- it can be that we haven't got any sprites yet, so only proceed if we have a sprite
                    if isb.current_sprite_index > 0 then
                        -- either we have all the sprites, or we want to do progressive/incremental rendering
                        if isb.progressive_render or (isb.active_sprites == isb.total_sprites) then

                            for index = 1, isb.active_sprites do
                                local spr = isb.sprites[index]
                                local y_offset = isb.sprite_line_height * (index - 1)

                                -- set the palette the first time, all the sprites should have the same palette
                                if index == 1 then
                                    image_sprite_block.set_palette(spr.num_colors, spr.palette_data)
                                end

                                frame.display.bitmap(1, y_offset + 1, spr.width, 2^spr.bpp, 0, spr.pixel_data)
                            end

                            frame.display.show()
                        end
                    end
                end

                if (data.app_data[CLEAR_MSG] ~= nil) then
                    frame.display.text("  ", 1, 1)
                    frame.display.show()
                    data.app_data[CLEAR_MSG] = nil
                end

                -- Handle new tap subscription message
                if (data.app_data[TAP_SUBS_MSG] ~= nil) then
                    if data.app_data[TAP_SUBS_MSG].value == 1 then
                        frame.imu.tap_callback(function()
                            pcall(frame.bluetooth.send, string.char(TAP_MSG))
                        end)
                    else
                        frame.imu.tap_callback(nil)
                    end
                    data.app_data[TAP_SUBS_MSG] = nil
                end
            end

            -- Periodic battery updates
            last_batt_update = battery.send_batt_if_elapsed(last_batt_update, 120)
            frame.sleep(0.1)
        end)

        if rc == false then
            print(err)
            frame.display.text(" ", 1, 1)
            frame.display.show()
            frame.sleep(0.04)
            break
        end
    end
end

-- Run the main app loop
app_loop()
