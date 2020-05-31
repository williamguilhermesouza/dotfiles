#!/bin/bash
echo " $(acpi --battery | cut -d, -f2)"
