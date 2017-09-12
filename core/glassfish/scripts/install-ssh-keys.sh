#!/bin/bash
#/usr/bin/ssh-keygen -t dsa -f $HOME/.ssh/marsur.key -N ""
/usr/bin/ssh-keygen -t dsa -N "" -f $HOME/.ssh/id_dsa

for var in "$@"
do
    cat ~/.ssh/id_dsa.pub | ssh $var 'mkdir .ssh 2>/dev/null;cat >> .ssh/authorized_keys;chmod -R 0700 .ssh'
done

