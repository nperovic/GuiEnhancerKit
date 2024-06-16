# GuiEnhancerKit
Elevate your AHK Gui development with extended methods and properties. This library provides a set of extended methods and properties to enhance your AutoHotkey Gui development experience.

🌍Other Language: [中文](README_zh-tw.md)  

## Getting Started

### Including the library in your script
```AUTOIT
#Requires AutoHotkey v2
#Include <GuiEnhancerKit>
```

### Using VSCode's IntelliSence
> ![image](https://github.com/nperovic/GuiEnhancerKit/assets/122501303/8b7942c1-5805-4c64-b955-d8aa1d782cc0)
> ![image](https://github.com/nperovic/GuiEnhancerKit/assets/122501303/8decc18c-57e0-47a7-8ee7-ebef7e4845d4)

To ensure proper functioning of VSCode's IntelliSence, you can:
1. 替换 `Gui` object with `GuiExt`. (Recommended)
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

### `GuiOrControl.X`/ `GuiOrControl.Y`/ `GuiOrControl.W`/ `GuiOrControl.H`
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

### `Gui.OnMessage(Msg, Callback, MaxThreads := 1)`  
### `GuiControl.OnMessage(Msg, Callback, AddRemove := 1)`
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

### `Gui.SetDarkTitle()`
This method sets the dark mode title bar for the window if the operating system version supports it.
```PHP
myGui.SetDarkTitle()
```

### `Gui.SetWindowAttribute(dwAttribute, pvAttribute?)`
This method calls the `DwmSetWindowAttribute` function from the dwmapi library to set attributes of a window.
> Requires Windows 11.  
> [Learn more on MSDN](https://learn.microsoft.com/en-us/windows/win32/api/dwmapi/nf-dwmapi-dwmsetwindowattribute)  
> ![image](https://github.com/nperovic/GuiEnhancerKit/assets/122501303/ed1a147e-4dea-402e-917a-028555bafb8c)
```PHP
/* To set Rounded Corners for window. */
myGui.SetWindowAttribute(33, 2)
```

### `Gui.SetWindowColor(titleText?, titleBackground?, border?)`
This method sets the title bar background color to match the GUI background and removes the window border.
```PHP
myGui.SetWindowColor(, myGui.BackColor, myGui.BackColor)
```

### `Gui.SetDarkMenu()`
This method sets the dark mode context menus.
```PHP
myGui.SetDarkMenu()
```

### `GuiControl.SetTheme(pszSubAppName, pszSubIdList := "")`
Applies a specified theme to the window through the SetWindowTheme function from the uxtheme library.
```PHP
/* This example sets dark mode edit control.*/
myEdit.SetTheme("DarkMode_Explorer")
```

### `GuiOrControl.SendMsg(Msg, wParam := 0, lParam := 0)`
This method sends a message to the gui or gui control.
```PHP
EN_KILLFOCUS := 0x0200
myEdit.SendMsg(EN_KILLFOCUS)
```

### `GuiExt.RECT(objOrAddress?)`
Create a `RECT` structure object that defines a rectangle by the coordinates of its upper-left and lower-right corners. This can be used directly with `DllCall`.
```php
/* Get RECT object from DllCall */
DllCall("GetWindowRect", "Ptr", WinExist("A"), "ptr", rc := GuiExt.RECT())
MsgBox(Format("{} {} {} {} {} {}", rc.left, rc.top, rc.right, rc.bottom, rc.Width, rc.Height))

/* Create a RECT object with values preset. */
rc := GuiExt.RECT({top: 10, bottom: 69})
MsgBox(Format("L{}/ T{}/ R{}/ B{}", rc.left, rc.top, rc.right, rc.bottom))

myGui.OnMessage(WM_NCCALCSIZE := 0x0083, NCCALCSIZE)

NCCALCSIZE(guiObj, wParam, lParam, msg) {
    if !wParam {
        /* Get the structure object from pointer address. */
        rc := GuiExt.RECT(lParam)
        ToolTip(Format("L{}/ T{}/ R{}/ B{}", rc.left, rc.top, rc.right, rc.bottom))
    }
}
```

### `GuiOrControl.GetWindowRect()`
Retrieves the dimensions of the bounding rectangle of the specified window. The dimensions are given in **screen coordinates** that are relative to the upper-left corner of the screen. [Learn more on MSDN](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getwindowrect)
```py
rc := myGui.GetWindowRect()
MsgBox(rc.left " " rc.top " " rc.right " " rc.bottom " " rc.Width " " rc.Height)
```

### `GuiOrControl.GetClientRect()`
Retrieves the coordinates of a window's **client area**. The client coordinates specify the upper-left and lower-right corners of the client area. Because client coordinates are relative to the upper-left corner of a window's client area, the coordinates of the upper-left corner are `(0,0)`. 
```py
rc := myEdit.GetClientRect()
MsgBox(rc.left " " rc.top " " rc.right " " rc.bottom " " rc.Width " " rc.Height)
```

### `Gui.SetBorderless(border := 6, dragWndFunc := "", cxLeftWidth?, cxRightWidth?, cyTopHeight?, cyBottomHeight?)`
To create a borderless window with customizable resizing behavior.
Creating a borderless resizable window with [Mica (Alt)](https://learn.microsoft.com/en-us/windows/apps/design/style/mica#app-layering-with-mica-alt) effect. background.   
> ![20240530-0455-52 6409216](https://github.com/nperovic/GuiEnhancerKit/assets/122501303/6f3f6474-2218-4f74-86ad-e227c49f8031)

```php
myGui := GuiExt("-Caption +Resize")
myGui.SetFont("cWhite s16", "Segoe UI")
myGui.SetDarkTitle()
myGui.SetDarkMenu()
myGui.OnEvent('Size', Size)

myGui.BackColor := 0x202020

text := myGui.Add("Text", "vTitlebar Backgroundcaa2031 cwhite Center R1.5 0x200 w280", "Titlebar Area")
text.SetRounded()

/* Set Mica (Alt) background. (Supported starting with Windows 11 Build 22000.) */
if (VerCompare(A_OSVersion, "10.0.22600") >= 0)
    myGui.SetWindowAttribute(38, 4)

myGui.SetBorderless(6, (g, x, y) => (y <= g['Titlebar'].GetWindowRect().bottom), 500, 500, 500, 500)

myGui.Show("h500")

Size(g, minmax, width, height) {
    SetControlDelay(-1)
    /** Set titlebar's width to fix the gui. */
    g["Titlebar"].W := (width - (g.MarginX*2))
}
```

