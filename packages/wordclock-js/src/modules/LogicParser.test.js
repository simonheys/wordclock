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
      it("returns empty string", () => {
        expect(processTerm()).toEqual("");
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
      it("returns zero", () => {
        expect(performOperation()).toEqual(0);
      });
    });
  });

  describe("term", () => {
    describe("when valid", () => {
      describe("when using only numbers", () => {
        it("returns the expected result", () => {
          expect(term("2*3")).toEqual(6);
          expect(term("2*3")).toEqual(6);
          expect(term("24/3*2")).toEqual(4);
          expect(term("(24/3)*2")).toEqual(16);
          expect(term("(27*3+(5+10))%(7*2)")).toEqual(12);
        });
      });
      describe("when using numbers and props", () => {
        it("returns the expected result", () => {
          const props = {
            day: 2,
            month: 3,
          };
          expect(term("day", props)).toEqual(2);
          expect(term("month", props)).toEqual(3);
          expect(term("day*month", props)).toEqual(6);
          expect(term("day%2", props)).toEqual(0);
          expect(term("day*2", props)).toEqual(4);
          expect(term("day==2", props)).toEqual(true);
          expect(term("day===2", props)).toEqual(true);
          expect(term("day!==month", props)).toEqual(true);
          expect(term("day===month", props)).toEqual(false);
          expect(term("(day*month)===(1+day+month)", props)).toEqual(true);

          expect(
            term("(second%10)===2 || (second>10 && second<21)", { second: 2 })
          ).toEqual(true);
          expect(
            term("(second%10)===2 || (second>10 && second<21)", { second: 12 })
          ).toEqual(true);
          expect(
            term("(second%10)===2 || (second>10 && second<21)", { second: 22 })
          ).toEqual(true);

          expect(
            term("(second%10)===2 && (second>10 && second<21)", { second: 2 })
          ).toEqual(false);
          expect(
            term("(second%10)===2 && (second>10 && second<21)", { second: 12 })
          ).toEqual(true);
          expect(
            term("(second%10)===2 && (second>10 && second<21)", { second: 22 })
          ).toEqual(false);

          expect(
            term("(second%10)===2 && !(second>10 && second<21)", { second: 2 })
          ).toEqual(true);
          expect(
            term("(second%10)===2 && !(second>10 && second<21)", { second: 12 })
          ).toEqual(false);
          expect(
            term("(second%10)===2 && !(second>10 && second<21)", { second: 22 })
          ).toEqual(true);
        });
      });
    });
    describe("when invalid", () => {
      it("returns empty string", () => {
        expect(term()).toEqual("");
      });
    });
  });
});
