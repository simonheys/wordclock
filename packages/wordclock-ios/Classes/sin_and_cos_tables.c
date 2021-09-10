//
//  sin_and_cos_tables.c
//  WordClock iOS
//
//  Created by Simon Heys on 21/07/2008.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#include "sin_and_cos_tables.h"

void buildSinAndCosTables()
{
	for ( int i = 0; i < SIN_TABLE_SIZE; i++ ) {
		_sinTable[i] = sinf( 2 * M_PI * i / SIN_TABLE_SIZE );
		_cosTable[i] = cosf( 2 * M_PI * i / SIN_TABLE_SIZE );
	}
}
