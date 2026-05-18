-- test

fontType = {-- (1)font (2)scale offset
	["default"] = {"default", 1},
	["default-bold"] = {"default-bold",1},
	["clear"] = {"clear",1.1},
	["arial"] = {"arial",1},
	["sans"] = {"sans",1.2},
	["pricedown"] = {"pricedown",3},
	["bankgothic"] = {"bankgothic",4},
	["diploma"] = {"diploma",2},
	["beckett"] = {"beckett",2},
	["BizNoteFont18"] = {"BizNoteFont18",1.1},
}

-- Menu variables
local screenW, screenH = guiGetScreenSize()
local menuShowing = false

-- vozidla
local carids = ""
local numcars = 0
local printCar = ""

-- nemovitosti
local properties = ""
local numproperties = 0

-- reporty
local onlineStaff = 0
local onDutyStaff = 0

GridLib.config = {
    gridCountX = 60,   -- počet stĺpcov
    gridCountY = 30,   -- počet riadkov
    gap        = 5,    -- medzera (v pixeloch) medzi bunkami
    edgeMargin = 20    -- okraj (v pixeloch) od okrajov obrazovky
}

roboto = dxCreateFont("f10_fonts/roboto.ttf", 10)
animated_rects = {
    top = {
        garaz = GridLib.createDiv(18, 4, 29, 15, tocolor(28, 28, 34, 255), {roundness = 10, bgImage = "f10_images/garage.png", text = " Garáž\n\n " ..printCar , textColor = tocolor(255, 255, 255, 255), textScale = 1.5, textFont = "default-bold", textAlignH = "left", textAlignV = "top", }),
        nehnutelnosti = GridLib.createDiv(30, 4, 41, 15, tocolor(28, 28, 34, 255),{roundness = 10, text=" Nemovitosti", bgImage = "f10_images/nehnutelnosti.png" , textColor=tocolor(255, 255, 255, 255), textScale=1.5, textFont="default-bold", textAlignH="left", textAlignV="top"}),

        profil = GridLib.createDiv(7, 4, 17, 9, tocolor(28, 28, 34, 255), {roundness = 10,  text=" Profil", bgImage = "f10_images/account.png", textColor=tocolor(255, 255, 255, 255), textScale=1.5, textFont="default-bold", textAlignH="left", textAlignV="top"}),
		profilLabel = GridLib.createDiv(7, 4, 17, 9, tocolor(28, 28, 34, 0), {roundness = 10, text="\n\n  "..getElementData(localPlayer, "account:username").. "\n  "..getPlayerName(localPlayer):gsub("_", " "), textColor=tocolor(255, 255, 255, 255), textScale=1, textFont="default-bold", textAlignH="left", textAlignV="top"}),
	},	
    bottom = {
        mapa = GridLib.createDiv(18, 16, 29, 27, tocolor(28, 28, 34, 255), {roundness = 10, bgImage = "f10_images/map.png", text = " Mapa", textColor=tocolor(255, 255, 255, 255), textScale=1.5, textFont="default-bold", textAlignH="left", textAlignV="top"}),
        reports = GridLib.createDiv(30, 16, 41, 21, tocolor(28, 28, 34, 255), {roundness = 10, bgImage = "f10_images/report.png", text = " Reporty\n\n  Staff online: "..onlineStaff.. "\n  Ve službě: "..onDutyStaff.."", textColor=tocolor(255, 255, 255, 255), textScale=1.5, textFont="default-bold", textAlignH="left", textAlignV="top"}),
        news = GridLib.createDiv(30, 22, 41, 27, tocolor(28, 28, 34, 255), {roundness = 10, bgImage = "f10_images/news.png", text = " Novinky", textColor=tocolor(255, 255, 255, 255), textScale=1.5, textFont="default-bold", textAlignH="left", textAlignV="top"}),

        daco = GridLib.createDiv(7, 22, 17, 24, tocolor(28, 28, 34, 255), {roundness = 10, text = "Přátele", hoverBgColor = tocolor(35,35,44,250), textColor=tocolor(255, 255, 255, 255), textScale=1.2, textFont="default-bold", textAlignH="center", textAlignV="center"}),
		daco2 = GridLib.createDiv(7, 25, 17, 27, tocolor(28, 28, 34, 255), {roundness = 10, text = "Discord", hoverBgColor = tocolor(35,35,44,250), textColor=tocolor(255, 255, 255, 255), textScale=1.2, textFont="default-bold", textAlignH="center", textAlignV="center"}),
    },
    left = {
        nastavenia = GridLib.createDiv(7, 10, 17, 15, tocolor(28, 28, 34, 255), {roundness = 10 , bgImage = "f10_images/settings.png",  text=" Nastavení", textColor=tocolor(255, 255, 255, 255), textScale=1.5, textFont="default-bold", textAlignH="left", textAlignV="top"}),
        shop = GridLib.createDiv(7, 16, 17, 21, tocolor(28, 28, 34, 255), {roundness = 10, text = " Shop", bgImage = "f10_images/shop.png", textColor=tocolor(255, 255, 255, 255), textScale=1.5, textFont="default-bold", textAlignH="left", textAlignV="top"}), 
    },
    right = {
        b1 = GridLib.createDiv(42, 4, 47, 6, tocolor(28, 28, 34, 255), {roundness = 10, text="Změnit postavu",  hoverBgColor = tocolor(35,35,44,250), clickBgColor = tocolor(60,60,60,250), textColor=tocolor(255, 255, 255, 255), textScale=1, textFont="default-bold", textAlignH="center", textAlignV="center"}),
        b2 = GridLib.createDiv(42, 7, 47, 9, tocolor(28, 28, 34, 255), {roundness = 10, text="Online Rádia", hoverBgColor = tocolor(35,35,44,250), clickBgColor = tocolor(60,60,60,250), textColor=tocolor(255, 255, 255, 255), textScale=1, textFont="default-bold", textAlignH="center", textAlignV="center"}),
        
		--b3 = GridLib.createDiv(42, 10, 47, 12, tocolor(28, 28, 34, 255), {roundness = 10, text="Manažment Staffu", hoverBgColor = tocolor(35,35,44,250), clickBgColor = tocolor(60,60,60,250), textColor=tocolor(255, 255, 255, 255), textScale=1, textFont="default-bold", textAlignH="center", textAlignV="center"}),
        --b4 = GridLib.createDiv(42, 13, 47, 15, tocolor(28, 28, 34, 255), {roundness = 10, text="Manažment Frakci", hoverBgColor = tocolor(35,35,44,250), clickBgColor = tocolor(60,60,60,250), textColor=tocolor(255, 255, 255, 255), textScale=1, textFont="default-bold", textAlignH="center", textAlignV="center"}),
		--b5 = GridLib.createDiv(42, 16, 47, 18, tocolor(28, 28, 34, 255), {roundness = 10, text="Manažment Interieru", hoverBgColor = tocolor(35,35,44,250), clickBgColor = tocolor(60,60,60,250), textColor=tocolor(255, 255, 255, 255), textScale=1, textFont="default-bold", textAlignH="center", textAlignV="center"}),
		--b6 = GridLib.createDiv(42, 19, 47, 21, tocolor(28, 28, 34, 255), {roundness = 10, text="Manažment Vozidel", hoverBgColor = tocolor(35,35,44,250), clickBgColor = tocolor(60,60,60,250), textColor=tocolor(255, 255, 255, 255), textScale=1, textFont="default-bold", textAlignH="center", textAlignV="center"}),
		--b7 = GridLib.createDiv(42, 22, 47, 24, tocolor(28, 28, 34, 255), {roundness = 10, text="Knihovna vozidel", hoverBgColor = tocolor(35,35,44,250), clickBgColor = tocolor(60,60,60,250), textColor=tocolor(255, 255, 255, 255), textScale=1, textFont="default-bold", textAlignH="center", textAlignV="center"}),
		--b8 = GridLib.createDiv(48, 4, 53, 6, tocolor(28, 28, 34, 255), {roundness = 10, text="MOTD Manažment", hoverBgColor = tocolor(35,35,44,250), clickBgColor = tocolor(60,60,60,250), textColor=tocolor(255, 255, 255, 255), textScale=1, textFont="default-bold", textAlignH="center", textAlignV="center"}),
		
		logout = GridLib.createDiv(42, 25, 47, 27, tocolor(28, 28, 34, 255), {roundness = 10, text="Odhlásit", hoverBgColor = tocolor(35,35,44,250), clickBgColor = tocolor(60,60,60,250), hoverBgColor = tocolor(35,35,44,250), clickBgColor = tocolor(60,60,60,250), textColor=tocolor(255, 255, 255, 255), textScale=1, textFont="default-bold", textAlignH="center", textAlignV="center"}),
    }
}

