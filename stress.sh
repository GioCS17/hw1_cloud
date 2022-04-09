#!/bin/bash


#echo "----------- Run test1 ----------" #20cpu
#stress-ng --vm 2 --vm-bytes 1G --timeout 20s

#echo "----------- Run test2 ----------" #40cpu
#stress-ng --vm 2  --vm-bytes 2G --mmap 2 --mmap-bytes 2G --page-in --timeout 20s

echo "----------- Run test3 ----------"
stress --cpu 2 --io 4 --vm 2 --hdd 1 --timeout 15s

