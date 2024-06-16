/************************************************************************
 * @description Elevate your AHK Gui development with extended methods and properties.  
 * @file GuiEnhancerKit.ahk
 * @author Nikola Perovic
 * @link https://github.com/nperovic/GuiEnhancerKit
 * @date 2024/06/16
 * @version 1.0.0
 ***********************************************************************/

#Requires AutoHotkey v2

#DllLoad gdi32.dll
#DllLoad uxtheme.dll
#DllLoad dwmapi.dll

class GuiExt extends Gui
{
    class __Struct extends Buffer
    {
        __New(ByteCount?, FillByte?) => super.__New(ByteCount?, FillByte?)
        
        Set(ptr?)
        {
            if !(ptr??0)
                return
            for p, v in ptr.OwnProps()
                if this.HasProp(p)
                    this.%p% := v
        }
    
        PropDesc(name, ofst, type, ptr?)
        {
            if ((ptr??0) && IsNumber(ptr))
                NumPut(type, NumGet(ptr, ofst, type), this, ofst)
            this.DefineProp(name, {
                Get: NumGet.Bind(, ofst, type),
                Set: (p, v) => NumPut(type, v, this, ofst)
            })
        }
    }
    
    class RECT extends GuiExt.__Struct
    { 
        /**
         * The `RECT` structure defines a rectangle by the coordinates of its upper-left and lower-right corners.
         * @param {object|integer} [objOrAddress] *Optional:* Create rect object and set values to each property. It can be object or the `ptr` address.  
         * @example
         * DllCall("GetWindowRect", "Ptr", WinExist("A"), "ptr", rc := GuiExt.RECT())
         * MsgBox rc.left " " rc.top " " rc.right " " rc.bottom
         * 
         * @example
         * rc := GuiExt.RECT({top: 10, bottom: 69})
         * MsgBox "L" rc.left "/ T" rc.top "/ R" rc.right "/ B" rc.bottom ; L0/ T10/ R0/ B69
         * 
         * @example
         * myGui.OnMessage(WM_NCCALCSIZE := 0x0083, NCCALCSIZE)
         * NCCALCSIZE(guiObj, wParam, lParam, msg)
         * {
         *      if !wParam {
         *          rc := GuiExt.RECT(lParam)
         *          ToolTip "L" rc.left "/ T" rc.top "/ R" rc.right "/ B" rc.bottom
         *      }
         * }
         * 
         * @returns The Buffer object that defined the `RECT` structure.
         * @link [Learn more on MSDN](https://learn.microsoft.com/en-us/windows/win32/api/windef/ns-windef-rect)
         */
        __New(objOrAddress?)
        {
            super.__New(16)
            (IsSet(objOrAddress) && IsNumber(objOrAddress) && (ptr := objOrAddress))
            (IsSet(objOrAddress) && IsObject(objOrAddress) && (objOrAddress := objOrAddress))
            for i, prop in ["left", "top", "right", "bottom"]
                this.PropDesc(prop, 4 * (i-1), "int",  ptr?)
            this.Set(objOrAddress?)
        }
         
        /** @prop {integer} left Specifies the x-coordinate of the upper-left corner of the rectangle. */
        left := unset
    
        /** @prop {integer} top Specifies the y-coordinate of the upper-left corner of the rectangle. */
        top := unset
    
        /** @prop {integer} right Specifies the x-coordinate of the lower-right corner of the rectangle. */
        right := unset
    
        /** @prop {integer} bottom Specifies the y-coordinate of the lower-right corner of the rectangle. */
        bottom := unset
        
        /** @prop {integer} width Rect width. */
        width => (this.right - this.left)

        /** @prop {integer} width Rect width. */
        height => (this.bottom - this.top)
    }

    static __New()
    {
        GuiExt.Control.__New(p := this.Prototype, sp := super.Prototype)

        for _p in [sp, this.Control.Prototype, Gui.Control.Prototype]
            for prop in ["x", "y", "w", "h"]
                _p.DefineProp(prop, {Get: p.__GetPos.Bind(, prop), Set: p.__SetPos.Bind(, prop)})
    }