buttons = {
    reports_back_button = GridLib.createDiv(42, 4, 47, 6, tocolor(0, 255, 0, 250))
}

temp = {}

profiledivs = {}

function removeFromRenderQueue(elem)
    for i, btn in ipairs(renderQueue) do
        if btn == elem then
            table.remove(renderQueue, i)
            break
        end
    end
end

function moveElementToFirst(tbl, elem)
    for i, value in ipairs(tbl) do
        if value == elem then
            table.remove(tbl, i)
            table.insert(tbl, 1, elem)
            break
        end
    end
end

function moveElementToLast(tbl, elem)
    for i, value in ipairs(tbl) do
        if value == elem then
            table.remove(tbl, i)
            table.insert(tbl, elem)  -- Inserts elem at the end of the table
            break
        end
    end
end

function getOverLayFonts()
	return fontType
end

function setMenuButtonClickable()
    for category, group in pairs(animated_rects) do
        for name, rect in pairs(group) do
            rect.clickable = true
        end
    end
end

function setMenuButtonNotClickable()
    for category, group in pairs(animated_rects) do
        for name, rect in pairs(group) do
            rect.clickable = false
        end
    end
end

menuShowing = false

animated_rects.top.garaz.onClick = function(self)
    -- Animate "garaz" to fullscreen
    moveElementToLast(renderQueue, self)
    self.bgImage = nil
	self.text = nil
    self:startAnimation(0, 0, GridLib.config.gridCountX - 1, GridLib.config.gridCountY - 1, 200)
    setMenuButtonNotClickable()
    setTimer(function()

		temp.garage.car1 = GridLib.createDiv(5, 0, 14, 29, tocolor(25, 25, 30, 255))
		temp.garage.car2 = GridLib.createDiv(15, 1, 24, 29, tocolor(25, 25, 30, 255))
		temp.garage.car3 = GridLib.createDiv(25, 1, 34, 29, tocolor(25, 25, 30, 255))
		temp.garage.car4 = GridLib.createDiv(35, 1, 44, 29, tocolor(25, 25, 30, 255))
		temp.garage.car5 = GridLib.createDiv(45, 1, 54, 29, tocolor(25, 25, 30, 255))

        buttons.garaz_back_button = GridLib.createDiv(58, 1, 58, 1, tocolor(28, 28, 34, 255), {bgImage = "f10_images/close.png"})
        buttons.garaz_back_button.onClick = function(self)
            -- Animate "garaz" back to its original dimensions (18,4) to (29,15)
            animated_rects.top.garaz:startAnimation(18, 4, 29, 15, 200)
            self.clickable = false
            removeFromRenderQueue(self)
            setTimer(function()
                animated_rects.top.garaz.bgImage = "f10_images/garage.png"
				animated_rects.top.garaz.text = " Garáž\n\n  Vozidla : "..numcars.."/"..getElementData(localPlayer, "maxvehicles")
                setMenuButtonClickable()
                buildRenderQueue()
            end, 200, 1)
        end
        
		table.insert(renderQueue, temp.garage.car1)
		table.insert(renderQueue, temp.garage.car2)
		table.insert(renderQueue, temp.garage.car3)
		table.insert(renderQueue, temp.garage.car4)
		table.insert(renderQueue, temp.garage.car5)
        table.insert(renderQueue, buttons.garaz_back_button)
    end, 200, 1)
end

animated_rects.top.nehnutelnosti.onClick = function(self)
    moveElementToLast(renderQueue, self)
	self.bgImage = nil
	self.text = nil
    self:startAnimation(0, 0, GridLib.config.gridCountX - 1, GridLib.config.gridCountY - 1, 200)
    setMenuButtonNotClickable()
    setTimer(function()

        buttons.garaz_back_button = GridLib.createDiv(58, 1, 58, 1, tocolor(28, 28, 34, 255), {bgImage = "f10_images/close.png"})
        buttons.garaz_back_button.onClick = function(self)
            -- Animate "garaz" back to its original dimensions (18,4) to (29,15)
            animated_rects.top.nehnutelnosti:startAnimation(30, 4, 41, 15, 200)
            self.clickable = false
            removeFromRenderQueue(self)
            setTimer(function()
				animated_rects.top.nehnutelnosti.bgImage = "f10_images/nehnutelnosti.png"
				animated_rects.top.nehnutelnosti.text = " Nemovitosti"
                setMenuButtonClickable()
                buildRenderQueue()
            end, 200, 1)
        end
        
        -- Optionally, update the renderQueue to render this new button along with others
        table.insert(renderQueue, buttons.garaz_back_button)
    end, 200, 1)
end

