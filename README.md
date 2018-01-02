# Galaback script
This script will make a backup from **postgres** database.

## Features
  * Make backup.
  * Restore to specific backup.
  * Restore to the last backup.
  
## Dependences
  * sqlite
 
## Installing
  1. clone this repo: ```git clone git@github.com:pablotrianda/GalaBack.git```
  2. run install script: ```./install.sh``` 
  
## Usage
* Make a backup:
  ```$galaback -b```
* Restore to the last backup:
  ```$galaback -r --last```
* View all backups: 
```$galaback -r --list--all```
* Restore to specific backuop
```$galaback -r 20180101_22_18_some_file.sql```
 

  
