//
//  LogicParserStringUtil.m
//  WordClock macOS
//
//  Created by Simon Heys on 16/04/2011.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

export const OPERATORS = "!%&*()-+=|/<>";

export const extractStringContainedInOutermostBraces = (source) => {
  if (typeof source !== "string") {
    return "";
  }

  let leftOfBraces;
  let rightOfBraces;
  let insideBraces;
  let count;
  let firstBrace;
  let i;
  let c;

  firstBrace = source.indexOf("(");
  i = 1 + firstBrace;

  leftOfBraces = source.substr(0, firstBrace);
  count = 1;

  while (count > 0 && i < source.length) {
    c = source.substr(i, 1);
    if (c == "(") {
      count++;
    }
    if (c == ")") {
      count--;
    }
    i++;
  }
  if (i < source.length) {
    rightOfBraces = source.substr(i);
  } else {
    rightOfBraces = "";
  }

  insideBraces = source.substr(1 + firstBrace, i - 1 - (1 + firstBrace));
  return { leftOfBraces, insideBraces, rightOfBraces };
};

// + (int)scanForInstanceOf:(NSString *)source inArray:(NSArray *)arrayOfStrings {
//     //	DDLogVerbose(@"scanForInstanceOf:%@",source);
//     //	DDLogVerbose(@"inArray:%@",arrayOfStrings);
//     for (int i = 0; i < [arrayOfStrings count]; i++) {
//         if ([source rangeOfString:arrayOfStrings[i]].location != NSNotFound) {
//             return i;
//         }
//     }
//     return -1;
// }

export const extractTermsAroundPivot = ({ source, pivot }) => {
  let leftTerm;
  let rightTerm;
  let leftOfPivot;
  let rightOfPivot;
  let beforeLeftTerm;
  let afterRightTerm;
  let c;
  let i;

  const pivotLocation = source.indexOf(pivot);

  leftOfPivot = source.substr(0, pivotLocation);
  rightOfPivot = source.substr(pivotLocation + pivot.length);

  // left term
  leftTerm = "";
  i = leftOfPivot.length - 1;
  c = leftOfPivot.substr(i, 1);

  while (i > 0 && OPERATORS.indexOf(c) === -1) {
    i--;
    c = leftOfPivot.substr(i, 1);
  }

  if (OPERATORS.indexOf(c) !== -1) {
    leftTerm = leftOfPivot.substr(i + 1);
    beforeLeftTerm = leftOfPivot.substr(0, i + 1);
  } else {
    leftTerm = leftOfPivot.substr(i);
    beforeLeftTerm = leftOfPivot.substr(0, i);
  }

  // rightTerm = @"";
  // if ([rightOfPivot length] > 0) {
  //     i = 0;
  //     c = [rightOfPivot characterAtIndex:i];  //.substr(i,1);
  //     //		while ( OPERATORS.indexOf(c) == -1 && i < rightOfPivot.length )
  //     while (([LogicParserStringUtilOperators rangeOfString:[NSString stringWithFormat:@"%c", c]]).location == NSNotFound && i < [rightOfPivot length]) {
  //         i++;
  //         if (i < [rightOfPivot length]) {
  //             c = [rightOfPivot characterAtIndex:i];
  //         }
  //     }
  //     //		rightTerm = rightOfPivot.substr(0,i);
  //     //		afterRightTerm = rightOfPivot.substr(i);
  // }

  // if (i < [rightOfPivot length]) {
  //     rightTerm = [rightOfPivot substringToIndex:i];
  //     afterRightTerm = [rightOfPivot substringFromIndex:i];
  // } else {
  //     rightTerm = rightOfPivot;
  //     afterRightTerm = @"";
  // }

  //	DDLogVerbose(@"rightTerm:%@",rightTerm);
  //	DDLogVerbose(@"afterRightTerm:%@",afterRightTerm);
  // return [beforeLeftTerm,leftTerm,rightTerm,afterRightTerm];

  return { beforeLeftTerm, leftTerm, rightTerm, afterRightTerm };
};

// + (NSString *)trim:(NSString *)source {
//     return [source stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
// }

// + (int)countInstancesOf:(NSString *)source instance:(char)instance {
//     int count = 0;
//     int i = 0;
//     while (i < [source length]) {
//         if ([source characterAtIndex:i] == instance) {
//             count++;
//         }
//         i++;
//     }
//     //	DDLogVerbose(@"countInstancesOf:%@ - %c = %d",source,instance,count);
//     return count;
// }

// + (BOOL)checkBalancedBraces:(NSString *)source {
//     return ([LogicParserStringUtil countInstancesOf:source instance:'('] == [LogicParserStringUtil countInstancesOf:source instance:')']);
// }

// + (BOOL)containsBraces:(NSString *)source {
//     return ([LogicParserStringUtil contains:source instance:'('] || [LogicParserStringUtil contains:source instance:')']);
// }

// + (BOOL)contains:(NSString *)source instance:(char)instance {
//     return ([LogicParserStringUtil countInstancesOf:source instance:instance] > 0);
// }
// @end
