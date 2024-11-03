@echo off
setlocal enabledelayedexpansion

REM Define the API endpoint and your API key
set "API_URL=https://api.openai.com/v1/chat/completions"
set "API_KEY=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"

REM Prompt the user for instructions
set "USER_PROMPT=You are a Cyber Security professional. Please analyze this text and tell me what to do and the commands I need to execute etc. These are for Windows."

REM Read the prompt from the file and set the variable
set "fileContent="
for /f "usebackq delims=" %%i in ("Forensics Question 1.txt") do (
    set "fileContent=!fileContent! %%i"
)

REM Check if curl command was successful
if %errorlevel% neq 0 (
    echo Error: Failed to connect to the API. Check your network and API details.
    exit /b 1
)

REM Make the API request
set "JSON_DATA={\"model\":\"gpt-4o-mini\",\"messages\":[{\"role\":\"user\",\"content\":\"!USER_PROMPT! !fileContent!\"}]}" 
curl -X POST "%API_URL%" ^
     -H "Content-Type: application/json" ^
     -H "Authorization: Bearer %API_KEY%" ^
     -d "!JSON_DATA!" > response.txt

REM Parse the JSON response and output the content to response.txt
powershell -Command "try { $response = Get-Content response.txt | ConvertFrom-Json; if ($response.choices.Count -gt 0) { $response.choices[0].message.content | Out-File response.txt -Encoding utf8 } else { 'No choices available in the response.' | Out-File response.txt -Encoding utf8 } } catch { 'Error parsing JSON response: ' + $_ | Out-File response.txt -Encoding utf8 }"

pause