--[[
    InterfaceLib Example - Executor Version
    完整示例，展示所有功能

    使用方法：
    1. 先加载库：loadstring(game:HttpGet("YOUR_URL/InterfaceLib_Injector.lua"))()
    2. 然后加载此示例：loadstring(game:HttpGet("YOUR_URL/Example_Injector.lua"))()

    或者直接复制粘贴到 executor 执行
]]

-- 假设 InterfaceLib 已经加载到全局
local InterfaceLib = getgenv().InterfaceLib or _G.InterfaceLib

if not InterfaceLib then
    error("[Example] InterfaceLib not found! Please load InterfaceLib_Injector.lua first.")
end

print("[Example] Creating interface...")

-- 创建界面实例
local window = InterfaceLib.new({
    accent = Color3.fromHex("80adfa"),  -- 冰蓝强调色
    radius = 12,                         -- 圆角大小
    speed = 1.0,                         -- 动画速度
})

-- 添加 Core 模块
window:addModule({
    id = "core",
    icon = "settings",
    label = "Core",
    pages = {
        {
            name = "General",
            sections = {
                {
                    title = "GENERAL PREFERENCES",
                    controls = {
                        {
                            type = "toggle",
                            label = "Enable module",
                            detail = "Turn on to activate core features.",
                            default = true
                        },
                        {
                            type = "slider",
                            label = "Sensitivity",
                            default = 65
                        },
                        {
                            type = "matrix",
                            label = "Mode",
                            options = {"Balanced", "Precision", "Dynamic", "Nearest", "Focused", "Adaptive"},
                            default = "Balanced"
                        }
                    }
                }
            }
        },
        {
            name = "Advanced",
            sections = {
                {
                    title = "ADVANCED SETTINGS",
                    controls = {
                        {
                            type = "toggle",
                            label = "Debug mode",
                            detail = "Show debug information.",
                            default = false
                        },
                        {
                            type = "slider",
                            label = "Update rate",
                            default = 60
                        }
                    }
                }
            }
        }
    }
})

-- 添加 Tools 模块
window:addModule({
    id = "tools",
    icon = "wrench",
    label = "Tools",
    pages = {
        {
            name = "Utilities",
            sections = {
                {
                    title = "TOOL PREFERENCES",
                    controls = {
                        {
                            type = "toggle",
                            label = "Auto-save",
                            detail = "Automatically save changes.",
                            default = true
                        },
                        {
                            type = "slider",
                            label = "Grid size",
                            default = 50
                        },
                        {
                            type = "matrix",
                            label = "Tool preset",
                            options = {"Default", "Compact", "Expanded", "Custom"},
                            default = "Default"
                        }
                    }
                }
            }
        }
    }
})

-- 添加 Workspace 模块
window:addModule({
    id = "workspace",
    icon = "layers",
    label = "Workspace",
    pages = {
        {
            name = "Layout",
            sections = {
                {
                    title = "LAYOUT SETTINGS",
                    controls = {
                        {
                            type = "toggle",
                            label = "Snap to grid",
                            detail = "Align objects to grid.",
                            default = false
                        },
                        {
                            type = "slider",
                            label = "Spacing",
                            default = 40
                        },
                        {
                            type = "matrix",
                            label = "Arrangement",
                            options = {"Compact", "Comfortable", "Spacious"},
                            default = "Comfortable"
                        }
                    }
                }
            }
        }
    }
})

-- 监听控件变化
window:onChanged(function(path, value)
    print(string.format("[InterfaceLib] %s = %s", path, tostring(value)))
end)

-- 显示界面
window:show()

-- 键盘控制
local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end

    if input.KeyCode == Enum.KeyCode.Insert then
        window:toggle()
        print("[Example] Interface toggled")
    end
end)

-- 存储到全局，方便控制台调试
getgenv().InterfaceWindow = window
_G.InterfaceWindow = window

print("===========================================")
print("[Example] Interface loaded successfully!")
print("===========================================")
print("Press INSERT to toggle interface")
print("Press ESC to close window")
print("===========================================")
print("Debug commands:")
print("  _G.InterfaceWindow:show()")
print("  _G.InterfaceWindow:hide()")
print("  _G.InterfaceWindow:getState()")
print("===========================================")
