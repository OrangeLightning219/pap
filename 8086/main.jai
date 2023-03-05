#import "Basic";
#import "File";

Mode_Field :: enum u8
{
    MODE_00 :: 0b00;
    MODE_01 :: 0b01;
    MODE_10 :: 0b10;
    MODE_11 :: 0b11;
    
    MEMORY_MODE_0 :: MODE_00;
    MEMORY_MODE_8 :: MODE_01;
    MEMORY_MODE_16 :: MODE_10;
    REGISTER_MODE :: MODE_11;
}

Register_Field :: enum u8
{
    REG_000 :: 0b000;
    REG_001 :: 0b001;
    REG_010 :: 0b010;
    REG_011 :: 0b011;
    REG_100 :: 0b100;
    REG_101 :: 0b101;
    REG_110 :: 0b110;
    REG_111 :: 0b111;
}

RM_Field :: enum u8
{
    RM_000 :: 0b000;
    RM_001 :: 0b001;
    RM_010 :: 0b010;
    RM_011 :: 0b011;
    RM_100 :: 0b100;
    RM_101 :: 0b101;
    RM_110 :: 0b110;
    RM_111 :: 0b111;
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

Move_Masks :: enum 
{
    DEFAULT_MOVE :: 0b111111_00;
    IMMEDIATE_TO_MEMORY :: 0b1111111_0;
    IMMEDIATE_TO_REGISTER :: 0b1111_0000;
    MEMORY_TO_ACCUMULATOR :: 0b1111111_0;
    ACCUMULATOR_TO_MEMORY :: 0b1111111_0;
    TO_SEGMENT_REGISTER :: 0b11111111;
    FROM_SEGMENT_REGISTER :: 0b11111111;
}

Move_Ops :: enum 
{
    DEFAULT_MOVE :: 0b100010_00;
    IMMEDIATE_TO_MEMORY :: 0b1100011_0;
    IMMEDIATE_TO_REGISTER :: 0b1011_0000;
    MEMORY_TO_ACCUMULATOR :: 0b1010000_0;
    ACCUMULATOR_TO_MEMORY :: 0b1010001_0;
    TO_SEGMENT_REGISTER :: 0b10001110;
    FROM_SEGMENT_REGISTER :: 0b10001100;
}

get_next_byte :: inline ( file: *string ) -> u8
{
    result := file.data[ 0 ];
    advance( file, 1 );
    return result;
}

get_next_word :: inline ( file: *string ) -> u16
{
    result := <<( cast( *u16 )file.data );
    advance( file, 2 );
    return result;
}

sign_extend :: inline ( value: u8 ) -> s16
{
    if value & 0b1000_0000
    {
        extension: s16 = 0xFF00;
        return extension | value;
    }
    return value;
}

get_value :: inline ( file: *string, is_wide: bool ) -> s16
{
    if is_wide
    {
        return <<( cast( *s16 ) * get_next_word( file ) );
    }
    else 
    {
        return sign_extend( get_next_byte( file ) );
    }
}

calculate_address :: ( file: *string, mode: Mode_Field, rm: RM_Field ) -> string
{
    offset: s16 = 0;
    if mode != .MEMORY_MODE_0
    {
        offset = get_value( file, mode == .MEMORY_MODE_16 );
    }
    
    address := "";
    if rm == 
    {
    case .RM_000;
        address = "bx + si";
    case .RM_001;
        address = "bx + di";
    case .RM_010;
        address = "bp + si";
    case .RM_011;
        address = "bp + di";
    case .RM_100;
        address = "si";
    case .RM_101;
        address = "di";
    case .RM_110;
        if mode == .MEMORY_MODE_0
        {
            address = tprint( "%", get_value( file, true ) );
        }
        else 
        {
            address = "bp";
        }
    case .RM_111;
        address = "bx";
    }
    if offset == 0 { address = tprint( "[%]", address ); }
    else if offset < 0 { address = tprint( "[% - %]", address, offset * -1 ); }
    else { address = tprint( "[% + %]", address, offset ); }
    
    return address;
}

main :: ()
{
    args := get_command_line_arguments();
    
    move_ops_type_info := type_info( Move_Ops );
    move_masks_type_info := type_info( Move_Masks );
    
    for 1..args.count - 1
    {
        filename := args[ it ];
        file_to_disassemble := read_entire_file( filename );
        file := *file_to_disassemble;
        
        print( "; %\n", filename );
        print( "bits 16\n" );
        
        while file_to_disassemble.count > 0
        {
            byte := get_next_byte( file );
            
            for mask64: move_masks_type_info.values
            {
                mask := cast( u8 )mask64;
                test_op := cast( Move_Ops )move_ops_type_info.values[ it_index ];
                op := cast( Move_Ops )( byte & mask );
                if op != test_op {  continue; }
                
                if op == 
                {
                case .DEFAULT_MOVE;
                    D_MASK :: 0b00000010;
                    W_MASK :: 0b00000001;
                    MOD_MASK :: 0b11000000;
                    REG_MASK :: 0b00111000;
                    RM_MASK :: 0b00000111;
                    reg_is_destination := byte & D_MASK != 0;
                    is_wide := byte & W_MASK != 0;
                    
                    byte = get_next_byte( file );
                    
                    mode := cast( Mode_Field )( ( byte & MOD_MASK ) >> 6 );
                    reg := cast( Register_Field )( ( byte & REG_MASK ) >> 3 );
                    
                    destination: string;
                    source: string;
                    if mode == .REGISTER_MODE
                    {
                        rm := cast( Register_Field )( byte & RM_MASK );
                        reg_string := get_register_name( reg, is_wide );
                        rm_string := get_register_name( rm, is_wide );
                        destination = ifx reg_is_destination then reg_string else rm_string;
                        source = ifx reg_is_destination then rm_string else reg_string;
                    }
                    else 
                    {
                        rm := cast( RM_Field )( byte & RM_MASK );
                        
                        address := calculate_address( file, mode, rm );
                        
                        reg_string := get_register_name( reg, is_wide );
                        destination = ifx reg_is_destination then reg_string else address;
                        source = ifx reg_is_destination then address else reg_string;
                    }
                    print( "mov %, %\n", destination, source );
                    break mask64;
                case .IMMEDIATE_TO_MEMORY;
                    W_MASK :: 0b00000001;
                    MOD_MASK :: 0b11000000;
                    RM_MASK :: 0b00000111;
                    is_wide := byte & W_MASK != 0;
                    
                    byte = get_next_byte( file );
                    
                    mode := cast( Mode_Field )( ( byte & MOD_MASK ) >> 6 );
                    
                    if mode != .REGISTER_MODE
                    {
                        rm := cast( RM_Field )( byte & RM_MASK );
                        
                        address := calculate_address( file, mode, rm );
                        data := get_value( file, is_wide );
                        
                        print( "mov %, % %\n", address, ifx is_wide then "word" else "byte", data );
                    }
                    else 
                    {
                        assert( false );
                    }
                    break mask64;
                case .IMMEDIATE_TO_REGISTER;
                    W_MASK :: 0b00001000;
                    REG_MASK :: 0b00000111;
                    
                    is_wide := byte & W_MASK != 0;
                    data: s16 = get_value( file, is_wide );
                    reg := cast( Register_Field )( byte & REG_MASK );
                    
                    print( "mov %, %\n", get_register_name( reg, is_wide ), data );
                    break mask64;
                case .MEMORY_TO_ACCUMULATOR;  #through;
                case .ACCUMULATOR_TO_MEMORY;
                    W_MASK :: 0b00000001;
                    is_wide := byte & W_MASK != 0;
                    data := get_value( file, is_wide );
                    if op == .MEMORY_TO_ACCUMULATOR
                    {
                        print( "mov %, [%]\n", ifx is_wide then "ax" else "al", data );
                    }
                    else 
                    {
                        print( "mov [%], %\n", data, ifx is_wide then "ax" else "al" );
                    }
                    break mask64;
                }
            }
        }
    }
}
