#NoEnv
#SingleInstance, Force
SendMode, Input
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%
#Include, %A_ScriptDir%\Jxon.ahk

banners := {}
bannerID := A_Args[1]
oWhr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
oWhr.Open("GET", "http://umapyoi.net/api/v1/gacha/" . bannerID, false)
oWhr.Send()
json := oWhr.ResponseText
data := Jxon_Load(json)
chars := data.pickups
if !IsObject(banners[idx])
    banners[idx] := []
for i, char in chars
{
    If (char.rarity = 3 or char.default_rarity = 3)
        banners[idx].Push(char.chara_data.name_en)
}
For idx, arr in banners
{
    names := ""
    For i, n in arr
    {
        names .= (i = arr.Length() ? n : n . ", ")
    }
    FileAppend, % names . "`n", %A_ScriptDir%\banners.txt
}
ExitApp