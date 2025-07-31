; This script was created partially using Pulover's Macro Creator
; www.macrocreator.com
#Requires AutoHotkey v1.1+
#NoEnv
SetWorkingDir %A_ScriptDir%
; #Include, %A_ScriptDir%\Gdip_All.ahk
#Include <Gdip_All>
#Include <FindText>
#Include <OCR>
#Include <Jxon>
#Include <SQLite>
#Include <ObjectSort>
CoordMode, Mouse, Screen
SendMode Input
#SingleInstance Force
SetTitleMatchMode 2
#WinActivateForce
SetControlDelay 1
SetWinDelay 0
SetKeyDelay -1
SetMouseDelay -1
SetBatchLines -1

CoordMode, Pixel, Screen

; F3:: ; For testing stuff
; ManualRollDetect()
; ; ManualSaveID()

; Return

; TODO: Better target SSR detection (unique pixel check?)
; TODO: Find alternative to excessive FileIntall usage

NORMAL_TEXT := 0x794016
RED_EXCLAMATION := 0xFF6943
CONFIRM := 0x88D108
CONFIRM2 := 0x94d708
GREYED_OUT_CONFIRM := 0x5E8605
SCOUT := 0xd9683e
KITA_HAIR := 0x45434c
KITA_CARD_COLOR := 0xfffa69

Intro:
    SysGet, MonitorCount, MonitorCount
    Gui -MinimizeBox -MaximizeBox -SysMenu
    Gui Add, Text, x32 y30 w309 h23 +0x200, Enter the age date that will be used for each reroll (e.g. 199101)
    Gui Add, Edit, hWndhEdtValue vdate x32 y53 w121 h21, 199101
    Gui Add, Text, x32 y90 w247 h23 +0x200, Enter the username that will be used for each reroll
    Gui Add, Edit, hWndhEdtValue2 vname x31 y113 w121 h21, PraiseRNG
    Gui Add, Text, x31 y150 w375 h23 +0x200, Enter the password that will be used for data link (This is not stored anywhere)
    Gui Add, Edit, hWndhEdtValue3 vpass x31 y173 w121 h21

    Gui Add, Text, x31 y210 w375 h23 +0x200, Choose banner to roll on
    Gui Add, DropDownList, vBannerDropdown x31 y233 w200 +AltSubmit Choose1, Loading...

    Gui Add, Text, x31 y270 w400 h23 +0x200, Number of target SSR obtained to save account
    TargetNum_TT := "The minimum amount of the target banner SSR obtained to Data Link and screenshot an account.`nIf the account did not get at least this many, the script will not Data Link or screenshot it.`nSet to 0 to save all accounts."
    Gui Add, Edit, vTargetNum x32 y293 w121 h21 +Limit1
    Gui, Add, UpDown, Range0-5, 2

    Gui Add, Text, x31 y330 w400 h23 +0x200, Choose which monitor to roll on (defaults to main display)
    Gui Add, DropDownList, hWndComboBox vMonitorDropdown x31 y353 w120 +AltSubmit Choose1

    Gui Add, CheckBox, hWndhChk vpreDataLink x31 y390 w350 h22 +Checked, Set Data Link for current account (Must be logged in already)
    Gui Add, CheckBox, hWndhChk2 vMoreScreenshots x31 y413 w350 h22, Take a screenshot for each x10 roll
    Gui Add, Button, vOK x270 y470 w80 h23, &OK

    Gui, Font, cDefault
    Gui Add, Text, x430 y40 w260, Welcome to UUR (Ultimate Uma Reroller)!`nThis script will infinitely reroll on the chosen banner. `n`n`nThis is the order of operations: `n  - deletes the current account`n - makes a new one`n  - grabs the carats from the gifts and rolls until out`n  - If the target SSR obtained treshold is met:`n    - takes a screenshot of the List view of Support Cards`n    - sets up a Data Link and takes a screenshot of the trainer ID`n    - saves the trainer ID and amount of target SSRs obtained to a text file, then restarts the process`n`n`n`nThe script will start after pressing the OK button. `nPress Shift+Escape to stop the script at any time.

    ; Get monitors and fill in dropdown
    Loop, %MonitorCount%
    {
        SysGet, MonitorName, MonitorName, %A_Index%
        if (MonitorName = "")
            MonitorName := "Monitor " . A_Index
        GuiControl, , MonitorDropdown, %MonitorName%
    }
    SysGet, MonitorMain, MonitorPrimary
    GuiControl, Choose, MonitorDropdown, %MonitorMain%

    Gui Show, w700 h520, UUR Options

    ; Get current banners and fill in dropdown, timer used for pseudo-async
    GuiControl, Disable, OK ; Disable starting the script until the banners are fetched
    SetTimer, AsyncBanner, 10

    OnMessage(0x200, "WM_MOUSEMOVE")
Return

; Credit to Rogers on AHK forum for mouse over tooltip
WM_MOUSEMOVE()
{
    static CurrControl, PrevControl, _TT  ; _TT is kept blank for use by the ToolTip command below.
    CurrControl := A_GuiControl
    If (CurrControl <> PrevControl and not InStr(CurrControl, " "))
    {
        ToolTip  ; Turn off any previous tooltip.
        SetTimer, DisplayToolTip, 1000
        PrevControl := CurrControl
    }
    return

    DisplayToolTip:
    SetTimer, DisplayToolTip, Off
    ToolTip % %CurrControl%_TT  ; The leading percent sign tell it to use an expression.
    SetTimer, RemoveToolTip, 10000
    return

    RemoveToolTip:
    SetTimer, RemoveToolTip, Off
    ToolTip
    return
}

ButtonOK:
    Gui Submit
    If (pass = "")
    {
        MsgBox, 0, , Please enter a password for Data Link.
        Gui Show
        Return
    }
    If (!RegExMatch(pass, "^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,16}$"))
    {
        MsgBox, 0, , Password must be between 8 - 16 characters and have at least one number, one lowercase letter and one uppercase letter.
        Gui Show
        Return
    }
    Gui Hide
    Gosub, Macro1
