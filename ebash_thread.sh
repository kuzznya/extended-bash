#!/bin/bash

idx="$1"

dir=thread_data
! [[ -d $dir ]] && mkdir $dir

task_file="$dir/ethread-$idx.task"
lock_file="$dir/ethread-$idx.lock"

rm -f "$lock_file"

while true ; do
  if ! [[ -f $task_file ]] || [[ -f $lock_file ]] ; then
    sleep 1s
    continue
  fi

#  echo "[DEBUG] ebash_thread $idx is working"

  touch "$lock_file"
  # Critical section start

  bash "$task_file"
  rm -f "$task_file"

  # Critical section end
  rm -f "$lock_file"
done
