import sys
import signal
import os
import uart
 
from asm_parser import asmParser
from tables import instructionTable, registerTable

def get_terminal_width():
    try:
        return os.get_terminal_size().columns
    except OSError:
        return 80 
    
def clear_screen(title = True):
    os.system('cls' if os.name == 'nt' else 'clear')
    
    if title:
        print_title(" Programa de control para el procesador MIPS ", uart.serial_port_name, uart.baudrate)
        print("\n")

def print_title(title, port, baudrate):
    width = get_terminal_width()

    if port and baudrate:
        title_width = len(title + f"-> Puerto: {port} | Baudrate: {baudrate} ")
        padding = (width - title_width) // 2
        print(f"{'=' * padding}{title}-> Puerto: {port} | Baudrate: {baudrate} {'=' * padding}")
    else:
        title_width = len(title)
        padding = (width - title_width) // 2
        print(f"{'=' * padding}{title}{'=' * padding}")

def print_separator():
    width = get_terminal_width()
    print("\n" + '=' * width + "\n")

def sigint_handler(signal, frame):
    clear_screen(False)
    
    print("\nSeñal SIGINT recibida. Cerrando el programa.\n")
    
    if uart.serial_port:
        uart.serial_port.close()
        
    sys.exit(0)
    
def main_menu():
    clear_screen()
    print("1. Cargar programa")
    print("2. Ejecutar programa cargado")
    print("3. Eliminar programa cargado")
    print("4. Salir")
    print("\n")
    
    while True:
        try:
            option = int(input("Ingrese el número de la opción: "))
            if 1 <= option <= 4:
                return option
            else:
                print("\nOpción no válida. Ingrese un número válido.\n")
        except ValueError:
            print("\nEntrada no válida. Ingrese un número válido.\n")

def build(file):
    lines = file.readlines()
    result = parser.firstPass(lines)
    if result != 0:
        print(result)
        print("Error en la compilación.\n")
    else:
        print("Programa compilado exitosamente.\n")  
        parser.asmToMachineCode(lines)
        for string in parser.outputArray:
            print(string)
               
def compile_program():
    clear_screen()
    while True:
        try: 
            file_name = input("Ingrese la ruta del archivo ASM a cargar: ")
            file = open(file_name)
            clear_screen()
            build(file)
            upload_program()
            return
        except FileNotFoundError:
            print("\nEl archivo no existe.\n")
            
def upload_program():
    uart.write(76)
    
    print()
    
    for i in range (0, len(parser.instructions), 4):
        for j in range (3, -1, -1):
            index = i+j
            if (index < len(parser.instructions)):
                byte = int(parser.instructions[index], 16)
                uart.write(byte)
            else: 
                break
        print()
    
    print_bytes_as_hex(uart.read())
    
def print_bytes_as_hex(byte_sequence):
    for byte in byte_sequence:
        hex_representation = hex(byte)[2:].zfill(2)
        print(hex_representation, end=' ')
    print() 

signal.signal(signal.SIGINT, sigint_handler)

if __name__ == "__main__":
    parser = asmParser(instructionTable, registerTable, 4)
    
    signal.signal(signal.SIGINT, sigint_handler)

    while True:
        clear_screen()

        if not uart.serial_port or not uart.baudrate:
            clear_screen()
            uart.init()
            clear_screen()
                
        option = main_menu()
        
        if option == 1:
            compile_program()
        elif option == 2:
            clear_screen()
        elif option == 3:
            pass
        elif option == 4:
            clear_screen(False)
            
            print("\nPrograma finalizado.\n")
            
            if uart.serial_port:
                uart.serial_port.close()
                
            sys.exit(0)
        
        input("\nPresione una tecla para continuar...")