	/**
	 * Create a new Gui object.
	 * @param Options AlwaysOnTop Border Caption Disabled -DPIScale LastFound
	 * MaximizeBox MinimizeBox MinSize600x600 MaxSize800x800 Resize
	 * OwnDialogs '+Owner' OtherGui.hwnd +Parent
	 * SysMenu Theme ToolWindow
	 * @param Title The window title. If omitted, it defaults to the current value of A_ScriptName.
	 * @param EventObj OnEvent, OnNotify and OnCommand can be used to register methods of EventObj to be called when an event is raised
     * @returns {GuiExt|Gui}
	 */
	__New(Options := '', Title := A_ScriptName, EventObj?) => super.__New(Options?, Title?, EventObj??this)

    /**
     * @prop {Integer} X X position
     * @prop {Integer} Y Y position
     * @prop {Integer} W Width
     * @prop {Integer} H Height
     */
    X := Y := W := H := 0

    /**
	 * Create controls such as text, buttons or checkboxes, and return a GuiControl object.
	 * @param {'ActiveX'|'Button'|'Checkbox'|'ComboBox'|'Custom'|'DateTime'|'DropDownList'|'Edit'|'GroupBox'|'Hotkey'|'Link'|'ListBox'|'ListView'|'MonthCal'|'Picture'|'Progress'|'Radio'|'Slider'|'StatusBar'|'Tab'|'Tab2'|'Tab3'|'Text'|'TreeView'|'UpDown'} ControlType
	 * @param Options V:    Sets the control's Name.
     * Pos: xn yn wn hn rn Right Left Center Section
	 *         VScroll HScroll -Tabstop -Wrap
	 *         BackgroundColor Border Theme Disabled Hidden
     * @returns {GuiExt.Control|GuiExt.ActiveX|GuiExt.Button|GuiExt.Checkbox|GuiExt.ComboBox|GuiExt.Custom|GuiExt.DateTime|GuiExt.DropDownList|GuiExt.Edit|GuiExt.GroupBox|GuiExt.Hotkey|GuiExt.Link|GuiExt.ListBox|GuiExt.ListView|GuiExt.MonthCal|GuiExt.Picture|GuiExt.Progress|GuiExt.Radio|GuiExt.Slider|GuiExt.StatusBar|GuiExt.Tab|GuiExt.Tab2|GuiExt.Tab3|GuiExt.Text|GuiExt.TreeView|GuiExt.UpDown}
     */
    Add(ControlType, Options?, Text?) => super.Add(ControlType, Options?, Text?)

    __GetPos(prop) => (this.GetPos(&x, &y, &w, &h), %prop%)

    __SetPos(prop, value)
    {
        SetWinDelay(-1), SetControlDelay(-1)
        try %prop% := value
        try this.Move(x?, y?, w?, h?)
    }

