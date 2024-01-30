#import "Basic";
#import "Hash_Table";

#load "profiler.jai";
#load "platform_metrics.jai";
#load "repetition_tester.jai";

PROFILER_ENABLED :: true;

f64 :: float64;

/*

00007FF76F222BA0  48 8b 57 08  mov   rdx, qword ptr [rdi+0x8]
00007FF76F222BA4  88 0c 11     mov   byte ptr [rcx+rdx*1], cl
00007FF76F222BA7  48 ff c1     inc   rcx
00007FF76F222BAA  48 39 c1     cmp   rcx, rax
00007FF76F222BAD  7e f1        jle   0x7ff76f222ba0 <write_to_all_bytes+0x200>

    Total 15 bytes

    4.7  GHz boost    -> 4.42 gb/s -> 0.99 cycles/loop
    3.65 GHz no boost -> 3.46 gb/s -> 0.98 cycles/loop
    
*/
loop_lib :: #library,no_dll "../build/loop";
mov_all_bytes_asm :: ( count: u64, data: *u8 ) #foreign loop_lib;
cmp_all_bytes_asm :: ( count: u64 ) #foreign loop_lib;
dec_all_bytes_asm :: ( count: u64 ) #foreign loop_lib;
nop_1x3_all_bytes_asm :: ( count: u64 ) #foreign loop_lib;
nop_3x1_all_bytes_asm :: ( count: u64 ) #foreign loop_lib;
nop_1x9_all_bytes_asm :: ( count: u64 ) #foreign loop_lib;

read_unroll_lib :: #library,no_dll "../build/read_unroll";
read_x1_asm :: ( count: u64, data: *u8 ) #foreign read_unroll_lib;
read_x2_asm :: ( count: u64, data: *u8 ) #foreign read_unroll_lib;
read_x3_asm :: ( count: u64, data: *u8 ) #foreign read_unroll_lib;
read_x4_asm :: ( count: u64, data: *u8 ) #foreign read_unroll_lib;

write_unroll_lib :: #library,no_dll "../build/write_unroll";
write_x1_asm :: ( count: u64, data: *u8 ) #foreign write_unroll_lib;
write_x2_asm :: ( count: u64, data: *u8 ) #foreign write_unroll_lib;
write_x3_asm :: ( count: u64, data: *u8 ) #foreign write_unroll_lib;
write_x4_asm :: ( count: u64, data: *u8 ) #foreign write_unroll_lib;

#insert ->string { 
    template :: #string END
% :: ( tester: *Repetition_Tester, buffer: string )
{
    while is_testing( tester )
    {
        begin_time( tester );
        %
        end_time( tester );
        
        count_bytes( tester, xx buffer.count );
    }
}
END;
    write_to_all_bytes := #string END
        for 0..buffer.count - 1
        {
            buffer.data[ it ] = cast,trunc( u8 )it;
        }
    END;
    mov_all_bytes := "mov_all_bytes_asm(xx buffer.count, buffer.data);";
    cmp_all_bytes := "cmp_all_bytes_asm(xx buffer.count);";
    dec_all_bytes := "dec_all_bytes_asm(xx buffer.count);";
    nop_1x3_all_bytes := "nop_1x3_all_bytes_asm(xx buffer.count);";
    nop_3x1_all_bytes := "nop_3x1_all_bytes_asm(xx buffer.count);";
    nop_1x9_all_bytes := "nop_1x9_all_bytes_asm(xx buffer.count);";
    
    builder: String_Builder;
    print_to_builder( *builder, template, "write_to_all_bytes", write_to_all_bytes );
    print_to_builder( *builder, template, "mov_all_bytes", mov_all_bytes );
    print_to_builder( *builder, template, "cmp_all_bytes", cmp_all_bytes );
    print_to_builder( *builder, template, "dec_all_bytes", dec_all_bytes );
    print_to_builder( *builder, template, "nop_1x3_all_bytes", nop_1x3_all_bytes );
    print_to_builder( *builder, template, "nop_3x1_all_bytes", nop_3x1_all_bytes );
    print_to_builder( *builder, template, "nop_1x9_all_bytes", nop_1x9_all_bytes );
    
    read_x1 := "read_x1_asm(xx buffer.count, buffer.data);";
    read_x2 := "read_x2_asm(xx buffer.count, buffer.data);";
    read_x3 := "read_x3_asm(xx buffer.count, buffer.data);";
    read_x4 := "read_x4_asm(xx buffer.count, buffer.data);";
    
    print_to_builder( *builder, template, "read_x1", read_x1 );
    print_to_builder( *builder, template, "read_x2", read_x2 );
    print_to_builder( *builder, template, "read_x3", read_x3 );
    print_to_builder( *builder, template, "read_x4", read_x4 );
    
    write_x1 := "write_x1_asm(xx buffer.count, buffer.data);";
    write_x2 := "write_x2_asm(xx buffer.count, buffer.data);";
    write_x3 := "write_x3_asm(xx buffer.count, buffer.data);";
    write_x4 := "write_x4_asm(xx buffer.count, buffer.data);";
    
    print_to_builder( *builder, template, "write_x1", write_x1 );
    print_to_builder( *builder, template, "write_x2", write_x2 );
    print_to_builder( *builder, template, "write_x3", write_x3 );
    print_to_builder( *builder, template, "write_x4", write_x4 );
    
    return builder_to_string( *builder );
}

Test_Function :: struct 
{
    name: string;
    func: ( *Repetition_Tester, string );
}

functions_to_test :: Test_Function.[ 
                                     // .{ "write_to_all_bytes", write_to_all_bytes }, 
                                     // .{ "mov_all_bytes", mov_all_bytes }, 
                                     // .{ "cmp_all_bytes", cmp_all_bytes }, 
                                     // .{ "dec_all_bytes", dec_all_bytes }, 
                                     // .{ "nop_1x3_all_bytes", nop_1x3_all_bytes }, 
                                     // .{ "nop_3x1_all_bytes", nop_3x1_all_bytes }, 
                                     // .{ "nop_1x9_all_bytes", nop_1x9_all_bytes }, 
                                     
                                     // .{ "read_x1", read_x1 }, 
                                     // .{ "read_x2", read_x2 }, 
                                     // .{ "read_x3", read_x3 }, 
                                     // .{ "read_x4", read_x4 }, 
                                     
                                     .{ "write_x1", write_x1 }, 
                                     .{ "write_x2", write_x2 }, 
                                     .{ "write_x3", write_x3 }, 
                                     .{ "write_x4", write_x4 }, 
                                      ];
main :: ()
{
    begin_profiling();
    
    testers: [ functions_to_test.count ]Repetition_Tester;
    
    buffer_size := 1024 * 1024 * 1024;
    buffer: string;
    
    buffer.data = alloc( buffer_size );
    buffer.count = buffer_size;
    
    // mov_all_bytes_asm( xx buffer.count, buffer.data );
    // nop_all_bytes_asm( xx buffer.count );
    // cmp_all_bytes_asm( xx buffer.count );
    // dec_all_bytes_asm( xx buffer.count );
    for functions_to_test
    {
        tester := *testers[ it_index ];
        print( "\n--- % ---\n", it.name );
        new_test_wave( tester, xx buffer_size );
        it.func( tester, buffer );
    }
    
    end_profiling();
}
