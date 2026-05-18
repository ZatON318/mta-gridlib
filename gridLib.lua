--==========================================================
-- GridLib.lua
-- A library for grid-based rendering in MTA:SA with customizable grid elements:
--   - Buttons
--   - Text Inputs
--   - Checkboxes
--   - Radio Buttons
--   - Divs (with fade, fly-in animations, click handling, separate clickability/visibility,
--           text support, customizable roundness, hover/click background colors, and background images)
--
-- Also includes a helper to render images within a grid field.
--==========================================================

-- Make GridLib a global table so other scripts can use it.
GridLib = {}

--------------------------------------------------
-- Configuration
--------------------------------------------------
GridLib.config = {
    gridCountX = 20,   -- number of columns
    gridCountY = 10,   -- number of rows
    gap        = 5,    -- gap (in pixels) between grid cells
    edgeMargin = 20    -- margin (in pixels) from screen edges
}

function GridLib.setConfig(newConfig)
    for k, v in pairs(newConfig) do
        GridLib.config[k] = v
    end
end

--------------------------------------------------
-- Grid Layout Calculation
--------------------------------------------------
function GridLib.getGridLayout()
    local screenW, screenH = guiGetScreenSize()
    local effectiveW = screenW - 2 * GridLib.config.edgeMargin
    local effectiveH = screenH - 2 * GridLib.config.edgeMargin
    local gcx = GridLib.config.gridCountX
    local gcy = GridLib.config.gridCountY
    local gap = GridLib.config.gap

    local maxSizeX = (effectiveW - (gcx - 1) * gap) / gcx
    local maxSizeY = (effectiveH - (gcy - 1) * gap) / gcy
    local squareSize = math.min(maxSizeX, maxSizeY)

    local gridWidth = gcx * squareSize + (gcx - 1) * gap
    local gridHeight = gcy * squareSize + (gcy - 1) * gap

    local startX = GridLib.config.edgeMargin + (effectiveW - gridWidth) / 2
    local startY = GridLib.config.edgeMargin + (effectiveH - gridHeight) / 2

    return startX, startY, squareSize
end

--------------------------------------------------
-- Rendering the Entire Grid
--------------------------------------------------
function GridLib.renderGrid()
    local startX, startY, squareSize = GridLib.getGridLayout()
    local gcx = GridLib.config.gridCountX
    local gcy = GridLib.config.gridCountY
    local gap = GridLib.config.gap

    for row = 0, gcy - 1 do
        for col = 0, gcx - 1 do
            local x = startX + col * (squareSize + gap)
            local y = startY + row * (squareSize + gap)
            dxDrawRectangle(x, y, squareSize, squareSize, tocolor(255, 255, 255, 200))
        end
    end
end

--------------------------------------------------
-- Get Pixel Rectangle from Grid Coordinates
--------------------------------------------------
function GridLib.getPixelRect(sc, sr, ec, er)
    local startX, startY, squareSize = GridLib.getGridLayout()
    local gap = GridLib.config.gap
    local x = startX + sc * (squareSize + gap)
    local y = startY + sr * (squareSize + gap)
    local width = (ec - sc + 1) * squareSize + (ec - sc) * gap
    local height = (er - sr + 1) * squareSize + (er - sr) * gap
    return x, y, width, height
end

--------------------------------------------------
-- Render a Static Rectangle in Grid Coordinates
--------------------------------------------------
function GridLib.renderRect(sc, sr, ec, er, color)
    local x, y, w, h = GridLib.getPixelRect(sc, sr, ec, er)
    dxDrawRectangle(x, y, w, h, color or tocolor(255, 0, 0, 150))
end

--------------------------------------------------
-- Render Text within a Grid Area
--------------------------------------------------
function GridLib.renderText(text, sc, sr, ec, er, color, scale, font, alignH, alignV, clip)
    local x, y, w, h = GridLib.getPixelRect(sc, sr, ec, er)
    local padding = 2
    dxDrawText(text, x + padding, y + padding, x + w - padding, y + h - padding,
               color or tocolor(0, 0, 0, 255), scale or 1, font or "default-bold",
               alignH or "center", alignV or "center", clip or false)
end

