#!/bin/sh

BACKUP_DIR="/var/backups"
BACKUP_LIM=10
BACKUP_LOG=YES
USERS=`getent passwd`
FILE_NAME="$(whoami).tar.gz"
SIZE=`du -ks $HOME | cut -f 1`
ERROR="/tmp/error.txt"

# Si el directorio no supera el límite n se hace un backup
if [ $DIR_SIZE -le $BACKUP_LIM ];
then 
	echo "$HOME does not reach the minimum size: $SIZE kB (< 10 kB)";
	if [ $BACKUP_LOG = "YES" ]; # Si la variable de log está activa se reporta el log, si no termina la ejecución
	then 
		logger -p user.notice -t backup_sript "$HOME does not reach the minimum size: $SIZE kB (< 10 kB)";
	fi
	exit 0;
fi

# Creamos un archivo temporal para redirigir la salida de error del backup
touch $ERROR;
# Creamos el directorio si aún no existe
mkdir -p "$BACKUP_DIR";

# Hacemos backup del directorio en un archivo comprimido 
# redirigiendo el error a un archivo
tar cf "$BACKUP_DIR/$FILE_NAME" "$HOME" 2> $ERROR;
chmod 700 "$BACKUP_DIR/$FILE_NAME"; # La copia solo será accesible por el usuario al que corresponde
# Reportamos el log dependiendo de si es un error o él programa
# fue ejecutado con exito
if [ $? -eq 0 ];
then 
	echo "Backup from $HOME done";
	if [ $BACKUP_LOG = "YES" ]; # Si la variable de log está activa se reporta el log, si no termina la ejecución
	then 
		logger -p user.notice -t backup_sript "Backup from $HOME done";
	fi
else 
	echo "Error while doing backup. See your system logs for further information.";
	if [ $BACKUP_LOG = "YES" ]; # Si la variable de log está activa se reporta el log, si no termina la ejecución
	then 
		logger -p user.notice -t backup_sript -f $ERROR;
	fi
fi
rm $ERROR;
exit 0;