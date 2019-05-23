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
set md5_try=0
echo Bienvenue dans ce script permettant de hacker votre PS3. >con
echo.>con
echo Ce script va vous permettre de réaliser, étape par étape, le hack de votre console. >con
echo.>con
echo Je rappel que pour les modèles CECH-25xxx (surtout celles avec un "date code" 1A ou 1B), il vaut mieux vérifier avec MIN_Ver_CHK que le firmware minimum ne soit pas suppérieur à 3.56. Si la version minimum est suppérieur à 3.56, votre console n'est pas compatible avec le hack. >con
echo Je rappel que les modèles CECH-3xxxx et CECH-4xxxx ne sont pas compatibles avec ce hack. >con
echo ATTENTION: Effectuer ce hack sur une consoles non compatible provoquera un brick de celle-ci. >con
echo ATTENTION: Effectuer ce hack sur une console qui n'est pas sur le firmware officiel 4.82 ou sur le firmware spécial 4.84 provoquera un brick de celle-ci. >con
echo ATTENTION: Effectuer ce hack sur une console en CFW provoquera un brick de celle-ci. >con
echo Note: Pour ceux n'étant pas sure de la compatibilité de leur console, vous pouvez aller jusqu'à l'étape de vérification de MIN_Ver_CHK, cette vérification est sans risque. >con
echo.>con
echo ATTENTION: Si vous décidez de formater votre Clé USB, toutes les données de celle-ci seront perdues. Sauvegardez les données importante avant de formater. >con
echo ATTENTION: Choisissez bien la lettre du volume qui correspond à votre Clé USB car aucune vérification ne pourra être faites à ce niveau là. >con
echo.>con
echo Je ne pourrais être tenu pour responsable en cas de dommage lié à l'utilisation de ce script ou des outils qu'il contient. >con
pause >con
:select_fw
echo.>con
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
echo.>con
echo Vous pouvez passer la copie des fichiers "flash_482.hex" ou "flash_482.hex", du QA Togle ainsi que les diverses vérifications et préparations de CFW sur votre clé USB si vous avez déjà préparé celle-ci et que vous êtes certains de la compatibilité de votre console/clé USB avec le hack 4.82/4.84. >con
echo Si vous n'êtes pas certain de se que vous faites, veuillez ne pas passer la copie des fichiers nécessaires sur une clé USB à la question qui va suivre. >con
set /p skip_prepare_usb=Souhaitez-vous seulement lancer le serveur web sans copier les fichiers nécessaires au hack sur une clé USB? (O/n): >con
IF NOT "%skip_prepare_usb%"=="" set skip_prepare_usb=%skip_prepare_usb:~0,1%
IF /i "%skip_prepare_usb%"=="o" goto:choose_exploit_type
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
	goto:define__minverchk
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
IF "%format_clusters%"=="0" goto:define__minverchk
IF "%format_clusters%"=="1" TOOLS\fat32format\fat32format.exe -q -c64 %volume_letter%
IF "%format_clusters%"=="2" TOOLS\fat32format\fat32format.exe -q -c128 %volume_letter%
echo.>con
IF "%ERRORLEVEL%"=="5" (
	echo La demande d'élévation n'a pas été acceptée, le formatage est annulé. >con
	::echo.>con
	goto:define__minverchk
)
IF "%ERRORLEVEL%"=="32" (
	echo Le formatage n'a pas été effectué. >con
	echo Essayez d'éjecter proprement votre clé USB, réinsérez-là et relancez immédiatement ce script. >con
	echo Vous pouvez également essayer de fermer toutes les fenêtres de l'explorateur Windows avant le formatage, parfois cela règle le bug. >con
	echo.>con
	echo Le script va maintenant s'arrêter. >con
	goto:endscript
)
IF "%ERRORLEVEL%"=="2" (
	echo Le volume à formater n'existe pas. Vous avez peut-être débranché ou éjecté la clé USB durant ce script.>con
	echo.>con
	echo Le script va maintenant s'arrêter. >con
	goto:endscript
)
IF NOT "%ERRORLEVEL%"=="1" (
	IF NOT "%ERRORLEVEL%"=="0" (
		echo Une erreur inconue s'est produite pendant le formatage. >con
		echo.>con
		echo Le script va maintenant s'arrêter. >con
		goto:endscript
	)
)
IF "%ERRORLEVEL%"=="1" (
	echo Le formatage a été annulé par l'utilisateur. >con
	echo.>con
		echo Le script va maintenant s'arrêter. >con
		goto:endscript
)
IF "%ERRORLEVEL%"=="0" (
	echo Formatage effectué avec succès. >con
	%windir%\system32\wscript //Nologo //B TOOLS\Storage\functions\list_volumes.vbs
TOOLS\gnuwin32\bin\grep.exe -c "" <templogs\volumes_list.txt >templogs\count.txt
)
:define__minverchk
set /p minverchk=Souhaitez-vous préparer la clé pour faire une vérification avec MIN_Ver_CHK? (O/n): >con
IF NOT "%minverchk%"=="" set minverchk=%minverchk:~0,1%
IF /I "%minverchk%"=="o" (
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
	copy /v TOOLS\usb_ps3\MinVerChk.PUP %volume_letter%:\PS3\UPDATE\PS3UPDAT.PUP
	echo.>con
	echo Vous pouvez maintenant éjecter proprement la clé USB de l'ordinateur, la mettre sur votre PS3 (port le plus prêt du lecteur^), allumer la console puis faire la mise à jour via un support de stockage. >con
	echo La console affichera une erreur contenant la version minimum possible de votre firmware. >con
	echo Si la version minimum n'est pas suppérieur à 3.55, la console est compatible avec le hack. >con
	set /p minverchk_result=La console a-t-elle affiché un firmware inférieur au 3.56? (O/n^): >con
) else (
		goto:define_OFW
)
IF /i NOT "%minverchk_result%"=="o" goto:endscript
echo.>con
echo Vous devez maintenant rebrancher votre clé USB à l'ordinateur pour continuer. >con
echo Attendez qu'elle soit reconu avant d'appuyez sur une touche. >con
pause >con
:define_volume_letter2
%windir%\system32\wscript //Nologo //B TOOLS\Storage\functions\list_volumes.vbs
TOOLS\gnuwin32\bin\grep.exe -c "" <templogs\volumes_list.txt >templogs\count.txt
set /p tempcount=<templogs\count.txt
del /q templogs\count.txt
IF "%tempcount%"=="" (
	echo Aucun disque compatible trouvé. Veuillez insérer votre clé USB.>con
	pause >con
	goto:define_volume_letter2
)
echo. >con
echo Liste des disques: >con
:list_volumes2
IF "%tempcount%"=="0" goto:set_volume_letter2
TOOLS\gnuwin32\bin\tail.exe -%tempcount% <templogs\volumes_list.txt | TOOLS\gnuwin32\bin\head.exe -1 >con
set /a tempcount-=1
goto:list_volumes2
:set_volume_letter2
echo.>con
echo.>con
set /p volume_letter=Entrez de nouveau la lettre du volume de la clé USB que vous souhaitez utiliser: >con
call TOOLS\Storage\functions\strlen.bat nb "%volume_letter%"
IF %nb% EQU 0 (
	echo La lettre de lecteur ne peut être vide. Réessayez. >con
	goto:define_volume_letter2
)
set volume_letter=%volume_letter:~0,1%
set nb=1
CALL TOOLS\Storage\functions\CONV_VAR_to_MAJ.bat volume_letter
set i=0
:check_chars_volume_letter2
IF %i% LSS %nb% (
	set check_chars_volume_letter=0
	FOR %%z in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
		IF "!volume_letter:~%i%,1!"=="%%z" (
			set /a i+=1
			set check_chars_volume_letter=1
			goto:check_chars_volume_letter2
		)
	)
	IF "!check_chars_volume_letter!"=="0" (
		echo Un caractère non autorisé a été saisie dans la lettre du lecteur. Recommencez. >con
		set volume_letter=
		goto:define_volume_letter2
	)
)
IF NOT EXIST "%volume_letter%:\" (
	echo Ce volume n'existe pas. Recommencez. >con
	set volume_letter=
	goto:define_volume_letter2
)
TOOLS\gnuwin32\bin\grep.exe "Lettre volume=%volume_letter%" <templogs\volumes_list.txt | TOOLS\gnuwin32\bin\cut.exe -d ; -f 1 | TOOLS\gnuwin32\bin\cut.exe -d = -f 2 > templogs\tempvar.txt
set /p temp_volume_letter=<templogs\tempvar.txt
IF NOT "%volume_letter%"=="%temp_volume_letter%" (
	echo Cette lettre de volume n'est pas dans la liste. Recommencez. >con
	goto:define_volume_letter2
)
TOOLS\gnuwin32\bin\grep.exe "Lettre volume=%volume_letter%" <templogs\volumes_list.txt | TOOLS\gnuwin32\bin\cut.exe -d ; -f 3 | TOOLS\gnuwin32\bin\cut.exe -d = -f 2 > templogs\tempvar.txt
set /p temp_volume_format=<templogs\tempvar.txt
IF NOT "%temp_volume_format%"=="FAT32" (
	echo Le support que vous avez choisi n'est pas formaté en FAT32. Sélectionnez un autre volume. >con
	set temp_volume_format=
	set temp_volume_letter=
	set volume_letter=
	goto:define_volume_letter2
)
:define_OFW
IF NOT "%fw_define%"=="4.82" goto:prepare_usb
set /p OFW=Souhaitez-vous préparer la clé pour installer le firmware officiel 4.82? (O/n): >con
IF NOT "%OFW%"=="" set OFW=%OFW:~0,1%
IF /i NOT "%OFW%"=="o" (
	goto:prepare_usb
) else (
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
	set md5_try=0
	:dl_ofw
	IF NOT EXIST TOOLS\usb_ps3\hack_4.82\OFW_4.82.PUP (
		echo Téléchargement de l'OFW 4.82... >con
		TOOLS\gnuwin32\bin\wget.exe --no-check-certificate -o templogs\wget_dl.txt -S -O templogs\temp.pup http://deu01.ps3.update.playstation.net/update/ps3/image/eu/2017_1113_152d950c365ede4130c53ceb18dcd43b/PS3UPDAT.PUP
		title Shadow256 Ultimate PS3 Hack Script %uphs_version%
		TOOLS\gnuwin32\bin\md5sum.exe templogs\temp.pup | TOOLS\gnuwin32\bin\cut.exe -d " " -f 1 | TOOLS\gnuwin32\bin\cut.exe -d ^\ -f 2 >templogs\tempvar.txt
		set /p md5_verif=<templogs\tempvar.txt
	)
)
IF NOT EXIST TOOLS\usb_ps3\hack_4.82\OFW_4.82.PUP (
	IF NOT "%md5_verif%"=="152d950c365ede4130c53ceb18dcd43b" (
		IF %md5_try% EQU 3 (
			echo Le fichier ne semble pas être correctement téléchargé. >con
			echo Vérifiez votre connexion internet et l'espace disponible sur votre disque dur. >con
			echo Le script va maintenant s'arrêter. >con
			goto:endscript
		) else (
			set /a md5_try+=1
			goto:dl_ofw
		)
	)
	set md5_try=0
	move templogs\temp.pup TOOLS\usb_ps3\hack_4.82\OFW_4.82.PUP
)
:copy_ofw
echo Copie de l'OFW en cours... >con
copy /v TOOLS\usb_ps3\hack_4.82\OFW_4.82.PUP %volume_letter%:\PS3\UPDATE\PS3UPDAT.PUP
TOOLS\gnuwin32\bin\md5sum.exe %volume_letter%:\PS3\UPDATE\PS3UPDAT.PUP | TOOLS\gnuwin32\bin\cut.exe -d " " -f 1 | TOOLS\gnuwin32\bin\cut.exe -d ^\ -f 2 >templogs\tempvar.txt
		set /p md5_verif=<templogs\tempvar.txt
