#Persistent
SetTitleMatchMode(2)  ; Allow partial match of window title.
SetWorkingDir(A_ScriptDir)  ; Set working directory to the script's folder.

; === Persistent Storage ===
iniFile := "settings.ini"
section := "Preferences"
key := "LastButton"

; Define button variants for different themes/sizes.
global buttonVariants := [
    { Image: "allow_light.png", Name: "Light", offsetX: 82, offsetY: 18 },
    { Image: "allow_dark.png",  Name: "Dark",  offsetX: 82, offsetY: 18 }
]

; Global image search tolerance (adjust as needed).
global searchVariation := "*100 "

; Read last used button from INI file (default to "Light" if not found)
IniRead(lastButton, iniFile, section, key, "Light")

; Start monitoring
SetTimer(CheckForButton, 500) ; Check every 500 ms
Return

; === Function: CheckForButton ===
CheckForButton() {
    if !WinExist("Claude")  ; Ensure the target window exists.
        return

    CoordMode("Pixel", "Screen")
    CoordMode("Mouse", "Screen")

    global buttonVariants, searchVariation, iniFile, section, key, lastButton

    ; Prioritize searching for the last used button first
    prioritizedVariants := buttonVariants.Clone()  ; Create a copy of the array
    for index, variant in buttonVariants {
        if (variant.Name = lastButton) {
            prioritizedVariants.RemoveAt(index)  ; Remove from its current position
            prioritizedVariants.InsertAt(1, variant)  ; Move it to the front
            break
        }
    }

    foundData := FindButton(prioritizedVariants, searchVariation)

    if (foundData && foundData.Name != lastButton) {  ; Update INI only if it changes
        lastButton := foundData.Name
        IniWrite(lastButton, iniFile, section, key)
    }

    if (foundData) {
        ClickButton(foundData.x + foundData.offsetX, foundData.y + foundData.offsetY)
    }
}

; === Function: FindButton ===
FindButton(variants, variation) {
    for variant in variants {
        if !FileExist(variant.Image)
            continue

        local foundX, foundY
        if (ImageSearch(&foundX, &foundY, 0, 0, A_ScreenWidth, A_ScreenHeight, variation . variant.Image) = 0) {
            return { x: foundX, y: foundY, offsetX: variant.offsetX, offsetY: variant.offsetY, Name: variant.Name }
        }
    }
    return
}

; === Function: ClickButton ===
ClickButton(x, y) {
    orig := MouseGetPos()
    MouseMove(x + 20, y + 20, 0)
    Sleep(100)
    MouseMove(x, y, 0)
    Sleep(100)
    Click(x, y)
    MouseMove(orig.x, orig.y, 0)
}