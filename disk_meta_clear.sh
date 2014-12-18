#! /bin/sh

CLEAR_SIZE=1024
BLOCK_SIZE=1048576

if [ $UID != `id -u root` ]; then
    echo 'This script can execute by only superuser.'
    exit 1
fi

while :
do
    tail /var/log/messages

    echo -n "target device = "
    read drive

    target="/dev/${drive}"

    if [ ! -b ${target} ]; then
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

#sectors=`diskinfo ${target} | cut -f4`
blocks=`LANG=C sfdisk -s ${target}`

echo "target drive =" ${target}
echo "blocks = ${blocks}"

seekpoint=$((${blocks}*1024/${BLOCK_SIZE}-${CLEAR_SIZE}))

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
