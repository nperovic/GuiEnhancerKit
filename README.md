# GuiEnhancerKit
Elevate your AHK Gui development with extended methods and properties.

# Example

### Include the library in your script.
```AUTOIT
#Requires AutoHotkey v2
#Include <GuiEnhancerKit>
```

### **IMPORTANT**: To ensure proper functioning of VSCode's Intelligence, annotate the variable type as GuiExt above the line where you create a new Gui object instance. Like this:
> ![image](https://github.com/nperovic/GuiEnhancerKit/assets/122501303/8b7942c1-5805-4c64-b955-d8aa1d782cc0)

```PHP
/** @var {GuiExt} myGui */
myGui := Gui("-Caption +Resize")
```

### Gui Control objects created in this way do not work with VSCode's IntelliSense. 
> Like these: `myGui.AddText`, `myGui.AddEdit`, `myGui.AddPic`, etc.
```PHP
text := myGui.AddText("Backgroundcaa2031 cwhite Center R1.5 0x200 w280", "Rounded Text Control")
```

### To get VSCode's IntelliSense works, create Gui Control objects with `Add` method: 
> Like this: `Gui.Add('ControlType')`  
> ![image](https://github.com/nperovic/GuiEnhancerKit/assets/122501303/8decc18c-57e0-47a7-8ee7-ebef7e4845d4)

```PHP
myEdit := myGui.Add("Edit", "-WantReturn -TabStop w300 h150 -E0x200 -HScroll -VScroll +Multi +ReadOnly cwhite Background" myGui.BackColor)
myEdit.SetFont(, "Consolas")
```

### Set the control's border style to rounded corners. The radius of the rounded corners is set to `9` in this case.
> ![image](https://github.com/nperovic/GuiEnhancerKit/assets/122501303/0ebff7a5-f3cf-45a3-9059-6bb62f8960f8)

```PHP
text.SetRounded(9)
```

### To get/ set the Gui or Gui Control's position and size.
```PHP
/* Get the current gui position. */
myEdit.UpdatePos := ctrl => (ctrl.Value := 
(
    "x: " myGui.X "
    y: " myGui.Y "
    w: " myGui.W "
    h: " myGui.H
))

myGui.OnEvent("Size", Size)

/**
 * @param {GuiExt|Gui} GuiObj 
 * @param {Integer} MinMax 
 * @param {Integer} Width 
 * @param {Integer} Height 
 */
Size(GuiObj, MinMax, Width, Height) {
    Critical("Off")
    SetWinDelay(-1), SetControlDelay(-1)

    /* Moving Controls */
    myEdit.W := text.W := Width - (GuiObj.MarginX*2)
    myEdit.H := Height - (GuiObj.MarginY*2)
    text.SetRounded()
    myEdit.UpdatePos()
}
```

### Registers a function or method to be called whenever the Gui or GuiControl receives the specified message. [Learn more](https://github.com/nperovic/GuiEnhancerKit/wiki#onmessage)

```PHP
WM_LBUTTONDOWN   := 0x0201
WM_SETCURSOR     := 0x0020
WM_MOVING        := 0x0216

myGui.OnMessage(WM_LBUTTONDOWN, DragWindow)
myEdit.OnMessage(WM_SETCURSOR, SetCursor)
myGui.OnMessage(WM_MOVING, (*) => myEdit.UpdatePos())

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

### Sets the dark mode title bar for the window if the operating system version supports it.
```PHP
myGui.SetDarkTitle()
```

### Calls the `SetWindowAttribute` method to set Rounded Corners.  
> Requires Windows 11.  
> [Learn more on MSDN](https://learn.microsoft.com/en-us/windows/win32/api/dwmapi/nf-dwmapi-dwmsetwindowattribute)  
> ![image](https://github.com/nperovic/GuiEnhancerKit/assets/122501303/ed1a147e-4dea-402e-917a-028555bafb8c)

```PHP
myGui.SetWindowAttribute(33, 2)
```

### To set the title bar background color to match the GUI background and remove the window border.
```PHP
myGui.SetWindowColor(, myGui.BackColor, myGui.BackColor)
```

### To set the dark mode context menus.
```PHP
myGui.SetDarkMenu()
```

### Set dark mode edit control.
```PHP
myEdit.SetTheme("DarkMode_Explorer")
```

### Send Message to the gui or gui control
```PHP
EN_KILLFOCUS := 0x0200
myEdit.SendMsg(EN_KILLFOCUS)
```
