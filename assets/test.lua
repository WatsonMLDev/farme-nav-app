local data = require('data.min')
local battery = require('battery.min')
local code = require('code.min')
local image_sprite_block = require('image_sprite_block.min')

-- Phone to Frame flags
IMAGE_SPRITE_BLOCK = 0x20
CLEAR_MSG = 0x10

-- register the message parsers so they are automatically called when matching data comes in
data.parsers[IMAGE_SPRITE_BLOCK] = image_sprite_block.parse_image_sprite_block
data.parsers[CLEAR_MSG] = code.parse_code

-- Main app loop
function app_loop()
	-- clear the display
	frame.display.text(" ", 1, 1)
	frame.display.show()
    local last_batt_update = 0

	while true do
		-- process any raw data items, if ready
		local items_ready = data.process_raw_items()

		-- one or more full messages received
		if items_ready > 0 then

			if (data.app_data[IMAGE_SPRITE_BLOCK] ~= nil) then
				-- show the image sprite block
				local isb = data.app_data[IMAGE_SPRITE_BLOCK]

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
				-- clear the display
				frame.display.text(" ", 1, 1)
				frame.display.show()

				data.app_data[CLEAR_MSG] = nil
			end
		end

        -- periodic battery level updates, 120s for a camera app
        last_batt_update = battery.send_batt_if_elapsed(last_batt_update, 120)
		frame.sleep(0.005)
	end
end

-- run the main app loop
app_loop()

