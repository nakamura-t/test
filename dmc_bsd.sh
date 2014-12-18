#! /usr/local/bin/bash

CLEAR_SIZE=1024
BLOCK_SIZE=1048576

while :
do
    tail /var/log/messages

    echo -n "target device = "
    read drive

    target="/dev/${drive}"

    if [ ! -c ${target} ]; then
        echo "Input device is not exist."
        exit 1
    fi

    ls -lAF ${target}

    echo -n "Are you OK ? :"
    read aok

    case x${aok} in
        x[Yy][Ee][Ss])
            break;
            ;;
        *)
            echo "Once again."
            ;;
    esac
done

sectors=`diskinfo ${target} | cut -f4`

echo "target drive =" ${target}
echo "sectors = ${sectors}"

seekpoint=$((${sectors}*512/${BLOCK_SIZE}-${CLEAR_SIZE}))

echo "seekpoint = ${seekpoint}"

echo ""
echo "head part"

echo "dd if=/dev/zero of=${target} bs=${BLOCK_SIZE} count=${CLEAR_SIZE}"
dd if=/dev/zero of=${target} bs=${BLOCK_SIZE} count=${CLEAR_SIZE}

echo ""
echo "tail part"

echo "dd if=/dev/zero of=${target} seek=${seekpoint} bs=${BLOCK_SIZE}"
dd if=/dev/zero of=${target} seek=${seekpoint} bs=${BLOCK_SIZE}

sync
sync
sync

exit