animated_rects.top.profil.onClick = function(self)
    moveElementToLast(renderQueue, self)
	self.bgImage = nil
	self.text = nil
    self:startAnimation(0, 0, GridLib.config.gridCountX - 1, GridLib.config.gridCountY - 1, 200)
    setMenuButtonNotClickable()
    setTimer(function()

		--Licencie
		local carlicense = getElementData(localPlayer, "license.car")
		local bikelicense = getElementData(localPlayer, "license.bike")
		local boatlicense = getElementData(localPlayer, "license.boat")
		--local pilotlicense = getElementData(localPlayer, "license.pilot")
		local fishlicense = getElementData(localPlayer, "license.fish")
		local gunlicense = getElementData(localPlayer, "license.gun")
		local gun2license = getElementData(localPlayer, "license.gun2")

		if (carlicense == 1) then
			carlicense = "ANO"
		elseif (carlicense == 3) then
			carlicense = "Teoretický test složen"
		else
			carlicense = "NE"
		end
		if (bikelicense == 1) then
			bikelicense = "ANO"
		elseif (bikelicense == 3) then
			bikelicense = "Teoretický test složen"
		else
			bikelicense = "NE"
		end
		if (boatlicense == 1) then
			boatlicense = "ANO"
		else
			boatlicense = "NE"
		end

		if (fishlicense == 1) then
			fishlicense = "ANO"
		else
			fishlicense = "NE"
		end
		if (gunlicense == 1) then
			gunlicense = "ANO"
		else
			gunlicense = "NE"
		end
		if (gun2license == 1) then
			gun2license = "ANO"
		else
			gun2license = "NE"
		end

		local job = getElementData(localPlayer, "job") or 0
		if job == 0 then
			job = "Bez práce"
		else
			local jobName = exports["job-system"]:getJobTitleFromID(job)
			job = jobName
		end

		local carried = " Přenášená hmotnost: "..("%.2f/%.2f" ):format( exports["item-system"]:getCarriedWeight( localPlayer ), exports["item-system"]:getMaxWeight( localPlayer ) ).." kg(s)"

		local currentGC = getElementData(localPlayer, "credits") or 0
		local bankmoney = getElementData(localPlayer, "bankmoney") or 0
		local money = getElementData(localPlayer, "money") or 0

		local dob = exports.global:getPlayerDoB(localPlayer)
		local hoursplayed = getElementData(localPlayer, "hoursplayed")
		local age = getElementData(localPlayer, "age")
		local weight = getElementData(localPlayer, "weight")
		local height = getElementData(localPlayer, "height")
		local race = getElementData(localPlayer, "race")

		local username = getPlayerName(localPlayer):gsub("_", " ")

		local accountname = getElementData(localPlayer, "account:username")


		profiledivs.charbg = GridLib.createDiv(9, 1, 24, 28, tocolor(25, 25, 30, 255), {roundness = 10})
		profiledivs.charlabel = GridLib.createDiv(9, 1, 24, 8, tocolor(28, 28, 34, 0), {roundness = 10, text="Postava" , textColor=tocolor(255, 255, 255, 255), textScale=1.5, textFont="default-bold", textAlignH="center", textAlignV="top"})
		profiledivs.char = GridLib.createDiv(9, 3, 24, 8, tocolor(28, 28, 34, 0), {roundness = 10, text="  Postava: "..username.. "  \n\n  Věk: " ..age.. " let \n\n  Datum narozeni: " ..dob.. "\n\n  Odohrano hodin: " ..hoursplayed.. "\n\n  Hmotnost: " ..weight.. " kg\n\n  Výška: " ..height.. "m \n\n  Rasa: " ..race.. "", textColor=tocolor(255, 255, 255, 255), textScale=1.2, textFont="default-bold", textAlignH="left", textAlignV="top"})

		profiledivs.careerbg = GridLib.createDiv(25, 1, 41, 28, tocolor(25, 25, 30, 255), {roundness = 10})
		profiledivs.careerlabel = GridLib.createDiv(25, 1, 41, 13, tocolor(28, 28, 34, 0), {roundness = 10, text="Statistiky", textColor=tocolor(255, 255, 255, 255), textScale=1.5, textFont="default-bold", textAlignH="center", textAlignV="top"})
		profiledivs.career = GridLib.createDiv(25, 3, 41, 8, tocolor(28, 28, 34, 0), {roundness = 10, text="  Penize: " ..money.. "$\n\n  Penize v bance: " ..bankmoney.. "$\n\n  "..job, textColor=tocolor(255, 255, 255, 255), textScale=1.2, textFont="default-bold", textAlignH="left", textAlignV="top"})

		profiledivs.licencebg = GridLib.createDiv(42,1, 57,28, tocolor(25, 25, 30, 255), {roundness = 10})
		profiledivs.licencelabel = GridLib.createDiv(42,1, 57,13, tocolor(28, 28, 34, 0), {roundness = 10, text="  Licence a prúkazy", textColor=tocolor(255, 255, 255, 255), textScale=1.5, textFont="default-bold", textAlignH="center", textAlignV="top"})
		profiledivs.license = GridLib.createDiv(42,3, 57,13, tocolor(28, 28, 34, 0), {roundness = 10, text="  Řidičský průkaz (A): "..bikelicense.."\n\n  Řidičský průkaz (B): "..carlicense.."\n\n  Lodní průkaz: "..boatlicense.."\n\n  Rybářský průkaz: "..fishlicense.."\n\n  Zbrojní průkaz: "..gunlicense.."", textColor=tocolor(255, 255, 255, 255), textScale=1.2, textFont="default-bold", textAlignH="left", textAlignV="top"})
		
		
		profiledivs.user = GridLib.createDiv(1,1, 8,8, tocolor(28, 28, 34, 255), {bgImage = "f10_images/user.png"})
		
		profiledivs.accountnamelabel = GridLib.createDiv(1,9,8,10, tocolor(28, 28, 34, 0), { text = ""..accountname, textColor=tocolor(255, 255, 255, 255), textScale=1, textFont="default-bold", textAlignH="center", textAlignV="center"})
		profiledivs.currentGClabel = GridLib.createDiv(1,10,8,11, tocolor(28, 28, 34, 0), { text = "OrbitPoints: "..currentGC, textColor=tocolor(255, 255, 255, 255), textScale=1, textFont="default-bold", textAlignH="center", textAlignV="center"})

        buttons.garaz_back_button = GridLib.createDiv(58, 1, 58, 1, tocolor(28, 28, 34, 255), {bgImage = "f10_images/close.png"})
        buttons.garaz_back_button.onClick = function(self)
            -- Animate "garaz" back to its original dimensions (18,4) to (29,15)
            animated_rects.top.profil:startAnimation(7, 4, 17, 9, 200)
            self.clickable = false
            removeFromRenderQueue(self)
			for i, v in pairs(profiledivs) do
				removeFromRenderQueue(v)
			end
	
            setTimer(function()
				animated_rects.top.profil.bgImage = "f10_images/account.png"
				animated_rects.top.profil.text = " Profil"
                setMenuButtonClickable()
                buildRenderQueue()
            end, 200, 1)
        end
        
        -- Optionally, update the renderQueue to render this new button along with others
        table.insert(renderQueue, buttons.garaz_back_button)
		table.insert(renderQueue, profiledivs.user)
		--licences
		table.insert(renderQueue, profiledivs.licencebg)
		table.insert(renderQueue, profiledivs.licencelabel)
		table.insert(renderQueue, profiledivs.license)
		--career
		table.insert(renderQueue, profiledivs.careerbg)
		table.insert(renderQueue, profiledivs.careerlabel)
		table.insert(renderQueue, profiledivs.career)
		--char
		table.insert(renderQueue, profiledivs.charbg)
		table.insert(renderQueue, profiledivs.charlabel)
		table.insert(renderQueue, profiledivs.char)

		table.insert(renderQueue, profiledivs.accountnamelabel)
		table.insert(renderQueue, profiledivs.currentGClabel)

    end, 200, 1)
