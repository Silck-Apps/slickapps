VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "ThisWorkbook"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True
Option Explicit
Sub Send_Service_Request()
On Error Resume Next
' ***************** These hold the values from the cells of the spreadsheet ***************

Dim strXLDepot            ' Depot Column - This is manipulated to get the address
Dim strLocated          ' Located COlumn - This is the department.....
Dim strContactName      ' Site Contact Name
Dim strContactPhone     ' Site Contact Phone Number
Dim strQName            ' Printer Q Name
Dim strPSerial          ' Printer Serial Number
Dim strPModel           ' Printer Model Number
Dim strCompanyName      ' Set to Either Parmalat Food Products or Parmalat P/L
Dim rngAddress          ' Search Range for Address sheet
Dim strAddress1         ' Site Address1 Line
Dim strStreet           ' Site Street
Dim strSuburb           ' Site Suburb
Dim strPostCode         ' Site Postcode
Dim strJobNumber        ' Help Desk Job number from SAP
Dim strFault            ' Fault Description
Dim objApp, msg, olMailItem         ' Outlook Application object
Dim strSBPrefix         ' South Brisbane Phone Prefix
' South Brisbane PABX Speed dial numbers
Dim spd4001, spd4003, spd4097, spd4112, spd4180, spd4333, spd4449, spd4599, spd4900, spd4985
Dim strEmailBody        ' Used to Define the Email Body Before creating the message
Dim olFromAddr, olToAddr, olSubject ' Outlook From, To and Subject fields
Dim strMsgInvalid, strMsgNotHP, objXLcolSites, strMaint, strMsgNotTP, strMsgImt

' ************** These are the Row and Column Letter references x is for row and y for column  **************************

Dim xrow, xrowAddress            ' Current Active Row Selected by the User
Dim yDepot, yLocation, yContact, yQName, yPSerial, yPModel, yPhone, yAddress1, yStreet, ySuburb, yPostcode, yMaint
yDepot = "E"
yLocation = "F"
yContact = "K"
yQName = "B"
yPSerial = "H"
yPModel = "G"
yPhone = "L"
yAddress1 = "B"
yStreet = "C"
ySuburb = "D"
yPostcode = "E"
yMaint = "O"
strCompanyName = "Parmalat Australia P/L"       ' This gets changed to PFP further down the page if required
Set objApp = CreateObject("Outlook.Application") ' Outlook application Object
Set msg = objApp.CreateItem(olMailItem)                    ' Outlook New Message
strSBPrefix = "(07) 38400"                      ' Sets the phone prefix for South Brisbane
olFromAddr = "HelpDesk@parmalat.com.au"                         ' Sets the From Address in outlook
olToAddr = "customerservice@techprecision.com.au"              ' Sets the To address in outlook
olSubject = "Service required parmalat job number "        ' Sets the subject of the outlook message.
strMsgInvalid = "You Must Select a Valid Row." & vbCrLf & vbCrLf & "To Continue, Select a Printer"
strMsgNotHP = "Incorrect Printer Model!!" & vbCrLf & "Tech Precision Only Service HP Printers!"
strMsgNotTP = "The Printer Selected is not serviced by Tech Precision" & vbCrLf & "Please make another selection."
strMsgImt = "This Printer is servicedd by Imagetec!" & vbCrLf & "The user should call Imagetec" & vbCrLf & "Direct to place this service..."
' **************** Set South Brisbane Speed Dial numbers ***********

spd4001 = "(08) 8980 2222"
spd4003 = "(07) 5442 0777"
spd4097 = "(07) 4041 1277"
spd4112 = "(07) 3865 1476"
spd4180 = "(07) 4721 3000"
spd4333 = "(03) 9215 6111"
spd4449 = "(07) 4931 7600"
spd4599 = "1800 034 250"
spd4900 = "0408 719 426"
spd4985 = "1800 100 562"

' *************** Populate Variables from Spreadsheet ****************************

