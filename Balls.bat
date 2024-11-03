@echo off
color 0A

set /p QUESTION_NUMBER=What Forensic Question number do you want (Ex: 1, 2, 3...)? 

set INPUT_FILE=Forensics Question %QUESTION_NUMBER%.txt

rem Check if the input file exists
if not exist "%INPUT_FILE%" (
    echo File "%INPUT_FILE%" not found. Please make sure the file exists in the current directory.
    pause
    exit /b
)

set API_KEY=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
set TEXT_INPUT=Please analyze the following file and provide ONLY the PowerShell script commands needed to solve the problem described. Ensure that the script reads input from "%INPUT_FILE%" and outputs the result to "Answer.txt".

rem Use PowerShell to read the content of the file and append it to TEXT_INPUT
powershell -Command "$content = Get-Content -Raw -Path '%INPUT_FILE%'; [System.IO.File]::WriteAllText('TempRequest.json', '{\"model\":\"gpt-4o-mini\",\"messages\":[{\"role\":\"system\",\"content\":\"You are a helpful assistant specializing in coding and cybersecurity.\"},{\"role\":\"user\",\"content\":\"' + '%TEXT_INPUT%' + ' ' + $content.Replace('\"', '\\\"') + '\"}]}' )"

rem Make the API call and store the response in a temporary file
curl -s -X POST "https://api.openai.com/v1/chat/completions" ^
    -H "Content-Type: application/json" ^
    -H "Authorization: Bearer %API_KEY%" ^
    -d "@TempRequest.json" > TempJsonResponse.txt

rem Extract the API response and save it to OutputSolution.ps1
powershell -Command "try { $response = Get-Content TempJsonResponse.txt | ConvertFrom-Json; if ($response.choices.Count -gt 0) { $scriptContent = $response.choices[0].message.content -replace '```powershell', '' -replace '```', '' -replace 'Here', '' -replace 'Make sure to run the script', ''; $scriptContent | Out-File -FilePath 'OutputSolution.ps1' -Encoding utf8 } else { 'No choices available in the response.' | Out-File -FilePath 'OutputSolution.ps1' -Encoding utf8 } } catch { 'Error parsing JSON response: ' + $_ | Out-File -FilePath 'OutputSolution.ps1' -Encoding utf8 }"

rem Clean up temporary files
del TempJsonResponse.txt
del TempRequest.json

rem Run the generated PowerShell script
powershell -ExecutionPolicy Bypass -File OutputSolution.ps1

rem Delete the ps1 file after giving the answer
del OutputSolution.ps1

rem Open the generated Answer.txt file
start Answer.txt

exit
