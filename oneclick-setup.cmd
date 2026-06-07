:; goto() { :; }
:; goto WINDOWS
goto WINDOWS

# =====================================================================
# --- MAC / LINUX AUTOMATION ---
# =====================================================================
clear

# ANSI Colors
CYAN=$'\033[0;36m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
RED=$'\033[0;31m'
BLUE=$'\033[0;34m'
MAGENTA=$'\033[0;35m'
BOLD=$'\033[1m'
RESET=$'\033[0m'

# Logging helpers (100% ASCII to avoid CMD parsing issues)
SUCCESS_TXT="${GREEN}[OK] SUCCESS:${RESET}"
ACTIVE_TXT="${CYAN}[---] RUNNING:${RESET}"
INFO_TXT="${BLUE}[i] INFO:${RESET}"
WARN_TXT="${YELLOW}[!] WARNING:${RESET}"
ERROR_TXT="${RED}[X] ERROR:${RESET}"

echo -e "${BOLD}${CYAN}==================================================${RESET}"
echo -e "   ${BOLD}${CYAN}         JRONIX ONE-CLICK FLUTTER SETUP          ${RESET}"
echo -e "${BOLD}${CYAN}==================================================${RESET}"
echo ""

# Phase 1: Install Homebrew if missing
echo -e "${ACTIVE_TXT} Phase 1: Verifying Homebrew Package Manager..."
if ! command -v brew &> /dev/null; then
    echo -e "${INFO_TXT} Homebrew not found. Starting automatic installation..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Configure Homebrew paths dynamically based on Apple Silicon or Intel Mac
    if [ -f "/opt/homebrew/bin/brew" ]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -f "/usr/local/bin/brew" ]; then
        echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/usr/local/bin/brew shellenv)"
    fi
