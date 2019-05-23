setlocal
::Script by Shadow256
chcp 65001 >nul
IF NOT EXIST templogs (
	mkdir templogs
) else (
	rmdir /s /q templogs
	mkdir templogs
)
echo Ce script va vous permettre de supprimer les fichiers copiés durant le script de préparation du hack 4.82/4.84 sur votre clé USB.
echo Les fichiers supprimés seront le fichier de mise à jour du firmware, le pkg du QA Togle ainsi que le fichier "flash_482.hex" et "flash_484.hex.hex".
echo Aucun autre fichier ne sera touché pendant ce script.
pause
echo.
:define_volume_letter
%windir%\system32\wscript //Nologo //B TOOLS\Storage\functions\list_volumes.vbs
TOOLS\gnuwin32\bin\grep.exe -c "" <templogs\volumes_list.txt >templogs\count.txt
set /p tempcount=<templogs\count.txt
del /q templogs\count.txt
IF "%tempcount%"=="" (
	echo Aucun disque compatible trouvé. Veuillez insérer votre clé USB puis relancez le script. >con
	echo Le script va maintenant s'arrêté. >con
	goto:endscript
)
echo. >con
echo Liste des disques: >con
:list_volumes
IF "%tempcount%"=="0" goto:set_volume_letter
TOOLS\gnuwin32\bin\tail.exe -%tempcount% <templogs\volumes_list.txt | TOOLS\gnuwin32\bin\head.exe -1 >con
set /a tempcount-=1
goto:list_volumes
:set_volume_letter
echo.>con
echo.>con
set /p volume_letter=Entrez la lettre du volume de la clé USB que vous souhaitez utiliser ou 0 pour quitter: >con
call TOOLS\Storage\functions\strlen.bat nb "%volume_letter%"
IF %nb% EQU 0 (
	echo La lettre de lecteur ne peut être vide. Réessayez. >con
	goto:define_volume_letter
)
set volume_letter=%volume_letter:~0,1%
IF "%volume_letter%"=="0" (
	echo Suppression annulée.
	goto:endscript
)
set nb=1
CALL TOOLS\Storage\functions\CONV_VAR_to_MAJ.bat volume_letter
set i=0
:check_chars_volume_letter
IF %i% LSS %nb% (
	set check_chars_volume_letter=0
	FOR %%z in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
		IF "!volume_letter:~%i%,1!"=="%%z" (
			set /a i+=1
			set check_chars_volume_letter=1
			goto:check_chars_volume_letter
		)
	)
	IF "!check_chars_volume_letter!"=="0" (
		echo Un caractère non autorisé a été saisie dans la lettre du lecteur. Recommencez. >con
		set volume_letter=
		goto:define_volume_letter
	)
)
IF NOT EXIST "%volume_letter%:\" (
	echo Ce volume n'existe pas. Recommencez. >con
	set volume_letter=
	goto:define_volume_letter
)
TOOLS\gnuwin32\bin\grep.exe "Lettre volume=%volume_letter%" <templogs\volumes_list.txt | TOOLS\gnuwin32\bin\cut.exe -d ; -f 1 | TOOLS\gnuwin32\bin\cut.exe -d = -f 2 > templogs\tempvar.txt
set /p temp_volume_letter=<templogs\tempvar.txt
IF NOT "%volume_letter%"=="%temp_volume_letter%" (
	echo Cette lettre de volume n'est pas dans la liste. Recommencez. >con
	goto:define_volume_letter
)
TOOLS\gnuwin32\bin\grep.exe "Lettre volume=%volume_letter%" <templogs\volumes_list.txt | TOOLS\gnuwin32\bin\cut.exe -d ; -f 3 | TOOLS\gnuwin32\bin\cut.exe -d = -f 2 > templogs\tempvar.txt
set /p temp_volume_format=<templogs\tempvar.txt
IF NOT "%temp_volume_format%"=="FAT32" (
	echo Le support que vous avez choisi n'est pas formaté en FAT32. Sélectionnez un autre volume. >con
	set temp_volume_format=
	set temp_volume_letter=
	set volume_letter=
	goto:define_volume_letter
)
IF EXIST %volume_letter%:\PS3\UPDATE\PS3UPDAT.PUP del /q %volume_letter%:\PS3\UPDATE\PS3UPDAT.PUP
IF EXIST %volume_letter%:\flash_482.hex del /q %volume_letter%:\flash_482.hex
IF EXIST %volume_letter%:\flash_484.hex del /q %volume_letter%:\flash_484.hex
IF EXIST "%volume_letter%:\Habib-QA_Toggle-4.21+.pkg" del /q "%volume_letter%:\Habib-QA_Toggle-4.21+.pkg"
IF EXIST log.txt del /q log.txt
echo Suppression des fichiers effectuée.
:endscript
pause
rmdir /s /q templogs
endlocal