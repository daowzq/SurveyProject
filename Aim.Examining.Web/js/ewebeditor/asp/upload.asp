<%@ LANGUAGE = VBScript %>
<!--#include file="private.asp"-->
<!--#include file="config.asp"-->
<!--#include file="md5.asp"-->
<!--#include file="upfileclass.asp"-->
<%
'######################################
' eWebEditor v7.3 - Advanced online web based WYSIWYG HTML editor.
' Copyright (c) 2003-2011 eWebSoft.com
'
' For further information go to http://www.ewebeditor.net/
' This copyright notice MUST stay intact for use.
'######################################
%>
<%
Server.ScriptTimeOut = 1800
Dim sType, sStyleName, sCusDir, sParamSYFlag, sParamRnd
Dim sAllowExt, nAllowSize, sUploadDir, nUploadObject, sAutoDir, sBaseUrl, sContentPath, sSetContentPath
Dim sFileExt, sOriginalFileName, sSaveFileName, sPathFileName, nFileNum
Dim nSLTFlag, nSLTMode, nSLTCheckFlag, nSLTMinSize, nSLTOkSize, nSYWZFlag, sSYText, sSYFontColor, nSYFontSize, sSYFontName, sSYPicPath, nSLTSYObject, sSLTSYExt, nSYWZMinWidth, sSYShadowColor, nSYShadowOffset, nSYWZMinHeight, nSYWZPosition, nSYWZTextWidth, nSYWZTextHeight, nSYWZPaddingH, nSYWZPaddingV, nSYTPFlag, nSYTPMinWidth, nSYTPMinHeight, nSYTPPosition, nSYTPPaddingH, nSYTPPaddingV, nSYTPImageWidth, nSYTPImageHeight, nSYTPOpacity
Dim sSpaceSize, sSpacePath, sMFUMode
Dim sParamBlockFile, sParamBlockFlag
Dim sFileNameMode, sFileNameSameFix, sAutoDirOrderFlag, sAutoTypeDir
Dim sAction
sAction = UCase(Trim(Request.QueryString("action")))
Call InitUpload()
Call DoCreateNewDir()
Select Case sAction
Case "LOCAL"
Call DoLocal()
Case "REMOTE"
Call DoRemote()
Case "SAVE"
Call DoSave()
Case "MFU"
Call DoMFU()
End Select
Sub DoSave()
Response.Write "<html><head><title>eWebEditor</title><meta http-equiv='Content-Type' content='text/html; charset=gb2312'></head><body>"
Call DoUpload()
sOriginalFileName = Replace(sOriginalFileName, "'", "\'")
sOriginalFileName = Replace(sOriginalFileName, """", "\""")
Dim s_SmallImageFile, s_SmallImagePathFile, s_SmallImageScript
s_SmallImageFile = getSmallImageFile(sSaveFileName)
s_SmallImagePathFile = ""
s_SmallImageScript = ""
If makeImageSLT(sUploadDir, sSaveFileName, s_SmallImageFile) = True Then
Select Case nSLTMode
Case 0
Call makeImageSY(sUploadDir, s_SmallImageFile)
Call makeImageSY(sUploadDir, sSaveFileName)
s_SmallImagePathFile = sContentPath & s_SmallImageFile
s_SmallImageScript = "try{obj.addUploadFile('" & sOriginalFileName & "', '" & s_SmallImagePathFile & "');} catch(e){} "
Case 1
Call makeImageSY(sUploadDir, s_SmallImageFile)
Call makeImageSY(sUploadDir, sSaveFileName)
s_SmallImagePathFile = sContentPath & s_SmallImageFile
s_SmallImageScript = "try{obj.addUploadFile('" & sOriginalFileName & "', '" & s_SmallImagePathFile & "');} catch(e){} "
s_SmallImagePathFile = ""
Case 2
Call makeImageSY(sUploadDir, s_SmallImageFile)
Call DelFile(sUploadDir & sSaveFileName)
sSaveFileName = s_SmallImageFile
End Select
Else
Call makeImageSY(sUploadDir, sSaveFileName)
End If
sPathFileName = sContentPath & sSaveFileName
Dim s_OutScript
s_OutScript = "var obj=parent.EWIN;" & _
"try{obj.addUploadFile('" & sOriginalFileName & "', '" & sPathFileName & "');} catch(e){} " & s_SmallImageScript  & _
"parent.UploadSaved('" & sPathFileName & "','" & s_SmallImagePathFile & "');"
Call OutScript(s_OutScript)
End Sub
Sub DoLocal()
Call DoUpload()
sPathFileName = sContentPath & sSaveFileName
Response.Write sPathFileName
End Sub
Sub DoMFU()
If sParamBlockFlag = "cancel" Then
If sParamBlockFile <> "" then
Call DelFile(sUploadDir & sParamBlockFile & ".tmp1")
End If
Response.Write "ok"
Response.End
Exit Sub
End If
Call DoUpload()
If sParamBlockFlag = "end" Then
Dim s_SmallImageFile, s_SmallImagePathFile
s_SmallImageFile = getSmallImageFile(sSaveFileName)
s_SmallImagePathFile = ""
If makeImageSLT(sUploadDir, sSaveFileName, s_SmallImageFile) = True Then
Select Case nSLTMode
Case 0
Call makeImageSY(sUploadDir, s_SmallImageFile)
Call makeImageSY(sUploadDir, sSaveFileName)
s_SmallImagePathFile = sContentPath & s_SmallImageFile
Case 1
Call makeImageSY(sUploadDir, s_SmallImageFile)
Call makeImageSY(sUploadDir, sSaveFileName)
s_SmallImagePathFile = ""
Case 2
Call makeImageSY(sUploadDir, s_SmallImageFile)
Call DelFile(sUploadDir & sSaveFileName)
sSaveFileName = s_SmallImageFile
End Select
Else
Call makeImageSY(sUploadDir, sSaveFileName)
End If
sPathFileName = sContentPath & sSaveFileName
Response.Write sPathFileName & "::" & s_SmallImagePathFile
Else
Dim n
n = InstrRev(sSaveFileName, ".")
Response.Write Left(sSaveFileName, n-1)
End If
End Sub
Sub makeImageSY(s_Path, s_File)
If nSYWZFlag = 0 And nSYTPFlag = 0 Then Exit Sub
If isValidSLTSYExt(s_File) = False Then Exit Sub
On Error Resume Next
Dim nOriginalWidth, nOriginalHeight, posX, posY
Dim oImage, oLogo
Select Case nSLTSYObject
Case 0, 1
If IsObjInstalled("Persits.Jpeg") = False Then Exit Sub
Set oImage = Server.CreateObject("Persits.Jpeg")
If nSYWZFlag = 1 Then
oImage.Open (s_Path & s_File)
nOriginalWidth = oImage.OriginalWidth
nOriginalHeight = oImage.OriginalHeight
If nOriginalWidth<nSYWZMinWidth Or nOriginalHeight<nSYWZMinHeight Then Exit Sub
posX = getSYPosX(nSYWZPosition, nOriginalWidth, nSYWZTextWidth+nSYShadowOffset, nSYWZPaddingH)
posY = getSYPosY(nSYWZPosition, nOriginalHeight, nSYWZTextHeight+nSYShadowOffset, nSYWZPaddingV)
oImage.Canvas.Font.Color = Clng("&H" & sSYFontColor)
oImage.Canvas.Font.Family = sSYFontName
oImage.Canvas.Font.Size = nSYFontSize
oImage.Canvas.Font.ShadowColor = Clng("&H" & sSYShadowColor)
oImage.Canvas.Font.ShadowXOffset = nSYShadowOffset
oImage.Canvas.Font.ShadowYOffset = nSYShadowOffset
oImage.Canvas.Print posX, posY, sSYText
oImage.Save (s_Path & s_File)
End If
If nSYTPFlag = 1 Then
oImage.Open (s_Path & s_File)
nOriginalWidth = oImage.OriginalWidth
nOriginalHeight = oImage.OriginalHeight
If nOriginalWidth<nSYTPMinWidth Or nOriginalHeight<nSYTPMinHeight Then Exit Sub
posX = getSYPosX(nSYTPPosition, nOriginalWidth, nSYTPImageWidth, nSYTPPaddingH)
posY = getSYPosY(nSYTPPosition, nOriginalHeight, nSYTPImageHeight, nSYTPPaddingV)
If nSLTSYObject = 0 Then
Set oLogo = Server.CreateObject("Persits.Jpeg")
oLogo.Open Server.Mappath(sSYPicPath)
oImage.Canvas.DrawImage posX, posY, oLogo, nSYTPOpacity, &HFFFFFF
Else
oImage.Canvas.DrawPNG posX, posY, Server.Mappath(sSYPicPath)
End If
oImage.Save (s_Path & s_File)
Set oLogo = Nothing
End If
Set oImage = Nothing
Case Else
End Select
End Sub
Function getSYPosX(posFlag, originalW, syW, paddingH)
Select Case posFlag
Case 1, 2, 3
getSYPosX = paddingH
Case 4, 5, 6
getSYPosX = (originalW - syW) \ 2
Case 7, 8, 9
getSYPosX = originalW - paddingH - syW
End Select
End Function
Function getSYPosY(posFlag, originalH, syH, paddingV)
Select Case posFlag
Case 1, 4, 7
getSYPosY = paddingV
Case 2, 5, 8
getSYPosY = (originalH - syH) \ 2
Case 3, 6, 9
getSYPosY = originalH - paddingV - syH
End Select
End Function
Function makeImageSLT(s_Path, s_File, s_SmallFile)
makeImageSLT = False
If nSLTFlag <> 1 Then Exit Function
If isValidSLTSYExt(s_File) = False Then Exit Function
Dim nOriginalWidth, nOriginalHeight, nWidth, nHeight
Dim oImage
Select Case nSLTSYObject
Case 0,1
If IsObjInstalled("Persits.Jpeg") = False Then Exit Function
Set oImage = Server.CreateObject("Persits.Jpeg")
oImage.Open (s_Path & s_File)
nOriginalWidth = oImage.OriginalWidth
nOriginalHeight = oImage.OriginalHeight
Select Case nSLTCheckFlag
Case 0
If nOriginalWidth <= nSLTMinSize Then Exit Function
nWidth = nSLTOkSize
nHeight = (nSLTOkSize / nOriginalWidth) * nOriginalHeight
Case 1
If nOriginalHeight <= nSLTMinSize Then Exit Function
nHeight = nSLTOkSize
nWidth = (nSLTOkSize / nOriginalHeight) * nOriginalWidth
Case 2
If nOriginalWidth <= nSLTMinSize And nOriginalHeight <= nSLTMinSize Then Exit Function
If nOriginalWidth > nOriginalHeight Then
nWidth = nSLTOkSize
nHeight = (nSLTOkSize / nOriginalWidth) * nOriginalHeight
Else
nHeight = nSLTOkSize
nWidth = (nSLTOkSize / nOriginalHeight) * nOriginalWidth
End If
End Select
oImage.Width = nWidth
oImage.Height = nHeight
oImage.Save (s_Path & s_SmallFile)
Set oImage = Nothing
Case Else
End Select
makeImageSLT = True
End Function
Function isValidSLTSYExt(s_File)
Dim b, i, aExt, sExt
b = False
sExt = LCase(Mid(s_File, InstrRev(s_File, ".")+1))
aExt = Split(LCase(sSLTSYExt), "|")
For i = 0 To UBound(aExt)
If aExt(i) = sExt Then
b = True
Exit For
End If
Next
isValidSLTSYExt = b
End Function
Function getSmallImageFile(s_File)
Dim n
n = InstrRev(s_File, ".")
getSmallImageFile = Left(s_File, n-1) & "_s." & Mid(s_File, n+1)
End Function
Sub DoRemote()
Dim sContent, i
For i = 1 To Request.Form("eWebEditor_UploadText").Count 
sContent = sContent & Request.Form("eWebEditor_UploadText")(i) 
Next
If sAllowExt <> "" Then
sContent = ReplaceRemoteUrl(sContent, sAllowExt)
End If
Response.Write "<html><head><title>eWebEditor</title><meta http-equiv='Content-Type' content='text/html; charset=gb2312'></head><body>" & _
"<input type=hidden id=UploadText value=""" & inHTML(sContent) & """>" & _
"</body></html>"
Call OutScript("parent.setHTML(document.getElementById('UploadText').value);try{parent.addUploadFile('" & sOriginalFileName & "', '" & sPathFileName & "');} catch(e){} parent.remoteUploadOK();")
End Sub
Sub CheckSpaceSize()
If sSpaceSize = "" Then Exit Sub
Dim s_Dir
If sSpacePath = "" Then
s_Dir = sUploadDir
Else
s_Dir = sSpacePath
End If
If GetFolderSize(s_Dir)>=CDbl(sSpaceSize) Then
Call OutScript("parent.UploadError('space')")
End If
End Sub
Function GetFolderSize(s_Dir)
Dim fso, dir, size
Set fso = Server.CreateObject("Scripting.FileSystemObject")
If fso.FolderExists(s_Dir) = False Then
GetFolderSize = 0
Exit Function
End If
Set dir = fso.GetFolder(s_Dir)
size = dir.Size/1024/1024
Set dir = Nothing
Set fso = Nothing
size = Fix(size*100+0.5)/100
GetFolderSize = size
End Function
Sub DoCreateNewDir()
Dim a, i
If sCusDir<>"" Then
a = Split(sCusDir, "/")
For i = 0 To UBound(a)
If a(i) <> "" Then
Call CreateFolder(a(i))
End If
Next
End If
Call CheckSpaceSize()
Select Case sAutoDirOrderFlag
Case "0"
Call DoCreateNewTypeDir()
Call DoCreateNewDateDir()
Case "1"
Call DoCreateNewDateDir()
Call DoCreateNewTypeDir()
End Select
End Sub
Sub DoCreateNewDateDir()
If sAutoDir = "" Then Exit Sub
Dim a, i, s_DateDir
s_DateDir = ReplaceTime(Now(), sAutoDir)
a = Split(s_DateDir, "/")
For i = 0 To UBound(a)
If a(i) <> "" Then
Call CreateFolder(a(i))
End If
Next
End Sub
Sub DoCreateNewTypeDir()
If sAutoTypeDir = "" Then Exit Sub
Dim a, i
a = Split(sAutoTypeDir, "/")
For i = 0 To UBound(a)
If a(i) <> "" Then
Call CreateFolder(a(i))
End If
Next
End Sub
Sub CreateFolder(s_Folder)
If IsObjInstalled("Scripting.FileSystemObject") = False Then
Exit Sub
End If
sUploadDir = sUploadDir & s_Folder & "\"
sContentPath = sContentPath & s_Folder & "/"
Dim fso
Set fso = Server.CreateObject("Scripting.FileSystemObject")
If fso.FolderExists(sUploadDir) = False Then
fso.CreateFolder sUploadDir
End If
Set fso = Nothing
End Sub
Sub DoUpload()
If nAllowSize <= 0 Then
Call OutScript("parent.UploadError('size')")
Exit Sub
End If
Select Case nUploadObject
Case 1
Call DoUpload_ASPUpload()
Case 2
Call DoUpload_SAFileUP()
Case 3
Call DoUpload_LyfUpload()
Case Else
Call DoUpload_Class()
End Select
End Sub
Sub DoUpload_LyfUpload()
On Error Resume Next
Dim oUpload, sResult, sOriginalFile
Set oUpload = Server.CreateObject("LyfUpload.UploadFile")
oUpload.CodePage = 936
oUpload.ExtName = Replace(sAllowExt, "|", ",")
oUpload.MaxSize = nAllowSize*1024
sOriginalFile = oUpload.Request("originalfile")
sOriginalFileName = Mid(sOriginalFile, InStrRev(sOriginalFile, "\") + 1)
sFileExt = LCase(Mid(sOriginalFileName, InStrRev(sOriginalFileName, ".") + 1))
Call CheckValidExt(sFileExt)
sSaveFileName = GetRndFileName(sFileExt)
sResult = oUpload.SaveFile("uploadfile", sUploadDir, True, sSaveFileName)
Select Case sResult
Case "0"
Call OutScript("parent.UploadError('size')")
Case ""
Call OutScript("parent.UploadError('file')")
Case "1"
Call OutScript("parent.UploadError('ext')")
End Select
Set oUpload = Nothing
End Sub
Sub DoUpload_SAFileUp()
On Error Resume Next
Dim oFileUp
Set oFileUp = Server.CreateObject("SoftArtisans.FileUp")
oFileUp.CodePage = 936
oFileUp.Path = sUploadDir
If (oFileUp.Form("uploadfile").TotalBytes/1024) > nAllowSize Then
Err.Clear
Call OutScript("parent.UploadError('size')")
End If
If oFileUp.Form("uploadfile").IsEmpty Then
Call OutScript("parent.UploadError('file')")
End If
Dim sShortFileName
sShortFileName = Mid(oFileUp.Form("uploadfile").UserFilename, InstrRev(oFileUp.Form("uploadfile").UserFilename, "\") + 1)
sFileExt = LCase(Mid(sShortFileName, InStrRev(sShortFileName, ".") + 1))
Call CheckValidExt(sFileExt)
sOriginalFileName = sShortFileName
sSaveFileName = GetRndFileName(sFileExt)
Dim str_Mappath, s_TrueSavePath
str_Mappath = sUploadDir & sSaveFileName
s_TrueSavePath = MFU_GetSavePath(str_Mappath)
oFileUp.Form("uploadfile").SaveAs (s_TrueSavePath)
Set oFileUp = Nothing
Call MFU_DoUploadAfter(str_Mappath)
End Sub
Sub DoUpload_ASPUpload()
On Error Resume Next
Dim oUpload, oFile, nCount
Set oUpload = Server.CreateObject("Persits.Upload")
oUpload.CodePage = 936
oUpload.SetMaxSize nAllowSize*1024, True
nCount = oUpload.Save
If nCount < 1 Then
Call OutScript("parent.UploadError('file')")
End If
If Err.Number = 8 Then
Err.Clear
Call OutScript("parent.UploadError('size')")
End If
Set oFile = oUpload.Files("uploadfile")
sFileExt = LCase(Mid(oFile.Ext, 2))
Call CheckValidExt(sFileExt)
sOriginalFileName = oFile.FileName
sSaveFileName = GetRndFileName(sFileExt)
Dim str_Mappath, s_TrueSavePath
str_Mappath = sUploadDir & sSaveFileName
s_TrueSavePath = MFU_GetSavePath(str_Mappath)
oFile.SaveAs (s_TrueSavePath)
Set oFile = Nothing
Set oUpload = Nothing
Call MFU_DoUploadAfter(str_Mappath)
End Sub
Sub DoUpload_Class()
On Error Resume Next
Dim oUpload, oFile
Set oUpload = New upfile_class
oUpload.GetData nAllowSize*1024
If oUpload.Err > 0 Then
Select Case oUpload.Err
Case 1
Call OutScript("parent.UploadError('file')")
Case 2
Call OutScript("parent.UploadError('size')")
End Select
End If
Set oFile = oUpload.File("uploadfile")
sFileExt = LCase(oFile.FileExt)	
Call CheckValidExt(sFileExt)
sOriginalFileName = oFile.FileName
sSaveFileName = GetRndFileName(sFileExt)
Dim str_Mappath
str_Mappath = sUploadDir & sSaveFileName
sFileExt = LCase(Mid(str_Mappath, InstrRev(str_Mappath, ".") + 1))
Call CheckValidExt(sFileExt)
Dim s_TrueSavePath
s_TrueSavePath = MFU_GetSavePath(str_Mappath)
oFile.SaveToFile s_TrueSavePath
Set oFile = Nothing
Set oUpload = Nothing
Call MFU_DoUploadAfter(str_Mappath)	
End Sub
Function MFU_GetSavePath(s_Path)
If sAction <> "MFU" Then
MFU_GetSavePath = s_Path
Exit Function
End If
Dim s_Ret
If sParamBlockFile = "" Then
If sParamBlockFlag = "end" Then
s_Ret = s_Path
Else
s_Ret = s_Path & ".tmp1"
End If
Else
If IsFileExists(s_Path & ".tmp1") = False Then
Call OutScript("file")
End If
s_Ret = s_Path & ".tmp2"		
End If
MFU_GetSavePath = s_Ret
End Function
Sub MFU_DoUploadAfter(s_Path)
If sAction <> "MFU" Then
Exit Sub
End If
If sParamBlockFile <> "" Then
If sMFUMode = "1" Then
Call MFU_DoMergeFile_Adv(s_Path)
Else
Call MFU_DoMergeFile_Normal(s_Path)
End If
If sParamBlockFlag = "end" Then
Call RenameFile(s_Path & ".tmp1", s_Path)
End If
End If
End Sub
Sub MFU_DoMergeFile_Adv(s_File)
Dim obj, b
Set obj = Server.CreateObject("eWebSoft.eWebEditorMFUServer")
b = obj.Merge(s_File)
Set obj = Nothing
Call DelFile(s_File & ".tmp2")
End Sub
Sub MFU_DoMergeFile_Normal(s_File)
Dim s_File1, s_File2
s_File1 = s_File & ".tmp1"
s_File2 = s_File & ".tmp2"
Dim dr1, dr2
Set dr1 = Server.CreateObject("adodb.stream")
dr1.Mode=3
dr1.Type=1
dr1.Open
dr1.LoadFromFile s_File1
dr1.Position = dr1.Size
Set dr2 = Server.CreateObject("adodb.stream")
dr2.Mode=3
dr2.Type=1
dr2.Open
dr2.LoadFromFile s_File2
dr1.Write dr2.Read(-1)
dr1.SaveToFile s_File1, 2
dr1.Close
dr2.Close
Set dr1 = Nothing
Set dr2 = Nothing
Call DelFile(s_File2)
End Sub
Function GetRndFileName(s_Ext)
If sAction = "MFU" And sParamBlockFile<>"" Then
GetRndFileName = sParamBlockFile & "." & s_Ext
Exit Function
End If
Dim s_Rnd, s_RndTime, s_FileName
If sParamRnd = "" Then
Randomize
s_Rnd = CStr(Int(900 * Rnd) + 100)
Else
s_Rnd = sParamRnd
End If
s_RndTime = FormatTime(Now(), 5) & s_Rnd
s_FileName = s_RndTime & "." & s_Ext
If sAction = "SAVE" Or sAction = "MFU" Then
Dim s_Pre
s_Pre = GetOriginalFileNamePre(sOriginalFileName, s_Ext)
If s_Pre <> "" Then
If (sFileNameMode="1" Or (sFileNameMode="2" And sType="FILE")) Then
s_FileName = s_Pre & "." & s_Ext
If sFileNameSameFix<>"" Then
If IsFileExists(sUploadDir & s_FileName) = True Then
s_FileName = Replace(sFileNameSameFix, "{time}", s_RndTime, 1, -1, 1)
If InStr(s_FileName, "{sn}")>0 Then
Dim i, s
i = 0
Do While True
i = i + 1
s = Replace(s_FileName, "{sn}", CStr(i), 1, -1, 1)
s = Replace(s, "{name}", s_Pre, 1, -1, 1)
If IsFileExists(sUploadDir & s & "." & s_Ext) = False Then
s_FileName = s
Exit Do
End If
Loop
Else
s_FileName = Replace(s_FileName, "{name}", s_Pre, 1, -1, 1)
End If
s_FileName = s_FileName & "." & s_Ext
End If
End If
End If
End If
End If
GetRndFileName = s_FileName
End Function
Function GetOriginalFileNamePre(s_FileName, s_OkExt)
GetOriginalFileNamePre = ""
s_FileName = Replace(s_FileName, "%20", " ", 1, -1, 1)
s_FileName = Trim(s_FileName)
If s_FileName = "" Then Exit Function
Dim n
s_FileName = Replace(s_FileName, "/", "\")
n = InStrRev(s_FileName, "\")
If n>0 Then
s_FileName = Mid(s_FileName, n+1)
End If
n = InstrRev(s_FileName, ".")
If n<=1 Then Exit Function
Dim s_Ext
s_Ext = Mid(s_FileName, n+1)
If LCase(s_Ext) <> LCase(s_OkExt) Then Exit Function
Dim s_Pre
s_Pre = Left(s_FileName, n-1)
If IsFileNameFormat(s_Pre) = False Then
s_Pre = ""
End If
GetOriginalFileNamePre = Trim(s_Pre)
End Function
Sub OutScript(str)
If sAction <> "LOCAL" Then
Response.Write "<script language=javascript>" & str & ";</script>"
End If
Response.End
End Sub
Sub CheckValidExt(s_Ext)
If CheckValidExt2(s_Ext, sAllowExt) = False Then
Call OutScript("parent.UploadError('ext')")
End If
End Sub
Function CheckValidExt2(s_Ext, s_AllowExt)
Dim b, i, a_Ext
b = False
a_Ext = Split(s_AllowExt, "|")
For i = 0 To UBound(a_Ext)
If LCase(a_Ext(i)) = s_Ext Then
b = True
Exit For
End If
Next
CheckValidExt2 = b
End Function
Sub InitUpload()
sType = UCase(Trim(Request.QueryString("type")))
sStyleName = Trim(Request.QueryString("style"))
sCusDir = Trim(Request.QueryString("cusdir"))
sParamSYFlag = Trim(Request.QueryString("syflag"))
sParamRnd = Trim(Request.QueryString("rnd"))
Dim s_SKey, s_SParams
s_SKey = Trim(Request.QueryString("skey"))
s_SParams = Trim(Request.QueryString("sparams"))
sParamBlockFile = Trim(Request.QueryString("blockfile"))
sParamBlockFlag = Trim(Request.QueryString("blockflag"))
If sParamBlockFile <> "" Then
If IsFileNameFormat(sParamBlockFile) = False Then
Call OutScript("blockfile")
End If
End If
Dim i, aStyleConfig, bValidStyle
bValidStyle = False
For i = 1 To Ubound(aStyle)
aStyleConfig = Split(aStyle(i), "|||")
If Lcase(sStyleName) = Lcase(aStyleConfig(0)) Then
bValidStyle = True
Exit For
End If
Next
If bValidStyle = False Then
Call OutScript("parent.UploadError('style')")
End If
If aStyleConfig(61) <> "1" Then
sCusDir = ""
End If
Dim ss_FileSize, ss_FileBrowse, ss_SpaceSize, ss_SpacePath, ss_PathMode, ss_PathUpload, ss_PathCusDir, ss_PathCode, ss_PathView
If (aStyleConfig(61) = "2") And (s_SKey <> "" Or IsOkSParams(s_SParams, aStyleConfig(70)) = True) Then
If s_SKey <> "" Then
ss_FileSize = GetSAPIvalue(s_SKey, "FileSize")
ss_FileBrowse = GetSAPIvalue(s_SKey, "FileBrowse")
ss_SpaceSize = GetSAPIvalue(s_SKey, "SpaceSize")
ss_SpacePath = GetSAPIvalue(s_SKey, "SpacePath")
ss_PathMode = GetSAPIvalue(s_SKey, "PathMode")
ss_PathUpload = GetSAPIvalue(s_SKey, "PathUpload")
ss_PathCusDir = GetSAPIvalue(s_SKey, "PathCusDir")
ss_PathCode = GetSAPIvalue(s_SKey, "PathCode")
ss_PathView = GetSAPIvalue(s_SKey, "PathView")
Else
Dim a_SParams
a_SParams = Split(s_SParams, "|")
ss_FileSize = a_SParams(1)
ss_FileBrowse = a_SParams(2)
ss_SpaceSize = a_SParams(3)
ss_SpacePath = a_SParams(4)
ss_PathMode = a_SParams(5)
ss_PathUpload = a_SParams(6)
ss_PathCusDir = a_SParams(7)
ss_PathCode = a_SParams(8)
ss_PathView = a_SParams(9)
End If
If IsNumeric(ss_FileSize) = True Then
aStyleConfig(11) = ss_FileSize
aStyleConfig(12) = ss_FileSize
aStyleConfig(13) = ss_FileSize
aStyleConfig(14) = ss_FileSize
aStyleConfig(15) = ss_FileSize
aStyleConfig(45) = ss_FileSize
Else
ss_FileSize = ""
End If
If ss_FileBrowse = "0" Or ss_FileBrowse = "1" Then
aStyleConfig(43) = ss_FileBrowse
Else
ss_FileBrowse = ""
End If
If IsNumeric(ss_SpaceSize) = True Then
aStyleConfig(78) = ss_SpaceSize
Else
ss_SpaceSize = ""
End If
If ss_PathMode <> "" Then
aStyleConfig(19) = ss_PathMode
End If
If ss_PathUpload <> "" Then
aStyleConfig(3) = ss_PathUpload
End If
If ss_PathCode <> "" Then
aStyleConfig(23) = ss_PathCode
End If
If ss_PathView <> "" Then
aStyleConfig(22) = ss_PathView
End If
sCusDir = ss_PathCusDir
sSpacePath = ss_SpacePath
Else
sSpacePath = ""
End If
sBaseUrl = aStyleConfig(19)
nUploadObject = Clng(aStyleConfig(20))
sAutoDir = aStyleConfig(71)
sUploadDir = aStyleConfig(3)
If sBaseUrl<>"3" Then
If Left(sUploadDir, 1) <> "/" Then
sUploadDir = "../" & sUploadDir
End If
End If
Select Case sBaseUrl
Case "0", "3"
sContentPath = aStyleConfig(23)
Case "1"
sContentPath = RelativePath2RootPath(sUploadDir)
Case "2"
sContentPath = RootPath2DomainPath(RelativePath2RootPath(sUploadDir))
End Select
sSetContentPath = sContentPath
If sBaseUrl<>"3" Then
sUploadDir = Server.Mappath(sUploadDir)
End If
If Right(sUploadDir,1)<>"\" Then
sUploadDir = sUploadDir & "\"
End If
Select Case sType
Case "REMOTE"
sAllowExt = aStyleConfig(10)
nAllowSize = Clng(aStyleConfig(15))
sAutoTypeDir = aStyleConfig(93)
Case "FILE"
sAllowExt = aStyleConfig(6)
nAllowSize = Clng(aStyleConfig(11))
sAutoTypeDir = aStyleConfig(92)
Case "MEDIA"
sAllowExt = aStyleConfig(9)
nAllowSize = Clng(aStyleConfig(14))
sAutoTypeDir = aStyleConfig(91)
Case "FLASH"
sAllowExt = aStyleConfig(7)
nAllowSize = Clng(aStyleConfig(12))
sAutoTypeDir = aStyleConfig(90)
Case "LOCAL"
sAllowExt = aStyleConfig(44)
nAllowSize = Clng(aStyleConfig(45))
sAutoTypeDir = aStyleConfig(94)
Case Else
sAllowExt = aStyleConfig(8)
nAllowSize = Clng(aStyleConfig(13))
sAutoTypeDir = aStyleConfig(89)
End Select
nSLTFlag = Clng(aStyleConfig(29))
nSLTMode = Clng(aStyleConfig(69))
nSLTCheckFlag = Clng(aStyleConfig(77))
nSLTMinSize = Clng(aStyleConfig(30))
nSLTOkSize = Clng(aStyleConfig(31))
nSYWZFlag = Clng(aStyleConfig(32))
sSYText = aStyleConfig(33)
sSYFontColor = aStyleConfig(34)
nSYFontSize = Clng(aStyleConfig(35))
sSYFontName = aStyleConfig(36)
sSYPicPath = aStyleConfig(37)
nSLTSYObject = Clng(aStyleConfig(38))
sSLTSYExt = aStyleConfig(39)
nSYWZMinWidth = Clng(aStyleConfig(40))
sSYShadowColor = aStyleConfig(41)
nSYShadowOffset = Clng(aStyleConfig(42))
nSYWZMinHeight = Clng(aStyleConfig(46))
nSYWZPosition = Clng(aStyleConfig(47))
nSYWZTextWidth = Clng(aStyleConfig(48))
nSYWZTextHeight = Clng(aStyleConfig(49))
nSYWZPaddingH = Clng(aStyleConfig(50))
nSYWZPaddingV = Clng(aStyleConfig(51))
nSYTPFlag = Clng(aStyleConfig(52))
nSYTPMinWidth = Clng(aStyleConfig(53))
nSYTPMinHeight = Clng(aStyleConfig(54))
nSYTPPosition = Clng(aStyleConfig(55))
nSYTPPaddingH = Clng(aStyleConfig(56))
nSYTPPaddingV = Clng(aStyleConfig(57))
nSYTPImageWidth = Clng(aStyleConfig(58))
nSYTPImageHeight = Clng(aStyleConfig(59))
nSYTPOpacity = CDbl(aStyleConfig(60))
sSpaceSize = aStyleConfig(78)
sMFUMode = aStyleConfig(79)
sFileNameMode = aStyleConfig(68)
sFileNameSameFix = aStyleConfig(87)
sAutoDirOrderFlag = aStyleConfig(88)
If nSYWZFlag=2 Then
If sParamSYFlag = "1" Then
nSYWZFlag = 1
Else
nSYWZFlag = 0
End If
End If
If nSYTPFlag=2 Then
If sParamSYFlag = "1" Then
nSYTPFlag = 1
Else
nSYTPFlag = 0
End If
End If
If IsInt(sParamRnd)=False Then
sParamRnd = ""
End If
If sCusDir <> "" Then
sCusDir = Replace(sCusDir, "\", "/")
If Left(sCusDir, 1) = "/" Or Left(sCusDir, 1) = "." Or Right(sCusDir, 1) = "." Or InStr(sCusDir, "./") > 0 Or InStr(sCusDir, "/.") > 0 Or InStr(sCusDir, "//") > 0 Or InStr(sCusDir, "..") > 0 Then
sCusDir = ""
Else
If Right(sCusDir, 1) <> "/" Then
sCusDir = sCusDir & "/"
End If
End If
End If
End Sub
Function RelativePath2RootPath(url)
Dim sTempUrl
sTempUrl = url
If Left(sTempUrl, 1) = "/" Then
RelativePath2RootPath = sTempUrl
Exit Function
End If
Dim sWebEditorPath
sWebEditorPath = Request.ServerVariables("SCRIPT_NAME")
sWebEditorPath = Left(sWebEditorPath, InstrRev(sWebEditorPath, "/") - 1)
Do While Left(sTempUrl, 3) = "../"
sTempUrl = Mid(sTempUrl, 4)
sWebEditorPath = Left(sWebEditorPath, InstrRev(sWebEditorPath, "/") - 1)
Loop
RelativePath2RootPath = sWebEditorPath & "/" & sTempUrl
End Function
Function RootPath2DomainPath(url)
Dim sHost
sHost = Split(Request.ServerVariables("SERVER_PROTOCOL"), "/")(0) & "://" & Request.ServerVariables("HTTP_HOST")
RootPath2DomainPath = sHost & url
End Function
Function ReplaceRemoteUrl(sHTML, sExt)
Dim s_Content
s_Content = sHTML
If IsObjInstalled("Microsoft.XMLHTTP") = False Or nAllowSize <= 0 then
ReplaceRemoteUrl = s_Content
Exit Function
End If
Dim re, RemoteFile, RemoteFileurl, SaveFileName, SaveFileType
Set re = new RegExp
re.IgnoreCase  = True
re.Global = True
re.Pattern = "((http|https|ftp|rtsp|mms):(\/\/|\\\\){1}(([A-Za-z0-9_-])+[.]){1,}([A-Za-z0-9]{1,5})\/(\S+\.(" & sExt & ")))"
Set RemoteFile = re.Execute(s_Content)
Dim a_RemoteUrl(), n, i, bRepeat
Dim b_SameSiteUrl, s_SameSiteDomain
If sBaseUrl="3" Then
s_SameSiteDomain = GetDomainFromUrl(sSetContentPath)
Else
s_SameSiteDomain = LCase(Request.ServerVariables("SERVER_NAME"))
End If
n = 0
For Each RemoteFileurl in RemoteFile
b_SameSiteUrl = False
If GetDomainFromUrl(RemoteFileurl) = s_SameSiteDomain Then
b_SameSiteUrl = True
End If
If b_SameSiteUrl=False Then
If n = 0 Then
n = n + 1
Redim a_RemoteUrl(n)
a_RemoteUrl(n) = RemoteFileurl
Else
bRepeat = False
For i = 1 To UBound(a_RemoteUrl)
If UCase(RemoteFileurl) = UCase(a_RemoteUrl(i)) Then
bRepeat = True
Exit For
End If
Next
If bRepeat = False Then
n = n + 1
Redim Preserve a_RemoteUrl(n)
a_RemoteUrl(n) = RemoteFileurl
End If
End If
End If
Next
nFileNum = 0
For i = 1 To n
SaveFileType = Mid(a_RemoteUrl(i), InstrRev(a_RemoteUrl(i), ".") + 1)
SaveFileName = GetRndFileName(SaveFileType)
If SaveRemoteFile(SaveFileName, a_RemoteUrl(i)) = True Then
nFileNum = nFileNum + 1
If nFileNum > 1 Then
sOriginalFileName = sOriginalFileName & "|"
sSaveFileName = sSaveFileName & "|"
sPathFileName = sPathFileName & "|"
End If
sOriginalFileName = sOriginalFileName & Mid(a_RemoteUrl(i), InstrRev(a_RemoteUrl(i), "/") + 1)
sSaveFileName = sSaveFileName & SaveFileName
sPathFileName = sPathFileName & sContentPath & SaveFileName
s_Content = Replace(s_Content, a_RemoteUrl(i), sContentPath & SaveFileName, 1, -1, 1)
End If
Next
ReplaceRemoteUrl = s_Content
End Function
Function SaveRemoteFile(s_LocalFileName, s_RemoteFileUrl)
Dim Ads, Retrieval, GetRemoteData
Dim bError
bError = False
SaveRemoteFile = False
On Error Resume Next
Set Retrieval = Server.CreateObject("Microsoft.XMLHTTP")
With Retrieval
.Open "Get", s_RemoteFileUrl, False, "", ""
.Send
GetRemoteData = .ResponseBody
End With
Set Retrieval = Nothing
If LenB(GetRemoteData) > nAllowSize*1024 Then
bError = True
Else
Set Ads = Server.CreateObject("Adodb." & "Stream")
With Ads
.Type = 1
.Open
.Write GetRemoteData
.SaveToFile sUploadDir & s_LocalFileName, 2
.Cancel()
.Close()
End With
Set Ads=nothing
End If
If Err.Number = 0 And bError = False Then
SaveRemoteFile = True
Else
Err.Clear
End If
End Function
Function IsObjInstalled(strClassString)
On Error Resume Next
IsObjInstalled = False
Err = 0
Dim xTestObj
Set xTestObj = Server.CreateObject(strClassString)
If 0 = Err Then IsObjInstalled = True
Set xTestObj = Nothing
Err = 0
End Function
Function inHTML(str)
Dim sTemp
sTemp = str
inHTML = ""
If IsNull(sTemp) = True Then
Exit Function
End If
sTemp = Replace(sTemp, "&", "&amp;")
sTemp = Replace(sTemp, "<", "&lt;")
sTemp = Replace(sTemp, ">", "&gt;")
sTemp = Replace(sTemp, Chr(34), "&quot;")
inHTML = sTemp
End Function
Function ReplaceTime(s_Time, s_Patt)
If IsDate(s_Time) = False Then
    ReplaceTime = ""
    Exit Function
End If
Dim ret
ret = s_Patt
Dim y1, y2, m1, m2, d1, d2, h1, h2, i1, i2, s1, s2
y2 = CStr(Year(s_Time))
y1 = Right(y2, 2)
m1 = CStr(Month(s_Time))
m2 = Right("0" & m1, 2)
d1 = CStr(Day(s_Time))
d2 = Right("0" & d1, 2)
h1 = CStr(Hour(s_Time))
h2 = Right("0" & h1, 2)
i1 = CStr(Minute(s_Time))
i2 = Right("0" & i1, 2)
s1 = CStr(Second(s_Time))
s2 = Right("0" & s1, 2)
ret = Replace(ret, "{yyyy}", y2, 1, -1, 1)
ret = Replace(ret, "{yy}", y1, 1, -1, 1)
ret = Replace(ret, "{mm}", m2, 1, -1, 1)
ret = Replace(ret, "{m}", m1, 1, -1, 1)
ret = Replace(ret, "{dd}", d2, 1, -1, 1)
ret = Replace(ret, "{d}", d1, 1, -1, 1)
ret = Replace(ret, "{hh}", h2, 1, -1, 1)
ret = Replace(ret, "{h}", h1, 1, -1, 1)
ret = Replace(ret, "{ii}", i2, 1, -1, 1)
ret = Replace(ret, "{i}", i1, 1, -1, 1)
ret = Replace(ret, "{ss}", s2, 1, -1, 1)
ret = Replace(ret, "{s}", s1, 1, -1, 1)
ReplaceTime = ret
End Function
Sub DelFile(s_MapFile)
On Error Resume Next
Dim fso
Set fso = Server.CreateObject("Scripting.FileSystemObject")
If fso.FileExists(s_MapFile) Then
fso.DeleteFile(s_MapFile)
End If
Set fso = Nothing
End Sub
Function IsFileExists(s_MapFile)
On Error Resume Next
Err.Clear
Dim fso
Set fso = Server.CreateObject("Scripting.FileSystemObject")
IsFileExists = fso.FileExists(s_MapFile)
Set fso = Nothing
If Err.Number <> 0 Then
Call OutScript("FSO")
End If
End Function
Sub RenameFile(s_File1, s_File2)
On Error Resume Next
Dim fso
Set fso = Server.CreateObject("Scripting.FileSystemObject")
fso.MoveFile s_File1, s_File2
Set fso = Nothing
End Sub
Function GetDomainFromUrl(s_Url)
Dim s, n
s = LCase(s_Url)
n = InStr(s, "://")
If n>0 Then
s = Mid(s, n+3)
End If
n = InStr(s, "/")
If n>0 Then
s = Left(s, n-1)
End If
n = InStr(s, ":")
If n>0 Then
s = Left(s, n-1)
End If
GetDomainFromUrl = s
End Function
Function IsFileNameFormat(s_Name)
IsFileNameFormat = False
If Left(s_Name, 1)="." Then Exit Function
If RegExpTest(s_Name, "[\/\\\:\*\?\""\<\>\|\r\n\t]+") = True Then Exit Function
IsFileNameFormat = True
End Function
%>