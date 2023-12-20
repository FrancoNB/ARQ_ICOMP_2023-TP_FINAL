from uart import Uart
import time
from enum import Enum, auto

class ExecutionsModes(Enum):
    BY_STEPS = auto()
    DEBUG = auto()
    RELEASE = auto()
    
RESPONSE_SIZE_BYTES  = 7

RESPONSE_TYPE_MASK   = 0xff000000000000
RESPONSE_CICLE_MASK  = 0x00ff0000000000
RESPONSE_ADDR_MASK   = 0x0000ff00000000
RESPONSE_DATA_MASK   = 0x000000ffffffff

FILD_BYTE                = 0x00

COMMAND_LOAD_PROGRAM     = 0x4C
COMMAND_EXECUTE          = 0x45
COMMAND_EXECUTE_BY_STEPS = 0x53
COMMAND_EXECUTE_DEBUG    = 0x44
COMMAND_DELETE           = 0x46
COMMAND_NEXT_STEP        = 0x4E
COMMAND_STOP_EXECUTION   = 0x53

ERROR_PREFIX = 0xff
INFO_PREFIX  = 0x00

RESPONSE_INFO_END_PROGRAM  = 0x00000001
RESPONSE_INFO_LOAD_PROGRAM = 0x00000010

class MipsHandler():
    uart = None
    registers = None
    memory = None
    
    in_step_execution_mode = False
    
    def __init__(self, uart: Uart):
        self.uart = uart
    
    def _read_response(self):
        if (self.uart.available(RESPONSE_SIZE_BYTES)):
            response = self.uart.read(RESPONSE_SIZE_BYTES)
            
            response_type  = (response & RESPONSE_TYPE_MASK)  >> 56
            response_cicle = (response & RESPONSE_CICLE_MASK) >> 48
            response_addr  = (response & RESPONSE_ADDR_MASK)  >> 40
            response_data  = (response & RESPONSE_DATA_MASK)
            
            return response_type, response_cicle, response_addr, response_data
        else:
            return None, None, None, None
        
    def _read_registers(self):
        for _ in range(0, 32):
            type, cicle, addr, content = self._read_response()
            
            if type == ERROR_PREFIX:
                raise Exception(f"Error al ejecutar el programa: 0x{hex(content)} !")
            else:
                self.registers.append({cicle, addr, content})
                
    def _read_memory(self):       
        for _ in range(0, 32):
            type, cicle, addr, content = self._read_response()
            
            if type == ERROR_PREFIX:
                raise Exception(f"Error al ejecutar el programa: 0x{hex(content)} !")
            else:
                self.memory.append({cicle, addr, content})
    
    def _send_command(self, command: int):
        self.uart.write(command)
        self.uart.write(FILD_BYTE)
        self.uart.write(FILD_BYTE)
        self.uart.write(FILD_BYTE)
        time.sleep(0.1)
          
    def load_program(self, instructions: list):
        self._send_command(COMMAND_LOAD_PROGRAM)
        
        type, _, _, data = self._read_response()
        
        if type != None:
            raise Exception(f"Error al cargar el programa: 0x{hex(data)} !")
        
        for i in range (0, len(instructions), 4):
            for j in range (3, -1, -1):
                index = i+j
                if (index < len(instructions)):
                    self.uart.write(int(instructions[index], 16), byteorder='big')
                else: 
                    break
                
        type, _, _, data = self._read_response()
        
        if type == ERROR_PREFIX:
            raise Exception(f"Error al cargar el programa: 0x{hex(data)} !")
        
    def execute_program(self, mode: ExecutionsModes) -> bool:
        self.registers = []
        self.memory = []
        
        self.in_step_execution_mode = False
        
        if mode == ExecutionsModes.BY_STEPS:
            self._send_command(COMMAND_EXECUTE_BY_STEPS)
            self.in_step_execution_mode = True
        elif mode == ExecutionsModes.DEBUG:
            self._send_command(COMMAND_EXECUTE_DEBUG)
        elif mode == ExecutionsModes.RELEASE:
            self._send_command(COMMAND_EXECUTE)
        else:
            raise Exception(f"Modo de ejecución no soportado: {mode} !")

        type, _, _, data = self._read_response()
        
        if type != None:
            raise Exception(f"Error al ejecutar el programa: 0x{hex(data)} !")
        
        while True:
            self._read_registers()
            self._read_memory()
            
            type, _, _, data = self._read_response()
            
            if type == ERROR_PREFIX:
                raise Exception(f"Error al ejecutar el programa: 0x{hex(data)} !")
            elif type == INFO_PREFIX:
                if data == RESPONSE_INFO_END_PROGRAM:
                    return True

            if mode != ExecutionsModes.DEBUG:
                break
            
        return False
    
    def execute_program_next_step(self) -> bool:
        if not self.in_step_execution_mode:
            raise Exception(f"El programa no se está ejecutando en modo paso a paso !")
            
        self._send_command(COMMAND_NEXT_STEP)
        
        type, _, _, data = self._read_response()
        
        if type != None:
            raise Exception(f"Error al ejecutar el paso: 0x{hex(data)} !")
        
        self._read_registers()
        self._read_memory()
        
        type, _, _, data = self._read_response()
        
        if type == ERROR_PREFIX:
            raise Exception(f"Error al ejecutar el paso: 0x{hex(data)} !")
        elif type == INFO_PREFIX:
            if data == RESPONSE_INFO_END_PROGRAM:
                return True
        
        return False
    
    def execute_program_stop(self):
        if not self.in_step_execution_mode:
            raise Exception(f"El programa no se está ejecutando en modo paso a paso !")
            
        self._send_command(COMMAND_STOP_EXECUTION)
        
        type, _, _, data = self._read_response()
        
        if type != None:
            raise Exception(f"Error al detener la ejecución: 0x{hex(data)} !")
        
    def delete_program(self):
        self._send_command(COMMAND_DELETE)
        
        type, _, _, data = self._read_response()
        
        if type != None:
            raise Exception(f"Error al eliminar el programa: 0x{hex(data)} !")
        
    def get_registers(self):
        return self.registers
    
    def get_memory(self):
        return self.memory
    
    def get_registers_by_cicle(self, cicle: int):
        return list(filter(lambda register: register['cicle'] == cicle, self.registers))
    
    def get_memory_by_cicle(self, cicle: int):
        return list(filter(lambda memory: memory['cicle'] == cicle, self.memory))
    
    def get_registers_by_addr(self, addr: int):
        return list(filter(lambda register: register['addr'] == addr, self.registers))
    
    def get_memory_by_addr(self, addr: int):
        return list(filter(lambda memory: memory['addr'] == addr, self.memory))
    
    def get_registers_by_cicle_and_addr(self, cicle: int, addr: int):
        return list(filter(lambda register: register['cicle'] == cicle and register['addr'] == addr, self.registers))
    
    def get_memory_by_cicle_and_addr(self, cicle: int, addr: int):
        return list(filter(lambda memory: memory['cicle'] == cicle and memory['addr'] == addr, self.memory))
    
    def get_register_summary(self, addr: int):
        summary = []
        
        last_cicle = self.registers.index(self.registers.count() - 1)[0]
        
        for cicle in range(1, last_cicle):
            prev_cicle_registers = self.get_memory_by_cicle_and_addr(cicle - 1, addr)
            cicle_registers = self.get_memory_by_cicle_and_addr(cicle, addr)
            
            for register in cicle_registers:
                if register['content'] != prev_cicle_registers[register['addr']]['content']:
                    summary.append(register)
                    
        return summary
    
    def get_memory_summary(self, addr: int):
        summary = []
        
        last_cicle = self.memory.index(self.memory.count() - 1)[0]
        
        for cicle in range(1, last_cicle):
            prev_cicle_memory = self.get_memory_by_cicle_and_addr(cicle - 1, addr)
            cicle_memory = self.get_memory_by_cicle_and_addr(cicle, addr)
            
            for memory in cicle_memory:
                if memory['content'] != prev_cicle_memory[memory['addr']]['content']:
                    summary.append(memory)
                    
        return summary