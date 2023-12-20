import sys
import signal
import os
import serial.tools.list_ports
 
from asm_parser import asmParser
from tables import instructionTable, registerTable
from uart import Uart
from mips_handler import MipsHandler

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

def hex(value):
    return '{:02X}'.format(value)

def sigint_handler(signal, frame):
    clear_screen(False)
    
    print("\nSeñal SIGINT recibida. Cerrando el programa.\n")
    
    if uart.serial_port:
        uart.serial_port.close()
        
    sys.exit(0)

def list_ports():
    ports = list(serial.tools.list_ports.comports())
    for i, port in enumerate(ports):
        print(f"{i + 1}. {port.device}")
    return ports

def select_port():
    ports = list_ports()
    
    while True:
        try:
            opcion = int(input("\nSeleccione el número del puerto al que desea conectarse: "))
            if 1 <= opcion <= len(ports):
                return ports[opcion - 1].device
            else:
                print("\nOpción no válida. Ingrese un número válido.")
        except ValueError:
            print("\nEntrada no válida. Ingrese un número válido.")
            
def select_baudrate():
    baudrate_options = [300, 1200, 2400, 4800, 9600, 19200, 38400, 57600, 115200]
    
    while True:
        print("\nSeleccione el baudrate:")
        for i, option in enumerate(baudrate_options):
            print(f"{i + 1}. {option}")
        
        try:
            opcion = int(input("\nIngrese el número de la opción: "))
            if 1 <= opcion <= len(baudrate_options):
                return baudrate_options[opcion - 1]
            else:
                print("\nOpción no válida. Ingrese un número válido.")
        except ValueError:
            print("\nEntrada no válida. Ingrese un número válido.")
            
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
    type = None
    content = None
    
    uart.start_load_program()

    if uart.available():
        type, _, _, content = uart.read() 
    
    if type == uart.ERROR_PREFIX:
        print(f"\nError al cargar el programa: 0x{hex(content)} !\n")
    else:
        for i in range (0, len(parser.instructions), 4):
            for j in range (3, -1, -1):
                index = i+j
                if (index < len(parser.instructions)):
                    uart.write(int(parser.instructions[index], 16))
                else: 
                    break
                
        type, _, _, content = uart.read() 
        
        if type == uart.ERROR_PREFIX:
            print(f"\nError al cargar el programa: 0x{hex(content)} !\n")
        else:
            print("\nPrograma cargado exitosamente.")
            
            
def print_results():
    print_registers()
    print_memory()
    
def print_registers():
    for i in range(0, 32):
        type, _, addr, content = uart.read()
        
        if type == uart.ERROR_PREFIX:
            print(f"\nError al ejecutar el programa: 0x{hex(content)} !\n")
            break
        else:
            print(f"Registro ({addr}): 0x{hex(content)}")

def print_memory():
    for i in range(0, 32):
        type, _, addr, content = uart.read()
        
        if type == uart.ERROR_PREFIX:
            print(f"\nError al ejecutar el programa: 0x{hex(content)} !\n")
            break
        else:
            print(f"Memoria ({hex(addr)}): 0x{hex(content)}")
    
signal.signal(signal.SIGINT, sigint_handler)

if __name__ == "__main__":
    parser = asmParser(instructionTable, registerTable, 4)
    
    signal.signal(signal.SIGINT, sigint_handler)

    clear_screen()
    serial_port = select_port()
    clear_screen()
    baudrate = select_baudrate()
    clear_screen()
    
    uart = Uart(serial_port, baudrate)
    mips_handler = MipsHandler(uart)
    
    while True:           
        option = main_menu()
        
        if option == 1:
            compile_program()
        elif option == 2:
            clear_screen()
            mips_handler.execute_program()
            print_results()
            
        elif option == 3:
            clear_screen()
            uart.delete_load_program()
            print("Programa eliminado exitosamente.")
        elif option == 4:
            clear_screen(False)
            
            print("\nPrograma finalizado.\n")
            
            if uart.serial_port:
                uart.serial_port.close()
                
            sys.exit(0)
        
        input("\nPresione una tecla para continuar...")
