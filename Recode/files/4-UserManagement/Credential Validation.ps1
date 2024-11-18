Start-Job -ScriptBlock {
    auditpol /set /subcategory:"Credential Validation" /success:enable
}