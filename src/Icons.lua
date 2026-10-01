--[[
    Icons
    Embedded lucide-icons subset for the interface
]]

local Icons = {}

-- Icon data (SVG path strings)
local iconPaths = {
    settings = "M12.22 2h-.44a2 2 0 0 0-2 2v.18a2 2 0 0 1-1 1.73l-.43.25a2 2 0 0 1-2 0l-.15-.08a2 2 0 0 0-2.73.73l-.22.38a2 2 0 0 0 .73 2.73l.15.1a2 2 0 0 1 1 1.72v.51a2 2 0 0 1-1 1.74l-.15.09a2 2 0 0 0-.73 2.73l.22.38a2 2 0 0 0 2.73.73l.15-.08a2 2 0 0 1 2 0l.43.25a2 2 0 0 1 1 1.73V20a2 2 0 0 0 2 2h.44a2 2 0 0 0 2-2v-.18a2 2 0 0 1 1-1.73l.43-.25a2 2 0 0 1 2 0l.15.08a2 2 0 0 0 2.73-.73l.22-.39a2 2 0 0 0-.73-2.73l-.15-.08a2 2 0 0 1-1-1.74v-.5a2 2 0 0 1 1-1.74l.15-.09a2 2 0 0 0 .73-2.73l-.22-.38a2 2 0 0 0-2.73-.73l-.15.08a2 2 0 0 1-2 0l-.43-.25a2 2 0 0 1-1-1.73V4a2 2 0 0 0-2-2z M12 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6z",

    grid = "M3 3h7v7H3z M14 3h7v7h-7z M14 14h7v7h-7z M3 14h7v7H3z",

    box = "M21 8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16Z M3.3 7l8.7 5 8.7-5 M12 22V12",

    wrench = "M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z",

    layers = "M12.83 2.18a2 2 0 0 0-1.66 0L2.6 6.08a1 1 0 0 0 0 1.83l8.58 3.91a2 2 0 0 0 1.66 0l8.58-3.9a1 1 0 0 0 0-1.83Z M22 17.65l-9.17 4.16a2 2 0 0 1-1.66 0L2 17.65 M22 12.65l-9.17 4.16a2 2 0 0 1-1.66 0L2 12.65",

    palette = "M13.73 4a2 2 0 0 0-3.46 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3Z M12 9v4 M12 17h.01",

    sliders = "M4 21v-7 M4 10V3 M12 21v-9 M12 8V3 M20 21v-5 M20 12V3 M2 14h4 M10 8h4 M18 16h4",

    zap = "M13 2L3 14h9l-1 8 10-12h-9l1-8z",

    crosshair = "M22 12h-4 M6 12H2 M12 6V2 M12 22v-4 M12 17a5 5 0 1 0 0-10 5 5 0 0 0 0 10z",

    layout = "M3 3h7v9H3z M14 3h7v5h-7z M14 12h7v9h-7z M3 16h7v5H3z",

    check = "M20 6L9 17l-5-5",

    minus = "M5 12h14",
}

-- Create an icon ImageLabel
function Icons.create(name, size)
    size = size or 16

    local pathData = iconPaths[name]
    if not pathData then
        warn("Icon not found:", name)
        return nil
    end

    -- For Roblox, we'll use TextLabels with unicode symbols as a fallback
    -- In a real implementation, you'd use EditableImage or external icon service
    local symbolMap = {
        settings = "⚙",
        grid = "▦",
        box = "📦",
        wrench = "🔧",
        layers = "⧉",
        palette = "🎨",
        sliders = "⫼",
        zap = "⚡",
        crosshair = "⊕",
        layout = "▦",
        check = "✓",
        minus = "−",
    }

    local icon = Instance.new("TextLabel")
    icon.Name = "Icon_" .. name
    icon.Size = UDim2.new(0, size, 0, size)
    icon.BackgroundTransparency = 1
    icon.Text = symbolMap[name] or "●"
    icon.TextSize = size
    icon.Font = Enum.Font.GothamMedium
    icon.TextColor3 = Color3.fromRGB(134, 152, 177)

    return icon
end

-- Get icon symbol only
function Icons.getSymbol(name)
    local symbolMap = {
        settings = "⚙",
        grid = "▦",
        box = "📦",
        wrench = "🔧",
        layers = "⧉",
        palette = "🎨",
        sliders = "⫼",
        zap = "⚡",
        crosshair = "⊕",
        layout = "▦",
        check = "✓",
        minus = "−",
    }
    return symbolMap[name] or "●"
end

return Icons
