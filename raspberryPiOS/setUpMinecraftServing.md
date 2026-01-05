first lets make all the setup, lets install the java

pacman -S jdk21-openjdk

then lets enable the destiny port, since we will be doing portforwarding i recommend not leaving the default port

sudo ufw allow <NEW_PORT>/tcp
sudo ufw reload

alternative if you dont have ufw

sudo firewall-cmd --add-port=<NEW_PORT>/tcp --permanent
sudo firewall-cmd --reload

now lets create a directory to make a more organizated structure

mkdir minecraft
cd minecraft


MAKING A VANILLA SERVER

mkdir vanilla
cd vanilla

get the lastest version of the minecraft java edition server https://www.minecraft.net/en-us/download/server, if you are doing this throu a CLI server use the wget command

wget <URL_FOR_DOWNLOAD>

this will download a "server.jar" to mantain more organization create a folder with the version

mkdir x.x.x # e.g. mkdir 1.21.1
cd x.x.x # e.g. cd 1.21.1

lets make the first run of the server this will check files and directories and if are not in the current directory it will create it then fail and stop it

java -Xms4096M -Xmx4096M -jar server.jar nogui

after fail with errors, go to the eula file that was created

nano eula.txt

change the line `eula=false` to `eula=true`

lets edit the config file "server.properties"

change these lines to these values

online-mode=false
server-ip=
query-port=<NEW_PORT>
server-port=<NEW_PORT>

then make the portforwarding with you network 

and the server is ready to go, initiate it with

java -Xms4096M -Xmx4096M -jar minecraft_server_X.X.X.jar nogui

modify the -Xms and -Xmx to more bigger values if you are planning to allocate multiple players
=====================================To make a modded server=====================================
get the lastest version of the minecraft forge server at https://files.minecraftforge.net/net/minecraftforge/forge/, it is the link that says the link that says "Installer (have a classifier icon)" after copy the link paste on arch, this will download the jar file 
> pacman -S fontconfig ttf-dejavu
> wget https://maven.minecraftforge.net/net/minecraftforge/forge/1.20.1-47.3.6/forge-1.20.1-47.3.6-installer.jar
Try to run the server that will get error, so no worries, the command will create multiple files and folder
> java -jar forge-1.12.2-14.23.5.2860-installer.jar --installServer
Now try run the server with the newly created jar
> java -Xms4096M -Xmx4096M -jar forge-1.20.6-50.1.12-shim.jar nogui
This will create multiple files again, between the files it will create a eula that you have to agree so
> vim eula.txt
change the line `eula=false` to `eula=true`
Now run the server again, this will create the server.properties file
> java -Xms4096M -Xmx4096M -jar forge-1.20.6-50.1.12-shim.jar nogui
since the server now its running with defaults config lets continue with the next step but for now exit the server with
> /stop

