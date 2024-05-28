# GuiEnhancerKit
Elevate your AHK Gui development with extended methods and properties. This library provides a set of extended methods and properties to enhance your AutoHotkey Gui development experience.

## Getting Started

### Including the library in your script
```AUTOIT
#Requires AutoHotkey v2
#Include <GuiEnhancerKit>
```

### Using VSCode's Intelligence
> ![image](https://github.com/nperovic/GuiEnhancerKit/assets/122501303/8b7942c1-5805-4c64-b955-d8aa1d782cc0)
> ![image](https://github.com/nperovic/GuiEnhancerKit/assets/122501303/8decc18c-57e0-47a7-8ee7-ebef7e4845d4)

To ensure proper functioning of VSCode's Intelligence, you can:
1. Replace `Gui` object with `GuiExt`. (Recommended)
```CPP
myGui := GuiExt("-Caption +Resize")
```
2. Annotate the variable type as GuiExt above the line where you create a new Gui object instance.
```js
/** @var {GuiExt} myGui */
myGui := Gui("-Caption +Resize")
```

## Features

### `GuiControl.SetRounded(corner := 9)`  
> ![image](https://github.com/nperovic/GuiEnhancerKit/assets/122501303/0ebff7a5-f3cf-45a3-9059-6bb62f8960f8)  

This method sets the control's border style to rounded corners. The radius of the rounded corners is set to `9` in this case.  
```PHP
text.SetRounded(9)
```

### GuiOrControl.X/ GuiOrControl.Y/ GuiOrControl.W/ GuiOrControl.H
These properties allow you to get or set the Gui or Gui Control's position and size.
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

### Gui.OnMessage(Msg, Callback, MaxThreads := 1)
### GuiControl.OnMessage(Msg, Callback, AddRemove := 1)
This method registers a function or method to be called whenever the Gui or GuiControl receives the specified message. [Learn more](https://github.com/nperovic/GuiEnhancerKit/wiki#onmessage)
```PHP
WM_LBUTTONDOWN   := 0x0201
WM_SETCURSOR     := 0x0020
WM_MOVING        := 0x0216

myGui.OnMessage(WM_LBUTTONDOWN, DragWindow)
myEdit.OnMessage(WM_SETCURSOR, SetCursor)
myGui.OnMessage(WM_MOVING, (*) => myEdit.UpdatePos())

/**
 * Callback function for `GuiCtrl.OnMessage()`
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
 * Callback function for `GuiCtrl.OnMessage()`
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

### SetDarkTitle()
This method sets the dark mode title bar for the window if the operating system version supports it.
```PHP
myGui.SetDarkTitle()
```

### Gui.SetWindowAttribute(dwAttribute, pvAttribute?)
This method calls the `DwmSetWindowAttribute` function from the dwmapi library to set attributes of a window.
> Requires Windows 11.  
> [Learn more on MSDN](https://learn.microsoft.com/en-us/windows/win32/api/dwmapi/nf-dwmapi-dwmsetwindowattribute)  
> ![image](https://github.com/nperovic/GuiEnhancerKit/assets/122501303/ed1a147e-4dea-402e-917a-028555bafb8c)
```PHP
/* To set Rounded Corners for window. */
myGui.SetWindowAttribute(33, 2)
```

### SetWindowColor(titleText?, titleBackground?, border?)
This method sets the title bar background color to match the GUI background and removes the window border.
```PHP
myGui.SetWindowColor(, myGui.BackColor, myGui.BackColor)
```

### SetDarkMenu()
This method sets the dark mode context menus.
```PHP
myGui.SetDarkMenu()
```

### SetTheme(pszSubAppName, pszSubIdList := "")
Applies a specified theme to the window through the SetWindowTheme function from the uxtheme library.
```PHP
/* This example sets dark mode edit control.*/
myEdit.SetTheme("DarkMode_Explorer")
```

### SendMsg(Msg, wParam := 0, lParam := 0)
This method sends a message to the gui or gui control.
```PHP
EN_KILLFOCUS := 0x0200
myEdit.SendMsg(EN_KILLFOCUS)
```