IF NOT "%md5_verif%"=="152d950c365ede4130c53ceb18dcd43b" (
	IF %md5_try% EQU 3 (
		echo Le fichier ne semble pas être correctement copié sur la clé USB. >con
		echo Vérifiez l'espace disponible sur votre clé USB. >con
		echo Si vous avez assez d'espace sur votre clé USB, essayez de réinitialiser le script. >con
		echo Le script va maintenant s'arrêter. >con
		goto:endscript
	) else (
		set /a md5_try+=1
		goto:copy_ofw
	)
)
set md5_try=0
echo Copie terminée. >con
echo.>con
echo Vous pouvez maintenant éjecter proprement la clé USB de l'ordinateur, la mettre sur votre PS3 (port le plus prêt du lecteur^), allumer la console puis faire la mise à jour via un support de stockage. >con
echo La console installera le firmware officiel 4.82. >con
echo.>con
echo Une fois le firmware installé, Vous devez rebrancher votre clé USB à l'ordinateur pour continuer. >con
echo Attendez qu'elle soit reconu avant d'appuyez sur une touche. >con
pause >con
:define_volume_letter3
%windir%\system32\wscript //Nologo //B TOOLS\Storage\functions\list_volumes.vbs
TOOLS\gnuwin32\bin\grep.exe -c "" <templogs\volumes_list.txt >templogs\count.txt
set /p tempcount=<templogs\count.txt
del /q templogs\count.txt
IF "%tempcount%"=="" (
	echo Aucun disque compatible trouvé. Veuillez insérer votre clé USB.>con
	pause >con
	goto:define_volume_letter3
)
echo. >con
echo Liste des disques: >con
:list_volumes3
IF "%tempcount%"=="0" goto:set_volume_letter3
TOOLS\gnuwin32\bin\tail.exe -%tempcount% <templogs\volumes_list.txt | TOOLS\gnuwin32\bin\head.exe -1 >con
set /a tempcount-=1
goto:list_volumes3
:set_volume_letter3
echo.>con
echo.>con
set /p volume_letter=Entrez de nouveau la lettre du volume de la clé USB que vous souhaitez utiliser: >con
call TOOLS\Storage\functions\strlen.bat nb "%volume_letter%"
IF %nb% EQU 0 (
	echo La lettre de lecteur ne peut être vide. Réessayez. >con
	goto:define_volume_letter3
)
set volume_letter=%volume_letter:~0,1%
set nb=1
CALL TOOLS\Storage\functions\CONV_VAR_to_MAJ.bat volume_letter
set i=0
:check_chars_volume_letter3
IF %i% LSS %nb% (
	set check_chars_volume_letter=0
	FOR %%z in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
		IF "!volume_letter:~%i%,1!"=="%%z" (
			set /a i+=1
			set check_chars_volume_letter=1
			goto:check_chars_volume_letter3
		)
	)
	IF "!check_chars_volume_letter!"=="0" (
		echo Un caractère non autorisé a été saisie dans la lettre du lecteur. Recommencez. >con
		set volume_letter=
		goto:define_volume_letter3
	)
)
IF NOT EXIST "%volume_letter%:\" (
	echo Ce volume n'existe pas. Recommencez. >con
	set volume_letter=
	goto:define_volume_letter3
)
TOOLS\gnuwin32\bin\grep.exe "Lettre volume=%volume_letter%" <templogs\volumes_list.txt | TOOLS\gnuwin32\bin\cut.exe -d ; -f 1 | TOOLS\gnuwin32\bin\cut.exe -d = -f 2 > templogs\tempvar.txt
set /p temp_volume_letter=<templogs\tempvar.txt
IF NOT "%volume_letter%"=="%temp_volume_letter%" (
	echo Cette lettre de volume n'est pas dans la liste. Recommencez. >con
	goto:define_volume_letter3
)
TOOLS\gnuwin32\bin\grep.exe "Lettre volume=%volume_letter%" <templogs\volumes_list.txt | TOOLS\gnuwin32\bin\cut.exe -d ; -f 3 | TOOLS\gnuwin32\bin\cut.exe -d = -f 2 > templogs\tempvar.txt
set /p temp_volume_format=<templogs\tempvar.txt
IF NOT "%temp_volume_format%"=="FAT32" (
	echo Le support que vous avez choisi n'est pas formaté en FAT32. Sélectionnez un autre volume. >con
	set temp_volume_format=
	set temp_volume_letter=
	set volume_letter=
	goto:define_volume_letter3
)

