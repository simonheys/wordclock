//
//  culling.c
//  WordClock-iOS
//
//  Created by Simon Heys on 07/07/2021.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#include "culling.h"

// qsort i
static int compareI(const void *a, const void *b)
{
	WordClockRectsForCulling *ia = ( WordClockRectsForCulling *)a;
	WordClockRectsForCulling *ib = ( WordClockRectsForCulling *)b;
	return (int)( ia->i - ib->i );
}

// qsort left
static int compareXl(const void *a, const void *b)
{
	WordClockRectsForCulling *ia = ( WordClockRectsForCulling *)a;
	WordClockRectsForCulling *ib = ( WordClockRectsForCulling *)b;
	return (int)( ia->xl - ib->xl );
}

// qsort right
static int compareXr(const void *a, const void *b)
{
	WordClockRectsForCulling *ia = ( WordClockRectsForCulling *)a;
	WordClockRectsForCulling *ib = ( WordClockRectsForCulling *)b;
	return (int)( ia->xr - ib->xr );
}

// qsort top
static int compareYt(const void *a, const void *b)
{
	WordClockRectsForCulling *ia = ( WordClockRectsForCulling *)a;
	WordClockRectsForCulling *ib = ( WordClockRectsForCulling *)b;
	return (int)( ia->yt - ib->yt );
}

// qsort b ottom
static int compareYb(const void *a, const void *b)
{
	WordClockRectsForCulling *ia = ( WordClockRectsForCulling *)a;
	WordClockRectsForCulling *ib = ( WordClockRectsForCulling *)b;
	return (int)( ia->yb - ib->yb );
}

static int bsearchLowerBoundCheckXrXl(const void *a, const void *b)
{
	WordClockRectsForCulling *ia = ( WordClockRectsForCulling *)a;
	WordClockRectsForCulling *ib = ( WordClockRectsForCulling *)b;

//	printf("ia->xr:%f ib->xl:%f ia->i:%d\r",ia->xr,ib->xl,ia->i);
	if ( ia->xr == ib->xl ) {
		return 0;
	}
	if ( ia->xr < ib->xl ) {
		return -1;
	}
	return 1;
}

static int bsearchLowerBoundCheckXlXr(const void *a, const void *b)
{
	WordClockRectsForCulling *ia = ( WordClockRectsForCulling *)a;
	WordClockRectsForCulling *ib = ( WordClockRectsForCulling *)b;

//	printf("ia->xr:%f ib->xl:%f ia->i:%d\r",ia->xr,ib->xl,ia->i);
	if ( ia->xl == ib->xr ) {
		return 0;
	}
	if ( ia->xl < ib->xr ) {
		return -1;
	}
	return 1;
}

static int bsearchLowerBoundCheckYbYt(const void *a, const void *b)
{
	WordClockRectsForCulling *ia = ( WordClockRectsForCulling *)a;
	WordClockRectsForCulling *ib = ( WordClockRectsForCulling *)b;

	if ( ia->yb == ib->yt ) {
		return 0;
	}
	if ( ia->yb < ib->yt ) {
		return -1;
	}
	return 1;
}

static int bsearchLowerBoundCheckYtYb(const void *a, const void *b)
{
	WordClockRectsForCulling *ia = ( WordClockRectsForCulling *)a;
	WordClockRectsForCulling *ib = ( WordClockRectsForCulling *)b;

	if ( ia->yt == ib->yb ) {
		return 0;
	}
	if ( ia->yt < ib->yb ) {
		return -1;
	}
	return 1;
}


/* Return the lowest index at which the element *KEY should be inserted into
   the array at BASE which has NELTS elements of size ELT_SIZE bytes each,
   according to the ordering defined by COMPARE_FUNC.
   0 <= NELTS <= INT_MAX, 1 <= ELT_SIZE <= INT_MAX.
   The array must already be sorted in the ordering defined by COMPARE_FUNC.
   COMPARE_FUNC is defined as for the C stdlib function bsearch().
   Note: This function is modeled on bsearch() and on lower_bound() in the
   C++ STL.
 */