I/flutter (24967): INFO: [MainApp] 2025-01-27 13:13:50.316742: current state of locking: false and false
I/flutter (24967): INFO: [MainApp] 2025-01-27 13:13:50.367728: Requesting storage permission...
I/ViewRootImpl@9633f56[MainActivity](24967): handleWindowFocusChanged: 0 0 call from android.view.ViewRootImpl.-$$Nest$mhandleWindowFocusChanged:0
I/ImeFocusController(24967): onPreWindowFocus: skipped, hasWindowFocus=false mHasImeFocus=true
I/ImeFocusController(24967): onPostWindowFocus: skipped, hasWindowFocus=false mHasImeFocus=true
I/ViewRootImpl@9633f56[MainActivity](24967): onDisplayChanged oldDisplayState=2 newDisplayState=2
I/flutter (24967): INFO: [MainApp] 2025-01-27 13:13:50.452920: Saving image to: /storage/emulated/0/Android/data/com.example.nav_frame/files/edge.jpg
I/BLASTBufferQueue_Java(24967): update, w= 2207 h= 840 mName = ViewRootImpl@9633f56[MainActivity] mNativeObject= 0xb40000774fa27330 sc.mNativeObject= 0xb40000777fa25550 format= -3 caller= android.view.ViewRootImpl.updateBlastSurfaceIfNeeded:3074 android.view.ViewRootImpl.relayoutWindow:10224 android.view.ViewRootImpl.performTraversals:4167 android.view.ViewRootImpl.doTraversal:3345 android.view.ViewRootImpl$TraversalRunnable.run:11437 android.view.Choreographer$CallbackRecord.run:1690
I/ViewRootImpl@9633f56[MainActivity](24967): Relayout returned: old=(82,0,2289,840) new=(82,0,2289,840) relayoutAsync=true req=(2207,840)0 dur=0 res=0x0 s={true 0xb4000077efa86ff0} ch=false seqId=0
I/ViewRootImpl@9633f56[MainActivity](24967): updateBoundsLayer: t=android.view.SurfaceControl$Transaction@1164a13 sc=Surface(name=Bounds for - com.example.nav_frame/com.example.nav_frame.MainActivity@0)/@0xec18450 frame=3
I/ViewRootImpl@9633f56[MainActivity](24967): registerCallbackForPendingTransactions
I/flutter (24967): INFO: [MainApp] 2025-01-27 13:13:50.461077: Image successfully saved to: /storage/emulated/0/Android/data/com.example.nav_frame/files/edge.jpg
I/ViewRootImpl@9633f56[MainActivity](24967): mWNT: t=0xb4000075efa49530 mBlastBufferQueue=0xb40000774fa27330 fn= 3 mRenderHdrSdrRatio=1.0 caller= android.view.ViewRootImpl$6.onFrameDraw:5705 android.view.ViewRootImpl$2.onFrameDraw:2190 android.view.ThreadedRenderer$1.onFrameDraw:792
I/ViewRootImpl@9633f56[MainActivity](24967): handleWindowFocusChanged: 1 0 call from android.view.ViewRootImpl.-$$Nest$mhandleWindowFocusChanged:0
D/ViewRootImpl@9633f56[MainActivity](24967): mThreadedRenderer.initializeIfNeeded()#2 mSurface={isValid=true 0xb4000077efa86ff0}
D/InputMethodManagerUtils(24967): startInputInner - Id : 0
I/InputMethodManager(24967): startInputInner - IInputMethodManagerGlobalInvoker.startInputOrWindowGainedFocus
I/flutter (24967): INFO: [MainApp] 2025-01-27 13:13:50.494410: Requesting storage permission...
I/ViewRootImpl@9633f56[MainActivity](24967): handleWindowFocusChanged: 0 0 call from android.view.ViewRootImpl.-$$Nest$mhandleWindowFocusChanged:0
I/ImeFocusController(24967): onPreWindowFocus: skipped, hasWindowFocus=false mHasImeFocus=true
I/ImeFocusController(24967): onPostWindowFocus: skipped, hasWindowFocus=false mHasImeFocus=true
D/InputTransport(24967): Input channel destroyed: 'ClientS', fd=155
I/flutter (24967): INFO: [MainApp] 2025-01-27 13:13:50.585500: Saving image to: /storage/emulated/0/Android/data/com.example.nav_frame/files/edges.jpg
I/flutter (24967): INFO: [MainApp] 2025-01-27 13:13:50.589099: Image successfully saved to: /storage/emulated/0/Android/data/com.example.nav_frame/files/edges.jpg
I/flutter (24967): INFO: [MainApp] 2025-01-27 13:13:50.589413: Processing completed in 0 seconds
I/InsetsSourceConsumer(24967): applyRequestedVisibilityToControl: visible=true, type=navigationBars, host=com.example.nav_frame/com.example.nav_frame.MainActivity
I/InsetsSourceConsumer(24967): applyRequestedVisibilityToControl: visible=true, type=statusBars, host=com.example.nav_frame/com.example.nav_frame.MainActivity
I/ViewRootImpl@9633f56[MainActivity](24967): handleWindowFocusChanged: 1 0 call from android.view.ViewRootImpl.-$$Nest$mhandleWindowFocusChanged:0
D/ViewRootImpl@9633f56[MainActivity](24967): mThreadedRenderer.initializeIfNeeded()#2 mSurface={isValid=true 0xb4000077efa86ff0}
D/InputMethodManagerUtils(24967): startInputInner - Id : 0
I/InputMethodManager(24967): startInputInner - IInputMethodManagerGlobalInvoker.startInputOrWindowGainedFocus
I/InsetsSourceConsumer(24967): applyRequestedVisibilityToControl: visible=false, type=ime, host=com.example.nav_frame/com.example.nav_frame.MainActivity
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/InputTransport(24967): Input channel destroyed: 'ClientS', fd=168
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onCharacteristicChanged:
D/[FBP-Android](24967): [FBP]   chr: 7a230003-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
I/flutter (24967): INFO: [Bluetooth] 2025-01-27 13:13:53.226830: Received string: [string "data.min.lua"]:1: not enough memory
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onCharacteristicChanged:
D/[FBP-Android](24967): [FBP]   chr: 7a230003-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
I/flutter (24967): INFO: [Bluetooth] 2025-01-27 13:13:53.258204: Received string: [string "require("frame_app")"]:1: exiting module 'frame_app': [string "frame_app.lua"]:105: not enough memory
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
D/[FBP-Android](24967): [FBP] onMethodCall: writeCharacteristic
D/[FBP-Android](24967): [FBP] onCharacteristicWrite:
D/[FBP-Android](24967): [FBP]   chr: 7a230002-5475-a6a4-654c-8431f6ad49c4
D/[FBP-Android](24967): [FBP]   status: GATT_SUCCESS (0)
I/flutter (24967): INFO: [MainApp] 2025-01-27 13:13:57.138493: Double tap detected, navigation initiated.
