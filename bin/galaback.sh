#!/bin/bash 
#title           :galabacj.sh
#description     :This script will make a backup from postgres database.
#author		     :pablotrianda<pablotrianda@gmail.com>

source ../config/config.cfg
source ../db/script.cfg
# echo "Config for the database name: $GALABACK_FOLDER" >&2
# echo "Config for the database name: $DATABASE_NAME" >&2
# echo "Config for the database host: $DATABASE_NAME" >&2
# echo "Config for the database use: $DATABASE_USER" >&2
# echo "Config for the database folder: $BACKUP_FOLDER" >&2

TODAY_DATE=$(date +%Y%m%d_%H_%M)

if [ ! -d $GALABACK_FOLDER ]; then
    mkdir $GALABACK_FOLDER 
    echo "Directory $GALABACK_FOLDER created"
fi

if [ ! -d $BACKUP_FOLDER ]; then
    mkdir $BACKUP_FOLDER 
    echo "Directory $BACKUP_FOLDER created"
fi

if [ ! -d $DATABASE_FOLDER ]; then
    mkdir $DATABASE_FOLDER 
    echo "Directory $DATABASE_FOLDER created"
    cd $DATABASE_FOLDER 
    touch $DATABASE_FILE
    sqlite3  $DATABASE_FILE "$CREATE_SCHEMA";
    echo "Schema created"
fi

cd $BACKUP_FOLDER
while :
do
  case $1 in
	"-b")
        PGPASSWORD=$DATABASE_PASS pg_dump -h $DATABASE_HOST -U $DATABASE_USER $DATABASE_NAME > $TODAY_DATE"_"$DATABASE_NAME.sql 
        cd $DATABASE_FOLDER
        sqlite3  $DATABASE_FILE "INSERT INTO backups (path_file,date ) VALUES('$TODAY_DATE"_"$DATABASE_NAME.sql',DATETIME('now'))";
        echo "Backup done!"
        exit
		;;
	"-r")
		echo "Restore"
        cd $DATABASE_FOLDER
        if [ "$2" == "--last" ]; then
            echo -e "This option REPLACE the schema: $DATABASE_NAME " 
            while true; do
                read -p "Do you want to continue? Y/N " yn
                case $yn in
                    [Yy]* ) GET_LAST=$(sqlite3  $DATABASE_FILE "$QUERY_LAST;")
                            PGPASSWORD=$POSTGRES_PASS  psql -h $DATABASE_HOST -U $POSTGRES_USER -c "DROP DATABASE $DATABASE_NAME;"
                            PGPASSWORD=$POSTGRES_PASS  psql -h $DATABASE_HOST -U $POSTGRES_USER -c "CREATE DATABASE $DATABASE_NAME;"
                            cd $BACKUP_FOLDER
                            PGPASSWORD=$DATABASE_PASS psql -h $DATABASE_HOST -U $DATABASE_USER $DATABASE_NAME < $GET_LAST
                            break;;
                    [Nn]* ) exit;;
                    * ) echo "Please answer yes or no.";;
                esac
            done
        fi
        if [ "$2" == "--list--all" ]; then
            GET_ALL=$(sqlite3  $DATABASE_FILE "$QUERT_ALL;")
            echo -e "Backup list: \n" $GET_ALL
            exit;
        fi

        if [ "$2" != "" ]; then
            cd $BACKUP_FOLDER
            if [ -e $2 ];then
                echo -e "This option REPLACE the schema: $DATABASE_NAME " 
                while true; do
                    read -p "Do you want to continue? Y/N " yn
                    case $yn in
                        [Yy]* )  
                                PGPASSWORD=$POSTGRES_PASS  psql -h $DATABASE_HOST -U $POSTGRES_USER -c "DROP DATABASE $DATABASE_NAME;"
                                PGPASSWORD=$POSTGRES_PASS  psql -h $DATABASE_HOST -U $POSTGRES_USER -c "CREATE DATABASE $DATABASE_NAME;"
                                PGPASSWORD=$DATABASE_PASS psql -h $DATABASE_HOST -U $DATABASE_USER $DATABASE_NAME < $2
                                exit;;
                        [Nn]* ) exit;;
                        * ) echo "Please answer yes or no.";;
                    esac
                done
            else
                echo "No such file $2"
            fi
        else
            echo -e "MISSING PARAMETER: Must especific the file."
            echo -e "galaback -r --list--all to view all files."
        fi
        
		exit
		;;
	*)
        echo "Usage:  galaback OPTION"
        echo "Options:"
		echo "      -b to do a back."
        echo "      -r to restore especific backup."
        echo "      -r --last to restore from last backup."
        echo "      -r --list--all to restore from last backup."

        exit
		;;
  esac
done