else
    # Load Homebrew paths for the current shell session
    if [ -f "/opt/homebrew/bin/brew" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -f "/usr/local/bin/brew" ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
fi
echo -e "${SUCCESS_TXT} Homebrew is ready!"
echo ""

# Phase 2: Installing Tools
echo -e "${ACTIVE_TXT} Phase 2: Installing/Updating Core Developer Tools..."
echo -e "          ${BLUE}- Git (Version Control)${RESET}"
echo -e "          ${BLUE}- Node.js (JavaScript Runtime)${RESET}"
echo -e "          ${BLUE}- OpenJDK (Java Development Kit)${RESET}"
echo -e "          ${BLUE}- Flutter SDK (Framework)${RESET}"
echo ""

# Install Git
if command -v git &> /dev/null; then
    echo -e "${SUCCESS_TXT} Git is already installed."
else
    echo -e "${INFO_TXT} Git not found. Installing Git..."
    brew install git
fi
echo ""

# Install Node
if command -v node &> /dev/null; then
    echo -e "${SUCCESS_TXT} Node.js is already installed."
else
    echo -e "${INFO_TXT} Node.js not found. Installing Node..."
    brew install node
fi
echo ""

# Install Java
if command -v java &> /dev/null; then
    echo -e "${SUCCESS_TXT} Java is already installed."
else
    echo -e "${INFO_TXT} Java not found. Installing OpenJDK..."
    brew install openjdk
fi
echo ""

# Install Flutter
if command -v flutter &> /dev/null; then
    echo -e "${SUCCESS_TXT} Flutter SDK is already installed."
else
    echo -e "${INFO_TXT} Flutter SDK not found. Installing Flutter..."
    brew install --cask flutter
fi
echo ""

# Phase 3: Path Setup
echo -e "${ACTIVE_TXT} Phase 3: Configuring System Paths..."
BREW_PREFIX=$(brew --prefix)
JDK_PATH="${BREW_PREFIX}/opt/openjdk/libexec/openjdk.jdk"

if [ -d "$JDK_PATH" ]; then
    sudo ln -sfn "$JDK_PATH" /Library/Java/JavaVirtualMachines/openjdk.jdk
    echo 'export JAVA_HOME="/Library/Java/JavaVirtualMachines/openjdk.jdk/Contents/Home"' >> ~/.zprofile
    export JAVA_HOME="/Library/Java/JavaVirtualMachines/openjdk.jdk/Contents/Home"
fi
echo -e "${SUCCESS_TXT} Environment paths successfully updated!"
echo ""

# Phase 4: Verification
echo -e "${ACTIVE_TXT} Phase 4: Verifying Installed Versions..."
echo -e "${BOLD}${CYAN}--------------------------------------------------${RESET}"

echo -e "${BOLD}Git Version:${RESET}"
printf "${GREEN}"
git --version
printf "${RESET}\n"

echo -e "${BOLD}Node.js Version:${RESET}"
printf "${GREEN}"
node -v
printf "${RESET}\n"

echo -e "${BOLD}Java Version:${RESET}"
printf "${GREEN}"
java -version
printf "${RESET}\n"

echo -e "${BOLD}Flutter Version:${RESET}"
printf "${GREEN}"
flutter --version
printf "${RESET}\n"

echo -e "${BOLD}${CYAN}--------------------------------------------------${RESET}"
echo ""

# Phase 5: IDE Detection & Install
echo -e "${ACTIVE_TXT} Phase 5: Scanning for Installed IDEs..."
vscode_installed=0
android_installed=0
intellij_installed=0
antigravity_installed=0

if command -v code &> /dev/null; then
    vscode_installed=1
    echo -e "${INFO_TXT} VS Code detected on your system."
fi
if [ -d "/Applications/Android Studio.app" ]; then
    android_installed=1
    echo -e "${INFO_TXT} Android Studio detected on your system."
fi
if [ -d "/Applications/IntelliJ IDEA.app" ] || [ -d "/Applications/IntelliJ IDEA CE.app" ]; then
    intellij_installed=1
    echo -e "${INFO_TXT} IntelliJ IDEA detected on your system."
fi
if [ -d "/Applications/Antigravity.app" ] || [ -d "/Applications/Antigravity IDE.app" ] || command -v antigravity &>/dev/null || command -v antigravity-ide &>/dev/null; then
    antigravity_installed=1
    echo -e "${INFO_TXT} Antigravity IDE detected on your system."
fi

if [ $vscode_installed -eq 0 ] && [ $android_installed -eq 0 ] && [ $intellij_installed -eq 0 ] && [ $antigravity_installed -eq 0 ]; then
    echo -e "${WARN_TXT} No developer IDEs detected. Choose one to install:"
    echo -e "        ${BOLD}1)${RESET} VS Code (Recommended)"
    echo -e "        ${BOLD}2)${RESET} Android Studio"
    echo -e "        ${BOLD}3)${RESET} IntelliJ IDEA Community"
    read -p "Enter choice (1, 2 or 3): " ide_choice
    if [ "$ide_choice" = "1" ]; then
        echo -e "${ACTIVE_TXT} Installing VS Code..."
        brew install --cask visual-studio-code && open -a "Visual Studio Code"
        vscode_installed=1
        echo -e "${SUCCESS_TXT} VS Code installed!"
    elif [ "$ide_choice" = "2" ]; then
        echo -e "${ACTIVE_TXT} Installing Android Studio..."
        brew install --cask android-studio && open -a "Android Studio"
        android_installed=1
        echo -e "${SUCCESS_TXT} Android Studio installed!"
    elif [ "$ide_choice" = "3" ]; then
        echo -e "${ACTIVE_TXT} Installing IntelliJ IDEA Community..."
        brew install --cask intellij-idea-ce && open -a "IntelliJ IDEA CE"
        intellij_installed=1
        echo -e "${SUCCESS_TXT} IntelliJ IDEA Community installed!"
    fi
else
    echo -e "${SUCCESS_TXT} IDE Scan complete."
fi

# Ask to open installed IDEs dynamically
any_ide_installed=0
[ $vscode_installed -eq 1 ] && any_ide_installed=1
[ $android_installed -eq 1 ] && any_ide_installed=1
[ $intellij_installed -eq 1 ] && any_ide_installed=1
[ $antigravity_installed -eq 1 ] && any_ide_installed=1

if [ $any_ide_installed -eq 1 ]; then
    echo ""
    echo -e "${INFO_TXT} Would you like to open any of the installed IDEs?"
    
    menu_index=0
    vscode_opt=-1
    android_opt=-1
    intellij_opt=-1
    antigravity_opt=-1
    
    if [ $vscode_installed -eq 1 ]; then
        menu_index=$((menu_index + 1))
        vscode_opt=$menu_index
        echo -e "     ${BOLD}${menu_index})${RESET} Open VS Code"
    fi
    if [ $android_installed -eq 1 ]; then
        menu_index=$((menu_index + 1))
        android_opt=$menu_index
        echo -e "     ${BOLD}${menu_index})${RESET} Open Android Studio"
    fi
    if [ $intellij_installed -eq 1 ]; then
        menu_index=$((menu_index + 1))
        intellij_opt=$menu_index
        echo -e "     ${BOLD}${menu_index})${RESET} Open IntelliJ IDEA"
    fi
    if [ $antigravity_installed -eq 1 ]; then
        menu_index=$((menu_index + 1))
        antigravity_opt=$menu_index
        echo -e "     ${BOLD}${menu_index})${RESET} Open Antigravity IDE"
    fi
    menu_index=$((menu_index + 1))
    exit_opt=$menu_index
    echo -e "     ${BOLD}${menu_index})${RESET} Skip / Exit"
    
    read -p "Enter choice (1-${menu_index}): " open_choice
    
    if [ "$open_choice" = "$vscode_opt" ]; then
        echo -e "${SUCCESS_TXT} Opening VS Code..."
        open -a "Visual Studio Code"
    elif [ "$open_choice" = "$android_opt" ]; then
        echo -e "${SUCCESS_TXT} Opening Android Studio..."
        open -a "Android Studio"
    elif [ "$open_choice" = "$intellij_opt" ]; then
        echo -e "${SUCCESS_TXT} Opening IntelliJ IDEA..."
        if [ -d "/Applications/IntelliJ IDEA.app" ]; then
            open -a "IntelliJ IDEA"
        else
            open -a "IntelliJ IDEA CE"
        fi
    elif [ "$open_choice" = "$antigravity_opt" ]; then
        echo -e "${SUCCESS_TXT} Opening Antigravity IDE..."
        if [ -d "/Applications/Antigravity.app" ]; then
            open -a "Antigravity"
        else
            open -a "Antigravity IDE"
        fi
    else
        echo -e "${INFO_TXT} Skipping launching IDE."
    fi
fi

echo ""
echo -e "${BOLD}${GREEN}==================================================${RESET}"
echo -e "${BOLD}${GREEN}   SETUP COMPLETED SUCCESSFULLY! READY TO CODE!  ${RESET}"
echo -e "${BOLD}${GREEN}==================================================${RESET}"
echo ""
echo -e "  ${BOLD}${CYAN}Thank you for using Jronix One-Click Setup!${RESET}"
echo -e "  Your development environment is now ready."
echo ""
echo -e "  ${BOLD}${MAGENTA}Created with care by Antigravity IDE.${RESET}"
echo -e "  ${BOLD}${YELLOW}Happy Coding!${RESET}"
echo -e "${BOLD}${GREEN}==================================================${RESET}"
echo ""
exit 0

# =====================================================================
# --- WINDOWS AUTOMATION ---
# =====================================================================
:WINDOWS
@echo off
title Jronix One-Click Flutter Setup
cls

:: Get ANSI Escape Character for Colors
for /f "delims=" %%a in ('powershell -Command "[char]27"') do set "ESC=%%a"
set "cyan=%ESC%[96m"
set "green=%ESC%[92m"
set "yellow=%ESC%[93m"
set "red=%ESC%[91m"
set "blue=%ESC%[94m"
set "magenta=%ESC%[95m"
set "bold=%ESC%[1m"
set "reset=%ESC%[0m"

:: Status Log Headers (100% ASCII to prevent parser issues on Windows)
set "SUCCESS_TXT=%green%[OK] SUCCESS:%reset%"
set "ACTIVE_TXT=%cyan%[---] RUNNING:%reset%"
set "INFO_TXT=%blue%[i] INFO:%reset%"
set "WARN_TXT=%yellow%[!] WARNING:%reset%"
set "ERROR_TXT=%red%[X] ERROR:%reset%"

echo %bold%%cyan%==================================================%reset%
echo   %bold%%cyan%         JRONIX ONE-CLICK FLUTTER SETUP           %reset%
echo %bold%%cyan%==================================================%reset%
echo.

:: Phase 1: Check Admin Rights
echo %ACTIVE_TXT% Phase 1: Checking Administrator Rights...
net session >nul 2>&1
if %errorLevel% == 0 goto admin_ok

echo %ERROR_TXT% %bold%CRITICAL:%reset% Administrative privileges are required!
echo        Please right-click this file and choose "%bold%Run as Administrator%reset%".
echo.
pause
exit /b

:admin_ok
echo %SUCCESS_TXT% Administrator privileges verified!
echo.

:: Phase 2: Chocolatey Installation
echo %ACTIVE_TXT% Phase 2: Verifying Chocolatey Package Manager...
choco -v >nul 2>&1
if %errorLevel% == 0 goto choco_ok

echo %INFO_TXT% Chocolatey not found. Starting automatic installation...
@powershell -NoProfile -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
set "PATH=%ALLUSERSPROFILE%\chocolatey\bin;%PATH%"

:: Confirm installation
choco -v >nul 2>&1
if %errorLevel% == 0 goto choco_ok

echo %ERROR_TXT% Chocolatey installation failed! Please check your internet connection.
pause
exit /b

:choco_ok
echo %SUCCESS_TXT% Chocolatey is ready!
echo.

:: Phase 3: Installing Core Development Tools
echo %ACTIVE_TXT% Phase 3: Installing/Updating Core Developer Tools...
echo          %blue%- Git (Version Control)%reset%
echo          %blue%- Node.js LTS (JavaScript Runtime)%reset%
echo          %blue%- OpenJDK (Java Development Kit)%reset%
echo          %blue%- Flutter SDK (Framework)%reset%
echo.

:: Check Git
where git >nul 2>&1
if %errorLevel% == 0 (
    echo %SUCCESS_TXT% Git is already installed.
) else (
    echo %INFO_TXT% Git not found. Installing Git...
    choco install git -y
)
echo.

:: Check Node.js
where node >nul 2>&1
if %errorLevel% == 0 (
    echo %SUCCESS_TXT% Node.js is already installed.
) else (
    echo %INFO_TXT% Node.js not found. Installing Node.js LTS...
    choco install nodejs-lts -y
)
echo.

:: Check Java
where java >nul 2>&1
if %errorLevel% == 0 (
    echo %SUCCESS_TXT% Java is already installed.
) else (
    echo %INFO_TXT% Java not found. Installing OpenJDK...
    choco install openjdk -y
)
echo.

:: Check Flutter
where flutter >nul 2>&1
if %errorLevel% == 0 (
    echo %SUCCESS_TXT% Flutter SDK is already installed.
) else (
    echo %INFO_TXT% Flutter SDK not found. Installing Flutter...
    choco install flutter -y
)
echo.

:: Phase 4: Path Configuration
echo %ACTIVE_TXT% Phase 4: Refreshing System Environment Paths...
if exist "%ALLUSERSPROFILE%\chocolatey\bin\RefreshEnv.cmd" (
    call "%ALLUSERSPROFILE%\chocolatey\bin\RefreshEnv.cmd"
) else (
    set "PATH=%SystemDrive%\tools\flutter\bin;%PATH%"
)
echo %SUCCESS_TXT% Environment paths updated in current session!
echo.

:: Phase 5: Verification
echo %ACTIVE_TXT% Phase 5: Verifying Installed Versions...
echo %bold%%cyan%--------------------------------------------------%reset%

echo %bold%Git Version:%reset%
<nul set /p="%green%"
call git --version
echo %reset%

echo %bold%Node.js Version:%reset%
<nul set /p="%green%"
call node -v
echo %reset%

echo %bold%Java Version:%reset%
<nul set /p="%green%"
call java -version
echo %reset%

echo %bold%Flutter Version:%reset%
<nul set /p="%green%"
call flutter --version
echo %bold%%cyan%--------------------------------------------------%reset%
echo.

:: Phase 6: IDE Selection
echo %ACTIVE_TXT% Phase 6: Scanning for Installed IDEs...
set "vscode_installed=0"
set "android_installed=0"
set "intellij_installed=0"
set "antigravity_installed=0"

:: Check VS Code
if exist "%LocalAppData%\Programs\Microsoft VS Code\Code.exe" set "vscode_installed=1"
if exist "%ProgramFiles%\Microsoft VS Code\Code.exe" set "vscode_installed=1"
where code >nul 2>&1
if %errorLevel% == 0 set "vscode_installed=1"

:: Check Android Studio
if exist "%ProgramFiles%\Android\Android Studio\bin\studio64.exe" set "android_installed=1"
if exist "%LocalAppData%\Programs\Android Studio\bin\studio64.exe" set "android_installed=1"
where studio64 >nul 2>&1
if %errorLevel% == 0 set "android_installed=1"

:: Check IntelliJ IDEA
if exist "%ProgramFiles%\JetBrains" (
    for /d %%i in ("%ProgramFiles%\JetBrains\IntelliJ IDEA*") do set "intellij_installed=1"
)
if exist "%LocalAppData%\Programs\JetBrains" (
    for /d %%i in ("%LocalAppData%\Programs\JetBrains\IntelliJ IDEA*") do set "intellij_installed=1"
)
where idea >nul 2>&1
if %errorLevel% == 0 set "intellij_installed=1"

:: Check Antigravity IDE
if exist "%LocalAppData%\Programs\Antigravity\Antigravity IDE.exe" set "antigravity_installed=1"
if exist "%LocalAppData%\Programs\antigravity-ide\Antigravity IDE.exe" set "antigravity_installed=1"
if exist "%LocalAppData%\Programs\Antigravity\Antigravity.exe" set "antigravity_installed=1"
if exist "%LocalAppData%\Programs\antigravity-ide\Antigravity.exe" set "antigravity_installed=1"
if exist "%ProgramFiles%\Antigravity\Antigravity IDE.exe" set "antigravity_installed=1"
if exist "%ProgramFiles%\antigravity-ide\Antigravity IDE.exe" set "antigravity_installed=1"
where antigravity >nul 2>&1
if %errorLevel% == 0 set "antigravity_installed=1"
where antigravity-ide >nul 2>&1
if %errorLevel% == 0 set "antigravity_installed=1"

if %vscode_installed%==1 echo %INFO_TXT% VS Code detected on your system.
if %android_installed%==1 echo %INFO_TXT% Android Studio detected on your system.
if %intellij_installed%==1 echo %INFO_TXT% IntelliJ IDEA detected on your system.
if %antigravity_installed%==1 echo %INFO_TXT% Antigravity IDE detected on your system.

if %vscode_installed%==1 goto ask_open_ide
if %android_installed%==1 goto ask_open_ide
if %intellij_installed%==1 goto ask_open_ide
if %antigravity_installed%==1 goto ask_open_ide

echo %WARN_TXT% No developer IDEs detected. Choose one to install:
echo        %bold%1]%reset% VS Code (Recommended)
echo        %bold%2]%reset% Android Studio
echo        %bold%3]%reset% IntelliJ IDEA Community
set /p ide_choice="Enter choice (1, 2 or 3): "

