local menuOpen = false
local selectedIndex = 1
local menuItems = {"Self", "Online", "Serveur", "Combat", "Paramètre"}

-- Touche pour ouvrir/fermer le menu (F1 = 288)
local toggleMenuKey = 288

-- Fonction pour dessiner le menu
local function drawMenu()
    -- Rectangle de fond
    DrawRect(0.1, 0.5, 0.15, 0.2, 0, 0, 0, 150)
    
    for i, item in ipairs(menuItems) do
        local color = {r=255, g=255, b=255}
        if i == selectedIndex then
            color = {r=0, g=255, b=0} -- vert sélection
        end
        SetTextFont(0)
        SetTextProportional(1)
        SetTextScale(0.4, 0.4)
        SetTextColour(color.r, color.g, color.b, 255)
        SetTextEntry("STRING")
        AddTextComponentString(item)
        DrawText(0.03, 0.45 + i * 0.03)
    end
end

-- Boucle principale
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        -- Attendre la touche pour ouvrir/fermer
        if IsControlJustPressed(0, toggleMenuKey) then
            menuOpen = not menuOpen
        end

        if menuOpen then
            -- Navigation Haut/Bas
            if IsControlJustPressed(0, 172) then -- flèche haut
                selectedIndex = selectedIndex - 1
                if selectedIndex < 1 then selectedIndex = #menuItems end
            end
            if IsControlJustPressed(0, 173) then -- flèche bas
                selectedIndex = selectedIndex + 1
                if selectedIndex > #menuItems then selectedIndex = 1 end
            end

            -- Valider
            if IsControlJustPressed(0, 191) then -- Entrée
                print("Option sélectionnée : " .. menuItems[selectedIndex])
                -- Ici tu peux ajouter les actions selon l’option
            end

            -- Afficher le menu
            drawMenu()
        end
    end
end)