xrow = ActiveCell.Row
strXLDepot = Cells(xrow, yDepot).Value
strLocated = Cells(xrow, yLocation).Value
strQName = Cells(xrow, yQName).Value
strPSerial = Cells(xrow, yPSerial).Value
strPModel = Cells(xrow, yPModel).Value
strContactName = Cells(xrow, yContact).Value
strContactPhone = Cells(xrow, yPhone).Value
strMaint = Cells(xrow, yMaint).Value

' *************** Check Selection Validity *********************************

If strQName = "" Then
    MsgBox (strMsgInvalid)
    Exit Sub
End If
If InStr(strMaint, "Imagetec") = 1 Then
    MsgBox (strMsgImt)
    Exit Sub
End If
If InStr(strPModel, "HP") = 0 Then
    MsgBox (strMsgNotHP)
    Exit Sub
End If

' ***************** Set Contact Name and Phone Fields ************************

strContactName = InputBox("Please enter the site Contact's name:", "Enter contact name", strContactName)

If StrPtr(strContactName) = 0 Then
    Exit Sub
End If

strContactPhone = InputBox("Please enter the site contact's Phone number (Including area code):", "Enter contact details", strContactPhone)

If StrPtr(strContactPhone) = 0 Then
    Exit Sub
End If

' ************************ Set Company Details if PFP ******************************

If InStr(strXLDepot, "PFP") <> 0 Then
    strCompanyName = "Parmalat Food Products"
End If

' **************************** Set Phone Prefix for Riverside ************************

If InStr(strXLDepot, "Riverside") <> 0 Then
    strContactPhone = strSBPrefix & strContactPhone
End If

' ***************************** Adjust Speed dial Numbers **************************

Select Case strContactPhone
    Case "4001"
        strContactPhone = spd4001
    Case "4003"
        strContactPhone = spd4003
    Case "4097"
        strContactPhone = spd4097
    Case "4112"
        strContactPhone = spd4112
    Case "4180"
        strContactPhone = spd4180
    Case "4333"
        strContactPhone = spd4333
    Case "4449"
        strContactPhone = spd4449
    Case "4599"
        strContactPhone = spd4599
    Case "4900"
        strContactPhone = spd4900
    Case "4985"
        strContactPhone = spd4985
End Select

' ********************** Set the Row Number for Site Address ******************
objXLcolSites = Worksheets(7).Columns(1)

If InStr(strXLDepot, "SB") <> 0 Then
    strContactPhone = strSBPrefix & strContactPhone                ' Set Phone prefix for South Brisbane
    xrowAddress = Worksheets(7).Columns(1).Find("South Brisbane").Row
Else
Select Case strXLDepot
    Case "Alice Springs"
        xrowAddress = Worksheets(7).Columns(1).Find(strXLDepot).Row
    Case "Bendigo"
        xrowAddress = Worksheets(7).Columns(1).Find(strXLDepot).Row
    Case "Cairns"
        xrowAddress = Worksheets(7).Columns(1).Find(strXLDepot).Row
    Case "Clarence Gardens"
        xrowAddress = Worksheets(7).Columns(1).Find(strXLDepot).Row
    Case "Darwin"
        xrowAddress = Worksheets(7).Columns(1).Find(strXLDepot).Row
    Case "Geebung"
        xrowAddress = Worksheets(7).Columns(1).Find(strXLDepot).Row
    Case "Hamilton"
        xrowAddress = Worksheets(7).Columns(1).Find(strXLDepot).Row
    Case "Horsham"
        xrowAddress = Worksheets(7).Columns(1).Find(strXLDepot).Row
    Case "Katherine"
         xrowAddress = Worksheets(7).Columns(1).Find(strXLDepot).Row
    Case "Kingston"
         xrowAddress = Worksheets(7).Columns(1).Find(strXLDepot).Row
    Case "Kununurra"
         xrowAddress = Worksheets(7).Columns(1).Find(strXLDepot).Row
    Case "Labrador"
         xrowAddress = Worksheets(7).Columns(1).Find(strXLDepot).Row
    Case "Lidcombe - PFP"
         xrowAddress = Worksheets(7).Columns(1).Find(strXLDepot).Row
    Case "Morwell"
         xrowAddress = Worksheets(7).Columns(1).Find(strXLDepot).Row
    Case "Nambour"
         xrowAddress = Worksheets(7).Columns(1).Find(strXLDepot).Row
    Case "Richlands"
         xrowAddress = Worksheets(7).Columns(1).Find(strXLDepot).Row
    Case "Riverside"
         xrowAddress = Worksheets(7).Columns(1).Find(strXLDepot).Row
    Case "Rockhampton"
         xrowAddress = Worksheets(7).Columns(1).Find(strXLDepot).Row
    Case "Rowville"
         xrowAddress = Worksheets(7).Columns(1).Find(strXLDepot).Row
    Case "Townsville"
         xrowAddress = Worksheets(7).Columns(1).Find(strXLDepot).Row
    End Select
