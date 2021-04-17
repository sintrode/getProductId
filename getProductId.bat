::------------------------------------------------------------------------------
:: NAME
::     Windows Product ID Retriever
::
:: DESCRIPTION
::     Returns your Windows Product key for later use. Compatible with both
::     32-bit and 64-bit operating systems. A batch port of
::     https://www.thewindowsclub.com/find-windows-10-product-key-using-vb-script
::
:: USAGE
::     getProductId.bat
::
:: AUTHOR
::     Sintrode
::
:: VERSION HISTORY
::     1.0 (2021-04-16) - Initial Version
::------------------------------------------------------------------------------
@echo off
setlocal enabledelayedexpansion
set "reg_key=HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
set "reg_value=DigitalProductId"
if "%processor_architecture%"=="AMD64" set "reg_value=%reg_value%4"
set "reg_query=reg query "%reg_key%" /v %reg_value%"
for /f "tokens=3" %%A in ('%reg_query%') do set "key=%%A"
for /L %%A in (0,2,326) do (
	set /a index=%%A/2
	for /f %%B in ("!index!") do set /a key[%%B]=0x!key:~%%A,2!
)
set "key_offset=52"
set "i=28"
set "chars=BCDFGHJKMPQRTVWXY2346789"

:outer_loop
set /a cur=0, x=14

:inner_loop
set /a cur*=256
set /a x_plus_offset=x+key_offset
set /a cur+=!key[%x_plus_offset%]!
set /a "key[!x_plus_offset!]=(!cur!/24)&255"
set /a cur=!cur!%%24
set /a x-=1
if !x! GEQ 0 goto :inner_loop

set /a i-=1
set "key_output=!chars:~%cur%,1!!key_output!"
set /a i_test=(29-!i!)%%6
if "!i_test!"=="0" if not "!i!"=="-1" (
	set /a i-=1
	set "key_output=-!key_output!"
)

if !i! GEQ 0 goto :outer_loop
echo !key_output!