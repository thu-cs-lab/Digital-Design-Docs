#!/bin/bash
set -x
TEMP=$(cat /dev/urandom | base64 | env LC_CTYPE=C tr -cd 'a-f0-9' | head -c 32)
OUTPUT_DOT=${1/.vhdl/_vhdl.dot}
OUTPUT_PNG=${1/.vhdl/_vhdl.png}
OUTPUT_SYN_V=${1/.vhdl/_vhdl.syn.v}
sudo docker run -it --rm -t -v $PWD:/src -w /src hdlc/ghdl:yosys yosys -m ghdl -p "ghdl -fsynopsys -fexplicit $1 -e $2" -p synth -p "abc -g AND,OR,XOR,NAND,NOR" -p "clean" -p "show -prefix $TEMP -format png" -p "write_verilog ${OUTPUT_SYN_V}"
sudo chown -R ${USER}:${USER} .
mv ${TEMP}.dot ${OUTPUT_DOT}
rm -rf ${TEMP}.png
python3 process.py ${OUTPUT_DOT}
dot -Tpng ${OUTPUT_DOT} > ${OUTPUT_PNG}
