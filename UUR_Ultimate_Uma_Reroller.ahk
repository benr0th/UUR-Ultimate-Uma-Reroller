; This script was created using Pulover's Macro Creator
; www.macrocreator.com

#NoEnv
SetWorkingDir %A_ScriptDir%
CoordMode, Mouse, Window
SendMode Input
#SingleInstance Force
SetTitleMatchMode 2
#WinActivateForce
SetControlDelay 1
SetWinDelay 0
SetKeyDelay -1
SetMouseDelay -1
SetBatchLines -1

Intro:
SysGet, MonitorCount, MonitorCount
Gui -MinimizeBox -MaximizeBox -SysMenu
Gui Add, Edit, hWndhEdtValue vdate x32 y65 w121 h21, 199101
Gui Add, CheckBox, hWndhChk vpreDataLink x31 y302 w350 h22 +Checked, Set Data Link for current account (Must be logged in already)
Gui Add, ComboBox, hWndComboBox vMonitorDropdown x31 y276 w120 +AltSubmit Choose1, 
Gui Add, Text, x32 y34 w309 h23 +0x200, Enter the age date that will be used for each reroll (e.g. 199101)
Gui Add, Text, x32 y98 w247 h23 +0x200, Enter the username that will be used for each reroll
Gui Add, Edit, hWndhEdtValue2 vname x31 y131 w121 h21, PraiseRNG
Gui Add, Text, x31 y162 w375 h23 +0x200, Enter the password that will be used for data link (This is not stored anywhere)
Gui Add, Edit, hWndhEdtValue3 vpass x31 y194 w121 h21
Gui Add, Button, vOK x270 y356 w80 h23, &OK
Gui Add, Text, x31 y250 w400 h23 +0x200, Choose which monitor to roll on (defaults to main display)
Gui Add, Text, x430 y40 w210, Welcome to UUR (Ultimate Uma Reroller)! This script will infinitely reroll on the Kitasan Black banner. `n`nThis is the order of operations: `n- deletes the current account`n- makes a new one`n- grabs the carats from the gifts and rolls until out of carats`n- takes a screenshot of the List view of Support Cards`n- sets up a Data Link and takes a screenshot of the trainer ID, then restarts.`n`n`n`nThe script will start after pressing the OK button. `nPress Shift+Escape to stop the script at any time.

Loop, %MonitorCount%
{
    SysGet, MonitorName, MonitorName, %A_Index%
    if (MonitorName = "")
            MonitorName := "Monitor " . A_Index
    GuiControl, , MonitorDropdown, %MonitorName% 
}
SysGet, MonitorMain, MonitorPrimary
GuiControl, Choose, MonitorDropdown, %MonitorMain%