end

animated_rects.bottom.reports.onClick = function(self)
	moveElementToLast(renderQueue, self)
	self.bgImage = nil
	self.text = nil
    self:startAnimation(0, 0, GridLib.config.gridCountX - 1, GridLib.config.gridCountY - 1, 200)
    setMenuButtonNotClickable()
    setTimer(function()
        self.clickable = false

        buttons.reports_back_button = GridLib.createDiv(58, 1, 58, 1, tocolor(28, 28, 34, 255), {bgImage = "f10_images/close.png"})
        buttons.reports_back_button.onClick = function(self)
            animated_rects.bottom.reports:startAnimation(30, 16, 41, 21, 200)
            self.clickable = false
            removeFromRenderQueue(self)
            setTimer(function()
                animated_rects.bottom.reports.clickable = true
				animated_rects.bottom.reports.bgImage = "f10_images/report.png"
				animated_rects.bottom.reports.text =  "Reporty\n\n  Staff online: "..onlineStaff.. "\n  Ve službě: "..onDutyStaff..""
                setMenuButtonClickable()
                
                buildRenderQueue()
            end, 200, 1)
        end

        --renderQueue = { self, buttons.reports_back_button}
        table.insert(renderQueue, buttons.reports_back_button)
    end, 200, 1)
end

--Nastavenia
animated_rects.left.nastavenia.onClick = function(self)
    if not isPedDead ( localPlayer ) and isCameraOnPlayer() then
		--triggerServerEvent("accounts:settings:fetchSettings", localPlayer)
		if not isPedDead(localPlayer) and isCameraOnPlayer() then
			showSettingsWindow()
			options_closemenu()
		end
	end
end

animated_rects.left.shop.onClick = function(self)
	if not isPedDead ( localPlayer ) and isCameraOnPlayer() then
		triggerServerEvent("donation-system:GUI:open", localPlayer)
		options_closemenu()
	end
end

--Change Character
animated_rects.right.b1.onClick = function(self)
	if not isPedDead ( localPlayer ) and isCameraOnPlayer() then
		options_logOut( )
	end
	options_closemenu()
end

--Radio Station Manager
animated_rects.right.b2.onClick = function(self)
	if not isPedDead ( localPlayer ) and isCameraOnPlayer() then
		executeCommandHandler("radios")
	end
	options_closemenu()
end

--Logout
animated_rects.right.logout.onClick = function(self)
	if not isPedDead ( localPlayer ) and isCameraOnPlayer() then
		fadeCamera ( false, 2, 0,0,0 )
		setTimer(function()
			triggerServerEvent("accounts:settings:reconnectPlayer", localPlayer)
		end, 2000,1)
	end
	options_closemenu()
end

function startAllAnimations()
    for category, rects in pairs(animated_rects) do
        for name, rect in pairs(rects) do
            local direction = "top"
            if category == "bottom" then
                direction = "bottom"
            elseif category == "left" then
                direction = "left"
            elseif category == "right" then
                direction = "right"
            end
            rect:startFlyInAnimation(direction, 300)
        end
    end
end


fonts = getOverLayFonts()


function setStaffStats(online, onduty)	
	onlineStaff = online
	onDutyStaff = onduty
	animated_rects.bottom.reports.text = " Reporty\n\n  Staff online: "..onlineStaff.."\n  Ve službě: "..onDutyStaff
end
addEvent("accounts:settings:f10staffStats", true)
addEventHandler("accounts:settings:f10staffStats", getRootElement(), setStaffStats)


function options_enable()

	--keys = getBoundKeys("change_camera")

	addCommandHandler("home", options_showmenu)
	bindKey("F10", "down", "home")
end
addEventHandler("accounts:options",getRootElement(),options_enable)

function options_disable()
	removeCommandHandler("home", options_showmenu)
	unbindKey("home", "down", "home")
	unbindKey("F10", "down", "home")
end

wOptions,bChangeCharacter,bStreamerSettings,bGraphicsSettings,bAccountSettings,bLogout = nil
wGraphicsMenu,cLogsEnabled,cMotionBlur,cSkyClouds,cStreamingAudio,bGraphicsMenuClose,sVehicleStreamer,sPickupStreamer,lVehicleStreamer,lPickupStreamer,gameMenuLoaded = nil

function isCameraOnPlayer()
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if vehicle then
		return getCameraTarget( ) == vehicle
	else
		return getCameraTarget( ) == localPlayer
	end
end

