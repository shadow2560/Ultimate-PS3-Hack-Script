setlocal
::script by shadow256
chcp 65001 >nul
set md5_try=0
echo.>con
:define_volume_letter
%windir%\system32\wscript //Nologo //B TOOLS\Storage\functions\list_volumes.vbs
TOOLS\gnuwin32\bin\grep.exe -c "" <templogs\volumes_list.txt >templogs\count.txt
set /p tempcount=<templogs\count.txt
del /q templogs\count.txt
IF "%tempcount%"=="" (
	echo Aucun disque compatible trouvé. Veuillez insérer votre clé USB puis relancez le script. >con
	echo Le script va maintenant s'arrêté. >con
	pause
	exit
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
set /p volume_letter=Entrez la lettre du volume de la clé USB que vous souhaitez utiliser: >con
call TOOLS\Storage\functions\strlen.bat nb "%volume_letter%"
IF %nb% EQU 0 (
	echo La lettre de lecteur ne peut être vide. Réessayez. >con
	goto:define_volume_letter
)
set volume_letter=%volume_letter:~0,1%
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
set /p format_choice=Souhaitez-vous formaté la clé USB (volume "%volume_letter%")? (O/n): >con
IF NOT "%format_choice%"=="" set format_choice=%format_choice:~0,1%
IF /I NOT "%format_choice%"=="o" (
	TOOLS\gnuwin32\bin\grep.exe "Lettre volume=%volume_letter%" <templogs\volumes_list.txt | TOOLS\gnuwin32\bin\cut.exe -d ; -f 3 | TOOLS\gnuwin32\bin\cut.exe -d = -f 2 > templogs\tempvar.txt
	set /p temp_volume_format=<templogs\tempvar.txt
)
IF /I NOT "%format_choice%"=="o" (
	IF NOT "%temp_volume_format%"=="FAT32" (
		echo Le support que vous avez choisi n'est pas formaté en FAT32. Sélectionnez un autre volume ou choisissez de formater celui-ci. >con
		set temp_volume_format=
		set temp_volume_letter=
		set volume_letter=
		goto:define_volume_letter
	)
)
:define_format_clusters
IF /i "%format_choice%"=="o" (
	echo Définissez le nombre de clusters que vous souhaitez utiliser: >con
	echo.>con
	echo 1: 32K (recommandé^) >con
	echo 2: 64K >con
	echo 0: Annule l'oppération de formatage >con
	echo.>con
	set /p format_clusters=Quelle taille de clusters voulez-vous utiliser? (1/2/0^): >con
) else (
	goto:first_verif_fw
)
call TOOLS\Storage\functions\strlen.bat nb "%format_clusters%"
IF %nb% EQU 0 (
	echo Le nombre de clusters ne peut être vide. Réessayez. >con
	goto:define_format_clusters
)
set format_clusters=%format_clusters:~0,1%
set i=0
:check_chars_format_clusters
IF %i% LSS %nb% (
	set check_chars_format_clusters=0
	FOR %%z in (0 1 2) do (
		IF "!format_clusters:~%i%,1!"=="%%z" (
			set /a i+=1
			set check_chars_format_clusters=1
			goto:check_chars_format_clusters
		)
	)
	IF "!check_chars_format_clusters!"=="0" (
		echo Un caractère non autorisé a été saisie dans le nombre de clusters. Recommencez. >con
		set format_clusters=
		goto:define_format_clusters
	)
)
:format_conditions
IF "%format_clusters%"=="0" (
	IF NOT "%temp_volume_format%"=="FAT32" (
		echo Vous ne devez pas annuler le formatage pour un support non formaté en FAT32.
		echo Pour des raisons de sécurité, le script va s'arrêter.
		pause
		exit
	) else (
		goto:first_verif_fw
	)
)
IF "%format_clusters%"=="1" TOOLS\fat32format\fat32format.exe -q -c64 %volume_letter%
IF "%format_clusters%"=="2" TOOLS\fat32format\fat32format.exe -q -c128 %volume_letter%
echo.>con
IF "%ERRORLEVEL%"=="5" (
	echo La demande d'élévation n'a pas été acceptée, le formatage est annulé. >con
	::echo.>con
	IF NOT "%temp_volume_format%"=="FAT32" (
		echo Le support n'est donc pas formaté en FAT32.
		echo Pour des raisons de sécurité, le script va s'arrêter.
		pause
		exit
	)
	goto:first_verif_fw
)
IF "%ERRORLEVEL%"=="32" (
	echo Le formatage n'a pas été effectué. >con
	echo Essayez d'éjecter proprement votre clé USB, réinsérez-là et relancez immédiatement ce script. >con
	echo Vous pouvez également essayer de fermer toutes les fenêtres de l'explorateur Windows avant le formatage, parfois cela règle le bug. >con
	echo.>con
	echo Le script va maintenant s'arrêter. >con
	pause
	exit
)
IF "%ERRORLEVEL%"=="2" (
	echo Le volume à formater n'existe pas. Vous avez peut-être débranché ou éjecté la clé USB durant ce script.>con
	echo.>con
	echo Le script va maintenant s'arrêter. >con
	pause
	exit
)
IF NOT "%ERRORLEVEL%"=="1" (
	IF NOT "%ERRORLEVEL%"=="0" (
		echo Une erreur inconue s'est produite pendant le formatage. >con
		echo.>con
		echo Le script va maintenant s'arrêter. >con
		pause
		exit
	)
)
IF "%ERRORLEVEL%"=="1" (
	echo Le formatage a été annulé par l'utilisateur. >con
	echo.>con
		echo Le script va maintenant s'arrêter. >con
		pause
		exit
)
IF "%ERRORLEVEL%"=="0" (
	echo Formatage effectué avec succès. >con
	%windir%\system32\wscript //Nologo //B TOOLS\Storage\functions\list_volumes.vbs
TOOLS\gnuwin32\bin\grep.exe -c "" <templogs\volumes_list.txt >templogs\count.txt
)
echo.>con
:first_verif_fw
IF EXIST TOOLS\usb_ps3\hack_4.84\special_OFW_4.84.PUP (
	TOOLS\gnuwin32\bin\md5sum.exe TOOLS\usb_ps3\hack_4.84\special_OFW_4.84.PUP | TOOLS\gnuwin32\bin\cut.exe -d " " -f 1 | TOOLS\gnuwin32\bin\cut.exe -d ^\ -f 2 >templogs\tempvar.txt
	set /p md5_verif=<templogs\tempvar.txt
)
IF EXIST TOOLS\usb_ps3\hack_4.84\special_OFW_4.84.PUP (
	IF NOT "%md5_verif%"=="4247362b54fadd2e4d7c09007f720803" (
		del /q TOOLS\usb_ps3\hack_4.84\special_OFW_4.84.PUP
		goto:dl_firmware
	) else (
	goto:copy_firmware
	)
)
:dl_firmware
IF NOT EXIST TOOLS\usb_ps3\hack_4.84\special_OFW_4.84.PUP (
	echo Téléchargement du firmware spécial 4.84...>con
	TOOLS\megatools\megadl.exe "https://mega.nz/#^!zQQwXIIB^!8KKPcY34Qjh-l9ZkYLax68FfuWM9D1VGFl26mD_NKk8" --path=templogs\temp.7z>con
	TOOLS\gnuwin32\bin\md5sum.exe templogs\temp.7z | TOOLS\gnuwin32\bin\cut.exe -d " " -f 1 | TOOLS\gnuwin32\bin\cut.exe -d ^\ -f 2 >templogs\tempvar.txt
	set /p md5_verif=<templogs\tempvar.txt
)
IF NOT EXIST TOOLS\usb_ps3\hack_4.84\special_OFW_4.84.PUP (
	IF NOT "%md5_verif%"=="0b07a857090c0b18b4f4bc80428077f8" (
		IF %md5_try% EQU 3 (
			echo Le md5 du firmware ne semble pas être correct. Veuillez vérifier votre connexion internet ainsi que l'espace disponible sur votre disque dur puis relancer le script. >con
			pause >con
			exit
		) else (
			set /a md5_try+=1
			goto:dl_firmware
		)
	)
	set md5_try=0
	echo Téléchargement terminé.>con
	echo Décompression du firmware...>con
	TOOLS\7zip\7za.exe x -y -sccUTF-8 "templogs\temp.7z" -o"templogs" -r
	TOOLS\gnuwin32\bin\md5sum.exe templogs\HFW_4.84.2_PS3UPDAT.PUP | TOOLS\gnuwin32\bin\cut.exe -d " " -f 1 | TOOLS\gnuwin32\bin\cut.exe -d ^\ -f 2 >templogs\tempvar.txt
	set /p md5_verif=<templogs\tempvar.txt
)
IF NOT EXIST TOOLS\usb_ps3\hack_4.84\special_OFW_4.84.PUP (
	IF NOT "%md5_verif%"=="4247362b54fadd2e4d7c09007f720803" (
		IF %md5_try% EQU 3 (
			echo Le md5 du firmware ne semble pas être correct. Veuillez vérifier votre connexion internet ainsi que l'espace disponible sur votre disque dur puis relancer le script. >con
			pause >con
			exit
		) else (
			set /a md5_try+=1
			goto:dl_firmware
		)
	)
	set md5_try=0
	echo Décompression terminée.>con
	move "templogs\HFW_4.84.2_PS3UPDAT.PUP" "TOOLS\usb_ps3\hack_4.84\special_OFW_4.84.PUP"
)
:copy_firmware
echo Copie du firmware...>con
IF NOT EXIST %volume_letter%:\PS3\*.* (
	del /q %volume_letter%:\PS3
	mkdir %volume_letter%:\PS3
)
IF NOT EXIST %volume_letter%:\PS3\UPDATE\*.* (
	del /q %volume_letter%:\PS3\UPDATE
	mkdir %volume_letter%:\PS3\UPDATE
)
IF EXIST %volume_letter%:\PS3\UPDATE\*.* (
	del /q %volume_letter%:\PS3\UPDATE\*.*
)
copy /v "TOOLS\usb_ps3\hack_4.84\special_OFW_4.84.PUP" %volume_letter%:\PS3\UPDATE\PS3UPDAT.PUP
TOOLS\gnuwin32\bin\md5sum.exe %volume_letter%:\PS3\UPDATE\PS3UPDAT.PUP | TOOLS\gnuwin32\bin\cut.exe -d " " -f 1 | TOOLS\gnuwin32\bin\cut.exe -d ^\ -f 2 >templogs\tempvar.txt
set /p md5_verif=<templogs\tempvar.txt
IF NOT "%md5_verif%"=="4247362b54fadd2e4d7c09007f720803" (
	IF %md5_try% EQU 3 (
		echo Le fichier ne semble pas être correctement copié sur la clé USB. >con
		echo Vérifiez l'espace disponible sur votre clé USB. >con
		echo Si vous avez assez d'espace sur votre clé USB, essayez de réinitialiser le script. >con
		echo Le script va maintenant s'arrêter. >con
		goto:endscript
	) else (
		set /a md5_try+=1
		goto:copy_firmware
	)
)
set md5_try=0
echo Copie terminée.>con
echo.>con
echo Préparation du firmware terminée.>con
echo Maintenant, débranchez votre clé USB, branchez-là à votre PS3 sur le port USB le plus proche du lecteur et installer le firmware sur la console (mode recovery conseillé).>con
echo Une fois cela fait, vous pouvez continuer le script en appuyant sur une touche.>con
pause >con
endlocal