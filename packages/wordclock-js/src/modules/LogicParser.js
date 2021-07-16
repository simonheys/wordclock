import * as LogicParserStringUtil from "./LogicParserStringUtil";

export const OPERATORS = {
  EQUALITY: ["==", "!=", ">=", "<=", ">", "<"],
  MATH: ["%", "*", "/", "+", "-"],
  BOOLEAN: ["&&", "||"],
  CONVERSION: ["-", "!"],
};

// ____________________________________________________________________________________________________ term

// export const term = source => {
//     const terms = [];
//     let parsing = false;
//     let result;

//     //	DDLogVerbose(@"term input:<%@>",source);

//     parsing = true;

//     while (parsing) {
//         // parse brackets
//         if (LogicParserStringUtil.containsBraces(source)) {
//             terms = LogicParserStringUtil.extractStringContainedInOutermostBraces(source);
//             source = `${terms[0]${term(terms[1])}${term(terms[2])}}`;
//         } else {
//             // parse math operators
//             result = LogicParserStringUtil.scanForInstanceOf({source, array:OPERATORS.MATH});
//             if (result !== -1) {
//                 terms = LogicParserStringUtil.extractTermsAroundPivot({source, pivot:OPERATORS.MATH[result]});
//                 source = [NSString
// 					stringWithFormat:@"%@%@%@",
// 					terms[0],
// 					[self
// 						performOperationOnTermOne:terms[1]
// 						termTwo:terms[2]
// 						operator:LogicParserMathOperators[result]
// 					],
// 					terms[3]
// 				];
//                 //  terms[0]+performOperation(terms[1],terms[2],MATH_OPERATORS[result])+terms[3];
//                 // trace(terms);
//             } else {
//                 // parse equality operators
//                 result = [LogicParserStringUtil scanForInstanceOf:source inArray:LogicParserEqualityOperators];
//                 if (result != -1) {
//                     terms = [LogicParserStringUtil extractTermsAroundPivot:source pivot:LogicParserEqualityOperators[result]];
//                     source = [NSString
// 						stringWithFormat:@"%@%@%@",
// 						terms[0],
// 						[self
// 							performOperationOnTermOne:terms[1]
// 							termTwo:terms[2]
// 							operator:LogicParserEqualityOperators[result]
// 						],
// 						terms[3]
// 					];
//                     // source =
//                     // terms[0]+performOperation(terms[1],terms[2],EQUALITY_OPERATORS[result])+terms[3];
//                     // trace(terms);
//                 } else {
//                     // parse boolean operators
//                     result = [LogicParserStringUtil scanForInstanceOf:source inArray:LogicParserBooleanOperators];
//                     if (result != -1) {
//                         terms = [LogicParserStringUtil extractTermsAroundPivot:source pivot:LogicParserBooleanOperators[result]];
//                         source = [NSString
// 							stringWithFormat:@"%@%@%@",
// 							terms[0],
// 							[self
// 								performOperationOnTermOne:terms[1]
// 								termTwo:terms[2]
// 								operator:LogicParserBooleanOperators[result]
// 							],
// 							terms[3]
// 						];
//                     } else {
//                         parsing = NO;
//                     }
//                 }
//             }
//         }
//     }
//     //	DDLogVerbose(@"term output:<%@>",source);
//     return source;
// }

// ____________________________________________________________________________________________________ Process

// check for var names, - and !
export const processTerm = (source, props = {}) => {
  let result;
  source = source.trim();
  if (source.length == 1) {
    return parseInt(source);
  } else if (source.startsWith("-")) {
    return 0 - processTerm(source.substr(1));
  } else if (source.startsWith("!")) {
    result = processTerm(source.substr(1));
    // invert result
    return !result;
  } else if (source === "else") {
    // 'else' is used as a convenient phrase for the xml, logically it's the equivalent of 'true'
    return true;
  } else if (source === "false") {
    return false;
  } else if (source === "true") {
    return true;
  }

  // return from props
  if (props[source] !== undefined) {
    return props[source];
  }

  result = parseInt(source);
  if (!isNaN(result)) {
    return result;
  }

  throw `Unable to determine result for '${source}' - not a number and missing in supplied props`;
};

// ____________________________________________________________________________________________________ operation

export const performOperation = ({ termOne, termTwo, operator } = {}) => {
  // replace variable names where appropriate
  let a = processTerm(termOne);
  let b = processTerm(termTwo);
  let result = 0;
  if (operator === "*") {
    result = a * b;
  } else if (operator === "/") {
    result = a / b;
  } else if (operator === "+") {
    result = a + b;
  } else if (operator === "-") {
    // FIXME need to fix negative logic (cases with - sign) see above
    result = a - b;
  } else if (operator === "%") {
    result = a % b;
  } else if (operator === "&&") {
    result = a && b;
  } else if (operator === "||") {
    result = a || b;
  } else if (operator === "!=") {
    result = a != b;
  } else if (operator === "==") {
    result = a == b;
  } else if (operator === ">") {
    result = a > b;
  } else if (operator === "<") {
    result = a < b;
  } else if (operator === ">=") {
    result = a >= b;
  } else if (operator === "<=") {
    result = a <= b;
  }

  return parseInt(result);
};
