#! /bin/bash

SERVER=s2

for f in `find * -type f`
do
    if [ $f != "deploy.sh" -a $f != "post-deploy.sh" ]; then
        echo $f
        cat $f | ssh -C $SERVER "sudo tee /$f > /dev/null"
    fi
done

cat ./post-deploy.sh | ssh $SERVER bash -
