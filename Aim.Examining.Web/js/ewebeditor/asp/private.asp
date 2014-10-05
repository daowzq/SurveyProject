<% Option Explicit %>
<%
Function RegExpTest(str, s_Pattern)
Dim re
Set re = new RegExp
re.IgnoreCase  = True
re.Global = True
re.Pattern = s_Pattern
RegExpTest = re.Test(str)
Set re = Nothing
End Function
Function FormatTime(s_Time, n_Flag)
Dim y, m, d, h, mi, s
FormatTime = ""
If IsDate(s_Time) = False Then Exit Function
y = cstr(year(s_Time))
m = cstr(month(s_Time))
If len(m) = 1 Then m = "0" & m
d = cstr(day(s_Time))
If len(d) = 1 Then d = "0" & d
h = cstr(hour(s_Time))
If len(h) = 1 Then h = "0" & h
mi = cstr(minute(s_Time))
If len(mi) = 1 Then mi = "0" & mi
s = cstr(second(s_Time))
If len(s) = 1 Then s = "0" & s
Select Case n_Flag
Case 1
' yyyy-mm-dd hh:mm:ss
FormatTime = y & "-" & m & "-" & d & " " & h & ":" & mi & ":" & s
Case 2
' yyyy-mm-dd
FormatTime = y & "-" & m & "-" & d
Case 3
' hh:mm:ss
FormatTime = h & ":" & mi & ":" & s
Case 4
' yyyymmdd
FormatTime = y & m & d
Case 5
' yyyymmddhhmmss
FormatTime = y & m & d & h & mi & s
End Select
End Function
Function IsInt(str)
IsInt = False
If str = "" Then
Exit Function
End If
If RegExpTest(str, "[^0-9]+")=False Then
IsInt = True
End If
End Function
Function GetSAPIvalue(s_SessionKey, s_ParamName)
GetSAPIvalue = Trim(Session("eWebEditor_" & s_SessionKey & "_" & s_ParamName))
End Function
Function IsOkSParams(s_SParams, s_EncryptKey)
IsOkSParams = False
If s_SParams = "" Then Exit Function
Dim a, n, s1, s2
n = InStr(s_SParams, "|")
If n <= 0 Then Exit Function
s1 = Left(s_SParams, n - 1)
s2 = Mid(s_SParams, n + 1)
If MD5(s_EncryptKey & s2) <> s1 Then Exit Function
IsOkSParams = True
End Function
%>