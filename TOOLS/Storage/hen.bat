Setlocal enabledelayedexpansion
echo on
chcp 65001 > nul
::Script by Shadow256

IF NOT EXIST templogs (
	mkdir templogs
) else (
	rmdir /s /q templogs
	mkdir templogs
)
echo Ce script va vous permettre d'installer et d'utiliser le hen pour votre PS3. >con
echo.>con
echo Toutes les consoles sont compatibles, il faut soit se trouver sur l'OFW 4.82 ou sous le firmware spécial 4.84.>con
echo Vous aurez besoin de brancher une clé USB formatée en FAT32 et contenant certains fichiers utiles au hen sur votre console. >con
echo.>con
pause >con
:select_fw
echo.>con
set fw_define=
set /p fw_define=Entrez le firmware de votre console (4.82 ou 4.84, tout autres valeurs terminera le script): >con
IF "%fw_define%"=="4.82" goto:verif_fw_ok
IF "%fw_define%"=="4.84" goto:verif_fw_ok
goto:endscript
:verif_fw_ok
IF "%fw_define%"=="4.84" (
	echo Attention, pour utiliser cette fonctionnalité sous ce firmware vous aurez besoin d'installer un firmware 4.84 spécial.>con
	echo Si ce firmware n'est pas installé sur votre console, veuillez le faire avant tout sous peine de brick de la console.>con
	set /p prepare_484_special_fw=Souhaitez-vous télécharger et copier ce firmware sur une clé USB pour pouvoir l'installer sur votre console ensuite? (O/n^): >con
	IF /i "!prepare_484_special_fw!"=="o" (
		call TOOLS\Storage\functions\prepare_484_special_fw.bat
	) else IF /i "!prepare_484_special_fw!"=="n" (
		echo Attention, vous avez choisi de ne pas préparer le firmware spécial 4.84 se qui signifie que vous l'avez déjà installé, le script va donc continuer mais vous êtes seul responsable de se que vous faites.>con
		pause >con
	) else (
		echo Choix non autorisé.>con
		goto:verif_fw_ok
	)
)

:define_action_choice
echo Que souhaitez-vous faire?
echo 1: Lancer l'installation du hen?
echo 2: Monter la partition flash?
echo 0: Changer de firmware (firmware %fw_define% actuellement sélectionné)?
echo Tout autre choix: Revenir au menu principal.
echo.
set action_choice=
set /p action_choice=Faites votre choix: 
IF "%action_choice%"=="1" (
	call :prepare_USB_files
	goto:define_action_choice
)
IF "%action_choice%"=="2" (
	call :launch_server "hen_flash_mount"
	goto:define_action_choice
)
IF "%action_choice%"=="0" goto:select_fw
goto:endscript