    /**
     * To create a borderless window with customizable resizing behavior.
     * @param {Integer} [border=6] The width of the edge of the window where the window size can be adjusted. If this value is `0`, the window will not be resizable.
     * @param {(guiObj, x, y) => Integer} [DragWndFunc=""] A callback function used to check whether the window is currently in a drag state. If the function returns `true` and the left mouse button is held down on the `Gui` window, the effect is the same as holding down the left button on the window title bar.
     * @param {number} [cxLeftWidth] The width of the left border that retains its size.
     * @param {number} [cxRightWidth] The width of the right border that retains its size.
     * @param {number} [cyTopHeight] The height of the top border that retains its size.
     * @param {number} [cyBottomHeight] The height of the bottom border that retains its size.
     */
    SetBorderless(border := 6, dragWndFunc := "", cxLeftWidth?, cxRightWidth?, cyTopHeight?, cyBottomHeight?)
    {
        static WM_NCCALCSIZE := 0x83
        static WM_NCHITTEST  := 0x84
        static WM_NCACTIVATE := 0x86
        static WM_ACTIVATE   := 0x6

        this.SetWindowAttribute(3, 1)

        ; Set Rounded Corner for Windows 11 
        if (VerCompare(A_OSVersion, "10.0.22000") >= 0)
            this.SetWindowAttribute(33, 2)

        this.OnMessage(WM_ACTIVATE, CB_ACTIVATE)
        this.OnMessage(WM_NCACTIVATE, CB_NCACTIVATE)
        this.OnMessage(WM_NCCALCSIZE, CB_NCCALCSIZE)

        ; Make window resizable. 
        this.OnMessage(WM_NCHITTEST, CB_NCHITTEST.Bind(dragWndFunc ? dragWndFunc.Bind(this) : 0))

        ExtendFrameIntoClientArea(cxLeftWidth?, cxRightWidth?, cyTopHeight?, cyBottomHeight?)

        CB_ACTIVATE(g, wParam, lParam, Msg)
        {
            SetWinDelay(-1), SetControlDelay(-1), WinRedraw(g)
            if (lParam = g.hwnd && (wParam & 0xFFFF))
                ExtendFrameIntoClientArea(cxLeftWidth?, cxRightWidth?, cyTopHeight?, cyBottomHeight?)
        }

        CB_NCCALCSIZE(g, wParam, lParam, Msg)
        {
            if wParam
                return 0
        }

        CB_NCACTIVATE(g, wParam, lParam, *)
        {
            if !wParam
                return true
            if (lParam != g.hwnd) && GetKeyState("LButton", "P")
                return false
            SetWinDelay(-1)
            WinRedraw(g)
        }

        /**
         * @param {Function} HTFunc 
         * @param {GuiExt} g 
         * @param {integer} wParam 
         * @param {integer} lParam 
         * @param {integer} Msg 
         * @returns {Integer | unset} 
         */
        CB_NCHITTEST(HTFunc?, g?, wParam?, lParam?, Msg?)
        {
            static HTLEFT       := 10, HTRIGHT       := 11
                 , HTTOP        := 12, HTTOPLEFT     := 13
                 , HTTOPRIGHT   := 14, HTBOTTOM      := 15
                 , HTBOTTOMLEFT := 16, HTBOTTOMRIGHT := 17
                 , TCAPTION     := 2
            
            if !(g is Gui)
                return

            CoordMode("Mouse")
            MouseGetPos(&x, &y)

            rc := g.GetWindowRect()
            R  := (x >= rc.right - border)
            L  := (x < rc.left + border)

            if (B := (y >= rc.bottom - border))
                return R ? HTBOTTOMRIGHT: L ? HTBOTTOMLEFT: HTBOTTOM

            if (T := (y < rc.top + border))
                return R ? HTTOPRIGHT: L ? HTTOPLEFT: HTTOP

            return L ? HTLEFT: R ? HTRIGHT: (HTFunc && HTFunc(x, y) ? TCAPTION : (_ := unset))
        }

        ExtendFrameIntoClientArea(cxLeftWidth?, cxRightWidth?, cyTopHeight?, cyBottomHeight?)
        {
            rc := this.GetWindowRect()
            NumPut('int', cxLeftWidth ?? rc.width,'int', cxRightWidth ?? rc.width,'int', cyTopHeight ?? rc.height,'int', cyBottomHeight ?? rc.height, margin := Buffer(16))
            DllCall("Dwmapi\DwmExtendFrameIntoClientArea", "Ptr", this.hWnd, "Ptr", margin)
        }
    }

    /**
     * Retrieves the dimensions of the bounding rectangle of the specified window. The dimensions are given in screen coordinates that are relative to the upper-left corner of the screen.  
     * [Learn more](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getwindowrect)
     * @returns {RECT} 
     */
    GetWindowRect() => (DllCall("GetWindowRect", "ptr", this.hwnd, "ptr", _rc := GuiExt.RECT(), "uptr"), _rc)

    /**
     * Retrieves the coordinates of a window's client area. The client coordinates specify the upper-left and lower-right corners of the client area. Because client coordinates are relative to the upper-left corner of a window's client area, the coordinates of the upper-left corner are (0,0).  
     * [Learn more](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getclientrect)
     * @returns {RECT} 
     */        
    GetClientRect() => (DllCall("GetClientRect", "ptr", this.hwnd, "ptr", _rc := GuiExt.RECT(), "uptr"), _rc)

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
    SetWindowColor(titleText?, titleBackground?, border?)
    {
        static DWMWA_BORDER_COLOR  := 34
        static DWMWA_CAPTION_COLOR := 35
        static DWMWA_TEXT_COLOR    := 36
        static SetClrMap           := Map(DWMWA_BORDER_COLOR, "border", DWMWA_CAPTION_COLOR, "titleBackground", DWMWA_TEXT_COLOR, "titleText")
        
        if (VerCompare(A_OSVersion, "10.0.22200") < 0) 
            throw OSError("This is supported starting with Windows 11 Build 22000.")

        for attr, var in SetClrMap
            if (%var%??0)
                this.SetWindowAttribute(attr, RgbToBgr(%var% is string && !InStr(%var%, "0x") ? Number("0x" %var%) : %var%))

        RgbToBgr(color) => (((Color >> 16) & 0xFF) | (Color & 0x00FF00) | ((Color & 0xFF) << 16))
    }