ExitApp
Return

Macro1:
    SSRs := 0
    SRs := 0
    Rs := 0
    rollResults := []
    onTitleScreen := 0
    preLinkDone := 0
    timeStarted := A_Now
    targetSSR := 0 ; Target SSR gotten per account roll
    SysGet, resolution, Monitor, %MonitorDropdown%

    Loop
    {
        global targetSSR, preLinkDone, onTitleScreen
        targetSSR := 0
        WinActivate, Umamusume ahk_class UnityWndClass
        Sleep, 333
        WinWaitActive, Umamusume ahk_class UnityWndClass, , 10
        If (ErrorLevel)
        {
            MsgBox, 0, , Umamusume not found. Please start the game first.
            Gui Show
        }
        Sleep, 333
        WinShow, Umamusume ahk_class UnityWndClass
        Sleep, 333
        x1 := scaleX(81)
        y1 := scaleY(1297)
        x2 := scaleX(163)
        y2 := scaleY(1358)

        PixelSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, 0x005CAD, 0, Fast RGB
        If (ErrorLevel = 0)
        {
            onTitleScreen := 1
        }
        Else
        {
            onTitleScreen := 0
        }
        If (preDataLink = 1 and preLinkDone = 0 and onTitleScreen = 1)
        {
            MsgBox, 0, , Title screen detected. Please sign in first to Link Data the current account before rerolling. Script terminating.
            ExitApp
        }
        If (preDataLink = 1 and preLinkDone = 0 and onTitleScreen = 0)
        {
            DataLink(pass)
            preLinkDone := 1
            Sleep, 1000
        }
        x1 := scaleX(1420)
        y1 := scaleY(884)
        x2 := scaleX(2182)
        y2 := scaleY(1261)

        ; ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250717110651.png
        PixelSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, 0x39DEE7, 0, Fast RGB
        Sleep, 100
        If (ErrorLevel = 0)
        {
            Sleep, 500
            click1 := scaleX(2005)
            click2 := scaleY(1204)
            Click, %click1%, %click2% Left, 1  ; Find and click Title Screen button from main logged in screen
            Sleep, 100
        }
        Else
        {
            Sleep, 500
            Loop
            {
                x1 := scaleX(926)
                y1 := scaleY(1031)
                x2 := scaleX(999)
                y2 := scaleY(1061)

                PixelSearch, FoundX, FoundX, %x1%, %y1%, %x2%, %y2%, 0xFF3300, 0, Fast RGB
                Sleep, 10
                If (ErrorLevel)
                {
                    click1 := scaleX(2454)
                    click2 := scaleY(1343)
                    Click, %click1%, %click2% Left, 1  ; Find hamburger menu on title screen
                    Sleep, 800
                }
                Else
                {
                    Break
                }
            }
        }
        Loop
        {
            x1 := scaleX(926)
            y1 := scaleY(1031)
            x2 := scaleX(999)
            y2 := scaleY(1061)

            PixelSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, 0xFF3300, 0, Fast RGB
            Sleep, 10
            If (ErrorLevel)
            {
                click1 := scaleX(2454)
                click2 := scaleY(1343)
                Click, %click1%, %click2% Left, 1  ; Find hamburger menu on title screen
                Sleep, 800
            }
            Else
            {
                Break
            }
        }
        Sleep, 300
        click1 := scaleX(1408)
        click2 := scaleY(955)
        Click, %click1%, %click2% Left, 1  ; Click delete data
        Sleep, 100
        Sleep, 300
        x1 := scaleX(1284)
        y1 := scaleY(890)
        x2 := scaleX(1628)
        y2 := scaleY(990)
        Loop
        {
            PixelSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, 0x9DDB05, 0, Fast RGB
            Sleep, 100
        }
        Until ErrorLevel = 0
        If (ErrorLevel = 0)
        {
            click1 := scaleX(1408)
            click2 := scaleY(955)
            Click, %click1%, %click2% Left, 1  ; Check it's been clicked and click it again
            Sleep, 10
        }
        Sleep, 500
        x1 := scaleX(1294)
        y1 := scaleY(886)
        x2 := scaleX(1624)
        y2 := scaleY(993)
        Loop
        {
            PixelSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, 0x9CDB05, 0, Fast RGB
            Sleep, 100
        }
        Until ErrorLevel = 0
        If (ErrorLevel = 0)
        {
            click1 := scaleX(1408)
            click2 := scaleY(955)
            Click, %click1%, %click2% Left, 1  ; Check it's been clicked and click it again
            Sleep, 500
        }
        ; x1 := scaleX(1288)
        ; y1 := scaleY(677)
        ; x2 := scaleX(1402)
        ; y2 := scaleY(712)
        x1 := scaleX(1293)
        y1 := scaleY(681)
        x2 := scaleX(1388)
        y2 := scaleY(713)
        Loop
        {
            ; screen := GetScreenshot(x1, y1, x2, y2, "deleted")
            ; ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %screen%
            PixelSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, 0x794016, 0, Fast RGB
            Sleep, 100
        }
        Until ErrorLevel = 0
        If (ErrorLevel = 0)
        {
            click1 := scaleX(1290)
            click2 := scaleY(940)
            Click, %click1%, %click2% Left, 1  ; Close out of user deleted confirmation
            Sleep, 10
            Sleep, 500
        }
        Loop
        {
            x1 := scaleX(932)
            y1 := scaleY(620)
            x2 := scaleX(978)
            y2 := scaleY(660)

            PixelSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, 0x794016, 0, Fast RGB
            If (ErrorLevel)
            {
                click1 := scaleX(1929)
                click2 := scaleY(925)
                Click, %click1%, %click2% Left, 1  ; Click screen to skip stuff until terms shows up
                Sleep, 100
            }
            Else
            {
                Break
            }
        }
        Sleep, 500
        click1 := scaleX(1561)
        click2 := scaleY(642)
        Click, %click1%, %click2% Left, 1  ; Accept terms and conditions
        Sleep, 100
        WinWaitNotActive, Umamusume ahk_class UnityWndClass, , 10
        Sleep, 333
        IfWinNotActive, Umamusume ahk_class UnityWndClass
        {
            Send, {Control Down}{w}{Control Up}
            Sleep, 100
            WinActivate, Umamusume ahk_class UnityWndClass
            Sleep, 333
        }
        Loop
        {
            x1 := scaleX(932)
            y1 := scaleY(620)
            x2 := scaleX(978)
            y2 := scaleY(660)

            PixelSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, 0x794016, 0, Fast RGB
            Sleep, 10
        }
        Until ErrorLevel = 0
        If (ErrorLevel = 0)
        {
            click1 := scaleX(1557)
            click2 := scaleY(796)
            Click, %click1%, %click2% Left, 1  ; Accept terms and conditions
            Sleep, 100
        }
        WinWaitNotActive, Umamusume ahk_class UnityWndClass, , 10
        Sleep, 333
        IfWinNotActive, Umamusume ahk_class UnityWndClass
        {
            Send, {Control Down}{w}{Control Up}
            Sleep, 100
            WinActivate, Umamusume ahk_class UnityWndClass
            Sleep, 333
        }
        Loop
        {
            PixelSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, 0x794016, 0, Fast RGB
            Sleep, 100
        }
        Until ErrorLevel = 0
        If (ErrorLevel = 0)
        {
            click1 := scaleX(1449)
            click2 := scaleY(1037)
            Click, %click1%, %click2% Left, 1  ; Check it's been clicked and click it again
            Sleep, 100
        }
        x1 := scaleX(1296)
        y1 := scaleY(892)
        x2 := scaleX(1619)
        y2 := scaleY(986)
        Loop
        {
            PixelSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, 0x538105, 2, Fast RGB
            Sleep, 100
        }
        Until ErrorLevel = 0
        If (ErrorLevel = 0)
        {
            Sleep, 500
            click1 := scaleX(1546)
            click2 := scaleY(746)
            Click, %click1%, %click2% Left, 1  ; Choose country
            Sleep, 100
        }
        Sleep, 500
        x1 := scaleX(1023)
        y1 := scaleY(467)
        x2 := scaleX(1128)
        y2 := scaleY(494)
        Loop
        {
            ; screen := GetScreenshot("country")
            ; ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %screen%
            PixelSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, 0xFFF4C6, 2, Fast RGB
            Sleep, 100
        }
        Until ErrorLevel = 0
        If (ErrorLevel = 0)
        {
            click1 := scaleX(1462)
            click2 := scaleY(1034)
            Click, %click1%, %click2% Left, 1  ; Check it's been clicked and click it again
            Sleep, 100
        }
        Sleep, 500
        x1 := scaleX(1293)
        y1 := scaleY(890)
        x2 := scaleX(1630)
        y2 := scaleY(993)
        Loop
        {
            ; ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, *2 %A_ScriptDir%\Screenshots\Screen_20250717224357.png
            PixelSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, 0x88D108, 2, Fast RGB
            Sleep, 100
        }
        Until ErrorLevel = 0
        If (ErrorLevel = 0)
        {
            click1 := scaleX(1449)
            click2 := scaleY(938)
            Click, %click1%, %click2% Left, 1  ; Check it's been clicked and click it again
            Sleep, 100
        }
        Sleep, 300
        x1 := scaleX(960)
        y1 := scaleY(810)
        x2 := scaleX(1093)
        y2 := scaleY(868)
        Loop
        {
            ; ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250718112853.png
            PixelSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, 0xFF6943, 2, Fast RGB
            Sleep, 100
        }
        Until ErrorLevel = 0
        If (ErrorLevel = 0)
        {
            click1 := scaleX(1254)
            click2 := scaleY(751)
            Click, %click1%, %click2% Left, 1  ; Age confirmation
            Sleep, 10
            Sleep, 300
            SendRaw, %date%
        }
        Loop
        {
            ; ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250718112853.png
            PixelSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, 0xFF6943, 2, Fast RGB
            Sleep, 100
        }
        Until ErrorLevel = 0
        If (ErrorLevel = 0)
        {
            click1 := scaleX(1456)
            click2 := scaleY(935)
            Click, %click1%, %click2% Left, 1  ; Check if text was entered and accept
            Sleep, 500
        }
        ;! Insert connection check here, needs more testing.
        /*
        x1 := scaleX(1246)
        y1 := scaleY(657)
        x2 := scaleX(1476)
        y2 := scaleY(696)
        PixelSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, 0x794016, 0, Fast RGB
        click1 := scaleX(1290)
        click2 := scaleY(940)
        Click, %click1%, %click2% Left, 1  ; Click go back to title screen if connection error occurs
        */
        x1 := scaleX(1300)
        y1 := scaleY(894)
        x2 := scaleX(1421)
        y2 := scaleY(991)
        Loop
        {
            ; ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250718095256.png
            PixelSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, 0x91D608, 2, Fast RGB
            Sleep, 100
        }
        Until ErrorLevel = 0
        If (ErrorLevel = 0)
        {
            Sleep, 500
            click1 := scaleX(1460)
            click2 := scaleY(945)
            Click, %click1%, %click2% Left, 1  ; Skip tutorial
            Sleep, 100
        }
        x1 := scaleX(1104)
        y1 := scaleY(892)
        x2 := scaleX(1456)
        y2 := scaleY(992)
        Loop
        {
            ; ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250718095329.png
            PixelSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, 0x5E8605, 2, Fast RGB
            Sleep, 100
        }
        Until ErrorLevel = 0
        If (ErrorLevel = 0)
        {
            click1 := scaleX(1306)
            click2 := scaleY(646)
            Click, %click1%, %click2% Left, 1  ; Skip tutorial
            Sleep, 500
            SendRaw, %name%
        }
        Sleep, 100
        click1 := scaleX(1279)
        click2 := scaleY(812)
        Click, %click1%, %click2% Left, 1  ; Check if text was entered and accept
        Sleep, 100
        Sleep, 500
        x1 := scaleX(1311)
        y1 := scaleY(899)
        x2 := scaleX(1444)
        y2 := scaleY(980)
        Loop
        {
            PixelSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, 0x84CB02, 0, Fast RGB
            Sleep, 100
        }
        Until ErrorLevel = 0
        If (ErrorLevel = 0)
        {
            click1 := scaleX(1279)
            click2 := scaleY(938)
            Click, %click1%, %click2% Left, 1  ; Check that register can be clicked
            Sleep, 10
        }
        Sleep, 2000
        x1 := scaleX(1495)
        y1 := scaleY(898)
        x2 := scaleX(1621)
        y2 := scaleY(977)
        Loop
        {
            PixelSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, 0x97D705, 0, Fast RGB
            Sleep, 100
        }
        Until ErrorLevel = 0
        If (ErrorLevel = 0)
        {
            click1 := scaleX(1453)
            click2 := scaleY(944)
            Click, %click1%, %click2% Left, 1  ; Check that register can be clicked
            Sleep, 100
        }
        ; x1 := scaleX(1007)
        ; y1 := scaleY(1383)
        ; x2 := scaleX(1109)
        ; y2 := scaleY(1420)
        x1 := scaleX(1021) ; Find scout
        y1 := scaleY(1347)
        x2 := scaleX(1048)
        y2 := scaleY(1374)
        Loop
        {
            ; screen := GetScreenshot(x1, y1, x2, y2, "scout")
            ; ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %screen%
            PixelSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, 0xd9683e, 0, Fast RGB ; Find scout
            Sleep, 10
            If (ErrorLevel)
            {
                click1 := scaleX(1202)
                click2 := scaleY(1378)
                Click, %click1%, %click2% Left, 1  ; Keep skipping new player stuff until Home screen appears
                Sleep, 100
            }
            Else
            {
                Break
            }
        }
        Sleep, 1000
        ; x1 := scaleX(628)
        ; y1 := scaleY(909)
        ; x2 := scaleX(867)
        ; y2 := scaleY(970)
        x1 := scaleX(680)
        y1 := scaleY(921)
        x2 := scaleX(788)
        y2 := scaleY(960)
        Loop
        {
            ; ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250718111349.png
            PixelSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, 0x794016, 0, Fast RGB ; Find close button
            Sleep, 100
        }
        Until ErrorLevel = 0
        If (ErrorLevel = 0)
        {
            click1 := scaleX(749)
            click2 := scaleY(1336)
            Click, %click1%, %click2% Left, 1 ; Close new story popup
            Sleep, 100
        }
        Sleep, 1000
        ; x1 := scaleX(641)
        ; y1 := scaleY(1295)
        ; x2 := scaleX(836)
        ; y2 := scaleY(1367)
        x1 := scaleX(689)
        y1 := scaleY(1311)
        x2 := scaleX(799)
        y2 := scaleY(1353)
        Loop
        {
            ; ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250718111434.png
            PixelSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, 0x794016, 0, Fast RGB ; Find second close button
            Sleep, 100
        }
        Until ErrorLevel = 0
        If (ErrorLevel = 0)
        {
            click1 := scaleX(749)
            click2 := scaleY(1336)
            Click, %click1%, %click2% Left, 1 ; Close notices popup
            Sleep, 10
        }
        ; x1 := scaleX(990)
        ; y1 := scaleY(1345)
        ; x2 := scaleX(1153)
        ; y2 := scaleY(1438)
        x1 := scaleX(1021)
        y1 := scaleY(1347)
        x2 := scaleX(1048)
        y2 := scaleY(1374)
        Loop
        {
            ; ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250718095916.png
            PixelSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, 0xd9683e, 0, Fast RGB
            Sleep, 100
        }
        Until ErrorLevel = 0
        If (ErrorLevel = 0)
        {
            click1 := scaleX(1070)
            click2 := scaleY(1026)
            Click, %click1%, %click2% Left, 1
            Sleep, 10
        }
        x1 := scaleX(752)
        y1 := scaleY(1284)
        x2 := scaleX(1085)
        y2 := scaleY(1380)
        Loop
        {
            ; ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250717215840.png
            PixelSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %CONFIRM2%, 0, Fast RGB
            Sleep, 100
        }
        Until ErrorLevel = 0
        If (ErrorLevel = 0)
        {
            Sleep, 500
            click1 := scaleX(896)
            click2 := scaleY(1330)
            Click, %click1%, %click2% Left, 1  ; Get gifts
        }
        Sleep, 5000 ; Sometimes this takes a long time
        ; x1 := scaleX(410)
        ; y1 := scaleY(1273)
        ; x2 := scaleX(1081)
        ; y2 := scaleY(1396)
        x1 := scaleX(692)
        y1 := scaleY(1321)
        x2 := scaleX(784)
        y2 := scaleY(1340)
        Loop
        {
            ; ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250717220017.png
            PixelSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %NORMAL_TEXT%, 0, Fast RGB
            Sleep, 100
        }
        Until ErrorLevel = 0
        If (ErrorLevel = 0)
        {
            click1 := scaleX(748)
            click2 := scaleY(1331)
            Click, %click1%, %click2% Left, 1
            Sleep, 1000
        }
        ; x1 := scaleX(374)
        ; y1 := scaleY(1286)
        ; x2 := scaleX(1102)
        ; y2 := scaleY(1388)
        x1 := scaleX(514)
        y1 := scaleY(1319)
        x2 := scaleX(613)
        y2 := scaleY(1341)
        Loop
        {
            ; ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250717220158.png
            PixelSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %NORMAL_TEXT%, 0, Fast RGB
            Sleep, 100
        }
        Until ErrorLevel = 0
        If (ErrorLevel = 0)
        {
            click1 := scaleX(564)
            click2 := scaleY(1333)
            Click, %click1%, %click2% Left, 1
            Sleep, 10
        }
        ; x1 := scaleX(864)
        ; y1 := scaleY(1327)
        ; x2 := scaleX(1229)
        ; y2 := scaleY(1437)
        x1 := scaleX(1021) ; Find scout
        y1 := scaleY(1347)
        x2 := scaleX(1048)
        y2 := scaleY(1374)
        Loop
        {
            ; ImageSearch, FoundX, FoundY, 981, 1321, 1152, 1439, %A_ScriptDir%\Screenshots\Screen_20250718100046.png
            PixelSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %SCOUT%, 0, Fast RGB
            Sleep, 100
        }
        Until ErrorLevel = 0
        If (ErrorLevel = 0)
        {
            click1 := scaleX(1055)
            click2 := scaleY(1376)
            Click, %click1%, %click2% Left, 1  ; Move to scout
            Sleep, 10
        }
        ; x1 := scaleX(953)
        ; y1 := scaleY(1217)
        ; x2 := scaleX(1146)
        ; y2 := scaleY(1308)
        x1 := scaleX(858)
        y1 := scaleY(1245)
        x2 := scaleX(872)
        y2 := scaleY(1271)
        Loop
        {
            ; ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250717220503.png
            PixelSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %NORMAL_TEXT%, 0, Fast RGB ; Scout has loaded
            Sleep, 100
        }
        Until ErrorLevel = 0
        If (ErrorLevel = 0)
        {
            click1 := scaleX(1232)
            click2 := scaleY(877)
            Sleep, 600
            Loop, % BannerDropdown - 1 ; Clicks next banner as many times as needed to get to desired banner
            {
                Click, %click1%, %click2% Left, 1  ; Move banner
                Sleep, 600
            }
        }
        ; x1 := scaleX(533)
        ; y1 := scaleY(807)
        ; x2 := scaleX(944)
        ; y2 := scaleY(954)
        ; x1 := scaleX(858)
        ; y1 := scaleY(856)
        ; x2 := scaleX(881)
        ; y2 := scaleY(872)
        x1 := scaleX(816)
        y1 := scaleY(848)
        x2 := scaleX(842)
        y2 := scaleY(915)
        Loop
        {
            ; ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250717230322.png
            PixelSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, 0x45434c, 0, Fast RGB
            Sleep, 100
        }
        Until ErrorLevel = 0
        If (ErrorLevel = 0)
        {
            Sleep, 500
            click1 := scaleX(994)
            click2 := scaleY(1153)
            Click, %click1%, %click2% Left, 1  ; Make sure we're rolling for Kitasan
            Sleep, 10
        }
        ; x1 := scaleX(374)
        ; y1 := scaleY(883)
        ; x2 := scaleX(1108)
        ; y2 := scaleY(997)
        x1 := scaleX(758)
        y1 := scaleY(897)
        x2 := scaleX(866)
        y2 := scaleY(986)
        Loop
        {
            ; ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250717221007.png
            PixelSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %CONFIRM2%, 0, Fast RGB
            Sleep, 100
        }
        Until ErrorLevel = 0
        If (ErrorLevel = 0)
        {
            Sleep, 500
            click1 := scaleX(917)
            click2 := scaleY(941)
            Click, %click1%, %click2% Left, 1  ; Pray to the RNG Gods
            Sleep, 10
        }
        /*

        ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250717221102.png
        Sleep, 100
        If (ErrorLevel)
        {
            click1 := scaleX(1206)
            click2 := scaleY(1365)
            Click, %click1%, %click2% Left, 1  ; Click skip until can roll again
            Sleep, 100
        }
        Else
        {
            Break
        }
        */
        Loop
        {
            ; x1 := scaleX(368)
            ; y1 := scaleY(1296)
            ; x2 := scaleX(1116)
            ; y2 := scaleY(1414)
            x1 := scaleX(752)
            y1 := scaleY(1309)
            x2 := scaleX(914)
            y2 := scaleY(1388)
            Loop
            {
                ; ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250717221102.png
                PixelSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %CONFIRM2%, 0, Fast RGB ; Look for Scout Again
                Sleep, 100
                If (ErrorLevel)
                {
                    click1 := scaleX(1206)
                    click2 := scaleY(1365)
                    Click, %click1%, %click2% Left, 1  ; Skip rolling cutscenes until Scout Again appears
                    Sleep, 100
                }
                Else
                {

                    rollResults := GetRollResults(SSRs, SRs, Rs, targetSSR)
                    ; MsgBox, 0, , % "SSR: " . rollResults[1] . ", SR: " . rollResults[2] . ", R: " rollResults[3]

                    Sleep, 200

                    Break
                }
            }

            If (MoreScreenshots = 1)
            {
                Send, {F12}
                Sleep, 500
            }

            click1 := scaleX(897)
            click2 := scaleY(1344)
            Click, %click1%, %click2% Left, 1  ; Pray to the RNG Gods
            Sleep, 10
            ; x1 := scaleX(378)
            ; y1 := scaleY(882)
            ; x2 := scaleX(1090)
            ; y2 := scaleY(1000)

            x1 := scaleX(755)
            y1 := scaleY(896)
            x2 := scaleX(1090)
            y2 := scaleY(987)
            Sleep, 600
            screen := GetScreenshot(x1, y1, x2, y2, "scoutConfirm")
            ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %screen%
            ; ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250717221007.png
            ; PixelSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %CONFIRM2%, 0, Fast RGB ; Look for Scout button
            Sleep, 100
            If (ErrorLevel = 0)
            {
                Sleep, 500
                click1 := scaleX(917)
                click2 := scaleY(941)
                Click, %click1%, %click2% Left, 1  ; Pray to the RNG Gods
                Sleep, 10
            }
            Else
            {
                ; x1 := scaleX(594)
                ; y1 := scaleY(837)
                ; x2 := scaleX(705)
                ; y2 := scaleY(886)
                x1 := scaleX(614)
                y1 := scaleY(843)
                x2 := scaleX(694)
                y2 := scaleY(879)
                Loop
                {
                    screen := GetScreenshot(x1, y1, x2, y2, "outOfCarats")
                    ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %screen%
                    ; ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250718132724.png
                    ; PixelSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %RED_EXCLAMATION%, 0, Fast RGB
                    If ErrorLevel = 0
                        Break ; Stop rolling when no carats left
                    Sleep, 100
                }
                Until ErrorLevel = 0
                Break
            }
            x1 := scaleX(1176)
            y1 := scaleY(1341)
            x2 := scaleX(1235)
            y2 := scaleY(1394)
            Loop
            {
                PixelSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, 0xA25E2E, 0, Fast RGB ; Look for skip button
                Sleep, 100
            }
            Until ErrorLevel = 0
            If (ErrorLevel = 0)
            {
                ; Wait until skip button appears to click it
            }
        }
        Sleep, 300
        ; x1 := scaleX(590)
        ; y1 := scaleY(834)
        ; x2 := scaleX(870)
        ; y2 := scaleY(884)
        x1 := scaleX(614)
        y1 := scaleY(843)
        x2 := scaleX(694)
        y2 := scaleY(879)
        Loop
        {
            screen := GetScreenshot(x1, y1, x2, y2, "outOfCarats")
            ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %screen% ; Sanity check that we're out of carats
            ; ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250718131356.png
            Sleep, 100
        }
        Until ErrorLevel = 0
        If (ErrorLevel = 0)
        {
            click1 := scaleX(558)
            click2 := scaleY(938)
            Click, %click1%, %click2% Left, 1 ; Click cancel
            Sleep, 10
        }
        ; x1 := scaleX(376)
        ; y1 := scaleY(1299)
        ; x2 := scaleX(1092)
        ; y2 := scaleY(1406)
        x1 := scaleX(752)
        y1 := scaleY(1309)
        x2 := scaleX(914)
        y2 := scaleY(1388)
        Loop
        {
            ; ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250717222616.png
            PixelSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %CONFIRM2%, 0, Fast RGB ; Look for Scout Again
            Sleep, 100
        }
        Until ErrorLevel = 0
        If (ErrorLevel = 0)
        {
            Sleep, 500
            click1 := scaleX(568)
            click2 := scaleY(1350)
            Click, %click1%, %click2% Left, 1  ; Go back to main screen
            Sleep, 10
        }
        ; x1 := scaleX(609)
        ; y1 := scaleY(1322)
        ; x2 := scaleX(875)
        ; y2 := scaleY(1435)
        x1 := scaleX(691)
        y1 := scaleY(1392)
        x2 := scaleX(785)
        y2 := scaleY(1421)
        Loop
        {
            ; ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250717222721.png
            PixelSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, 0x635d7e, 0, Fast RGB ; Check we're out of scout screen
            Sleep, 100
        }
        Until ErrorLevel = 0
        If (ErrorLevel = 0)
        {
            click1 := scaleX(418)
            click2 := scaleY(1382)
            Click, %click1%, %click2% Left, 1  ; Go to Enhance scren
            Sleep, 10
        }
        Sleep, 1500
        ; x1 := scaleX(752)
        ; y1 := scaleY(983)
        ; x2 := scaleX(1057)
        ; y2 := scaleY(1064)
        x1 := scaleX(1017)
        y1 := scaleY(1024)
        x2 := scaleX(1045)
        y2 := scaleY(1055)
        Loop
        {
            ; ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250717232707.png
            PixelSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, 0x635d7e, 0, Fast RGB
            Sleep, 100
        }
        Until ErrorLevel = 0
        If (ErrorLevel = 0)
        {
            click1 := scaleX(896)
            click2 := scaleY(945)
            Click, %click1%, %click2% Left, 1  ; Support cards
            Sleep, 1000
        }
        ; x1 := scaleX(437)
        ; y1 := scaleY(1067)
        ; x2 := scaleX(719)
        ; y2 := scaleY(1146)
        x1 := scaleX(433)
        y1 := scaleY(1114)
        x2 := scaleX(453)
        y2 := scaleY(1134)
        Loop
        {
            ; ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250717233256.png
            PixelSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, 0xe15d5d, 0, Fast RGB
            Sleep, 100
        }
        Until ErrorLevel = 0
        If (ErrorLevel = 0)
        {
            click1 := scaleX(573)
            click2 := scaleY(1109)
            Click, %click1%, %click2% Left, 1  ; List to see all
            Sleep, 10
        }
        ; x1 := scaleX(235)
        ; y1 := scaleY(1182)
        ; x2 := scaleX(340)
        ; y2 := scaleY(1248)
        x1 := scaleX(249)
        y1 := scaleY(1191)
        x2 := scaleX(327)
        y2 := scaleY(1231)
        Loop
        {
            ; ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250717233402.png
            PixelSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %NORMAL_TEXT%, 0, Fast RGB ; Make sure List screen is loaded
            Sleep, 100
        }
        Until ErrorLevel = 0
        If (ErrorLevel = 0)
        {
            If (targetSSR >= TargetNum)
                Send, {F12}  ; Take screenshot
        }
        Sleep, 300
        If (targetSSR >= TargetNum) {
            DataLink(pass)
        }

        Sleep, 100

        ; End of reroll loop
        ; MsgBox, 0, , % "Target SSRs obtained: " . targetSSR
    }
