# kubernates
cd "C:%HOMEPATH%\.IntelliJIdea*\config"

rmdir "eval" /s /q

del "options\other.xml"

reg delete "HKEY_CURRENT_USER\Software\JavaSoft\Prefs\jetbrains\idea" /f

