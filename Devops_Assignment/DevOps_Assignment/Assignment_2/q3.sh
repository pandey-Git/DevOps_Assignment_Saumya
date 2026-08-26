#!/bin/bash

path=$(find ~ -name conf.d | head -1)

echo "Path: $path"

echo $path | tr '/' '-'
