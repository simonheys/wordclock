import * as LogicParserStringUtil from "./LogicParserStringUtil";

export const OPERATORS = {
  EQUALITY: ["===", "!==", "==", "!=", ">=", "<=", ">", "<"],
  MATH: ["%", "*", "/", "+", "-"],
  BOOLEAN: ["&&", "||"],
  CONVERSION: ["-", "!"],
};

// ____________________________________________________________________________________________________ term

export const term = (source, props) => {
  let terms;
  let parsing = false;
  let result;
  parsing = true;
  while (parsing) {
    // parse brackets
    if (LogicParserStringUtil.containsBraces(source)) {
      terms =
        LogicParserStringUtil.extractStringContainedInOutermostBraces(source);
      const termResult = term(terms[1], props);
      source = `${terms[0]}${termResult}${terms[2]}`;
    } else {
      // parse math operators
      result = LogicParserStringUtil.scanForInstanceOf({
        source,
        array: OPERATORS.MATH,
      });
      if (result !== -1) {
        terms = LogicParserStringUtil.extractTermsAroundPivot({
          source,
          pivot: OPERATORS.MATH[result],
        });
        const operationResult = performOperation({
          termOne: terms[1],
          termTwo: terms[2],
          operator: OPERATORS.MATH[result],
          props,
        });
        source = `${terms[0]}${operationResult}${terms[3]}`;
      } else {
        // parse equality operators
        result = LogicParserStringUtil.scanForInstanceOf({
          source,
          array: OPERATORS.EQUALITY,
        });
        if (result !== -1) {
          terms = LogicParserStringUtil.extractTermsAroundPivot({
            source,
            pivot: OPERATORS.EQUALITY[result],
          });
          const operationResult = performOperation({
            termOne: terms[1],
            termTwo: terms[2],
            operator: OPERATORS.EQUALITY[result],
            props,
          });
          source = `${terms[0]}${operationResult}${terms[3]}`;
        } else {
          // parse boolean operators
          result = LogicParserStringUtil.scanForInstanceOf({
            source,
            array: OPERATORS.BOOLEAN,
          });
          if (result !== -1) {
            terms = LogicParserStringUtil.extractTermsAroundPivot({
              source,
              pivot: OPERATORS.BOOLEAN[result],
            });
            const operationResult = performOperation({
              termOne: terms[1],
              termTwo: terms[2],
              operator: OPERATORS.BOOLEAN[result],
              props,
            });
            source = `${terms[0]}${operationResult}${terms[3]}`;
          } else {
            parsing = false;
          }
        }
      }
    }
  }
  return processTerm(source, props);
};

// ____________________________________________________________________________________________________ Process

// check for var names, - and !
export const processTerm = (source = "", props = {}) => {
  let result;
  const isString = typeof source === "string";
  if (isString) {
    source = source.trim();
  }
  const isNumeric = LogicParserStringUtil.isNumericString(source);
  if (isString && source.startsWith("-")) {
    result = processTerm(source.substr(1), props);
    return 0 - result;
  } else if (isString && source.startsWith("!")) {
    result = processTerm(source.substr(1), props);
    // invert result
    return !result;
  } else if (isNumeric) {
    return parseInt(source);
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
    return processTerm(props[source], props);
  }

  return source;
};

// ____________________________________________________________________________________________________ operation

export const performOperation = ({
  termOne,
  termTwo,
  operator,
  props,
} = {}) => {
  // replace variable names where appropriate
  let a = processTerm(termOne, props);
  let b = processTerm(termTwo, props);
  let result = 0;
  if (operator === "*") {
    result = a * b;
  } else if (operator === "/") {
    result = a / b;
  } else if (operator === "+") {
    result = a + b;
  } else if (operator === "-") {
    result = a - b;
  } else if (operator === "%") {
    result = a % b;
  } else if (operator === "&&") {
    result = a && b;
  } else if (operator === "||") {
    result = a || b;
  } else if (operator === "!==") {
    result = a !== b;
  } else if (operator === "===") {
    result = a === b;
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

  return result;
};
