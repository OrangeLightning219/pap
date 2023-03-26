//
// This file was auto-generated using the following command:
//
// jai ./generate_bindings.jai
//



s8 :: u8;

b32 :: s32;

operation_type :: enum u32 {
    None    :: 0;

    mov     :: 1;

    push    :: 2;

    pop     :: 3;

    xchg    :: 4;

    in      :: 5;

    out     :: 6;

    xlat    :: 7;
    lea     :: 8;
    lds     :: 9;
    les     :: 10;
    lahf    :: 11;
    sahf    :: 12;
    pushf   :: 13;
    popf    :: 14;

    add     :: 15;

    adc     :: 16;

    inc     :: 17;

    aaa     :: 18;
    daa     :: 19;

    sub     :: 20;

    sbb     :: 21;

    dec     :: 22;

    neg     :: 23;

    cmp     :: 24;

    aas     :: 25;
    das     :: 26;
    mul     :: 27;
    imul    :: 28;
    aam     :: 29;
    div     :: 30;
    idiv    :: 31;
    aad     :: 32;
    cbw     :: 33;
    cwd     :: 34;

    not     :: 35;
    shl     :: 36;
    shr     :: 37;
    sar     :: 38;
    rol     :: 39;
    ror     :: 40;
    rcl     :: 41;
    rcr     :: 42;

    and     :: 43;

    test    :: 44;

    or      :: 45;

    xor     :: 46;

    rep     :: 47;
    movs    :: 48;
    cmps    :: 49;
    scas    :: 50;
    lods    :: 51;
    stos    :: 52;

    call    :: 53;

    jmp     :: 54;

    ret     :: 55;

    retf    :: 56;

    je      :: 57;
    jl      :: 58;
    jle     :: 59;
    jb      :: 60;
    jbe     :: 61;
    jp      :: 62;
    jo      :: 63;
    js      :: 64;
    jne     :: 65;
    jnl     :: 66;
    jg      :: 67;
    jnb     :: 68;
    ja      :: 69;
    jnp     :: 70;
    jno     :: 71;
    jns     :: 72;
    loop    :: 73;
    loopz   :: 74;
    loopnz  :: 75;
    jcxz    :: 76;

    int     :: 77;
    int3    :: 78;

    into    :: 79;
    iret    :: 80;

    clc     :: 81;
    cmc     :: 82;
    stc     :: 83;
    cld     :: 84;
    std     :: 85;
    cli     :: 86;
    sti     :: 87;
    hlt     :: 88;
    wait    :: 89;
    esc     :: 90;
    lock    :: 91;
    segment :: 92;

    Count   :: 93;

    Op_None    :: None;

    Op_mov     :: mov;

    Op_push    :: push;

    Op_pop     :: pop;

    Op_xchg    :: xchg;

    Op_in      :: in;

    Op_out     :: out;

    Op_xlat    :: xlat;
    Op_lea     :: lea;
    Op_lds     :: lds;
    Op_les     :: les;
    Op_lahf    :: lahf;
    Op_sahf    :: sahf;
    Op_pushf   :: pushf;
    Op_popf    :: popf;

    Op_add     :: add;

    Op_adc     :: adc;

    Op_inc     :: inc;

    Op_aaa     :: aaa;
    Op_daa     :: daa;

    Op_sub     :: sub;

    Op_sbb     :: sbb;

    Op_dec     :: dec;

    Op_neg     :: neg;

    Op_cmp     :: cmp;

    Op_aas     :: aas;
    Op_das     :: das;
    Op_mul     :: mul;
    Op_imul    :: imul;
    Op_aam     :: aam;
    Op_div     :: div;
    Op_idiv    :: idiv;
    Op_aad     :: aad;
    Op_cbw     :: cbw;
    Op_cwd     :: cwd;

    Op_not     :: not;
    Op_shl     :: shl;
    Op_shr     :: shr;
    Op_sar     :: sar;
    Op_rol     :: rol;
    Op_ror     :: ror;
    Op_rcl     :: rcl;
    Op_rcr     :: rcr;

    Op_and     :: and;

    Op_test    :: test;

    Op_or      :: or;

    Op_xor     :: xor;

    Op_rep     :: rep;
    Op_movs    :: movs;
    Op_cmps    :: cmps;
    Op_scas    :: scas;
    Op_lods    :: lods;
    Op_stos    :: stos;

    Op_call    :: call;

    Op_jmp     :: jmp;

    Op_ret     :: ret;

    Op_retf    :: retf;

    Op_je      :: je;
    Op_jl      :: jl;
    Op_jle     :: jle;
    Op_jb      :: jb;
    Op_jbe     :: jbe;
    Op_jp      :: jp;
    Op_jo      :: jo;
    Op_js      :: js;
    Op_jne     :: jne;
    Op_jnl     :: jnl;
    Op_jg      :: jg;
    Op_jnb     :: jnb;
    Op_ja      :: ja;
    Op_jnp     :: jnp;
    Op_jno     :: jno;
    Op_jns     :: jns;
    Op_loop    :: loop;
    Op_loopz   :: loopz;
    Op_loopnz  :: loopnz;
    Op_jcxz    :: jcxz;

    Op_int     :: int;
    Op_int3    :: int3;

    Op_into    :: into;
    Op_iret    :: iret;

    Op_clc     :: clc;
    Op_cmc     :: cmc;
    Op_stc     :: stc;
    Op_cld     :: cld;
    Op_std     :: std;
    Op_cli     :: cli;
    Op_sti     :: sti;
    Op_hlt     :: hlt;
    Op_wait    :: wait;
    Op_esc     :: esc;
    Op_lock    :: lock;
    Op_segment :: segment;

    Op_Count   :: Count;
}

