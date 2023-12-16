from asm_parser import asmParser
from tables import instructionTable, registerTable
 
import sys
 
def main(argv):
    file = argv
    
    asm = open(file)
    lines = asm.readlines()
    parser = asmParser(instructionTable, registerTable, 4)
    parser.firstPass(lines)
    parser.asmToMachineCode(lines)

    for out in parser.outputArray:
        print(out)


if __name__ == '__main__':
    main(sys.argv[1])