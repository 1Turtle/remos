local repositoryUrl = "https://raw.githubusercontent.com/MasonGulu/remos/main/"

local function fromURL(url)
    return { url = url }
end

local function fromRepository(url)
    return fromURL(repositoryUrl .. url)
end

local files = {
    icons = {
        ["default_icon_large.blit"] = fromRepository "icons/default_icon_large.blit",
        ["default_icon_small.blit"] = fromRepository "icons/default_icon_small.blit",
        ["worm_icon_large.blit"] = fromRepository "icons/worm_icon_large.blit",
        ["worm_icon_small.blit"] = fromRepository "icons/worm_icon_small.blit",
        ["eod_icon_large.blit"] = fromRepository "icons/eod_icon_large.blit",
        ["eod_icon_small.blit"] = fromRepository "icons/eod_icon_small.blit",
        ["iconedit_icon_large.blit"] = fromRepository "icons/iconedit_icon_large.blit",
        ["iconedit_icon_small.blit"] = fromRepository "icons/iconedit_icon_small.blit",
        ["unknown_icon_large.blit"] = fromRepository "icons/unknown_icon_large.blit",
        ["unknown_icon_small.blit"] = fromRepository "icons/unknown_icon_small.blit",
        ["settings_icon_small.blit"] = fromRepository "icons/settings_icon_small.blit",
        ["settings_icon_large.blit"] = fromRepository "icons/settings_icon_large.blit",
        ["taskmon_icon_small.blit"] = fromRepository "icons/taskmon_icon_small.blit",
        ["taskmon_icon_large.blit"] = fromRepository "icons/taskmon_icon_large.blit",
        ["shell_icon_small.blit"] = fromRepository "icons/shell_icon_small.blit",
        ["shell_icon_large.blit"] = fromRepository "icons/shell_icon_large.blit",
        ["browser_icon_large.blit"] = fromRepository "icons/browser_icon_large.blit",
        ["browser_icon_small.blit"] = fromRepository "icons/browser_icon_small.blit"
    },
    remos = {
        ["home.lua"] = fromRepository "remos/home.lua",
        ["init.lua"] = fromRepository "remos/init.lua",
        ["kernel.lua"] = fromRepository "remos/kernel.lua",
        ["menu.lua"] = fromRepository "remos/menu.lua",
        ["popup.lua"] = fromRepository "remos/popup.lua",
        ["taskmon.lua"] = fromRepository "remos/taskmon.lua",
        ["settings.lua"] = fromRepository "remos/settings.lua"
    },
    libs = {
        touchui = {
            ["containers.lua"] = fromRepository "libs/touchui/containers.lua",
            ["init.lua"] = fromRepository "libs/touchui/init.lua",
            ["input.lua"] = fromRepository "libs/touchui/input.lua",
            ["lists.lua"] = fromRepository "libs/touchui/lists.lua",
            ["popups.lua"] = fromRepository "libs/touchui/popups.lua",
        },
        ["fe.lua"] = fromRepository "libs/fe.lua",
        ["draw.lua"] = fromRepository "libs/draw.lua",
        ["bigfont.lua"] = fromURL "https://pastebin.com/raw/3LfWxRWh"
    },
    config = {
        ["home_apps.table"] = fromRepository "config/home_apps.table",
    },
    themes = {
        ["advanced.theme"] = fromRepository "themes/advanced.theme"
    },
    apps = {
        ["eod.lua"] = fromRepository "apps/eod.lua",
        ["browser.lua"] = fromRepository "apps/browser.lua",
        ["iconedit.lua"] = fromRepository "apps/iconedit.lua",
    },
    ["startup.lua"] = fromRepository "startup.lua"
}
local function downloadFile(path, url)
    local response = assert(http.get(url, nil, true), "Failed to get " .. url)
    local writeFile = true
    if writeFile then
        local f = assert(fs.open(path, "wb"), "Cannot open file " .. path)
        f.write(response.readAll())
        f.close()
    end
    response.close()
end

local function printBar(percentage)
    term.clearLine()
    local w = term.getSize()
    local filledw = math.ceil(percentage * (w - 2))
    local bar = "[" .. ("*"):rep(filledw) .. (" "):rep(w - filledw - 2) .. "]"
    print(bar)
end

local function count(t)
    local i = 0
    for _, _ in pairs(t) do
        i = i + 1
    end
    return i
end

local function printProgress(y, path, percent)
    term.setCursorPos(1, y)
    printBar(percent)
    term.clearLine()
    print(path)
end

local function downloadFiles(folder, files)
    local total = count(files)
    local filen = 0
    local _, y = term.getCursorPos()
    for k, v in pairs(files) do
        filen = filen + 1
        local path = fs.combine(folder, k)
        printProgress(y, path, filen / total)
        if v.url then
            downloadFile(path, v.url)
        else
            fs.makeDir(path)
            downloadFiles(path, v)
        end
    end
    term.setCursorPos(1, y)
    term.clearLine()
    term.setCursorPos(1, y + 1)
    term.clearLine()
end

term.clear()
term.setCursorPos(1, 1)
print("This will install Remos on this device, overwriting files if necessary.")
print("Do you want to continue (Y/n)? ")
local input = read()
if input:sub(1, 1):lower() == "n" then
    print("Cancelled installation.")
    return
end
print("Installing Remos...")

downloadFiles("/", files)

print("Remos installed, rebooting...")
sleep(1)
os.reboot()
