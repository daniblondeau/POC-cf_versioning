#!/bin/bash

gcloud functions deploy HelloGet \
--runtime go113 --trigger-http --allow-unauthenticated --update-labels ver=$1,commit=$2
