import { extractStringContainedInOutermostBraces } from "./LogicParserStringUtil";

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
});
