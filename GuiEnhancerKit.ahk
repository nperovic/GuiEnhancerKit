/************************************************************************
 * @description Elevate your AHK Gui development with extended methods and properties.
 * @file GuiEnhancerKit.ahk
 * @author Nikola Perovic
 * @link https://github.com/nperovic/GuiEnhancerKit
 * @date 2024/05/26
 * @version 1.0.1
 ***********************************************************************/

#Requires AutoHotkey v2.0.15

#DllLoad gdi32.dll
#DllLoad uxtheme.dll
#DllLoad dwmapi.dll

class GuiExt extends Gui
{
    class Control extends GuiExt
    {
        static __New()
        {
            p              := super.Prototype
            gcp            := Gui.Control.Prototype
            gcp.SendMsg    := p.SendMsg.Bind(this)
            gcp.SetRounded := p.SetRounded.Bind(this)
            gcp.SetTheme   := p.SetTheme.Bind(this)

            if (VerCompare(A_AhkVersion, "2.1-alpha.7") < 0) 
                gcp.OnMessage := this.Prototype.OnMessage.Bind(this)
    
            for prop in ["x", "y", "w", "h"] 
                gcp.DefineProp(prop, {Get: p.GetPos.Bind(this, prop), Set: p.SetPos.Bind(this, prop)})

            gcp.DeleteProp("__New")
            this.DeleteProp("Call")
        }

          /**
         * Registers a function or method to be called whenever the GuiControl receives the specified message.
         * @param {Integer} Msg The number of the message to monitor, which should be between 0 and 4294967295 (0xFFFFFFFF).
         * @param {String|(GuiCtrlObj, wParam, lParam, Msg) => Integer} Callback The function, method or object to call when the event is raised.
         * If the GUI has an event sink (that is, if Gui()'s EventObj parameter was specified), this parameter may be the name of a method belonging to the event sink.
         * Otherwise, this parameter must be a function object. The function may also consult the built-in variable `A_EventInfo`, which contains 0 if the message was sent via SendMessage.
         * If sent via PostMessage, it contains the tick-count time the message was posted.
            * @param {Integer} AddRemove If omitted, it defaults to 1 (call the callback after any previously registered callbacks). Otherwise, specify one of the following numbers: 
            * - 1  = Call the callback after any previously registered callbacks.
            * - -1 = Call the callback before any previously registered callbacks.
            * - 0  = Do not call the callback.
         */
        OnMessage(obj, Msg, Callback, AddRemove := 1)
        {
            static SubClasses := Map()
            static HookedMsgs := Map()

            if !SubClasses.Has(obj.hwnd) {
                SubClasses[obj.hwnd] := CallbackCreate(SubClassProc,, 6)
                HookedMsgs[obj.hwnd] := Map(Msg, Callback.Bind(obj))
                SetWindowSubclass(obj, SubClasses[obj.hwnd])
                obj.Gui.OnEvent("Close", RemoveWindowSubclass)
            }
            
            hm := HookedMsgs[obj.hwnd]

            if AddRemove
                hm[Msg] := Callback.Bind(obj)
            else if hm.Has(Msg)
                hm.Delete(Msg)

            SubClassProc(hWnd?, uMsg?, wParam?, lParam?, uIdSubclass?, dwRefData?)
            {
                if HookedMsgs.Has(uIdSubclass) && HookedMsgs[uIdSubclass].Has(uMsg) {
                    reply := HookedMsgs[uIdSubclass][uMsg](wParam?, lParam?, uMsg?)
                    if IsSet(reply)
                        return reply
                }

                return DefSubclassProc(hwnd, uMsg?, wParam?, lParam?)
            }

            DefSubclassProc(hwnd?, uMsg?, wParam?, lParam?) => DllCall("DefSubclassProc", "Ptr", hwnd, "UInt", uMsg, "Ptr", wParam, "Ptr", lParam, "Ptr")

            SetWindowSubclass(obj, cb) => DllCall("SetWindowSubclass", "Ptr", obj.hwnd, "Ptr", cb, "Ptr", obj.hwnd, "Ptr", 0)

            RemoveWindowSubclass(*)
            {
                for hwnd, cb in SubClasses.Clone() {
                    try {
                        DllCall("RemoveWindowSubclass", "Ptr", hWnd, "Ptr", cb, "Ptr", hWnd)
                        CallbackFree(cb)
                        SubClasses.Delete(hwnd)
                    }
                }
            }
        }
    }

