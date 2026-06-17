<#
.SYNOPSIS
Updates a CMDB HTML asset block by adding, updating, or deleting a service record.

.DESCRIPTION
The Update-CmdbAsset cmdlet manages an embedded JSON asset array inside a CMDB HTML file.
It supports Add, Update, and Delete operations and writes a transaction log for every change.

.PARAMETER HtmlFilePath
The path to the CMDB HTML file that contains the embedded asset block.

.PARAMETER Action
The action to perform: Add, Update, or Delete.

.PARAMETER Id
The unique identifier for the service asset.

.PARAMETER Name
The display name of the asset when adding or updating.

.PARAMETER SupportGroup
The support team or group responsible for the asset.

.PARAMETER ConfluenceUrl
An optional Confluence documentation URL for the asset.

.PARAMETER ManagementUrl
An optional management console URL for the asset.

.PARAMETER Environment
The environment value for the asset: production, staging, development, or lab.

.PARAMETER Tier
The service criticality tier: critical, high, medium, or low.

.PARAMETER Ip
An optional IP address for the asset.

.PARAMETER LogFilePath
Path to save the JSON transaction log file. Defaults to .\cmdb_changes.json.

.EXAMPLE
Update-CmdbAsset -HtmlFilePath .\cmdb.html -Action Add -Id svc-NewService -Name "New Service" -SupportGroup "Fury" -Environment production -Tier high -Ip 10.1.2.3
Adds a new asset record to the CMDB HTML and logs the change.

.EXAMPLE
Update-CmdbAsset -HtmlFilePath .\cmdb.html -Action Update -Id svc-SeanTest11 -SupportGroup "Fury" -ManagementUrl "https://manage.example.com"
Updates the specified asset fields and rewrites the embedded JSON array.

.EXAMPLE
Update-CmdbAsset -HtmlFilePath .\cmdb.html -Action Delete -Id svc-SeanTest11
Removes the asset with the specified ID from the CMDB HTML asset block.

