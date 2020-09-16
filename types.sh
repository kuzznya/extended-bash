#!/bin/bash

# [[ -z "$IMPORT_TYPE" ]] && IMPORT_TYPE=true || return 0

NEW_INSTANCE_ID=0

type_error() {
    echo "Type error: $@" > /dev/stderr
    exit -1
}

instance_error() {
    echo "Instance error: $@" > /dev/stderr
    exit -2
}

clear() {
    [[ -d btp ]] && rm -rf btp
}

init() {
    clear
    mkdir btp
    touch btp/TYPES.txt
    touch btp/INSTANCES.txt
    touch btp/INSTANCE_PROPS.txt
}

newstruct() {
    local type=$1
    local pattern='\$$type .\*'
    awk '!/pattern/' btp/TYPES.txt > btp/TEMP && mv btp/TEMP btp/TYPES.txt
    for ((i=2; i <= $#; i++))
    do
	local prop=${!i}
	echo $type $prop >> btp/TYPES.txt
    done
}

delete() {
    local id=$1
    echo '!/\$$id .\*/'
    awk '!/\$$id .\*/' btp/INSTANCES.txt > btp/TEMP && mv btp/TEMP btp/INSTANCES.txt
    awk '!/\$$id .\*/' btp/INSTANCE_PROPS.txt > btp/TEMP && mv btp/TEMP btp/INSTANCE_PROPS.txt
}

new() {
    local type=$1
    ! grep -Fxq '$type .*' btp/TYPES.txt && type_error "type $type not found"

    delete $NEW_INSTANCE_ID
    
    echo $NEW_INSTANCE_ID $type >> btp/INSTANCES.txt

    i=2
    for prop in $( grep -Fx '$type .*' btp/TYPES.txt | awk '{print $2}' )
    do
	echo $NEW_INSTANCE_ID \'$prop ${!i}\' >> btp/INSTANCE_PROPS.txt
	i=$(( $i + 1 ))
    done

    echo $NEW_INSTANCE_ID
    
    NEW_INSTANCE_ID=$(( $NEW_INSTANCE_ID + 1 ))
}

get() {
    local id=$1
    local prop=$2
    ! grep -Fxq '$id .*' btp/INSTANCES && instance_error "instance $id not found"
    grep -Fx '$id[:space:]+$prop .*' btp/INSTANCE_PROPS.txt | awk '{print $3}'
}

init

newstruct person name surname age

new person ILYA KUZNETSOV 18
#user=$( new person ILYA KUZNETSOV 18 )

#get $user name
