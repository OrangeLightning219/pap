typedef char unsigned u8;
typedef short unsigned u16;
typedef int unsigned u32;
typedef long long unsigned u64;

typedef char s8;
typedef short s16;
typedef int s32;
typedef long long s64;

typedef s32 b32;

static u32 const SIM86_VERSION = 3;
enum operation_type : u32 {
    Op_None,

    Op_mov,

    Op_push,

    Op_pop,

    Op_xchg,

    Op_in,

    Op_out,

    Op_xlat,
    Op_lea,
    Op_lds,
    Op_les,
    Op_lahf,
    Op_sahf,
    Op_pushf,
    Op_popf,

    Op_add,

    Op_adc,

    Op_inc,

    Op_aaa,
    Op_daa,

    Op_sub,

    Op_sbb,

    Op_dec,

    Op_neg,

    Op_cmp,

    Op_aas,
    Op_das,
    Op_mul,
    Op_imul,
    Op_aam,
    Op_div,
    Op_idiv,
    Op_aad,
    Op_cbw,
    Op_cwd,

    Op_not,
    Op_shl,
    Op_shr,
    Op_sar,
    Op_rol,
    Op_ror,
    Op_rcl,
    Op_rcr,

    Op_and,

    Op_test,

    Op_or,

    Op_xor,

    Op_rep,
    Op_movs,
    Op_cmps,
    Op_scas,
    Op_lods,
    Op_stos,

    Op_call,

    Op_jmp,

    Op_ret,

    Op_retf,

    Op_je,
    Op_jl,
    Op_jle,
    Op_jb,
    Op_jbe,
    Op_jp,
    Op_jo,
    Op_js,
    Op_jne,
    Op_jnl,
    Op_jg,
    Op_jnb,
    Op_ja,
    Op_jnp,
    Op_jno,
    Op_jns,
    Op_loop,
    Op_loopz,
    Op_loopnz,
    Op_jcxz,

    Op_int,
    Op_int3,

    Op_into,
    Op_iret,

    Op_clc,
    Op_cmc,
    Op_stc,
    Op_cld,
    Op_std,
    Op_cli,
    Op_sti,
    Op_hlt,
    Op_wait,
    Op_esc,
    Op_lock,
    Op_segment,

    Op_Count,
};

enum instruction_flag : u32 {
    Inst_Lock = 0x1,
    Inst_Rep = 0x2,
    Inst_Segment = 0x4,
    Inst_Wide = 0x8,
    Inst_Far = 0x10,
};

struct register_access {
    u32 Index;
    u32 Offset;
    u32 Count;
};

struct effective_address_term {
    struct register_access Register;
    s32 Scale;
};

enum effective_address_flag : u32 {
    Address_ExplicitSegment = 0x1,
};
struct effective_address_expression {
    struct effective_address_term Terms[2];
    u32 ExplicitSegment;
    s32 Displacement;
    u32 Flags;
};

enum immediate_flag : u32 {
    Immediate_RelativeJumpDisplacement = 0x1,
};
struct immediate {
    s32 Value;
    u32 Flags;
};

enum operand_type : u32 {
    Operand_None,
    Operand_Register,
    Operand_Memory,
    Operand_Immediate,
};
struct instruction_operand {
    enum operand_type Type;
    union {
        struct effective_address_expression Address;
        struct register_access Register;
        struct immediate Immediate;
    };
};

struct instruction {
    u32 Address;
    u32 Size;

    enum operation_type Op;
    u32 Flags;

    struct instruction_operand Operands[2];

    u32 SegmentOverride;
};
enum instruction_bits_usage : u8 {
    Bits_End,

    Bits_Literal,

    Bits_D,
    Bits_S,
    Bits_W,
    Bits_V,
    Bits_Z,
    Bits_MOD,
    Bits_REG,
    Bits_RM,
    Bits_SR,
    Bits_Disp,
    Bits_Data,

    Bits_DispAlwaysW,
    Bits_WMakesDataW,
    Bits_RMRegAlwaysW,
    Bits_RelJMPDisp,
    Bits_Far,

    Bits_Count,
};

struct instruction_bits {
    enum instruction_bits_usage Usage;
    u8 BitCount;
    u8 Shift;
    u8 Value;
};

struct instruction_encoding {
    enum operation_type Op;
    struct instruction_bits Bits[16];
};

struct instruction_table {
    struct instruction_encoding *Encodings;
    u32 EncodingCount;
    u32 MaxInstructionByteCount;
};

u32 Sim86_GetVersion(void);
void Sim86_Decode8086Instruction(u32 SourceSize, u8 *Source,
                                 struct instruction *Dest);
char const *Sim86_RegisterNameFromOperand(struct register_access *RegAccess);
char const *Sim86_MnemonicFromOperationType(enum operation_type Type);
void Sim86_Get8086InstructionTable(struct instruction_table *Dest);
