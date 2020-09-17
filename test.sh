#!/bin/bash

if [[ -f core.sh ]] ; then
    source core.sh
else
    echo "Fatal error: missing script core.sh" > /dev/strerr && exit -10
fi

require errors.sh
require types.sh

testfunc() {
    local person=$1
    echo $(propget $person name)
}

newstruct person name surname age

user=$( new person ILYA KUZNETSOV 18 )
user2=$( new person KIRILL TEST 20 )

propget $user name
propget $user2 age

propget $user invalidprop

propset $user2 surname IVANOV
propget $user2 surname

testfunc $user
testfunc $user2

delete $user2
propget $user2 surname

typeof $user

newstruct car name speed weight

car=$(new car Mercedes 250 2500)

typeof $car

propget $car speed
propset $car name "Cadillac 123"
propget $car name
