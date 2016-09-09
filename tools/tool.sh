#!/bin/bash


TARGET="../draft"
#DRAFTS=$(ls -l $TARGET| awk '!/index/ {print $9}')
DRAFTS=$(ls -l $TARGET| awk '{print $9}')

for DRAFT in $DRAFTS
do
    pandoc $TARGET/$DRAFT -o ../$(echo $DRAFT| cut -d'.' -f1).html
done
