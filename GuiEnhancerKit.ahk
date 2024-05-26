/************************************************************************
 * @description Elevate your AHK Gui development with extended methods and properties.
 * @file GuiEnhancerKit.ahk
 * @author Nikola Perovic
 * @link https://github.com/nperovic/GuiEnhancerKit
 * @date 2024/05/26
 * @version 1.0.0
 ***********************************************************************/

#Requires AutoHotkey v2.0.15

class GuiExt extends Gui
{
    static __New()
    {
		proto     := super.Prototype
		ctrlProto := super.Control.Prototype

        if (VerCompare(A_AhkVersion, "2.1-alpha.7") < 0) {
            proto.OnMessage     := this.OnMessage_Gui.Bind(this)
            ctrlProto.OnMessage := this.OnMessage_Ctrl.Bind(this)
        }

		ctrlProto.SendMsg        := this.SendMsg.Bind(this)
		ctrlProto.SetRounded     := this.SetRoundedCtrl.Bind(this)
		ctrlProto.SetTheme       := this.SetTheme.Bind(this)
		proto.SendMsg            := this.SendMsg.Bind(this)
		proto.SetDarkMenu        := this.SetDarkMenu.Bind(this)
		proto.SetDarkTitle       := this.SetDarkTitle.Bind(this)
		proto.SetWindowColor     := this.SetWindowColor.Bind(this)
		proto.SetWindowAttribute := this.SetWindowAttribute.Bind(this)

        for prop in ["x", "y", "w", "h"] {
            proto.DefineProp(prop, {Get: GetPos.Bind(prop), Set: SetPos.Bind(prop)})
            ctrlProto.DefineProp(prop, {Get: GetPos.Bind(prop), Set: SetPos.Bind(prop)})
        }

        GetPos(prop, obj) => (obj.GetPos(&x, &y, &w, &h), %prop%)
        SetPos(prop, obj, value) {
            SetWinDelay(-1), SetControlDelay(-1)
            %prop% := value
            obj.Move(x?, y?, w?, h?)
        }
    }

    static SetTheme(obj, pszSubAppName, pszSubIdList := "") => (!DllCall("uxtheme\SetWindowTheme", "ptr", obj.hwnd, "ptr", StrPtr(pszSubAppName), "ptr", pszSubIdList ? StrPtr(pszSubIdList) : 0) ? true : false)

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
	static SetWindowColor(guiObj, titleText?, titleBackground?, border?)
	{
        static DWMWA_BORDER_COLOR  := 34
        static DWMWA_CAPTION_COLOR := 35
        static DWMWA_TEXT_COLOR    := 36
        static SetClrMap           := Map(DWMWA_BORDER_COLOR, "border", DWMWA_CAPTION_COLOR, "titleBackground", DWMWA_TEXT_COLOR, "titleText")
		
		if (VerCompare(A_OSVersion, "10.0.22200") < 0)
			return MsgBox("This is supported starting with Windows 11 Build 22000.", "OS Version Not Supported.")

        for attr, var in SetClrMap
            if (%var%??0)
                guiObj.SetWindowAttribute(attr, RgbToBgr(%var% is string && !InStr(%var%, "0x") ? Number("0x" %var%) : %var%))

        RgbToBgr(color) => (((Color >> 16) & 0xFF) | (Color & 0x00FF00) | ((Color & 0xFF) << 16))
	}

    static SetWindowAttribute(obj, dwAttribute, pvAttribute?) => DllCall("dwmapi\DwmSetWindowAttribute", 'ptr', obj.Hwnd, "uint", dwAttribute, "uint*", pvAttribute, "int", 4)

	Static SetDarkTitle(obj)
	{
		if (attr := ((VerCompare(A_OSVersion, "10.0.18985") >= 0) ? 20 : (VerCompare(A_OSVersion, "10.0.17763") >= 0) ? 19 : 0))
		    return obj.SetWindowAttribute(attr, true)
	}

	static SetRoundedCtrl(ctrl, coner := 9)
	{		
        ctrl.Opt("+0x4000000")
		DllCall("GetClientRect", "ptr", ctrl.Hwnd, "ptr", rc := Buffer(16, 0), "int")
		rcRgn := DllCall('Gdi32\CreateRoundRectRgn', 'int', NumGet(rc, 0, "int") + 3, 'int', NumGet(rc, 4, "int") + 3, 'int', NumGet(rc, 8, "int") - 3, 'int', NumGet(rc, 12, "int") - 3, 'int', coner, 'int', coner, 'ptr')
		DllCall("User32\SetWindowRgn", "ptr", ctrl.hWnd, "ptr", rcRgn, "int", 1, "int")
        ctrl.Redraw()
        DllCall('Gdi32\DeleteObject', 'ptr', rcRgn, 'int')
	}

