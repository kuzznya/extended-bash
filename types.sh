#!/bin/bash

[[ -z "$IMPORT_TYPE" ]] && IMPORT_TYPE=true || return 0

require core.sh

NEW_INSTANCE_ID=btp/NEW_INSTANCE_ID.txt
INSTANCES=btp/INSTANCES.txt
TYPES=btp/TYPES.txt
INSTANCE_PROPS=btp/INSTANCE_PROPS.txt
TEMP=btp/TEMP

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
    echo 0 > $NEW_INSTANCE_ID
    touch $TYPES
    touch $INSTANCES
    touch $INSTANCE_PROPS
}

new_id() {
    id=$(cat $NEW_INSTANCE_ID)
    echo $id
    let "id=$id+1"
    echo $id > $NEW_INSTANCE_ID
}

defined() {
    grep -xq "$1 .*" $TYPES && return 0 || return -1
}

exists() {
    grep -xq "$1 .*" $INSTANCES && return 0 || return -1
}

propdefined() {
    grep -xq "$1 $2" $TYPES && return 0 || return -1
}

newstruct() {
    local type=$1
    local pattern="\$$type .*"
    awk '!/pattern/' $TYPES > $TEMP && mv $TEMP $TYPES
    for ((i=2; i <= $#; i++))
    do
	local prop=${!i}
	echo $type $prop >> $TYPES
    done
}

delete() {
    local id=$1
    awk '$1 != '$id' {print $0}' $INSTANCES > $TEMP && mv $TEMP $INSTANCES
    awk '$1 != '$id' {print $0}' $INSTANCE_PROPS > $TEMP && mv $TEMP $INSTANCE_PROPS
}

new() {
    local type=$1
    ! defined $type && type_error "type $type not found"

    id=$(new_id)
    
    delete $id

    echo $id $type >> $INSTANCES

    i=2
    for prop in $( grep -x "$type .*" $TYPES | awk '{print $2}' )
    do
      echo $id $prop \"${!i}\" >> $INSTANCE_PROPS
      (( i++ ))
    done

    echo $id
}

propget() {
    local id=$1
    local prop=$2
    ! exists $id && instance_error "instance $id not found"
    grep -x "^$id $prop .*" $INSTANCE_PROPS | awk '{print $3}'
}

propset() {
    local id=$1
    local prop=$2
    local value=$3
    ! exists $id && instance_error "instance $id not found"
    ! propdefined $(typeof $id) $prop && type_error "type does not have prop $prop"
    # TODO set prop
}

typeof() {
    id=$1
    ! exists $id && instance_error "instance $id not found"
    grep "^$id .*" $INSTANCES | awk '{print $2}'
}

init
