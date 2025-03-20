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

; Start monitoring every 500ms
SetTimer(CheckForButton, 500)
Return

; === Function: CheckForButton ===
CheckForButton() {
    static lastFound := ""  ; Store last found button in memory (reduces INI reads/writes)

    if !WinExist("Claude")  ; Ensure the target window exists.
        return

    CoordMode("Pixel", "Screen")
    CoordMode("Mouse", "Screen")

    global buttonVariants, searchVariation, iniFile, section, key, lastButton

    ; Swap the last used button to the front of the list (instead of cloning)
    if (buttonVariants[1].Name != lastButton) {
        Loop buttonVariants.Length {
            if (buttonVariants[A_Index].Name = lastButton) {
                temp := buttonVariants[A_Index]
                buttonVariants[A_Index] := buttonVariants[1]
                buttonVariants[1] := temp
                break
            }
        }
    }

    foundData := FindButton(buttonVariants, searchVariation)

    if (foundData) {
        if (foundData.Name != lastFound) {  ; Update INI only if it changes
            lastFound := foundData.Name
            IniWrite(lastFound, iniFile, section, key)
        }

        ; Temporarily stop the timer to prevent multiple clicks
        SetTimer(CheckForButton, 0)

        ClickButton(foundData.x + foundData.offsetX, foundData.y + foundData.offsetY)

        ; Restart the timer after a short delay
        SetTimer(CheckForButton, -1000)
    }
}

; === Function: FindButton ===
FindButton(variants, variation) {
    for variant in variants {
        if !FileExist(variant.Image)
            continue

        local foundX, foundY

        ; Limit search area if possible (replace values accordingly)
        x1 := 0, y1 := 0, x2 := A_ScreenWidth, y2 := A_ScreenHeight

        if (ImageSearch(&foundX, &foundY, x1, y1, x2, y2, variation . variant.Image) = 0) {
            return { x: foundX, y: foundY, offsetX: variant.offsetX, offsetY: variant.offsetY, Name: variant.Name }
        }
    }
    return
}

; === Function: ClickButton ===
ClickButton(x, y) {
    orig := MouseGetPos()

    ; Faster, more human-like movement
    MouseMove(x + 10, y + 10, 10)
    Sleep(50)
    MouseMove(x, y, 10)
    Sleep(50)

    Click(x, y)

    ; Restore original mouse position
    MouseMove(orig.x, orig.y, 10)
}