    /**
     * Calls the DwmSetWindowAttribute function from the dwmapi library to set attributes of a window.
     * @param {number} dwAttribute - The attribute constant to set.
     * @param {number} [pvAttribute] - The value of the attribute to set. Optional parameter.
     * @returns {number} The result of the DllCall, typically indicating success or failure.
     * @see [MSDN](https://learn.microsoft.com/en-us/windows/win32/api/dwmapi/nf-dwmapi-dwmsetwindowattribute)
     */
    SetWindowAttribute(dwAttribute, pvAttribute?) => DllCall("dwmapi\DwmSetWindowAttribute", 'ptr', this.Hwnd, "uint", dwAttribute, "uint*", pvAttribute, "int", 4)

    /**
     * Sets the dark mode title bar for the window if the operating system version supports it.
     * @returns {number|undefined} The result of setting the window attribute, or undefined if not applicable.
     */
    SetDarkTitle()
    {
        if (attr := ((VerCompare(A_OSVersion, "10.0.18985") >= 0) ? 20 : (VerCompare(A_OSVersion, "10.0.17763") >= 0) ? 19 : 0))
            return this.SetWindowAttribute(attr, true)
    }

    ; Apply dark theme to all the context menus that is created by this script. 
    SetDarkMenu()
    {
        uxtheme             := DllCall("GetModuleHandle", "ptr", StrPtr("uxtheme"), "ptr")
        SetPreferredAppMode := DllCall("GetProcAddress", "ptr", uxtheme, "ptr", 135, "ptr")
        FlushMenuThemes     := DllCall("GetProcAddress", "ptr", uxtheme, "ptr", 136, "ptr")
        DllCall(SetPreferredAppMode, "int", 1)	
        DllCall(FlushMenuThemes)
    }

    /**
     * Send the message to the window or control, and then wait for confirmation.
     * @param {Integer} Msg
     * @param {Integer} [wParam=0]
     * @param {Integer} [lParam=0] 
     * @returns {Integer} 
     */
    SendMsg(Msg, wParam := 0, lParam := 0) {
        return SendMessage(Msg, wParam?, lParam?,, this)
    }

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
    OnMessage(Msg, Callback, MaxThreads?)
    {
        OnMessage(Msg, _callback, MaxThreads?)
        super.OnEvent("Close", g => OnMessage(Msg, _callback, 0))

        _callback(wParam, lParam, uMsg, hWnd) {
            try if (uMsg = Msg && hwnd = this.hwnd)
                return Callback(this, wParam, lParam, uMsg)
        }
    }

    class Control extends Gui.Control
    {
        static __New(p := this.Prototype, sp?)
        {
            sp := sp ?? super.Prototype
            for prop in p.OwnProps()
                if (!sp.HasMethod(prop) && !InStr(prop, "__")) 
                    sp.DefineProp(prop, p.GetOwnPropDesc(prop))

            if sp.HasMethod("OnMessage")
                p.DeleteProp("OnMessage")
        }

        /**
         * @property {Integer} X X position
         * @property {Integer} Y Y position
         * @property {Integer} W Width
         * @property {Integer} H Height
         */
        X := unset, Y := unset, W := unset, H := unset

        /**
         * Retrieves the dimensions of the bounding rectangle of the specified window. The dimensions are given in screen coordinates that are relative to the upper-left corner of the screen.  
         * [Learn more](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getclientrect)
         * @returns {RECT} 
         */
        GetWindowRect() => (DllCall("GetWindowRect", "ptr", this.hwnd, "ptr", _rc := GuiExt.RECT(), "uptr"), _rc)

        /**
         * Retrieves the coordinates of a window's client area. The client coordinates specify the upper-left and lower-right corners of the client area. Because client coordinates are relative to the upper-left corner of a window's client area, the coordinates of the upper-left corner are (0,0).  
         * [Learn more](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getclientrect)
         * @returns {RECT} 
         */        
        GetClientRect() => (DllCall("GetClientRect", "ptr", this.hwnd, "ptr", _rc := GuiExt.RECT(), "uptr"), _rc)

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
        OnMessage(Msg, Callback, AddRemove := 1)
        {
            static SubClasses := Map()
            static HookedMsgs := Map()

            if !SubClasses.Has(this.hwnd) {
                SubClasses[this.hwnd] := CallbackCreate(SubClassProc,, 6)
                HookedMsgs[this.hwnd] := Map(Msg, Callback.Bind(this))
                SetWindowSubclass(this, SubClasses[this.hwnd])
                OnExit(RemoveWindowSubclass)
                this.Gui.OnEvent("Close", RemoveWindowSubclass)
            }
            
            hm := HookedMsgs[this.hwnd]

            if AddRemove
                hm[Msg] := Callback.Bind(this)
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
                DetectHiddenWindows true
                
                for hwnd, cb in SubClasses.Clone() {
                    try if WinExist(hwnd) {
                        DllCall("RemoveWindowSubclass", "Ptr", hWnd, "Ptr", cb, "Ptr", hWnd)
                        CallbackFree(cb)
                    }
                    SubClasses.Delete(hwnd)
                }
                OnExit(RemoveWindowSubclass, 0)
            }
        }