function options_showmenu()
	if menuShowing then
		options_closemenu()
		return
	end

	if getElementData(localPlayer, "exclusiveGUI") or not isCameraOnPlayer() then
		return
	end
	triggerEvent( 'hud:blur', resourceRoot, 6, false, 0.5, nil )
	setElementData(localPlayer, "exclusiveGUI", true, false)
	triggerEvent("account:changingchar", localPlayer)
	local screenWidth, screenHeight = guiGetScreenSize()
	local windowWidth, windowHeight = 250, 15
	local bHeight = 35
	windowHeight = windowHeight+(bHeight*5)
	local left = screenWidth/2 - windowWidth/2
	local top = screenHeight/2 - windowHeight/2
	local margin = 10
	local wHeight = margin
	showCursor(true)

	menuShowing = true
	outputConsole(tostring(menuShowing))
	

	--VEHICLES
	local carids = ""
	local numcars = 0
	local dbid = tonumber(getElementData(localPlayer, "dbid"))
	for key, value in ipairs(exports.pool:getPoolElementsByType("vehicle")) do
		local owner = tonumber(getElementData(value, "owner"))

		if (owner) and (owner==dbid) then
			local id = getElementData(value, "dbid")
			carids = carids .. id .. ", "
			numcars = numcars + 1
			exports.anticheat:changeProtectedElementDataEx(value, "owner_last_login", exports.datetime:now(), true)
		end
	end
	--printCar = numcars .. "/" .. getElementData(localPlayer, "maxvehicles")
	animated_rects.top.garaz.text = " Garáž\n\n  Vozidla : "..numcars.."/"..getElementData(localPlayer, "maxvehicles")
	--outputConsole(printCar)

	-- PROPERTIES
	local properties = ""
	local numproperties = 0
	for key, value in ipairs(getElementsByType("interior")) do
		local stt = getElementData(value, "status")
		if stt.owner and stt.owner == dbid and getElementData(value, "name") then
			local id = getElementData(value, "dbid")
			properties = properties .. id .. ", "
			numproperties = numproperties + 1
			--Update owner last login / MAXIME 2015.01.07
			exports.anticheat:changeProtectedElementDataEx(value, "owner_last_login", exports.datetime:now(), true)
		end
	end
	animated_rects.top.nehnutelnosti.text = " Nemovitosti\n\n  Nemovitosti : "..numproperties

	if getResourceFromName("admin-system") and exports['admin-system']:canPlayerAccessStaffManager(localPlayer) then
		animated_rects.right.b3 = GridLib.createDiv(42, 10, 47, 12, tocolor(28, 28, 34, 255), {roundness = 10, text="Manažment Staffu", hoverBgColor = tocolor(35,35,44,250), clickBgColor = tocolor(60,60,60,250), textColor=tocolor(255, 255, 255, 255), textScale=1, textFont="default-bold", textAlignH="center", textAlignV="center"})
		animated_rects.right.b3.onClick = function(self)
			if not isPedDead ( localPlayer ) and isCameraOnPlayer() then
				executeCommandHandler("staffs")
			end
			options_closemenu()
		end
	end

	if getResourceFromName("factions") and exports.factions:canAccessFactionManager( localPlayer ) then
		animated_rects.right.b4 = GridLib.createDiv(42, 13, 47, 15, tocolor(28, 28, 34, 255), {roundness = 10, text="Manažment Frakci", hoverBgColor = tocolor(35,35,44,250), clickBgColor = tocolor(60,60,60,250), textColor=tocolor(255, 255, 255, 255), textScale=1, textFont="default-bold", textAlignH="center", textAlignV="center"})
		animated_rects.right.b4.onClick = function(self)
			if not isPedDead ( localPlayer ) and isCameraOnPlayer() then
				executeCommandHandler("factions")
				showCursor(true)
			end
			options_closemenu()
		end
	end

	if getResourceFromName("interior_system") and getResourceFromName("interior-manager") and exports.integration:isPlayerAdmin( localPlayer ) then
		animated_rects.right.b5 = GridLib.createDiv(42, 16, 47, 18, tocolor(28, 28, 34, 255), {roundness = 10, text="Manažment Interieru", hoverBgColor = tocolor(35,35,44,250), clickBgColor = tocolor(60,60,60,250), textColor=tocolor(255, 255, 255, 255), textScale=1, textFont="default-bold", textAlignH="center", textAlignV="center"})
		animated_rects.right.b5.onClick = function(self)
			if not isPedDead ( localPlayer ) and isCameraOnPlayer() then
				triggerServerEvent("interiorManager:openit", localPlayer, localPlayer)
			end
			options_closemenu()
		end
	end

	if getResourceFromName("vehicle") and getResourceFromName("vehicle_manager") and exports.vehicle_manager:canAccessVehicleManager( localPlayer ) then
		animated_rects.right.b6 = GridLib.createDiv(42, 19, 47, 21, tocolor(28, 28, 34, 255), {roundness = 10, text="Manažment Vozidel", hoverBgColor = tocolor(35,35,44,250), clickBgColor = tocolor(60,60,60,250), textColor=tocolor(255, 255, 255, 255), textScale=1, textFont="default-bold", textAlignH="center", textAlignV="center"})
		animated_rects.right.b6.onClick = function(self)
			if not isPedDead ( localPlayer ) and isCameraOnPlayer() then
				executeCommandHandler("vehs")
			end
			options_closemenu()
		end
	end

	if getResourceFromName('vehicle') and getResourceFromName("vehicle_manager") then
		local thePlayer = localPlayer
		if exports.integration:isPlayerVCTMember(thePlayer) or exports.integration:isPlayerSupporter(thePlayer) or exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerScripter(thePlayer) or exports.integration:isPlayerVehicleConsultant(thePlayer) then
			animated_rects.right.b7 = GridLib.createDiv(42, 22, 47, 24, tocolor(28, 28, 34, 255), {roundness = 10, text="Knihovna vozidel", hoverBgColor = tocolor(35,35,44,250), clickBgColor = tocolor(60,60,60,250), textColor=tocolor(255, 255, 255, 255), textScale=1, textFont="default-bold", textAlignH="center", textAlignV="center"})
			animated_rects.right.b7.onClick = function(self)
				if not isPedDead ( localPlayer ) and isCameraOnPlayer() then
					triggerServerEvent("vehlib:sendLibraryToClient", localPlayer, localPlayer)
				end
				options_closemenu()
			end
		end
	end

	if getResourceFromName("announcement") and exports.announcement:canPlayerAccessMotdManager(localPlayer) then
		animated_rects.right.b8 = GridLib.createDiv(48, 4, 53, 6, tocolor(28, 28, 34, 255), {roundness = 10, text="MOTD Manažment", hoverBgColor = tocolor(35,35,44,250), clickBgColor = tocolor(60,60,60,250), textColor=tocolor(255, 255, 255, 255), textScale=1, textFont="default-bold", textAlignH="center", textAlignV="center"})
		animated_rects.right.b8.onClick = function(self)
			if not isPedDead ( localPlayer ) and isCameraOnPlayer() then
				executeCommandHandler("motd")
			end
			options_closemenu()
		end
	end
	
	--[[if getResourceFromName("map_manager") then
		bHelp = guiCreateButton(margin, wHeight, 230, 30, "Map Manager", false, wOptions)
		addEventHandler("onClientGUIClick", bHelp,
			function ()
				if not isPedDead ( localPlayer ) and isCameraOnPlayer() then
					executeCommandHandler("maps")
				end
				options_closemenu()
			end, false)
		wHeight = wHeight + bHeight
	end]]

	setMenuButtonClickable()
	buildRenderQueue()
    startAllAnimations()

end

function options_closemenu()
	--options_closegraphicsmenu()
	--closeSettingsWindow()
	setMenuButtonNotClickable()

	showCursor(false)
	menuShowing = false
	if wOptions then
		destroyElement(wOptions)
		wOptions = nil
	end
	setElementData(localPlayer, "exclusiveGUI", false, false)
	triggerEvent( 'hud:blur', resourceRoot, 'off' )
end

function options_cameraWorkAround()
	setPedControlState(localPlayer, "change_camera", true)
end