instruction_flag :: enum u32 {
    Lock    :: 1;
    Rep     :: 2;
    Segment :: 4;
    Wide    :: 8;
    Far     :: 16;

    Inst_Lock    :: Lock;
    Inst_Rep     :: Rep;
    Inst_Segment :: Segment;
    Inst_Wide    :: Wide;
    Inst_Far     :: Far;
}

register_access :: struct {
    Index:  u32;
    Offset: u32;
    Count:  u32;
}
#run {
    instance: register_access;
    assert(((cast(*void)(*instance.Index)) - cast(*void)(*instance)) == 0, "register_access.Index has unexpected offset % instead of 0", ((cast(*void)(*instance.Index)) - cast(*void)(*instance)));
    assert(size_of(type_of(register_access.Index)) == 4, "register_access.Index has unexpected size % instead of 4", size_of(type_of(register_access.Index)));
    assert(((cast(*void)(*instance.Offset)) - cast(*void)(*instance)) == 4, "register_access.Offset has unexpected offset % instead of 4", ((cast(*void)(*instance.Offset)) - cast(*void)(*instance)));
    assert(size_of(type_of(register_access.Offset)) == 4, "register_access.Offset has unexpected size % instead of 4", size_of(type_of(register_access.Offset)));
    assert(((cast(*void)(*instance.Count)) - cast(*void)(*instance)) == 8, "register_access.Count has unexpected offset % instead of 8", ((cast(*void)(*instance.Count)) - cast(*void)(*instance)));
    assert(size_of(type_of(register_access.Count)) == 4, "register_access.Count has unexpected size % instead of 4", size_of(type_of(register_access.Count)));
    assert(size_of(register_access) == 12, "register_access has size % instead of 12", size_of(register_access));
}

effective_address_term :: struct {
    Register: register_access;
    Scale:    s32;
}
#run {
    instance: effective_address_term;
    assert(((cast(*void)(*instance.Register)) - cast(*void)(*instance)) == 0, "effective_address_term.Register has unexpected offset % instead of 0", ((cast(*void)(*instance.Register)) - cast(*void)(*instance)));
    assert(size_of(type_of(effective_address_term.Register)) == 12, "effective_address_term.Register has unexpected size % instead of 12", size_of(type_of(effective_address_term.Register)));
    assert(((cast(*void)(*instance.Scale)) - cast(*void)(*instance)) == 12, "effective_address_term.Scale has unexpected offset % instead of 12", ((cast(*void)(*instance.Scale)) - cast(*void)(*instance)));
    assert(size_of(type_of(effective_address_term.Scale)) == 4, "effective_address_term.Scale has unexpected size % instead of 4", size_of(type_of(effective_address_term.Scale)));
    assert(size_of(effective_address_term) == 16, "effective_address_term has size % instead of 16", size_of(effective_address_term));
}

effective_address_flag :: enum u32 {
    Address_ExplicitSegment :: 1;
}