:launch_server
:test_network
ipconfig | TOOLS\gnuwin32\bin\grep.exe "Adresse IPv4" | TOOLS\gnuwin32\bin\cut.exe -d : -f 2 > templogs\IPs_list.txt
TOOLS\gnuwin32\bin\grep.exe -c "" <templogs\IPs_list.txt >templogs\count.txt
set /p tempcount=<templogs\count.txt
del /q templogs\count.txt
IF "%tempcount%"=="" (
	echo Aucune adresse IP V4 trouvée. Veuillez vous assuré d'être connecté à votre réseau avant de continuer. >con
	pause >con
	goto:test_network
)
echo.>con
echo Voici quelques conseils pour faire fonctionner l'exploit au mieux, dans un certain ordre d'importance: >con
echo - Brancher la clé USB sur le port le plus proche du lecteur (recommandé). >con
echo - Régler la page d'accueil du navigateur de la console sur une page vierge (recommandé). >con
echo - Enregistrer l'adresse du site dans un favoris pour plus de simplicité et pour éviter le bug de saisie d'adresse. >con
echo - Si le Wifi est utilisé, veillez à ne pas avoir un signale trop faible (PC et console). >con
echo - Si la console freeze, utiliser une autre clé USB. >con
echo - Nettoyer le cache et les cookies du navigateur de la console. >con
echo - Reconstruire le système de fichier via le Recovery de la console (si vraiment ça ne fonctionne pas) (ne supprime pas de données). >con
echo - Réinitialiser complètement la console via le Recovery (si vraiment rien ne fonctionne après beaucoup d'essais) (supprime toutes les données). >con
echo Note: Pour lancer le mode Recovery, il faut que la console soit éteinte puis: >con
echo maintenir le bouton Power. La console va faire un bip, puis un second, puis un troisième et va s'éteindre. >con
echo Relacher le bouton Power puis le maintenir de nouveau. La console va faire un bip, puis un second et enfin deux bips consécutifs. C'est à ce moment là qu'il faudra relacher le bouton Power. >con
echo.>con
echo.>con
echo Liste des adresse IP possibles: >con
:list_IPs
IF "%tempcount%"=="0" goto:skip_list_IPs
TOOLS\gnuwin32\bin\tail.exe -%tempcount% <templogs\IPs_list.txt | TOOLS\gnuwin32\bin\head.exe -1 >con
set /a tempcount-=1
goto:list_IPs
:skip_list_IPs
echo.>con
echo Vous devrez entrer une des adresses IP ci-dessus dans la barre d'adresse du navigateur internet de votre console pour lancer l'exploit. >con
echo N'oubliez pas d'autoriser également l'application si cela est demandée par votre pare-feu. >con
echo.>con
echo Pour terminer l'exécution du serveur, vous devrez appuyer sur "ctrl+c" ou fermer sa fenêtre. >con
pause  >con
IF EXIST TOOLS\web_exploits\htdocs del /q TOOLS\web_exploits\htdocs
IF EXIST TOOLS\web_exploits\htdocs\*.* rmdir /s /q TOOLS\web_exploits\htdocs
mkdir TOOLS\web_exploits\htdocs
call :%~1
start tools\web_exploits\caddy.exe -agree -http-port 80 -https-port 443 -port 80 -root tools\web_exploits\htdocs
exit /b

:hen_install
IF "%fw_define%"=="4.82" (
	copy /v TOOLS\web_exploits\4.82\hen\ps3xploit_v301.js TOOLS\web_exploits\htdocs\ps3xploit_v301.js
	copy /v TOOLS\web_exploits\4.82\hen\han_installer.html TOOLS\web_exploits\htdocs\index.html
) else IF "%fw_define%"=="4.84" (
	copy /v TOOLS\web_exploits\4.84\hen\ps3xploit_v301.js TOOLS\web_exploits\htdocs\ps3xploit_v301.js
	copy /v TOOLS\web_exploits\4.84\hen\han_installer.html TOOLS\web_exploits\htdocs\index.html
)
exit /b

:hen_flash_mount
IF "%fw_define%"=="4.82" (
	copy /v TOOLS\web_exploits\4.82\hen\ps3xploit_v301.js TOOLS\web_exploits\htdocs\ps3xploit_v301.js
	copy /v TOOLS\web_exploits\4.82\hen\han_flash_mount.html TOOLS\web_exploits\htdocs\index.html
) else IF "%fw_define%"=="4.84" (
	copy /v TOOLS\web_exploits\4.84\hen\ps3xploit_v301.js TOOLS\web_exploits\htdocs\ps3xploit_v301.js
	copy /v TOOLS\web_exploits\4.84\hen\han_flash_mount.html TOOLS\web_exploits\htdocs\index.html
)
exit /b

:prepare_USB_files
echo.>con
set /p skip_prepare_usb=Souhaitez-vous seulement lancer le serveur web sans copier les fichiers nécessaires au hen sur une clé USB? (O/n): >con
IF NOT "%skip_prepare_usb%"=="" set skip_prepare_usb=%skip_prepare_usb:~0,1%
IF /i "%skip_prepare_usb%"=="o" goto:skip_prepare_usb
:define_volume_letter
%windir%\system32\wscript //Nologo //B TOOLS\Storage\functions\list_volumes.vbs
TOOLS\gnuwin32\bin\grep.exe -c "" <templogs\volumes_list.txt >templogs\count.txt
set /p tempcount=<templogs\count.txt
del /q templogs\count.txt
IF "%tempcount%"=="" (
	echo Aucun disque compatible trouvé. Veuillez insérer votre clé USB puis relancez le script. >con
	echo Le script va maintenant s'arrêté. >con
	pause
	exit /b
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
set volume_letter=
set /p volume_letter=Entrez la lettre du volume de la clé USB que vous souhaitez utiliser ou entrez 0 pour revenir au menu précédent: >con
call TOOLS\Storage\functions\strlen.bat nb "%volume_letter%"
IF %nb% EQU 0 (
	echo La lettre de lecteur ne peut être vide. Réessayez. >con
	goto:define_volume_letter
)
set volume_letter=%volume_letter:~0,1%
IF "%volume_letter%"=="0" exit /b
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
	goto:prepare_usb
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
		exit /b
	) else (
		goto:prepare_usb
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
		exit /b
	)
	goto:prepare_usb
)
IF "%ERRORLEVEL%"=="32" (
	echo Le formatage n'a pas été effectué. >con
	echo Essayez d'éjecter proprement votre clé USB, réinsérez-là et relancez immédiatement ce script. >con
	echo Vous pouvez également essayer de fermer toutes les fenêtres de l'explorateur Windows avant le formatage, parfois cela règle le bug. >con
	echo.>con
	echo Le script va maintenant s'arrêter. >con
	pause
	exit /b
)
IF "%ERRORLEVEL%"=="2" (
	echo Le volume à formater n'existe pas. Vous avez peut-être débranché ou éjecté la clé USB durant ce script.>con
	echo.>con
	echo Le script va maintenant s'arrêter. >con
	pause
	exit /b
)
IF NOT "%ERRORLEVEL%"=="1" (
	IF NOT "%ERRORLEVEL%"=="0" (
		echo Une erreur inconue s'est produite pendant le formatage. >con
		echo.>con
		echo Le script va maintenant s'arrêter. >con
		pause
		exit /b
	)
)
IF "%ERRORLEVEL%"=="1" (
	echo Le formatage a été annulé par l'utilisateur. >con
	echo.>con
		echo Le script va maintenant s'arrêter. >con
		pause
		exit /b
)
IF "%ERRORLEVEL%"=="0" (
	echo Formatage effectué avec succès. >con
	%windir%\system32\wscript //Nologo //B TOOLS\Storage\functions\list_volumes.vbs
TOOLS\gnuwin32\bin\grep.exe -c "" <templogs\volumes_list.txt >templogs\count.txt
)
echo.>con
:prepare_usb
IF "%fw_define%"=="4.82" (
	%windir%\System32\Robocopy.exe TOOLS\usb_ps3\hack_4.82\hen %volume_letter%:\ /e
) else IF "%fw_define%"=="4.84" (
	%windir%\System32\Robocopy.exe TOOLS\usb_ps3\hack_4.84\hen %volume_letter%:\ /e
)
:skip_prepare_usb
call :launch_server "hen_install"
exit /b

:endscript
pause >con
rmdir /s /q templogs
rmdir /s /q TOOLS\web_exploits\htdocs
endlocal