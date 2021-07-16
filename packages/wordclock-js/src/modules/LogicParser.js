export const OPERATORS = {
  EQUALITY: ["==", "!=", ">=", "<=", ">", "<"],
  MATH: ["%", "*", "/", "+", "-"],
  BOOLEAN: ["&&", "||"],
  CONVERSION: ["-", "!"],
};

// ____________________________________________________________________________________________________ term

export const term = source => {
    const terms = [];
    let parsing = false;
    let result;

    //	DDLogVerbose(@"term input:<%@>",source);

    parsing = true;

    while (parsing) {
        // parse brackets
        if ([LogicParserStringUtil containsBraces:source]) {
            terms = [LogicParserStringUtil extractStringContainedInOutermostBraces:source];
            //			DDLogVerbose(@"extracted braces:%@",terms);
            source = [NSString stringWithFormat:@"%@%@%@", terms[0], [self term:terms[1]], terms[2]];
        } else {
            // parse math operators
            result = [LogicParserStringUtil scanForInstanceOf:source inArray:LogicParserMathOperators];
            if (result != -1) {
                terms = [LogicParserStringUtil extractTermsAroundPivot:source pivot:LogicParserMathOperators[result]];  //  MATH_OPERATORS[result]);
                source = [NSString
					stringWithFormat:@"%@%@%@",
					terms[0], 
					[self 
						performOperationOnTermOne:terms[1]
						termTwo:terms[2]
						operator:LogicParserMathOperators[result]
					],
					terms[3]
				];
                //  terms[0]+performOperation(terms[1],terms[2],MATH_OPERATORS[result])+terms[3];
                // trace(terms);
            } else {
                // parse equality operators
                result = [LogicParserStringUtil scanForInstanceOf:source inArray:LogicParserEqualityOperators];
                if (result != -1) {
                    terms = [LogicParserStringUtil extractTermsAroundPivot:source pivot:LogicParserEqualityOperators[result]];
                    source = [NSString
						stringWithFormat:@"%@%@%@",
						terms[0], 
						[self 
							performOperationOnTermOne:terms[1]
							termTwo:terms[2]
							operator:LogicParserEqualityOperators[result]
						],
						terms[3]
					];
                    // source =
                    // terms[0]+performOperation(terms[1],terms[2],EQUALITY_OPERATORS[result])+terms[3];
                    // trace(terms);
                } else {
                    // parse boolean operators
                    result = [LogicParserStringUtil scanForInstanceOf:source inArray:LogicParserBooleanOperators];
                    if (result != -1) {
                        terms = [LogicParserStringUtil extractTermsAroundPivot:source pivot:LogicParserBooleanOperators[result]];
                        source = [NSString
							stringWithFormat:@"%@%@%@",
							terms[0], 
							[self 
								performOperationOnTermOne:terms[1]
								termTwo:terms[2]
								operator:LogicParserBooleanOperators[result]
							],
							terms[3]
						];
                    } else {
                        parsing = NO;
                    }
                }
            }
        }
    }
    //	DDLogVerbose(@"term output:<%@>",source);
    return source;
}