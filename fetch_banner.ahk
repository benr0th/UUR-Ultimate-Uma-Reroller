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
        banners[idx].Push({"name": char.chara_data.name_en, "char_id": char.id, "banner_id": data.id})
}
For idx, arr in banners
{
    names := ""
    For i, n in arr
    {
        names .= n.name . " (char_id: " . n.char_id . ", banner_id: " . n.banner_id ")"
        if (i < arr.Length())
            names .= "`n"
    }
    FileAppend, % names . "`n", %A_ScriptDir%\banners.txt
}
ExitApp