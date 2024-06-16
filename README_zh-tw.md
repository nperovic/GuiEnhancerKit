# GuiEnhancerKit
本函式庫提供一套擴展方法和屬性來增強你的 AutoHotkey Gui 開發體驗。

## 開始使用

### 將本函式庫加到你的程式碼中。
```AUTOIT
#Requires AutoHotkey v2
#Include <GuiEnhancerKit>
```

### 使用 VSCode 的 IntelliSence (程式碼自動補全)
> ![image](https://github.com/nperovic/GuiEnhancerKit/assets/122501303/8b7942c1-5805-4c64-b955-d8aa1d782cc0)
> ![image](https://github.com/nperovic/GuiEnhancerKit/assets/122501303/8decc18c-57e0-47a7-8ee7-ebef7e4845d4)

為了確保 VSCode 的 IntelliSence 能正常運作，你可以：
1. 將 `Gui` 物件替換為 `GuiExt`。 (推薦)
```CPP
myGui := GuiExt("-Caption +Resize")
```
2. 在你創建新的 `Gui` 物件實例的那一行上方，將變數類型註解為 `GuiExt`。
```js
/** @var {GuiExt} myGui */
myGui := Gui("-Caption +Resize")
```

## 功能

### `GuiControl.SetRounded(corner := 9)`  
> ![image](https://github.com/nperovic/GuiEnhancerKit/assets/122501303/0ebff7a5-f3cf-45a3-9059-6bb62f8960f8)  

這個方法將控制元件的邊框樣式設置為圓角。在這個例子中，圓角的半徑設置為 `9`。  
```PHP
text.SetRounded(9)
```

### `GuiOrControl.X`/ `GuiOrControl.Y`/ `GuiOrControl.W`/ `GuiOrControl.H`
這些屬性允許你獲取或設置 `Gui` 或 `Gui` 控制元件的位置和大小。
```PHP
/* 獲取當前 gui 的位置。 */
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

    /* 移動控制元件 */
    myEdit.W := text.W := Width - (GuiObj.MarginX*2)
    myEdit.H := Height - (GuiObj.MarginY*2)
    text.SetRounded()
    myEdit.UpdatePos()
}
```

### `Gui.OnMessage(Msg, Callback, MaxThreads := 1)`  
### `GuiControl.OnMessage(Msg, Callback, AddRemove := 1)`
註冊一個回調函數或方法，在 `Gui` 或 `GuiControl` 收到指定的訊息時調用。 [了解更多](https://github.com/nperovic/GuiEnhancerKit/wiki#onmessage)
```PHP
WM_LBUTTONDOWN   := 0x0201
WM_SETCURSOR     := 0x0020
WM_MOVING        := 0x0216

myGui.OnMessage(WM_LBUTTONDOWN, DragWindow)
myEdit.OnMessage(WM_SETCURSOR, SetCursor)
myGui.OnMessage(WM_MOVING, (*) => myEdit.UpdatePos())

/**
 * `GuiCtrl.OnMessage()` 的回調函數
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
 * `GuiCtrl.OnMessage()` 的回調函數
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
這個方法為視窗設置深色模式的標題欄 (如果作業系統版本支援的話。)
```PHP
myGui.SetDarkTitle()
```

### `Gui.SetWindowAttribute(dwAttribute, pvAttribute?)`
這個方法從 dwmapi 函式庫調用 `DwmSetWindowAttribute` 函數來設置視窗的屬性。
> 需要 Windows 11。  
> [在 MSDN 上了解更多](https://learn.microsoft.com/en-us/windows/win32/api/dwmapi/nf-dwmapi-dwmsetwindowattribute)  
> ![image](https://github.com/nperovic/GuiEnhancerKit/assets/122501303/ed1a147e-4dea-402e-917a-028555bafb8c)
```PHP
/* 為視窗設置圓角。 */
myGui.SetWindowAttribute(33, 2)
```

### `Gui.SetWindowColor(titleText?, titleBackground?, border?)`
這個方法將標題欄的背景顏色設置為與 GUI 背景匹配，並移除視窗邊框。
```PHP
myGui.SetWindowColor(, myGui.BackColor, myGui.BackColor)
```

### `Gui.SetDarkMenu()`
這個方法設置深色模式的上下文菜單。
```PHP
myGui.SetDarkMenu()
```

### `GuiControl.SetTheme(pszSubAppName, pszSubIdList := "")`
透過 uxtheme 函式庫的 SetWindowTheme 函數將指定的主題應用到視窗。
```PHP
/* 這個例子將編輯控制元件設置為深色模式。*/
myEdit.SetTheme("DarkMode_Explorer")
```

### `GuiOrControl.SendMsg(Msg, wParam := 0, lParam := 0)`
這個方法向 gui 或 gui 控制元件發送訊息。
```PHP
EN_KILLFOCUS := 0x0200
myEdit.SendMsg(EN_KILLFOCUS)
```

### `GuiExt.RECT(objOrAddress?)`
創建一個 `RECT` 結構物件，該物件通過其左上角和右下角的坐標定義一個矩形。這可以直接與 `DllCall` 一起使用。
```php
/* 從 DllCall 獲取 RECT 物件 */
DllCall("GetWindowRect", "Ptr", WinExist("A"), "ptr", rc := GuiExt.RECT())
MsgBox(Format("{} {} {} {} {} {}", rc.left, rc.top, rc.right, rc.bottom, rc.Width, rc.Height))

/* 創建一個帶有預設值的 RECT 物件。 */
rc := GuiExt.RECT({top: 10, bottom: 69})
MsgBox(Format("L{}/ T{}/ R{}/ B{}", rc.left, rc.top, rc.right, rc.bottom))

myGui.OnMessage(WM_NCCALCSIZE := 0x0083, NCCALCSIZE)

NCCALCSIZE(guiObj, wParam, lParam, msg) {
    if !wParam {
        /* 從指針地址獲取結構物件。 */
        rc := GuiExt.RECT(lParam)
        ToolTip(Format("L{}/ T{}/ R{}/ B{}", rc.left, rc.top, rc.right, rc.bottom))
    }
}
```

### `GuiOrControl.GetWindowRect()`
獲取指定視窗的邊界矩形的尺寸。尺寸以**螢幕坐標**給出，相對於螢幕的左上角。 [在 MSDN 上了解更多](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getwindowrect)
```py
rc := myGui.GetWindowRect()
MsgBox(rc.left " " rc.top " " rc.right " " rc.bottom " " rc.Width " " rc.Height)
```

### `GuiOrControl.GetClientRect()`
獲取視窗**客戶區**的坐標。客戶區坐標指定客戶區的左上角和右下角。因為客戶區坐標是相對於視窗客戶區的左上角，所以左上角的坐標是 `(0,0)`。 
```py
rc := myEdit.GetClientRect()
MsgBox(rc.left " " rc.top " " rc.right " " rc.bottom " " rc.Width " " rc.Height)
```

### `Gui.SetBorderless(border := 6, dragWndFunc := "", cxLeftWidth?, cxRightWidth?, cyTopHeight?, cyBottomHeight?)`
創建一個具有可自定義調整大小行為的無邊框視窗。
創建一個具有 [Mica (Alt)](https://learn.microsoft.com/en-us/windows/apps/design/style/mica#app-layering-with-mica-alt) 效果的無邊框可調整大小的視窗。   
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

/* 設置 Mica (Alt) 背景。 (從 Windows 11 Build 22000 開始支援。) */
if (VerCompare(A_OSVersion, "10.0.22600") >= 0)
    myGui.SetWindowAttribute(38, 4)

myGui.SetBorderless(6, (g, x, y) => (y <= g['Titlebar'].GetWindowRect().bottom), 500, 500, 500, 500)

myGui.Show("h500")

Size(g, minmax, width, height) {
    SetControlDelay(-1)
    /** 設置 titlebar 的寬度以適應 gui。 */
    g["Titlebar"].W := (width - (g.MarginX*2))
}
```