--------------------------------------------------
-- Render Image within a Grid Area
--------------------------------------------------
function GridLib.renderImage(image, sc, sr, ec, er, color)
    local x, y, w, h = GridLib.getPixelRect(sc, sr, ec, er)
    dxDrawImage(x, y, w, h, image, 0, 0, 0, color or tocolor(255,255,255,255))
end

--------------------------------------------------
-- Button Rendering (Optional)
--------------------------------------------------
function GridLib.renderButton(button)
    if button.enabled == false or not button.clickable then return end
    local x, y, w, h = button.getRect(button)
    local hovered = false
    local cx, cy = getCursorPosition()
    if cx and cy then
        local screenW, screenH = guiGetScreenSize()
        local absX, absY = cx * screenW, cy * screenH
        if absX >= x and absX <= x + w and absY >= y and absY <= y + h then
            hovered = true
        end
    end
    local bgColor = hovered and (button.hoverColor or tocolor(0,150,255,200))
                            or (button.bgColor or tocolor(0,100,255,200))
    dxDrawRectangle(x, y, w, h, bgColor)
    dxDrawText(button.label or "Button", x, y, x + w, y + h,
               button.textColor or tocolor(255,255,255,255),
               button.textScale or 1,
               button.font or "default-bold",
               button.textAlignH or "center",
               button.textAlignV or "center")
end

--------------------------------------------------
-- Clickable Elements
--------------------------------------------------
GridLib.clickables = {}

local function isInRect(px, py, rx, ry, rw, rh)
    return (px >= rx and px <= rx + rw and py >= ry and py <= ry + rh)
end

function GridLib.handleClick(absX, absY)
    for _, element in ipairs(GridLib.clickables) do
        if element.enabled ~= false and element.clickable then
            local rx, ry, rw, rh = element.getRect(element)
            if isInRect(absX, absY, rx, ry, rw, rh) then
                if type(element.onClick) == "function" then
                    element.onClick(element)
                end
            end
        end
    end
end

function GridLib.clickHandler(button, state, absX, absY)
    if button == "left" and state == "down" then
        GridLib.handleClick(absX, absY)
    end
end
addEventHandler("onClientClick", root, GridLib.clickHandler)

function GridLib.createClickable(params)
    local clickable = {
        startCol = params.startCol,
        startRow = params.startRow,
        endCol = params.endCol,
        endRow = params.endRow,
        label = params.label,
        onClick = params.onClick,
        enabled = params.enabled ~= false,
        clickable = params.clickable == nil and true or params.clickable,
        getRect = function(self)
            return GridLib.getPixelRect(self.startCol, self.startRow, self.endCol, self.endRow)
        end
    }
    table.insert(GridLib.clickables, clickable)
    return clickable
end

function GridLib.createButton(sc, sr, ec, er, label, onClick, clickable)
    return GridLib.createClickable({
        startCol = sc,
        startRow = sr,
        endCol = ec,
        endRow = er,
        label = label,
        onClick = onClick,
        enabled = true,
        clickable = clickable == nil and true or clickable,
    })
end

--------------------------------------------------
-- Divs (formerly Animated Rectangles) with Fade, Fly-In, Click Handling, Text Support,
-- and Customizable Background (including hover and click colors, roundness, and background images)
--------------------------------------------------
GridLib.divs = {}

-- Helper: Extract RGBA components from a color value.
function GridLib.getColorComponents(color)
    local a = math.floor(color / 0x1000000) % 256
    local r = math.floor(color / 0x10000) % 256
    local g = math.floor(color / 0x100) % 256
    local b = color % 256
    return r, g, b, a
end

