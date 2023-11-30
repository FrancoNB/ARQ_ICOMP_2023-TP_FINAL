`ifndef __CODES_VH__
`define __CODES_VH__

    /** --------------------------- Codes for OP (instruction[31:26]) --------------------------- **/

    `define CODE_OP_R_TYPE  6'b000000 // R-Type instructions                             

    `define CODE_OP_BEQ     6'b000100 // Branch if equal instruction                     
    `define CODE_OP_BNE     6'b000101 // Branch if not equal instruction                     
    `define CODE_OP_J       6'b000010 // Jump instruction                                
    `define CODE_OP_JAL     6'b000011 // Jump and link instruction                       
    `define CODE_OP_LB      6'b100000 // Load byte instruction                           
    `define CODE_OP_LH      6'b100001 // Load halfword instruction                       
    `define CODE_OP_LW      6'b100011 // Load word instruction                           
    `define CODE_OP_LWU     6'b100111 // Load word unsigned instruction                  
    `define CODE_OP_LBU     6'b100100 // Load byte unsigned instruction                  
    `define CODE_OP_LHU     6'b100101 // Load halfword unsigned instruction              
    `define CODE_OP_SB      6'b101000 // Store byte instruction                          
    `define CODE_OP_SH      6'b101001 // Store halfword instruction                      
    `define CODE_OP_SW      6'b101011 // Store word instruction                          
    `define CODE_OP_ADDI    6'b001000 // Add immediate instruction                       
    `define CODE_OP_ANDI    6'b001100 // And immediate instruction                       
    `define CODE_OP_ORI     6'b001101 // Or immediate instruction                        
    `define CODE_OP_XORI    6'b001110 // Xor immediate instruction                       
    `define CODE_OP_LUI     6'b001111 // Load upper immediate instruction                
    `define CODE_OP_SLTI    6'b001010 // Set less than immediate instruction          

    /** --------------------------- Codes for FUNCT (instruction[5:0]) --------------------------- **/   

    `define CODE_FUNCT_JR   6'b001000 // Jump register function                       
    `define CODE_FUNCT_JALR 6'b001001 // Jump and link register function              

    `define CODE_FUNCT_SLL  6'b000000 // Shift left logical function                  
    `define CODE_FUNCT_SRL  6'b000010 // Shift right logical function                 
    `define CODE_FUNCT_SRA  6'b000011 // Shift right arithmetic function              
    `define CODE_FUNCT_ADD  6'b100000 // Add function                                 
    `define CODE_FUNCT_ADDU 6'b100001 // Add unsigned function                        
    `define CODE_FUNCT_SUB  6'b100010 // Subtract function                            
    `define CODE_FUNCT_SUBU 6'b100011 // Subtract unsigned function                   
    `define CODE_FUNCT_AND  6'b100100 // And function                                 
    `define CODE_FUNCT_OR   6'b100101 // Or function                                  
    `define CODE_FUNCT_XOR  6'b100110 // Xor function                                 
    `define CODE_FUNCT_NOR  6'b100111 // Nor function                                 
    `define CODE_FUNCT_SLT  6'b101010 // Set less than function                       
    `define CODE_FUNCT_SLLV 6'b000100 // Shift left logical variable function         
    `define CODE_FUNCT_SRLV 6'b000110 // Shift right logical variable function        
    `define CODE_FUNCT_SRAV 6'b000111 // Shift right arithmetic variable function      

    /** --------------------------- Codes for MAIN control --------------------------- **/   

    `define CODE_MAIN_CTR_NEXT_PC_SRC_SEQ       1'b0  // Sequential
    `define CODE_MAIN_CTR_NEXT_PC_SRC_NOT_SEQ   1'b1  // Not sequential
    `define CODE_MAIN_CTR_NOT_JMP               2'bxx // Not jump
    `define CODE_MAIN_CTR_JMP_DIR               2'b10 // Jump direct
    `define CODE_MAIN_CTR_JMP_REG               2'b01 // Jump register
    `define CODE_MAIN_CTR_JMP_BRANCH            2'b00 // Jump branch
    `define CODE_MAIN_CTR_REG_WRITE_ENABLE      1'b1  // Enable register write
    `define CODE_MAIN_CTR_REG_WRITE_DISABLE     1'b0  // Disable register write
    `define CODE_MAIN_CTR_REG_DST_RD            2'b01 // Register destination is rd
    `define CODE_MAIN_CTR_REG_DST_GPR_31        2'b10 // Register destination is gpr[31]
    `define CODE_MAIN_CTR_REG_DST_RT            2'b00 // Register destination is rt
    `define CODE_MAIN_CTR_REG_DST_NOTHING       2'bxx // Register destination is nothing
    `define CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT 2'b00 // Memory to register is alu result
    `define CODE_MAIN_CTR_MEM_TO_REG_MEM_RESULT 2'b01 // Memory to register is memory result
    `define CODE_MAIN_CTR_MEM_TO_REG_HALF_WORD  2'b10 // Memory to register is half word
    `define CODE_MAIN_CTR_MEM_TO_REG_BYTE       2'b11 // Memory to register is byte
    `define CODE_MAIN_CTR_MEM_TO_REG_NOTHING    2'bxx // Memory to register is nothing
    `define CODE_MAIN_CTR_MEM_WRITE_ENABLE      1'b1  // Enable memory write
    `define CODE_MAIN_CTR_MEM_WRITE_DISABLE     1'b0  // Disable memory write

    /** --------------------------- Codes for ALU control --------------------------- **/

    `define CODE_ALU_CTR_R_TYPE         3'b110 // R-Type instructions
    `define CODE_ALU_CTR_LOAD_TYPE      3'b000 // Load instructions
    `define CODE_ALU_CTR_STORE_TYPE     3'b000 // Store instructions
    `define CODE_ALU_CTR_BRANCH_TYPE    3'b001 // Branch instructions
    `define CODE_ALU_CTR_JUMP_TYPE      3'bxxx // Jump instructions
    `define CODE_ALU_CTR_ADDI           3'b000 // Add immediate instruction
    `define CODE_ALU_CTR_ANDI           3'b010 // And immediate instruction
    `define CODE_ALU_CTR_ORI            3'b011 // Or immediate instruction
    `define CODE_ALU_CTR_XORI           3'b100 // Xor immediate instruction
    `define CODE_ALU_CTR_SLTI           3'b101 // Set less than immediate instruction
    `define CODE_ALU_CTR_UNDEFINED      3'bxxx // Undefined instruction

    `define CODE_ALU_CTR_SRC_A_SHAMT      1'b0  // Shamt
    `define CODE_ALU_CTR_SRC_A_BUS_A      1'b1  // Bus A
    
    `define CODE_ALU_CTR_SRC_B_BUS_B      2'b00  // Bus B
    `define CODE_ALU_CTR_SRC_B_SIG_INM    2'b01  // Sign immediate
    `define CODE_ALU_CTR_SRC_B_USIG_INM   2'b10  // Unsigned immediate
    `define CODE_ALU_CTR_SRC_B_UPPER_INM  2'b11  // Upper immediate
    `define CODE_ALU_CTR_SRC_B_NOTHING    2'bxx  // Nothing
    
    /** --------------------------- Codes for ALU excution --------------------------- **/

    `define CODE_ALU_EX_SLL          4'b0000 // Shift left logical
    `define CODE_ALU_EX_SRL          4'b0001 // Shift right logical
    `define CODE_ALU_EX_SRA          4'b0010 // Shift right arithmetic
    `define CODE_ALU_EX_ADD          4'b0011 // Sum
    `define CODE_ALU_EX_SUB          4'b0100 // Substract 
    `define CODE_ALU_EX_AND          4'b0101 // Logical and
    `define CODE_ALU_EX_OR           4'b0110 // Logical or
    `define CODE_ALU_EX_XOR          4'b0111 // Logical xor
    `define CODE_ALU_EX_NOR          4'b1000 // Logical nor
    `define CODE_ALU_EX_SLT          4'b1001 // Set if less than
    `define CODE_ALU_EX_SLLV         4'b1010 // Shift left logical
    `define CODE_ALU_EX_SRLV         4'b1011 // Shift right logical
    `define CODE_ALU_EX_SRAV         4'b1100 // Shift right arithmetic
    `define CODE_ALU_EX_NEQ          4'b1110 // Equal
    `define CODE_ALU_EX_NOP          4'b1111 // Not operation

`endif // __CODES_VH__