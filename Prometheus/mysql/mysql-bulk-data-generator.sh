#!/bin/bash 
mysql  << EOF 
create database packops;
CREATE TABLE example ( id smallint unsigned not null auto_increment, name varchar() not null, constraint pk_example primary key (id) );
EOF



for i in {1..10000}
do 
RND=$(cat /dev/urandom | tr -dc '[:alpha:]' | fold -w ${1:-10} | head -n 1)
mysql  << EOF 
use packops;
INSERT INTO example ( id, name ) VALUES ( $i, '$RND' );
EOF
done
