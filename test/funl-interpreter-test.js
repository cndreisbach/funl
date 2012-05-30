var should = require("chai").should();
var FunL = require("../lib/funl");
var evalFunL = FunL.evalFunL;

describe("The FunL interpreter", function() {
  it("should interpret integers", function() {
    evalFunL("1").print().should.eq("1");
  });

  it("should interpret floats", function() {
    evalFunL("3.14").print().should.eq("3.14");
  });

  it("should interpret strings", function() {
    evalFunL('"hello world"').print().should.eq('"hello world"');
  });
});
