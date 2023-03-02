#import "Basic";
#import "File";

Mode_Field :: enum 
{
    MODE_00 :: 0b00_000000;
    MODE_01 :: 0b01_000000;
    MODE_10 :: 0b10_000000;
    MODE_11 :: 0b11_000000;
    
    MEMORY_MODE :: 0b00_000000;
    MEMORY_MODE_8 :: 0b01_000000;
    MEMORY_MODE_16 :: 0b10_000000;
    REGISTER_MODE :: 0b11_000000;
}

Register_Field :: enum u8
{
    REG_000 :: 0b00_000_000;
    REG_001 :: 0b00_001_000;
    REG_010 :: 0b00_010_000;
    REG_011 :: 0b00_011_000;
    REG_100 :: 0b00_100_000;
    REG_101 :: 0b00_101_000;
    REG_110 :: 0b00_110_000;
    REG_111 :: 0b00_111_000;
}

get_register_name :: inline ( bit_value: Register_Field, is_wide: bool ) -> string
{
    if #complete bit_value == 
    {
    case .REG_000;  return ifx is_wide then "ax" else "al";
    case .REG_001;  return ifx is_wide then "cx" else "cl";
    case .REG_010;  return ifx is_wide then "dx" else "dl";
    case .REG_011;  return ifx is_wide then "bx" else "bl";
    case .REG_100;  return ifx is_wide then "sp" else "ah";
    case .REG_101;  return ifx is_wide then "bp" else "ch";
    case .REG_110;  return ifx is_wide then "si" else "dh";
    case .REG_111;  return ifx is_wide then "di" else "bh";
    }
    return "invalid";
}

main :: ()
{
    args := get_command_line_arguments();
    
    for 1..args.count - 1
    {
        filename := args[ it ];
        file_to_disassemble := read_entire_file( filename );
        
        print( "; %\n", filename );
        print( "bits 16\n" );
        
        OP_CODE_MASK :: 0b11111100;
        D_MASK :: 0b00000010;
        W_MASK :: 0b00000001;
        MOD_MASK :: 0b11000000;
        REG_MASK :: 0b00111000;
        RM_MASK :: 0b00000111;
        
        MOV_CODE :: 0b10001000;
        
        index := 0;
        while index < file_to_disassemble.count
        {
            byte := file_to_disassemble.data[ index ];
            if byte & OP_CODE_MASK == MOV_CODE
            {
                reg_is_destination := byte & D_MASK != 0;
                is_wide := byte & W_MASK != 0;
                
                index += 1;
                byte = file_to_disassemble.data[ index ];
                
                mode := cast( Mode_Field )byte & MOD_MASK;
                reg := cast( Register_Field )byte & REG_MASK;
                
                if mode == .REGISTER_MODE
                {
                    rm := cast( Register_Field )( ( byte & RM_MASK ) << 3 );
                    destination := ifx reg_is_destination then reg else rm;
                    source := ifx reg_is_destination then rm else reg;
                    print( "mov %, %\n", get_register_name( destination, is_wide ), get_register_name( source, is_wide ) );
                }
                else 
                {
                    assert( false );
                }
            }
            
            index += 1;
        }
    }
}
