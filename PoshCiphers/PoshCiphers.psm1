#Get the public and private functions
$Public = @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue)
$Private = @(Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue)

#Dot source the files
ForEach ($Import in @($Public + $Private))
{
    Try
    {
        . $Import.FullName   
    }
    Catch
    {
        Write-Error -Message "Failed to import function $($Import.FullName): $_"    
    }
}
Export-ModuleMember -Function $Public.BaseName