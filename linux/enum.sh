#!/bin/bash
echo "sudo -l results:"
sudo -l
echo "------------------------------------------------------------------------"
echo "find results for"+$(whoami)+":"
find / -user $(whoami) 2>/dev/null | egrep -v '(/proc)'
echo "------------------------------------------------------------------------"
echo "find results for -writeable:"
find / -writeable 2>/dev/null | egrep -v '(/proc|/run|/dev)'
