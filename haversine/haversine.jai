f64 :: float64;

Point_Pair :: struct 
{
    x0, y0: f64;
    x1, y1: f64;
}

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

