#!/bin/bash

set -e

while getopts t:c: flag
do
    case "${flag}" in
        t) TARGET_BUCKET=${OPTARG};;
        c) CLOUDFRONT_DISTRIBUTION=${OPTARG};;
    esac
done

if [ -z "$TARGET_BUCKET" ]; then
    echo "exit: No TARGET_BUCKET specified - please give a bucket URL as parameter -t"
    exit;
fi

if [ -z "$CLOUDFRONT_DISTRIBUTION" ]; then
    echo "exit: No CLOUDFRONT_DISTRIBUTION specified - please give a valid cloudfront distribution ID as parameter -c"
    exit;
fi

npm run lint
npm run build

aws s3 sync dist/ s3://"$TARGET_BUCKET" --delete --acl public-read
INVALIDATION_RESULT=$(aws cloudfront create-invalidation --distribution-id $CLOUDFRONT_DISTRIBUTION --paths "/*")
echo $INVALIDATION_RESULT