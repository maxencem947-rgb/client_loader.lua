local menuOuvert = false
local indexSelectionne = 1
local indexCategorieSelectionnee = nil
local joueursSelectionnes = {}  -- Liste des joueurs sélectionnés
local rayon = 150  -- Rayon de détection des joueurs
local joueursProches = {}  -- Liste des joueurs à proximité
local toucheMenu = nil  -- Touche assignée pour ouvrir/fermer le menu
local enAttenteTouche = true  -- Flag pour savoir si on attend la sélection de la touche

-- Liste des catégories
local itemsMenu = {
    {name = "Player", options = {"Self", "Online", "Visual", "Combat", "Vehicle", "Miscellaneous", "Settings"}},
    {name = "Online", options = {"Option1", "Option2", "Option3"}},
    {name = "Visual", options = {"Option1", "Option2", "Option3"}},
    {name = "Combat", options = {"Option1", "Option2", "Option3"}},
    {name = "Vehicle", options = {"Option1", "Option2", "Option3"}},
    {name = "Miscellaneous", options = {"Option1", "Option2", "Option3"}},
    {name = "Settings", options = {"Option1", "Option2", "Option3"}}
}

-- Position du menu à l'écran
local posX, posY = 0.1, 0.5
local largeurMenu, hauteurMenu = 0.25, 0.3

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

-- Dessiner la barre de titre avec "DERVONn" en gros et stylisé
local function dessinerBarreTitre()
    -- Dessiner la barre de titre en rouge
    dessinerCadre(posX, posY - 0.08, largeurMenu, 0.08, 255, 0, 0, 255)
    
    -- Afficher "DERVONn" en gros et stylisé (police par défaut de FiveM : Roboto)
    SetTextFont(4)  -- Utilisation de la police Roboto
    dessinerTexte(posX, posY - 0.075, "DERVONn", 1.0, 1.0, 255, 255, 255, 255)  -- Texte en grand
    dessinerTexte(posX, posY - 0.03, "Main Menu", 0.4, 0.4, 255, 255, 255, 255)
end

-- Fonction pour récupérer les joueurs à proximité dans un rayon de 150 unités
local function getJoueursProches()
    joueursProches = {}
    local joueurActuel = PlayerPedId()  -- ID du joueur actuel
    local x, y, z = table.unpack(GetEntityCoords(joueurActuel))  -- Position du joueur actuel

    -- Parcours des joueurs et ajout à la liste s'ils sont dans le rayon de 150 unités
    for _, joueur in ipairs(GetActivePlayers()) do
        if joueur ~= joueurActuel then
            local ped = GetPlayerPed(joueur)
            local px, py, pz = table.unpack(GetEntityCoords(ped))
            local distance = Vdist(x, y, z, px, py, pz)
            if distance <= rayon then
                table.insert(joueursProches, {id = joueur, name = GetPlayerName(joueur), distance = distance})
            end
        end
    end
end

-- Fonction pour dessiner la liste des joueurs à proximité dans le menu "Online"
local function dessinerListeJoueurs()
    getJoueursProches()  -- Récupérer les joueurs à proximité

    dessinerCadre(posX, posY, largeurMenu, hauteurMenu, 0, 0, 0, 150)  -- Fond du menu
    dessinerBarreTitre()

    -- Afficher la liste des joueurs proches
    for i, joueur in ipairs(joueursProches) do
        local couleur = (joueursSelectionnes[joueur.id]) and {r = 255, g = 0, b = 0} or {r = 255, g = 255, b = 255}  -- Rouge si sélectionné, sinon blanc
        dessinerTexte(posX, posY + 0.05 + i * 0.05, joueur.name, 0.4, 0.4, couleur.r, couleur.g, couleur.b, 255)

        -- Dessiner la distance du joueur
        dessinerTexte(posX + 0.18, posY + 0.05 + i * 0.05, string.format("Distance: %.1f", joueur.distance), 0.3, 0.3, 255, 255, 255, 255)
    end
end

-- Fonction pour gérer la sélection/désélection des joueurs
local function gererSelectionJoueur()
    if IsControlJustPressed(0, 172) then  -- Flèche haut
        indexSelectionne = indexSelectionne - 1
        if indexSelectionne < 1 then indexSelectionne = #joueursProches end
    end
    if IsControlJustPressed(0, 173) then  -- Flèche bas
        indexSelectionne = indexSelectionne + 1
        if indexSelectionne > #joueursProches then indexSelectionne = 1 end
    end

    -- Sélectionner ou désélectionner un joueur
    if IsControlJustPressed(0, 191) then  -- Entrée
        local joueurSelectionne = joueursProches[indexSelectionne]
        if joueurSelectionne then
            -- Inverser la sélection
            joueursSelectionnes[joueurSelectionne.id] = not joueursSelectionnes[joueurSelectionne.id]
        end
    end
end

-- Afficher la demande de sélection de touche pour ouvrir le menu
local function afficherDemandeTouche()
    -- Si aucune touche n'est assignée, afficher un message demandant à l'utilisateur de sélectionner une touche
    if enAttenteTouche then
        dessinerCadre(0.5, 0.5, 0.25, 0.08, 0, 0, 0, 150)
        dessinerTexte(0.5, 0.5, "Appuyez sur une touche pour ouvrir/fermer le menu", 0.5, 0.5, 255, 255, 255, 255)
    elseif toucheMenu then
        -- Si une touche a été sélectionnée, afficher la touche assignée
        dessinerCadre(0.5, 0.5, 0.25, 0.08, 0, 0, 0, 150)
        dessinerTexte(0.5, 0.5, "Touche assignée: " .. GetControlInstructionalButton(0, toucheMenu, true), 0.5, 0.5, 255, 255, 255, 255)
    end
end

-- Déplacement du menu avec la souris
local function deplacerMenu()
    if IsControlPressed(0, 25) then -- Clic droit (contrôle de souris)
        local sourisX, sourisY = GetCursorPosition()
        posX = sourisX / GetScreenWidth()
        posY = sourisY / GetScreenHeight()
    end
end

-- Fonction principale pour gérer les entrées
local function gererEntrees()
    if indexCategorieSelectionnee == 2 then  -- Si on est sur la catégorie "Online"
        -- Gérer la sélection des joueurs
        gererSelectionJoueur()
    else
        -- Navigation dans le menu principal
        if IsControlJustPressed(0, 172) then  -- Flèche haut
            indexSelectionne = indexSelectionne - 1
            if indexSelectionne < 1 then indexSelectionne = #itemsMenu end
        end
        if IsControlJustPressed(0, 173) then  -- Flèche bas
            indexSelectionne = indexSelectionne + 1
            if indexSelectionne > #itemsMenu then indexSelectionne = 1 end
        end

        -- Sélectionner une catégorie
        if IsControlJustPressed(0, 191) then  -- Entrée
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
                if indexCategorieSelectionnee == 2 then
                    dessinerListeJoueurs()
                else
                    dessinerMenuPrincipal()
                end
            end
        end
    end
end)

