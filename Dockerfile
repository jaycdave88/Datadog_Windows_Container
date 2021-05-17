#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

#Depending on the operating system of the host machines(s) that will build or run the containers, the image specified in the FROM statement may need to be changed.
#For more information, please see https://aka.ms/containercompat

FROM mcr.microsoft.com/dotnet/aspnet:5.0-windowsservercore-ltsc2019 AS base
WORKDIR /app

ARG DD_TRACER_VERSION=1.26.3
ENV DD_TRACER_VERSION=$DD_TRACER_VERSION
ENV ASPNETCORE_URLS=http://*.80

ENV COR_ENABLE_PROFILING="1"
ENV COR_PROFILER="{846F5F1C-F9AE-4B07-969E-05C26BC060D8}"

ENV CORECLR_ENABLE_PROFILING="1"
ENV CORECLR_PROFILER=$COR_PROFILER

ENV DD_DOTNET_TRACER_HOME="C:\\Program Files\\Datadog\\.NET Tracer"
ENV DD_INTEGRATIONS="$DD_DOTNET_TRACER_HOME\\integrations.json"
ENV COR_PROFILER_PATH="$DD_DOTNET_TRACER_HOME\\Datadog.Trace.ClrProfiler.Native.dll"
ENV CORECLR_PROFILER_PATH=$COR_PROFILER_PATH

# We recommend always using the latest release and regularly updating: https://github.com/DataDog/dd-trace-dotnet/releases/latest
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

RUN Write-Host "Downloading Datadog .NET Tracer v$env:DD_TRACER_VERSION" ;\
    (New-Object System.Net.WebClient).DownloadFile('https://github.com/DataDog/dd-trace-dotnet/releases/download/v' + $env:DD_TRACER_VERSION + '/datadog-dotnet-apm-' + $env:DD_TRACER_VERSION + '-x64.msi', 'datadog-apm.msi') ;\
    Write-Host 'Installing Datadog .NET Tracer' ;\
    Start-Process -Wait msiexec -ArgumentList '/i datadog-apm.msi /quiet /qn /norestart /log datadog-apm-msi-installer.log' ; \
    Write-Host 'Datadog .NET Tracer installed, removing installer file' ; \
	Remove-Item 'datadog-apm.msi' ;

FROM mcr.microsoft.com/dotnet/sdk:5.0-windowsservercore-ltsc2019 AS build
WORKDIR /src
COPY ["Dotnet.WindowsContainer.Example.csproj", "."]
RUN dotnet restore "./Dotnet.WindowsContainer.Example.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet publish "Dotnet.WindowsContainer.Example.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "Dotnet.WindowsContainer.Example.dll"]