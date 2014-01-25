#!/bin/bash

git init
git add .
git commit -m "deploy"
git push git@heroku.com:askpebble.git master -f
rm -fr .git