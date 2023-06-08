#import "Basic";
#import "Math";
#import "File";

#load "random.jai";

f64 :: float64;

degrees_to_radians :: inline ( degrees: f64 ) -> f64
{
    return degrees * ( TAU64 / 360.0 );
}

reference_haversine :: ( x0: f64, y0: f64, x1: f64, y1: f64, radius: f64 ) -> f64
{
    lat1 := y0;
    lat2 := y1;
    lon1 := x0;
    lon2 := x1;
    
    d_lat := degrees_to_radians( lat2 - lat1 );
    d_lon := degrees_to_radians( lon2 - lon1 );
    lat1 = degrees_to_radians( lat1 );
    lat2 = degrees_to_radians( lat2 );
    
    a := square( sin( d_lat / 2.0 ) ) + cos( lat1 ) * cos( lat2 ) * square( sin( d_lon / 2.0 ) );
    c := 2.0 * asin( sqrt( a ) );
    
    result := radius * c;
    return result;
}

Point_Pair :: struct 
{
    x0, y0: f64;
    x1, y1: f64;
}

main :: ()
{
    context.print_style.default_format_float.trailing_width = 20;
    context.print_style.default_format_float.mode = .SHORTEST;
    
    args := get_command_line_arguments();
    
    if args.count < 3
    {
        print( "Usage: haversine-generator [seed] [pair_count]\n" );
        return;
    }
    
    seed := string_to_int( args[ 1 ] );
    pair_count := string_to_int( args[ 2 ] );
    
    // print( "Seed: %, Point count: %\n", seed, pair_count );
    
    random_seed( cast( u64 )seed );
    
    CLUSTER_COUNT :: 16;
    pairs: [ .. ]Point_Pair;
    
    assert( pair_count >= CLUSTER_COUNT );
    pairs_per_cluster := cast( int )( pair_count / CLUSTER_COUNT );
    
    for 1..CLUSTER_COUNT
    {
        center_x := random_within_range( -180, 180 );
        center_y := random_within_range( -90, 90 );
        
        max_radius_x := min( 180 - center_x, 180 + center_x );
        max_radius_y := min( 90 - center_y, 90 + center_y );
        
        radius_x := random_within_range( 0, max_radius_x );
        radius_y := random_within_range( 0, max_radius_y );
        
        // print( "Cluster: %, x: %, y: %, rx: %, ry: %\n", it, center_x, center_y, radius_x, radius_y );
        
        for 1..pairs_per_cluster
        {
            x0 := random_within_range( center_x - radius_x, center_x + radius_x );
            y0 := random_within_range( center_y - radius_y, center_y + radius_y );
            x1 := random_within_range( center_x - radius_x, center_x + radius_x );
            y1 := random_within_range( center_y - radius_y, center_y + radius_y );
            array_add( *pairs, .{ x0, y0, x1, y1 } );
            // print( "  Points: x0: %, y0: %, x1: %, y1: %\n", x0, y0, x1, y1 );
        }
    }
    
    remaining_pairs := pair_count - CLUSTER_COUNT * pairs_per_cluster;
    if remaining_pairs > 0
    {
        for 1..remaining_pairs
        {
            x0 := random_within_range( -180, 180 );
            y0 := random_within_range( -90, 90 );
            x1 := random_within_range( -180, 180 );
            y1 := random_within_range( -90, 90 );
            array_add( *pairs, .{ x0, y0, x1, y1 } );
        }
    }
    
    JSON_FORMAT := #string DONE
{
    "pairs": [
%
    ]
}
DONE;
    
    PAIR_FORMAT_WITH_COMMA :: #string DONE
        {"x0":%, "y0":%, "x1":%, "y1":%},
DONE;
    PAIR_FORMAT_WITHOUT_COMMA := #string DONE
        {"x0":%, "y0":%, "x1":%, "y1":%}
DONE;
    PAIR_FORMAT_WITHOUT_COMMA.count -= 1;
    
    builder: String_Builder;
    pair_format := PAIR_FORMAT_WITH_COMMA;
    
    distances: [ .. ]f64;
    distance_sum: f64 = 0.0;
    
    for pairs
    {
        if it_index == pairs.count - 1
        {
            pair_format = PAIR_FORMAT_WITHOUT_COMMA;
        }
        using it;
        distance := reference_haversine( x0, y0, x1, y1, 6372.8 );
        distance_sum += distance;
        array_add( *distances, distance );
        print_to_builder( *builder, pair_format, x0, y0, x1, y1 );
    }
    
    result_builder: String_Builder;
    print_to_builder( *result_builder, JSON_FORMAT, builder_to_string( *builder ) );
    result := builder_to_string( *result_builder );
    
    write_entire_file( "haversine_input.json", result );
    
    distances_string: string;
    distances_string.data = cast( *u8 )distances.data;
    distances_string.count = distances.count * size_of( f64 );
    
    write_entire_file( "haversine_input.f64", distances_string );
    
    print( "Total paris generated: %\n", pairs.count );
    print( "Distance average: %\n", distance_sum / pairs.count );
}
