#!/bin/bash

[[ -z "$IMPORT_TYPE" ]] && IMPORT_TYPE=true || return 0

require core.sh

NEW_INSTANCE_ID=btp/NEW_INSTANCE_ID.txt
INSTANCES=btp/INSTANCES.txt
TYPES=btp/TYPES.txt
INSTANCE_PROPS=btp/INSTANCE_PROPS.txt
TEMP=btp/TEMP

# clear
# Remove type & instances info
clear() {
    [[ -d btp ]] && rm -rf btp
}

# init
# Set up type system
init() {
    clear
    mkdir btp
    echo 0 > $NEW_INSTANCE_ID
    touch $TYPES
    touch $INSTANCES
    touch $INSTANCE_PROPS
}

# new_id
# Get new ID for instance
new_id() {
    id=$(cat $NEW_INSTANCE_ID)
    echo $id
    let "id=$id+1"
    echo $id > $NEW_INSTANCE_ID
}

# defined <type>
# If type is defined then return 0 else -1
defined() {
    grep -xq "$1 .*" $TYPES && return 0 || return -1
}

# exists <instance>
# If instance exists then return 0 else return -1
exists() {
    grep -xq "$1 .*" $INSTANCES && return 0 || return -1
}

# propdefined <type> <prop>
# Check if prop exists in type
propdefined() {
    grep -xq "$1 $2" $TYPES && return 0 || return -1
}

# typeof <instance>
# Get type of instance
typeof() {
    id=$1
    ! exists $id && instance_error "instance $id not found"
    grep "^$id .*" $INSTANCES | awk '{print $2}'
}

# newstruct <type> <props>...
# Define new type with given props
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

# delete <instance>
# Delete instance
delete() {
    local id=$1
    awk '$1 != '$id' {print $0}' $INSTANCES > $TEMP && mv $TEMP $INSTANCES
    awk '$1 != '$id' {print $0}' $INSTANCE_PROPS > $TEMP && mv $TEMP $INSTANCE_PROPS
}

# new <type> <params>...
# Create new instance of type with given params as property values
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

# propget <instance> <prop>
# Get property value of instance
propget() {
    local id=$1
    local prop=$2
    ! exists $id && instance_error "instance $id not found" && return -1
    ! propdefined $(typeof $id) $prop && type_error "type does not have prop $prop" && return -1
    grep -x "^$id $prop .*" $INSTANCE_PROPS | awk '{print $3}'
}

# propset <instance> <prop> <value>
# Set property value of instance
propset() {
    local id=$1
    local prop=$2
    local value=$3
    ! exists $id && instance_error "instance $id not found" && return -1
    ! propdefined $(typeof $id) $prop && type_error "type does not have prop $prop" && return -1

    cat $INSTANCE_PROPS | while read line
    do
	if [[ $line =~ ^$id\ $prop\ .*$ ]]; then
	    echo "$id $prop $value" >> $TEMP
	else
	    echo $line >> $TEMP
	fi
    done

    mv $TEMP $INSTANCE_PROPS
}

init
