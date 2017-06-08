net use x: \\crsqln1\CiscoPhoneUpload GiveMeTheD@t@ /USER:crsqln1\vmccmdc01_user
del C:\scripts\sap-hr-to-ad-update\data\CiscoPhoneData.txt.3
ren C:\scripts\sap-hr-to-ad-update\data\CiscoPhoneData.txt.2 CiscoPhoneData.txt.3
ren C:\scripts\sap-hr-to-ad-update\data\CiscoPhoneData.txt.1 CiscoPhoneData.txt.2
ren C:\scripts\sap-hr-to-ad-update\data\CiscoPhoneData.txt CiscoPhoneData.txt.1
copy x:\CiscoPhoneData.txt C:\scripts\sap-hr-to-ad-update\data\CiscoPhoneData.txt
copy /a C:\scripts\sap-hr-to-ad-update\data\csv-headers.txt /a + C:\scripts\sap-hr-to-ad-update\data\CiscoPhoneData.txt /a C:\scripts\sap-hr-to-ad-update\data\sapphonerecords.csv /a
net use x: /d

del C:\scripts\sap-hr-to-ad-update\data\import-results.txt.3
ren C:\scripts\sap-hr-to-ad-update\data\import-results.txt.2 import-results.txt.3
ren C:\scripts\sap-hr-to-ad-update\data\import-results.txt.1 import-results.txt.2
ren C:\scripts\sap-hr-to-ad-update\data\import-results.txt import-results.txt.1
powershell.exe c:\scripts\sap-hr-to-ad-update\ad-record-update.ps1 > C:\scripts\sap-hr-to-ad-update\data\import-results.txt