@echo off
echo Version:
:: pandoc --version
:: quarto --version

::echo render the following slides slides:
::quarto render slides/L01_Theory.qmd
::quarto render slides/L02_Methods.qmd

:: optional argument for the output dir
IF "%1"=="" (
    SET outputdir=%1
) ELSE (
    :: docs or _books
    SET outputdir=docs
)


:: iterate over all *.qmd files in the slides folder
:: quarto render slides/L01_Theory.qmd --to pptx --reference-doc "_resources\template.potx"
for %%f in (slides\*.qmd) do (
    quarto render %%f
)

echo move files
mkdir "%outputdir%\slides"
::copy "slides\L01_Theory.html" "_book\slides\L01_Theory.html"
:: copy the slides if you want to use listings to list the slides
copy "slides\*.html" "%outputdir%\slides\"
::mkdir "%outputdir%\chapters"
::copy "_chapters\*.pdf" "%outputdir%\chapters\"




:: check if directory "chapter" exists and create directory "%outputdir%\chapter"
:: move all *.pdf files to the %outputdir%/chapter folder
if exist "chapters" (
    if not exist "%outputdir%\chapters" (
        mkdir "%outputdir%\chapters"
    )   
    copy "chapters\*.pdf" "%outputdir%\chapters\"
)
