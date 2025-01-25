#!/bin/sh
docker build -t dcmtk .
docker cp $(docker create dcmtk):/dcmtk.zip .
