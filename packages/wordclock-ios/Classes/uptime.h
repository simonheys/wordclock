/*
 *  uptime.h
 *  iphone_word_clock_open_gl
 *
 *  Created by Simon on 18/04/2009.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */
#include <mach/mach_time.h>

//double getUpTime();

static inline double getUpTime()
{
   static mach_timebase_info_data_t sTimebaseInfo;
   // If this is the first time we've run, get the timebase.
   // We can use denom == 0 to indicate that sTimebaseInfo is
   // uninitialised because it makes no sense to have a zero
   // denominator is a fraction.
   if ( sTimebaseInfo.denom == 0 ) {
      (void) mach_timebase_info(&sTimebaseInfo);
   }
   uint64_t thenano;
   thenano = mach_absolute_time() * sTimebaseInfo.numer / sTimebaseInfo.denom;
   return thenano / 1000000000.0;
}