# Minecraft Server Docker

# Server
Spigot is used as the server. Server JAR file is build from source.

# Plugins
The default configuration automatically builds and adds the latest version of the following plugins:
- Vault
- LuckPerms
- WorldEdit
- WorldGuard
- WorldBorder
- EssentialsX
- BetterSleeping

# Running
The initial run takes quite a while to start up, as all the jar files are compiled from source, however subsequent runs are very fast

Run the server using docker-compose 
```
docker-compose up --build
```