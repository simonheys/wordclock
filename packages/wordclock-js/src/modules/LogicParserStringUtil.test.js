import {
  extractStringContainedInOutermostBraces,
  extractTermsAroundPivot,
} from "./LogicParserStringUtil";

describe("LogicParserStringUtil", () => {
  describe("extractStringContainedInOutermostBraces", () => {
    describe("when valid", () => {
      it("returns the string contained in outermost braces", () => {
        expect(
          extractStringContainedInOutermostBraces("foo(((bar)))").insideBraces
        ).toEqual("((bar))");
        expect(
          extractStringContainedInOutermostBraces("foo((bar))foo").insideBraces
        ).toEqual("(bar)");
        expect(
          extractStringContainedInOutermostBraces("(bar)foo").insideBraces
        ).toEqual("bar");
      });
    });
    describe("when invalid", () => {
      it("returns an empty string", () => {
        expect(extractStringContainedInOutermostBraces()).toEqual("");
      });
    });
  });

  describe("extractTermsAroundPivot", () => {
    describe("when valid", () => {
      it("returns the expected terms", () => {
        const { beforeLeftTerm, leftTerm, rightTerm, afterRightTerm } =
          extractTermsAroundPivot({ source: "23-foo*25+6", pivot: "*" });
        expect(beforeLeftTerm).toEqual("23-");
        expect(leftTerm).toEqual("foo");
        expect(rightTerm).toEqual("25");
        expect(afterRightTerm).toEqual("+6");
      });
    });
    describe("when invalid", () => {
      it("throws an error", () => {
        expect(() => extractTermsAroundPivot()).toThrow();
      });
    });
  });
});
