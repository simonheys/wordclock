import { term, processTerm, performOperation } from "./LogicParser";

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

  describe("performOperation", () => {
    describe("when valid", () => {
      it("returns the expected result", () => {
        expect(
          performOperation({ termOne: "2", termTwo: "3", operator: "*" })
        ).toEqual(6);
        expect(
          performOperation({ termOne: "6", termTwo: "3", operator: "/" })
        ).toEqual(2);
        expect(
          performOperation({
            termOne: "foo",
            termTwo: "bar",
            operator: "+",
            props: { foo: "3", bar: 2 },
          })
        ).toEqual(5);
      });
    });
    describe("when invalid", () => {
      it("throws an error", () => {
        expect(() => performOperation()).toThrow();
      });
    });
  });
});
