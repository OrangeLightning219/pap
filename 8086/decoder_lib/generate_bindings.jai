
#import "Basic";
#import "Compiler";
#import "Bindings_Generator";
#import "String";

#run main();

main :: ()
{
    set_build_options_dc( .{ do_output = false } );
    
    options := get_build_options();
    if !generate_bindings()
    {
        compiler_set_workspace_status( .FAILED );
        return;
    }
}

#assert ( OS == .WINDOWS ); // windows only for now

generate_bindings :: () -> bool
{
    output_filename: string;
    opts: Generate_Bindings_Options;
    {
        using opts;
        
        #if OS == .WINDOWS
        {
            output_filename = "8086_decoder.jai";
            strip_flags = 0;
        }
        
        // cl -LD -DHB_DLL_EXPORT ../harfbuzz.cc
        array_add( *libpaths, "." );
        array_add( *libnames, "sim86_shared_debug" );
        array_add( *system_include_paths, GENERATOR_DEFAULT_SYSTEM_INCLUDE_PATH );
        array_add( *source_files, "sim86_shared.h" );
    }
    
    return generate_bindings( opts, output_filename );
}
