import { extractStringContainedInOutermostBraces } from "./LogicParserStringUtil";

describe("LogicParserStringUtil", () => {
  describe("extractStringContainedInOutermostBraces", () => {
    describe("when valid", () => {});
    describe("when invalid", () => {
      describe("returns an empty string", () => {
        expect(extractStringContainedInOutermostBraces()).toEqual("");
      });
    });
  });
});
