#!/bin/bash
set -x
TEMP=$(cat /dev/urandom | base64 | env LC_CTYPE=C tr -cd 'a-f0-9' | head -c 32)
OUTPUT_DOT=${1/.sv/_sv.dot}
OUTPUT_PNG=${1/.sv/_sv.png}
OUTPUT_SVG=${1/.sv/_sv.svg}
OUTPUT_SYN_V=${1/.sv/_sv.syn.v}
yosys -p "read_verilog -sv $1" -p synth -p "abc -g AND,OR,XOR,NAND,NOR" -p "clean" -p "select -module $2" -p "show -prefix $TEMP -format png" -p "write_verilog ${OUTPUT_SYN_V}"
mv ${TEMP}.dot ${OUTPUT_DOT}
rm ${TEMP}.png
python3 process.py ${OUTPUT_DOT}
dot -Tpng ${OUTPUT_DOT} > ${OUTPUT_PNG}
dot -Tsvg ${OUTPUT_DOT} > ${OUTPUT_SVG}
