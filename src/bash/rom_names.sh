#!/bin/bash

tail -n +2 games.csv | cut -d',' -f1 | tr -d '"' > names.txt