:prepare_usb
TOOLS\gnuwin32\bin\grep.exe "Lettre volume=%volume_letter%" <templogs\volumes_list.txt | TOOLS\gnuwin32\bin\cut.exe -d ; -f 3 | TOOLS\gnuwin32\bin\cut.exe -d = -f 2 > templogs\tempvar.txt
set /p temp_volume_format=<templogs\tempvar.txt
IF NOT "%temp_volume_format%"=="FAT32" (
	echo Le support que vous avez choisi n'est pas formaté en FAT32. >con
	echo Le script va maintenant s'arrêter. >con
	goto:endscript
)
copy /v "TOOLS\usb_ps3\Habib-QA_Toggle-4.21+.pkg" "%volume_letter%:\Habib-QA_Toggle-4.21+.pkg"
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
:define_cfw_select
echo Quel CFW souhaitez-vous utiliser, renseignez-vous pour connaître les différences entre eux: >con
echo.>con
IF "%fw_define%"=="4.82" (
	echo 1: CFW CEX FERROX 4.82 - COBRA 7.55 - V1.01? >con
	echo 2: CFW CEX FERROX 4.82 - COBRA 7.55 - noBD - 1.00? >con
)
echo 0: Choisir un fichier de CFW 4.82/4.84? >con
echo.>con
set /p cfw_select=Entrez le chiffre correspondant au CFW que vous souhaitez utiliser: >con
call TOOLS\Storage\functions\strlen.bat nb "%cfw_select%"
IF %nb% EQU 0 (
	echo Le CFW à choisir ne peut être vide. Réessayez. >con
	goto:define_cfw_select
)
set cfw_select=%cfw_select:~0,1%
set nb=1
set i=0
:check_chars_cfw_select
IF %i% LSS %nb% (
	set check_chars_cfw_select=0
	FOR %%z in (0 1 2) do (
		IF "!cfw_select:~%i%,1!"=="%%z" (
			set /a i+=1
			set check_chars_cfw_select=1
			goto:check_chars_cfw_select
		)
	)
	IF "!check_chars_cfw_select!"=="0" (
		echo Un caractère non autorisé a été saisie dans le choix du CFW. Recommencez. >con
		set cfw_select=
		goto:define_cfw_select
	)
)
IF "%cfw_select%"=="0" goto:copy_cfw0
IF "%cfw_select%"=="1" goto:copy_cfw1
IF "%cfw_select%"=="2" goto:copy_cfw2
:copy_cfw0
%windir%\system32\wscript.exe //Nologo TOOLS\Storage\functions\open_file.vbs "" "Firmware PS3 (*.pup)|*.pup|" "Sélection du fichier de CFW PS3 4.82" "templogs\tempvar.txt"
set /p filepath=<templogs\tempvar.txt
IF NOT "%filepath%"=="" (
	echo Copie du CFW en cours... >con
	copy /v "%filepath%" %volume_letter%:\PS3\UPDATE\PS3UPDAT.PUP
	TOOLS\gnuwin32\bin\md5sum.exe %volume_letter%:\PS3\UPDATE\PS3UPDAT.PUP | TOOLS\gnuwin32\bin\cut.exe -d " " -f 1 | TOOLS\gnuwin32\bin\cut.exe -d ^\ -f 2 >templogs\tempvar.txt
	set /p md5_verif=<templogs\tempvar.txt
) else (
	echo Vous devez sélectionner un CFW. >con
	set cfw_select=
	goto:define_cfw_select
)
IF NOT "%md5_verif%"=="" (
	echo Vérifiez que le MD5 de votre fichier soit correct avant de continuer. >con
	echo Le MD5 du fichier copié est: >con
	echo %md5_verif% >con
	echo.>con
	set /p confirm_cfw_file=Confirmez-vous le choix du CFW? (O/n^): >con
) else (
	echo Il semble y avoir eu un problème lors de la copie du fichier. >con
	echo Vérifiez l'espace libre restant sur votre clé USB. >con
	del /q %volume_letter%:\PS3\UPDATE\PS3UPDAT.PUP
	set cfw_select=
	goto:define_cfw_select
)
IF NOT "%confirm_cfw_file%"=="" set confirm_cfw_file=%confirm_cfw_file:~0,1%
IF /i NOT "%confirm_cfw_file%"=="o" (
	del /q %volume_letter%:\PS3\UPDATE\PS3UPDAT.PUP
	set cfw_select=
	goto:define_cfw_select
)
goto:skip_cfw_copy
:copy_cfw1
IF NOT EXIST TOOLS\usb_ps3\hack_4.82\CEXFERROX482COBRA755_101.PUP (
	echo Téléchargement du CFW en cours... >con
	TOOLS\megatools\megadl.exe "https://mega.nz/#^!n4UFDLwD^!v-pymwI-LRCUEkyKlyFm12Y1BjOZ4Cc1fAnOnRTHVbc" --path=templogs\temp.pup>con
	TOOLS\gnuwin32\bin\md5sum.exe templogs\temp.pup | TOOLS\gnuwin32\bin\cut.exe -d " " -f 1 | TOOLS\gnuwin32\bin\cut.exe -d ^\ -f 2 >templogs\tempvar.txt
	set /p md5_verif=<templogs\tempvar.txt
)
IF NOT EXIST TOOLS\usb_ps3\hack_4.82\CEXFERROX482COBRA755_101.PUP (
	IF NOT "%md5_verif%"=="4ea0375a93cd888afbdf8797bb1a9d4f" (
		IF %md5_try% EQU 3 (
			echo Le md5 du CFW ne semble pas être correct. Veuillez vérifier votre connexion internet ainsi que l'espace disponible sur votre disque dur puis relancer le script. >con
			goto:endscript
		) else (
			set /a md5_try+=1
			goto:copy_cfw1
		)
	)
	set md5_try=0
	move templogs\temp.pup TOOLS\usb_ps3\hack_4.82\CEXFERROX482COBRA755_101.PUP
)
echo Copie du CFW en cours... >con
copy /v TOOLS\usb_ps3\hack_4.82\CEXFERROX482COBRA755_101.PUP %volume_letter%:\PS3\UPDATE\PS3UPDAT.PUP
TOOLS\gnuwin32\bin\md5sum.exe %volume_letter%:\PS3\UPDATE\PS3UPDAT.PUP | TOOLS\gnuwin32\bin\cut.exe -d " " -f 1 | TOOLS\gnuwin32\bin\cut.exe -d ^\ -f 2 >templogs\tempvar.txt
set /p md5_verif=<templogs\tempvar.txt
IF NOT "%md5_verif%"=="4ea0375a93cd888afbdf8797bb1a9d4f" (
	IF %md5_try% EQU 3 (
		echo Le fichier ne semble pas être correctement copié sur la clé USB. >con
		echo Vérifiez l'espace disponible sur votre clé USB. >con
		echo Si vous avez assez d'espace sur votre clé USB, essayez de réinitialiser le script. >con
		echo Le script va maintenant s'arrêter. >con
		goto:endscript
	) else (
		set /a md5_try+=1
		goto:copy_cfw1
	)
)
set md5_try=0
goto:skip_cfw_copy
:copy_cfw2
IF NOT EXIST TOOLS\usb_ps3\hack_4.82\CEXFERROX482COBRA755_noBD_100.PUP (
	echo Téléchargement du CFW en cours... >con
	TOOLS\megatools\megadl.exe "https://mega.nz/#^!m5MFSQoT^!LcMNYeMm1a8IEUfjGm_3xVz1oqYurLiuQhQkMWvEnig" --path=templogs\temp.pup>con
	TOOLS\gnuwin32\bin\md5sum.exe templogs\temp.pup | TOOLS\gnuwin32\bin\cut.exe -d " " -f 1 | TOOLS\gnuwin32\bin\cut.exe -d ^\ -f 2 >templogs\tempvar.txt
	set /p md5_verif=<templogs\tempvar.txt
)
IF NOT EXIST TOOLS\usb_ps3\hack_4.82\CEXFERROX482COBRA755_noBD_100.PUP (
	IF NOT "%md5_verif%"=="8f70b35dcfbcfdf9f99a2d6f8d686b7b" (
		IF %md5_try% EQU 3 (
			echo Le md5 du CFW ne semble pas être correct. Veuillez vérifier votre connexion internet ainsi que l'espace disponible sur votre disque dur puis relancer le script. >con
			goto:endscript
		) else (
			set /a md5_try+=1
			goto:copy_cfw2
		)
	)
	set md5_try=0
	move templogs\temp.pup TOOLS\usb_ps3\hack_4.82\CEXFERROX482COBRA755_noBD_100.PUP
)
echo Copie du CFW en cours... >con
copy /v TOOLS\usb_ps3\hack_4.82\CEXFERROX482COBRA755_noBD_100.PUP %volume_letter%:\PS3\UPDATE\PS3UPDAT.PUP
TOOLS\gnuwin32\bin\md5sum.exe %volume_letter%:\PS3\UPDATE\PS3UPDAT.PUP | TOOLS\gnuwin32\bin\cut.exe -d " " -f 1 | TOOLS\gnuwin32\bin\cut.exe -d ^\ -f 2 >templogs\tempvar.txt
set /p md5_verif=<templogs\tempvar.txt
IF NOT "%md5_verif%"=="8f70b35dcfbcfdf9f99a2d6f8d686b7b" (
	IF %md5_try% EQU 3 (
		echo Le fichier ne semble pas être correctement copié sur la clé USB. >con
		echo Vérifiez l'espace disponible sur votre clé USB. >con
		echo Si vous avez assez d'espace sur votre clé USB, essayez de réinitialiser le script. >con
		echo Le script va maintenant s'arrêter. >con
		goto:endscript
	) else (
		set /a md5_try+=1
		goto:copy_cfw2
	)
)
set md5_try=0
goto:skip_cfw_copy
:skip_cfw_copy
echo Copie terminée. >con
echo.>con

