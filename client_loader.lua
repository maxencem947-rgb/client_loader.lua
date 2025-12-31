local menuOuvert = false
local indexSelectionne = 1
local indexCategorieSelectionnee = nil
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

-- Position du menu à l'écran
local posX, posY = 0.1, 0.5
local largeurMenu, hauteurMenu = 0.2, 0.3

-- Variable pour détecter l'entrée de l'utilisateur pour choisir la touche d'ouverture/fermeture du menu
local enAttenteTouche = true

-- Fonction pour dessiner un cadre générique
local function dessinerCadre(x, y, largeur, hauteur, r, g, b, a)
    DrawRect(x, y, largeur, hauteur, r, g, b, a)
end

-- Fonction pour dessiner le texte avec ombre et couleur
local function dessinerTexte(x, y, texte, tailleX, tailleY, r, g, b, a)
    SetTextFont(0)
    SetTextProportional(1)
    SetTextScale(tailleX, tailleY)
    SetTextColour(0, 0, 0, 255)  -- Ombre noire pour le texte
    SetTextEntry("STRING")
    AddTextComponentString(texte)
    DrawText(x + 0.02, y + 0.02)
    SetTextColour(r, g, b, a)  -- Texte principal
    DrawText(x, y)
end

-- Fonction pour dessiner le menu principal
local function dessinerMenuPrincipal()
    dessinerCadre(posX, posY, largeurMenu, hauteurMenu, 0, 0, 0, 150)
    dessinerCadre(posX, posY, largeurMenu, hauteurMenu, 255, 0, 0, 255) -- Bordure rouge

    dessinerTexte(posX, posY - 0.07, "Bnz'", 0.6, 0.6, 255, 0, 0, 255)

    -- Dessiner les catégories principales
    for i, category in ipairs(itemsMenu) do
        local couleur = (i == indexSelectionne) and {r = 0, g = 255, b = 0} or {r = 255, g = 255, b = 255}
        dessinerTexte(posX, posY + 0.05 + i * 0.05, category.name, 0.4, 0.4, couleur.r, couleur.g, couleur.b, 255)
    end
end

-- Fonction pour dessiner le sous-menu avec les options
local function dessinerSousMenu()
    local category = itemsMenu[indexCategorieSelectionnee]
    dessinerCadre(posX, posY, largeurMenu, hauteurMenu, 0, 0, 0, 150)
    dessinerCadre(posX, posY, largeurMenu, hauteurMenu, 255, 0, 0, 255) -- Bordure rouge

    dessinerTexte(posX, posY - 0.07, category.name, 0.6, 0.6, 255, 0, 0, 255)

    -- Dessiner les options du sous-menu
    for i, option in ipairs(category.options) do
        local couleur = (i == indexSelectionne) and {r = 0, g = 255, b = 0} or {r = 255, g = 255, b = 255}
        dessinerTexte(posX, posY + 0.05 + i * 0.05, option, 0.4, 0.4, couleur.r, couleur.g, couleur.b, 255)
    end
end

-- Fonction pour afficher la demande de sélection de touche
local function afficherDemandeTouche()
    dessinerTexte(0.25, 0.5, "Appuyez sur une touche pour ouvrir/fermer le menu", 0.5, 0.5, 255, 255, 255, 255)
end

-- Fonction pour déplacer le menu
local function deplacerMenu()
    if IsControlPressed(0, 25) then -- Clic droit (contrôle de souris)
        local sourisX, sourisY = GetCursorPosition()
        posX = sourisX / GetScreenWidth()
        posY = sourisY / GetScreenHeight()
    end
end

-- Fonction principale de gestion des entrées
local function gererEntrees()
    if indexCategorieSelectionnee then
        -- Navigation des options dans le sous-menu
        if IsControlJustPressed(0, 172) then -- Flèche haut
            indexSelectionne = indexSelectionne - 1
            if indexSelectionne < 1 then indexSelectionne = #itemsMenu[indexCategorieSelectionnee].options end
        end
        if IsControlJustPressed(0, 173) then -- Flèche bas
            indexSelectionne = indexSelectionne + 1
            if indexSelectionne > #itemsMenu[indexCategorieSelectionnee].options then indexSelectionne = 1 end
        end

        -- Retour au menu principal avec la touche Supprimer
        if IsControlJustPressed(0, 178) then -- Touche Supprimer (Delete)
            indexCategorieSelectionnee = nil
            indexSelectionne = 1
        end
    else
        -- Navigation dans le menu principal
        if IsControlJustPressed(0, 172) then -- Flèche haut
            indexSelectionne = indexSelectionne - 1
            if indexSelectionne < 1 then indexSelectionne = #itemsMenu end
        end
        if IsControlJustPressed(0, 173) then -- Flèche bas
            indexSelectionne = indexSelectionne + 1
            if indexSelectionne > #itemsMenu then indexSelectionne = 1 end
        end

        -- Sélectionner une catégorie
        if IsControlJustPressed(0, 191) then -- Entrée
            indexCategorieSelectionnee = indexSelectionne
            indexSelectionne = 1
        end
    end
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
                -- Déplacer le menu avec la souris
                deplacerMenu()

                -- Gérer les entrées utilisateur
                gererEntrees()

                -- Afficher le menu ou le sous-menu
                if indexCategorieSelectionnee then
                    dessinerSousMenu()
                else
                    dessinerMenuPrincipal()
                end
            end
        end
    end
end)




