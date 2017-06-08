Attribute VB_Name = "Module1"
Option Explicit
Sub QuarantineEmail()
On Error Resume Next
Dim MsgUsr
Dim MsgReply
Dim FromAddr
Dim UsrName, anames
Dim ReplyBody
Dim MsgBody
Dim DisplayName

Set MsgUsr = ActiveExplorer.Selection.Item(1)
If ActiveExplorer.Selection.Count <> 1 Then
    MsgBox ("Please Select One Message only to Reply to")
    Exit Sub
End If

DisplayName = MsgUsr.SenderName
MsgBody = MsgUsr.Body
If InStr(DisplayName, ", ") Then
    anames = Split(DisplayName, ", ")
    UsrName = anames(1)
Else
UsrName = DisplayName
End If
FromAddr = "HelpDesk@parmalat.com.au"
ReplyBody = "Hi " & UsrName & "," & vbCrLf & vbCrLf _
            & "We Have released this email for you." & vbCrLf & vbCrLf _
            & "Regards," & vbCrLf & vbCrLf _
            & "Help Desk - IT Client Services" & vbCrLf _
            & "Parmalat, Australia" & vbCrLf _
            & "PH: (07) 38400 170" & vbCrLf _
            & "Email: HelpDesk@parmalat.com.au" & vbCrLf & vbCrLf _
            & "----------------------------- Original Message -------------------------" & vbCrLf & vbCrLf _
            & MsgBody
Set MsgReply = MsgUsr.ReplyAll
With MsgReply
    .SentOnBehalfOfName = FromAddr
    .Body = ReplyBody
End With
MsgReply.Send
MsgBox ("Reply Sent!")
End Sub
Sub LogNewJob()
On Error Resume Next
Dim MsgUsr
Dim MsgReply
Dim FromAddr
Dim UsrName, anames
Dim ReplyBody
Dim MsgBody
Dim DisplayName
Dim JobNumber

Set MsgUsr = ActiveExplorer.Selection.Item(1)
If ActiveExplorer.Selection.Count <> 1 Then
    MsgBox ("Please Select One Message only to Reply to")
    Exit Sub
End If

JobNumber = InputBox("Please enter the job Number", "Enter Job Number")
If StrPtr(JobNumber) = 0 Then
    Exit Sub
End If
DisplayName = MsgUsr.SenderName
MsgBody = MsgUsr.Body
If InStr(DisplayName, ", ") Then
    anames = Split(DisplayName, ", ")
    UsrName = anames(1)
Else
UsrName = DisplayName
End If
FromAddr = "HelpDesk@parmalat.com.au"
ReplyBody = "Hi " & UsrName & "," & vbCrLf & vbCrLf _
            & "We have logged Job Number " & JobNumber & " For your request. One of our support personel will contact you as soon as possible." & vbCrLf & vbCrLf _
            & "Regards," & vbCrLf & vbCrLf _
            & "Help Desk - IT Client Services" & vbCrLf _
            & "Parmalat, Australia" & vbCrLf _
            & "PH: (07) 38400 170" & vbCrLf _
            & "Email: HelpDesk@parmalat.com.au" & vbCrLf & vbCrLf _
            & "----------------------------- Original Message -------------------------" & vbCrLf & vbCrLf _
            & MsgBody
Set MsgReply = MsgUsr.ReplyAll
With MsgReply
    .SentOnBehalfOfName = FromAddr
    .Body = ReplyBody
End With
MsgReply.Send
MsgBox ("Reply Sent!")
End Sub
Sub NewMessage()
On Error Resume Next
Dim NewMsg
Dim FromAddr
Dim strSig

