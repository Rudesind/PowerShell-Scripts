<#
.Synopsis
    Compare two CSVs and keep matching values.

.Description
    This PowerShell script compares two CSV values and only keeps values that 
    are matched from both files. The comparison is based on the column selected.

.Parameter Debugging
    (Optional) Turn on local console debugging when running this script.

.Notes
    Script : Keep Equal
    Updated: 10.18.21
    Author : Rudesind <rudesind76@gmail.com>
    Version: 0.1

.Link
    For information on advanced parameters, see: 
        https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced_parameters?view=powershell-6

.Link
    More information on variable types at: 
        https://docs.microsoft.com/en-us/powershell/developer/cmdlet/strongly-encouraged-development-guidelines

.Link
    Details on debug options: 
        https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_preference_variables?view=powershell-6

.Example
    <example>

#>

# Script parameters below
Param(

    [ValidateNotNullOrEmpty()]
    [ValidateScript({(Test-Path $_)})]
    [Parameter(ValueFromPipeline=$True, Mandatory=$True)]
    [string] $FirstFilePath,

    [ValidateNotNullOrEmpty()]
    [ValidateScript({(Test-Path $_)})]
    [Parameter(ValueFromPipeline=$True, Mandatory=$True)]
    [string] $SecondFilePath,

    [ValidateNotNullOrEmpty()]
    [Parameter(ValueFromPipeline=$True, Mandatory=$True)]
    [string] $Column


)

# Error\Exit Codes
#
New-Variable INITIALIZATION_FAILED -option Constant -value 4000
New-Variable MODULE_LOAD_FAILED -option Constant -value 4001
New-Variable LOG_LOAD_FAILED -option Constant -value 4002
New-Variable FAILED_TO_EXIT -option Constant -value 4003

# Debugging
#
try {

    if ($Debugging) {

        $DebugPreference = "Continue"

        Write-Debug "Debug logging has been enabled"
    }

} catch {
    exit -1
}

# Initialize Variables
#
try {

    Write-Debug "Initializing variables"

    # Friendly error message for the script
    #
    [string] $errorMsg = [string]::Empty
    $equalOnly = @()

} catch {
    $errorMsg = "Error, could not initialize the script: " + $Error[0]
    Write-Debug $errorMsg
    exit $INITIALIZATION_FAILED
}

# Import and compare
#
try  {

    $firstCSV = Import-Csv -Path $FirstFilePath
    $secondCSV = Import-Csv -Path $SecondFilePath

    # It's important to understand how to use the compare-object command here
    # Those command will compare the two files, and only include matching values
    # PassThru ensures that the 'SN' field is retained. Otherwise the object 
    # would only have the 'Name' field
    # 
    $compare = Compare-Object $firstCSV $secondCSV -Property Name -IncludeEqual -ExcludeDifferent -PassThru

    $compare | ConvertTo-Csv -NoTypeInformation | Out-File -Append -FilePath ".\compared.csv"


} catch {
    $errorMsg = "Error" + $Error[0]
    Write-Debug $errorMsg
    exit $SAMPLEBLOCK
}

# Exit actions
#
try {

    Write-Debug "Script has completed with no errors"

    exit 0

} catch {
    $errorMsg = "Error, code not exit: " + $Error[0]
    Write-Debug $errorMsg
    exit $FAILED_TO_EXIT
}