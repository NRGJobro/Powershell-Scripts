@echo off
setlocal enabledelayedexpansion

REM Define the API endpoint and your API key
set "API_URL=https://api.openai.com/v1/chat/completions"
set "API_KEY=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"

REM Prompt the user for instructions
set "USER_PROMPT=You are a Cyber Security professional. Please analyze this text and tell me what to do and the commands I need to execute etc. These are for Windows. Do NOT try to format anything"

REM Read the prompt from the file and set the variable
set "fileContent="
for /f "usebackq delims=" %%i in ("Forensics Question 1.txt") do (
    set "fileContent=!fileContent! %%i"
)

REM Construct the JSON data for the first request
set "JSON_DATA={\"model\":\"gpt-4o-mini\",\"messages\":[{\"role\":\"user\",\"content\":\"!USER_PROMPT! !fileContent!\"}]}" 

REM Debugging: Output the JSON_DATA
REM echo !JSON_DATA!

REM Make the API request
curl -X POST "%API_URL%" ^
     -H "Content-Type: application/json" ^
     -H "Authorization: Bearer %API_KEY%" ^
     -d "!JSON_DATA!" > response.txt

REM Check if curl command was successful
if %errorlevel% neq 0 (
    echo Error: Curl command failed. Check the output above.
    exit /b 1
)

REM Parse the JSON response and output the content to response.txt
powershell -Command "try { $response = Get-Content response.txt | ConvertFrom-Json; if ($response.choices.Count -gt 0) { $response.choices[0].message.content | Out-File response.txt -Encoding utf8 } else { 'No choices available in the response.' | Out-File response.txt -Encoding utf8 } } catch { 'Error parsing JSON response: ' + $_ | Out-File response.txt -Encoding utf8 }"

REM Second request
set "fileContent2="
for /f "usebackq delims=" %%i in ("response.txt") do (
    set "fileContent2=!fileContent2! %%i"
)

REM Prompt the user for instructions for the second request
set "USER_PROMPT2=Based on the following analysis, generate .bat script CODE ONLY containing the necessary commands. Do NOT try to format the script with three backticks: "

REM Construct the JSON data for the second request
set "JSON_DATA2={\"model\":\"gpt-4o-mini\",\"messages\":[{\"role\":\"user\",\"content\":\"!USER_PROMPT2! !fileContent2!\"}]}" 

REM Debugging: Output the JSON_DATA2
REM echo !JSON_DATA2!

REM Make the second API request
curl -X POST "%API_URL%" ^
     -H "Content-Type: application/json" ^
     -H "Authorization: Bearer %API_KEY%" ^
     -d "!JSON_DATA2!" > final.bat

REM Parse the JSON response and output the content to final.bat
powershell -Command "try { $response = Get-Content final.bat | ConvertFrom-Json; if ($response.choices.Count -gt 0) { $response.choices[0].message.content | Out-File final.bat -Encoding utf8 } else { 'No choices available in the response.' | Out-File final.bat -Encoding utf8 } } catch { 'Error parsing JSON response: ' + $_ | Out-File final.bat -Encoding utf8 }"

del "response.txt"

pause