function GridLib.createDiv(sc, sr, ec, er, color, params)
    local providedColor = color or tocolor(0,0,0,250)
    local r, g, b, a = GridLib.getColorComponents(providedColor)
    local div = {
        currentSC = sc, currentSR = sr,
        currentEC = ec, currentER = er,
        baseR = r, baseG = g, baseB = b, baseA = a,
        alpha = a,
        color = providedColor,   -- default background color
        isActive = false,
        startTime = 0,
        endTime = 0,
        duration = 2000,
        -- Fade animation properties:
        isFading = false,
        fadeStartTime = 0,
        fadeDuration = 0,
        fadeFrom = 0,
        fadeTo = 0,
        -- Timer for fly-in updates:
        updateTimer = nil,
        -- Stored target coordinates for fly-in:
        targetSC = nil,
        targetSR = nil,
        targetEC = nil,
        targetER = nil,
        clickable = params and (params.clickable == nil and true or params.clickable) or true,
        visible = params and (params.visible == nil and true or params.visible) or true,
        onClick = params and params.onClick or nil,
        bgImage = params and params.bgImage or nil,
        text = params and params.text or "",
        textColor = params and params.textColor or tocolor(255,255,255,255),
        textScale = params and params.textScale or 1,
        textFont = params and params.textFont or "default",
        textAlignH = params and params.textAlignH or "center",
        textAlignV = params and params.textAlignV or "center",
        roundness = params and params.roundness or 0,
        hoverBgColor = params and params.hoverBgColor or nil,
        clickBgColor = params and params.clickBgColor or nil,
    }
    function div:startAnimation(newSC, newSR, newEC, newER, duration)
        self.isActive = true
        self.startTime = getTickCount()
        self.endTime = self.startTime + (duration or self.duration)
        self.fromSC = self.currentSC
        self.fromSR = self.currentSR
        self.fromEC = self.currentEC
        self.fromER = self.currentER
        self.toSC = newSC
        self.toSR = newSR
        self.toEC = newEC
        self.toER = newER
        self.duration = duration or self.duration
    end
    function div:startFadeAnimation(targetAlpha, duration)
        self.isFading = true
        self.fadeStartTime = getTickCount()
        self.fadeDuration = duration
        self.fadeFrom = self.alpha
        self.fadeTo = targetAlpha
    end
    function div:startFlyInAnimation(side, duration)
        if not self.targetSC then
            self.targetSC = self.currentSC
            self.targetSR = self.currentSR
            self.targetEC = self.currentEC
            self.targetER = self.currentER
        end
        local targetSC = self.targetSC
        local targetSR = self.targetSR
        local targetEC = self.targetEC
        local targetER = self.targetER
        if side == "top" then
            self.fromSC = targetSC
            self.fromSR = -((targetER - targetSR) + 1)
            self.fromEC = targetEC
            self.fromER = self.fromSR + (targetER - targetSR)
        elseif side == "bottom" then
            self.fromSC = targetSC
            self.fromSR = GridLib.config.gridCountY
            self.fromEC = targetEC
            self.fromER = self.fromSR + (targetER - targetSR)
        elseif side == "left" then
            self.fromSC = -((targetEC - targetSC) + 1)
            self.fromSR = targetSR
            self.fromEC = self.fromSC + (targetEC - targetSC)
            self.fromER = targetER
        elseif side == "right" then
            self.fromSC = GridLib.config.gridCountX
            self.fromSR = targetSR
            self.fromEC = self.fromSC + (targetEC - targetSC)
            self.fromER = targetER
        else
            self.fromSC = targetSC
            self.fromSR = targetSR
            self.fromEC = targetEC
            self.fromER = targetER
        end
        self.currentSC = self.fromSC
        self.currentSR = self.fromSR
        self.currentEC = self.fromEC
        self.currentER = self.fromER
        self.toSC = targetSC
        self.toSR = targetSR
        self.toEC = targetEC
        self.toER = targetER
        self.isActive = true
        self.startTime = getTickCount()
        self.endTime = self.startTime + (duration or self.duration)
        if self.updateTimer then killTimer(self.updateTimer) end
        self.updateTimer = setTimer(function()
            self:update()
            if not self.isActive then
                killTimer(self.updateTimer)
                self.updateTimer = nil
            end
        end, 50, 0)
    end
    function div:update()
        if self.isActive then
            local now = getTickCount()
            local progress = (now - self.startTime) / (self.endTime - self.startTime)
            if progress >= 1 then progress = 1; self.isActive = false end
            local function lerp(a, b, t) return a + (b - a) * t end
            self.currentSC = lerp(self.fromSC, self.toSC, progress)
            self.currentSR = lerp(self.fromSR, self.toSR, progress)
            self.currentEC = lerp(self.fromEC, self.toEC, progress)
            self.currentER = lerp(self.fromER, self.toER, progress)
        end
        if self.isFading then
            local now = getTickCount()
            local fadeProgress = (now - self.fadeStartTime) / self.fadeDuration
            if fadeProgress >= 1 then fadeProgress = 1; self.isFading = false end
            self.alpha = self.fadeFrom + (self.fadeTo - self.fadeFrom) * fadeProgress
        end
    end
    function div:render()
        local x, y, w, h = GridLib.getPixelRect(self.currentSC, self.currentSR, self.currentEC, self.currentER)
        -- Determine the background color (or tint) based on mouse state.
        local currentBgColor = self.color
        local cx, cy = getCursorPosition()
        if cx and cy then
            local screenW, screenH = guiGetScreenSize()
            local absX, absY = cx * screenW, cy * screenH
            if absX >= x and absX <= x + w and absY >= y and absY <= y + h then
                if getKeyState("mouse1") then
                    currentBgColor = self.clickBgColor or currentBgColor
                else
                    currentBgColor = self.hoverBgColor or currentBgColor
                end
            end
        end
        -- Draw the background (using rounded rectangle if roundness > 0)
        if self.roundness and self.roundness > 0 then
            GridLib.dxDrawRoundedRect(x, y, w, h, self.roundness, currentBgColor)
        else
            dxDrawRectangle(x, y, w, h, currentBgColor)
        end
        -- Draw the background image on top, if provided.
        if self.bgImage then
            dxDrawImage(x, y, w, h, self.bgImage, 0, 0, 0, tocolor(255,255,255,self.alpha))
        end
        -- Draw the text (supports multi-line "\n")
        if self.text and self.text ~= "" then
            dxDrawText(self.text, x + 5, y + 5, x + w - 5, y + h - 5, self.textColor, self.textScale, self.textFont, self.textAlignH, self.textAlignV)
        end
    end
    table.insert(GridLib.divs, div)
    return div
