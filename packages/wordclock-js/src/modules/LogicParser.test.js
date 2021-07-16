import { processTerm } from "./LogicParser";

describe("LogicParser", () => {
  describe("processTerm", () => {
    describe("when valid", () => {
      describe("when the term is negative string", () => {
        it("returns negative", () => {
          expect(processTerm("-123")).toEqual(-123);
          expect(processTerm("--123")).toEqual(123);
        });
      });
      describe("when the term is a boolean string", () => {
        it("returns boolean value", () => {
          expect(processTerm("true")).toEqual(true);
          expect(processTerm("false")).toEqual(false);
        });
      });
    });
    describe("when invalid", () => {
      it("throws an error", () => {
        expect(() => processTerm()).toThrow();
      });
    });
  });
});
