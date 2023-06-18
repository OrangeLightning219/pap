#import "Windows";
#import "Machine_X64";

cpu_frequency: u64 = 0;

get_os_timer_frequency :: inline () -> u64
{
    result: s64 = ---;
    QueryPerformanceFrequency( *result );
    return xx result;
}

get_os_time :: inline () -> u64
{
    result: s64 = ---;
    QueryPerformanceCounter( *result );
    return xx result;
}

get_cpu_time :: inline () -> u64, u64
{
    result := rdtsc();
    result_ms := cast( u64 )( ( result / cast( f64 )cpu_frequency ) * 1000 );
    return result, result_ms;
}

get_cpu_time_ms :: inline () -> u64
{
    assert( cpu_frequency != 0 );
    return cast( u64 )( ( rdtsc() / cast( f64 )cpu_frequency ) * 1000 );
}

estimate_cpu_timer_frequency :: ( milliseconds_to_wait: u64 ) -> u64
{
    os_frequency := get_os_timer_frequency();
    
    cpu_start := get_cpu_time();
    os_start := get_os_time();
    
    os_end: u64 = 0;
    os_elapsed: u64 = 0;
    os_wait_time := os_frequency * milliseconds_to_wait / 1000;
    
    while os_elapsed < os_wait_time
    {
        os_end = get_os_time();
        os_elapsed = os_end - os_start;
    }
    
    cpu_end := get_cpu_time();
    cpu_elapsed := cpu_end - cpu_start;
    
    if os_elapsed > 0
    {
        cpu_frequency = os_frequency * cpu_elapsed / os_elapsed;
    }
    
    return cpu_frequency;
}

cpu_time_to_milliseconds :: ( value: u64 ) -> u64
{
    assert( cpu_frequency != 0 );
    return cast( u64 )( ( value / cast( f64 )cpu_frequency ) * 1000 );
}
