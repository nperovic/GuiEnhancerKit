# GuiEnhancerKit
Elevate your AHK Gui development with extended methods and properties.

# Example

```PHP
#Requires AutoHotkey v2.0.15
#Include <GuiEnhancerKit>

WM_LBUTTONDOWN   := 0x0201
WM_SETCURSOR     := 0x0020
WM_NCLBUTTONDOWN := 0x00A1
EN_KILLFOCUS     := 0x0200

myGui := Gui("-Caption +Resize")
myGui.SetFont("cWhite s16", "Segoe UI")
myGui.BackColor := 0x202020

text := myGui.AddText("Backgroundcaa2031 cwhite Center R1.5 0x200 w280 0x4000000", "Rounded Text Control")

/* Set Rounded Control */
text.SetRounded()

myEdit := myGui.Add("Edit", "-WantReturn -TabStop w300 h300 -E0x200 -HScroll -VScroll +Multi +ReadOnly cwhite Background" myGui.BackColor, "123`n456`n789")

myEdit.OnEvent("Focus", (myEdit, *) => (
    DllCall("User32\HideCaret", "ptr", myEdit.hWnd, "int"),
    myEdit.SendMsg(EN_KILLFOCUS)
))

myGui.OnEvent("Size", Size)

/* Registers a function or method to be called whenever the Gui or GuiControl receives the specified message. [Check out the official document for more information.](https://www.autohotkey.com/docs/alpha/lib/GuiOnMessage.htm) */
myGui.OnMessage(WM_LBUTTONDOWN, DragWindow)
myEdit.OnMessage(WM_LBUTTONDOWN, DragWindow)
myEdit.OnMessage(WM_SETCURSOR, SetCursor)

/* Set Dark Titlebar */
myGui.SetDarkTitle()

/* Set Rounded Window (win 11+) */
myGui.SetWindowAttribute(33, 2)

/* Set Titlebar background color the same as the gui background and remove the window border */
myGui.SetWindowColor(, myGui.BackColor, myGui.BackColor)

/* Set Dark ContextMenu */
myGui.SetDarkMenu()

/* Set Edit Control theme */
myEdit.SetTheme("DarkMode_Explorer")

myGui.Show("w300 h300")
myGui.Opt("MinSize")

/* Send Message to the gui or gui control */
myEdit.SendMsg(EN_KILLFOCUS)

Size(GuiObj, MinMax, Width, Height) {
    text.Move(,, newW := Width - (GuiObj.MarginX*2))
    text.SetRounded()
    myEdit.Move(,, newW, Height - GuiObj.MarginY)
}

/**
 * Callback function for `GuiCtrl.OnMessage()` [Check out the official document for more information.](https://www.autohotkey.com/docs/alpha/lib/GuiOnMessage.htm)
 * @param GuiCtrlObj 
 * @param wParam 
 * @param lParam 
 * @param msg 
 * @returns {Integer} 
 */
DragWindow(GuiCtrlObj, wParam, lParam, msg) {
    static WM_NCLBUTTONDOWN := 0x00A1
    PostMessage(WM_NCLBUTTONDOWN, 2,,, GuiCtrlObj is Gui.Control ? GuiCtrlObj.Gui : GuiCtrlObj)
    return 0
}

/**
 * Callback function for `GuiCtrl.OnMessage()` [Check out the official document for more information.](https://www.autohotkey.com/docs/alpha/lib/GuiOnMessage.htm)
 * @param GuiCtrlObj 
 * @param wParam 
 * @param lParam 
 * @param msg 
 * @returns {Integer} 
 */
SetCursor(GuiCtrlObj, wParam, lParam, Msg) {
    static hCursor := DllCall("LoadCursor", "ptr", 0, "ptr", 32512)
    DllCall("SetCursor", "ptr", hCursor, "ptr")
    return 0
}
```
