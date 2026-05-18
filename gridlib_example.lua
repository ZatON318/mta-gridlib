local origSC, origSR, origEC, origER = 0, 0, 2, 2

local loginVisible = false

GridLib.config = {
    gridCountX = 60,   -- počet stĺpcov
    gridCountY = 30,   -- počet riadkov
    gap        = 5,    -- medzera (v pixeloch) medzi bunkami
    edgeMargin = 20    -- okraj (v pixeloch) od okrajov obrazovky
}

-- Create the animated rectangle (using inclusive coordinates)
myRect = GridLib.createAnimatedRect(origSC, origSR, origEC, origER, tocolor(32, 32, 33, 255))

local myLoader = GridLib.createLoadingIndicator(10, 5, 20, 8, {
    bgColor = tocolor(0, 0, 0, 150),
    text = "Loading…",
    textColor = tocolor(255,255,255,255),
    textScale = 1.2,
    textFont = "default-bold",
    rotationSpeed = 180,  -- degrees per second
})


-- Create the Expand button using the simpler API:
expandClick = GridLib.createButton(origSC, origSR, origEC, origER, "+", 
    function(self)
        local duration = 200
        myRect:startAnimation(0, 0, GridLib.config.gridCountX - 1, GridLib.config.gridCountY - 1, duration)
        self.enabled = false       -- disable the expand button after click
        if minimizeClick then
            minimizeClick.enabled = true  -- enable the minimize button
        end

        setTimer(function()
            loginVisible = true
        end, duration, 1)
    end)

-- Create the Minimize button using the simplified syntax:
minimizeClick = GridLib.createButton(GridLib.config.gridCountX - 2, 0,
    GridLib.config.gridCountX - 1, 1,
    "-", function(self)
        local duration = 200
        if myRect and not myRect.isActive then
            -- Animate the rectangle back to its original size.
            myRect:startAnimation(origSC, origSR, origEC, origER, duration)
            loginVisible = false
            self.enabled = false  -- disable minimize button after click
            setTimer(function()
                if expandClick then
                    expandClick.enabled = true
                end
            end, duration, 1)
        end
    end)

    myTextInput = GridLib.createTextInput(25, 9, 34, 10, "", 
        function(newText)
            outputChatBox("Text changed: " .. newText)
        end,
        function(text)
            outputChatBox("Entered: " .. text)
        end,
        {
            bgColor = tocolor(42, 42, 43, 255),
            borderColor = tocolor(51, 51, 53, 0),
            borderColorFocused = tocolor(61, 61, 63, 0),
            textColor = tocolor(255, 255, 255, 255),
            font = "default-bold",
            textScale = 1,
            borderWidth = 0,
            textPadding = 8,
            textAlignH = "left",
            textAlignV = "center",
            placeholder = "Type here...",
            placeholderColor = tocolor(255, 255, 255, 180),
            inputType = "password"
        }
    )

    myTextInput2 = GridLib.createTextInput(25, 11, 34, 12, "",
        function(newText)
            outputChatBox("Text changed: " .. newText)
        end,
        function(text)
            outputChatBox("Entered: " .. text)
        end,
        {
            bgColor = tocolor(42, 42, 43, 255),
            borderColor = tocolor(51, 51, 53, 0),
            borderColorFocused = tocolor(61, 61, 63, 0),
            textColor = tocolor(255, 255, 255, 255),
            font = "default-bold",
            textScale = 1,
            borderWidth = 0,
            textPadding = 8,
            textAlignH = "left",    -- horizontal alignment: "left", "center", or "right"
            textAlignV = "center",  -- vertical alignment: "top", "center", or "bottom"
            placeholder = "Type here...",
            placeholderColor = tocolor(255, 255, 255, 180),
        }
    )

    myRadio1 = GridLib.createRadioButton({
        startCol = 5, startRow = 10, endCol = 7, endRow = 10,
        label = "Option 1", group = "myGroup",
        selected = false,
        circleBgColor = tocolor(240,240,240,255),
        circleBorderColor = tocolor(120,120,120,255),
        selectedColor = tocolor(255,0,0,255),
        labelColor = tocolor(0,0,0,255)
    })

    myRadio2 = GridLib.createRadioButton({
        startCol = 5, startRow = 11, endCol = 5, endRow = 11,
        label = "Option 1", group = "myGroup",
        selected = false,
        circleBgColor = tocolor(240,240,240,255),
        circleBorderColor = tocolor(120,120,120,255),
        selectedColor = tocolor(255,0,0,255),
        labelColor = tocolor(0,0,0,255)
    })

    myCheckbox = GridLib.createCheckbox({
        startCol = 5, startRow = 12, endCol = 7, endRow = 12,
        label = "I agree", checked = false,
        boxBgColor = tocolor(255,255,255,255),
        boxBorderColor = tocolor(0,0,0,255),
        checkColor = tocolor(0,200,0,255),
        labelColor = tocolor(0,0,0,255)
    })


function onClientRenderHandler()
    --GridLib.renderGrid()
    GridLib.renderRect(2, 2, 3, 3, tocolor(0, 0, 0, 250))
    GridLib.renderAnimatedRects()

    GridLib.renderButton(expandClick)
    GridLib.renderButton(minimizeClick)

    -- Render all text input fields
    if loginVisible then
        GridLib.renderTextInput(myTextInput)
        GridLib.renderTextInput(myTextInput2)
        GridLib.renderRadioButton(myRadio1)
        GridLib.renderRadioButton(myRadio2)
        GridLib.renderCheckbox(myCheckbox)
    end
    GridLib.renderLoader(myLoader)


end
addEventHandler("onClientRender", root, onClientRenderHandler)
