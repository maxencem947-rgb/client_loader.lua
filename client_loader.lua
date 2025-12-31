-- Configuration des touches
local toggleMenuKey = "F1"  -- touche pour ouvrir/fermer le menu
local selectKey = "ENTER"   -- touche pour valider
local upKey = "UP"          -- touche pour monter
local downKey = "DOWN"      -- touche pour descendre

-- Menu
local menuItems = {"Self", "Online", "Serveur", "Combat", "Paramètre"}
local menuOpen = false
local selectedIndex = 1

-- Fonction pour afficher le menu
local function drawMenu()
    print("\n===== MENU =====")
    for i, item in ipairs(menuItems) do
        if i == selectedIndex then
            print("> " .. item)
        else
            print("  " .. item)
        end
    end
end

-- Fonction pour gérer l’input
local function handleInput()
    while true do
        if Susano.IsKeyPressed(toggleMenuKey) then
            menuOpen = not menuOpen
            if menuOpen then
                print("Menu ouvert !")
                drawMenu()
            else
                print("Menu fermé !")
            end
            Susano.Wait(200) -- anti-rebond
        end

        if menuOpen then
            if Susano.IsKeyPressed(upKey) then
                selectedIndex = selectedIndex - 1
                if selectedIndex < 1 then selectedIndex = #menuItems end
                drawMenu()
                Susano.Wait(150)
            end

            if Susano.IsKeyPressed(downKey) then
                selectedIndex = selectedIndex + 1
                if selectedIndex > #menuItems then selectedIndex = 1 end
                drawMenu()
                Susano.Wait(150)
            end

            if Susano.IsKeyPressed(selectKey) then
                print("Vous avez sélectionné : " .. menuItems[selectedIndex])
                -- Ici tu peux appeler la fonction correspondante
                Susano.Wait(200)
            end
        end

        Susano.Wait(10) -- boucle principale
    end
end

-- Lancer le menu
handleInput()