:choose_exploit_type
echo Quel mode d'exploit souhaitez-vous utiliser: >con
echo 1: Exploit utilisant le disque dur interne de la console (recommandé)? >con
echo 2: Exploit utilisant une clé USB ou une carte SD formatée en FAT32? >con
echo.>con
set /p exploit_type=Choisissez votre mode d'exploit: >con
IF %exploit_type%==1 goto:set_choose_exploit
IF %exploit_type%==2 goto:prepare_usb_flash.hex
goto:choose_exploit_type

:prepare_usb_flash.hex
set md5_try=0
IF /i "%skip_prepare_usb%"=="o" goto:set_choose_exploit
echo.>con
IF "%fw_define%"=="4.82" (
	echo Le fichier "flash_482.hex" va être copié sur la clé USB. >con
	echo Une fois le CFW installé et le QA flag activé, vous pouvez supprimer les fichiers "flash_482.hex", "Habib-QA_Toggle-4.21+.pkg" et "PS3\UPDATE\PS3UPDAT.PUP" de la clé USB. >con
) else IF "%fw_define%"=="4.84" (
	echo Le fichier "flash_484.hex" va être copié sur la clé USB. >con
	echo Une fois le CFW installé et le QA flag activé, vous pouvez supprimer les fichiers "flash_484.hex", "Habib-QA_Toggle-4.21+.pkg" et "PS3\UPDATE\PS3UPDAT.PUP" de la clé USB. >con
)
:copy_flash.hex
IF "%fw_define%"=="4.82" (
	copy /v TOOLS\usb_ps3\hack_4.82\flash_482.hex %volume_letter%:\flash_482.hex
) else IF "%fw_define%"=="4.84" (
	copy /v TOOLS\usb_ps3\hack_4.84\flash_484.hex %volume_letter%:\flash_484.hex
)
IF "%fw_define%"=="4.82" (
	TOOLS\gnuwin32\bin\md5sum.exe %volume_letter%:\flash_482.hex | TOOLS\gnuwin32\bin\cut.exe -d " " -f 1 | TOOLS\gnuwin32\bin\cut.exe -d ^\ -f 2 >templogs\tempvar.txt
) else IF "%fw_define%"=="4.84" (
	TOOLS\gnuwin32\bin\md5sum.exe %volume_letter%:\flash_484.hex | TOOLS\gnuwin32\bin\cut.exe -d " " -f 1 | TOOLS\gnuwin32\bin\cut.exe -d ^\ -f 2 >templogs\tempvar.txt
)
set /p md5_verif=<templogs\tempvar.txt
IF "%fw_define%"=="4.82" (
	IF NOT "%md5_verif%"=="d05be52f8d21700052fbd1fc0174acae" (
		IF %md5_try% EQU 3 (
			echo Le md5 du fichier "flash_482.hex" ne semble pas être correct. Veuillez retélécharger le script et recommencer à zéro. >con
			goto:endscript
		) else (
			set /a md5_try+=1
			goto:copy_flash.hex
		)
	)
) else IF "%fw_define%"=="4.84" (
	IF NOT "%md5_verif%"=="ab2b3a2e23fa731301260f5702fc4101" (
		IF %md5_try% EQU 3 (
			echo Le md5 du fichier "flash_484.hex" ne semble pas être correct. Veuillez retélécharger le script et recommencer à zéro. >con
			goto:endscript
		) else (
			set /a md5_try+=1
			goto:copy_flash.hex
		)
	)
)
set md5_try=0
:set_choose_exploit
echo Sélectionnez l'exploit correspondant à votre console: >con
echo.>con
echo 1: PS3 Nand (CECHA0x, CECHB0x, CECHC0x, CECHE0x, CECHG0x)? >con
echo 2: PS3 Nor (CECHH0x, CECHJ0x, CECHK0x, CECHL0x, CECHM0x, CECHP0x, CECHQ0x, CECH-20xxx, CECH-21xxx, CECH-25xxx compatibles)? >con
echo.>con
set /p choose_exploit=Entrez le chiffre correspondant à vottre version de PS3: >con
call TOOLS\Storage\functions\strlen.bat nb "%choose_exploit%"
IF %nb% EQU 0 (
	echo Cette valeur  ne peut être vide. Réessayez. >con
	goto:set_choose_exploit
)
set "choose_exploit=%choose_exploit:~0,1%"
set nb=1
set i=0
:check_chars_choose_exploit
IF %i% LSS %nb% (
	set check_chars_choose_exploit=0
	FOR %%z in (1 2) do (
		IF "!choose_exploit:~%i%,1!"=="%%z" (
			set /a i+=1
			set check_chars_choose_exploit=1
			goto:check_chars_choose_exploit
		)
	)
	IF "!check_chars_choose_exploit!"=="0" (
		echo Vous devez choisir une des valeurs permisent. >con
		set choose_exploit=
		goto:set_choose_exploit
	)
)
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
echo Réinstaller l'OFW 4.82 via le recovery de la console (ne supprime pas de données).
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
:copy_flash.jpg
IF "%fw_define%"=="4.82" (
	if "%exploit_type%"=="1" (
		copy /v TOOLS\web_exploits\4.82\flash\flash_482.jpg TOOLS\web_exploits\htdocs\flash_482.jpg
		TOOLS\gnuwin32\bin\md5sum.exe TOOLS\web_exploits\htdocs\flash_482.jpg | TOOLS\gnuwin32\bin\cut.exe -d " " -f 1 | TOOLS\gnuwin32\bin\cut.exe -d ^\ -f 2 >templogs\tempvar.txt
	)
) else IF "%fw_define%"=="4.84" (
	if "%exploit_type%"=="1" (
		copy /v TOOLS\web_exploits\4.84\flash\flash_484.jpg TOOLS\web_exploits\htdocs\flash_484.jpg
		TOOLS\gnuwin32\bin\md5sum.exe TOOLS\web_exploits\htdocs\flash_484.jpg | TOOLS\gnuwin32\bin\cut.exe -d " " -f 1 | TOOLS\gnuwin32\bin\cut.exe -d ^\ -f 2 >templogs\tempvar.txt
	)
)
set /p md5_verif=<templogs\tempvar.txt
IF "%fw_define%"=="4.82" (
	if "%exploit_type%"=="1" (
		IF NOT "%md5_verif%"=="d05be52f8d21700052fbd1fc0174acae" (
			IF %md5_try% EQU 3 (
				echo Le md5 du fichier "flash_482.jpg" ne semble pas être correct. Veuillez retélécharger le script et recommencer à zéro. >con
				goto:endscript
			) else (
				set /a md5_try+=1
				goto:copy_flash.jpg
			)
		)
		set md5_try=0
	)
) else IF "%fw_define%"=="4.84" (
	if "%exploit_type%"=="1" (
		IF NOT "%md5_verif%"=="ab2b3a2e23fa731301260f5702fc4101" (
			IF %md5_try% EQU 3 (
				echo Le md5 du fichier "flash_484.jpg" ne semble pas être correct. Veuillez retélécharger le script et recommencer à zéro. >con
				goto:endscript
			) else (
				set /a md5_try+=1
				goto:copy_flash.jpg
			)
		)
		set md5_try=0
	)
)
IF "%fw_define%"=="4.82" (
	if "%exploit_type%"=="1" (
		copy /v TOOLS\web_exploits\4.82\flash\ps3xploit_writer_v20.js TOOLS\web_exploits\htdocs\ps3xploit_writer_v20.js
		IF "%choose_exploit%"=="1" (
			copy /v TOOLS\web_exploits\4.82\flash\index_nand_hdd.html TOOLS\web_exploits\htdocs\index.html
			start tools\web_exploits\caddy.exe -agree -http-port 80 -https-port 443 -port 80 -root tools\web_exploits\htdocs
		) else IF "%choose_exploit%"=="2" (
			copy /v TOOLS\web_exploits\4.82\flash\index_nor_hdd.html TOOLS\web_exploits\htdocs\index.html
			start tools\web_exploits\caddy.exe -agree -http-port 80 -https-port 443 -port 80 -root tools\web_exploits\htdocs
		)
	)
) else IF "%fw_define%"=="4.84" (
	if "%exploit_type%"=="1" (
		copy /v TOOLS\web_exploits\4.84\flash\ps3xploit_writer_v201.js TOOLS\web_exploits\htdocs\ps3xploit_writer_v201.js
		IF "%choose_exploit%"=="1" (
			copy /v TOOLS\web_exploits\4.84\flash\index_nand_hdd.html TOOLS\web_exploits\htdocs\index.html
			start tools\web_exploits\caddy.exe -agree -http-port 80 -https-port 443 -port 80 -root tools\web_exploits\htdocs
		) else IF "%choose_exploit%"=="2" (
			copy /v TOOLS\web_exploits\4.84\flash\index_nor_hdd.html TOOLS\web_exploits\htdocs\index.html
			start tools\web_exploits\caddy.exe -agree -http-port 80 -https-port 443 -port 80 -root tools\web_exploits\htdocs
		)
	)
)
IF "%fw_define%"=="4.82" (
	if "%exploit_type%"=="2" (
		copy /v TOOLS\web_exploits\4.82\flash\ps3xploit_writer_v20.js TOOLS\web_exploits\htdocs\ps3xploit_writer_v20.js
		IF "%choose_exploit%"=="1" (
			copy /v TOOLS\web_exploits\4.82\flash\index_nand.html TOOLS\web_exploits\htdocs\index.html
			start tools\web_exploits\caddy.exe -agree -http-port 80 -https-port 443 -port 80 -root tools\web_exploits\htdocs
		) else IF "%choose_exploit%"=="2" (
			copy /v TOOLS\web_exploits\4.82\flash\index_nor.html TOOLS\web_exploits\htdocs\index.html
			start tools\web_exploits\caddy.exe -agree -http-port 80 -https-port 443 -port 80 -root tools\web_exploits\htdocs
		)
	)
) else IF "%fw_define%"=="4.84" (
	if "%exploit_type%"=="2" (
		copy /v TOOLS\web_exploits\4.84\flash\ps3xploit_writer_v201.js TOOLS\web_exploits\htdocs\ps3xploit_writer_v201.js
		IF "%choose_exploit%"=="1" (
			copy /v TOOLS\web_exploits\4.84\flash\index_nand.html TOOLS\web_exploits\htdocs\index.html
			start tools\web_exploits\caddy.exe -agree -http-port 80 -https-port 443 -port 80 -root tools\web_exploits\htdocs
		) else IF "%choose_exploit%"=="2" (
			copy /v TOOLS\web_exploits\4.84\flash\index_nor.html TOOLS\web_exploits\htdocs\index.html
			start tools\web_exploits\caddy.exe -agree -http-port 80 -https-port 443 -port 80 -root tools\web_exploits\htdocs
		)
	)
)
echo.>con
echo Après l'application du patch, il est conseillé de faire un dump de votre NAND ou NOR sans redémarrer la console et de le vérifier avec l'application "PyPS3checker" pour être certain que le patch a fonctionner correctement. Si tout est OK, vous devez redémarrer votre console pour que les patches s'appliquent. Regardez la documentation du script pour plus d'informations et pour télécharger "PyPS3checker". >con
echo Pour information, vous pouvez dumper votre NAND/NOR via une fonction qui est proposée dans le menu de lancement du script. >con
echo.>con
echo Une fois votre PS3 redémarrée et votre CFW installé, il faut installer le QA Togle via le gestionnaire de package du CFW puis lancer l'application installée. >con
echo En cas de freeze sur un écran noir ou d'erreur, vérifiez que vous avez installé un CFW correspondant à votre matériel (NoBD pour ceux ayant un lecteur de disques HS). >con
echo Pour vérifier si le QA est activé, faites cette manipulation en étant positionné sur les paramètres réseau: >con
echo L1+L2+R1+R2+L3+croix dirrectionnelle vers le bas >con
echo Si le QA est actif, de nouveaux menus apparaitront. >con
echo Note: L3=clique du stick gauche.
echo Note: Pour simplifier la manipulation, maintenez tous les boutons et terminez par la croix dirrectionnelle. >con
echo.>con
echo Bon jeu. >con
:endscript
pause >con
rmdir /s /q templogs
rmdir /s /q TOOLS\web_exploits\htdocs
endlocal