Gui Show, w650 h420, UUR Options
Return

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
kitas := 0
rollResults := []
onTitleScreen := 0
SysGet, resolution, Monitor, %MonitorDropdown%
preLinkDone := 0
Loop
{
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
    CoordMode, Pixel, Window
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
        MsgBox, 0, , Title screen detected. Please sign in first to Link Data of current account before rerolling. Script terminating.
        ExitApp
    }
    If (preDataLink = 1 and preLinkDone = 0 and onTitleScreen = 0)
    {
        DataLink(pass)
        Sleep, 300
        x1 := scaleX(502)
        y1 := scaleY(625)
        x2 := scaleX(689)
        y2 := scaleY(674)
        Loop
        {
            CoordMode, Pixel, Screen
            PixelSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, 0xECE7E4, 0, Fast RGB
            Sleep, 100
        }
        Until ErrorLevel = 0
        If (ErrorLevel = 0)
        {
            Sleep, 500
            click1 := scaleX(740)
            click2 := scaleY(939)
            Click, %click1%, %click2% Left, 1  ; Close out of Data Link
            preLinkDone := 1
            Sleep, 500
        }
    }
    x1 := scaleX(1420)
    y1 := scaleY(884)
    x2 := scaleX(2182)
    y2 := scaleY(1261)
    CoordMode, Pixel, Screen
    ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250717110651.png
    Sleep, 100
    If (ErrorLevel = 0)
    {
        click1 := scaleX(2005)
        click2 := scaleY(1204)
        Click, %click1%, %click2% Left, 1  ; Find and click Title Screen button from main logged in screen
        Sleep, 50
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
            CoordMode, Pixel, Screen
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
    }
    Loop
    {
        x1 := scaleX(926)
        y1 := scaleY(1031)
        x2 := scaleX(999)
        y2 := scaleY(1061)
        CoordMode, Pixel, Screen
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
        CoordMode, Pixel, Window
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
        CoordMode, Pixel, Screen
        PixelSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, 0x9CDB05, 0, Fast RGB
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
    x1 := scaleX(1273)
    y1 := scaleY(665)
    x2 := scaleX(1415)
    y2 := scaleY(733)
    Loop
    {
        CoordMode, Pixel, Screen
        ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250718114645.png
        Sleep, 100
    }
    Until ErrorLevel = 0
    If (ErrorLevel = 0)
    {
        click1 := scaleX(1290)
        click2 := scaleY(940)
        Click, %click1%, %click2% Left, 1  ; Check it's been clicked and click it again
        Sleep, 10
        Sleep, 300
    }
    x1 := scaleX(898)
    y1 := scaleY(562)
    x2 := scaleX(1657)
    y2 := scaleY(878)
    Loop
    {
        CoordMode, Pixel, Screen
        ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250717223749.png
        Sleep, 10
        If (ErrorLevel)
        {
            click1 := scaleX(1929)
            click2 := scaleY(925)
            Click, %click1%, %click2% Left, 1  ; Accept terms and conditions
            Sleep, 100
        }
        Else
        {
            Break
        }
    }
    click1 := scaleX(1561)
    click2 := scaleY(642)
    Click, %click1%, %click2% Left, 1  ; Accept terms and conditions
    Sleep, 100
    WinWaitNotActive, Umamusume ahk_class UnityWndClass, , 10
    Sleep, 333
    IfWinNotActive, Umamusume ahk_class UnityWndClass
    {
        Send, {Control Down}{w}{Control Up}
        WinActivate, Umamusume ahk_class UnityWndClass
        Sleep, 333
    }
    x1 := scaleX(903)
    y1 := scaleY(565)
    x2 := scaleX(1658)
    y2 := scaleY(869)
    Loop
    {
        CoordMode, Pixel, Screen
        ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250717223749.png
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
        WinActivate, Umamusume ahk_class UnityWndClass
        Sleep, 333
    }
    Loop
    {
        CoordMode, Pixel, Screen
        ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250717223749.png
        Sleep, 10
    }
    Until ErrorLevel = 0
    If (ErrorLevel = 0)
    {
        click1 := scaleX(1449)
        click2 := scaleY(1037)
        Click, %click1%, %click2% Left, 1  ; Check it's been clicked and click it again
        Sleep, 10
    }
    x1 := scaleX(907)
    y1 := scaleY(535)
    x2 := scaleX(1671)
    y2 := scaleY(885)
    Loop
    {
        CoordMode, Pixel, Screen
        ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250717211019.png
        Sleep, 100
    }
    Until ErrorLevel = 0
    If (ErrorLevel = 0)
    {
        click1 := scaleX(1546)
        click2 := scaleY(746)
        Click, %click1%, %click2% Left, 1  ; Choose country
        Sleep, 10
    }
    x1 := scaleX(1127)
    y1 := scaleY(517)
    x2 := scaleX(1433)
    y2 := scaleY(594)
    Loop
    {
        CoordMode, Pixel, Screen
        ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250718094856.png
        Sleep, 100
    }
    Until ErrorLevel = 0
    If (ErrorLevel = 0)
    {
        click1 := scaleX(1462)
        click2 := scaleY(1034)
        Click, %click1%, %click2% Left, 1  ; Check it's been clicked and click it again
        Sleep, 10
    }
    x1 := scaleX(926)
    y1 := scaleY(704)
    x2 := scaleX(1634)
    y2 := scaleY(858)
    Loop
    {
        CoordMode, Pixel, Screen
        ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250717224357.png
        Sleep, 100
    }
    Until ErrorLevel = 0
    If (ErrorLevel = 0)
    {
        click1 := scaleX(1449)
        click2 := scaleY(938)
        Click, %click1%, %click2% Left, 1  ; Check it's been clicked and click it again
        Sleep, 10
    }
    x1 := scaleX(960)
    y1 := scaleY(810)
    x2 := scaleX(1093)
    y2 := scaleY(868)
    Loop
    {
        CoordMode, Pixel, Screen
        ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250718112853.png
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
        CoordMode, Pixel, Screen
        ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250718112853.png
        Sleep, 100
    }
    Until ErrorLevel = 0
    If (ErrorLevel = 0)
    {
        click1 := scaleX(1456)
        click2 := scaleY(935)
        Click, %click1%, %click2% Left, 1  ; Check if text was entered and accept
        Sleep, 10
    }
    x1 := scaleX(1069)
    y1 := scaleY(616)
    x2 := scaleX(1494)
    y2 := scaleY(791)
    Loop
    {
        CoordMode, Pixel, Screen
        ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250718095256.png
        Sleep, 100
    }
    Until ErrorLevel = 0
    If (ErrorLevel = 0)
    {
        click1 := scaleX(1460)
        click2 := scaleY(945)
        Click, %click1%, %click2% Left, 1  ; Skip tutorial
        Sleep, 10
    }
    x1 := scaleX(1023)
    y1 := scaleY(511)
    x2 := scaleX(1602)
    y2 := scaleY(617)
    Loop
    {
        CoordMode, Pixel, Window
        ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250718095329.png
        Sleep, 100
    }
    Until ErrorLevel = 0
    If (ErrorLevel = 0)
    {
        click1 := scaleX(1306)
        click2 := scaleY(646)
        Click, %click1%, %click2% Left, 1  ; Skip tutorial
        Sleep, 10
        Sleep, 500
        SendRaw, %name%
    }
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
        CoordMode, Pixel, Window
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
        CoordMode, Pixel, Window
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
    x1 := scaleX(991)
    y1 := scaleY(1371)
    x2 := scaleX(1128)
    y2 := scaleY(1437)
    Loop
    {
        CoordMode, Pixel, Window
        ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250718133514.png
        Sleep, 10
        If (ErrorLevel)
        {
            click1 := scaleX(1202)
            click2 := scaleY(1378)
            Click, %click1%, %click2% Left, 1  ; Skip all new player stuff
            Sleep, 100
        }
        Else
        {
            Break
        }
    }
    x1 := scaleX(628)
    y1 := scaleY(909)
    x2 := scaleX(867)
    y2 := scaleY(970)
    Loop
    {
        CoordMode, Pixel, Window
        ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250718111349.png
        Sleep, 100
    }
    Until ErrorLevel = 0
    If (ErrorLevel = 0)
    {
        click1 := scaleX(749)
        click2 := scaleY(1336)
        Click, %click1%, %click2% Left, 1
        Sleep, 10
    }
    x1 := scaleX(641)
    y1 := scaleY(1295)
    x2 := scaleX(836)
    y2 := scaleY(1367)
    Loop
    {
        CoordMode, Pixel, Window
        ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250718111434.png
        Sleep, 100
    }
    Until ErrorLevel = 0
    If (ErrorLevel = 0)
    {
        click1 := scaleX(749)
        click2 := scaleY(1336)
        Click, %click1%, %click2% Left, 1
        Sleep, 10
    }
    x1 := scaleX(990)
    y1 := scaleY(1345)
    x2 := scaleX(1153)
    y2 := scaleY(1438)
    Loop
    {
        CoordMode, Pixel, Window
        ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250718095916.png
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
    x1 := scaleX(369)
    y1 := scaleY(1271)
    x2 := scaleX(1097)
    y2 := scaleY(1394)
    Loop
    {
        CoordMode, Pixel, Window
        ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250717215840.png
        Sleep, 100
    }
    Until ErrorLevel = 0
    If (ErrorLevel = 0)
    {
        click1 := scaleX(896)
        click2 := scaleY(1330)
        Click, %click1%, %click2% Left, 1  ; Get gifts
        Sleep, 10
    }
    Sleep, 2000
    x1 := scaleX(410)
    y1 := scaleY(1273)
    x2 := scaleX(1081)
    y2 := scaleY(1396)
    Loop
    {
        CoordMode, Pixel, Window
        ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250717220017.png
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
    x1 := scaleX(374)
    y1 := scaleY(1286)
    x2 := scaleX(1102)
    y2 := scaleY(1388)
    Loop
    {
        CoordMode, Pixel, Window
        ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250717220158.png
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
    x1 := scaleX(864)
    y1 := scaleY(1327)
    x2 := scaleX(1229)
    y2 := scaleY(1437)
    Loop
    {
        CoordMode, Pixel, Window
        ImageSearch, FoundX, FoundY, 981, 1321, 1152, 1439, %A_ScriptDir%\Screenshots\Screen_20250718100046.png
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
    x1 := scaleX(953)
    y1 := scaleY(1217)
    x2 := scaleX(1146)
    y2 := scaleY(1308)
    Loop
    {
        CoordMode, Pixel, Window
        ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250717220503.png
        Sleep, 100
    }
    Until ErrorLevel = 0
    If (ErrorLevel = 0)
    {
        click1 := scaleX(1232)
        click2 := scaleY(877)
        Sleep, 600
        Click, %click1%, %click2% Left, 1  ; Make sure scout is loaded
        Sleep, 10
        Sleep, 600
        Click, %click1%, %click2% Left, 1  ; Make sure scout is loaded
        Sleep, 10
        Sleep, 600
        Click, %click1%, %click2% Left, 1  ; Make sure scout is loaded
        Sleep, 10
    }
    x1 := scaleX(533)
    y1 := scaleY(807)
    x2 := scaleX(944)
    y2 := scaleY(954)
    Loop
    {
        CoordMode, Pixel, Window
        ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250717230322.png
        Sleep, 100
    }
    Until ErrorLevel = 0
    If (ErrorLevel = 0)
    {
        click1 := scaleX(994)
        click2 := scaleY(1153)
        Click, %click1%, %click2% Left, 1  ; Make sure we're rolling for Kitasan
        Sleep, 10
    }
    x1 := scaleX(374)
    y1 := scaleY(883)
    x2 := scaleX(1108)
    y2 := scaleY(997)
    Loop
    {
        CoordMode, Pixel, Window
        ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250717221007.png
        Sleep, 100
    }
    Until ErrorLevel = 0
    If (ErrorLevel = 0)
    {
        click1 := scaleX(917)
        click2 := scaleY(941)
        Click, %click1%, %click2% Left, 1  ; Pray to the RNG Gods
        Sleep, 10
    }
    /*
    CoordMode, Pixel, Window
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
        x1 := scaleX(368)
        y1 := scaleY(1296)
        x2 := scaleX(1116)
        y2 := scaleY(1414)
        Loop
        {
            CoordMode, Pixel, Window
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
                /*
                rollResults := GetRollResults(SSRs, SRs, Rs)
                MsgBox, 0, , % rollResults[1] rollResults[2] rollResults[3]
                */
                Break
            }
        }
        click1 := scaleX(897)
        click2 := scaleY(1344)
        Click, %click1%, %click2% Left, 1  ; Pray to the RNG Gods
        Sleep, 10
        x1 := scaleX(378)
        y1 := scaleY(882)
        x2 := scaleX(1090)
        y2 := scaleY(1000)
        Sleep, 600
        CoordMode, Pixel, Window
        ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250717221007.png
        Sleep, 100
        If (ErrorLevel = 0)
        {
            click1 := scaleX(917)
            click2 := scaleY(941)
            Click, %click1%, %click2% Left, 1  ; Pray to the RNG Gods
            Sleep, 10
        }
        Else
        {
            x1 := scaleX(594)
            y1 := scaleY(837)
            x2 := scaleX(705)
            y2 := scaleY(886)
            Loop
            {
                CoordMode, Pixel, Window
                ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250718132724.png
                If ErrorLevel = 0
                	Break
                Sleep, 100
            }
            Until ErrorLevel = 0
            Break
        }
        /*
        Sleep, 5000
        */
        x1 := scaleX(1176)
        y1 := scaleY(1341)
        x2 := scaleX(1235)
        y2 := scaleY(1394)
        Loop
        {
            CoordMode, Pixel, Window
            PixelSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, 0xA25E2E, 0, Fast RGB
            Sleep, 100
        }
        Until ErrorLevel = 0
        If (ErrorLevel = 0)
        {
            /*
            Break
            */
        }
    }
    Sleep, 300
    x1 := scaleX(590)
    y1 := scaleY(834)
    x2 := scaleX(870)
    y2 := scaleY(884)
    Loop
    {
        CoordMode, Pixel, Window
        ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250718131356.png
        If ErrorLevel
        {
            MsgBox, 49, Continue?, Image / Pixel Not Found.`nPress OK to continue.
            IfMsgBox, Cancel
            	Return
        }
        Sleep, 100
    }
    Until ErrorLevel = 0
    If (ErrorLevel = 0)
    {
        click1 := scaleX(558)
        click2 := scaleY(938)
        Click, %click1%, %click2% Left, 1
        Sleep, 10
    }
    x1 := scaleX(376)
    y1 := scaleY(1299)
    x2 := scaleX(1092)
    y2 := scaleY(1406)
    Loop
    {
        CoordMode, Pixel, Window
        ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250717222616.png
        Sleep, 100
    }
    Until ErrorLevel = 0
    If (ErrorLevel = 0)
    {
        click1 := scaleX(568)
        click2 := scaleY(1350)
        Click, %click1%, %click2% Left, 1  ; Go back to main screen
        Sleep, 10
    }
    x1 := scaleX(609)
    y1 := scaleY(1322)
    x2 := scaleX(875)
    y2 := scaleY(1435)
    Loop
    {
        CoordMode, Pixel, Window
        ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250717222721.png
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
    x1 := scaleX(752)
    y1 := scaleY(983)
    x2 := scaleX(1057)
    y2 := scaleY(1064)
    Loop
    {
        CoordMode, Pixel, Window
        ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250717232707.png
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
    x1 := scaleX(437)
    y1 := scaleY(1067)
    x2 := scaleX(719)
    y2 := scaleY(1146)
    Loop
    {
        CoordMode, Pixel, Window
        ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250717233256.png
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
    x1 := scaleX(235)
    y1 := scaleY(1182)
    x2 := scaleX(340)
    y2 := scaleY(1248)
    Loop
    {
        CoordMode, Pixel, Window
        ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250717233402.png
        Sleep, 100
    }
    Until ErrorLevel = 0
    If (ErrorLevel = 0)
    {
        Send, {Control Down}{F12}{Control Up}  ; Take screenshot
    }
    /*
    x1 := scaleX(235)
    y1 := scaleY(1182)
    x2 := scaleX(340)
    y2 := scaleY(1248)
    Loop
    {
        CoordMode, Pixel, Window
        ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250717233402.png
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
    x1 := scaleX(752)
    y1 := scaleY(983)
    x2 := scaleX(1057)
    y2 := scaleY(1064)
    Loop
    {
        CoordMode, Pixel, Window
        ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250717232707.png
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
    */
    Sleep, 300
    DataLink(pass)
    x1 := scaleX(484)
    y1 := scaleY(521)
    x2 := scaleX(1014)
    y2 := scaleY(630)
    Loop
    {
        CoordMode, Pixel, Window
        ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250718101433.png
        Sleep, 100
    }
    Until ErrorLevel = 0
    If (ErrorLevel = 0)
    {
        Send, {Control Down}{F12}{Control Up}  ; Take screenshot
    }
    Sleep, 300
    click1 := scaleX(739)
    click2 := scaleY(942)
    Click, %click1%, %click2% Left, 1  ; Go to Data Link
    Sleep, 100
    /*
    MsgBox, 0, , % rollResults
    */
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
        /*
        CoordMode, Pixel, Window
        PixelSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, 0x89C5EC, 0, Fast RGB
        */
        CoordMode, Pixel, Window
        ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screen_20250718195829.png
        If (ErrorLevel = 0)
        {
            /*
            MsgBox, 0, , found ssr
            */
            return "SSR"
        }
        /*
        CoordMode, Pixel, Window
        PixelSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, 0xC69E08, 0, Fast RGB
        If (ErrorLevel = 0)
        {
            MsgBox, 0, , found sr
            return "SR"
        }
        CoordMode, Pixel, Window
        PixelSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, 0x6B82AD, 0, Fast RGB
        If (ErrorLevel = 0)
        {
            MsgBox, 0, , found r
            return "R"
        }
        */
        Sleep, 100
        return ""
        /*
        MsgBox, 0, , searched %x1% %y1% %x2% %y2%
        */
    }
}

GetRollResults(ByRef SSRs, ByRef SRs, ByRef Rs)
{
    positions := [[411,149,475,199], [624,140,835,384], [871,138,1087,384], [520,417,710,648], [769,411,946,651], [373,675,597,924], [644,688,832,923], [865,678,1077,922], [520,959,708,1193], [750,959,967,1194]]
    For index, pos in positions
    {
        card := FindRarity(pos[1], pos[2], pos[3], pos[4])
        If (card = "SSR")
        {
            SSRs += 1
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
    return [SSRs, SRs, Rs]
}

DataLink(pass)
{
    x1 := scaleX(1912)
    y1 := scaleY(950)
    x2 := scaleX(2183)
    y2 := scaleY(1020)
    Loop
    {
        CoordMode, Pixel, Window
        ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250717233946.png
        Sleep, 100
    }
    Until ErrorLevel = 0
    If (ErrorLevel = 0)
    {
        click1 := scaleX(2024)
        click2 := scaleY(987)
        Click, %click1%, %click2% Left, 1  ; Go to Data Link
        Sleep, 10
    }
    x1 := scaleX(756)
    y1 := scaleY(900)
    x2 := scaleX(1077)
    y2 := scaleY(986)
    Loop
    {
        CoordMode, Pixel, Window
        ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250717234247.png
        Sleep, 100
    }
    Until ErrorLevel = 0
    If (ErrorLevel = 0)
    {
        click1 := scaleX(898)
        click2 := scaleY(947)
        Click, %click1%, %click2% Left, 1  ; Go to Data Link
        Sleep, 10
    }
    x1 := scaleX(921)
    y1 := scaleY(479)
    x2 := scaleX(1004)
    y2 := scaleY(536)
    Loop
    {
        CoordMode, Pixel, Window
        ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250718134241.png
        Sleep, 100
    }
    Until ErrorLevel = 0
    If (ErrorLevel = 0)
    {
        click1 := scaleX(1010)
        click2 := scaleY(822)
        Click, %click1%, %click2% Left, 1  ; Go to Data Link
        Sleep, 10
    }
    x1 := scaleX(614)
    y1 := scaleY(749)
    x2 := scaleX(859)
    y2 := scaleY(821)
    Loop
    {
        CoordMode, Pixel, Window
        ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250718132342.png
        Sleep, 100
    }
    Until ErrorLevel = 0
    If (ErrorLevel = 0)
    {
        click1 := scaleX(904)
        click2 := scaleY(933)
        Click, %click1%, %click2% Left, 1  ; Go to Data Link
        Sleep, 10
    }
    x1 := scaleX(619)
    y1 := scaleY(515)
    x2 := scaleX(872)
    y2 := scaleY(580)
    Loop
    {
        CoordMode, Pixel, Window
        ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, %A_ScriptDir%\Screenshots\Screen_20250717234701.png
        Sleep, 100
    }
    Until ErrorLevel = 0
    If (ErrorLevel = 0)
    {
        click1 := scaleX(728)
        click2 := scaleY(607)
        Click, %click1%, %click2% Left, 1  ; Go to Data Link
        Sleep, 10
        Sleep, 300
        SendRaw, %pass%
    }
    /*
    Sleep, 100
    */
    click1 := scaleX(736)
    click2 := scaleY(750)
    Click, %click1%, %click2% Left, 1  ; Go to Data Link
    Sleep, 800
    Click, %click1%, %click2% Left, 1  ; Click EXACTLY twice after a delay because this game is jank
    Sleep, 100
    /*
    Click, %click1%, %click2% Left, 1  ; Go to Data Link
    Sleep, 100
    */
    Sleep, 500
    SendRaw, %pass%
    Sleep, 100
    Sleep, 500
    click1 := scaleX(496)
    click2 := scaleY(936)
    Click, %click1%, %click2% Left, 1  ; Go to Data Link
    Sleep, 100
    click1 := scaleX(914)
    click2 := scaleY(1035)
    Click, %click1%, %click2% Left, 1  ; Go to Data Link
    Sleep, 100
}


+Escape::
    MsgBox, 0, , UUR terminated.
    ExitApp