FromAddr = "HelpDesk@parmalat.com.au"
strSig = "<P><FONT COLOR=""#000000"" FACE=""Arial""><BR></P>" _
        & "<P><FONT COLOR=""#000000"" FACE=""Arial"">Regards.</FONT>" _
        & "</P>" _
        & "<SPAN LANG=""en-us""><B><FONT COLOR=""#000000"" FACE=""Arial"">Help Desk - IT Client Services</FONT></B></SPAN><SPAN LANG=""en-au"">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </SPAN>" _
        & "<BR><SPAN LANG=""en-au""><FONT COLOR=""#000000"" FACE=""Arial"">Parmalat, Australia </FONT></SPAN>" _
        & "<BR><SPAN LANG=""en-au""><FONT COLOR=""#000000"" FACE=""Arial"">PH (07) 38400170</FONT></SPAN>" _
        & "<BR><SPAN LANG=""en-au""><U></U></SPAN><A HREF=""mailto:HelpDesk@parmalat.com.au""><SPAN LANG=""en-au""><U><FONT COLOR=""#3333FF"" FACE=""Arial"">HelpDesk@parmalat.com.au</FONT></U><U></U></SPAN></A><SPAN LANG=""en-au""><U></U></SPAN>" _
        & "</P>"

Set NewMsg = Application.CreateItem(olMailItem)
With NewMsg
    .SentOnBehalfOfName = FromAddr
    .HTMLBody = strSig
    .Display
End With
End Sub
Sub ReplyToMessage()
On Error Resume Next
Dim NewMsg
Dim FromAddr
Dim strSig
Dim MsgUsr
Dim MsgBody
Dim DisplayName, anames, UsrName
Dim MsgReply

Set MsgUsr = ActiveExplorer.Selection.Item(1)
If ActiveExplorer.Selection.Count <> 1 Then
    MsgBox ("Please Select One Message only to Reply to")
    Exit Sub
End If
MsgBody = Replace(MsgUsr.Body, vbCrLf, "<BR>")
DisplayName = MsgUsr.SenderName
If InStr(DisplayName, ", ") Then
    anames = Split(DisplayName, ", ")
    UsrName = anames(1)
Else
UsrName = DisplayName
End If
Set MsgReply = MsgUsr.ReplyAll

FromAddr = "HelpDesk@parmalat.com.au"
strSig = "<P><FONT COLOR=""#000000"" FACE=""Arial"">Hi " & UsrName & ",<BR></P>" _
        & "<P><FONT COLOR=""#000000"" FACE=""Arial""><BR></P>" _
        & "<P><FONT COLOR=""#000000"" FACE=""Arial"">Regards.</FONT>" _
        & "</P>" _
        & "<SPAN LANG=""en-us""><B><FONT COLOR=""#000000"" FACE=""Arial"">Help Desk - IT Client Services</FONT></B></SPAN><SPAN LANG=""en-au"">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </SPAN>" _
        & "<BR><SPAN LANG=""en-au""><FONT COLOR=""#000000"" FACE=""Arial"">Parmalat, Australia </FONT></SPAN>" _
        & "<BR><SPAN LANG=""en-au""><FONT COLOR=""#000000"" FACE=""Arial"">PH (07) 38400170</FONT></SPAN>" _
        & "<BR><SPAN LANG=""en-au""><U></U></SPAN><A HREF=""mailto:HelpDesk@parmalat.com.au""><SPAN LANG=""en-au""><U><FONT COLOR=""#3333FF"" FACE=""Arial"">HelpDesk@parmalat.com.au</FONT></U><U></U></SPAN></A><SPAN LANG=""en-au""><U></U></SPAN>" _
        & "</P><BR>" _
        & "<B>------------------------  Original Message Follows  --------------------------</B><BR>" _
        & "<P><I><FONT COLOR=""#666666"" FACE=""Arial"" SIZE=""2"">" & MsgBody & "</FONT></I></P>"

With MsgReply
    .SentOnBehalfOfName = FromAddr
    .HTMLBody = strSig
    .Display
End With
End Sub
Sub Export_NTForm()
Dim Process_ID As Long
Dim Process_Handle As Long
Dim NewMsg
Dim SaveDir
Dim EmailTo
Dim sh As Object
Dim a
Dim CSVFile
Dim arrvalues(1, 5)
Dim GetFileCOntent
Dim i As Integer
Dim Password As String
Dim NoOffice As String
Dim EmailToUser As String
Dim UserName As String
Dim FirstName As String
Dim lastname As String
Dim MsgReply As Object
Dim FromAddr As String
Dim Strsig As String
Dim RunAs As String
Dim Pass As String
CSVFile = FreeFile
SaveDir = "M:\temp\New_NT_Form.txt"
EmailTo = "M:\Temp\Email.csv"

