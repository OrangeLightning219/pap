Profiler :: struct 
{
    start_time: u64;
    end_time: u64;
    
    points: Table( string, Profile_Point );
    current_parent: *Profile_Point;
    
    cpu_frequency: u64;
}

#add_context profiler: Profiler;

Profile_Point :: struct 
{
    name: string;
    
    own_time: u64; // without children
    total_time: u64; // with children
    
    hit_count: u64;
}

begin_profiling :: ()
{
    using profiler := *context.profiler;
    
    end_time = 0;
    current_parent = null;
    table_reset( *points );
    resize( *points, 4096 );
    cpu_frequency = estimate_cpu_timer_frequency( 100 );
    
    start_time = get_cpu_time();
}

end_profiling :: ()
{
    using profiler := *context.profiler;
    
    end_time = get_cpu_time();
    
    total_time := end_time - start_time;
    print( "Total time: % (%ms)\n", total_time, cpu_time_to_milliseconds( total_time ) );
    for points
    {
        percent := ( cast( f64 )it.own_time / cast( f64 )total_time ) * 100;
        print( "  %[%]: own: % (%%%) [%ms]", it.name, it.hit_count, it.own_time, percent, cpu_time_to_milliseconds( it.own_time ) );
        if it.total_time != it.own_time
        {
            children_percent := ( cast( f64 )it.total_time / cast( f64 )total_time ) * 100;
            print( " %%% with children", children_percent );
        }
        print( "\n" );
    }
}

#if PROFILER_ENABLED
{
    PROFILE_FUNCTION :: PROFILE_SCOPE;
    
    PROFILE_SCOPE :: ( name := "" ) #expand 
    {
        profiler := *context.profiler;
        
        scope_name := ifx name != "" then name else context.stack_trace.info.name;
        point, new := find_or_add( *profiler.points, scope_name );
        
        point.name = scope_name;
        point.hit_count += 1;
        
        parent := profiler.current_parent;
        profiler.current_parent = point;
        
        old_total_time := point.total_time;
        
        start_time := get_cpu_time();
        `defer 
        {
            time := get_cpu_time() - start_time;
            point.own_time += time;
            point.total_time = old_total_time + time;
            if parent
            {
                parent.own_time -= time;
            }
            profiler.current_parent = parent;
        }
    }
}
else 
{
    PROFILE_FUNCTION :: () #expand  { }
    PROFILE_SCOPE :: ( name: string ) #expand  { }
}
