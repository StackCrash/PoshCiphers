# Pester testing. https://github.com/pester/Pester/wiki
$myScript = "$PSScriptRoot\PoshCiphers\PoshCiphers.psm1"

Describe 'Unit Tests' {
  Context 'Basic Validation' {
    it 'Should run successfully' {
      if ($myScript -like '*ps1') {
        $run = invoke-expression $myScript
      } else {
        import-module $myScript
        $runCommand = test-PoshCiphers
      }

      $runCommand | Should Match "Reporting from"
    }
  }
}
