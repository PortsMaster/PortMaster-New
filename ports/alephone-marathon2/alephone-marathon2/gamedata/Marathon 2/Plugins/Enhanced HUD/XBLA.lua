-- Copyright (C) 2011 and beyond by Jeremiah Morris
-- and the "Aleph One" developers.
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- This license is contained in the file "COPYING",
-- which is included with this source code; it is available online at
-- http://www.gnu.org/licenses/gpl.html

Triggers = {}
function Triggers.init()
  
  -- align weapon and item mnemonics
  ItemTypes["knife"].mnemonic = "fist"

  opengl = true
  if Screen.renderer == "software" then
    opengl = false
  end
  
  Screen.crosshairs.lua_hud = true
  
  alienWeaponFlickerMask = 0x1F0
  alienWeaponShowText = true
  alienWeaponSlant = 1
  firstBackRender = false
  
  img = {}
  img.motionSensorDisabledHUD = Images.new{path = "720p/health_noradar.png"}
  img.motionSensorHUD = Images.new{path = "720p/health_radar.png"}
  img.weaponAreaHUD = Images.new{path = "720p/weapons.png"}
  img.oxygenBarLeftEnd = Images.new{path = "720p/left_oxygen.png"}
  img.oxygenBar = Images.new{path = "720p/mid_oxygen.png"}
  img.oxygenBarRightEnd = Images.new{path = "720p/right_oxygen.png"}
  img.shield1xBarLeftEnd = Images.new{path = "720p/left_shield1x.png"}
  img.shield1xBar = Images.new{path = "720p/mid_shield1x.png"}
  img.shield1xBarRightEnd = Images.new{path = "720p/right_shield1x.png"}
  img.shield2xBarLeftEnd = Images.new{path = "720p/left_shield2x.png"}
  img.shield2xBar = Images.new{path = "720p/mid_shield2x.png"}
  img.shield2xBarRightEnd = Images.new{path = "720p/right_shield2x.png"}
  img.shield3xBarLeftEnd = Images.new{path = "720p/left_shield3x.png"}
  img.shield3xBar = Images.new{path = "720p/mid_shield3x.png"}
  img.shield3xBarRightEnd = Images.new{path = "720p/right_shield3x.png"}
  img.radarBackground = Images.new{path = "720p/background.png"}
  img.friendly = Images.new{path = "720p/friendly.png"}
  img.enemy = Images.new{path = "720p/enemy.png"}
  img.alien = Images.new{path = "720p/alien.png"}
  img.pistol = Images.new{path = "720p/pistol.png"}
  img.plasmaPistol = Images.new{path = "720p/fusion.png"}
  img.ar = Images.new{path = "720p/arr.png"}
  img.missileLauncher = Images.new{path = "720p/spnkr.png"}
  img.flamethrower = Images.new{path = "720p/tozt.png"}
  img.alienWeapon = Images.new{path = "720p/alienwep.png"}
  img.shotgun = Images.new{path = "720p/shotgun.png"}
  img.dualPistol = Images.new{path = "720p/pistolx2.png"}
  img.dualShotgun = Images.new{path = "720p/shotgunx2.png"}
  img.pistolAmmoEmpty = Images.new{path = "720p/pistolamoused.png"}
  img.pistolAmmoFull = Images.new{path = "720p/pistolamo.png"}
  img.shotgunAmmoFull = Images.new{path = "720p/shotgunamo.png"}
  img.shotgunAmmoEmpty = Images.new{path = "720p/shotgunamoused.png"}
  img.missileAmmoFull = Images.new{path = "720p/spnkramo.png"}
  img.missileAmmoEmpty = Images.new{path = "720p/spnkramoused.png"}
  img.fillFull = Images.new{path = "720p/fill.png"}
  img.fillEmpty = Images.new{path = "720p/fillshell.png"}
  img.arAmmoFull = Images.new{path = "720p/arramo.png"}
  img.arAmmoEmpty = Images.new{path = "720p/arramoused.png"}
  img.arGrenadeFull = Images.new{path = "720p/grenadeamo.png"}
  img.arGrenadeEmpty = Images.new{path = "720p/grenadeamoused.png"}
  img.pistolCrosshair = Images.new{path = "720p/ret_pistol.png"}
  img.shotgunCrosshair = Images.new{path = "720p/ret_shotgun.png"}
  img.fusionPistolCrosshair = Images.new{path = "720p/ret_plasma.png"}
  img.assaultRifleCrosshair = Images.new{path = "720p/ret_machinegun.png"}
  img.rocketCrosshair = Images.new{path = "720p/ret_rocket.png"}
  img.flameCrosshair = Images.new{path = "720p/ret_flame.png"}
  img.alienWeaponCrosshair = Images.new{path = "720p/ret_alien.png"}
