var should = require("chai").should();
var FunL = require("../lib/funl");
var evalFunL = FunL.evalFunL;

describe("The FunL interpreter", function() {
  it("should interpret integers", function() {
    evalFunL("1").print().should.eq("1");
    evalFunL("1").should.be.instanceof(FunL.Type.Integer);
  });

  it("should interpret floats", function() {
    evalFunL("3.14").print().should.eq("3.14");
  });

  it("should interpret strings", function() {
    evalFunL('"hello world"').print().should.eq('"hello world"');
  });

  it("should interpret booleans", function() {
    evalFunL("#t").toJS().should.eq(true);
    evalFunL("#f").toJS().should.eq(false);
  });

  it("should evaluate keywords", function() {
    var it = evalFunL("+");
    it.should.be.instanceof(FunL.Type.Function);
  });

  it("should evaluate seqs", function() {
    evalFunL("[1, 3.14, \"hi\"]").print().should.eq('[1 3.14 "hi"]');
  });

  it("should evaluate seq application", function () {
    evalFunL("[1, 3.14]:1").toJS().should.eq(3.14);
  });

  it("should evaluate function application", function() {
    evalFunL("+:[1,2]").toJS().should.eq(3);
  });

  it("should evaluate tight function application", function() {
    evalFunL("+[[2,2]]").toJS().should.eq(4);
  });

  it("should evaluate constants", function() {
    evalFunL("~1").should.be.instanceof(FunL.Type.Function);
    evalFunL("~1:1").should.be.instanceof(FunL.Type.Integer);
  });

  it("should evaluate composition", function() {
    evalFunL("(+ | id):[1, 2]").toJS().should.eq(3);
  });

  it("should evaluate construction", function() {
    evalFunL("<+, ->:[4, 2]").toJS().should.eql([6, 2]);
  });

  it("should evaluate conditionals", function() {
    evalFunL("#t ? 0 ; 1").toJS().should.eq(0);
    evalFunL("#f ? 0 ; 1").toJS().should.eq(1);
  });

  it("can evaluate definitions", function() {
    evalFunL("sum-and-product = <+, *> \n sum-and-product:[2, 3]").toJS().should.eql([5, 6]);
  });

  it("can use map", function() {
    evalFunL("map[(<id, 2> | *)]:[1, 2, 3]").toJS().should.eql([2, 4, 6]);
  });

  it("can use fold", function() {
    evalFunL("fold[+]:[1, 2, 3, 4]").toJS().should.eq(10);
  });

  it("can compute length", function() {
    evalFunL("length = map[1] | fold[+] \n length:[1, 2, 3, 4, 10]").toJS().should.eq(5);
  });
});
