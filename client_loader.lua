-- ========================
-- MENU PRINCIPAL (COMPLET)
-- ========================

-- Menu State
local menuOpen = false
local selectedIndex = 1
local currentSubMenu = nil

-- Main Menu Items
local menuItems = {
  { label = "Player", icon = ">" },
  { label = "Online", icon = ">" },
  { label = "Visual", icon = ">" },
  { label = "Combat", icon = ">" },
  { label = "Vehicle", icon = ">" },
  { label = "Miscellaneous", icon = ">" },
  { label = "Settings", icon = ">" }
}

-- Sub‑menus
local subMenus = {
  Visual = {
    { label = "ESP Players", action = "visual:esp_players" },
    { label = "ESP Vehicles", action = "visual:esp_vehicles" },
    { label = "Skeleton Players", action = "visual:skeleton_players" },
    { label = "Name Tags", action = "visual:nametags" },
    { label = "Distance Info", action = "visual:distance_info" },
    { label = "Back", action = "back" }
  },
  -- tu peux ajouter d'autres submenus ici (Par exemple Online, Combat, etc.)
}

-- COLORS
local colors = {
  red = { r = 220, g = 20, b = 20, a = 255 },
  darkRed = { r = 139, g = 0, b = 0, a = 255 },
  black = { r = 0, g = 0, b = 0, a = 200 },
  white = { r = 255, g = 255, b = 255, a = 255 },
  gray = { r = 50, g = 50, b = 50, a = 255 },
}

-- Menu Position
local menuConfig = {
  startX = 0.18,
  startY = 0.15,
  width = 0.25,
  itemHeight = 0.05,
  headerHeight = 0.08
}

-- DRAW TEXT
local function drawText(text, x, y, scale, r, g, b, a)
  SetTextFont(4)
  SetTextScale(scale, scale)
  SetTextColour(r, g, b, a)
  SetTextDropshadow(0, 0, 0, 0, 255)
  BeginTextCommandDisplayText("STRING")
  AddTextComponentString(text)
  DrawText(x, y)
end

-- DRAW RECT
local function drawRect(x, y, width, height, r, g, b, a)
  DrawRect(x + width / 2, y + height / 2, width, height, r, g, b, a)
end

-- DRAW MENU
local function drawMenu()
  if not menuOpen then return end

  local x = menuConfig.startX
  local y = menuConfig.startY
  local w = menuConfig.width
  local hItem = menuConfig.itemHeight
  local hHeader = menuConfig.headerHeight

  -- Header BG
  drawRect(x, y, w, hHeader, colors.darkRed.r, colors.darkRed.g, colors.darkRed.b, colors.darkRed.a)
  drawText(currentSubMenu and "["..currentSubMenu.."]" or "Main Menu", x + 0.02, y + 0.015, 0.4, colors.white.r, colors.white.g, colors.white.b, colors.white.a)

  if currentSubMenu then
    -- Draw SubMenu
    local items = subMenus[currentSubMenu]
    for i, v in ipairs(items) do
      local itemY = y + hHeader + (i - 1) * hItem
      if i == selectedIndex then
        drawRect(x, itemY, w, hItem, colors.red.r, colors.red.g, colors.red.b, colors.red.a)
      else
        drawRect(x, itemY, w, hItem, colors.black.r, colors.black.g, colors.black.b, colors.black.a)
      end
      drawText(v.label, x + 0.02, itemY + 0.012, 0.35, colors.white.r, colors.white.g, colors.white.b, colors.white.a)
    end
  else
    -- Draw Main Menu
    for i, v in ipairs(menuItems) do
      local itemY = y + hHeader + (i - 1) * hItem
      if i == selectedIndex then
        drawRect(x, itemY, w, hItem, colors.red.r, colors.red.g, colors.red.b, colors.red.a)
      else
        drawRect(x, itemY, w, hItem, colors.black.r, colors.black.g, colors.black.b, colors.black.a)
      end

      drawText(v.label, x + 0.02, itemY + 0.012, 0.35, colors.white.r, colors.white.g, colors.white.b, colors.white.a)
      drawText(v.icon, x + w - 0.03, itemY + 0.012, 0.35, colors.white.r, colors.white.g, colors.white.b, colors.white.a)
    end
  end
end

-- HANDLE INPUT
local function handleMenuInput()
  if IsControlJustReleased(0, 188) then -- UP
    selectedIndex = selectedIndex - 1
    if selectedIndex < 1 then
      selectedIndex = currentSubMenu and #subMenus[currentSubMenu] or #menuItems
    end
  elseif IsControlJustReleased(0, 187) then -- DOWN
    selectedIndex = selectedIndex + 1
    if selectedIndex > (currentSubMenu and #subMenus[currentSubMenu] or #menuItems) then
      selectedIndex = 1
    end
  elseif IsControlJustReleased(0, 191) then -- ENTER
    if currentSubMenu then
      local action = subMenus[currentSubMenu][selectedIndex].action
      if action == "back" then
        -- back to main menu
        currentSubMenu = nil
        selectedIndex = 1
      else
        -- Trigger event for action
        TriggerEvent(action)
      end
    else
      local label = menuItems[selectedIndex].label
      if subMenus[label] then
        currentSubMenu = label
        selectedIndex = 1
      else
        TriggerEvent("menu:selected", label)
      end
    end
  end
end

-- TOGGLE MENU (Touche + Commande)
function ToggleMenu()
  menuOpen = not menuOpen
  selectedIndex = 1
  if not menuOpen then
    currentSubMenu = nil
  end
end

-- OPEN MENU WITH F1
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)
    if IsControlJustReleased(0, 288) then -- F1
      ToggleMenu()
    end
    if menuOpen then
      handleMenuInput()
    end
    drawMenu()
  end
end)

-- CHAT COMMAND
RegisterCommand('menu', function()
  ToggleMenu()
end, false)

-- MENU SELECTION EVENT
RegisterNetEvent('menu:selected')
AddEventHandler('menu:selected', function(itemLabel)
  print("Selected: " .. itemLabel)
end)

-- ===== EXEMPLE D’ACTIONS POUR VISUAL =====

RegisterNetEvent('visual:esp_players', function()
  print("🔎 ESP Players toggled")
  -- Ajoute ta logique ESP ici
end)

RegisterNetEvent('visual:esp_vehicles', function()
  print("🚗 ESP Vehicles toggled")
end)

RegisterNetEvent('visual:skeleton_players', function()
  print("💀 Skeleton Players toggled")
end)

RegisterNetEvent('visual:nametags', function()
  print("🏷️ Name Tags toggled")
end)

RegisterNetEvent('visual:distance_info', function()
  print("📏 Distance Info toggled")
end)