--MAXIME
function options_opengraphicsmenu()
	gameMenuLoaded = false
	local screenWidth, screenHeight = guiGetScreenSize()
	local windowWidth, windowHeight = 200, 350+17
	local left = screenWidth/2 - windowWidth/2
	local top = screenHeight/2 - windowHeight/2
	local enable = 1

	guiSetEnabled(wOptions, false)

	wGraphicsMenu = guiCreateWindow(left, top, windowWidth, windowHeight, "Game options", false)
	guiWindowSetSizable(wGraphicsMenu, false)
	----------

	cMotionBlur = guiCreateCheckBox(10, 25, 180, 17, "Enable motion blur", false, false, wGraphicsMenu)
	addEventHandler("onClientGUIClick", cMotionBlur, options_updateGameConfig)
	-----------
	cSkyClouds = guiCreateCheckBox(10, 45, 180, 17, "Enable Sky clouds", false, false, wGraphicsMenu)
	addEventHandler("onClientGUIClick", cSkyClouds, options_updateGameConfig)
	------------
	cStreamingAudio = guiCreateCheckBox(10, 65, 180, 17, "Enable streaming audio", false, false, wGraphicsMenu)
	addEventHandler("onClientGUIClick", cStreamingAudio, options_updateGameConfig)

	bOverlayDescription = guiCreateButton ( 10, 85, 180, 17*2, "Overlay Description Settings", false, wGraphicsMenu )
	addEventHandler("onClientGUIClick", bOverlayDescription, overlayDescSettings)

	--[[lVehicleStreamer = guiCreateCheckBox ( 10, 95, 180, 17, "Vehicle streamer: Disabled", false, false, wGraphicsMenu )
	addEventHandler("onClientGUIClick", lVehicleStreamer, options_updateGameConfig)

	sVehicleStreamer = guiCreateScrollBar(10, 110, 180, 17, true, false, wGraphicsMenu)
	addEventHandler("onClientGUIScroll", sVehicleStreamer, options_GameConfig_updateScrollbars)

	lPickupStreamer = guiCreateCheckBox ( 10, 125, 180, 17, "Interior streamer: Disabled", false, false, wGraphicsMenu )
	addEventHandler("onClientGUIClick", lPickupStreamer, options_updateGameConfig)

	sPickupStreamer = guiCreateScrollBar(10, 140, 180, 17, true, false, wGraphicsMenu)
	addEventHandler("onClientGUIScroll", sPickupStreamer, options_GameConfig_updateScrollbars)]]

	cLogsEnabled = guiCreateCheckBox(10, 160, 180, 17, "Logging of chat", false, false, wGraphicsMenu)
	addEventHandler("onClientGUIClick", cLogsEnabled, options_updateGameConfig)

	cBubblesEnabled = guiCreateCheckBox(10, 180, 180, 17, "Enable Chat bubbles", false, false, wGraphicsMenu)
	addEventHandler("onClientGUIClick", cBubblesEnabled, options_updateGameConfig)

	cIconsEnabled = guiCreateCheckBox(10, 200, 180, 17, "Enable typing icons", false, false, wGraphicsMenu)
	addEventHandler("onClientGUIClick", cIconsEnabled, options_updateGameConfig)

	cEnableNametags = guiCreateCheckBox(10, 220, 180, 17, "Enable nametags", false, false, wGraphicsMenu)
	addEventHandler("onClientGUIClick", cEnableNametags, options_updateGameConfig)

	cEnableRShaders = guiCreateCheckBox(10, 240, 180, 17, "Enable radar shader", false, false, wGraphicsMenu)
	addEventHandler("onClientGUIClick", cEnableRShaders, options_updateGameConfig)

	cEnableWShaders = guiCreateCheckBox(10, 260, 180, 17, "Enable water shader", false, false, wGraphicsMenu)
	addEventHandler("onClientGUIClick", cEnableWShaders, options_updateGameConfig)

	cEnableVShaders = guiCreateCheckBox(10, 280, 180, 17, "Enable vehicle shader", false, false, wGraphicsMenu)
	addEventHandler("onClientGUIClick", cEnableVShaders, options_updateGameConfig)

	--[[
	chatbubbles
	]]

	-- Put the current settings selected/active

	--[[local vehicleStreamerEnabled = tonumber( loadSavedData("streamer-vehicle-enabled", "1") )
	if (vehicleStreamerEnabled) then
		guiCheckBoxSetSelected ( lVehicleStreamer, true )
	end

	local pickupStreamerEnabled = tonumber( loadSavedData("streamer-pickup-enabled", "1") )
	if (pickupStreamerEnabled) then
		guiCheckBoxSetSelected ( lPickupStreamer, true )
	end]]

	local blurEnabled = tonumber( loadSavedData("motionblur", "1") )
	if (blurEnabled == 1) then
		guiCheckBoxSetSelected ( cMotionBlur, true )
	end


	local skyCloudsEnabled = tonumber( loadSavedData("skyclouds", "1") )
	if (skyCloudsEnabled == 1) then
		guiCheckBoxSetSelected ( cSkyClouds, true )
	end

	local streamingMediaEnabled = tonumber( loadSavedData("streamingmedia", "1") )
	if (streamingMediaEnabled == 1) then
		guiCheckBoxSetSelected ( cStreamingAudio, true )
	end

	local logsEnabled = tonumber( loadSavedData("logsenabled", "1") )
	if (logsEnabled == 1) then
		guiCheckBoxSetSelected ( cLogsEnabled, true )
	end


	local isBubblesEnabled = tonumber( loadSavedData("chatbubbles", "1") )
	if (isBubblesEnabled == 1) then
		guiCheckBoxSetSelected ( cBubblesEnabled, true )
	end

	local isChatIconsEnabled = tonumber( loadSavedData("chaticons", "1") )
	if (isChatIconsEnabled == 1) then
		guiCheckBoxSetSelected ( cIconsEnabled, true )
	end

	local isNameTagsEnabled = tonumber( loadSavedData("shownametags", "1") )
	if (isNameTagsEnabled == 1) then
		guiCheckBoxSetSelected ( cEnableNametags, true )
	end

	local isRShaderEnabled = tonumber( loadSavedData( "enable_radar_shader", "1") )
	if isRShaderEnabled == 1 then
		guiCheckBoxSetSelected ( cEnableRShaders, true )
	end

	local isWShaderEnabled = tonumber( loadSavedData( "enable_water_shader", "1") )
	if isWShaderEnabled == 1 then
		guiCheckBoxSetSelected ( cEnableWShaders, true )
	end

	local isVShaderEnabled = tonumber( loadSavedData( "enable_vehicle_shader", "1") )
	if isVShaderEnabled == 1 then
		guiCheckBoxSetSelected ( cEnableVShaders, true )
	end

	gameMenuLoaded = true
	--options_GameConfig_updateScrollbars()

	bGraphicsMenuClose = guiCreateButton(10, 320, 490, 17*2, "Close", false, wGraphicsMenu)
	addEventHandler("onClientGUIClick", bGraphicsMenuClose, options_closegraphicsmenu, false)
end

