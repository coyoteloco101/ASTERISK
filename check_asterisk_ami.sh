#!/bin/bash
#
#    Program : check_asterisk_ami
#     Author : Paúl Espín <paulespin@hotmail.com>
#    Purpose : Nagios plugin to return Information from an Asterisk host using AMI
#    Returns : Standard Nagios status_* codes exit 0 OK, 2 CRITICAL
#    Licence : GPL
#==========================================================================


if [ "$#" -ne 5 ]; then
    echo "Uso: $0 <hostname> <port> <username> <password> <sip_trunk_name>"
    exit 1
fi

HOSTNAME="$1"
PORT="$2"
USERNAME="$3"
PASSWORD="$4"
SIP_TRUNK_NAME="$5"

# Crear el comando para autenticarse en el AMI y obtener el estado de la troncal SIP
COMMAND="Action: Login\r\nUsername: ${USERNAME}\r\nSecret: ${PASSWORD}\r\n\r\nAction: Command\r\nCommand: sip show pee$

# Enviar el comando al AMI utilizando netcat y leer la respuesta
RESPONSE=$(echo -ne "${COMMAND}" | nc "${HOSTNAME}" "${PORT}")

# Buscar el estado de la troncal SIP en la respuesta
STATUS=$(echo -e "${RESPONSE}" | grep "Status" | awk -F':' '{print $3}' | tr -d '[:space:]' )

# 0 = OK ; 1 = WARNING ; 2 = CRITICAL ; 
# Verificar el estado de la troncal SIP y devolver el mensaje y código de salida correspondiente
case $STATUS in
    UNREACHABLE)
                MSG="UNREACHABLE"
                CODE=2
        ;;

	UNKNOWN)
                MSG="UNKNOWN"
                CODE=1
        ;;

	UNMONITORED)
                MSG="UNMONITORED"
                CODE=1
        ;;
	*)
          	MSG="OK"
                CODE=0
        ;;
esac

echo "$MSG"
exit $CODE
