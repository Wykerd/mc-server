#!/bin/bash
cd /data
mkdir -p /data/plugins
touch /data/plugins/plugin-loc.yml
touch /mc/config/plugin-list.yml
# set the eula to true
rm -rf /data/eula.txt
echo "eula=true" >> /data/eula.txt

build_tools() {
    cd /tools
    git clone https://hub.spigotmc.org/stash/scm/spigot/buildtools.git
    cd buildtools/
    mvn clean install
    cd /data
}

build_essentials() {
    cd /tools
    git clone https://github.com/EssentialsX/Essentials.git
    ln -s /tools/buildtools/target /tools/Essentials/.buildtools
    cd /tools/Essentials/.buildtools
    java -jar BuildTools.jar --rev 1.8
    java -jar BuildTools.jar --rev 1.8.3
    cd /tools/Essentials
    mvn clean install
    cd /data
}

build_luckperms() {
    cd /tools
    git clone https://github.com/lucko/LuckPerms.git
    cd LuckPerms/
    ./gradlew build
    cd /data
}

build_vault() {
    cd /tools
    git clone https://github.com/MilkBowl/Vault.git
    cd Vault/
    mvn clean install
    cd /data
}

build_worldedit() {
    cd /tools
    git clone https://github.com/EngineHub/WorldEdit.git
    cd WorldEdit/
    ./gradlew build
    cd /data
}

build_worldguard() {
    cd /tools
    git clone https://github.com/EngineHub/WorldGuard.git
    cd WorldGuard/
    ./gradlew build
    cd /data
}

build_bettersleeping() {
    cd /tools
    git clone https://github.com/Nuytemans-Dieter/BetterSleeping.git
    cd BetterSleeping/
    mvn clean install
    cd /data
}

build_wb() {
    cd /tools
    git clone https://github.com/Brettflan/WorldBorder.git
    cd WorldBorder/
    mvn clean install
    cd /data
}

build_spigot() {
    cd /tools/buildtools/target
    java -jar BuildTools.jar -o /mc/spigot/dist
}

build_jars() {
    if [ -f /tools/buildtools/target/BuildTools.jar ]; then
        echo "Using exisiting buildtools binaries"
    else
        build_tools
    fi

    if [ -f /mc/spigot/dist/spigot*.jar ]; then
        echo "Using existing spigot binaries"
    else
        build_spigot
    fi
    
    if [ -d /tools/Essentials/jars ]; then
        echo "Using existing Essentials binaries"
    else
        build_essentials
    fi
    
    if [ -f /tools/LuckPerms/bukkit/build/libs/LuckPerms*.jar ]; then
        echo "Using existing LuckPerms binaries"
    else
        build_luckperms
    fi

    if [ -f /tools/Vault/target/Vault*.jar ]; then
        echo "Using existing Vault binaries"
    else
        build_vault
    fi

    if [ -f /tools/WorldEdit/worldedit-bukkit/build/libs/worldedit-*-SNAPSHOT-dist.jar ]; then
        echo "Using existing WorldEdit binaries"
    else
        build_worldedit
    fi

    if [ -f /tools/WorldGuard/worldguard-bukkit/build/libs/worldguard-*-SNAPSHOT-dist.jar ]; then
        echo "Using existing WorldGuard binaries"
    else
        build_worldguard
    fi

    if [ -f /tools/BetterSleeping/target/BetterSleeping*.jar ]; then
        echo "Using existing BetterSleeping binaries"
    else
        build_bettersleeping
    fi

    if [ -f /tools/WorldBorder/target/WorldBorder.jar ]; then
        echo "Using existing WorldBorder binaries"
    else
        build_wb
    fi
}

cp_jars() {
    echo "Copying binaries to /data/plugins"
    cd /data/plugins
    es=/tools/Essentials
    cp $es/Essentials/target/Essentials*.jar Essentials.jar
    cp $es/EssentialsAntiBuild/target/Essentials*.jar EssentialsAntiBuild.jar
    cp $es/EssentialsChat/target/Essentials*.jar EssentialsChat.jar
    cp $es/EssentialsGeoIP/target/Essentials*.jar EssentialsGeoIP.jar
    cp $es/EssentialsProtect/target/Essentials*.jar EssentialsProtect.jar
    cp $es/EssentialsSpawn/target/Essentials*.jar EssentialsSpawn.jar
    cp $es/EssentialsXMPP/target/Essentials*.jar EssentialsXMPP.jar

    cp /tools/LuckPerms/bukkit/build/libs/LuckPerms*.jar LuckPerms.jar

    cp /tools/Vault/target/Vault*.jar Vault.jar

    cp /tools/WorldEdit/worldedit-bukkit/build/libs/worldedit-*-SNAPSHOT-dist.jar WorldEdit.jar

    cp /tools/WorldGuard/worldguard-bukkit/build/libs/worldguard-*-SNAPSHOT-dist.jar WorldGuard.jar

    cp /tools/BetterSleeping/target/BetterSleeping*.jar BetterSleeping.jar

    cp /tools/WorldBorder/target/WorldBorder.jar WorldBorder.jar

    cd /data
}

setup() {
    node /mc/setup
}

init() {
    build_jars
    cp_jars
    setup
    java -Xms2G -Xmx2G -XX:+UseConcMarkSweepGC -jar /mc/spigot/dist/spigot*.jar
}

init