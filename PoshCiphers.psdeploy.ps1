# Deploy the script to the C:\Powershell directory
Deploy 'Copy to scripts folder' {
  By Filesystem {
    FromSource '.\'
    To "C:\PowerShell\PoshCiphers"
    Tagged Prod
  }
}
