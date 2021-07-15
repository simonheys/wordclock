//
//  sin_and_cos_tables.c
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
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