function overlayDescSettings(button, state)
	if source == bOverlayDescription then
		if wOverlayDescSettings then
			fCloseOverlayDescSettings()
		else

			local screenWidth, screenHeight = guiGetScreenSize()
			local windowWidth, windowHeight = 350, 40+(20*15)
			local left = screenWidth/2 - windowWidth/2
			local top = screenHeight/2 - windowHeight/2
			local enable = 1

			guiSetEnabled(wOptions, false)
			guiSetEnabled(wGraphicsMenu, false)

			wOverlayDescSettings = guiCreateWindow(left, top, windowWidth, windowHeight, "Overlay Description Options", false)
			guiWindowSetSizable(wOverlayDescSettings, false)
			----------
			local y = 0
			local lane1w = 230
			local lane1x = 10
			local lane2w = lane1w + lane1x
			local lane2x = lane1x*2 + lane1w
			cEnableDescription = guiCreateCheckBox(10, 25+y, lane1w, 17, "Enable All Overlay Description", true, false, wOverlayDescSettings)
			addEventHandler("onClientGUIClick", cEnableDescription, options_updateGameConfig)
			enable = tonumber( loadSavedData("enableOverlayDescription", "1") or 1)
			guiCheckBoxSetSelected ( cEnableDescription, enable == 1 and true or false)
			guiCreateStaticImage ( 10, 25+y+23, windowWidth-20 , 1, ":admin-system/images/whitedot.jpg", false, wOverlayDescSettings )
			y = y + 30

			cEnableDescriptionVeh = guiCreateCheckBox(10, 25+y, lane1w, 17, "Enable Overlay Description (Vehicle)", true, false, wOverlayDescSettings)
			addEventHandler("onClientGUIClick", cEnableDescriptionVeh, options_updateGameConfig)
			enable = tonumber( loadSavedData("enableOverlayDescriptionVeh", "1") or 1 )
			guiCheckBoxSetSelected ( cEnableDescriptionVeh, enable == 1 and true or false)

			cEnableDescriptionVehPin = guiCreateCheckBox(lane2x, 25+y, lane2w, 17, "Pin", false, false, wOverlayDescSettings)
			addEventHandler("onClientGUIClick", cEnableDescriptionVehPin, options_updateGameConfig)
			enable = tonumber( loadSavedData("enableOverlayDescriptionVehPin", "1") or 1 )
			guiCheckBoxSetSelected ( cEnableDescriptionVehPin, enable == 1 and true or false)

			y = y + 20

			lFontVeh = guiCreateLabel ( 10, 25+y+3, 40, 20,  "Font:", false, wOverlayDescSettings )
			cFontVeh = guiCreateComboBox ( 10+40, 25+y, lane1w, 20,  loadSavedData2("cFontVeh") or "default", false, wOverlayDescSettings )
			local count1 = 0
			for key, font in pairs(fonts) do
				guiComboBoxAddItem(cFontVeh, type(font[1]) == "string" and font[1] or "BizNoteFont18")
				count1 = count1 + 1
			end
			guiComboBoxAdjustHeight ( cFontVeh, count1 )
			addEventHandler ( "onClientGUIComboBoxAccepted", guiRoot,
				function ( comboBox )
					if ( comboBox == cFontVeh ) then
						local item = guiComboBoxGetSelected ( cFontVeh )
						local text = tostring ( guiComboBoxGetItemText ( cFontVeh , item ) )
						if ( text ~= "" ) then
							 appendSavedData("cFontVeh", text)
						end
					end
				end
			)

			y = y + 20 + 5

			bgVeh = guiCreateCheckBox ( 10, 25+y+3, 150, 17,  "Enable Background", true, false, wOverlayDescSettings )
			enable = tonumber( loadSavedData("bgVeh", "1") or 1 )
			guiCheckBoxSetSelected ( bgVeh, enable == 1 and true or false)

			borderVeh = guiCreateCheckBox ( 10+150, 25+y+3, 150, 17, "Enable Border", true, false, wOverlayDescSettings )
			enable = tonumber( loadSavedData("borderVeh", "1") or 1)
			guiCheckBoxSetSelected ( borderVeh, enable == 1 and true or false)

			addEventHandler("onClientGUIClick", bgVeh, options_updateGameConfig)
			addEventHandler("onClientGUIClick", borderVeh, options_updateGameConfig)

			guiCreateStaticImage ( 10, 25+y+21, windowWidth-20 , 1, ":admin-system/images/whitedot.jpg", false, wOverlayDescSettings )

			y = y + 40

			cEnableOverlayDescriptionPro = guiCreateCheckBox(10, 25+y, lane1w, 17, "Enable Overlay Description (Property)", true, false, wOverlayDescSettings)
			addEventHandler("onClientGUIClick", cEnableOverlayDescriptionPro, options_updateGameConfig)
			enable = tonumber( loadSavedData("enableOverlayDescriptionPro", "1") or 1 )
			guiCheckBoxSetSelected ( cEnableOverlayDescriptionPro, enable == 1 and true or false)

			cEnableOverlayDescriptionProPin = guiCreateCheckBox(lane2x, 25+y, lane2w, 17, "Pin", false, false, wOverlayDescSettings)
			addEventHandler("onClientGUIClick", cEnableOverlayDescriptionProPin, options_updateGameConfig)
			enable = tonumber( loadSavedData("enableOverlayDescriptionProPin", "1") or 1 )
			guiCheckBoxSetSelected ( cEnableOverlayDescriptionProPin, enable == 1 and true or false)

			y = y + 20

			lFontPro = guiCreateLabel ( 10, 25+y+3, 40, 20,  "Font:", false, wOverlayDescSettings )
			cFontPro = guiCreateComboBox ( 10+40, 25+y, lane1w, 20,  loadSavedData2("cFontPro") , false, wOverlayDescSettings )
			for key, font in pairs(fonts) do
				guiComboBoxAddItem(cFontPro, type(font[1]) == "string" and font[1] or "BizNoteFont18")
			end
			guiComboBoxAdjustHeight ( cFontPro, count1 )
			addEventHandler ( "onClientGUIComboBoxAccepted", guiRoot,
				function ( comboBox )
					if ( comboBox == cFontPro ) then
						local item = guiComboBoxGetSelected ( cFontPro )
						local text = tostring ( guiComboBoxGetItemText ( cFontPro , item ) )
						if ( text ~= "" ) then
							appendSavedData("cFontPro", text)
						end
					end
				end
			)

			y = y + 20 + 5

			bgPro = guiCreateCheckBox ( 10, 25+y+3, 150, 17,  "Enable Background", true, false, wOverlayDescSettings )
			enable = tonumber( loadSavedData("bgPro", "1") or 1 )
			guiCheckBoxSetSelected ( bgPro, enable == 1 and true or false)

			borderPro = guiCreateCheckBox ( 10+150, 25+y+3, 150, 17, "Enable Border", true,false,  wOverlayDescSettings )
			enable = tonumber( loadSavedData("borderPro", "1") or 1 )
			guiCheckBoxSetSelected ( borderPro, enable == 1 and true or false)

			addEventHandler("onClientGUIClick", bgPro, options_updateGameConfig)
			addEventHandler("onClientGUIClick", borderPro, options_updateGameConfig)

			guiCreateStaticImage ( 10, 25+y+21, windowWidth-20 , 1, ":admin-system/images/whitedot.jpg", false, wOverlayDescSettings )

			y = y + 40

			bCloseOverlayDescSettings = guiCreateButton(10, 70+y, windowWidth+34, 17*2, "Close", false, wOverlayDescSettings)
			addEventHandler("onClientGUIClick", bCloseOverlayDescSettings, fCloseOverlayDescSettings, false)
		end
	end