if "%ide_choice%"=="1" (
    echo %ACTIVE_TXT% Installing VS Code...
    choco install vscode -y
    if exist "%ALLUSERSPROFILE%\chocolatey\bin\RefreshEnv.cmd" call "%ALLUSERSPROFILE%\chocolatey\bin\RefreshEnv.cmd"
    set "vscode_installed=1"
    echo %SUCCESS_TXT% VS Code installed!
)
if "%ide_choice%"=="2" (
    echo %ACTIVE_TXT% Installing Android Studio...
    choco install androidstudio -y
    set "android_installed=1"
    echo %SUCCESS_TXT% Android Studio installed!
)
if "%ide_choice%"=="3" (
    echo %ACTIVE_TXT% Installing IntelliJ IDEA Community...
    choco install intellijidea-community -y
    set "intellij_installed=1"
    echo %SUCCESS_TXT% IntelliJ IDEA Community installed!
)

:ask_open_ide
set "any_ide_installed=0"
if %vscode_installed%==1 set "any_ide_installed=1"
if %android_installed%==1 set "any_ide_installed=1"
if %intellij_installed%==1 set "any_ide_installed=1"
if %antigravity_installed%==1 set "any_ide_installed=1"

if %any_ide_installed%==0 goto ide_done

:: Initialize menu options dynamically
set "vscode_opt=-1"
set "android_opt=-1"
set "intellij_opt=-1"
set "antigravity_opt=-1"
set "exit_opt=-1"
set "menu_index=0"

