#!/bin/bash
set -x
OUTPUT_PNG=${1/.v/.png}
OUTPUT_SVG=${1/.v/.svg}
OUTPUT_JSON=${1/.v/.json}
OUTPUT_SYN_V=${1/.v/.syn.v}
yosys -p "read_verilog $1" -p "prep -top $2" -p "synth" -p "dffunmap" -p "abc -g AND,OR,XOR,MUX,NAND,NOR -dff" -p "select -module $2" -p "write_json ${OUTPUT_JSON}" -p "write_verilog ${OUTPUT_SYN_V}"
netlistsvg ${OUTPUT_JSON} -o ${OUTPUT_SVG}
rsvg-convert ${OUTPUT_SVG} -b white --height 800 --keep-aspect-ratio -o ${OUTPUT_PNG}