.NOTES
Supports ShouldProcess, so -WhatIf and -Confirm can be used for safe changes.
#>
function Update-CmdbAsset {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, HelpMessage = "The path to your CMDB HTML file.")]
        [string]$HtmlFilePath,

        [Parameter(Mandatory = $true, HelpMessage = "Specify whether you want to Add, Update, or Delete an asset.")]
        [ValidateSet('Add', 'Update', 'Delete')]
        [string]$Action,

        [Parameter(Mandatory = $true, HelpMessage = "The unique identifier for the service asset.")]
        [string]$Id,

        [string]$Name,
        [string]$SupportGroup,
        [string]$ConfluenceUrl,
        [string]$ManagementUrl,
        [ValidateSet('production', 'staging', 'development', 'lab')]
        [string]$Environment,
        [ValidateSet('critical', 'high', 'medium', 'low')]
        [string]$Tier,
        [string]$Ip,

        [Parameter(Mandatory = $false, HelpMessage = "Path to save the JSON transaction log file.")]
        [string]$LogFilePath = ".\cmdb_changes.json"
    )

    process {
        # 1. Resolve path and verify files exist
        $ResolvedPath = Resolve-Path $HtmlFilePath -ErrorAction Stop
        $ResolvedLogPath = Ensure-LogFile -LogFilePath $LogFilePath

        $HtmlContent = Get-Content -Path $ResolvedPath -Raw

        # 2. Establish boundaries
        $StartTag = "// #ASSETS_START#"
        $EndTag   = "]; // #ASSETS_END#"

        if (-not ($HtmlContent.Contains($StartTag) -and $HtmlContent.Contains($EndTag))) {
            Write-Error "Could not find your exact anchor markers ($StartTag or $EndTag) inside the target file."
            return
        }

        # 3. Split and isolate JSON array body
        $PartsFirst  = $HtmlContent -split [regex]::Escape($StartTag), 2
        $BeforeBlock = $PartsFirst[0] + $StartTag + "`r`n"
        
        $PartsSecond = $PartsFirst[1] -split [regex]::Escape($EndTag), 2
        $RawAssets   = $PartsSecond[0].Trim()
        $AfterBlock  = "`r`n" + $EndTag + $PartsSecond[1]
        
        $CleanJson = "[" + $RawAssets.TrimEnd(',') + "]"
        
        try {
            $CurrentAssets = ConvertFrom-Json $CleanJson -ErrorAction Stop
            if ($null -eq $CurrentAssets) { $CurrentAssets = @() }
            
            $AssetList = [System.Collections.Generic.List[PSCustomObject]]::new()
            foreach ($item in $CurrentAssets) { [void]$AssetList.Add($item) }
        }
        catch {
            Write-Error "Failed to parse current embedded JSON asset block. Details: $_"
            return
        }

        # Locate existing tracking entity
        $ExistingAsset = $AssetList | Where-Object { $_.id -eq $Id }
        $LogEntry = $null

        # 4. EXECUTE ACTIONS & PREPARE LOG SNAPSHOTS
        switch ($Action) {
            'Add' {
                if ($ExistingAsset) {
                    Write-Error "An asset with ID '$Id' already exists. Use -Action Update instead."
                    return
                }

                # Fallback assignments
                $FinalName         = if ($PSBoundParameters.ContainsKey('Name')) { $Name } else { $Id }
                $FinalSupportGroup = if ($PSBoundParameters.ContainsKey('SupportGroup')) { $SupportGroup } else { "" }
                $FinalEnv          = if ($PSBoundParameters.ContainsKey('Environment')) { $Environment } else { "production" }
                $FinalTier         = if ($PSBoundParameters.ContainsKey('Tier')) { $Tier } else { "medium" }
                $FinalIp           = if ($PSBoundParameters.ContainsKey('Ip')) { $Ip } else { "" }

                # Pre-compute search data block so browser indexing logic remains fast and works instantly
                $SearchBlob = "$($FinalName.ToLower()) $($Id.ToLower()) $($FinalSupportGroup.ToLower()) $($FinalEnv.ToLower()) $($FinalTier.ToLower()) $(${FinalIp})"

                $NewAsset = [PSCustomObject]@{
                    id             = $Id
                    name           = $FinalName
                    support_group  = $FinalSupportGroup
                    confluence_url = if ($PSBoundParameters.ContainsKey('ConfluenceUrl')) { $ConfluenceUrl } else { "" }
                    management_url = if ($PSBoundParameters.ContainsKey('ManagementUrl')) { $ManagementUrl } else { "" }
                    environment    = $FinalEnv
                    tier           = $FinalTier
                    ip             = $FinalIp
                    _searchBlob    = $SearchBlob
                }

                if ($PSCmdlet.ShouldProcess("Asset ID: $Id", "Add new asset to CMDB layout")) {
                    $AssetList.Add($NewAsset)
                    
                    $LogEntry = [PSCustomObject]@{
                        Timestamp       = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
                        Action          = "Add"
                        AssetId         = $Id
                        PreviousState   = $null
                        CurrentState    = $NewAsset
                    }
                }
            }

            'Update' {
                if (-not $ExistingAsset) {
                    Write-Error "No asset found matching ID '$Id' to update."
                    return
                }

                if ($PSCmdlet.ShouldProcess("Asset ID: $Id", "Update existing asset fields")) {
                    $PreviousStateSnapshot = $ExistingAsset | ConvertTo-Json -Compress | ConvertFrom-Json

                    if ($PSBoundParameters.ContainsKey('Name'))          { $ExistingAsset.name = $Name }
                    if ($PSBoundParameters.ContainsKey('SupportGroup'))  { $ExistingAsset.support_group = $SupportGroup }
                    if ($PSBoundParameters.ContainsKey('ConfluenceUrl')) { $ExistingAsset.confluence_url = $ConfluenceUrl }
                    if ($PSBoundParameters.ContainsKey('ManagementUrl')) { $ExistingAsset.management_url = $ManagementUrl }
                    if ($PSBoundParameters.ContainsKey('Environment'))   { $ExistingAsset.environment = $Environment }
                    if ($PSBoundParameters.ContainsKey('Tier'))          { $ExistingAsset.tier = $Tier }
                    if ($PSBoundParameters.ContainsKey('Ip'))            { $ExistingAsset.ip = $Ip }
                    
                    # Refresh search index blob dynamically for changes
                    $ExistingAsset._searchBlob = "$($ExistingAsset.name.ToLower()) $($ExistingAsset.id.ToLower()) $($ExistingAsset.support_group.ToLower()) $($ExistingAsset.environment.ToLower()) $($ExistingAsset.tier.ToLower()) $($ExistingAsset.ip)"

                    $LogEntry = [PSCustomObject]@{
                        Timestamp       = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
                        Action          = "Update"
                        AssetId         = $Id
                        PreviousState   = $PreviousStateSnapshot
                        CurrentState    = $ExistingAsset
                    }
                }
            }

            'Delete' {
                if (-not $ExistingAsset) {
                    Write-Warning "Asset ID '$Id' not found. Nothing to remove."
                    return
                }

                if ($PSCmdlet.ShouldProcess("Asset ID: $Id", "Permanently remove asset row")) {
                    $PreviousStateSnapshot = $ExistingAsset | ConvertTo-Json -Compress | ConvertFrom-Json
                    
                    [void]$AssetList.RemoveAll({ param($x) $x.id -eq $Id })
                    
                    $LogEntry = [PSCustomObject]@{
                        Timestamp       = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
                        Action          = "Delete"
                        AssetId         = $Id
                        PreviousState   = $PreviousStateSnapshot
                        CurrentState    = $null
                    }
                }
            }
        }

        # 5. REBUILD AND SAVE HTML
        if ($LogEntry) {
            $UpdatedJsonLines = foreach ($Asset in $AssetList) {
                $SingleLineJson = $Asset | ConvertTo-Json -Depth 4 -Compress
                "            $SingleLineJson,"
            }
            
            $NewInnerBlock = ($UpdatedJsonLines -join "`r`n").TrimEnd(',')
            $FinalHtmlContent = $BeforeBlock + $NewInnerBlock + $AfterBlock
            
            Set-Content -Path $ResolvedPath -Value $FinalHtmlContent -Encoding UTF8
            
            # Append transaction data directly to log file
            Write-TransactionLog -LogFilePath $ResolvedLogPath -LogEntry $LogEntry
            
            Write-Host "Success! CMDB updated and change logged to $ResolvedLogPath" -ForegroundColor Green
        }
    }
}

function Ensure-LogFile ([string]$LogFilePath) {
    if (-not (Test-Path $LogFilePath)) {
        New-Item -Path $LogFilePath -ItemType File -Value "[]" -Force | Out-Null
    }
    return (Resolve-Path $LogFilePath)
}

function Write-TransactionLog ([string]$LogFilePath, [PSCustomObject]$LogEntry) {
    $RawLogContent = Get-Content -Path $LogFilePath -Raw
    
    # Force output to array before populating standard generic lists to resolve method exceptions
    $ParsedLogs = ConvertFrom-Json $RawLogContent
    $Logs = [System.Collections.Generic.List[PSCustomObject]]::new()
    
    if ($null -ne $ParsedLogs) {
        foreach ($Log in $ParsedLogs) { [void]$Logs.Add($Log) }
    }
    
    $Logs.Add($LogEntry)
    $Logs | ConvertTo-Json -Depth 5 | Set-Content -Path $LogFilePath -Encoding UTF8
}