::Script by Shadow256
chcp 65001 >nul
IF EXIST TOOLS\usb_ps3\hack_4.82\CEXFERROX482COBRA755_101.PUP del /q TOOLS\usb_ps3\hack_4.82\CEXFERROX482COBRA755_101.PUP
IF EXIST TOOLS\usb_ps3\hack_4.82\CEXFERROX482COBRA755_noBD_100.PUP del /q TOOLS\usb_ps3\hack_4.82\CEXFERROX482COBRA755_noBD_100.PUP
IF EXIST TOOLS\usb_ps3\hack_4.82\OFW_4.82.PUP del /q TOOLS\usb_ps3\hack_4.82\OFW_4.82.PUP
IF EXIST TOOLS\usb_ps3\hack_4.84\special_OFW_4.84.PUP del /q TOOLS\usb_ps3\hack_4.84\special_OFW_4.84.PUP
IF EXIST templogs rmdir /s /q templogs
IF EXIST log.txt del /q log.txt
echo Remise à zéro du script effectuée.
pause