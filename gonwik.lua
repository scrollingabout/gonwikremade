require 'lib.moonloader'

local imgui      = require('imgui')
local vkeys      = require('vkeys')
local ffi        = require('ffi')
local q = require 'samp.events'
local memory = require 'memory'
local ffi = require 'ffi'
local inicfg = require 'inicfg'


-- производить загрузку кофигов можно и вне 'main'
local mainIni = inicfg.load({
    config =
    {
        time = 0, -- radius
        weather = 0, -- smooth
        antiservertime = false, -- enabled
        fixsun = false, -- visible check
        fixmoon = false, -- clistfilter
        enablesun = false, -- checkstuned
        disablepostprocess = false, -- checkpause
        disablemoon = false,
        resetremove = false, -- autoload
        fixswimfps = false, -- antistun


    }
}, 'setWeather&Time.ini')

if not doesFileExist('moonloader/config/setWeather&Time.ini') then inicfg.save(mainIni, 'setWeather&Time.ini') end
im_hotkey    = {(mainIni.config.activation)}

local getbonePosition = ffi.cast("int (__thiscall*)(void*, float*, int, bool)", 0x5E4280)

local stun_anims = {'DAM_armL_frmBK', 'DAM_armL_frmFT', 'DAM_armL_frmLT', 'DAM_armR_frmBK', 'DAM_armR_frmFT', 'DAM_armR_frmRT', 'DAM_LegL_frmBK', 'DAM_LegL_frmFT', 'DAM_LegL_frmLT', 'DAM_LegR_frmBK', 'DAM_LegR_frmFT', 'DAM_LegR_frmRT', 'DAM_stomach_frmBK', 'DAM_stomach_frmFT', 'DAM_stomach_frmLT', 'DAM_stomach_frmRT'}

local mainWindowState = imgui.ImBool(false)
local smooth = imgui.ImFloat(0.0)
local radius = imgui.ImFloat(0.6)
local enable = imgui.ImBool(false)
local clistFilter = imgui.ImBool(false)
local visibleCheck = imgui.ImBool(false)
local checkStuned = imgui.ImBool(false)
local loads = imgui.ImBool(false)
local saves = imgui.ImBool(false)
local checkPause = imgui.ImBool(false)
local onlyX = imgui.ImBool(false)
local control = imgui.ImBool(false)
local autoload = imgui.ImBool(false)
local antistun = imgui.ImBool(false)
local autofire = imgui.ImBool(false)
local extraws = imgui.ImBool(false)
local chance = imgui.ImFloat(0)
local encoding = require 'encoding'
local u8 = encoding.UTF8
local tab = 0
encoding.default = 'CP1251'

function main()
    repeat wait(0) until isSampAvailable()
    lua_thread.create(smooth_aimbot)
    if mainIni.config.resetremove then
        loadSettings()
    end
    while true do
        if extraws.v then
            memory.write(0x5109AC, 235, 1, true)
            memory.write(0x5109C5, 235, 1, true)
            memory.write(0x5231A6, 235, 1, true)
            memory.write(0x52322D, 235, 1, true)
            memory.write(0x5233BA, 235, 1, true)
        end
        if not extraws.v then
            memory.write(0x5109AC, 122, 1, true)
            memory.write(0x5109C5, 122, 1, true)
            memory.write(0x5231A6, 117, 1, true)
            memory.write(0x52322D, 117, 1, true)
            memory.write(0x5233BA, 117, 1, true)
       end
        wait(0)
    end
end

function q.onSendCommand(command)
    if command == '/salentaboba' then
        mainWindowState.v = not mainWindowState.v
    end
    imgui.Process = mainWindowState.v
end    


function imgui.TextQuestion(label, description)
    imgui.TextDisabled(label)

    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
            imgui.PushTextWrapPos(600)
                imgui.TextUnformatted(description)
            imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end

function imgui.CenterTextColoredRGB(text)
    imgui.SetCursorPosX(imgui.GetWindowSize().x / 2 - imgui.CalcTextSize(text).x / 2)
end



