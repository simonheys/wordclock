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

export const scanForInstanceOf = ({ source, array } = {}) => {
  if (typeof source !== "string" || !Array.isArray(array)) {
    return -1;
  }
  for (let i = 0; i < array.length; i++) {
    if (source.indexOf(array[i]) !== -1) {
      return i;
    }
  }
  return -1;
};

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

  // right term
  rightTerm = "";
  if (rightOfPivot.length > 0) {
    i = 0;
    c = rightOfPivot.substr(i, 1);

    while (i < rightOfPivot.length && OPERATORS.indexOf(c) === -1) {
      i++;
      if (i < rightOfPivot.length) {
        c = rightOfPivot.substr(i, 1);
      }
    }
  }

  if (i < rightOfPivot.length) {
    rightTerm = rightOfPivot.substr(0, i);
    afterRightTerm = rightOfPivot.substr(i);
  } else {
    rightTerm = rightOfPivot;
    afterRightTerm = "";
  }

  return { beforeLeftTerm, leftTerm, rightTerm, afterRightTerm };
};

export const countInstancesOf = ({ source, instance } = {}) => {
  if (typeof source !== "string" || typeof instance !== "string") {
    return 0;
  }
  let count = 0;
  let i = 0;
  while (i < source.length) {
    if (source.substr(i, 1) === instance) {
      count++;
    }
    i++;
  }
  return count;
};

export const checkBalancedBraces = (source) => {
  if (!containsBraces(source)) {
    return false;
  }
  const leftInstances = countInstancesOf({ source, instance: "(" });
  const rightInstances = countInstancesOf({ source, instance: ")" });
  return leftInstances === rightInstances;
};

export const contains = ({ source, instance } = {}) => {
  if (typeof source !== "string") {
    return false;
  }
  return source.indexOf(instance) !== -1;
};

export const containsBraces = (source) => {
  return (
    contains({ source, instance: "(" }) > 0 ||
    contains({ source, instance: ")" }) > 0
  );
};
