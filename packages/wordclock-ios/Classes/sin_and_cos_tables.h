//
//  sin_and_cos_tables.h
//  WordClock iOS
//
//  Created by Simon Heys on 21/07/2008.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "math.h"

#define SIN_TABLE_SIZE 4096
#define SIN_TABLE_BITMASK 4095

float _sinTable[SIN_TABLE_SIZE];
float _cosTable[SIN_TABLE_SIZE];

void buildSinAndCosTables();

static inline float getSinFromTable(float d) {
    return _sinTable[(int)(d * 651.8986469f) & SIN_TABLE_BITMASK];
}

static inline float getCosFromTable(float d) {
    return _cosTable[(int)(d * 651.8986469f) & SIN_TABLE_BITMASK];
}
