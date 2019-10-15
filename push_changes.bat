@echo off
echo.
echo Creating file list...
echo.
BigFileLister .\ .\files.txt

echo.
echo Adding all files to git...
echo.
git add -A

echo.
echo Creating Commit...
echo Please enter Commit Message in file.
echo.
git commit

echo.
echo Pushing all changes to Repository...
echo.
git push -u origin master

echo.
echo Done! Press [ENTER] to exit
pause
