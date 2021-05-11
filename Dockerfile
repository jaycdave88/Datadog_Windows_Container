#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

#Depending on the operating system of the host machines(s) that will build or run the containers, the image specified in the FROM statement may need to be changed.
#For more information, please see https://aka.ms/containercompat

FROM mcr.microsoft.com/dotnet/sdk:5.0-windowsservercore-ltsc2019 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 5000

ENV DD_API_KEY="<API_KEY>"
ENV DD_APM_ENABLED="true"
ENV DD_ENV="apm-docker-samples"

ENV COR_ENABLE_PROFILING="1"
ENV COR_PROFILER="{846F5F1C-F9AE-4B07-969E-05C26BC060D8}"

ENV CORECLR_ENABLE_PROFILING="1"
ENV CORECLR_PROFILER="{846F5F1C-F9AE-4B07-969E-05C26BC060D8}"

# We recommend always using the latest release and regularly updating: https://github.com/DataDog/dd-trace-dotnet/releases/latest
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

RUN Write-Host 'Downloading Datadog .NET Tracer' ;\
	(New-Object System.Net.WebClient).DownloadFile('https://github.com/DataDog/dd-trace-dotnet/releases/download/v1.26.1/datadog-dotnet-apm-1.26.1-x64.msi', 'datadog-apm.msi') ;\
	Write-Host 'Installing Datadog .NET Tracer' ;\
	Start-Process msiexec -ArgumentList '/i datadog-apm.msi /quiet /qn /norestart /log datadog-apm-msi-installer.log' ;\ 
	Start-Sleep -s 10

RUN Write-Host 'Downloading Datadog Agent' ;\
	(New-Object System.Net.WebClient).DownloadFile('https://s3.amazonaws.com/ddagent-windows-stable/datadog-agent-7-latest.amd64.msi', 'datadog-agent.msi') ;\
	Write-Host 'Installing Datadog Agent' ;\
	Start-Process msiexec -ArgumentList '/i datadog-agent.msi /quiet /qn /norestart /log datadog-agent-msi-installer.log' ;\ 
	Start-Sleep -s 10

FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build
WORKDIR /src
COPY ["Dotnet.WindowsContainer.Example.csproj", "."]
RUN dotnet restore "./Dotnet.WindowsContainer.Example.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "Dotnet.WindowsContainer.Example.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Dotnet.WindowsContainer.Example.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Dotnet.WindowsContainer.Example.dll"]