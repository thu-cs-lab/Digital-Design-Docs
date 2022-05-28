#!/bin/bash
set -x
TEMP=$(cat /dev/urandom | base64 | env LC_CTYPE=C tr -cd 'a-f0-9' | head -c 32)
yosys -p "read_verilog $1" -p synth -p "abc -g AND,OR,XOR,NAND,NOR" -p "clean" -p "show -prefix $TEMP -format png"
OUTPUT_DOT=${1/.v/.dot}
OUTPUT_PNG=${1/.v/.png}
mv ${TEMP}.dot ${OUTPUT_DOT}
rm ${TEMP}.png
python3 process.py ${OUTPUT_DOT}
dot -Tpng ${OUTPUT_DOT} > ${OUTPUT_PNG}
