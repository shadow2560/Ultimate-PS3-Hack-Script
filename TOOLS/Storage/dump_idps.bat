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
echo Ce script va vous permettre de dumper l'IDPS de votre PS3. >con
echo.>con
echo Toutes les consoles sont compatibles à partir du firmware CEX 4.10 et le firmware DEX 4.81 (OFW ou CFW).>con
echo Vous aurez besoin de brancher une clé USB formatée en FAT32 sur votre console car c'est sur la clé que le dump sera sauvegardé. >con
echo.>con
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
IF "%fw_define%"=="4.82" (
	copy /v TOOLS\web_exploits\4.82\dump\ps3xploit_v20.js TOOLS\web_exploits\htdocs\ps3xploit_v20.js
	copy /v TOOLS\web_exploits\4.82\dump\index_idps.html TOOLS\web_exploits\htdocs\index.html
) else IF "%fw_define%"=="4.84" (
	copy /v TOOLS\web_exploits\4.84\dump\ps3xploit_v201.js TOOLS\web_exploits\htdocs\ps3xploit_v201.js
	copy /v TOOLS\web_exploits\4.84\dump\index_idps.html TOOLS\web_exploits\htdocs\index.html
)
start tools\web_exploits\caddy.exe -agree -http-port 80 -https-port 443 -port 80 -root tools\web_exploits\htdocs
:endscript
pause >con
rmdir /s /q templogs
rmdir /s /q TOOLS\web_exploits\htdocs
endlocal