        /**
         * Applies a specified theme to the window through the SetWindowTheme function from the uxtheme library.
         * @param {string} pszSubAppName - The name of the application's subcomponent to apply the theme to.
         * @param {string} [pszSubIdList] - A semicolon-separated list of class names to apply the theme to. Optional parameter.
         * @returns {boolean} True if the theme was set successfully, false otherwise.
         * @link https://learn.microsoft.com/en-us/windows/win32/api/uxtheme/nf-uxtheme-setwindowtheme
         */
        SetTheme(pszSubAppName, pszSubIdList := "") => (!DllCall("uxtheme\SetWindowTheme", "ptr", this.hwnd, "ptr", StrPtr(pszSubAppName), "ptr", pszSubIdList ? StrPtr(pszSubIdList) : 0) ? true : false)

        /**
         * Set the control's border style to rounded corners.
         * @param {Integer} [corner=9] The radius of the rounded corners.
         * @returns {void}
         */
        SetRounded(corner := 9)
        {
            static WM_SIZE := 0x0005
            
            SIZING(this)
            this.OnMessage(WM_SIZE, SIZING)

            SIZING(ctrl, wParam?, lParam?, msg?)
            {
                ctrl.Opt("+0x4000000")
                rc    := ctrl.GetClientRect()
                rcRgn := DllCall('Gdi32\CreateRoundRectRgn', 'int', rc.left + 3, 'int', rc.top + 3, 'int', rc.right - 3, 'int', rc.bottom - 3, 'int', corner, 'int', corner, 'ptr')
                DllCall("SetWindowRgn", "ptr", ctrl.hWnd, "ptr", rcRgn, "int", 1, "int")
                ctrl.Redraw()
                DllCall('Gdi32\DeleteObject', 'ptr', rcRgn, 'int')
            }
        }

