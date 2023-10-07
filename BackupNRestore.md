# Backup

## Simple - Just configs and Radio app data /etc

 You need to be able to login to your x6100 via ssh.
 Replace x6100 below with the address or hostname of your device.
 Doing these dumps and backup experiments should be done outside of this repository in a seperate
 directory.

 * Multidevice: Use a differently named directory instead of 'Backup-Etc-Git/', so it is possible
 to manage multiple devices in your radio club or ham bubble.

### Initial Setup
 ``` sh
 ssh root@x6100 /etc/init.d/monit stop          # stops the radio app, ensures its data persisted
 ssh root@x6100 etckeeper commit -m "snapshot"

 git clone root@x6100:/etc/.git Backup-Etc-Git/ # init backup to directory Backup-Etc-Git/

 ssh root@x6100 /etc/init.d/monit start         # start the radio app
 ```

### Pull changes
 ``` sh
 cd Backup-Etc-Git/                             # enter the repository

 ssh root@x6100 /etc/init.d/monit stop          # stops the radio app, ensures its data persisted
 ssh root@x6100 etckeeper commit -m "snapshot"  # commit state

 git pull                                       # pull changes

 ssh root@x6100 /etc/init.d/monit start         # start the radio app
 ```

### Restore

 ... TODO ...
 IDEA something with, !!! /not yet tested/ !!!
 ```
 ssh root@x6100 /etc/init.d/monit stop          # stops the radio app, ensures its data persisted
 git push --force                               # assuming the radio has the same network address when
                                                # this backup/repo was initially cloned
                                                # If the address has changed, we need to edit the
                                                # address of the "git remote origin"

 # TODO # here we miss a step, we need to checkout the files pushed to the git repository on the xiegu. 
 #        currently it is on the state previous to push --force
 #        some like this should work, !!! untested !!!
 #        ssh root@x6100 git -C /etc checkout main"

 ssh root@x6100 poweroff                        # power cycle!
 ```

## Full - Backup

... TODO ...


