# https://github.com/sqlcollaborative/dbatools/blob/development/bin/randomizer/en.randomizertypes.csv#L55

# Generate Random Data
Import-Module dbatools

Get-DbaRandomizedValue -RandomizerType Random -RandomizerSubType number -Min 20 -Max 100

Get-DbaRandomizedDatasetTemplate -Path pres:\TestingBasics\ -Template PlayerData | Get-DbaRandomizedDataset -Rows 10
Get-DbaRandomizedDatasetTemplate -Path pres:\TestingBasics\ -Template PlayerData | Get-DbaRandomizedDataset -Rows 10 | ConvertTo-Csv -NoTypeInformation 
$path = "Data:\Customer.csv"
Get-DbaRandomizedDatasetTemplate -Path pres:\TestingBasics\ -Template PlayerData | Get-DbaRandomizedDataset -Rows 1000 | ConvertTo-Csv -NoTypeInformation | Out-File -PSPath $path

pres:\automation\ImportPlayers -Path $path -Truncate $true