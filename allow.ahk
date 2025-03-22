#Requires AutoHotkey v2
SetTitleMatchMode(2)
SetWorkingDir(A_ScriptDir)


; === GLOBALS ===
global theme := "dark"  ; Change (light/dark)
global imagePath := "allow_" theme ".png"
global winTitle := "Claude"  ; Change to your target window title (application, e.g. Claude or Paint 3D for testing)

global offsetX := 82
global offsetY := 18

; === TRAY SETUP ===
TraySetIcon("shell32.dll", 44)

CoordMode("Pixel", "Screen")
CoordMode("Mouse", "Screen")

; === ENTRY POINT ===
CheckForButton()
return

; === MAIN FUNCTIONALITY ===

CheckForButton() {
    if !WinExist(winTitle) {
        ; ToolTip("Window not found: " winTitle)
        SetTimer(CheckForButton, -1000)
        return
    }

    area := getClientArea(winTitle)
    if !area {
        ; ToolTip("Could not get client area")
        SetTimer(CheckForButton, -1000)
        return
    }

    box := getScanBox(area)
    coords := searchImage(box)
    if !coords {
        SetTimer(CheckForButton, -1000)
        return
    }

    clickImage(coords.x, coords.y)
    ; ToolTip("Waiting 5 seconds before next scan...")
    SetTimer(CheckForButton, -5000)
}

getClientArea(winTitle) {
    hwnd := WinExist(winTitle)
    rc := Buffer(16, 0)

    if !DllCall("GetClientRect", "ptr", hwnd, "ptr", rc)
        return false
    if !DllCall("ClientToScreen", "ptr", hwnd, "ptr", rc)
        return false

    left   := NumGet(rc, 0, "int")
    top    := NumGet(rc, 4, "int")
    right  := left + NumGet(rc, 8, "int")
    bottom := top + NumGet(rc, 12, "int")
    width  := right - left
    height := bottom - top

    return {left: left, top: top, right: right, bottom: bottom, width: width, height: height}
}

getScanBox(area) {
    cropTop := area.top + Round(area.height * 0.15)
    cropBottom := area.bottom - Round(area.height * 0.15)
    return {left: area.left, top: cropTop, right: area.right, bottom: cropBottom}
}

searchImage(box) {
    local foundX := 0, foundY := 0

    try {
        ImageSearch(&foundX, &foundY, box.left, box.top, box.right, box.bottom, "*100 " . imagePath)
    } catch {
        ; ToolTip("ImageSearch error")
        return false
    }

    if (foundX == "" || foundY == "") || (foundX == 0 && foundY == 0) {
        ; ToolTip("ImageSearch returned empty string or 0,0")
        return false
    }

    ; ToolTip("Image found at: " foundX ", " foundY)
    return {x: foundX + offsetX, y: foundY + offsetY}
}

clickImage(x, y) {
    try {
        MouseGetPos(&origX, &origY)

        rX := Random(-16, 16)
        rY := Random(-6, 6)
        x += rX
        y += rY

        MouseMove(x, y, 5)
        Sleep(50)
        Click(x, y)
        Sleep(50)

        ; ToolTip("Image clicked at: " x ", " y " (randomized)")
        MouseMove(origX, origY, 5)
    } catch Error as e {
        try FileAppend("[" A_Now "] Crash: " e.Message "`n", A_ScriptDir "\debug.log", "UTF-8")
    }
}