effective_address_expression :: struct {
    Terms:           [2] effective_address_term;
    ExplicitSegment: u32;
    Displacement:    s32;
    Flags:           u32;
}
#run {
    instance: effective_address_expression;
    assert(((cast(*void)(*instance.Terms)) - cast(*void)(*instance)) == 0, "effective_address_expression.Terms has unexpected offset % instead of 0", ((cast(*void)(*instance.Terms)) - cast(*void)(*instance)));
    assert(size_of(type_of(effective_address_expression.Terms)) == 32, "effective_address_expression.Terms has unexpected size % instead of 32", size_of(type_of(effective_address_expression.Terms)));
    assert(((cast(*void)(*instance.ExplicitSegment)) - cast(*void)(*instance)) == 32, "effective_address_expression.ExplicitSegment has unexpected offset % instead of 32", ((cast(*void)(*instance.ExplicitSegment)) - cast(*void)(*instance)));
    assert(size_of(type_of(effective_address_expression.ExplicitSegment)) == 4, "effective_address_expression.ExplicitSegment has unexpected size % instead of 4", size_of(type_of(effective_address_expression.ExplicitSegment)));
    assert(((cast(*void)(*instance.Displacement)) - cast(*void)(*instance)) == 36, "effective_address_expression.Displacement has unexpected offset % instead of 36", ((cast(*void)(*instance.Displacement)) - cast(*void)(*instance)));
    assert(size_of(type_of(effective_address_expression.Displacement)) == 4, "effective_address_expression.Displacement has unexpected size % instead of 4", size_of(type_of(effective_address_expression.Displacement)));
    assert(((cast(*void)(*instance.Flags)) - cast(*void)(*instance)) == 40, "effective_address_expression.Flags has unexpected offset % instead of 40", ((cast(*void)(*instance.Flags)) - cast(*void)(*instance)));
    assert(size_of(type_of(effective_address_expression.Flags)) == 4, "effective_address_expression.Flags has unexpected size % instead of 4", size_of(type_of(effective_address_expression.Flags)));
    assert(size_of(effective_address_expression) == 44, "effective_address_expression has size % instead of 44", size_of(effective_address_expression));
}

immediate_flag :: enum u32 {
    Immediate_RelativeJumpDisplacement :: 1;
}

immediate :: struct {
    Value: s32;
    Flags: u32;
}
#run {
    instance: immediate;
    assert(((cast(*void)(*instance.Value)) - cast(*void)(*instance)) == 0, "immediate.Value has unexpected offset % instead of 0", ((cast(*void)(*instance.Value)) - cast(*void)(*instance)));
    assert(size_of(type_of(immediate.Value)) == 4, "immediate.Value has unexpected size % instead of 4", size_of(type_of(immediate.Value)));
    assert(((cast(*void)(*instance.Flags)) - cast(*void)(*instance)) == 4, "immediate.Flags has unexpected offset % instead of 4", ((cast(*void)(*instance.Flags)) - cast(*void)(*instance)));
    assert(size_of(type_of(immediate.Flags)) == 4, "immediate.Flags has unexpected size % instead of 4", size_of(type_of(immediate.Flags)));
    assert(size_of(immediate) == 8, "immediate has size % instead of 8", size_of(immediate));
}

operand_type :: enum u32 {
    None      :: 0;
    Register  :: 1;
    Memory    :: 2;
    Immediate :: 3;

    Operand_None      :: None;
    Operand_Register  :: Register;
    Operand_Memory    :: Memory;
    Operand_Immediate :: Immediate;
}

instruction_operand :: struct {
    Type: operand_type;
    union {
        Address:   effective_address_expression;
        Register:  register_access;
        Immediate: immediate;
    }
}
#run {
    instance: instruction_operand;
    assert(((cast(*void)(*instance.Type)) - cast(*void)(*instance)) == 0, "instruction_operand.Type has unexpected offset % instead of 0", ((cast(*void)(*instance.Type)) - cast(*void)(*instance)));
    assert(size_of(type_of(instruction_operand.Type)) == 4, "instruction_operand.Type has unexpected size % instead of 4", size_of(type_of(instruction_operand.Type)));
    assert(size_of(instruction_operand) == 48, "instruction_operand has size % instead of 48", size_of(instruction_operand));
}