function imgui.OnDrawFrame()
    local posX, posY = getScreenResolution()
    if mainWindowState.v then
        imgui.SetNextWindowPos(imgui.ImVec2(posX / 2, posY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(560, 560), imgui.Cond.FirstUseEver)
        imgui.Begin('SAMPFUNCS Hided', mainWindowState)
        imgui.Text("..._...|..____________________,,")
        imgui.Text("....../ `---___________----_____|] ")
        imgui.Text("...../_==o;;;;;;;;_______.:/ ")
        imgui.Text(".....), ---.(_(__) /")
        imgui.Text('....// (..) ), ----"')
        imgui.Text('...//___//')
        imgui.Text('..//___//')

        imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"Aim").x) / 4)
        if imgui.Button('Aim') then tab = 0 end
        imgui.SameLine()
        if imgui.Button('Misc') then tab = 1 end
        imgui.SameLine()
        if imgui.Button('CFG') then tab = 2 end
        imgui.SameLine()
        if imgui.Button(u8'Выгрузить') then
            showCursor(false,false)
            thisScript():unload()
        end
        if tab == 0 then
            imgui.SliderFloat('Radius', radius, 0.0, 100.0, '%.1f')
            imgui.TextQuestion(u8"Что делает Радиус", u8"В радиус задается дистанция, при которой Smooth аим доводит.")
            imgui.SliderFloat('Smooth', smooth, 0.0, 50.0, '%.1f')
            imgui.TextQuestion(u8"Что делает Smooth", u8"Smooth - плавность аима, можно ставить ее максимально, аим не потерпит поражения.")
            imgui.Checkbox('Enable', enable)
            imgui.Checkbox('VisibleCheck', visibleCheck)
        end
        if tab == 1 then
            imgui.Checkbox('CheckStuned', checkStuned)
            imgui.TextQuestion(u8"Что делает Check Stuned", u8"CheckStuned - проверяет застанены ли вы, и прекращает работать в случаи стана. Если нет стана - продолжает работу.")
            imgui.Checkbox('ClistFilter', clistFilter)
            imgui.TextQuestion(u8"Что делает ClistFilter", u8"ClistFilter - ориентируется на ваш клист, чтобы не наводится на других игроков с вашим клистом")
            imgui.Checkbox('CheckPause', checkPause)
            imgui.TextQuestion(u8"Что делает CheckPause", u8"Если Вы в AFK, аим прекращает работу (бесполезная функция, но ладно)")
            imgui.Checkbox('Only X coord (gonwik)', onlyX)
            imgui.TextQuestion(u8"Что делает Only X", u8"OnlyX - делает ваш аим максимально беспалевным на опрах")
            imgui.TextQuestion(u8"Что делает Don't Auto controlling", u8"Вы сможете сами контроллить +С при аиме.")
            imgui.Checkbox("Chanced antistun", antistun)
            imgui.SliderFloat('Chance antistun', chance, 0, 5, '%.1f')
            imgui.Checkbox('Auto Fire', autofire)
            imgui.Checkbox('Extra WS', extraws) 
        end
        if tab == 2 then
            if imgui.Button(u8'Загрузить настройки') then
                loadSettings()
            end
            if imgui.Button(u8'Сохранить настройки') then
                saveSettings()
            end
            imgui.Checkbox(u8'Авто загрузка конфига при входе в игру', autoload)
        end
        imgui.End()
    end
end




function saveSettings()
    mainIni.config.time = smooth.v
    mainIni.config.weather = radius.v
    mainIni.config.antiservertime = enable.v
    mainIni.config.fixsun = visibleCheck.v
    mainIni.config.fixmoon = clistFilter.v
    mainIni.config.enablesun = checkStuned.v
    mainIni.config.disablepostprocess = checkPause.v
    mainIni.config.resetremove = autoload.v
    mainIni.config.fixswimfps = antistun.v
    mainIni.config.disablemoon = extraws.v
    inicfg.save(mainIni, "setWeather&Time.ini")
end

function loadSettings()
    smooth.v = mainIni.config.time
    radius.v = mainIni.config.weather
    enable.v = mainIni.config.antiservertime
    visibleCheck.v = mainIni.config.fixsun
    clistFilter.v = mainIni.config.fixmoon
    checkStuned.v =  mainIni.config.enablesun
    checkPause.v = mainIni.config.disablepostprocess
    autoload.v = mainIni.config.resetremove
    antistun.v = mainIni.config.fixswimfps
    extraws.v = mainIni.config.disablemoon
end



function fix(angle)
    if angle > math.pi then
        angle = angle - (math.pi * 2)
    elseif angle < -math.pi then
        angle = angle + (math.pi * 2)
    end
    return angle
end

function q.onSendPlayerSync(data)
	if antistun.v then
        local r = math.random(0, 5)
        if r == 2 then
            for k, v in pairs(stun_anims) do
                if isCharPlayingAnim(PLAYER_PED, v) then
                    setCharAnimSpeed(playerPed, v, 100)
                end
            end
        end
	end
end

