<%@ LANGUAGE = VBScript %>
<!--#include file="private.asp"-->
<!--#include file="config.asp"-->
<!--#include file="md5.asp"-->
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
Dim sAction
sAction = UCase(Trim(Request.QueryString("action")))
Select Case sAction
Case "LICENSE"
Call ShowLicense()
Case "CONFIG"
Call ShowConfig()
End Select
Sub ShowLicense()
If sLicense="" Then
Exit Sub
End If
Dim r
r = Trim(Request("r"))
If Len(r)<10 Then
Exit Sub
End If
Dim s_Domain
s_Domain=LCase(Request.ServerVariables("SERVER_NAME"))
If s_Domain="127.0.0.1" Or s_Domain="localhost" Then
Exit Sub
End If
Dim aa, a, i, j, ret
ret=""
aa = Split(sLicense, ";")
For i = 0 To UBound(aa)
a = Split(aa(i), ":")
If UBound(a)=7 Then
If Len(a(7))=32 Then
Dim b
b = False
Select Case a(0)
Case "3"
If (a(6)=s_Domain) Or (Right(s_Domain, Len(a(6))+1)="." & a(6)) Then
b = True
End If
Case Else
If (a(6)=s_Domain) Or ("www." & a(6)=s_Domain) Then
b = True
End If
End Select
If (b = True) Then
For j=0 To 6
ret=ret & a(j) & ":"
Next 
ret=ret & MD5(Left(a(7),16) & r) & MD5(Right(a(7),16) & r)
Exit For
End If
End If
End If
Next
Response.Write ret
End Sub
Sub ShowConfig()
Dim s_License
If CheckLicense()=True Then
s_License = "ok"
Else
s_License = ""
End If
Dim s_StyleName, n_StyleID
s_StyleName = Trim(Request.QueryString("style"))
Dim i, aTmpStyle, b
b = False
For i = 1 To Ubound(aStyle)
aTmpStyle = Split(aStyle(i), "|||")
If Lcase(s_StyleName) = Lcase(aTmpStyle(0)) Then
n_StyleID = i
b = True
Exit For
End If
Next
If b = False Then
Exit Sub
End If
Dim s_SKey, s_SParams
s_SKey = Trim(Request.QueryString("skey"))
s_SParams = ""
Dim ss_FileSize, ss_FileBrowse, ss_SpaceSize, ss_SpacePath, ss_PathMode, ss_PathUpload, ss_PathCusDir, ss_PathCode, ss_PathView
ss_PathCusDir = ""
If aTmpStyle(61) = "2" And s_SKey <> "" Then
ss_FileSize = GetSAPIvalue(s_SKey, "FileSize")
ss_FileBrowse = GetSAPIvalue(s_SKey, "FileBrowse")
ss_SpaceSize = GetSAPIvalue(s_SKey, "SpaceSize")
ss_SpacePath = GetSAPIvalue(s_SKey, "SpacePath")
ss_PathMode = GetSAPIvalue(s_SKey, "PathMode")
ss_PathUpload = GetSAPIvalue(s_SKey, "PathUpload")
ss_PathCusDir = GetSAPIvalue(s_SKey, "PathCusDir")
ss_PathCode = GetSAPIvalue(s_SKey, "PathCode")
ss_PathView = GetSAPIvalue(s_SKey, "PathView")
If IsNumeric(ss_FileSize) = True Then
aTmpStyle(11) = ss_FileSize
aTmpStyle(12) = ss_FileSize
aTmpStyle(13) = ss_FileSize
aTmpStyle(14) = ss_FileSize
aTmpStyle(15) = ss_FileSize
aTmpStyle(45) = ss_FileSize
Else
ss_FileSize = ""
End If
If ss_FileBrowse = "0" Or ss_FileBrowse = "1" Then
aTmpStyle(43) = ss_FileBrowse
Else
ss_FileBrowse = ""
End If
If IsNumeric(ss_SpaceSize) = True Then
aTmpStyle(78) = ss_SpaceSize
Else
ss_SpaceSize = ""
End If
If ss_PathMode <> "" Then
aTmpStyle(19) = ss_PathMode
End If
If ss_PathUpload <> "" Then
aTmpStyle(3) = ss_PathUpload
End If
If ss_PathCode <> "" Then
aTmpStyle(23) = ss_PathCode
End If
If ss_PathView <> "" Then
aTmpStyle(22) = ss_PathView
End If
s_SParams = ss_FileSize & "|" & ss_FileBrowse & "|" & ss_SpaceSize & "|" & ss_SpacePath & "|" & ss_PathMode & "|" & ss_PathUpload & "|" & ss_PathCusDir & "|" & ss_PathCode & "|" & ss_PathView
s_SParams = MD5(aTmpStyle(70) & s_SParams) & "|" & s_SParams
End If
Dim ret
ret = ""
ret = ret & "config.FixWidth = """ & aTmpStyle(1) & """;" & Vbcrlf
If aTmpStyle(19) = "3" Then
ret = ret & "config.UploadUrl = """ & aTmpStyle(23) & """;" & Vbcrlf
Else
ret = ret & "config.UploadUrl = """ & aTmpStyle(3) & """;" & Vbcrlf
End If
ret = ret & "config.InitMode = """ & aTmpStyle(18) & """;" & Vbcrlf
ret = ret & "config.AutoDetectPaste = """ & aTmpStyle(17) & """;" & Vbcrlf
ret = ret & "config.BaseUrl = """ & aTmpStyle(19) & """;" & Vbcrlf
ret = ret & "config.BaseHref = """ & aTmpStyle(22) & """;" & Vbcrlf
ret = ret & "config.AutoRemote = """ & aTmpStyle(24) & """;" & Vbcrlf
ret = ret & "config.ShowBorder = """ & aTmpStyle(25) & """;" & Vbcrlf
ret = ret & "config.StateFlag = """ & aTmpStyle(16) & """;" & Vbcrlf
ret = ret & "config.SBCode = """ & aTmpStyle(62) & """;" & Vbcrlf
ret = ret & "config.SBEdit = """ & aTmpStyle(63) & """;" & Vbcrlf
ret = ret & "config.SBText = """ & aTmpStyle(64) & """;" & Vbcrlf
ret = ret & "config.SBView = """ & aTmpStyle(65) & """;" & Vbcrlf
ret = ret & "config.SBSize = """ & aTmpStyle(76) & """;" & Vbcrlf
ret = ret & "config.EnterMode = """ & aTmpStyle(66) & """;" & Vbcrlf
ret = ret & "config.Skin = """ & aTmpStyle(2) & """;" & Vbcrlf
ret = ret & "config.AllowBrowse = """ & aTmpStyle(43) & """;" & Vbcrlf
ret = ret & "config.AllowImageSize = """ & aTmpStyle(13) & """;" & Vbcrlf
ret = ret & "config.AllowFlashSize = """ & aTmpStyle(12) & """;" & Vbcrlf
ret = ret & "config.AllowMediaSize = """ & aTmpStyle(14) & """;" & Vbcrlf
ret = ret & "config.AllowFileSize = """ & aTmpStyle(11) & """;" & Vbcrlf
ret = ret & "config.AllowRemoteSize = """ & aTmpStyle(15) & """;" & Vbcrlf
ret = ret & "config.AllowLocalSize = """ & aTmpStyle(45) & """;" & Vbcrlf
ret = ret & "config.AllowImageExt = """ & aTmpStyle(8) & """;" & Vbcrlf
ret = ret & "config.AllowFlashExt = """ & aTmpStyle(7) & """;" & Vbcrlf
ret = ret & "config.AllowMediaExt = """ & aTmpStyle(9) & """;" & Vbcrlf
ret = ret & "config.AllowFileExt = """ & aTmpStyle(6) & """;" & Vbcrlf
ret = ret & "config.AllowRemoteExt = """ & aTmpStyle(10) & """;" & Vbcrlf
ret = ret & "config.AllowLocalExt = """ & aTmpStyle(44) & """;" & Vbcrlf
ret = ret & "config.AreaCssMode = """ & aTmpStyle(67) & """;" & Vbcrlf
ret = ret & "config.SLTFlag = """ & aTmpStyle(29) & """;" & Vbcrlf
ret = ret & "config.SLTMinSize = """ & aTmpStyle(30) & """;" & Vbcrlf
ret = ret & "config.SLTOkSize = """ & aTmpStyle(31) & """;" & Vbcrlf
ret = ret & "config.SLTMode = """ & aTmpStyle(69) & """;" & Vbcrlf
ret = ret & "config.SLTCheckFlag = """ & aTmpStyle(77) & """;" & Vbcrlf
ret = ret & "config.SYWZFlag = """ & aTmpStyle(32) & """;" & Vbcrlf
ret = ret & "config.SYTPFlag = """ & aTmpStyle(52) & """;" & Vbcrlf
ret = ret & "config.FileNameMode = """ & aTmpStyle(68) & """;" & Vbcrlf
ret = ret & "config.PaginationMode = """ & aTmpStyle(72) & """;" & Vbcrlf
ret = ret & "config.PaginationKey = """ & aTmpStyle(73) & """;" & Vbcrlf
ret = ret & "config.PaginationAutoFlag = """ & aTmpStyle(74) & """;" & Vbcrlf
ret = ret & "config.PaginationAutoNum = """ & aTmpStyle(75) & """;" & Vbcrlf
ret = ret & "config.SParams = """ & s_SParams & """;" & Vbcrlf
ret = ret & "config.SpaceSize = """ & aTmpStyle(78) & """;" & Vbcrlf
ret = ret & "config.MFUBlockSize = """ & aTmpStyle(80) & """;" & Vbcrlf
ret = ret & "config.MFUEnable = """ & aTmpStyle(81) & """;" & Vbcrlf
ret = ret & "config.CodeFormat = """ & aTmpStyle(82) & """;" & Vbcrlf
ret = ret & "config.TB2Flag = """ & aTmpStyle(83) & """;" & Vbcrlf
ret = ret & "config.TB2Mode = """ & aTmpStyle(84) & """;" & Vbcrlf
ret = ret & "config.TB2Max = """ & aTmpStyle(85) & """;" & Vbcrlf
ret = ret & "config.ShowBlock = """ & aTmpStyle(86) & """;" & Vbcrlf
ret = ret & "config.WIIMode = """ & aTmpStyle(95) & """;" & Vbcrlf
ret = ret & "config.QFIFontName = """ & aTmpStyle(96) & """;" & Vbcrlf
ret = ret & "config.QFIFontSize = """ & aTmpStyle(97) & """;" & Vbcrlf
ret = ret & "config.L = ""EWEBEDITORV73GB231212580"";" & Vbcrlf
ret = ret & "config.ServerExt = ""asp"";" & vbCrLf
ret = ret & "config.Charset = ""gb2312"";" & vbCrLf
If ss_PathCusDir <> "" Then
ret = ret & "config.CusDir = """ & ss_PathCusDir & """;" & Vbcrlf
End If
ret = ret & Vbcrlf
ret = ret & "config.Toolbars = [" & Vbcrlf
Dim s_Order, s_ID, n, aTmpToolbar
s_Order = ""
s_ID = ""
For n = 1 To UBound(aToolbar)
If aToolbar(n) <> "" Then
aTmpToolbar = Split(aToolbar(n), "|||")
If aTmpToolbar(0) = CStr(n_StyleID) Then
If s_ID <> "" Then
s_ID = s_ID & "|"
s_Order = s_Order & "|"
End If
s_ID = s_ID & CStr(n)
s_Order = s_Order & aTmpToolbar(3)
End If
End If
Next
Dim a_ID, a_Order, aTmpButton
If s_ID <> "" Then
a_ID = Split(s_ID, "|")
a_Order = Split(s_Order, "|")
For n = 0 To UBound(a_Order)
a_Order(n) = Clng(a_Order(n))
a_ID(n) = Clng(a_ID(n))
Next
For n = 0 To UBound(a_ID)
aTmpToolbar = Split(aToolbar(a_ID(n)), "|||")
aTmpButton = Split(aTmpToolbar(1), "|")
If n >0 Then
ret = ret & "," & Vbcrlf
End If
ret = ret & Chr(9) & "["
For i = 0 To UBound(aTmpButton)
If i > 0 Then
ret = ret & ", "
End If
ret = ret & """" & aTmpButton(i) & """"
Next
ret = ret & "]"
Next
End If
ret = ret & Vbcrlf & "];" & Vbcrlf
Response.Write ret
End Sub
Function CheckLicense()
CheckLicense = False
Dim s_Domain
s_Domain = LCase(Request.ServerVariables("SERVER_NAME"))
If s_Domain="127.0.0.1" Or s_Domain="localhost" Then
CheckLicense = True
Exit Function
End If
If sLicense="" Then	
Exit Function
End If
Dim aa, a, i, j
aa = Split(sLicense, ";")
For i = 0 To UBound(aa)
a = Split(aa(i), ":")
If UBound(a)=7 Then
If Len(a(7))=32 Then
Select Case a(0)
Case "3"
If (a(6)=s_Domain) Or (Right(s_Domain, Len(a(6))+1)="." & a(6)) Then
CheckLicense = True
Exit Function
End If
Case Else
If (a(6)=s_Domain) Or ("www." & a(6)=s_Domain) Then
CheckLicense = True
Exit Function
End If
End Select
End If
End If
Next
End Function
%>