--  img.namePanelFriend = Images.new{path = "720p/target-panel-friend.png"}
--  img.namePanelFoe = Images.new{path = "720p/target-panel-foe.png"}
  img.chipIndicator = Images.new{path = "720p/chip.png"}
  img.dualShotgunIdle = Images.new{path = "720p/shotgunx2_idle.png"}
  img.dualPistolIdle = Images.new{path = "720p/pistolx2_idle.png"}
  img.objectiveFull = Images.new{path = "720p/objective-indicator-full.png"}
  img.scorePanel = Images.new{path = "720p/score-panel.png"}
  
  img.scorePanelColor = {}
  img.scorePanelColor[0] = Images.new{path = "720p/score-panel_slate.png"}
  img.scorePanelColor[1] = Images.new{path = "720p/score-panel_red.png"}
  img.scorePanelColor[2] = Images.new{path = "720p/score-panel_violet.png"}
  img.scorePanelColor[3] = Images.new{path = "720p/score-panel_yellow.png"}
  img.scorePanelColor[4] = Images.new{path = "720p/score-panel_white.png"}
  img.scorePanelColor[5] = Images.new{path = "720p/score-panel_orange.png"}
  img.scorePanelColor[6] = Images.new{path = "720p/score-panel_blue.png"}
  img.scorePanelColor[7] = Images.new{path = "720p/score-panel_green.png"}
  
  img.scorePanelIcon = Images.new{path = "720p/score-panel-icon.png"}
  img.ball = Images.new{path = "720p/skull.png"}
  
  img.smg = Images.new{path = "720p/w_smg.png"}
  img.smgAmmoFull = Images.new{path = "720p/flechette_on.png"}
  img.smgAmmoEmpty = Images.new{path = "720p/flechette_off.png"}
  img.smgCrosshair = Images.new{path = "720p/ret_smg.png"}
  
  img.objectiveFull.tint_color = { 1, 1, 1, 0.75 }
  img.scorePanel.tint_color = { 1, 1, 1, 0.7 }
  for k in pairs(img.scorePanelColor) do
    img.scorePanelColor[k].tint_color = { 1, 1, 1, 0.7 }
  end

  rawpos = {}
  rawpos.leftHUDPosition = { x = 0, y = 0 }
  rawpos.radarPosition = { x = 24, y = 17 }
  rawpos.radarCenter = { x = 24+64, y = 17+64 }
  rawpos.radarBlipSize = 9
  rawpos.shieldOffset = { x = 177, y = 26 }
  rawpos.shieldLength = 197
  rawpos.oxygenOffset = { x = 160, y = 4 }
  rawpos.oxygenLength = 197
  rawpos.rightHUDPosition = { x = 0, y = 0 }
  
  rawpos.pistolOffset = { x = 56, y = 20 }
  rawpos.pistolClipOffset = { x = 160, y = 18 }
  rawpos.pistolClipReadoutOffset = { x = 41, y = 14 }
  
  rawpos.dualPistolsOffset = { x = 56, y = 20 }
  rawpos.dualPistolsClipOffset = { x = 264, y = 18 }
  rawpos.dualPistolsSpacer = 43
  rawpos.dualPistolsClipReadoutOffset = { x = 182, y = 41 }
  
  rawpos.shotgunOffset = { x = 57, y = 16 }
  rawpos.shotgunShellsOffset = { x = 162, y = 14 }
  rawpos.shotgunShellReadoutOffset = { x = 41, y = 14 }
  
  rawpos.dualShotgunsOffset = { x = 40, y = 16 }
  rawpos.dualShotgunShellsOffset = { x = 206, y = 14 }
  rawpos.dualShotgunsSpacer = 20
  rawpos.dualShotgunShellReadoutOffset = { x = 41, y = 14 }
  
  rawpos.fusionPistolOffset = { x = 92, y = 18 }
  rawpos.fusionPistolCellOffset = { x = 257, y = 12 }
  rawpos.fusionPistolCellReadoutOffset = { x = 41, y = 14 }
  
  rawpos.flamethrowerOffset = { x = 111, y = 18 }
  rawpos.flamethrowerCellOffset = { x = 257, y = 12 }
  rawpos.flamethrowerCellReadoutOffset = { x = 41, y = 14 }
  
  rawpos.rocketLauncherOffset = { x = 45, y = 18 }
  rawpos.rocketLauncherRocketOffset = { x = 315, y = 13 }
  rawpos.rocketLauncherRocketReadoutOffset = { x = 97, y = 14 }
  
  rawpos.assaultRifleOffset = { x = 53, y = 10 }
  rawpos.assaultRifleRackOffset = { x = 320, y = 12 }
  rawpos.assaultRifleGrenadeSpacer = 10
  rawpos.assaultRifleClipReadoutOffset = { x = 108, y = 25 }
  
  rawpos.alienWeaponOffset = { x = 40, y = 7 }
  rawpos.alienWeaponTextOffset = { x = 200, y = 15 }
  
--  rawpos.ballOffset = { x = 55, y = 40 }
  rawpos.ballOffset = { x = 65, y = 15 }
  rawpos.chipOffset = { x = -48, y = 12 }
  
  rawpos.smgOffset = { x = 28, y = 8 }
  rawpos.smgClipOffset = { x = 257, y = 24 }
  rawpos.smgClipReadoutOffset = { x = 41, y = 14 }
  
  rawpos.scorePanelSpacer = 2
  rawpos.scorePanelOffset = { x = 0, y = 0 }
  rawpos.scorePanelScoreOffset = { x = 20, y = 24 }
  rawpos.scorePanelNameOffset = { x = 100, y = 24 }
  rawpos.scorePanelRankOffset = { x = 330, y = 24 }
  
  rawpos.crosshairRocket = { x = -32, y = 0 }
  rawpos.crosshairAlien = { x = 0, y = -24 }
  
  Triggers.resize()