function GetNearestPed(fov)
    local maxDistance = 35
    local nearestPED = -1
    for i = 0, sampGetMaxPlayerId(true) do
        if sampIsPlayerConnected(i) then
            local find, handle = sampGetCharHandleBySampPlayerId(i)
            if find then
                if isCharOnScreen(handle) then
                    if not isCharDead(handle) then
                        local _, currentID = sampGetPlayerIdByCharHandle(PLAYER_PED)
                        local enPos = {GetBodyPartCoordinates(GetNearestBone(handle), handle)}
                        local myPos = {getActiveCameraCoordinates()}
                        local vector = {myPos[1] - enPos[1], myPos[2] - enPos[2], myPos[3] - enPos[3]}
                        if isWidescreenOnInOptions() then coefficentZ = 0.0778 else coefficentZ = 0.103 end
                        local angle = {(math.atan2(vector[2], vector[1]) + 0.04253), (math.atan2((math.sqrt((math.pow(vector[1], 2) + math.pow(vector[2], 2)))), vector[3]) - math.pi / 2 - coefficentZ)}
                        local view = {fix(representIntAsFloat(readMemory(0xB6F258, 4, false))), fix(representIntAsFloat(readMemory(0xB6F248, 4, false)))}
                        local distance = math.sqrt((math.pow(angle[1] - view[1], 2) + math.pow(angle[2] - view[2], 2))) * 57.2957795131
                        if distance > fov then check = true else check = false end
                        if not check then
                            local myPos = {getCharCoordinates(PLAYER_PED)}
                            local distance = math.sqrt((math.pow((enPos[1] - myPos[1]), 2) + math.pow((enPos[2] - myPos[2]), 2) + math.pow((enPos[3] - myPos[3]), 2)))
                            if (distance < maxDistance) then
                                nearestPED = handle
                                maxDistance = distance
                            end
                        end
                    end
                end
            end
        end
    end
    return nearestPED
end

function GetNearestBone(handle)
    local maxDist = 20000    
    local nearestBone = -1
    bone = {42, 52, 23, 33, 3, 22, 32, 8}
    for n = 1, 8 do
        local crosshairPos = {convertGameScreenCoordsToWindowScreenCoords(339.1, 179.1)}
        local bonePos = {GetBodyPartCoordinates(bone[n], handle)}
        local enPos = {convert3DCoordsToScreen(bonePos[1], bonePos[2], bonePos[3])}
        local distance = math.sqrt((math.pow((enPos[1] - crosshairPos[1]), 2) + math.pow((enPos[2] - crosshairPos[2]), 2)))
        if (distance < maxDist) then
            nearestBone = bone[n]
            maxDist = distance
        end 
    end
    return nearestBone
end

function GetBodyPartCoordinates(id, handle)
    if doesCharExist(handle) then
        local pedptr = getCharPointer(handle)
        local vec = ffi.new("float[3]")
        getbonePosition(ffi.cast("void*", pedptr), vec, id, true)
        return vec[0], vec[1], vec[2]
    end
end

function CheckStuned()
	for k, v in pairs(stun_anims) do
		if isCharPlayingAnim(PLAYER_PED, v) then
			return false
		end
	end
	return true
end

function smooth_aimbot()
    if enable.v and isKeyDown(vkeys.VK_RBUTTON) then
        local handle = GetNearestPed(radius.v)
        if handle ~= -1 then
            local _, myID = sampGetPlayerIdByCharHandle(PLAYER_PED)
            local result, playerID = sampGetPlayerIdByCharHandle(handle)
            if result then
                if (checkStuned.v and not CheckStuned()) then return false end
                if (clistFilter.v and sampGetPlayerColor(myID) == sampGetPlayerColor(playerID)) then return false end
                if (checkPause.v and sampIsPlayerPaused(playerID)) then return false end
                local myPos = {getActiveCameraCoordinates()}
                local enPos = {GetBodyPartCoordinates(GetNearestBone(handle), handle)}
                if not visibleCheck.v or (visibleCheck.v and isLineOfSightClear(myPos[1], myPos[2], myPos[3], enPos[1], enPos[2], enPos[3], true, true, false, true, true)) then
                    local vector = {myPos[1] - enPos[1], myPos[2] - enPos[2], myPos[3] - enPos[3]}
                    if isWidescreenOnInOptions() then coefficentZ = 0.0778 else coefficentZ = 0.103 end
                    local angle = {(math.atan2(vector[2], vector[1]) + 0.04253), (math.atan2((math.sqrt((math.pow(vector[1], 2) + math.pow(vector[2], 2)))), vector[3]) - math.pi / 2 - coefficentZ)}
                    local view = {fix(representIntAsFloat(readMemory(0xB6F258, 4, false))), fix(representIntAsFloat(readMemory(0xB6F248, 4, false)))}
                    local difference = {angle[1] - view[1], angle[2] - view[2]}
                    local smooth = {difference[1] / smooth.v, difference[2] / smooth.v}
                    setCameraPositionUnfixed((view[2] + smooth[2]), (view[1] + smooth[1]))
                    if autofire.v then setGameKeyState(17, 255) end
                end
            end
        end
    end
    return false