Set NewMsg = ActiveExplorer.Selection.Item(1)
If ActiveExplorer.Selection.Count <> 1 Then
    MsgBox ("Please Select One Message only to Export")
    Exit Sub
End If

If InStr(NewMsg.Subject, "NT Application Form (New User) Request generated by") = vbFalse Then
    MsgBox ("The Selected email is not an NT form. Please select an NT form to continue")
    Exit Sub
End If


NewMsg.SaveAs SaveDir, olTXT

Set sh = CreateObject("WScript.Shell")
'RunAs = InputBox("Please Enter your ""_adm"" account username (Including QUF\): ", "Enter Details")
'Pass = InputBox("Please Enter your Password", "Enter Details")
'a = sh.Run("C:\windows\psexec.exe \\VMupdates2 -u ""quf\bennettw_adm"" -p ""(174$@mbo)""" _
            & " C:\windows\syswow64\windowspowershell\v1.0\powershell " _
            & "-File ""\\fs3\bennettw$\My Documents\Scripts\Add New User-Email.ps1"" -RunAs ""Bennettw""", _
             vbNormalFocus, vbTrue)
i = 0
Open EmailTo For Input As CSVFile
Do
Input #CSVFile, Password, lastname, NoOffice, EmailToUser, UserName, FirstName
arrvalues(i, 0) = Password
arrvalues(i, 1) = lastname
arrvalues(i, 2) = NoOffice
arrvalues(i, 3) = EmailToUser
arrvalues(i, 4) = UserName
arrvalues(i, 5) = FirstName
i = i + 1
Loop Until i = 2

MsgBox ("Password: " & Password & vbCrLf _
        & "NoOffice: " & NoOffice & vbCrLf _
        & "Email To: " & EmailToUser & vbCrLf _
        & "UserName: " & UserName & vbCrLf _
        & "FirstName: " & FirstName & vbCrLf _
        & "LastName: " & lastname)

Set MsgReply = NewMsg.ReplyAll

FromAddr = "HelpDesk@parmalat.com.au"
Strsig = "<P><FONT COLOR=""#000000"" FACE=""Arial"">Hi " & UserName & ",<BR></P>" _
        & "<P><FONT COLOR=""#000000"" FACE=""Arial""><BR></P>" _
        & "<P><FONT COLOR=""#000000"" FACE=""Arial"">Regards.</FONT>" _
        & "</P>" _
        & "<SPAN LANG=""en-us""><B><FONT COLOR=""#000000"" FACE=""Arial"">Help Desk - IT Client Services</FONT></B></SPAN><SPAN LANG=""en-au"">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </SPAN>" _
        & "<BR><SPAN LANG=""en-au""><FONT COLOR=""#000000"" FACE=""Arial"">Parmalat, Australia </FONT></SPAN>" _
        & "<BR><SPAN LANG=""en-au""><FONT COLOR=""#000000"" FACE=""Arial"">PH (07) 38400170</FONT></SPAN>" _
        & "<BR><SPAN LANG=""en-au""><U></U></SPAN><A HREF=""mailto:HelpDesk@parmalat.com.au""><SPAN LANG=""en-au""><U><FONT COLOR=""#3333FF"" FACE=""Arial"">HelpDesk@parmalat.com.au</FONT></U><U></U></SPAN></A><SPAN LANG=""en-au""><U></U></SPAN>" _
        & "</P><BR>" _
        & "<B>------------------------  Original Message Follows  --------------------------</B><BR>" _
        & "<P><I><FONT COLOR=""#666666"" FACE=""Arial"" SIZE=""2""></FONT></I></P>"

With MsgReply
    .SentOnBehalfOfName = FromAddr
    .HTMLBody = Strsig
    .Display
End With


Reset
'Kill (EmailTo)
End Sub