    static __New()
    {
        p                     := this.Prototype
        gp                    := super.Prototype
        gp.SendMsg            := p.SendMsg.Bind(this)
        gp.SetDarkMenu        := p.SetDarkMenu.Bind(this)
        gp.SetDarkTitle       := p.SetDarkTitle.Bind(this)
        gp.SetWindowColor     := p.SetWindowColor.Bind(this)
        gp.SetWindowAttribute := p.SetWindowAttribute.Bind(this)

        if (VerCompare(A_AhkVersion, "2.1-alpha.7") < 0) 
            gp.OnMessage := p.OnMessage.Bind(this)

        for prop in ["x", "y", "w", "h"] 
            gp.DefineProp(prop, {Get: p.GetPos.Bind(this, prop), Set: p.SetPos.Bind(this, prop)})

        p.DeleteProp("__New")
        this.DeleteProp("Call")
    }

    ; X position
    X => Integer

    ; Y position
    Y => Integer
    
    ; Width
    W => Integer
    
    ; Height
    H => Integer

      /**
     * Create a text control that the user cannot edit. Often used to label other controls.
     * @param {'ActiveX'|'Button'|'Checkbox'|'ComboBox'|'Custom'|'DateTime'|'DropDownList'|'Edit'|'GroupBox'|'Hotkey'|'Link'|'ListBox'|'ListView'|'MonthCal'|'Picture'|'Progress'|'Radio'|'Slider'|'StatusBar'|'Tab'|'Tab2'|'Tab3'|'Text'|'TreeView'|'UpDown'} ControlType 
     * @param Options V:    Sets the control's Name.
        * Pos: xn yn wn hn rn  Right Left Center Section
     *         VScroll  HScroll -Tabstop -Wrap
     *         BackgroundColor  BackgroundTrans
     *         Border  Theme  Disabled  Hidden
     * @param Text The text 
     * @returns {GuiExt.Control|Gui.Control}
     */
    Add(ControlType, Options?, Text?) {
        return super.Add(ControlType, Options?, Text?)
    }

    GetPos(prop, obj) => (obj.GetPos(&x, &y, &w, &h), %prop%)

    SetPos(prop, obj, value) {
        SetWinDelay(-1), SetControlDelay(-1)
        %prop% := value
        obj.Move(x?, y?, w?, h?)
    }

      /**
     * Applies a specified theme to the window through the SetWindowTheme function from the uxtheme library.
     * @param {string} pszSubAppName - The name of the application's subcomponent to apply the theme to.
     * @param {string} [pszSubIdList] - A semicolon-separated list of class names to apply the theme to. Optional parameter.
     * @returns {boolean} True if the theme was set successfully, false otherwise.
        * @see https: //learn.microsoft.com/en-us/windows/win32/api/uxtheme/nf-uxtheme-setwindowtheme
     */
    SetTheme(obj, pszSubAppName, pszSubIdList := "") => (!DllCall("uxtheme\SetWindowTheme", "ptr", obj.hwnd, "ptr", StrPtr(pszSubAppName), "ptr", pszSubIdList ? StrPtr(pszSubIdList) : 0) ? true : false)

      /**
     * Sets the attributes of a window. Specifically, it can set the color of the window's caption, text, and border.
     * @param {integer} [titleText] Specifies the color of the caption text. Specifying `0xFFFFFFFF` will reset to the system's default caption text color.  
     * @param {integer} [titleBackground] Specifies the color of the caption. Specifying `0xFFFFFFFF` will reset to the system's default caption color.
     * @param {integer} [border] Specifies the color of the window border.
     * - Specifying `0xFFFFFFFE` will suppress the drawing of the window border. 
     * - Specifying `0xFFFFFFFF` will reset to the system's default border color.  
     * The application is responsible for changing the border color in response to state changes, such as window activation.
     * @since This is supported starting with Windows 11 Build 22000.
     * @returns {String} - The result of the attribute setting operation.
     */
    SetWindowColor(obj, titleText?, titleBackground?, border?)
    {
        static DWMWA_BORDER_COLOR  := 34
        static DWMWA_CAPTION_COLOR := 35
        static DWMWA_TEXT_COLOR    := 36
        static SetClrMap           := Map(DWMWA_BORDER_COLOR, "border", DWMWA_CAPTION_COLOR, "titleBackground", DWMWA_TEXT_COLOR, "titleText")
        
        if (VerCompare(A_OSVersion, "10.0.22200") < 0)
            return MsgBox("This is supported starting with Windows 11 Build 22000.", "OS Version Not Supported.")

        for attr, var in SetClrMap
            if (%var%??0)
                obj.SetWindowAttribute(attr, RgbToBgr(%var% is string && !InStr(%var%, "0x") ? Number("0x" %var%) : %var%))

        RgbToBgr(color) => (((Color >> 16) & 0xFF) | (Color & 0x00FF00) | ((Color & 0xFF) << 16))
    }

