#!/bin/bash
echo " $(df | grep "/dev/mapper/cryptroot" | awk '{printf $5}')"
