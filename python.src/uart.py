import serial
import serial.tools.list_ports
import time

serial_port_name = None
serial_port = None
baudrate = None

def init():
    global serial_port_name, serial_port, baudrate
     
    serial_port_name = select_port()
    baudrate = select_baudrate()
    
    serial_port = serial.Serial(port=serial_port_name,
                                baudrate=baudrate,
                                parity=serial.PARITY_NONE,
                                stopbits=serial.STOPBITS_ONE,
                                bytesize=serial.EIGHTBITS)
    
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
            
def write(data_to_send):
    serial_port.write(data_to_send)
    hex_representation = hex(data_to_send)[2:].zfill(2)
    print(hex_representation, end=' ')

def read():
    return serial_port.read(7)