 // ported from http://www.math.sci.hiroshima-u.ac.jp/m-mat/MT/VERSIONS/C-LANG/mt19937-64.c
/* 
   A C-program for MT19937-64 (2004/9/29 version).
   Coded by Takuji Nishimura and Makoto Matsumoto.

   This is a 64-bit version of Mersenne Twister pseudorandom number
   generator.

   Before using, initialize the state by using init_genrand64(seed)  
   or init_by_array64(init_key, key_length).

   Copyright (C) 2004, Makoto Matsumoto and Takuji Nishimura,
   All rights reserved.                          

   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions
   are met:

     1. Redistributions of source code must retain the above copyright
        notice, this list of conditions and the following disclaimer.

     2. Redistributions in binary form must reproduce the above copyright
        notice, this list of conditions and the following disclaimer in the
        documentation and/or other materials provided with the distribution.

     3. The names of its contributors may not be used to endorse or promote 
        products derived from this software without specific prior written 
        permission.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
   A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
   CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
   EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
   PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
   PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
   LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
   NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

   References:
   T. Nishimura, ``Tables of 64-bit Mersenne Twisters''
     ACM Transactions on Modeling and 
     Computer Simulation 10. (2000) 348--357.
   M. Matsumoto and T. Nishimura,
     ``Mersenne Twister: a 623-dimensionally equidistributed
       uniform pseudorandom number generator''
     ACM Transactions on Modeling and 
     Computer Simulation 8. (Jan. 1998) 3--30.

   Any feedback is very welcome.
   http://www.math.hiroshima-u.ac.jp/~m-mat/MT/emt.html
   email: m-mat @ math.sci.hiroshima-u.ac.jp (remove spaces)
*/

NN: u64: 312;
MM :: 156;
MATRIX_A :: 0xB5026F5AA96619E9;
UM :: 0xFFFFFFFF80000000;
LM :: 0x7FFFFFFF;

mt: [ NN ]u64;
mti := NN + 1;

random_seed :: ( seed: u64 )
{
    mt[ 0 ] = seed;
    mti = 1;
    while mti < NN
    {
        mt[ mti ] = ( 6364136223846793005 * ( mt[ mti - 1 ] ^ ( mt[ mti - 1 ] >> 62 ) ) + mti );
        mti += 1;
    }
}

/* generates a random number on [0, 2^64-1]-interval */
random_get_64 :: () -> u64
{
    i: int;
    x: u64;
    mag01: [ 2 ]u64: .[ 0, MATRIX_A ];
    
    if mti >= NN
    {
        if mti == NN + 1
        {
            random_seed( 5489 );
        }
        
        for 0..NN - MM - 1
        {
            x = ( mt[ it ] & UM ) | ( mt[ it + 1 ] & LM );
            mt[ it ] = mt[ it + MM ] ^ ( x >> 1 ) ^ mag01[ cast( int )( x & 1 ) ];
        }
        
        for NN - MM..NN - 2
        {
            x = ( mt[ it ] & UM ) | ( mt[ it + 1 ] & LM );
            mt[ it ] = mt[ it + ( MM - NN ) ] ^ ( x >> 1 ) ^ mag01[ cast( int )( x & 1 ) ];
        }
        
        x = ( mt[ NN - 1 ] & UM ) | ( mt[ 0 ] & LM );
        mt[ NN - 1 ] = mt[ MM - 1 ] ^ ( x >> 1 ) ^ mag01[ cast( int )( x & 1 ) ];
        
        mti = 0;
    }
    
    x = mt[ mti ];
    mti += 1;
    
    x ^= ( x >> 29 ) & 0x5555555555555555;
    x ^= ( x << 17 ) & 0x71D67FFFEDA60000;
    x ^= ( x << 37 ) & 0xFFF7EEE000000000;
    x ^= ( x >> 43 );
    
    return x;
}

/* generates a random number on [0,1]-real-interval */
random_zero_to_one :: () -> f64
{
    result := ( random_get_64() >> 11 ) * ( 1.0 / 9007199254740991.0 );
    return result;
}

random_within_range :: ( min: f64, max: f64 ) -> f64
{
    return min + ( random_zero_to_one() * ( max - min ) );
}