end

function scaled(number)
  return math.floor(number * scale)
end

function Triggers.resize()
  if TexturePalette.resize() then return end

  Screen.clip_rect.width = Screen.width
  Screen.clip_rect.x = 0
  Screen.clip_rect.height = Screen.height
  Screen.clip_rect.y = 0

  Screen.map_rect.width = Screen.width
  Screen.map_rect.x = 0
  Screen.map_rect.height = Screen.height
  Screen.map_rect.y = 0
  
  local min_aspect_ratio = 1.6
  local max_aspect_ratio = 2.4
  local h = math.min(Screen.height, Screen.width / min_aspect_ratio)
  local w = math.min(Screen.width, h*max_aspect_ratio)
  Screen.world_rect.width = w
  Screen.world_rect.x = (Screen.width - w)/2
  Screen.world_rect.height = h
  Screen.world_rect.y = (Screen.height - h)/2
    
  if Screen.map_overlay_active then
    Screen.map_rect.x = Screen.world_rect.x
    Screen.map_rect.y = Screen.world_rect.y
    Screen.map_rect.width = Screen.world_rect.width
    Screen.map_rect.height = Screen.world_rect.height
  end

  sx = Screen.world_rect.x
  sy = Screen.world_rect.y
  sw = Screen.world_rect.width
  sh = Screen.world_rect.height
  
  crossX = sx + math.floor(sw / 2)
  crossY = sy + math.floor(sh / 2)
    
  safeZoneWidthSize = math.floor(sw * 0.06)
  safeZoneHeightSize = math.floor(sh * 0.06)
  hudL = sx + safeZoneWidthSize
  hudR = sx + sw - safeZoneWidthSize
  hudT = sy + safeZoneHeightSize
  hudB = sy + sh - safeZoneHeightSize
  
  local scaleX = sw / 1280
  local scaleY = sh / 720
  local max_scale_factor = 4.0
  local min_scale_factor = 0.5
  scale = math.min(max_scale_factor, math.max(min_scale_factor, math.min(scaleX, scaleY)))

  for k in pairs(img) do
    if type(img[k]) == "table" then
      for kk in pairs(img[k]) do
        img[k][kk]:rescale(scaled(img[k][kk].unscaled_width), scaled(img[k][kk].unscaled_height))
      end
    else
      img[k]:rescale(scaled(img[k].unscaled_width), scaled(img[k].unscaled_height))
    end
  end
  
  pos = {}
  for k in pairs(rawpos) do
    local p = rawpos[k]
    if type(p) == "table" then
      pos[k] = { }
      for kk in pairs(p) do
        pos[k][kk] = scaled(p[kk])
      end
    else
      pos[k] = scaled(p)
    end
  end
  
  bgf = Fonts.new{file = "squarishsans/Squarish Sans CT Regular SC.ttf", size = (17*scale), style = 0}
  bgfAdjust = math.floor(20*scale)
  
  ngf = Fonts.new{file = "squarishsans/Squarish Sans CT Regular SC.ttf", size = (17*scale), style = 0}
  ngfAdjust = math.floor(20*scale)
  
  local th = math.max(320, math.floor(sh - 260*scale))
  local tw = math.max(640, math.floor(sw - 400*scale))
  h = math.min(tw / 2, th)
  w = h*2
  
  Screen.term_rect.width = w
  Screen.term_rect.height = h
  Screen.term_rect.x = sx + (sw - w)/2
  Screen.term_rect.y = sy + 0.23*(sh - h)
  
  shortened_player_names = {}

  local max_name_len = pos.scorePanelRankOffset.x - pos.scorePanelNameOffset.x
  for i = 1, # Game.players do
     local p = Game.players[i - 1]
     local name = p.name
     if ngf:measure_text(name) >= max_name_len and # name > 3 then
	name = name:sub(1, # name - 3) .. "..."
	while ngf:measure_text(name) >= max_name_len and # name > 4 do
	   name = name:sub(1, # name - 4) .. "..."
	end
     end
     shortened_player_names[p.index] = name
  end
end

function drawBL(image, x, y)
  image:draw(hudL + math.floor(x), hudB - math.floor(y) - image.crop_rect.height)
end
function drawBR(image, x, y)
  image:draw(hudR - math.floor(x) - image.crop_rect.width, hudB - math.floor(y) - image.crop_rect.height)
end

function drawTR(image, x, y)
  image:draw(hudR - math.floor(x) - image.crop_rect.width, hudT + math.floor(y))
end

function drawBRL(image, x, y)
  image:draw(hudR - math.floor(x), hudB - math.floor(y) - image.crop_rect.height)
end

function drawCrosshair(image, offset)
  if Screen.term_active or Screen.map_active then return end
  if not Screen.crosshairs.active then return end
  
  local nudgex = 0
  local nudgey = 0
  if offset ~= nil then
    nudgex = offset.x
    nudgey = offset.y
  end
  image:draw(crossX + nudgex - math.floor(image.crop_rect.width / 2), crossY - nudgey - math.floor(image.crop_rect.height / 2))
end

function Triggers.draw()
  if TexturePalette.draw() then return end

  -- net stats
  if #Game.players > 1 then drawNetPlayers() end
  
  -- left area
  if Player.motion_sensor.active then
    -- radar
    drawBL(img.radarBackground, pos.radarPosition.x, pos.radarPosition.y)
    local sens_rad = img.radarBackground.width / 2
    local sens_xcen = pos.radarPosition.x + sens_rad
    local sens_ycen = pos.radarPosition.y + sens_rad

    local compass_diff = (img.radarBackground.width - img.objectiveFull.width) / 2
    drawCompass(img.objectiveFull, { x = pos.radarPosition.x + compass_diff, y = pos.radarPosition.y + compass_diff })
    
    -- blips
    for i = 1,#Player.motion_sensor.blips do
      local blip = Player.motion_sensor.blips[i - 1]
      local mult = blip.distance * sens_rad / 8
      local rad = math.rad(blip.direction)
      local xoff = sens_xcen + math.cos(rad) * mult
      local yoff = sens_ycen - math.sin(rad) * mult
      
      local image = img.friendly
      if blip.type == "alien" then
        image = img.alien
      end
      if blip.type == "hostile player" then
        image = img.enemy
      end
      image.tint_color = { 1, 1, 1, 1 - (blip.intensity / 7) }
      drawBL(image, xoff - (image.width / 2), yoff - (image.height / 2))
    end

    drawBL(img.motionSensorHUD, pos.leftHUDPosition.x, pos.rightHUDPosition.y)
  else
    drawBL(img.motionSensorDisabledHUD, pos.leftHUDPosition.x, pos.leftHUDPosition.y)
  end
  
  -- oxygen bar
  drawBar(pos.oxygenOffset, pos.oxygenLength, Player.oxygen, 10800, "oxygen")
  
  -- health bar
  do
    local health = Player.energy
    if (health > 0) and (health < 300) then
      drawBar(pos.shieldOffset, pos.shieldLength, health, 150, "shield1x")
    end
    if (health > 150) and (health < 450) then
      drawBar(pos.shieldOffset, pos.shieldLength, health - 150, 150, "shield2x")
    end
    if health > 300 then
      drawBar(pos.shieldOffset, pos.shieldLength, health - 300, 150, "shield3x")
    end
  end
  
  -- right area
  drawBR(img.weaponAreaHUD, pos.rightHUDPosition.x, pos.rightHUDPosition.y)
  
  -- weapons
  if Player.weapons.desired then
    local weapon = Player.weapons.desired
    local wt = weapon.type.mnemonic
    
    if wt == "pistol" then
      drawCrosshair(img.pistolCrosshair)
      if Player.items[wt].count > 1 then
        if weapon.secondary.weapon_drawn then
          drawBR(img.dualPistol, pos.dualPistolsOffset.x, pos.dualPistolsOffset.y)
        else
          drawBR(img.dualPistolIdle, pos.dualPistolsOffset.x, pos.dualPistolsOffset.y)
        end
        drawAmmo(pos.dualPistolsClipOffset, img.pistolAmmoEmpty, img.pistolAmmoFull, weapon.secondary.rounds, weapon.secondary.total_rounds)
        drawAmmoR({ x = pos.dualPistolsClipOffset.x - img.pistolAmmoFull.width - pos.dualPistolsSpacer, y = pos.dualPistolsClipOffset.y }, img.pistolAmmoEmpty,img.pistolAmmoFull, weapon.primary.rounds, weapon.primary.total_rounds)
        drawReserveR(Player.items[weapon.primary.ammo_type].count .. "x", pos.dualPistolsClipReadoutOffset)
      else
        drawBR(img.pistol, pos.pistolOffset.x, pos.pistolOffset.y)
        drawAmmoR(pos.pistolClipOffset, img.pistolAmmoEmpty, img.pistolAmmoFull, weapon.primary.rounds, weapon.primary.total_rounds)
        drawReserve(Player.items[weapon.primary.ammo_type].count .. "x", pos.pistolClipReadoutOffset)
      end
    elseif wt == "fusion pistol" then
      drawCrosshair(img.fusionPistolCrosshair)
      drawBR(img.plasmaPistol, pos.fusionPistolOffset.x, pos.fusionPistolOffset.y)
      drawCell(pos.fusionPistolCellOffset, weapon.primary.rounds, weapon.primary.total_rounds)
      drawReserve(Player.items[weapon.primary.ammo_type].count .. "x", pos.fusionPistolCellReadoutOffset)
    elseif wt == "assault rifle" then
      drawCrosshair(img.assaultRifleCrosshair)
      drawBR(img.ar, pos.assaultRifleOffset.x, pos.assaultRifleOffset.y)
      
      local bullets = img.arAmmoFull
      local grenades = img.arGrenadeFull
      
      local ammoB = pos.assaultRifleRackOffset.y
      local ammoL = pos.assaultRifleRackOffset.x
      local ammoG = ammoL - (bullets.width - grenades.width)/2
      
      drawAmmo({ x = ammoG, y = ammoB }, img.arGrenadeEmpty, img.arGrenadeFull, weapon.secondary.rounds, weapon.secondary.total_rounds)
      
      ammoB = ammoB + grenades.height + pos.assaultRifleGrenadeSpacer
      local extra = 39
      while extra >= 0 do
        drawAmmo({ x = ammoL, y = ammoB }, img.arAmmoEmpty, img.arAmmoFull, weapon.primary.rounds - extra, 13)
        extra = extra - 13
        ammoB = ammoB + bullets.height
      end

      drawReserve("x" .. Player.items[weapon.primary.ammo_type].count, pos.assaultRifleClipReadoutOffset)
      
      local fw, fh = bgf:measure_text("x")
      drawReserve("x" .. Player.items[weapon.secondary.ammo_type].count, { x = pos.assaultRifleClipReadoutOffset.x, y = pos.assaultRifleClipReadoutOffset.y - (14*scale) })
    elseif wt == "missile launcher" then
      drawCrosshair(img.rocketCrosshair, pos.crosshairRocket)
      drawBR(img.missileLauncher, pos.rocketLauncherOffset.x, pos.rocketLauncherOffset.y)
      drawAmmo(pos.rocketLauncherRocketOffset, img.missileAmmoEmpty, img.missileAmmoFull, weapon.primary.rounds, weapon.primary.total_rounds)
      drawReserve(Player.items[weapon.primary.ammo_type].count .. "x", pos.rocketLauncherRocketReadoutOffset)
    elseif wt == "flamethrower" then
      drawCrosshair(img.flameCrosshair)
      drawBR(img.flamethrower, pos.flamethrowerOffset.x, pos.flamethrowerOffset.y)
      drawCell(pos.flamethrowerCellOffset, weapon.primary.rounds, weapon.primary.total_rounds)
      drawReserve(Player.items[weapon.primary.ammo_type].count .. "x", pos.flamethrowerCellReadoutOffset)
    elseif wt == "alien weapon" then
      drawCrosshair(img.alienWeaponCrosshair, pos.crosshairAlien)
      drawBR(img.alienWeapon, pos.alienWeaponOffset.x, pos.alienWeaponOffset.y)
      drawAlienText()
    elseif wt == "shotgun" then
      drawCrosshair(img.shotgunCrosshair)
      if Player.items[wt].count > 1 then
        if weapon.secondary.weapon_drawn then
          drawBR(img.dualShotgun, pos.dualShotgunsOffset.x, pos.dualShotgunsOffset.y)
        else
          drawBR(img.dualShotgunIdle, pos.dualShotgunsOffset.x, pos.dualShotgunsOffset.y)
        end
        drawAmmo(pos.dualShotgunShellsOffset, img.shotgunAmmoEmpty, img.shotgunAmmoFull, weapon.secondary.rounds, weapon.secondary.total_rounds)
        drawAmmoR({ x = pos.dualShotgunShellsOffset.x - img.shotgunAmmoFull.width - pos.dualShotgunsSpacer, y = pos.dualShotgunShellsOffset.y }, img.shotgunAmmoEmpty,img.shotgunAmmoFull, weapon.primary.rounds, weapon.primary.total_rounds)
        drawReserve(Player.items[weapon.primary.ammo_type].count .. "x", pos.dualShotgunShellReadoutOffset)
      else
        drawBR(img.shotgun, pos.shotgunOffset.x, pos.shotgunOffset.y)
        drawAmmoR(pos.shotgunShellsOffset, img.shotgunAmmoEmpty, img.shotgunAmmoFull, weapon.primary.rounds, weapon.primary.total_rounds)
        drawReserve(Player.items[weapon.primary.ammo_type].count .. "x", pos.shotgunShellReadoutOffset)
      end
    elseif wt == "ball" then
      drawBR(img.ball, pos.ballOffset.x, pos.ballOffset.y)
    elseif wt == "smg" then
      drawCrosshair(img.smgCrosshair)
      drawBR(img.smg, pos.smgOffset.x, pos.smgOffset.y)
      
      local bullets = img.smgAmmoFull
      
      local ammoB = pos.smgClipOffset.y
      local ammoL = pos.smgClipOffset.x
      
      local extra = 24
      while extra >= 0 do
        drawAmmo({ x = ammoL, y = ammoB }, img.smgAmmoEmpty, img.smgAmmoFull, weapon.primary.rounds - extra, 8)
        extra = extra - 8
        ammoB = ammoB + bullets.height
      end

      drawReserve(Player.items[weapon.primary.ammo_type].count .. "x", pos.smgClipReadoutOffset)
    end
  end
  
  -- chip
  if Player.items["uplink chip"].count > 0 then
    drawBR(img.chipIndicator, -(img.chipIndicator.width / 2) - pos.chipOffset.x, pos.chipOffset.y - (img.chipIndicator.height / 2))
  end
  
end

function drawReserve(text, offset)
  local rw, rh = bgf:measure_text(text)
  bgf:draw_text(text, hudR - img.weaponAreaHUD.width + offset.x - (rw / 2), hudB - offset.y - bgfAdjust, { 0, 1, 0, 1 })
end

function drawReserveR(text, offset)
  local rw, rh = bgf:measure_text(text)
  bgf:draw_text(text, hudR - offset.x - (rw / 2), hudB - offset.y - bgfAdjust, { 0, 1, 0, 1 })
end

function drawAmmo(offset, empty, full, cur, max)
  drawBRL(empty, offset.x, offset.y)
  full.crop_rect.width = full.width * math.max(0, math.min(cur, max)) / max
  full.crop_rect.x = 0
  drawBRL(full, offset.x, offset.y)
end
 
function drawAmmoR(offset, empty, full, cur, max)
  drawBRL(empty, offset.x, offset.y)
  full.crop_rect.width = full.width * math.max(0, math.min(cur, max)) / max
  full.crop_rect.x = full.width - full.crop_rect.width
  drawBRL(full, offset.x - full.crop_rect.x, offset.y)
end
 
function drawBar(offset, width, cur, max, which)
  local li = img[which .. "BarLeftEnd"]
  local mi = img[which .. "Bar"]
  local ri = img[which .. "BarRightEnd"]
  
  local total_width = math.floor(width * math.max(0, math.min(cur, max)) / max)
  local cap_width = li.width + ri.width
  
  if total_width > cap_width then
    mi.crop_rect.width = mi.width
    local midoff = offset.x + li.width
    local midwidth = total_width - cap_width
    while midwidth >= mi.width do
      drawBL(mi, midoff, offset.y)
      midoff = midoff + mi.width
      midwidth = midwidth - mi.width
    end
    if midwidth > 0 then
      mi.crop_rect.width = midwidth
      drawBL(mi, midoff, offset.y)
    end
    
    li.crop_rect.x = 0
    li.crop_rect.width = li.width
    drawBL(li, offset.x, offset.y)
    
    ri.crop_rect.x = 0
    ri.crop_rect.width = ri.width
    drawBL(ri, offset.x + total_width - ri.width, offset.y)
  else
    local lwidth = math.floor(total_width / 2)
    local rwidth = total_width - lwidth
    
    li.crop_rect.x = 0
    li.crop_rect.width = lwidth
    drawBL(li, offset.x, offset.y)
    
    ri.crop_rect.x = ri.width - rwidth
    ri.crop_rect.width = rwidth
    drawBL(ri, offset.x + lwidth, offset.y)
  end
end

function drawCell(offset, cur, max)
  drawBRL(img.fillEmpty, offset.x, offset.y)
  
  local full = img.fillFull
  local h = full.height * cur / max
  full.crop_rect.height = h
  full.crop_rect.y = full.height - h
  drawBRL(full, offset.x, offset.y)
end

function drawCompass(image, offset)
  local lw = math.floor(image.width / 2)
  local rw = image.width - lw
  local th = math.floor(image.height / 2)
  local bh = image.height - th
  if Player.compass.nw or Player.compass.ne then
    image.crop_rect.y = 0
    image.crop_rect.height = th
    if Player.compass.nw then
      image.crop_rect.x = 0
      image.crop_rect.width = lw
      drawBL(image, offset.x, offset.y + bh)
    end
    if Player.compass.ne then
      image.crop_rect.x = lw
      image.crop_rect.width = rw
      drawBL(image, offset.x + lw, offset.y + bh)
    end
  end
  if Player.compass.sw or Player.compass.se then
    image.crop_rect.y = th
    image.crop_rect.height = bh
    if Player.compass.sw then
      image.crop_rect.x = 0
      image.crop_rect.width = lw
      drawBL(image, offset.x, offset.y)
    end
    if Player.compass.se then
      image.crop_rect.x = lw
      image.crop_rect.width = rw
      drawBL(image, offset.x + lw, offset.y)
    end
  end
end

function hasbit(x, p)
  return x % (p + p) >= p
end

function bitand(x, y)
  local p = 1
  while (p <= x) and (p <= y) do
    if hasbit(x, p) and hasbit(y, p) then return true end
    p = p + p
  end
  return false
end

function rand()
  return math.random(32768)-1
end

function drawAlienText()
  if bitand(Game.ticks * 2, alienWeaponFlickerMask) then
    if alienWeaponShowText then
      local text = "0xfded"
      local rw, rh = bgf:measure_text(text)
      
      Screen.clip_rect.x = hudR - pos.alienWeaponOffset.x - img.alienWeapon.width
      Screen.clip_rect.width = img.alienWeapon.width
      
      local clipB = hudB - pos.alienWeaponTextOffset.y
      local fontL = hudR - img.weaponAreaHUD.width + pos.alienWeaponTextOffset.x - rw
      local fontT = clipB - bgfAdjust
      local clipLast = clipB
      
      -- fake slant by drawing text with clipping and offset
      local i = 0
      local steps = 8
      while i < steps do
        local clipT = clipB - math.floor(rh * (i + 1) / steps)
        Screen.clip_rect.y = clipT
        Screen.clip_rect.height = clipLast - clipT
        clipLast = clipT
        
        local txtL = fontL + math.floor(alienWeaponSlant * scale * i / steps)
        bgf:draw_text(text, txtL, fontT, { 0, 1, 0, 1 })
        i = i + 1
      end
      
      Screen.clip_rect.width = Screen.width
      Screen.clip_rect.x = 0
      Screen.clip_rect.height = Screen.height
      Screen.clip_rect.y = 0
    end
    firstBackRender = true
  elseif firstBackRender then
    alienWeaponSlant = math.floor((((rand() % 200) / 201) * 100) - 50)
    if (rand() % 2) > 0 then
      if (rand() % 2) > 0 then
        alienWeaponFlickerMask = alienWeaponFlickerMask * 2
      end
      alienWeaponShowText = false
    else
      if (rand() % 2) > 0 then
        alienWeaponFlickerMask = math.floor(alienWeaponFlickerMask / 2)
      end
      alienWeaponShowText = true
    end
    if (alienWeaponFlickerMask > 0x1F00) or (alienWeaponFlickerMask < 0x3E) then
      alienWeaponFlickerMask = 0x1F0
    end
    firstBackRender = false
  end
end
    

function comp_player(a, b)
  if a.ranking > b.ranking then
    return true
  end
  if a.ranking < b.ranking then
    return false
  end
  if a.name < b.name then
    return true
  end
  return false
end

function sorted_players()
  local tbl = {}
  for i = 1,#Game.players do
    table.insert(tbl, Game.players[i - 1])
  end
  table.sort(tbl, comp_player)
  local tt = {}
  local lastrank = 1
  local lastscore = tbl[1].ranking
  for i, v in ipairs(tbl) do
    local rr = i
    if v.ranking == lastscore then
      rr = lastrank
    else
      lastscore = v.ranking
      lastrank = rr
    end
    table.insert(tt, { player = v, rank = rr })
  end
  return tt
end

function best_four()
  local tbl = sorted_players()
  local total = #tbl
  if total < 5 then return tbl end
  
  local lrank = total
  for i, v in ipairs(tbl) do
    if v.player.active then lrank = i end
  end
  if lrank < 4 then return { tbl[1], tbl[2], tbl[3], tbl[4] } end
  
  local lstart = math.min(lrank - 1, total - 2)
  return { tbl[1], tbl[lstart], tbl[lstart + 1], tbl[lstart + 2] }
end

function format_time(ticks)
   local secs = math.ceil(ticks / 30)
   return string.format("%d:%02d", math.floor(secs / 60), secs % 60)
end

function net_gamelimit()
  if Game.time_remaining then
    return "time left:", format_time(Game.time_remaining)
  end
  if Game.kill_limit then
    local max_kills = 0
    for i = 1,#Game.players do
      max_kills = math.max(max_kills, Game.players[i - 1].kills)
    end
    return "kills left:", string.format("%d", Game.kill_limit - max_kills)
  end
  return nil, nil
end
  
function ranking_text(gametype, ranking)
  if (gametype == "kill monsters") or
     (gametype == "capture the flag") or
     (gametype == "rugby") or
     (gametype == "most points") then
    return string.format("%d", ranking)
  end
  if (gametype == "least points") then
    return string.format("%d", -ranking)
  end
  if (gametype == "cooperative play") then
    return string.format("%d%%", ranking)
  end
  if (gametype == "most time") or
     (gametype == "least time") or
     (gametype == "king of the hill") or
     (gametype == "kill the man with the ball") or
     (gametype == "defense") or
     (gametype == "tag") then
    return format_time(math.abs(ranking))
  end
  
  -- unknown
  return nil
end

function drawNetText(text, offset)
  local rw, rh = ngf:measure_text(text)
  ngf:draw_text(text, hudR - offset.x - rw, hudT + offset.y - ngfAdjust, { 1, 1, 1, 1 })
end

function drawNetPlayers()
  local tr = { x = pos.scorePanelOffset.x, y = pos.scorePanelOffset.y }
  local gametype = Game.type
  if gametype == "netscript" then
    gametype = Game.scoring_mode
  end
  
  local lbl, value = net_gamelimit()
  if lbl ~= nil then
    drawNetText(lbl, { x = tr.x + pos.scorePanelNameOffset.x, y = tr.y - img.scorePanel.height + pos.scorePanelNameOffset.y })
    drawNetText(value, { x = tr.x + pos.scorePanelScoreOffset.x, y = tr.y - img.scorePanel.height + pos.scorePanelScoreOffset.y })
  end

  for i, v in ipairs(best_four()) do
    drawTR(img.scorePanelColor[v.player.team.index], tr.x, tr.y)
    if v.player.active then
      drawTR(img.scorePanelIcon, tr.x, tr.y)
    end
    drawNetText(ranking_text(gametype, v.player.ranking), { x = tr.x + pos.scorePanelScoreOffset.x, y = tr.y + pos.scorePanelScoreOffset.y })
    drawNetText(shortened_player_names[v.player.index], { x = tr.x + pos.scorePanelNameOffset.x, y = tr.y + pos.scorePanelNameOffset.y })
    drawNetText(v.rank, { x = tr.x + pos.scorePanelRankOffset.x, y = tr.y + pos.scorePanelRankOffset.y })
    
    tr.y = tr.y + img.scorePanel.height + pos.scorePanelSpacer
  end
end
  
  
  
-- BEGIN texture palette utility
--
-- Use: in Triggers.draw: "if TexturePalette.draw() then return end"
--    in Triggers.resize: "if TexturePalette.resize() then return end"

TexturePalette = {}
TexturePalette.active = false

function TexturePalette.check_active()
  local old_active = TexturePalette.active
  local new_active = false
  if Player.texture_palette.size > 0 then new_active = true end
  TexturePalette.active = new_active
  
  if old_active and not new_active then
    Screen.crosshairs.lua_hud = TexturePalette.saved_crosshairs_lua_hud
    Triggers.resize()
  elseif new_active and not old_active then
    TexturePalette.palette_cache = {}
    TexturePalette.saved_crosshairs_lua_hud = Screen.crosshairs.lua_hud
    Screen.crosshairs.lua_hud = false
    TexturePalette.resize()
  end
  return TexturePalette.active
end

function TexturePalette.get_shape(slot)
  local key = string.format("%d %d", slot.collection, slot.texture_index)
  local shp = TexturePalette.palette_cache[key]
  if not shp then
    shp = Shapes.new{collection = slot.collection, texture_index = slot.texture_index, type = slot.type}
    TexturePalette.palette_cache[key] = shp
  end
  return shp
end

function TexturePalette.draw_shape(slot, x, y, size)
  local shp = TexturePalette.get_shape(slot)
  if not shp then return end
  if shp.width > shp.height then
    shp:rescale(size, shp.unscaled_height * size / shp.unscaled_width)
    shp:draw(x, y + (size - shp.height)/2)
  else
    shp:rescale(shp.unscaled_width * size / shp.unscaled_height, size)
    shp:draw(x + (size - shp.width)/2, y)
  end
end

function TexturePalette.draw(hr)
  if not TexturePalette.check_active() then return false end
  
  local hr = TexturePalette.hud_rect
  local tcount = Player.texture_palette.size
  local size
  if     tcount <=   5 then size = 128
  elseif tcount <=  16 then size =  80
  elseif tcount <=  36 then size =  53
  elseif tcount <=  64 then size =  40
  elseif tcount <= 100 then size =  32
  elseif tcount <= 144 then size =  26
  else                      size =  20
  end
  size = size * hr.scale
  
  local rows = math.floor(hr.height/size)
  local cols = math.floor(hr.width/size)
  local x_offset = hr.x + (hr.width - cols * size)/2
  local y_offset = hr.y + (hr.height - rows * size)/2
  
  for i = 0,tcount - 1 do
    TexturePalette.draw_shape(
      Player.texture_palette.slots[i],
      (i % cols) * size + x_offset + hr.scale/2,
      math.floor(i / cols) * size + y_offset + hr.scale/2,
      size - hr.scale)
  end
  
  if Player.texture_palette.highlight then
    local i = Player.texture_palette.highlight
    Screen.frame_rect(
      (i % cols) * size + x_offset,
      math.floor(i / cols) * size + y_offset,
      size, size,
      InterfaceColors["inventory text"],
      hr.scale)
  end
  
  return true
end

function TexturePalette.resize()
  if not TexturePalette.check_active() then return false end
  
  local ww = Screen.width
  local wh = Screen.height
  
  -- calculate HUD area
  TexturePalette.hud_rect = {}
  local hudsize = Screen.hud_size_preference
  TexturePalette.hud_rect.width = 640
  if hudsize == SizePreferences["double"] then
    if wh >= 960 and ww >= 1280 then
      TexturePalette.hud_rect.width = 1280
    end
  elseif hudsize == SizePreferences["largest"] then
    TexturePalette.hud_rect.width = math.min(ww, math.max(640, (4 * wh) / 3));
  end
  
  TexturePalette.hud_rect.height = TexturePalette.hud_rect.width / 4
  TexturePalette.hud_rect.x = math.floor((ww - TexturePalette.hud_rect.width) / 2)
  TexturePalette.hud_rect.y = math.floor(wh - TexturePalette.hud_rect.height)
  
  TexturePalette.hud_rect.scale = TexturePalette.hud_rect.width / 640

  -- remove HUD height from rest of calculations
  wh = TexturePalette.hud_rect.y
  
  -- calculate terminal area
  local termsize = Screen.term_size_preference
  Screen.term_rect.width = 640
  if termsize == SizePreferences["double"] then
    if wh >= 640 and ww >= 1280 then
      Screen.term_rect.width = 1280
    end
  elseif termsize == SizePreferences["largest"] then
    Screen.term_rect.width = math.min(ww, math.max(640, 2 * wh))
  end
  
  Screen.term_rect.height = Screen.term_rect.width / 2
  Screen.term_rect.x = math.floor((ww - Screen.term_rect.width) / 2)
  Screen.term_rect.y = math.floor((wh - Screen.term_rect.height) / 2)
  
  -- calculate world-view area
  Screen.world_rect.width = math.min(ww, math.max(640, 2 * wh))
  Screen.world_rect.height = Screen.world_rect.width / 2
  Screen.world_rect.x = math.floor((ww - Screen.world_rect.width) / 2)
  Screen.world_rect.y = math.floor((wh - Screen.world_rect.height) / 2)
  
  -- calculate map area
  if Screen.map_overlay_active then
    -- overlay just matches world-view
    Screen.map_rect.width = Screen.world_rect.width
    Screen.map_rect.height = Screen.world_rect.height
    Screen.map_rect.x = Screen.world_rect.x
    Screen.map_rect.y = Screen.world_rect.y
  else
    Screen.map_rect.width = ww
    Screen.map_rect.height = wh
    Screen.map_rect.x = 0
    Screen.map_rect.y = 0
  end
  
  Screen.clip_rect.width = Screen.width
  Screen.clip_rect.height = Screen.height
  Screen.clip_rect.x = 0
  Screen.clip_rect.y = 0

  return true
end

-- END texture palette utility