	Static SetDarkMenu(obj?)
	{
		uxtheme             := DllCall("GetModuleHandle", "ptr", StrPtr("uxtheme"), "ptr")
		SetPreferredAppMode := DllCall("GetProcAddress", "ptr", uxtheme, "ptr", 135, "ptr")
		FlushMenuThemes     := DllCall("GetProcAddress", "ptr", uxtheme, "ptr", 136, "ptr")
		DllCall(SetPreferredAppMode, "int", 1)	
		DllCall(FlushMenuThemes)
	}
 
    static SendMsg(obj, Msg, wParam?, lParam?) => SendMessage(Msg, wParam?, lParam?, obj)

    /**
     * Registers a function or method to be called whenever the Gui or GuiControl receives the specified message. 
     */
    static OnMessage_Ctrl(obj, Msg, Callback, AddRemove := 1)
    {
        static SubClasses := Map()
        static HookedMsgs := Map()

        if !SubClasses.Has(obj.hwnd) {
            SubClasses[obj.hwnd] := CallbackCreate(SubClassProc)
            HookedMsgs[obj.hwnd] := Map(Msg, Callback.Bind(obj))
            SetWindowSubclass(obj, SubClasses[obj.hwnd])
            obj.Gui.OnEvent("Close", RemoveWindowSubclass)
        }
        
        hm := HookedMsgs[obj.hwnd]

        if AddRemove
            hm[Msg] := Callback.Bind(obj)
        else if hm.Has(Msg)
            hm.Delete(Msg)

        ; ==============================================================
        
        SubClassProc(hWnd, uMsg, wParam, lParam, uIdSubclass, dwRefData)
        {
            if HookedMsgs[uIdSubclass].Has(uMsg) {
                reply := HookedMsgs[uIdSubclass][uMsg](wParam, lParam, uMsg)
                if IsSet(reply)
                    return reply
            }

            return DefSubclassProc(hwnd, uMsg, wParam, lParam)
        }

        DefSubclassProc(hwnd, uMsg, wParam, lParam) => DllCall("DefSubclassProc", "Ptr", hwnd, "UInt", uMsg, "Ptr", wParam, "Ptr", lParam, "Ptr")

        SetWindowSubclass(obj, cb) => DllCall("SetWindowSubclass", "Ptr", obj.hwnd, "Ptr", cb, "Ptr", obj.hwnd, "Ptr", 0)

        RemoveWindowSubclass(*)
        {
            for hwnd, cb in SubClasses 
                try (DllCall("RemoveWindowSubclass", "Ptr", hWnd, "Ptr", cb, "Ptr", hWnd), CallbackFree(cb))
        }
    }

    static OnMessage_Gui(obj, Msg, Callback, AddRemove?)
    {
        OnMessage(Msg, _callback, AddRemove?)
        obj.OnEvent("Close", g => OnMessage(Msg, _callback, 0))

        _callback(wParam, lParam, uMsg, hWnd)
        {
            try if (uMsg = Msg && hwnd = obj.hwnd)
                return Callback(obj, wParam, lParam, uMsg)
        }
    }
}


/*
; Examples

WM_LBUTTONDOWN   := 0x0201
WM_SETCURSOR     := 0x0020
WM_NCLBUTTONDOWN := 0x00A1
EN_KILLFOCUS     := 0x0200

myGui := Gui("-Caption +Resize")
myGui.SetFont("cWhite s16", "Segoe UI")
myGui.BackColor := 0x202020

text := myGui.AddText("Backgroundcaa2031 cwhite Center R1.5 0x200 w280 0x4000000", "Rounded Text Control")

; Set Rounded Control
text.SetRounded()

myEdit := myGui.Add("Edit", "-WantReturn -TabStop w300 h300 -E0x200 -HScroll -VScroll +Multi +ReadOnly cwhite Background" myGui.BackColor, "123`n456`n789")

myEdit.OnEvent("Focus", (myEdit, *) => (
    DllCall("User32\HideCaret", "ptr", myEdit.hWnd, "int"),
    myEdit.SendMsg(EN_KILLFOCUS)
))

myGui.OnEvent("Size", Size)

; Registers a function or method to be called whenever the Gui or GuiControl receives the specified message. [Check out the official document for more information.](https://www.autohotkey.com/docs/alpha/lib/GuiOnMessage.htm)
myGui.OnMessage(WM_LBUTTONDOWN, DragWindow)
myEdit.OnMessage(WM_LBUTTONDOWN, DragWindow)
myEdit.OnMessage(WM_SETCURSOR, SetCursor)

; Set Dark Titlebar
myGui.SetDarkTitle()

; Set Rounded Window (win 11+)
myGui.SetWindowAttribute(33, 2)

; Set Titlebar background color the same as the gui background and remove the window border
myGui.SetWindowColor(, myGui.BackColor, myGui.BackColor)

; Set Dark ContextMenu
myGui.SetDarkMenu()

; Set Edit Control theme
myEdit.SetTheme("DarkMode_Explorer")

myGui.Show("w300 h300")
myGui.Opt("MinSize")

; Send Message to the gui or gui control
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