      /**
     * Calls the DwmSetWindowAttribute function from the dwmapi library to set attributes of a window.
     * @param {number} dwAttribute - The attribute constant to set.
     * @param {number} [pvAttribute] - The value of the attribute to set. Optional parameter.
     * @returns {number} The result of the DllCall, typically indicating success or failure.
        * @see https: //learn.microsoft.com/en-us/windows/win32/api/dwmapi/nf-dwmapi-dwmsetwindowattribute
     */
    SetWindowAttribute(obj, dwAttribute, pvAttribute?) => DllCall("dwmapi\DwmSetWindowAttribute", 'ptr', obj.Hwnd, "uint", dwAttribute, "uint*", pvAttribute, "int", 4)

      /**
     * Sets the dark mode title bar for the window if the operating system version supports it.
     * @returns {number|undefined} The result of setting the window attribute, or undefined if not applicable.
     */
    SetDarkTitle(obj)
    {
        if (attr := ((VerCompare(A_OSVersion, "10.0.18985") >= 0) ? 20 : (VerCompare(A_OSVersion, "10.0.17763") >= 0) ? 19 : 0))
            return obj.SetWindowAttribute(attr, true)
    }

      /**
     * Set the control's border style to rounded corners.
     * @param {Integer} [corner=9] The radius of the rounded corners.
     * @returns {void}
     */
    SetRounded(obj, corner := 9)
    {
        
        obj.Opt("+0x4000000")
        DllCall("GetClientRect", "ptr", obj.Hwnd, "ptr", rc := Buffer(16, 0), "int")
        rcRgn := DllCall('Gdi32\CreateRoundRectRgn', 'int', NumGet(rc, 0, "int") + 3, 'int', NumGet(rc, 4, "int") + 3, 'int', NumGet(rc, 8, "int") - 3, 'int', NumGet(rc, 12, "int") - 3, 'int', corner, 'int', corner, 'ptr')
        DllCall("User32\SetWindowRgn", "ptr", obj.hWnd, "ptr", rcRgn, "int", 1, "int")
        obj.Redraw()
        DllCall('Gdi32\DeleteObject', 'ptr', rcRgn, 'int')
    }

    ; Apply dark theme to all the context menus that is created by this script. 
    SetDarkMenu(obj?)
    {
        uxtheme             := DllCall("GetModuleHandle", "ptr", StrPtr("uxtheme"), "ptr")
        SetPreferredAppMode := DllCall("GetProcAddress", "ptr", uxtheme, "ptr", 135, "ptr")
        FlushMenuThemes     := DllCall("GetProcAddress", "ptr", uxtheme, "ptr", 136, "ptr")
        DllCall(SetPreferredAppMode, "int", 1)	
        DllCall(FlushMenuThemes)
    }
 
      /**
     * Send the message to the window or control, and then wait for confirmation.
     */
    SendMsg(obj, Msg, wParam?, lParam?) => SendMessage(Msg, wParam?, lParam?, obj)

      /**
     * Registers a function or method to be called whenever the Gui receives the specified message.
     * @param {Integer} Msg The number of the message to monitor, which should be between 0 and 4294967295 (0xFFFFFFFF).
     * @param {String|(GuiObj, wParam, lParam, Msg) => Integer} Callback The function, method or object to call when the event is raised.
     * If the GUI has an event sink (that is, if Gui()'s EventObj parameter was specified), this parameter may be the name of a method belonging to the event sink.
     * Otherwise, this parameter must be a function object. (**ahk_h 2.0**)The function may also consult the built-in variable `A_EventInfo`, which contains 0 if the message was sent via SendMessage.
     * If sent via PostMessage, it contains the tick-count time the message was posted.
     * @param {Integer} MaxThreads This integer is usually omitted. In this case, the monitoring function can only process one thread at a time. This is usually the best, because otherwise whenever the monitoring function is interrupted, the script will process the messages in chronological order. Therefore, as an alternative to MaxThreads, Critical can be considered, as shown below.
     * 
     * Specify 0 to unregister the function previously identified by Function.
     * 
     * By default, when multiple functions are registered for a MsgNumber, they will be called in the order of registration. To register a function before the previously registered function, specify a negative value for MaxThreads. For example, OnMessage Msg, Fn, -2 Register Fn to be called before any other functions registered for Msg, and allow Fn to have up to 2 threads. However, if the function has already been registered, the order will not change unless the registration is cancelled and then re-registered.
     */
    OnMessage(obj, Msg, Callback, MaxThreads?)
    {
        OnMessage(Msg, _callback, MaxThreads?)
        obj.OnEvent("Close", g => OnMessage(Msg, _callback, 0))

        _callback(wParam, lParam, uMsg, hWnd)
        {
            try if (uMsg = Msg && hwnd = obj.hwnd)
                return Callback(obj, wParam, lParam, uMsg)
        }
    }
}


