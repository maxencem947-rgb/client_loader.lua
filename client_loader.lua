local menuOuvert = false
local indexSelectionne = 1
local itemsMenu = {
    {name = "Player", options = {"Self", "Online", "Visual", "Combat", "Vehicle", "Miscellaneous", "Settings"}},
    {name = "Online", options = {"Option1", "Option2", "Option3"}},
    {name = "Visual", options = {"Option1", "Option2", "Option3"}},
    {name = "Combat", options = {"Option1", "Option2", "Option3"}},
    {name = "Vehicle", options = {"Option1", "Option2", "Option3"}},
    {name = "Miscellaneous", options = {"Option1", "Option2", "Option3"}},
    {name = "Settings", options = {"Option1", "Option2", "Option3"}}
}

-- Touche par défaut pour ouvrir/fermer le menu (F1 = 288)
local toucheMenu = 288

-- Variable pour détecter l'entrée de l'utilisateur pour choisir la touche d'ouverture/fermeture du menu
local enAttenteTouche = true
local toucheSelectionnee = nil

-- Fonction pour dessiner le menu
local function dessinerMenu()
    -- Dessiner le fond (dégradé rouge et noir similaire à l'image)
    DrawRect(0.1, 0.5, 0.2, 0.3, 0, 0, 0, 150)

    -- Dessiner le titre du menu
    SetTextFont(0)
    SetTextProportional(1)
    SetTextScale(0.6, 0.6)
    SetTextColour(255, 0, 0, 255)  -- Texte rouge pour le titre
    SetTextEntry("STRING")
    AddTextComponentString("Bnz'")  -- Le titre du menu
    DrawText(0.12, 0.42)

    -- Dessiner les catégories
    for i, category in ipairs(itemsMenu) do
        local couleur = {r = 255, g = 255, b = 255}
        if i == indexSelectionne then
            couleur = {r = 0, g = 255, b = 0} -- Vert pour l'élément sélectionné
        end
        SetTextFont(0)
        SetTextProportional(1)
        SetTextScale(0.4, 0.4)
        SetTextColour(couleur.r, couleur.g, couleur.b, 255)
        SetTextEntry("STRING")
        AddTextComponentString(category.name)
        DrawText(0.03, 0.45 + i * 0.05)

        -- Dessiner les sous-options lorsque la catégorie est sélectionnée
        if i == indexSelectionne then
            local offsetY = 0.0
            for j, option in ipairs(category.options) do
                SetTextColour(255, 255, 255, 255)
                SetTextEntry("STRING")
                AddTextComponentString(option)
                DrawText(0.08, 0.48 + i * 0.05 + offsetY)
                offsetY = offsetY + 0.04
            end
        end
    end
end

-- Fonction pour afficher la demande de sélection de touche
local function afficherDemandeTouche()
    SetTextFont(0)
    SetTextProportional(1)
    SetTextScale(0.5, 0.5)
    SetTextColour(255, 255, 255, 255)
    SetTextEntry("STRING")
    AddTextComponentString("Appuyez sur une touche pour ouvrir/fermer le menu")
    DrawText(0.25, 0.5)
end

-- Boucle principale
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        -- Si nous attendons la sélection de la touche
        if enAttenteTouche then
            afficherDemandeTouche()

            -- Détecter la pression d'une touche pour définir la touche d'ouverture/fermeture
            for i = 1, 255 do
                if IsControlJustPressed(0, i) then
                    toucheMenu = i
                    enAttenteTouche = false
                    print("Touche sélectionnée : " .. i)
                    break
                end
            end
        else
            -- Attendre la pression de la touche pour ouvrir/fermer le menu
            if IsControlJustPressed(0, toucheMenu) then
                menuOuvert = not menuOuvert
            end

            if menuOuvert then
                -- Navigation (haut et bas)
                if IsControlJustPressed(0, 172) then -- Flèche haut
                    indexSelectionne = indexSelectionne - 1
                    if indexSelectionne < 1 then indexSelectionne = #itemsMenu end
                end
                if IsControlJustPressed(0, 173) then -- Flèche bas
                    indexSelectionne = indexSelectionne + 1
                    if indexSelectionne > #itemsMenu then indexSelectionne = 1 end
                end

                -- Valider (Entrée)
                if IsControlJustPressed(0, 191) then -- Entrée
                    print("Option sélectionnée : " .. itemsMenu[indexSelectionne].name)
                    -- Actions à ajouter selon l'option choisie
                end

                -- Dessiner le menu
                dessinerMenu()
            end
        end
    end
end)



