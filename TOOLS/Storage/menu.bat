::Script by Shadow256
chcp 65001 > nul
IF EXIST log.txt del /q log.txt
cls
::Header
title Shadow256 Ultimate PS3 Hack Script %uphs_version%
echo :::::::::::::::::::::::::::::::::::::
echo ::Shadow256 Ultimate PS3 Hack Script %uphs_version%::
echo :::::::::::::::::::::::::::::::::::::
:define_action_choice
echo.
echo Que souhaitez-vous faire?
echo.
echo 1: Préparer le hack PS3 4.82/4.84 pour les consoles compatibles?
echo.
echo 2: Dumper la mémoire NAND/NOR de votre console (toutes les consoles sont compatibles à partir du firmware 4.20)?
echo.
echo 3: Dumper l'IDPS de votre console (toutes les consoles sont compatibles à partir du firmware 4.20)?
echo.
echo 4: Installer/gérer le Hen (firmware 4.82/4.84)?
echo.
echo 5: Supprimer les fichiers copier  par la préparation du hack 4.82/4.84 d'une clé USB?
echo.
echo 6: Réinitialiser le script?
echo.
echo 0: Lancer la documentation (recommandé)?
echo.
echo N'importe quelle autre choix: Quitter sans rien faire?
echo.
echo.
set /p action_choice=Entrez le numéro correspondant à l'action à faire: 
IF "%action_choice%"=="0" goto:launch_doc
IF "%action_choice%"=="1" goto:prepare_hack_script
IF "%action_choice%"=="2" goto:dump_memory_script
IF "%action_choice%"=="3" goto:dump_idps_script
IF "%action_choice%"=="4" goto:hen_script
IF "%action_choice%"=="5" goto:restore_USB__script
IF "%action_choice%"=="6" goto:restore_default__script
goto:end_script
:prepare_hack_script
set action_choice=
echo.
call TOOLS\Storage\flash.bat > log.txt 2>&1
@echo off
goto:define_action_choice
:dump_memory_script
set action_choice=
echo.
call TOOLS\Storage\dump_memory.bat > log.txt 2>&1
@echo off
goto:define_action_choice
:dump_idps_script
set action_choice=
echo.
call TOOLS\Storage\dump_idps.bat > log.txt 2>&1
@echo off
goto:define_action_choice
:hen_script
set action_choice=
echo.
call TOOLS\Storage\hen.bat > log.txt 2>&1
@echo off
goto:define_action_choice
:restore_USB__script
set action_choice=
echo.
call TOOLS\Storage\restore_USB.bat
@echo off
goto:define_action_choice
:restore_default__script
set action_choice=
echo.
call TOOLS\Storage\restore_default_all.bat
@echo off
goto:define_action_choice
:launch_doc
set action_choice=
echo.
start DOC\index.html
goto:define_action_choice
:end_script
exit