# Check-Connection-HamVoIP-Version
This is the Check Connection Script for the HamVoIP Installation
![CheckConn Logo](https://github.com/KD5FMU/Check-Connection-Script-File/blob/main/CheckConn1%20.png)


This is a script file for HamVoIP to check for a specific node connection and if it is not present the server will re-connect to it.

To get the script file downloaded onto your node just use this command:
```
sudo wget https://raw.githubusercontent.com/KD5FMU/Check-Connection-HamVoIP-Version/refs/heads/main/check_connection_hamvoip.sh
```

Once the file has been downloaded we need to make a few customizations. For example we need to edit in your node number and the target node number you want to stay connected to. You can so that by using the following command:
```
sudo nano check_connection_hamvoip.sh
```

Remove the X's on the line that starts with "MY_NODE" and replace them with your node number. Then remove the X's on the line beginning with TARGET_NODE and replace them with the node number you wish to stay connected to. Then save the file (if you are using nano then hit CTL + X and then Y to save and enter to exit). 

Now the script file needs to be made executable, this can be done with this command:
```
sudo chmod +x check_connection.sh
```

Now we need to set a crontab job so that your node can periodically run the script file and check to make sure your node is still connected. I like to set mine for every 2 minuets and this can be achieved with this crontab entery. To open this crontab editor go to the command like and execute this command:
```
sudo crontab -e
```

Once in the crontab you can enter this line and then next available space in the file:
```
*/2 * * * * /etc/asterisk/local/check_connection.sh >/dev/null 2>&1
