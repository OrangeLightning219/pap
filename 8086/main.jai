#import "Basic";
#import "File";

#load "decoder_lib/8086_decoder.jai";

Register_Index :: enum 
{
    A :: 0;
    B :: 1;
    C :: 2;
    D :: 3;
    SP :: 4;
    BP :: 5;
    SI :: 6;
    DI :: 7;
    
    ES :: 8;
    CS :: 9;
    SS :: 10;
    DS :: 11;
    // IP :: 12;
}

Register_Flags :: enum_flags 
{
    ZERO;
    SIGN;
}

Sim_State :: struct 
{
    registers: [ 12 ]u16;
    flags: Register_Flags;
    instruction_pointer: s32;
}

main :: ()
{
    print( "Decoder version: %\n", Sim86_GetVersion() );
    
    args := get_command_line_arguments();
    
    for 1..args.count - 1
    {
        filename := args[ it ];
        file_to_disassemble := read_entire_file( filename );
        
        table: instruction_table;
        Sim86_Get8086InstructionTable( *table );
        
        sim_state: Sim_State;
        
        file_size: u32 = cast( u32 )file_to_disassemble.count;
        while sim_state.instruction_pointer < file_to_disassemble.count
        {
            offset := cast( u32 )sim_state.instruction_pointer;
            decoded_instruction: instruction;
            Sim86_Decode8086Instruction( file_size - offset, file_to_disassemble.data + offset, *decoded_instruction );
            if ( decoded_instruction.Op )
            {
                sim_state.instruction_pointer += xx decoded_instruction.Size;
                print_instruction( decoded_instruction );
                excecute_instruction( *sim_state, decoded_instruction );
            }
            else 
            {
                print( "Unrecognized instruction\n" );
                break;
            }
        }
        print_registers( *sim_state );
    }
}

print_registers :: ( state: *Sim_State )
{
    default_format := context.print_style.default_format_int;
    context.print_style.default_format_int.base = 16;
    context.print_style.default_format_int.minimum_digits = 4;
    
    print( "Register state:\n" );
    for state.registers
    {
        print( "%: 0x%\n", cast( Register_Index )it_index, state.registers[ it_index ] );
    }
    print( "Instruction pointer: %\n", state.instruction_pointer );
    context.print_style.default_format_int = default_format;
}

set_register_value :: ( using state: *Sim_State, register: register_access, operand: instruction_operand )
{
    value: u16;
    
    if operand.Type == 
    {
    case operand_type.Operand_Register;
        source_register := operand.Register;
        source := cast( *u8 )( registers.data + source_register.Index - 1 ) + source_register.Offset;
        if source_register.Count == 2
        {
            value = <<cast( *u16 )source;
        }
        else 
        {
            value = cast( u16 ) << source;
        }
        
    case operand_type.Operand_Immediate;
        value = xx operand.Immediate.Value;
    case operand_type.Operand_Memory;
    }
    
    target := cast( *u8 )( registers.data + register.Index - 1 ) + register.Offset;
    
    if register.Count == 2
    {
        <<( cast( *u16 )target ) = value;
    }
    else 
    {
        <<target = cast( u8 )value;
    }
}

get_operands_for_add_sub_cmp :: inline ( using state: *Sim_State, inst: instruction ) -> *u16, u16, u16
{
    first_operand := inst.Operands[ 0 ];
    second_operand := inst.Operands[ 1 ];
    assert( inst.Operands[ 0 ].Type == operand_type.Operand_Register );
    r1 := registers.data + first_operand.Register.Index - 1;
    r2: u16;
    if second_operand.Type == operand_type.Operand_Register
    {
        r2 = registers.data[ second_operand.Register.Index - 1 ];
    }
    else 
    {
        assert( second_operand.Type == operand_type.Operand_Immediate );
        r2 = xx second_operand.Immediate.Value;
    }
    return r1, <<r1, r2;
}

set_flags_for_add_sub_cmp :: inline ( using state: *Sim_State, value: u16 )
{
    if value == 0
    {
        flags |= .ZERO;
    }
    else 
    {
        flags &= ~.ZERO;
    }
    
    if value & 0x8000
    {
        flags |= .SIGN;
    }
    else 
    {
        flags &= ~.SIGN;
    }
}