instruction :: struct {
    Address:         u32;
    Size:            u32;

    Op:              operation_type;
    Flags:           u32;

    Operands:        [2] instruction_operand;

    SegmentOverride: u32;
}
#run {
    instance: instruction;
    assert(((cast(*void)(*instance.Address)) - cast(*void)(*instance)) == 0, "instruction.Address has unexpected offset % instead of 0", ((cast(*void)(*instance.Address)) - cast(*void)(*instance)));
    assert(size_of(type_of(instruction.Address)) == 4, "instruction.Address has unexpected size % instead of 4", size_of(type_of(instruction.Address)));
    assert(((cast(*void)(*instance.Size)) - cast(*void)(*instance)) == 4, "instruction.Size has unexpected offset % instead of 4", ((cast(*void)(*instance.Size)) - cast(*void)(*instance)));
    assert(size_of(type_of(instruction.Size)) == 4, "instruction.Size has unexpected size % instead of 4", size_of(type_of(instruction.Size)));
    assert(((cast(*void)(*instance.Op)) - cast(*void)(*instance)) == 8, "instruction.Op has unexpected offset % instead of 8", ((cast(*void)(*instance.Op)) - cast(*void)(*instance)));
    assert(size_of(type_of(instruction.Op)) == 4, "instruction.Op has unexpected size % instead of 4", size_of(type_of(instruction.Op)));
    assert(((cast(*void)(*instance.Flags)) - cast(*void)(*instance)) == 12, "instruction.Flags has unexpected offset % instead of 12", ((cast(*void)(*instance.Flags)) - cast(*void)(*instance)));
    assert(size_of(type_of(instruction.Flags)) == 4, "instruction.Flags has unexpected size % instead of 4", size_of(type_of(instruction.Flags)));
    assert(((cast(*void)(*instance.Operands)) - cast(*void)(*instance)) == 16, "instruction.Operands has unexpected offset % instead of 16", ((cast(*void)(*instance.Operands)) - cast(*void)(*instance)));
    assert(size_of(type_of(instruction.Operands)) == 96, "instruction.Operands has unexpected size % instead of 96", size_of(type_of(instruction.Operands)));
    assert(((cast(*void)(*instance.SegmentOverride)) - cast(*void)(*instance)) == 112, "instruction.SegmentOverride has unexpected offset % instead of 112", ((cast(*void)(*instance.SegmentOverride)) - cast(*void)(*instance)));
    assert(size_of(type_of(instruction.SegmentOverride)) == 4, "instruction.SegmentOverride has unexpected size % instead of 4", size_of(type_of(instruction.SegmentOverride)));
    assert(size_of(instruction) == 116, "instruction has size % instead of 116", size_of(instruction));
}

instruction_bits_usage :: enum u8 {
    End          :: 0;

    Literal      :: 1;

    D            :: 2;
    S            :: 3;
    W            :: 4;
    V            :: 5;
    Z            :: 6;
    MOD          :: 7;
    REG          :: 8;
    RM           :: 9;
    SR           :: 10;
    Disp         :: 11;
    Data         :: 12;

    DispAlwaysW  :: 13;
    WMakesDataW  :: 14;
    RMRegAlwaysW :: 15;
    RelJMPDisp   :: 16;
    Far          :: 17;

    Count        :: 18;

    Bits_End          :: End;

    Bits_Literal      :: Literal;

    Bits_D            :: D;
    Bits_S            :: S;
    Bits_W            :: W;
    Bits_V            :: V;
    Bits_Z            :: Z;
    Bits_MOD          :: MOD;
    Bits_REG          :: REG;
    Bits_RM           :: RM;
    Bits_SR           :: SR;
    Bits_Disp         :: Disp;
    Bits_Data         :: Data;

    Bits_DispAlwaysW  :: DispAlwaysW;
    Bits_WMakesDataW  :: WMakesDataW;
    Bits_RMRegAlwaysW :: RMRegAlwaysW;
    Bits_RelJMPDisp   :: RelJMPDisp;
    Bits_Far          :: Far;

    Bits_Count        :: Count;
}

instruction_bits :: struct {
    Usage:    instruction_bits_usage;
    BitCount: u8;
    Shift:    u8;
    Value:    u8;
}
#run {
    instance: instruction_bits;
    assert(((cast(*void)(*instance.Usage)) - cast(*void)(*instance)) == 0, "instruction_bits.Usage has unexpected offset % instead of 0", ((cast(*void)(*instance.Usage)) - cast(*void)(*instance)));
    assert(size_of(type_of(instruction_bits.Usage)) == 1, "instruction_bits.Usage has unexpected size % instead of 1", size_of(type_of(instruction_bits.Usage)));
    assert(((cast(*void)(*instance.BitCount)) - cast(*void)(*instance)) == 1, "instruction_bits.BitCount has unexpected offset % instead of 1", ((cast(*void)(*instance.BitCount)) - cast(*void)(*instance)));
    assert(size_of(type_of(instruction_bits.BitCount)) == 1, "instruction_bits.BitCount has unexpected size % instead of 1", size_of(type_of(instruction_bits.BitCount)));
    assert(((cast(*void)(*instance.Shift)) - cast(*void)(*instance)) == 2, "instruction_bits.Shift has unexpected offset % instead of 2", ((cast(*void)(*instance.Shift)) - cast(*void)(*instance)));
    assert(size_of(type_of(instruction_bits.Shift)) == 1, "instruction_bits.Shift has unexpected size % instead of 1", size_of(type_of(instruction_bits.Shift)));
    assert(((cast(*void)(*instance.Value)) - cast(*void)(*instance)) == 3, "instruction_bits.Value has unexpected offset % instead of 3", ((cast(*void)(*instance.Value)) - cast(*void)(*instance)));
    assert(size_of(type_of(instruction_bits.Value)) == 1, "instruction_bits.Value has unexpected size % instead of 1", size_of(type_of(instruction_bits.Value)));
    assert(size_of(instruction_bits) == 4, "instruction_bits has size % instead of 4", size_of(instruction_bits));
}

