#!/bin/bash

if [ -n "$S3_CP_URI" ]; then
    echo "Copying file from $S3_CP_URI to $S3_CP_LOCAL_PATH"
    aws s3 cp $S3_CP_URI $S3_CP_LOCAL_PATH
else
     echo "Skipping S3 copy"
fi

# allow subsequent script to run
exec "$@"