        /**
         * Send the message to the window or control, and then wait for confirmation.
         * @param {Integer} Msg
         * @param {Integer} [wParam=0]
         * @param {Integer} [lParam=0] 
         * @returns {Integer} 
         */
        SendMsg(Msg, wParam := 0, lParam := 0) => (SendMessage(Msg, wParam?, lParam?, this))
    }

    ;;{ Gui.Addxxx methods:

    /**
     * Create a text control that the user cannot edit. Often used to label other controls.
     * @param Options V:    Sets the control's Name.
     *   Pos:  xn yn wn hn rn  Right Left Center Section
     *         VScroll  HScroll -Tabstop -Wrap
     *         BackgroundColor  BackgroundTrans
     *         Border  Theme  Disabled  Hidden
     * @param Text The text  
     * @returns {GuiExt.Control|GuiExt.Text}
     */
    AddText(Options?, Text?) => super.AddText(Options?, Text?)

    /**
     * Create controls such as text, buttons or checkboxes, and return a GuiControl object.
     * @param Options Limit Lowercase Multi Number Password ReadOnly
     *        Tn Uppercase WantCtrlA WantReturn WantTab
     *  V:    Sets the control's Name.
     *  Pos:  xn yn wn hn rn Right Left Center Section
     *        VScroll HScroll -Tabstop -Wrap
     *        BackgroundColor Border Theme Disabled Hidden
     * @param Text The text in the Edit  
     * @returns {GuiExt.Control|GuiExt.Edit|Gui.Edit}
     */
    AddEdit(Options?, Text?) => super.AddEdit(Options?, Text?)

    /**
     * Create UpDown control and return a GuiControl object.
     * @returns {GuiExt.Control|GuiExt.UpDown|Gui.UpDown}
     */
    AddUpDown(Options?, Text?) => super.AddUpDown(Options?, Text?)

    /**
     * Create Picture control and return a GuiControl object.
     * @returns {GuiExt.Control|GuiExt.Picture|Gui.Picture}
     */
    AddPicture(Options?, FileName?) => super.AddPicture(Options?, FileName?)

    /**
     * Create Picture control and return a GuiControl object.
     * @returns {GuiExt.Control|GuiExt.Picture|Gui.Picture}
     */
    AddPic(Options?, FileName?) => super.AddPicture(Options?, FileName?)

    /**
     * Adds a Button control and returns a GuiControl object.
     * @param Options Positioning and Sizing of Controls
     *   V:  Sets the control's Name.
     *   Positioning:  xn yn wn hn rn Right Left Center Section -Tabstop -Wrap
     *   BackgroundColor Border Theme Disabled Hidden
     * @param Text The text of the button  
     * @returns {GuiEx.Control}
     */
    AddButton(Options?, Text?) => super.AddButton(Options?, Text?)

    /**
     * Create Checkbox and return a GuiControl object.
     * GuiCtrl.Value returns the number 1 for checked, 0 for unchecked, and -1 for gray/indeterminate.
     * @param Options  V:           Sets the control's Name.
     *  Checked:     Start off checked
     *  Check3:      Enable a third "indeterminate" state that displays a gray checkmark
     *  CheckedGray: Start off checked or indeterminate
     *  CheckedN:    Set state: 0, 1 or -1
     *  Pos:         xn yn wn Right Left Center Section
     *               VScroll  HScroll -Tabstop -Wrap
     *               BackgroundColor  BackgroundTrans
     *               Border  Theme  Disabled  Hidden
     * @param Text The text of the Checkbox  
     * @returns {GuiExt.Control|GuiExt.Checkbox|Gui.Checkbox}
     */
    AddCheckbox(Options?, Text?) => super.AddCheckbox(Options?, Text?)

    /**
     * Create Radio control and return a GuiControl object.
     * GuiCtrl.Value returns the number 1 for checked, 0 for unchecked, and -1 for gray/indeterminate.
     * Events:       DoubleClick, Focus & LoseFocus
     * @param Options  V:           Sets the control's Name.
     *  Checked:     Start off checked
     *  CheckedN:    Set state: 0 or 1
     *  Group:       Start a new group
     *  Pos:         xn yn wn Right Left Center Section
     *               VScroll  HScroll -Tabstop -Wrap
     *               BackgroundColor  BackgroundTrans
     *               Border  Theme  Disabled  Hidden
     * @param Text The text of the Checkbox  
     * @returns {GuiExt.Control|GuiExt.Radio|Gui.Radio}
     */
    AddRadio(Options?, Text?) => super.AddRadio(Options?, Text?)

    /**
     * Create DropDownList control and return a GuiControl object.
     * @returns {GuiExt.Control|GuiExt.DropDownList|Gui.DropDownList}
     */
    AddDropDownList(Options?, Items?) => super.AddDropDownList(Options?, Items?)

    /**
     * Create DropDownList control and return a GuiControl object.
     * @returns {GuiExt.Control|GuiExt.DropDownList|Gui.DropDownList}
     */
    AddDDL(Options?, Items?) => super.AddDropDownList(Options?, Items?)


    /**
     * Create ComboBox control and return a GuiControl object.
     * @returns {GuiExt.Control|GuiExt.ComboBox|Gui.ComboBox}
     */
    AddComboBox(Options?, Items?) => super.AddComboBox(Options?, Items?)

    /**
     * Create ListBox control and return a GuiControl object.
     * @returns {GuiExt.Control|GuiExt.ListBox|Gui.ListBox}
     */
    AddListBox(Options?, Items?) => super.AddListBox(Options?, Items?)

    /**
     * Create ListView control and return a GuiControl object.
     * @returns {GuiExt.Control|GuiExt.ListView|Gui.ListView}
     */
    AddListView(Options?, Titles?) => super.AddListView(Options?, Titles?)

    /**
     * Create TreeView control and return a GuiControl object.
     * @returns {GuiExt.Control|GuiExt.TreeView|Gui.TreeView}
     */
    AddTreeView(Options?, Text?) => super.AddTreeView(Options?, Text?)

    /**
     * Create Link control and return a GuiControl object.
     * @returns {GuiExt.Control|GuiExt.Link|Gui.Link}
     */
    AddLink(Options?, Text?) => super.AddLink(Options?, Text?)

    /**
     * Create Hotkey control and return a GuiControl object.
     * @returns {GuiExt.Control|GuiExt.Hotkey|Gui.Hotkey}
     */
    AddHotkey(Options?, Text?) => super.AddHotkey(Options?, Text?)

    /**
     * Create DateTime control and return a GuiControl object.
     * @returns {GuiExt.Control|GuiExt.DateTime|Gui.DateTime}
     */
    AddDateTime(Options?, DateTime?) => super.AddDateTime(Options?, DateTime?)

    /**
     * Create MonthCal control and return a GuiControl object.
     * @returns {GuiExt.Control|GuiExt.MonthCal|Gui.MonthCal}
     */
    AddMonthCal(Options?, YYYYMMDD?) => super.AddMonthCal(Options?, YYYYMMDD?)

    /**
     * Create Slider control and return a GuiControl object.
     * @returns {GuiExt.Control|GuiExt.Slider|Gui.Slider}
     */
    AddSlider(Options?, Value?) => super.AddSlider(Options?, Value?)

    /**
     * Create Progress control and return a GuiControl object.
     * @returns {GuiExt.Control|GuiExt.Progress|Gui.Progress}
     */
    AddProgress(Options?, Value?) => super.AddProgress(Options?, Value?)

    /**
     * Create GroupBox control and return a GuiControl object.
     * @returns {GuiExt.Control|GuiExt.GroupBox|Gui.GroupBox}
     */
    AddGroupBox(Options?, Text?) => super.AddGroupBox(Options?, Text?)

    /**
     * Create Tab control and return a GuiControl object.
     * @returns {GuiExt.Control|GuiExt.Tab|Gui.Tab}
     */
    AddTab(Options?, Pages?) => super.AddTab(Options?, Pages?)

    /**
     * Create Tab2 control and return a GuiControl object.
     * @returns {GuiExt.Control|GuiExt.Tab2|Gui.Tab2}
     */
    AddTab2(Options?, Pages?) => super.AddTab2(Options?, Pages?)

    /**
     * Create Tab3 control and return a GuiControl object.
     * @returns {GuiExt.Control|GuiExt.Tab3|Gui.Tab3}
     */
    AddTab3(Options?, Pages?) => super.AddTab3(Options?, Pages?)

    /**
     * Create StatusBar control and return a GuiControl object.
     * @returns {GuiExt.Control|GuiExt.StatusBar|Gui.StatusBar}
     */
    AddStatusBar(Options?, Text?) => super.AddStatusBar(Options?, Text?)

    /**
     * Create ActiveX control and return a GuiControl object.
     * @returns {GuiExt.Control|GuiExt.ActiveX|Gui.ActiveX}
     */
    AddActiveX(Options?, Component?) => super.AddActiveX(Options?, Component?)

    /**
     * Create Custom controls and return a GuiControl object.
     * @returns {GuiExt.Control|GuiExt.Custom|Gui.Custom}
     */
    AddCustom(Win32Class?, Text?) => super.AddCustom(Win32Class?, Text?)

    ;;}
}

