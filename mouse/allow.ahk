SetTitleMatchMode 2  ; Removed comma
SetWorkingDir A_ScriptDir  ; Changed syntax, no % needed

; Path to button image
ImagePath := "allow_for_this_chat.png"

; Check every second
SetTimer CheckForButton, 1000
return

CheckForButton()
{
    if WinExist("Claude")  ; Only run if Claude is open
    {
        CoordMode "Pixel", "Screen"  ; Changed syntax
        CoordMode "Mouse", "Screen"  ; Changed syntax

        ; Search for the button
        if ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, "*100 " ImagePath)  ; Changed syntax, added &
        {
            ; Center offsets (adjust if needed)
            CenterOffsetX := 82
            CenterOffsetY := 18

            ; Calculate exact center
            CenterX := FoundX + CenterOffsetX
            CenterY := FoundY + CenterOffsetY

            ; Store current mouse position
            MouseGetPos &OriginalX, &OriginalY  ; Changed syntax, added &

            ; Move the mouse to prevent bot detection
            MouseMove CenterX + 20, CenterY + 20, 0  ; 
            Sleep 100  ; Removed comma
            MouseMove CenterX, CenterY, 0  ; 
            Sleep 100  ; Removed comma

            ; Click the button
            Click CenterX, CenterY  ; 

            ; Restore original mouse position
            MouseMove OriginalX, OriginalY, 0  ; 
        }
    }
}