Return

scaleX(x)
{
    return floor((x / 2560) * A_ScreenWidth)
}

scaleY(y)
{
    return floor((y / 1440) * A_ScreenHeight)
}

FindRarity(x1, y1, x2, y2)
{
    Loop
    {
        PixelSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, 0x9266d6, 9, Fast RGB

        If (ErrorLevel = 0)
        {
            ; MsgBox, 0, , found ssr
            return "SSR"
        }

        PixelSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, 0xf2db96, 7, Fast RGB
        If (ErrorLevel = 0)
        {
            ; MsgBox, 0, , found sr
            return "SR"
        }

        PixelSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, 0xadd9ee, 6, Fast RGB
        If (ErrorLevel = 0)
        {
            ; MsgBox, 0, , found r
            return "R"
        }

        Sleep, 100
        return ""
    }
}

GetRollResults(ByRef SSRs, ByRef SRs, ByRef Rs, ByRef targetSSR)
{
    positions := [[426,165,464,187], [666,166,707,187], [908,167,950,187], [546,435,586,457], [787,435,830,455], [423,710,465,730], [667,710,707,729], [909,707,949,729], [546,979,587,1001], [789,980,829,1002]]
    fullCardpositions := [[411,149,475,199], [624,140,835,384], [871,138,1087,384], [520,417,710,648], [769,411,946,651], [373,675,597,924], [644,688,832,923], [865,678,1077,922], [520,959,708,1193], [750,959,967,1194]]
    For index, pos in positions
    {
        x1 := scaleX(pos[1])
        y1 := scaleY(pos[2])
        x2 := scaleX(pos[3])
        y2 := scaleY(pos[4])
        card := FindRarity(x1, y1, x2, y2)
        If (card = "SSR")
        {
            SSRs += 1

            ; Check if SSR is banner target
            targetX1 := scaleX(fullCardpositions[index][1])
            targetY1 := scaleY(fullCardpositions[index][2])
            targetX2 := scaleX(fullCardpositions[index][3])
            targetY2 := scaleY(fullCardpositions[index][4])
            PixelSearch, FoundX, FoundY, %targetX1%, %targetY1%, %targetX2%, %targetY2%, 0xfffa69, 2, Fast RGB ; Kitasan Black
            If (ErrorLevel = 0)
            {
                ; MsgBox, 0, , % "found kitasan at " . index
                targetSSR += 1
            }

        }
        If (card = "SR")
        {
            SRs += 1
        }
        If (card = "R")
        {
            Rs += 1
        }
    }
    return [SSRs, SRs, Rs, targetSSR]
}

