#!/bin/bash

if [[ -f core.sh ]] ; then
    source core.sh
else
    echo "Fatal error: missing script core.sh" > /dev/strerr && exit -10
fi

echo "OK"

require errors.sh
require types.sh

newstruct person name surname age

user=$( new person ILYA KUZNETSOV 18 )
user2=$( new person KIRILL TEST 20 )

propget $user name
propget $user2 age

propset $user2 surname IVANOV

delete $user2

typeof $user