End If
' *******************  Populate site address details***************
If xrowAddress <> "" Then
With Worksheets(7)
    strAddress1 = .Cells(xrowAddress, yAddress1).Value
    strStreet = .Cells(xrowAddress, yStreet).Value
    strSuburb = .Cells(xrowAddress, ySuburb).Value
    strPostCode = .Cells(xrowAddress, yPostcode).Value
End With
End If

' ************************** Enter Job Number and Fault Description or exit on cancel *********************

strJobNumber = InputBox("Please enter the Help Desk job number...", "Enter Details")
If StrPtr(strJobNumber) = 0 Then
    Exit Sub
End If
strFault = InputBox("Please add information about the fault for the technician....", "Enter Details")
If StrPtr(strFault) = 0 Then
    Exit Sub
End If

' ********************** Create Email Body Text ************************

strEmailBody = "Hi There," & vbCrLf & vbCrLf & "We would like to log the following service call please:" & vbCrLf & vbCrLf & "Company Name:" & vbCrLf _
        & strCompanyName & vbCrLf & vbCrLf & "Department:" & vbCrLf & strLocated & vbCrLf & vbCrLf _
        & "Address:" & vbCrLf & strAddress1 & vbCrLf & strStreet & vbCrLf & strSuburb & vbCrLf & strPostCode & vbCrLf & vbCrLf _
        & "Site Contact:" & vbCrLf & strContactName & vbCrLf & vbCrLf & "Phone Number:" & vbCrLf & strContactPhone & vbCrLf & vbCrLf _
        & "Printer Details" & vbCrLf & vbCrLf & "Parmalat Queue Name:" & vbCrLf & strQName & vbCrLf & "Printer Model:" & vbCrLf & strPModel & vbCrLf & "Printer Serial Number:" & vbCrLf & strPSerial & vbCrLf & vbCrLf _
        & "Job Details" & vbCrLf & "Parmalat Help Desk Reference Number:" & vbCrLf & strJobNumber & vbCrLf & vbCrLf & "Fault Description:" & vbCrLf & strFault & vbCrLf & vbCrLf & "All job numbers and quotes to be emailed to helpdesk@parmalat.com.au" & vbCrLf & vbCrLf _
        & "Regards," & vbCrLf & vbCrLf & "Help Desk - IT Client Services" & vbCrLf & "Parmalat Australia" & vbCrLf & "Ph: (07) 38400 170" & vbCrLf & "HelpDesk@parmalat.com.au"

MsgBox ("Thanks" & vbCrLf & "Please review the email before pressing send!")

' ********************************* Create and send Email **********************************

msg.SentOnBehalfofName = olFromAddr
msg.to = olToAddr
msg.Subject = olSubject & strJobNumber
msg.Body = strEmailBody
msg.Display
End Sub