DataLink(pass)
{
    global targetSSR
    x1 := scaleX(1912)
    y1 := scaleY(950)
    x2 := scaleX(2183)
    y2 := scaleY(1020)
    Loop
    {
        ; ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250717233946.png
        PixelSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, 0xf49e00, 0, Fast RGB
        Sleep, 100
    }
    Until ErrorLevel = 0
    If (ErrorLevel = 0)
    {
        Sleep, 500
        click1 := scaleX(2024)
        click2 := scaleY(987)
        Click, %click1%, %click2% Left, 1  ; Go to Data Link
        Sleep, 100
    }
    x1 := scaleX(756)
    y1 := scaleY(900)
    x2 := scaleX(1077)
    y2 := scaleY(986)
    Loop
    {
        ; ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250717234247.png
        PixelSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, 0x94d708, 0, Fast RGB
        Sleep, 100
    }
    Until ErrorLevel = 0
    If (ErrorLevel = 0)
    {
        Sleep, 500
        click1 := scaleX(898)
        click2 := scaleY(947)
        Click, %click1%, %click2% Left, 1  ; Go to Data Link
        Sleep, 100
    }
    ; x1 := scaleX(921)
    ; y1 := scaleY(479)
    ; x2 := scaleX(1004)
    ; y2 := scaleY(536)
    x1 := scaleX(948)
    y1 := scaleY(795)
    x2 := scaleX(1091)
    y2 := scaleY(856)
    Loop
    {
        ; ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250718134241.png
        PixelSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, 0x94d708, 0, Fast RGB
        Sleep, 100
    }
    Until ErrorLevel = 0
    If (ErrorLevel = 0)
    {
        Sleep, 500
        click1 := scaleX(1010)
        click2 := scaleY(822)
        Click, %click1%, %click2% Left, 1  ; Go to Data Link
        Sleep, 100
    }
    ; x1 := scaleX(614)
    ; y1 := scaleY(749)
    ; x2 := scaleX(859)
    ; y2 := scaleY(821)
    x1 := scaleX(753)
    y1 := scaleY(893)
    x2 := scaleX(889)
    y2 := scaleY(989)
    Loop
    {
        ; ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250718132342.png
        PixelSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, 0x94d708, 0, Fast RGB
        Sleep, 100
    }
    Until ErrorLevel = 0
    If (ErrorLevel = 0)
    {
        Sleep, 500
        click1 := scaleX(904)
        click2 := scaleY(933)
        Click, %click1%, %click2% Left, 1  ; Go to Data Link
        Sleep, 100
    }
    ; x1 := scaleX(619)
    ; y1 := scaleY(515)
    ; x2 := scaleX(872)
    ; y2 := scaleY(580)
    x1 := scaleX(752)
    y1 := scaleY(991)
    x2 := scaleX(1088)
    y2 := scaleY(1076)
    Loop
    {
        ; ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250717234701.png
        PixelSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, 0x5E8605, 0, Fast RGB
        Sleep, 100
    }
    Until ErrorLevel = 0
    If (ErrorLevel = 0)
    {
        Sleep, 500
        click1 := scaleX(728)
        click2 := scaleY(607)
        Click, %click1%, %click2% Left, 1  ; Go to Data Link
        Sleep, 300
        SendRaw, %pass%
    }
    Sleep, 500
    click1 := scaleX(736)
    click2 := scaleY(750)
    Click, %click1%, %click2% Left, 1  ; Go to Data Link
    Sleep, 800
    Click, %click1%, %click2% Left, 1  ; Click EXACTLY twice after a delay because this game is jank
    Sleep, 500
    SendRaw, %pass%
    Sleep, 500
    click1 := scaleX(496)
    click2 := scaleY(936)
    Click, %click1%, %click2% Left, 1  ; Click check box
    Sleep, 100
    click1 := scaleX(914)
    click2 := scaleY(1035)
    Click, %click1%, %click2% Left, 1  ; Click OK
    Sleep, 100
    x1 := scaleX(895)
    y1 := scaleY(632)
    x2 := scaleX(991)
    y2 := scaleY(672)
    Loop
    {
        ; ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250718101433.png
        PixelSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, 0xff9900, 0, Fast RGB ; Check that Data Link is complete, find Trainer ID
        Sleep, 100
    }
    Until ErrorLevel = 0
    If (ErrorLevel = 0)
    {
        Sleep, 500
        x1 := scaleX(696)
        y1 := scaleY(619)
        x2 := scaleX(1004)
        y2 := scaleY(683)

        trainerID := GetTrainerID(x1, y1, x2, y2)
        saved := Trim(trainerID, "`n") . ": " . targetSSR
        filePath := "SavedTrainerIDs.txt"
        FileAppend, %saved%`n, %filePath% ; Save trainer ID and target SSRs gotten to text file
        Sleep, 200

        Send, {F12}  ; Take screenshot of Trainer ID
    }
    Sleep, 1500
    click1 := scaleX(739)
    click2 := scaleY(942)
    Click, %click1%, %click2% Left, 1  ; Close data link
}

TakeScreenshot(x1, y1, x2, y2, name)
{
    w := Abs(x2 - x1)
    h := Abs(y2 - y1)
    region := x1 "|" y1 "|" w "|" h
    ; out := A_ScriptDir "\Screenshots\Screenshot_" A_Now ".png"
    dir := A_ScriptDir "\Screenshots"
    IfNotExist, %dir%
        FileCreateDir, %dir%
    out := dir "\" name ".png"
    start := Gdip_Startup()
    pic := Gdip_BitmapFromScreen(region)
    Gdip_SaveBitmapToFile(pic, out, 100)
    Gdip_DisposeImage(pic)
    Gdip_Shutdown(start)
    return out
}

GetTrainerID(x1, y1, x2, y2)
{
    trainer_pic := TakeScreenshot(x1, y1, x2, y2, "trainer")
    trainerID := ocr(trainer_pic, "en")
    FileDelete, %trainer_pic%
    return trainerID
}

GetScreenshot(x1, y1, x2, y2, name)
{
    screen := A_ScriptDir "\Screenshots" "\" name ".png"

    If (!FileExist(screen))
    {
        screen := TakeScreenshot(x1, y1, x2, y2, name)
    }
    return screen
}

GetCurrentBanners()
{
    banners := GetBannersFromDB()
    FileInstall, fetch_banner.ahk, %A_ScriptDir%\fetch_banner.ahk, 1
    FileInstall, Lib\Jxon.ahk, %A_ScriptDir%\Jxon.ahk, 1

    banners := objectSort(banners, "card_type") ; Sort banners in the order they appear in game
    for i, v in banners
    {
        ; Dumb workaround to allow for asynchronous fetching, python interop might be better (and faster)
        RunWait, % "fetch_banner.ahk " v.banner_id, , Hide
    }
}

GetBannersFromDB()
{
    FileInstall, sqlite3.dll, %A_ScriptDir%\sqlite3.dll, 1 ; This might get flagged by AV, look for alternatives if possible
    DBFileName := "C:\Users\" . A_UserName . "\AppData\LocalLow\Cygames\Umamusume\master\master.mdb"
    DB := New SQLiteDB
    If !DB.OpenDB(DBFileName) {
        MsgBox, 16, SQLite Error, % "Msg:`t" . DB.ErrorMsg . "`nCode:`t" . DB.ErrorCode
        ExitApp
    }

    SQL := "SELECT transition, priority, end_date FROM banner_data;"
    banners := []
    Result := ""
    If !DB.GetTable(SQL, Result)
        MsgBox, 16, SQLite Error: GetTable, % "Msg:`t" . DB.ErrorMsg . "`nCode:`t" . DB.ErrorCode
    Else
    {
        Values := ""
        For Each, Row In Result.Rows
        {
            dateTimeAHK := RegExReplace(Row[3], "[/: ]", "")
            EnvSub, datetimeAHK, A_NowUTC, Seconds
            If (dateTimeAHK > 0 and Row[2] = 9) ; Find the correct banners that are currently running
            {
                subSQL := "SELECT card_type FROM gacha_data WHERE id = " . Row[1] . ";" ; Used to sort the banners in the order they appear in game
                subResult := ""
                If !DB.GetTable(subSQL, subResult)
                    MsgBox, 16, SQLite Error: GetTable, % "Msg:`t" . DB.ErrorMsg . "`nCode:`t" . DB.ErrorCode
                Else
                {
                    subValues := ""
                    For i, subRow in subResult.Rows
                    {
                        banners.Push({"banner_id": Row[1], "card_type": subRow[1]})
                    }
                }
            }
        }
        Return banners
    }
    DB.CloseDB()
}