;;{ Examples

; WM_LBUTTONDOWN   := 0x0201
; WM_SETCURSOR     := 0x0020
; WM_NCLBUTTONDOWN := 0x00A1
; EN_KILLFOCUS     := 0x0200
; WM_SIZING        := 0x0214
; WM_MOVE          := 0x0003
; WM_MOVING        := 0x0216

; ; To ensure proper functioning of VSCode's Intelligence, annotate the variable type as GuiExt above the line where you create a new Gui object instance.
; ; Like the example below: 
; /** @var {GuiExt} myGui */
; myGui := Gui("-Caption +Resize")

; myGui.SetFont("cWhite s16", "Segoe UI")
; myGui.BackColor := 0x202020

; ; Gui Control objects created in this way do not work with VSCode's IntelliSense. Create an Edit control as shown below.
; text := myGui.AddText("Backgroundcaa2031 cwhite Center R1.5 0x200 w280", "Rounded Text Control")

; ; Set Rounded Control
; text.SetRounded()
 
; myEdit := myGui.Add("Edit", "-WantReturn -TabStop w300 h150 -E0x200 -HScroll -VScroll +Multi +ReadOnly cwhite Background" myGui.BackColor)
; myEdit.SetFont(, "Consolas")

; myEdit.UpdatePos := ctrl => (ctrl.Value := 
; (
;     "x: " myGui.X "
;     y: " myGui.Y "
;     w: " myGui.W "
;     h: " myGui.H
; ))

; myEdit.OnEvent("Focus", (myEdit, *) => (
;     DllCall("User32\HideCaret", "ptr", myEdit.hWnd, "int"),
;     myEdit.SendMsg(EN_KILLFOCUS)
; ))

; myGui.OnEvent("Size", Size)

; ; Registers a function or method to be called whenever the Gui or GuiControl receives the specified message. [Check out the official document for more information.](https://www.autohotkey.com/docs/alpha/lib/GuiOnMessage.htm)
; myGui.OnMessage(WM_LBUTTONDOWN, DragWindow)
; myEdit.OnMessage(WM_SETCURSOR, SetCursor)

; myGui.OnMessage(WM_MOVING, (*) => myEdit.UpdatePos())

; ; Set Dark Titlebar
; myGui.SetDarkTitle()

; ; Set Rounded Window (win 11+)
; myGui.SetWindowAttribute(33, 2)

; ; Set Titlebar background color the same as the gui background and remove the window border
; myGui.SetWindowColor(, myGui.BackColor, myGui.BackColor)

; ; Set Dark ContextMenu
; myGui.SetDarkMenu()

; ; Set Edit Control theme
; myEdit.SetTheme("DarkMode_Explorer")

; myGui.Show("w300 AutoSize")
; myGui.Opt("MinSize")

; ; Send Message to the gui or gui control
; myEdit.SendMsg(EN_KILLFOCUS)

; /**
;  * @param {GuiExt|Gui} GuiObj 
;  * @param {Integer} MinMax 
;  * @param {Integer} Width 
;  * @param {Integer} Height 
;  */
; Size(GuiObj, MinMax, Width, Height) {
;     Critical("Off")
;     SetWinDelay(-1), SetControlDelay(-1)

;     ; Moving Controls
;     myEdit.W := text.W := Width - (GuiObj.MarginX*2)
;     myEdit.H := Height - (GuiObj.MarginY*2)
;     text.SetRounded()
;     myEdit.UpdatePos()
; }

; /**
;  * Callback function for `GuiCtrl.OnMessage()` [Check out the official document for more information.](https://www.autohotkey.com/docs/alpha/lib/GuiOnMessage.htm)
;  * @param GuiCtrlObj 
;  * @param wParam 
;  * @param lParam 
;  * @param msg 
;  * @returns {Integer} 
;  */
; DragWindow(GuiCtrlObj, wParam, lParam, msg) {
;     static WM_NCLBUTTONDOWN := 0x00A1
;     PostMessage(WM_NCLBUTTONDOWN, 2,,, GuiCtrlObj is Gui.Control ? GuiCtrlObj.Gui : GuiCtrlObj)
;     return 0
; }

; /**
;  * Callback function for `GuiCtrl.OnMessage()` [Check out the official document for more information.](https://www.autohotkey.com/docs/alpha/lib/GuiOnMessage.htm)
;  * @param GuiCtrlObj 
;  * @param wParam 
;  * @param lParam 
;  * @param msg 
;  * @returns {Integer} 
;  */
; SetCursor(GuiCtrlObj, wParam, lParam, Msg) {
;     static hCursor := DllCall("LoadCursor", "ptr", 0, "ptr", 32512)
;     DllCall("SetCursor", "ptr", hCursor, "ptr")
;     return 0
; }

;;}