end

function apply_custom_style()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    local ImVec2 = imgui.ImVec2
 
     style.WindowPadding = ImVec2(15, 15)
     style.WindowRounding = 15.0
     style.FramePadding = ImVec2(5, 5)
     style.ItemSpacing = ImVec2(12, 8)
     style.ItemInnerSpacing = ImVec2(8, 6)
     style.IndentSpacing = 25.0
     style.ScrollbarSize = 15.0
     style.ScrollbarRounding = 15.0
     style.GrabMinSize = 15.0
     style.GrabRounding = 7.0
     style.ChildWindowRounding = 8.0
     style.FrameRounding = 6.0
   
 
       colors[clr.Text] = ImVec4(0.95, 0.96, 0.98, 1.00)
       colors[clr.TextDisabled] = ImVec4(0.36, 0.42, 0.47, 1.00)
       colors[clr.WindowBg] = ImVec4(0.11, 0.15, 0.17, 1.00)
       colors[clr.ChildWindowBg] = ImVec4(0.15, 0.18, 0.22, 1.00)
       colors[clr.PopupBg] = ImVec4(0.08, 0.08, 0.08, 0.94)
       colors[clr.Border] = ImVec4(0.43, 0.43, 0.50, 0.50)
       colors[clr.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00)
       colors[clr.FrameBg] = ImVec4(0.20, 0.25, 0.29, 1.00)
       colors[clr.FrameBgHovered] = ImVec4(0.12, 0.20, 0.28, 1.00)
       colors[clr.FrameBgActive] = ImVec4(0.09, 0.12, 0.14, 1.00)
       colors[clr.TitleBg] = ImVec4(0.09, 0.12, 0.14, 0.65)
       colors[clr.TitleBgCollapsed] = ImVec4(0.00, 0.00, 0.00, 0.51)
       colors[clr.TitleBgActive] = ImVec4(0.08, 0.10, 0.12, 1.00)
       colors[clr.MenuBarBg] = ImVec4(0.15, 0.18, 0.22, 1.00)
       colors[clr.ScrollbarBg] = ImVec4(0.02, 0.02, 0.02, 0.39)
       colors[clr.ScrollbarGrab] = ImVec4(0.20, 0.25, 0.29, 1.00)
       colors[clr.ScrollbarGrabHovered] = ImVec4(0.18, 0.22, 0.25, 1.00)
       colors[clr.ScrollbarGrabActive] = ImVec4(0.09, 0.21, 0.31, 1.00)
       colors[clr.ComboBg] = ImVec4(0.20, 0.25, 0.29, 1.00)
       colors[clr.CheckMark] = ImVec4(0.28, 0.56, 1.00, 1.00)
       colors[clr.SliderGrab] = ImVec4(0.28, 0.56, 1.00, 1.00)
       colors[clr.SliderGrabActive] = ImVec4(0.37, 0.61, 1.00, 1.00)
       colors[clr.Button] = ImVec4(0.20, 0.25, 0.29, 1.00)
       colors[clr.ButtonHovered] = ImVec4(0.28, 0.56, 1.00, 1.00)
       colors[clr.ButtonActive] = ImVec4(0.06, 0.53, 0.98, 1.00)
       colors[clr.Header] = ImVec4(0.20, 0.25, 0.29, 0.55)
       colors[clr.HeaderHovered] = ImVec4(0.26, 0.59, 0.98, 0.80)
       colors[clr.HeaderActive] = ImVec4(0.26, 0.59, 0.98, 1.00)
       colors[clr.ResizeGrip] = ImVec4(0.26, 0.59, 0.98, 0.25)
       colors[clr.ResizeGripHovered] = ImVec4(0.26, 0.59, 0.98, 0.67)
       colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
       colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
       colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
       colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
       colors[clr.PlotLines] = ImVec4(0.61, 0.61, 0.61, 1.00)
       colors[clr.PlotLinesHovered] = ImVec4(1.00, 0.43, 0.35, 1.00)
       colors[clr.PlotHistogram] = ImVec4(0.90, 0.70, 0.00, 1.00)
       colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
       colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
       colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
 end
 apply_custom_style()