end

--MAXIME--
function options_updateGameConfig()
	if source == borderVeh then
		appendSavedData("borderVeh", guiCheckBoxGetSelected(borderVeh) and "1" or "0")
	end

	if source == bgVeh then
		appendSavedData("bgVeh", guiCheckBoxGetSelected(bgVeh) and "1" or "0")
	end

	if source == borderPro then
		appendSavedData("borderPro", guiCheckBoxGetSelected(borderPro) and "1" or "0")
	end

	if source == bgPro then
		appendSavedData("bgPro", guiCheckBoxGetSelected(bgPro) and "1" or "0")
	end

	if source == cEnableDescription then
		appendSavedData("enableOverlayDescription", guiCheckBoxGetSelected(cEnableDescription) and "1" or "0")
	end

	if source == cEnableDescriptionVeh then
		appendSavedData("enableOverlayDescriptionVeh", guiCheckBoxGetSelected(cEnableDescriptionVeh) and "1" or "0")
	end

	if source == cEnableDescriptionVehPin then
		appendSavedData("enableOverlayDescriptionVehPin", guiCheckBoxGetSelected(cEnableDescriptionVehPin) and "1" or "0")
	end

	if source == cEnableOverlayDescriptionPro then
		appendSavedData("enableOverlayDescriptionPro", guiCheckBoxGetSelected(cEnableOverlayDescriptionPro) and "1" or "0")
	end

	if source == cEnableOverlayDescriptionProPin then
		appendSavedData("enableOverlayDescriptionProPin", guiCheckBoxGetSelected(cEnableOverlayDescriptionProPin) and "1" or "0")
	end


	if source == cMotionBlur then
		if (guiCheckBoxGetSelected(cMotionBlur)) then
			appendSavedData("motionblur", "1")
		else
			appendSavedData("motionblur", "0")
		end
	end

	if source == cSkyClouds then
		if (guiCheckBoxGetSelected(cSkyClouds)) then
			appendSavedData("skyclouds", "1")
		else
			appendSavedData("skyclouds", "0")
		end
	end

	if source == cStreamingAudio then
		if (guiCheckBoxGetSelected(cStreamingAudio)) then
			appendSavedData("streamingmedia", "1")
		else
			appendSavedData("streamingmedia", "0")
		end
	end

	if source == cLogsEnabled then
		if (guiCheckBoxGetSelected(cLogsEnabled)) then
			appendSavedData("logsenabled", "1")
		else
			appendSavedData("logsenabled", "0")
		end
	end

	--[[if (guiCheckBoxGetSelected(lPickupStreamer)) then
		appendSavedData("streamer-pickup-enabled", "1")
	else
		appendSavedData("streamer-pickup-enabled", "0")
	end

	if (guiCheckBoxGetSelected(lVehicleStreamer)) then
		appendSavedData("streamer-vehicle-enabled", "1")
	else
		appendSavedData("streamer-vehicle-enabled", "0")
	end]]

	if source == cBubblesEnabled then
		if (guiCheckBoxGetSelected(cBubblesEnabled)) then
			appendSavedData("chatbubbles", "1")
		else
			appendSavedData("chatbubbles", "0")
		end
	end

	if source == cIconsEnabled then
		if (guiCheckBoxGetSelected(cIconsEnabled)) then
			appendSavedData("chaticons", "1")
		else
			appendSavedData("chaticons", "0")
		end
	end

	if source == cEnableNametags then
		if (guiCheckBoxGetSelected(cEnableNametags)) then
			appendSavedData("shownametags", "1")
		else
			appendSavedData("shownametags", "0")
		end
	end

	if source == cEnableRShaders then
		appendSavedData("enable_radar_shader", guiCheckBoxGetSelected(cEnableRShaders) and "1" or "0")
	end

	if source == cEnableWShaders then
		appendSavedData("enable_water_shader", guiCheckBoxGetSelected(cEnableWShaders) and "1" or "0")
	end

	if source == cEnableVShaders then
		appendSavedData("enable_vehicle_shader", guiCheckBoxGetSelected(cEnableVShaders) and "1" or "0")
	end

	triggerEvent("accounts:settings:loadGraphicSettings", localPlayer)
end

function guiComboBoxAdjustHeight ( combobox, itemcount )
	if getElementType ( combobox ) ~= "gui-combobox" or type ( itemcount ) ~= "number" then error ( "Invalid arguments @ 'guiComboBoxAdjustHeight'", 2 ) end
	local width = guiGetSize ( combobox, false )
	return guiSetSize ( combobox, width, ( itemcount * 20 ) + 20, false )
end

function fCloseOverlayDescSettings()
	if wOverlayDescSettings then
		destroyElement(wOverlayDescSettings)
		wOverlayDescSettings = nil
		if wGraphicsMenu then
			guiSetEnabled(wGraphicsMenu, true)
		end
	end
end

function options_closegraphicsmenu()
	if wGraphicsMenu then
		options_updateGameConfig()
		destroyElement(wGraphicsMenu)
		wGraphicsMenu = nil
	end
	fCloseOverlayDescSettings()
	if wOptions then
		guiSetEnabled(wOptions, true)
	end
end

function options_logOut( message )
	triggerServerEvent("updateCharacters", localPlayer)
	triggerServerEvent("accounts:characters:change", localPlayer, "Change Character")
	triggerEvent("onClientChangeChar", getRootElement())
	options_disable()
	Characters_showSelection()
	clearChat()
	if message then
		LoginScreen_showWarningMessage( message )
	end
end
addEventHandler("accounts:logout", getRootElement(), options_logOut)

function options_logOutToLoginPanel( message )
	triggerServerEvent("accounts:characters:logout", localPlayer, "Change Character")
	open_log_reg_pannel()
end

function buildRenderQueue()
    renderQueue = {}
    for category, group in pairs(animated_rects) do
        for name, rect in pairs(group) do
            table.insert(renderQueue, rect)
        end
    end
end

-- Render everything in the render queue
function renderQueueElements()
    for _, rect in ipairs(renderQueue) do
        GridLib.renderDiv(rect)
    end
end

setMenuButtonNotClickable()
function onClientRenderHandler()
    --GridLib.renderGrid()
    if menuShowing then
        GridLib.renderText("PANEL - RP", 7, 2, 14, 3, tocolor(255, 255, 255, 255), 2, "default-bold", "left", "center")
        renderQueueElements()
    end
end
addEventHandler("onClientRender", root, onClientRenderHandler)
