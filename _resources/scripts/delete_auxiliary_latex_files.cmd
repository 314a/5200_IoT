@echo off
:: for some reason the pdf option latex-clean: true is way to slow
:: This script is used to delete all auxiliary files created by latex
:: It cleans up the directory after the build process
:: Delete all files with the following extensions:
set extensions=mtc mtc0 maf aux bbl blg idx ilg ind log toc

:: Iterate over each extension and delete the files
(for %%i in (%extensions%) do ( 
    if exist *.%%i echo *.%%i files deleted 
    if exist *.%%i del *.%%i
))