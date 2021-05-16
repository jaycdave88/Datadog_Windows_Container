# Open up network for Windows Containers to download files directly.
#Get-NetIPInterface -AddressFamily IPv4 | Sort-Object -Property InterfaceMetric -Descending
#Set-NetIPInterface -InterfaceAlias 'Wi-Fi' -InterfaceMetric 3
#Get-NetRoute -AddressFamily IPv4

# Locally testing to let the script run locally 
#Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

#Download .NET 5 SDK
Write-Host 'Downloading .NET SDK'
mkdir 'c:\Program Files\dotnet'
Invoke-WebRequest -OutFile 'c:\Program Files\dotnet\dotnet.zip' https://dotnetcli.azureedge.net/dotnet/Sdk/5.0.203/dotnet-sdk-5.0.203-win-x64.zip

#Install .NET 5 SDK
Write-Host 'Installing .NET SDK'
$dotnet_sha512 = '762ad53d66b893cb2cdf61540794a4a1e20b127e371f57f912ad8ebd4102aabf32366ebaabfe90aa362c1fae0bec0aa7ac6af35c6c0153fb913cd4c532149238' 
if ((Get-FileHash 'c:\Program Files\dotnet\dotnet.zip' -Algorithm sha512).Hash -ne $dotnet_sha512) { Write-Host 'CHECKSUM VERIFICATION FAILED!'
    exit 1 } 
tar -C 'c:\Program Files\dotnet\' -oxzf 'c:\Program Files\dotnet\dotnet.zip'

#clean-up
Remove-Item -Force 'c:\Program Files\dotnet\dotnet.zip'

#Adding dotnet.exe to path for code to execute.
Write-Host 'Adding C:\Program Files\dotnet to $Env:Path'
$INCLUDE = 'C:\Program Files\dotnet;C:\Windows\System32\Wbem;C:\Program Files\PowerShell\latest;C:\Windows\System32\OpenSSH\;C:\Users\ContainerAdministrator\AppData\Local\Microsoft\WindowsApps' 
$ENV:INCLUDE 
$OLDPATH = [System.Environment]::GetEnvironmentVariable('PATH','machine')
$NEWPATH = "$OLDPATH;$INCLUDE" 
[Environment]::SetEnvironmentVariable("PATH", "$NEWPATH", "Machine")

Write-Host 'Downloading Datadog .NET Tracer'
#Invoke-WebRequest -OutFile 'c:\tools\datadog-apm.msi' https://github.com/DataDog/dd-trace-dotnet/releases/download/v1.26.1/datadog-dotnet-apm-1.26.1-x64.msi
(New-Object System.Net.WebClient).DownloadFile('https://github.com/DataDog/dd-trace-dotnet/releases/download/v1.26.1/datadog-dotnet-apm-1.26.1-x64.msi', 'C:\datadog-apm.msi') 

Write-Host 'Installing Datadog .NET Tracer'
Start-Process msiexec -ArgumentList '/i C:\datadog-apm.msi /quiet /qn /norestart /log c:\installdatadogmsi.log' 


#Install Powershell globally 