end

function GridLib.renderDiv(div)
    if div and div.visible then
        div:update()
        div:render()
    end
end

--------------------------------------------------
-- Helper: Draw a Filled Rounded Rectangle (Approximation)
--------------------------------------------------
function GridLib.dxDrawRoundedRect(x, y, w, h, radius, color)
    for i = 0, h - 1 do
        local curY = y + i
        local offset = 0
        if i < radius then
            offset = radius - math.sqrt(radius * radius - (radius - i) * (radius - i))
        elseif i > h - radius then
            local j = i - (h - radius)
            offset = radius - math.sqrt(radius * radius - j * j)
        end
        dxDrawLine(x + offset, curY, x + w - offset, curY, color, 1)
    end
end

--------------------------------------------------
-- Text Input Fields
--------------------------------------------------
GridLib.textInputs = {}
GridLib.focusedTextInput = nil
GridLib.backspaceTimer = nil

function GridLib.createTextInput(sc, sr, ec, er, initialText, onChange, onEnter, options)
    local options = options or {}
    local style = {
        bgColor = options.bgColor or tocolor(255, 255, 255, 150),
        borderColor = options.borderColor or tocolor(200, 200, 200, 255),
        borderColorFocused = options.borderColorFocused or tocolor(0, 255, 0, 255),
        textColor = options.textColor or tocolor(0, 0, 0, 255),
        font = options.font or "default",
        textScale = options.textScale or 1,
        borderWidth = options.borderWidth or 2,
        textPadding = options.textPadding or 5,
        textAlignH = options.textAlignH or "left",
        textAlignV = options.textAlignV or "center",
    }
    local placeholder = options.placeholder or ""
    local isPlaceholderActive = false
    if (initialText == "" or initialText == nil) and placeholder ~= "" then
        initialText = placeholder
        isPlaceholderActive = true
    end
    local placeholderColor = options.placeholderColor or tocolor(0, 0, 0, 180)
    local inputType = options.inputType or "text"
    local textInput = {
        startCol = sc,
        startRow = sr,
        endCol = ec,
        endRow = er,
        text = initialText or "",
        onChange = onChange,
        onEnter = onEnter,
        focused = false,
        style = style,
        placeholder = placeholder,
        isPlaceholderActive = isPlaceholderActive,
        placeholderColor = placeholderColor,
        inputType = inputType,
        clickable = options.clickable == nil and true or options.clickable,
        getRect = function(self)
            return GridLib.getPixelRect(self.startCol, self.startRow, self.endCol, self.endRow)
        end,
        render = function(self)
            local x, y, w, h = self:getRect()
            local cx, cy = getCursorPosition()
            local hovered = false
            if cx and cy then
                local screenW, screenH = guiGetScreenSize()
                local absX, absY = cx * screenW, cy * screenH
                if absX >= x and absX <= x + w and absY >= y and absY <= y + h then
                    hovered = true
                end
            end
            local bgColor = self.style.bgColor
            local borderColor = self.focused and self.style.borderColorFocused or (hovered and tocolor(0,150,255,200) or self.style.borderColor)
            dxDrawRectangle(x, y, w, h, bgColor)
            dxDrawLine(x, y, x + w, y, borderColor, self.style.borderWidth)
            dxDrawLine(x, y, x, y + h, borderColor, self.style.borderWidth)
            dxDrawLine(x + w, y, x + w, y + h, borderColor, self.style.borderWidth)
            dxDrawLine(x, y + h, x + w, y + h, borderColor, self.style.borderWidth)
            if self.isPlaceholderActive then
                dxDrawText(self.placeholder, x + self.style.textPadding, y, x + w - self.style.textPadding, y + h, self.placeholderColor, self.style.textScale, self.style.font, self.style.textAlignH, self.style.textAlignV)
            else
                local displayText = self.text
                if self.inputType == "password" then
                    displayText = string.rep("*", #self.text)
                end
                dxDrawText(displayText, x + self.style.textPadding, y, x + w - self.style.textPadding, y + h, self.style.textColor, self.style.textScale, self.style.font, self.style.textAlignH, self.style.textAlignV)
                if self.focused then
                    local textWidth = dxGetTextWidth(displayText, self.style.textScale, self.style.font)
                    local caretX = x + self.style.textPadding + textWidth + 2
                    local caretY1 = y + self.style.textPadding
                    local caretY2 = y + h - self.style.textPadding
                    if (getTickCount() % 1000) < 500 then
                        dxDrawLine(caretX, caretY1, caretX, caretY2, self.style.textColor, self.style.borderWidth)
                    end
                end
            end
        end,
        setFocus = function(self, state)
            if state then
                self.focused = true
                GridLib.focusedTextInput = self
                guiSetInputEnabled(true)
                showCursor(true)
                if self.isPlaceholderActive then
                    self.text = ""
                    self.isPlaceholderActive = false
                end
            else
                self.focused = false
                if GridLib.focusedTextInput == self then
                    GridLib.focusedTextInput = nil
                end
                if self.text == "" and self.placeholder ~= "" then
                    self.text = self.placeholder
                    self.isPlaceholderActive = true
                end
                if not GridLib.focusedTextInput then
                    guiSetInputEnabled(false)
                    showCursor(false)
                end
            end
        end,
        addCharacter = function(self, char)
            self.text = self.text .. char
            if self.onChange then self.onChange(self.text) end
        end,
        removeCharacter = function(self)
            self.text = string.sub(self.text, 1, -2)
            if self.onChange then self.onChange(self.text) end
        end,
    }
    table.insert(GridLib.textInputs, textInput)
    return textInput
end

function GridLib.renderTextInputs()
    for _, input in ipairs(GridLib.textInputs) do
        if input.clickable then input:render() end
    end
end

function GridLib.renderTextInput(textInput)
    if textInput and textInput.clickable then textInput:render() end
end

--------------------------------------------------
-- Checkboxes
--------------------------------------------------
GridLib.checkboxes = {}

function GridLib.createCheckbox(params)
    local checkbox = {
        startCol = params.startCol,
        startRow = params.startRow,
        endCol = params.endCol,
        endRow = params.endRow,
        label = params.label or "",
        checked = params.checked or false,
        onToggle = params.onToggle,
        style = {
            boxBgColor = params.boxBgColor or tocolor(255, 255, 255, 255),
            boxBorderColor = params.boxBorderColor or tocolor(0, 0, 0, 255),
            boxBorderWidth = params.boxBorderWidth or 2,
            checkColor = params.checkColor or tocolor(0, 0, 0, 255),
            labelColor = params.labelColor or tocolor(0, 0, 0, 255),
            labelFont = params.labelFont or "default",
            labelScale = params.labelScale or 1,
            labelAlignH = params.labelAlignH or "left",
            labelAlignV = params.labelAlignV or "center",
        },
        clickable = params.clickable == nil and true or params.clickable,
        getRect = function(self)
            return GridLib.getPixelRect(self.startCol, self.startRow, self.endCol, self.endRow)
        end,
        render = function(self)
            local x, y, w, h = self:getRect()
            local boxSize = h * 0.8
            local boxX = x + self.style.boxBorderWidth
            local boxY = y + (h - boxSize) / 2
            dxDrawRectangle(boxX, boxY, boxSize, boxSize, self.style.boxBgColor)
            dxDrawLine(boxX, boxY, boxX + boxSize, boxY, self.style.boxBorderColor, self.style.boxBorderWidth)
            dxDrawLine(boxX, boxY, boxX, boxY + boxSize, self.style.boxBorderColor, self.style.boxBorderWidth)
            dxDrawLine(boxX + boxSize, boxY, boxX + boxSize, boxY + boxSize, self.style.boxBorderColor, self.style.boxBorderWidth)
            dxDrawLine(boxX, boxY + boxSize, boxX + boxSize, boxY + boxSize, self.style.boxBorderColor, self.style.boxBorderWidth)
            if self.checked then
                local margin = 4
                dxDrawLine(boxX + margin, boxY + margin, boxX + boxSize - margin, boxY + boxSize - margin, self.style.checkColor, self.style.boxBorderWidth)
                dxDrawLine(boxX + boxSize - margin, boxY + margin, boxX + margin, boxY + boxSize - margin, self.style.checkColor, self.style.boxBorderWidth)
            end
            dxDrawText(self.label, boxX + boxSize + 5, y, x + w, y + h, self.style.labelColor, self.style.labelScale, self.style.labelFont, self.style.labelAlignH, self.style.labelAlignV)
        end,
        toggle = function(self)
            self.checked = not self.checked
            if self.onToggle then self.onToggle(self, self.checked) end
        end,
        setChecked = function(self, state)
            self.checked = state
            if self.onToggle then self.onToggle(self, self.checked) end
        end,
    }
    table.insert(GridLib.checkboxes, checkbox)
    return checkbox
end

function GridLib.renderCheckbox(checkbox)
    if checkbox and checkbox.clickable then checkbox:render() end
end

--------------------------------------------------
-- Radio Buttons
--------------------------------------------------
GridLib.radioButtons = {}

function GridLib.dxDrawCircle(x, y, radius, startAngle, stopAngle, color, width)
    local segments = 32
    local angleStep = (stopAngle - startAngle) / segments
    local prevX, prevY
    for i = 0, segments do
        local angle = math.rad(startAngle + i * angleStep)
        local newX = x + math.cos(angle) * radius
        local newY = y + math.sin(angle) * radius
        if i > 0 then
            dxDrawLine(prevX, prevY, newX, newY, color, width)
        end
        prevX, prevY = newX, newY
    end
end

function GridLib.dxDrawFilledCircle(x, y, radius, color)
    local segments = 32
    local step = radius / segments
    for r = step, radius, step do
        GridLib.dxDrawCircle(x, y, r, 0, 360, color, 1)
    end
end

function GridLib.createRadioButton(params)
    local radio = {
        startCol = params.startCol,
        startRow = params.startRow,
        endCol = params.endCol,
        endRow = params.endRow,
        label = params.label or "",
        selected = params.selected or false,
        group = params.group or "default",
        onSelect = params.onSelect,
        style = {
            circleBgColor = params.circleBgColor or tocolor(255, 255, 255, 255),
            circleBorderColor = params.circleBorderColor or tocolor(0, 0, 0, 255),
            circleBorderWidth = params.circleBorderWidth or 2,
            selectedColor = params.selectedColor or tocolor(0, 0, 0, 255),
            labelColor = params.labelColor or tocolor(0, 0, 0, 255),
            labelFont = params.labelFont or "default",
            labelScale = params.labelScale or 1,
            labelAlignH = params.labelAlignH or "left",
            labelAlignV = params.labelAlignV or "center",
        },
        clickable = params.clickable == nil and true or params.clickable,
        getRect = function(self)
            return GridLib.getPixelRect(self.startCol, self.startRow, self.endCol, self.endRow)
        end,
        render = function(self)
            local x, y, w, h = self:getRect()
            local circleRadius = h * 0.4
            local circleX = x + self.style.circleBorderWidth + circleRadius
            local circleY = y + h / 2
            GridLib.dxDrawCircle(circleX, circleY, circleRadius, 0, 360, self.style.circleBorderColor, self.style.circleBorderWidth)
            GridLib.dxDrawCircle(circleX, circleY, circleRadius - self.style.circleBorderWidth, 0, 360, self.style.circleBgColor, 0)
            if self.selected then
                GridLib.dxDrawFilledCircle(circleX, circleY, circleRadius * 0.5, self.style.selectedColor)
            end
            dxDrawText(self.label, circleX + circleRadius + 5, y, x + w, y + h, self.style.labelColor, self.style.labelScale, self.style.labelFont, self.style.labelAlignH, self.style.labelAlignV)
        end,
        select = function(self)
            for _, r in ipairs(GridLib.radioButtons) do
                if r.group == self.group then
                    r.selected = false
                end
            end
            self.selected = true
            if self.onSelect then self.onSelect(self) end
        end,
    }
    table.insert(GridLib.radioButtons, radio)
    return radio
end

function GridLib.renderRadioButton(radio)
    if radio and radio.clickable then radio:render() end
end

--------------------------------------------------
-- Global Input Handling for Text Inputs
--------------------------------------------------
addEventHandler("onClientCharacter", root, function(character)
    if GridLib.focusedTextInput and not isConsoleActive() then
        GridLib.focusedTextInput:addCharacter(character)
    end
end)

addEventHandler("onClientKey", root, function(key, pressed)
    if key == "backspace" then
        if pressed then
            if GridLib.focusedTextInput then
                if not GridLib.backspaceTimer then
                    GridLib.focusedTextInput:removeCharacter()
                    GridLib.backspaceTimer = setTimer(function()
                        if GridLib.focusedTextInput then
                            GridLib.focusedTextInput:removeCharacter()
                        end
                    end, 100, 0)
                end
            end
        else
            if GridLib.backspaceTimer then
                killTimer(GridLib.backspaceTimer)
                GridLib.backspaceTimer = nil
            end
        end
    elseif key == "enter" then
        if pressed then
            if GridLib.focusedTextInput then
                if GridLib.focusedTextInput.onEnter then
                    GridLib.focusedTextInput.onEnter(GridLib.focusedTextInput.text)
                end
                GridLib.focusedTextInput:setFocus(false)
            end
        end
    else
        if not pressed then return end
    end
end, true)

--------------------------------------------------
-- Global Click Handling for All Elements
--------------------------------------------------
addEventHandler("onClientClick", root, function(button, state, absX, absY)
    if button == "left" and state == "down" then
        -- Text inputs:
        local clickedOnInput = false
        for _, input in ipairs(GridLib.textInputs) do
            if input.clickable then
                local x, y, w, h = input:getRect()
                if absX >= x and absX <= x + w and absY >= y and absY <= y + h then
                    input:setFocus(true)
                    clickedOnInput = true
                else
                    input:setFocus(false)
                end
            end
        end
        if not clickedOnInput and GridLib.focusedTextInput then
            GridLib.focusedTextInput:setFocus(false)
        end
        -- Checkboxes:
        for _, checkbox in ipairs(GridLib.checkboxes) do
            if checkbox.clickable then
                local x, y, w, h = checkbox:getRect()
                if absX >= x and absX <= x + w and absY >= y and absY <= y + h then
                    checkbox:toggle()
                end
            end
        end
        -- Radio buttons:
        for _, radio in ipairs(GridLib.radioButtons) do
            if radio.clickable then
                local x, y, w, h = radio:getRect()
                if absX >= x and absX <= x + w and absY >= y and absY <= y + h then
                    radio:select()
                end
            end
        end
        -- Divs:
        for _, div in ipairs(GridLib.divs) do
            if div.clickable then
                local x, y, w, h = GridLib.getPixelRect(div.currentSC, div.currentSR, div.currentEC, div.currentER)
                if isInRect(absX, absY, x, y, w, h) then
                    if type(div.onClick) == "function" then
                        div.onClick(div)
                    end
                end
            end
        end
    end
end)

--------------------------------------------------
-- Return the Library
--------------------------------------------------
return GridLib