AsyncBanner:
    GetCurrentBanners()
    FileRead, banners, banners.txt
    GuiControl, , BannerDropdown, |
    Loop, Parse, banners, `n, `r
    {
        GuiControl, , BannerDropdown, %A_LoopField%
    }
    Sleep, 100
    GuiControl, Choose, BannerDropdown, 1
    SetTimer, AsyncBanner, Off
    GuiControl, Enable, OK
    FileDelete, banners.txt
    FileDelete, %A_ScriptDir%\fetch_banner.ahk
    FileDelete, %A_ScriptDir%\Jxon.ahk
    FileDelete, %A_ScriptDir%\sqlite3.dll
Return

UnixToUTC(unixTime){
    time:=1970
    time+=unixTime, s
    return time
}

;! For testing purporses only
ManualRollDetect()
{
    SSRs := 0
    SRs := 0
    Rs := 0
    targetSSR := 0
    rolls := GetRollResults(SSRs, SRs, Rs, targetSSR)
    MsgBox, 0, , % "Target: " . rolls[4] . " SSRs: " . rolls[1] . " SRs: " . rolls[2] . " Rs: " . rolls[3]
}

ManualSaveID()
{
    filePath := "SavedTrainerIDs.txt"
    x1 := scaleX(696)
    y1 := scaleY(619)
    x2 := scaleX(1004)
    y2 := scaleY(683)

    trainerID := GetTrainerID(x1, y1, x2, y2)
    targetSSR := 2
    saved := Trim(trainerID, "`n") . ": " . targetSSR
    FileAppend, %saved%`n, %filePath%
    ; MsgBox, 0, , % trainerID
}

+Escape::
    MsgBox, 0, , UUR terminated.
ExitApp