;; Examples

if !A_IsCompiled && A_LineFile = A_ScriptFullPath
    Example_GuiExt()

Example_GuiExt()
{
    static WM_LBUTTONDOWN   := 0x0201
    static WM_SETCURSOR     := 0x0020
    static WM_NCLBUTTONDOWN := 0x00A1
    static EN_KILLFOCUS     := 0x0200
    static WM_SIZING        := 0x0214
    static WM_MOVE          := 0x0003
    static WM_MOVING        := 0x0216
    
    /**
     * ### To ensure proper functioning of VSCode's Intelligence, you can:  
     * 1. Replace `Gui` object with `GuiExt`. (Recommended)
     * 2. Annotate the variable type as GuiExt above the line where you create a new Gui object instance.(Like the example below:)
     * @var {GuiExt} myGui
     * */
    myGui := Gui("-Caption +Resize")
    ; myGui := GuiExt("-Caption +Resize")
    
    myGui.SetFont("cWhite s16", "Segoe UI")
    myGui.BackColor := 0x202020
    
    myGui.OnEvent("Size", Size)
    myGui.OnMessage(WM_MOVING, (*) => myEdit.UpdatePos())

    myGui.OnEvent("Escape", (*) => ExitApp())
    
    ; Registers a function or method to be called whenever the Gui or GuiControl receives the specified message. [Check out the official document for more information.](https://www.autohotkey.com/docs/alpha/lib/GuiOnMessage.htm)
    myGui.OnMessage(WM_LBUTTONDOWN, DragWindow)

    ; Set Dark Titlebar
    myGui.SetDarkTitle()

    ; Set Dark ContextMenu
    myGui.SetDarkMenu()
    
    if (VerCompare(A_OSVersion, "10.0.22000") >= 0)
    {
        ; Set Rounded Window (Requires win 11)
        myGui.SetWindowAttribute(33, 2)
    
        ; Remove the window border. (Requires win 11)
        ; Do not set this if you're creating a borderless window with `SetBorderless` method.
        ; myGui.SetWindowColor(, , -1)
    
        ; Set Mica (Alt) background. (Requires win 11 build 22600)
        ; [Learn more](https://learn.microsoft.com/en-us/windows/apps/design/style/mica#app-layering-with-mica-alt)
        if (VerCompare(A_OSVersion, "10.0.22600") >= 0)
            myGui.SetWindowAttribute(38, 4)
    }
    
    ; Set the borderless 
    myGui.SetBorderless(6, BorderlessCallback, 500, 500, 500, 500)
    
    ; Gui Control objects created in this way do not work with VSCode's IntelliSense. Create an Edit control as shown below.
    text := myGui.Add("Text", "Backgroundcaa2031 cwhite Center R1.5 0x200 w280", "Rounded Text Control")
    
    ; Set Rounded Control
    text.SetRounded()
     
    myEdit := myGui.Add("Edit", "vEdit -WantReturn -TabStop w300 h150 -E0x200 -HScroll -VScroll +Multi +ReadOnly cwhite Background" myGui.BackColor)
    myEdit.SetFont(, "Consolas")
    
    ; Set Edit Control theme
    myEdit.SetTheme("DarkMode_Explorer")
    
    myEdit.UpdatePos := (ctrl => (ctrl.Value := 
    (
        "x: " myGui.X "
        y: " myGui.Y "
        w: " myGui.W "
        h: " myGui.H
    )))
    
    ; Hide the blinking caret 
    myEdit.OnEvent("Focus", (gCtrl, *) => (DllCall("HideCaret", "ptr", gCtrl.hWnd, "int"), gCtrl.SendMsg(EN_KILLFOCUS)))
    
    myEdit.OnMessage(WM_SETCURSOR, SetCursor)
    
    myGui.Show("w300 AutoSize")
    myGui.Opt("MinSize")

    ; Send Message to the gui or gui control
    myEdit.SendMsg(EN_KILLFOCUS)

    WinRedraw(myGui)
    WinWaitClose(myGui)
    
    BorderlessCallback(g, x, y) {
        if !g["Edit"]
            return 
        WinGetPos(, &eY,,, g["Edit"])
        return y <= eY
    }
    
    /**
     * @param {GuiExt|Gui} GuiObj 
     * @param {Integer} MinMax 
     * @param {Integer} Width 
     * @param {Integer} Height 
     */
    Size(GuiObj, MinMax, Width, Height)
    {
        Critical("Off")
        SetWinDelay(-1), SetControlDelay(-1)
    
        ; Moving Controls
        myEdit.W := text.W := Width - (GuiObj.MarginX*2)
        myEdit.H := Height - (GuiObj.MarginY*2)
        myEdit.UpdatePos()
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
}

/*
Example_SetBorderless()
{
    myGui := GuiExt("-Caption +Resize")
    myGui.SetFont("cWhite s16", "Segoe UI")
    myGui.SetDarkTitle()
    myGui.SetDarkMenu()

    myGui.BackColor := 0x202020
    text            := myGui.AddText("vTitlebar Backgroundcaa2031 cwhite Center R1.5 0x200 w280", "Titlebar Area")
    
    text.Base := GuiExt.Control

    text.SetRounded()

    myGui.OnEvent('Size', Size)

    ;Set Mica (Alt) background. (Supported starting with Windows 11 Build 22000.) 
    if (VerCompare(A_OSVersion, "10.0.22600") >= 0)
        myGui.SetWindowAttribute(38, 4)

    myGui.SetBorderless(6, (g, x, y) => (y <= g['Titlebar'].GetWindowRect().bottom), 500, 500, 500, 500)

    myGui.Show("h500")

    Size(g, minmax, width, height)
    {
        SetControlDelay(-1)
        ; Set titlebar's width to fix the gui.
        g["Titlebar"].W := (width - (g.MarginX*2))
    }
}