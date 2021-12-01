FROM mcr.microsoft.com/dotnet/aspnet:5.0-focal AS base
WORKDIR /app
EXPOSE 5000

ENV ASPNETCORE_URLS=http://+:5000

# Creates a non-root user with an explicit UID and adds permission to access the /app folder
# For more info, please refer to https://aka.ms/vscode-docker-dotnet-configure-containers
RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app
USER appuser

FROM mcr.microsoft.com/dotnet/sdk:5.0-focal AS build
# Set proxy information so that we can pull certificates and apt packages
ENV http_proxy=http://proxy-chain.intel.com:911
ENV https_proxy=http://proxy-chain.intel.com:911
WORKDIR /src
COPY ["Demo1.csproj", "./"]
RUN dotnet restore "Demo1.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "Demo1.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Demo1.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Demo1.dll"]
