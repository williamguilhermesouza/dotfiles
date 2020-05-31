#!/bin/bash
free -m | awk 'NR==3{printf " %s/%sMB\n", $3,$2 }'
