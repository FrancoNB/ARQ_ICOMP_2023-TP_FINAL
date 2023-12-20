import curses
import os
import serial
from serial.tools import list_ports
from mips_handler import MipsHandler
from asm_parser import asmParser
from uart import Uart
from tables import instructionTable, registerTable

def get_terminal_width():
    try:
        return os.get_terminal_size().columns
    except OSError:
        return 80
    
def print_centered_title(stdscr):
    console_width = get_terminal_width()

    title = "MIPS User Interface"
    spaces_before = (console_width - len(title) - 2) // 2
    spaces_after = console_width - len(title) - spaces_before - 2

    border_line = "-" * console_width

    stdscr.clear()
    stdscr.addstr(0, 0, border_line, curses.color_pair(2))
    stdscr.addstr(1, 0, "-" + " " * spaces_before, curses.color_pair(2))
    stdscr.addstr(title, curses.color_pair(2))
    stdscr.addstr(" " * spaces_after + "-", curses.color_pair(2))
    stdscr.addstr(2, 0, border_line, curses.color_pair(2))

def print_baud_rate_menu(stdscr, options, current_row):
    stdscr.clear()
    print_centered_title(stdscr)

    stdscr.addstr(4, 0, "Seleccione el Baud Rate")

    for i, option in enumerate(options):
        x = 2
        y = i + 6
        if i == current_row:
            stdscr.addstr(y, x, f"> {option}", curses.color_pair(1) | curses.A_BOLD)
        else:
            stdscr.addstr(y, x, f"  {option}", curses.color_pair(1))

def print_serial_ports_menu(stdscr, ports, current_row):
    stdscr.clear()
    print_centered_title(stdscr)

    stdscr.addstr(4, 0, "Seleccione el Puerto Serie")

    for i, port in enumerate(ports):
        x = 2
        y = i + 6
        if i == current_row:
            stdscr.addstr(y, x, f"> {port}", curses.color_pair(1) | curses.A_BOLD)
        else:
            stdscr.addstr(y, x, f"  {port}", curses.color_pair(1))

def get_baud_rate(stdscr):
    baud_rates = [9600, 19200, 38400, 57600, 115200]
    options = [f"{i + 1}. {rate} bps" for i, rate in enumerate(baud_rates)]
    current_row = 0

    while True:
        print_baud_rate_menu(stdscr, options, current_row)
        key = stdscr.getch()

        if key == curses.KEY_UP and current_row > 0:
            current_row -= 1
        elif key == curses.KEY_DOWN and current_row < len(options) - 1:
            current_row += 1
        elif key == curses.KEY_ENTER or key in [10, 13]:
            return baud_rates[current_row]

def select_serial_port(stdscr):
    ports = get_serial_ports()
    current_row = 0

    while True:
        print_serial_ports_menu(stdscr, ports, current_row)
        key = stdscr.getch()

        if key == curses.KEY_UP and current_row > 0:
            current_row -= 1
        elif key == curses.KEY_DOWN and current_row < len(ports) - 1:
            current_row += 1
        elif key == curses.KEY_ENTER or key in [10, 13]:
            return ports[current_row]

def get_serial_ports():
    try:
        ports = list_ports.comports()
        return [port.device for port in ports]
    except serial.SerialException:
        return []

def init_curses():
    curses.curs_set(0)

    curses.start_color()

    curses.init_pair(1, curses.COLOR_WHITE, curses.COLOR_BLACK)
    curses.init_pair(2, curses.COLOR_WHITE, curses.COLOR_BLACK)

def main_menu(stdscr, serial_port, baud_rate):
    current_row = 0
    menu_options = ["1. Cargar programa", "2. Ejecutar programa", "3. Ejecutar programa por pasos", "4. Ejecutar modo debug", 
                    "5. Eliminar programa","6. Salir"]

    uart = Uart(serial_port, baud_rate)
    mips_handler = MipsHandler(uart)
    parser = asmParser(instructionTable, registerTable, 4)

    while True:
        key = stdscr.getch()

        if key == curses.KEY_UP and current_row > 0:
            current_row -= 1
        elif key == curses.KEY_DOWN and current_row < len(menu_options) - 1:
            current_row += 1
        elif key == curses.KEY_ENTER or key in [10, 13]:
            if current_row == 0:
                load_program(parser)
            elif current_row == 1:
                run_normal_mode_program()
            elif current_row == 2:
                run_step_mode_program()
            elif current_row == 3:
                run_debug_mode_program()
            elif current_row == 4:
                delete_program()
            elif current_row == 5:
                break

def load_program(parser: asmParser):
    program_path = input("Ingrese la ruta del programa a cargar")

    file = open(program_path, "r")
    lines = file.readlines()

    result = parser.firstPass(lines)

    if result != 0:
        print("Error en el primer pase")
    
    return

def run_normal_mode_program(mips_handler: MipsHandler):
    return

def run_step_mode_program(mips_handler: MipsHandler):
    return

def run_debug_mode_program(mips_handler: MipsHandler):
    return

def delete_program(mips_handler: MipsHandler):
    return

def main(stdscr):
    init_curses()
    
    serial_port = select_serial_port(stdscr)
    baud_rate = get_baud_rate(stdscr)

    main_menu(stdscr, serial_port, baud_rate)
    

if __name__ == "__main__":
    uart = None
    mips_handler = None
    parser = None

    curses.wrapper(main)