instruction_encoding :: struct {
    Op:   operation_type;
    Bits: [16] instruction_bits;
}
#run {
    instance: instruction_encoding;
    assert(((cast(*void)(*instance.Op)) - cast(*void)(*instance)) == 0, "instruction_encoding.Op has unexpected offset % instead of 0", ((cast(*void)(*instance.Op)) - cast(*void)(*instance)));
    assert(size_of(type_of(instruction_encoding.Op)) == 4, "instruction_encoding.Op has unexpected size % instead of 4", size_of(type_of(instruction_encoding.Op)));
    assert(((cast(*void)(*instance.Bits)) - cast(*void)(*instance)) == 4, "instruction_encoding.Bits has unexpected offset % instead of 4", ((cast(*void)(*instance.Bits)) - cast(*void)(*instance)));
    assert(size_of(type_of(instruction_encoding.Bits)) == 64, "instruction_encoding.Bits has unexpected size % instead of 64", size_of(type_of(instruction_encoding.Bits)));
    assert(size_of(instruction_encoding) == 68, "instruction_encoding has size % instead of 68", size_of(instruction_encoding));
}

instruction_table :: struct {
    Encodings:               *instruction_encoding;
    EncodingCount:           u32;
    MaxInstructionByteCount: u32;
}
#run {
    instance: instruction_table;
    assert(((cast(*void)(*instance.Encodings)) - cast(*void)(*instance)) == 0, "instruction_table.Encodings has unexpected offset % instead of 0", ((cast(*void)(*instance.Encodings)) - cast(*void)(*instance)));
    assert(size_of(type_of(instruction_table.Encodings)) == 8, "instruction_table.Encodings has unexpected size % instead of 8", size_of(type_of(instruction_table.Encodings)));
    assert(((cast(*void)(*instance.EncodingCount)) - cast(*void)(*instance)) == 8, "instruction_table.EncodingCount has unexpected offset % instead of 8", ((cast(*void)(*instance.EncodingCount)) - cast(*void)(*instance)));
    assert(size_of(type_of(instruction_table.EncodingCount)) == 4, "instruction_table.EncodingCount has unexpected size % instead of 4", size_of(type_of(instruction_table.EncodingCount)));
    assert(((cast(*void)(*instance.MaxInstructionByteCount)) - cast(*void)(*instance)) == 12, "instruction_table.MaxInstructionByteCount has unexpected offset % instead of 12", ((cast(*void)(*instance.MaxInstructionByteCount)) - cast(*void)(*instance)));
    assert(size_of(type_of(instruction_table.MaxInstructionByteCount)) == 4, "instruction_table.MaxInstructionByteCount has unexpected size % instead of 4", size_of(type_of(instruction_table.MaxInstructionByteCount)));
    assert(size_of(instruction_table) == 16, "instruction_table has size % instead of 16", size_of(instruction_table));
}

Sim86_GetVersion :: () -> u32 #foreign sim86_shared_debug;
Sim86_Decode8086Instruction :: (SourceSize: u32, Source: *u8, Dest: *instruction) -> void #foreign sim86_shared_debug;

Sim86_RegisterNameFromOperand :: (RegAccess: *register_access) -> *u8 #foreign sim86_shared_debug;
Sim86_MnemonicFromOperationType :: (Type: operation_type) -> *u8 #foreign sim86_shared_debug;
Sim86_Get8086InstructionTable :: (Dest: *instruction_table) -> void #foreign sim86_shared_debug;

#scope_file

#import "Basic"; // For assert

sim86_shared_debug :: #library "./sim86_shared_debug";