static inline int
bsearch_lower_bound(const void *key,
                    const void *base,
                    int nelts,
                    int elt_size,
                    int (*compare_func)(const void *, const void *))
{
  int lower = 0;
  int upper = nelts - 1;

  /* Binary search for the lowest position at which to insert KEY. */
  while (lower <= upper)
    {
      int try = lower + (upper - lower) / 2;  /* careful to avoid overflow */
      int cmp = compare_func((const char *)base + try * elt_size, key);

      if (cmp < 0)
        lower = try + 1;
      else
        upper = try - 1;
    }
  assert(lower == upper + 1);

  return lower;
}

// ____________________________________________________________________________________________________ culling

int cull_rects(WordClockRectsForCulling *rects, int numberOfRects, CGRect rect, void *resultPointer )
{
	int *result = (int *)resultPointer;
	
	WordClockRectsForCulling key;
	key.xl = CGRectGetMinX(rect);
	key.xr = CGRectGetMaxX(rect);
	key.yt = CGRectGetMinY(rect);
	key.yb = CGRectGetMaxY(rect);

#ifdef DEBUG_CULL
	printf("__________________________________________________ starting\r");

	for (i=0;i<numberOfRects;i++) {
		printf("i:%d rect i:%d xl:%f xr:%f yt:%f yb:%f\n",i, rects[ i ].i,rects[ i ].xl, rects[ i ].xr, rects[i].yt, rects[i].yb) ;
	}
	
	
	
	// step 1
	// sort the array by x, so we can then trim to the left and right edges
#endif
	qsort(rects,numberOfRects,sizeof(WordClockRectsForCulling),compareXr);
#ifdef DEBUG_CULL
	printf("__________ qsort xr\r");
	for (i=0;i<numberOfRects;i++) {
		printf("i:%d rect i:%d xl:%f xr:%f yt:%f yb:%f\n",i, rects[ i ].i,rects[ i ].xl, rects[ i ].xr, rects[i].yt, rects[i].yb) ;
	}
	printf("__________ left b search\r");
#endif
	
	int left;
	int right;
	int top;
	int bottom;
	
	// step 2
	// find the left edge
	// if it's not found, then we just use the first one


	left = bsearch_lower_bound(&key, &rects[0], numberOfRects, sizeof(WordClockRectsForCulling), bsearchLowerBoundCheckXrXl);
#ifdef DEBUG_CULL
	printf("key.xl:%f\r",key.xl);
	printf("left:%d\r",left);
#endif	
//	printf("found index %d x:%f,y:%f\r", rects[left].i,rects[left].x,rects[left].y);
	
	
	//	printf("found index %d x:%f,y:%f\r", left->i,left->x,left->y);
//	}
//	else {
//		printf("NOT FOUND\r");
//		left = &rects[0];
//	}
//	printf("left:%d left-rects:%d\r",left,left-rects);
	
	// step 3
	// find the right edge; start the serach at left
	// if nto found then jsut use the last one
	qsort(&rects[left],numberOfRects-left,sizeof(WordClockRectsForCulling),compareXl);	
#ifdef DEBUG_CULL
	printf("__________ qsort xl\r");
	for (i=left;i<numberOfRects;i++) {
		printf("i:%d rect i:%d xl:%f xr:%f yt:%f yb:%f\n",i, rects[ i ].i,rects[ i ].xl, rects[ i ].xr, rects[i].yt, rects[i].yb) ;
	}
#endif

	right = bsearch_lower_bound(&key, &rects[left], numberOfRects-left, sizeof(WordClockRectsForCulling), bsearchLowerBoundCheckXlXr); 
	right +=left;
#ifdef DEBUG_CULL
	printf("key.xr:%f\r",key.xr);
	printf("right:%d\r",right);
#endif
	
	
	// if left and right are the same, we know that noting matches
	if ( left == right ){
		printf("cull_rects: NO MATCHES. NOTHING IS VISIBLE. BAILING OUT\r");
		return 0;
	}
	
	// discount the last one; it will be over the bound because of the way that lower_bound works
	right--;
#ifdef DEBUG_CULL
	printf("adjusted right:%d\r",right);
#endif
	
	//printf("found index %d x:%f,y:%f\r", rects[right].i,rects[right].x,rects[right].y);
	
	//int numberOfItemsLeftToRight = 1+right-left;

	// step 3
	// sort in y between left and right
	// so we do the same process with the y numbers


	qsort(&rects[left],1+right-left,sizeof(WordClockRectsForCulling),compareYb);

#ifdef DEBUG_CULL
	printf("__________ qsort yb from %d with %d items\r",left,1+right-left);
	for (i=left;i<=right;i++) {
		printf("i:%d rect i:%d xl:%f xr:%f yt:%f yb:%f\n",i, rects[ i ].i,rects[ i ].xl, rects[ i ].xr, rects[i].yt, rects[i].yb) ;
	}
#endif
	top = bsearch_lower_bound(&key, &rects[left], 1+right-left, sizeof(WordClockRectsForCulling), bsearchLowerBoundCheckYbYt);
	top += left;
#ifdef DEBUG_CULL
	printf("key.yt:%f\r",key.yt);
	printf("top:%d\r",top);

		
	printf("__________bottom b search:\r");
	// find bottom
	printf("key.yb:%f\r",key.yb);
#endif
	qsort(&rects[top],1+right-top,sizeof(WordClockRectsForCulling),compareYt);
	bottom = bsearch_lower_bound(&key, &rects[top], 1+right-top, sizeof(WordClockRectsForCulling), bsearchLowerBoundCheckYtYb);
	bottom += top;
#ifdef DEBUG_CULL
	printf("bottom:%d\r",bottom);
#endif
	if ( top == bottom ) {
		printf("NO MATCHES. BAILING OUT\r");
		return 0;	
	}
	// discount the last one
	bottom--;
#ifdef DEBUG_CULL
	printf("bottom adjusted:%d\r",bottom);
	
	printf("__________y sorted and trimmed:\r");
	
//	for ( WordClockVerticesForCulling*i = left; i != right; ++i ) {
	for ( int i = top; i <= bottom; i++ ) {
		printf("rect i:%d xl:%f xr:%f yt:%f yb:%f\n",rects[ i ].i,rects[ i ].xl, rects[ i ].xr, rects[i].yt, rects[i].yb);
	}
	
	
	// now we need to filter unique values of i
	printf("__________sort by i:\r");
#endif
	
	// TODO is this necessary?
//	qsort(&rects[top],bottom-top,sizeof(WordClockRectsForCulling),compareI);
#ifdef DEBUG_CULL
	for ( int i = top; i <= bottom; i++ ) {
		printf("rect i:%d xl:%f xr:%f yt:%f yb:%f\n",rects[ i ].i,rects[ i ].xl, rects[ i ].xr, rects[i].yt, rects[i].yb);
	}
#endif
	/*
	printf("__________filter unique i:\r");
	
//	int result[1+bottom-top];
	int currentFind;
	int resultIndex = 0;
	currentFind = -1;
	for ( int i = top; i <= bottom; i++ ) {
		printf("coordinate x:%f y:%f i:%d\r",rects[i].x,rects[i].y,rects[i].i);
		printf("currentFind:%d\r",currentFind);
		if ( currentFind < rects[i].i ) {
			currentFind = rects[i].i;
			printf("unique:%d\r",currentFind);
			result[resultIndex++] = currentFind;
		}
	}
	
	printf("__________resulting unique i:\r");
	for ( int i = 0; i < resultIndex; i++ ) {
		printf("result:%d\r",result[i]);
	}
	
	
	
	
	//result[0] = 5;
	//return 0;

	return resultIndex;
	*/
//	int result[1+bottom-top];
	int resultIndex = 0;
	for ( int i = top; i <= bottom; i++ ) {
#ifdef DEBUG_CULL
		printf("adding:%d\r",rects[i].i);
#endif
		result[resultIndex++] = rects[i].i;
	}
	return resultIndex;
}

