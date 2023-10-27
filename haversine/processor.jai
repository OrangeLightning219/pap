#import "Basic";
#import "File";
#import "File_Utilities";
#import "Math";
#import "Hash_Table";
#import "Reflection";

#load "haversine.jai";
#load "platform_metrics.jai";
#load "profiler.jai";

PROFILER_ENABLED :: true;

main :: ()
{
    begin_profiling();
    
    args := get_command_line_arguments();
    
    if args.count < 2
    {
        print( "Usage: haversine-processor [input_file] [answer_file]" );
        return;
    }
    
    input_file := args[ 1 ];
    answer_file: string;
    if args.count > 2
    {
        answer_file = args[ 2 ];
    }
    
    file_to_parse, ok := read_entire_file( input_file );
    if !ok
    {
        print( "Error reading input file.\n" );
        return;
    }
    
    input := parse_json( file_to_parse );
    
    answers: []f64;
    
    if answer_file
    {
        answer_data := read_entire_file( answer_file );
        answers.data = cast( *f64 )answer_data.data;
        time, size := file_modtime_and_size( answer_file );
        answers.count = size / size_of( f64 );
        assert( answers.count == input.count );
    }
    
    sum: f64 = 0.0;
    answer_sum: f64 = 0.0;
    {
        PROFILE_SCOPE( "Haversine" );
        for input
        {
            PROFILE_SCOPE( "haversine loop" );
            using it;
            distance := reference_haversine( x0, y0, x1, y1, 6372.8 );
            sum += distance;
            if answers
            {
                answer_sum += answers[ it_index ];
            }
        }
    }
    
    average := sum / cast( f64 )input.count;
    
    print( "Average distance: %\n", average );
    if answers
    {
        print( "Answers diff: %\n", abs( average - ( answer_sum / cast( f64 )input.count ) ) );
    }
    
    context.print_style.default_format_float.trailing_width = 2;
    context.print_style.default_format_float.zero_removal = .NO;
    
    // context.print_style.default_format_int.minimum_digits = 15;
    // context.print_style.default_format_int.padding = #char " ";
    
    // context.print_style.default_format_float.mode = .SHORTEST;
    end_profiling();
}

parse_json :: ( input: string ) -> []Point_Pair
{
    PROFILE_FUNCTION();
    result: [ .. ]Point_Pair;
    
    parsing := true;
    tokenizer := input;
    
    expect_token :: ( type: Token_Type, expected_text := "" ) -> Token #expand 
    {
        token := get_token( *`tokenizer );
        // print( "token: %  expected: %\n", token.text, type );
        assert( token.type == type );
        if expected_text
        {
            assert( token == expected_text );
        }
        return token;
    }
    
    expect_token( .OBJECT_START );
    expect_token( .STRING, "pairs" );
    expect_token( .COLON );
    expect_token( .ARRAY_START );
    
    while true
    {
        expect_token( .OBJECT_START );
        
        pair: Point_Pair;
        
        expect_token( .STRING, "x0" );
        expect_token( .COLON );
        token := expect_token( .NUMBER );
        pair.x0 = string_to_float64( token.text );
        expect_token( .COMMA );
        
        expect_token( .STRING, "y0" );
        expect_token( .COLON );
        token = expect_token( .NUMBER );
        pair.y0 = string_to_float64( token.text );
        expect_token( .COMMA );
        
        expect_token( .STRING, "x1" );
        expect_token( .COLON );
        token = expect_token( .NUMBER );
        pair.x1 = string_to_float64( token.text );
        expect_token( .COMMA );
        
        expect_token( .STRING, "y1" );
        expect_token( .COLON );
        token = expect_token( .NUMBER );
        pair.y1 = string_to_float64( token.text );
        
        expect_token( .OBJECT_END );
        
        array_add( *result, pair );
        // print( "%\n", pair );
        
        token = get_token( *tokenizer );
        if token.type == .ARRAY_END then break;
        assert( token.type == .COMMA );
    }
    
    expect_token( .OBJECT_END );
    
    return result;
}

is_whitespace :: inline ( c: u8 ) -> bool
{
    result := c == #char " " || c == #char "\t" || c == #char "\\" || c == #char "\n" || c == #char "\r";
    return result;
}

eat_all_whitespace :: ( tokenizer: *string )
{
    while true
    {
        if is_whitespace( tokenizer.data[ 0 ] )
        {
            advance( tokenizer );
        }
        else 
        {
            break;
        }
    }
}

Token_Type :: enum 
{
    UNKNOWN;
    
    OBJECT_START; // {
    OBJECT_END; // }
    
    ARRAY_START; // [
    ARRAY_END; //]
    
    COLON;
    COMMA;
    
    STRING;
    NUMBER;
    
    END_OF_STREAM;
}

Token :: struct 
{
    type: Token_Type;
    text: string;
}

operator == :: ( a: Token, b: Token ) -> bool #symmetric 
{
    return a.type == b.type && a.text == b.text;
}

operator == :: ( a: Token, b: string ) -> bool #symmetric 
{
    return a.text == b;
}

get_token :: ( tokenizer: *string ) -> Token
{
    eat_all_whitespace( tokenizer );
    
    result: Token;
    result.text.count = 1;
    result.text.data = tokenizer.data;
    
    c := <<tokenizer.data;
    if tokenizer.count > 0
    {
        advance( tokenizer );
    }
    else 
    {
        result.type = .END_OF_STREAM;
        return result;
    }
    
    if c == 
    {
    case #char "["; result.type = .ARRAY_START;
    case #char "]"; result.type = .ARRAY_END;
    case #char "{"; result.type = .OBJECT_START;
    case #char "}"; result.type = .OBJECT_END;
    case #char ","; result.type = .COMMA;
    case #char ":"; result.type = .COLON;
        
    case #char "\"";
        result.type = .STRING;
        while tokenizer.data[ 0 ] && tokenizer.data[ 0 ] != #char "\""
        {
            if tokenizer.data[ 0 ] == #char "\\" && tokenizer.data[ 1 ]
            {
                advance( tokenizer );
            }
            advance( tokenizer );
        }
        
        if tokenizer.data[ 0 ] == #char "\""
        {
            advance( tokenizer );
        }
        result.text.count = tokenizer.data - result.text.data - 2;
        result.text.data += 1;
        
    case;
        if is_digit( c ) || c == #char "-"
        {
            result.type = .NUMBER;
            
            while is_digit( tokenizer.data[ 0 ] )
            {
                advance( tokenizer );
            }
            
            if tokenizer.data[ 0 ] == #char "."
            {
                advance( tokenizer );
                while is_digit( tokenizer.data[ 0 ] )
                {
                    advance( tokenizer );
                }
            }
            
            if tokenizer.data[ 0 ] == #char "e"
            {
                advance( tokenizer );
                if tokenizer.data[ 0 ] == #char "-"
                {
                    advance( tokenizer );
                }
                while is_digit( tokenizer.data[ 0 ] )
                {
                    advance( tokenizer );
                }
            }
            
            result.text.count = tokenizer.data - result.text.data;
        }
        else 
        {
            result.type = .UNKNOWN;
        }
    }
    
    return result;
}
