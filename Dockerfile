#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

#Depending on the operating system of the host machines(s) that will build or run the containers, the image specified in the FROM statement may need to be changed.
#For more information, please see https://aka.ms/containercompat

FROM datadog/agent-amd64:7.27.0-win1909 AS base

ENV DD_API_KEY="a8a8a518ea9959f289fe2154953ceda3"
ENV DD_APM_ENABLED="true"
ENV DD_ENV="apm-docker-samples"
ENV DD_NON_LOCAL_TRAFFIC="true"

ENV COR_ENABLE_PROFILING="1"
ENV COR_PROFILER="{846F5F1C-F9AE-4B07-969E-05C26BC060D8}"

ENV CORECLR_ENABLE_PROFILING="1"
ENV CORECLR_PROFILER="{846F5F1C-F9AE-4B07-969E-05C26BC060D8}"

ENV ASPNETCORE_URLS=http://*:80
# Enable detection of running in a container
ENV DOTNET_RUNNING_IN_CONTAINER=true 
# Enable correct mode for dotnet watch (only mode supported in a container)
ENV DOTNET_USE_POLLING_FILE_WATCHER=true
# Skip extraction of XML docs - generally not useful within an image/container - helps performance
ENV NUGET_XMLDOC_MODE=skip

ADD setup.ps1 /setup.ps1

USER ContainerAdministrator
RUN ["pwsh", "-File","/setup.ps1"]

#ENV DOTNET_SDK_VERSION=5.0.203 

#ENV ProgramFiles='C:\Program Files'

#RUN pwsh -Command Invoke-WebRequest -OutFile dotnet.zip https://dotnetcli.azureedge.net/dotnet/Sdk/5.0.203/dotnet-sdk-$Env:DOTNET_SDK_VERSION-win-x64.zip ;\ 
#$dotnet_sha512 = '762ad53d66b893cb2cdf61540794a4a1e20b127e371f57f912ad8ebd4102aabf32366ebaabfe90aa362c1fae0bec0aa7ac6af35c6c0153fb913cd4c532149238' ;\
#if ((Get-FileHash dotnet.zip -Algorithm sha512).Hash -ne $dotnet_sha512) { Write-Host 'CHECKSUM VERIFICATION FAILED!' ;\
    #exit 1 } ;\
   #mkdir $Env:ProgramFiles\dotnet ;\
   #tar -C $Env:ProgramFiles\dotnet -oxzf dotnet.zip ;\
#
   #Remove-Item -Force dotnet.zip 
#
#
#RUN pwsh -Command Write-Host 'Downloading Datadog .NET Tracer' ;\
	#Invoke-WebRequest -OutFile datadog-apm.msi https://github.com/DataDog/dd-trace-dotnet/releases/download/v1.26.1/datadog-dotnet-apm-1.26.1-x64.msi ;\ 
	#Write-Host 'Installing Datadog .NET Tracer' ;\
	#Start-Process -Wait msiexec -ArgumentList '/i datadog-apm.msi /quiet /qn /norestart /log datadog-apm-msi-installer.log' 
#

	#if ((Get-ChildItem C:\tools | Measure-Object)) { Write-Host 'Datadog .NET Tracer install failled' ;\
	     #exit 1 } #;\
	#Start-Sleep -s 10

# Attempt to set pathing for dotnet.exe but could not get this to work.
#USER ContainerAdministrator
#RUN setx /M PATH '%PATH%;C:\Program Files\dotnet'
#USER ContainerUser
#RUN cd ./app

#WORKDIR /app
EXPOSE 80

#FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build
#WORKDIR /src
#COPY ["Dotnet.WindowsContainer.Example.csproj", "."]
#RUN dotnet restore "./Dotnet.WindowsContainer.Example.csproj"
#COPY . .
#WORKDIR "/src/."
#RUN dotnet build "Dotnet.WindowsContainer.Example.csproj" -c Release -o /app/build
#
#FROM build AS publish
#RUN dotnet publish "Dotnet.WindowsContainer.Example.csproj" -c Release -o /app/publish
#
#FROM base AS final
##WORKDIR /app
#COPY --from=publish /publish .
##ENTRYPOINT ["dotnet", "Dotnet.WindowsContainer.Example.dll"]