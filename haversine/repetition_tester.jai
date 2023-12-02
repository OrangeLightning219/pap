Test_Mode :: enum 
{
    UNINITIALIZED;
    TESTING;
    COMPLETED;
    ERROR;
}

Repetition_Test_Results :: struct 
{
    test_count: u64;
    total_time: u64;
    max_time: u64;
    min_time: u64;
}

Repetition_Tester :: struct 
{
    target_processed_byte_count: u64;
    try_for_time: u64;
    tests_started_at: u64;
    
    mode: Test_Mode;
    print_new_minimums: bool;
    open_block_count: u32;
    close_block_count: u32;
    time_accumulated_on_this_test: u64;
    bytes_accumulated_on_this_test: u64;
    
    results: Repetition_Test_Results;
}

print_time :: ( label: string, time: u64, byte_count: u64 )
{
    print_time( label, cast( f64 )time, byte_count );
}

print_time :: ( label: string, time: f64, byte_count: u64 )
{
    print( "%: % (%ms)", label, time, cpu_time_to_milliseconds( time ) );
    
    if byte_count
    {
        gigabyte := 1024.0 * 1024.0 * 1024.0;
        bandwidth := byte_count / ( gigabyte * cpu_time_to_seconds( time ) );
        print( " %gb/s", bandwidth );
    }
}

print_results :: ( results: Repetition_Test_Results, byte_count: u64 )
{
    print_time( "Min", results.min_time, byte_count );
    print( "\n" );
    print_time( "Max", results.max_time, byte_count );
    print( "\n" );
    
    if results.test_count
    {
        print_time( "Avg", cast( f64 )results.total_time / cast( f64 )results.test_count, byte_count );
        print( "\n" );
    }
}

error :: ( tester: *Repetition_Tester, message: string )
{
    tester.mode = .ERROR;
    print( "ERROR: %\n", message );
}

new_test_wave :: ( tester: *Repetition_Tester, target_processed_byte_count: u64, seconds_to_try: u64 = 10 )
{
    if tester.mode == .UNINITIALIZED
    {
        tester.mode = .TESTING;
        tester.target_processed_byte_count = target_processed_byte_count;
        tester.print_new_minimums = true;
        tester.results.min_time = 0xFFFFFFFFFFFFFFFF;
    }
    else if tester.mode == .COMPLETED
    {
        tester.mode = .TESTING;
        
        if tester.target_processed_byte_count != target_processed_byte_count
        {
            error( tester, "target_processed_byte_count changed" );
        }
    }
    
    tester.try_for_time = seconds_to_try * context.profiler.cpu_frequency;
    tester.tests_started_at = get_cpu_time();
}

begin_time :: ( tester: *Repetition_Tester )
{
    tester.open_block_count += 1;
    tester.time_accumulated_on_this_test -= get_cpu_time();
}

end_time :: ( tester: *Repetition_Tester )
{
    tester.close_block_count += 1;
    tester.time_accumulated_on_this_test += get_cpu_time();
}

count_bytes :: ( tester: *Repetition_Tester, byte_count: u64 )
{
    tester.bytes_accumulated_on_this_test += byte_count;
}

is_testing :: ( tester: *Repetition_Tester ) -> bool
{
    if tester.mode == .TESTING
    {
        current_time := get_cpu_time();
        
        if tester.open_block_count
        {
            if tester.open_block_count != tester.close_block_count then error( tester, "Unbalanced begin_time/end_time" );
            if tester.bytes_accumulated_on_this_test != tester.target_processed_byte_count then error( tester, "Processed byte count mismatch" );
            
            if tester.mode == .TESTING
            {
                results := *tester.results;
                elapsed_time := tester.time_accumulated_on_this_test;
                results.test_count += 1;
                results.total_time += elapsed_time;
                
                if results.max_time < elapsed_time
                {
                    results.max_time = elapsed_time;
                }
                
                if results.min_time > elapsed_time
                {
                    results.min_time = elapsed_time;
                    
                    tester.tests_started_at = current_time;
                    
                    if tester.print_new_minimums
                    {
                        print_time( "Min", results.min_time, tester.bytes_accumulated_on_this_test );
                        print( "                                                           \r" );
                    }
                }
                
                tester.open_block_count = 0;
                tester.close_block_count = 0;
                tester.time_accumulated_on_this_test = 0;
                tester.bytes_accumulated_on_this_test = 0;
            }
        }
        
        if current_time - tester.tests_started_at > tester.try_for_time
        {
            tester.mode = .COMPLETED;
            print( "                                                           \r" );
            print_results( tester.results, tester.target_processed_byte_count );
        }
    }
    
    return tester.mode == .TESTING;
}
