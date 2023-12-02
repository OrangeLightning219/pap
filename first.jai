
#import "Basic";
#import "Compiler";

build :: ()
{
    // build_program( "8086/main.jai", "8086-sim" );
    // build_program( "haversine/generator.jai", "haversine-generator", true );
    build_program( "haversine/processor.jai", "haversine-processor", true );
    build_program( "haversine/processor.jai", "haversine-processor-debug", false );
    build_program( "haversine/tests.jai", "tests", true );
    build_program( "haversine/tests.jai", "tests-debug", false );
    
    set_build_options_dc( .{ do_output = false } );
}

build_program :: ( main_file: string, exe_name: string, optimized: bool = false )
{
    print( "Building: %\n", main_file );
    w := compiler_create_workspace( exe_name );
    if !w
    {
        print( "Workspace % creation failed.\n", exe_name );
        return;
    }
    
    options := get_build_options( w );
    options.output_executable_name = exe_name;
    options.output_path = "build";
    
    args := options.compile_time_command_line;
    
    if optimized
    {
        set_optimization( *options, .VERY_OPTIMIZED );
    }
    
    set_build_options( options, w );
    
    compiler_begin_intercept( w );
    
    add_build_file( main_file, w );
    
    compiler_end_intercept( w );
}

#run build();