excecute_instruction :: ( using state: *Sim_State, inst: instruction )
{
    if inst.Op == 
    {
    case operation_type.mov;
        if inst.Operands[ 0 ].Type == operand_type.Operand_Register
        {
            set_register_value( state, inst.Operands[ 0 ].Register, inst.Operands[ 1 ] );
        }
        else 
        {
            print( "invalid operand type\n" );
        }
    case operation_type.add;
        target, v1, v2 := get_operands_for_add_sub_cmp( state, inst );
        <<target = v1 + v2;
        set_flags_for_add_sub_cmp( state, <<target );
    case operation_type.sub;
        target, v1, v2 := get_operands_for_add_sub_cmp( state, inst );
        <<target = v1 - v2;
        set_flags_for_add_sub_cmp( state, <<target );
    case operation_type.cmp;
        target, v1, v2 := get_operands_for_add_sub_cmp( state, inst );
        set_flags_for_add_sub_cmp( state, v1 - v2 );
    case operation_type.jne;
        if !( flags & .ZERO )
        {
            jump_offset := inst.Operands[ 0 ].Immediate.Value;
            instruction_pointer += jump_offset;
        }
    case;
        print( "can't simulate %\n", inst.Op );
    }
    // print( "flags: %\n", flags );
    // print_registers( state );
}

print_instruction :: ( i: instruction )
{
    inst := i;
    flags := inst.Flags;
    w := flags & xx instruction_flag.Inst_Wide;
    
    if flags & xx instruction_flag.Inst_Lock
    {
        if inst.Op == operation_type.Op_xchg
        {
            inst.Operands[ 0 ], inst.Operands[ 1 ] = swap( inst.Operands[ 1 ], inst.Operands[ 0 ] );
        }
        print( "lock " );
    }
    
    mnemonic_suffix := "";
    if flags & xx instruction_flag.Inst_Rep
    {
        print( "rep " );
        mnemonic_suffix = ifx w then "w" else "b";
    }
    
    print( "%1%2 ", to_string( Sim86_MnemonicFromOperationType( inst.Op ) ), mnemonic_suffix );
    
    separator := "";
    for inst.Operands
    {
        if it.Type != operand_type.Operand_None
        {
            print( "%", separator );
            separator = ", ";
            
            if it.Type == 
            {
            case operand_type.Operand_None;
                break;
            case operand_type.Operand_Register;
                print( "%", to_string( Sim86_RegisterNameFromOperand( *it.Register ) ) );
            case operand_type.Operand_Memory;
                address := it.Address;
                
                if flags & xx instruction_flag.Inst_Far
                {
                    print( "far " );
                }
                
                if address.Flags & xx effective_address_flag.Address_ExplicitSegment
                {
                    print( "%:%", address.ExplicitSegment, address.Displacement );
                }
                else 
                {
                    if inst.Operands[ 0 ].Type != operand_type.Operand_Register
                    {
                        print( "% ", ifx w then "word" else "byte" );
                    }
                    
                    if flags & xx instruction_flag.Inst_Segment
                    {
                        reg := register_access.{ inst.SegmentOverride, 0, 2 };
                        print( "%:", to_string( Sim86_RegisterNameFromOperand( *reg ) ) );
                    }
                    
                    print( "[" );
                    print_effective_address_expression( address );
                    print( "]" );
                }
            case operand_type.Operand_Immediate;
                imm := it.Immediate;
                if ( imm.Flags & xx immediate_flag.Immediate_RelativeJumpDisplacement )
                {
                    print( "$%", imm.Value + xx inst.Size );
                }
                else 
                {
                    print( "%", imm.Value );
                }
            }
        }
    }
    print( "\n" );
}

print_effective_address_expression :: ( address: effective_address_expression )
{
    separator := "";
    for address.Terms
    {
        reg := it.Register;
        if reg.Index
        {
            print( "%", separator );
            if it.Scale != 1
            {
                print( "%*", it.Scale );
            }
            print( "%", to_string( Sim86_RegisterNameFromOperand( *reg ) ) );
            separator = "+";
        }
    }
    
    if address.Displacement != 0
    {
        print( "%1%2", separator, address.Displacement );
    }
}