echo.
echo %INFO_TXT% Would you like to open any of the installed IDEs?

if %vscode_installed%==1 (
    set /a menu_index=menu_index+1
    call echo        %%bold%%%%menu_index%%]%%reset%% Open VS Code
    call set "vscode_opt=%%menu_index%%"
)
if %android_installed%==1 (
    set /a menu_index=menu_index+1
    call echo        %%bold%%%%menu_index%%]%%reset%% Open Android Studio
    call set "android_opt=%%menu_index%%"
)
if %intellij_installed%==1 (
    set /a menu_index=menu_index+1
    call echo        %%bold%%%%menu_index%%]%%reset%% Open IntelliJ IDEA
    call set "intellij_opt=%%menu_index%%"
)
if %antigravity_installed%==1 (
    set /a menu_index=menu_index+1
    call echo        %%bold%%%%menu_index%%]%%reset%% Open Antigravity IDE
    call set "antigravity_opt=%%menu_index%%"
)
set /a menu_index=menu_index+1
call echo        %%bold%%%%menu_index%%]%%reset%% Skip / Exit
call set "exit_opt=%%menu_index%%"

call set /p open_choice="Enter choice (1-%%menu_index%%): "

if "%open_choice%"=="%vscode_opt%" (
    echo %SUCCESS_TXT% Opening VS Code...
    if exist "%ProgramFiles%\Microsoft VS Code\Code.exe" (
        start "" "%ProgramFiles%\Microsoft VS Code\Code.exe"
    ) else if exist "%LocalAppData%\Programs\Microsoft VS Code\Code.exe" (
        start "" "%LocalAppData%\Programs\Microsoft VS Code\Code.exe"
    ) else (
        start "" code
    )
)
if "%open_choice%"=="%android_opt%" (
    echo %SUCCESS_TXT% Opening Android Studio...
    if exist "%ProgramFiles%\Android\Android Studio\bin\studio64.exe" (
        start "" "%ProgramFiles%\Android\Android Studio\bin\studio64.exe"
    ) else if exist "%LocalAppData%\Programs\Android Studio\bin\studio64.exe" (
        start "" "%LocalAppData%\Programs\Android Studio\bin\studio64.exe"
    ) else (
        start "" studio64
    )
)
if "%open_choice%"=="%intellij_opt%" (
    echo %SUCCESS_TXT% Opening IntelliJ IDEA...
    if exist "%ProgramFiles%\JetBrains" (
        for /d %%i in ("%ProgramFiles%\JetBrains\IntelliJ IDEA*") do (
            if exist "%%i\bin\idea64.exe" start "" "%%i\bin\idea64.exe"
        )
    )
    if exist "%LocalAppData%\Programs\JetBrains" (
        for /d %%i in ("%LocalAppData%\Programs\JetBrains\IntelliJ IDEA*") do (
            if exist "%%i\bin\idea64.exe" start "" "%%i\bin\idea64.exe"
        )
    )
)
if "%open_choice%"=="%antigravity_opt%" (
    echo %SUCCESS_TXT% Opening Antigravity IDE...
    if exist "%LocalAppData%\Programs\Antigravity\Antigravity IDE.exe" (
        start "" "%LocalAppData%\Programs\Antigravity\Antigravity IDE.exe"
    ) else if exist "%LocalAppData%\Programs\antigravity-ide\Antigravity IDE.exe" (
        start "" "%LocalAppData%\Programs\antigravity-ide\Antigravity IDE.exe"
    ) else if exist "%LocalAppData%\Programs\Antigravity\Antigravity.exe" (
        start "" "%LocalAppData%\Programs\Antigravity\Antigravity.exe"
    ) else if exist "%LocalAppData%\Programs\antigravity-ide\Antigravity.exe" (
        start "" "%LocalAppData%\Programs\antigravity-ide\Antigravity.exe"
    ) else if exist "%ProgramFiles%\Antigravity\Antigravity IDE.exe" (
        start "" "%ProgramFiles%\Antigravity\Antigravity IDE.exe"
    ) else if exist "%ProgramFiles%\antigravity-ide\Antigravity IDE.exe" (
        start "" "%ProgramFiles%\antigravity-ide\Antigravity IDE.exe"
    ) else (
        start "" antigravity-ide
    )
)

:ide_done
echo.
echo %bold%%green%==================================================%reset%
echo   %bold%%green%   SETUP COMPLETED SUCCESSFULLY! READY TO CODE!  %reset%
echo %bold%%green%==================================================%reset%
echo.
echo   %bold%%cyan%Thank you for using Jronix One-Click Setup!%reset%
echo   Your development environment is now ready.
echo.
echo   %bold%%magenta%Created with care by Antigravity IDE.%reset%
echo   %bold%%yellow%Happy Coding!%reset%
echo %bold%%green%==================================================%reset%
echo.
pause
exit /b
