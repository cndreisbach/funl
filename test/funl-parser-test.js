var should = require('chai').should();
var Assertion = require('chai').Assertion;
var parse = require('../lib/funl-parser').Parser.parse;
var inspect = require('util').inspect;

Assertion.addMethod('mapTo', function (compObj) {
  var obj = this._obj;
  for (var prop in compObj) {
    obj.should.have.property(prop, compObj[prop]);
  };
});

describe("The FunL parser", function() {
  it("should parse integers", function() {
    parse("1").should.mapTo({type: 'int', value: 1});
  });

  it("should parse floats", function() {
    parse("3.14").should.mapTo({type: 'float', value: 3.14});
  });

  it("should parse strings", function() {
    parse('"hello world"').should.mapTo({type: 'string', value: "hello world"});
  });

  it("should parse strings with embedded newlines and escape codes", function() {
    parse("\"hello\nworld\"").should.mapTo({type: 'string', value: "hello\nworld"});
    parse("\"hello\\\nworld\"").should.mapTo({type: 'string', value: "hello\nworld"});
  });

  it("should parse booleans", function() {
    parse("#t").should.mapTo({type: 'boolean', value: true});
    parse("#f").should.mapTo({type: 'boolean', value: false});
  });

  it("should parse keywords", function() {
    parse("range").should.mapTo({type: 'keyword', value: 'range'});
  });

  it("should parse sequences", function() {
    var it = parse('[1 "two" 3]');
    it.should.have.property('type', 'seq');
    it.value.should.have.length(3);
    it.value[0].should.mapTo({type: 'int', value: 1});
  });

  it("should parse sequences with complex values", function() {
    var it = parse('[inc:2 4 "hello"]');
    it.should.have.property('type', 'seq');
    it.value.should.have.length(3);
    it.value[0].should.have.property('type', 'application');
  });

  it("should parse maps", function() {
    var it = parse('{"foo" 1 "bar" 2}');
    it.should.have.property('type', 'map');
    it.value.should.have.length(4);
    it.value[0].should.mapTo({type: "string", value: "foo"});
    it.value[1].should.mapTo({type: "int", value: 1});
  });

  it("can handle whitespace and newlines", function() {
    var it = parse("  [ 1\n  2  \n 3 ]\n");
    it.should.have.property('type', 'seq');
    it.value.should.have.length(3);
  });

  it("should parse function application", function() {
    var it = parse("range:[1, 10]");
    it.should.have.property('type', 'application');
    it.value[0].should.mapTo({type: "keyword", value: "range"});
  });

  it("should nest application right-to-left", function() {
    var it = parse("first:second:third");
    it.value[0].should.mapTo({type: "keyword", value: "first"});
    it.value[1].should.have.property('type', 'application');
  });

  it("should use parentheses to nest application differently", function() {
    var it = parse("(first:second):third");
    it.value[0].should.have.property('type', 'application');
    it.value[1].should.mapTo({type: "keyword", value: "third"});
  });

  it("should handle construction", function() {
    var it = parse("<first second third>");
    it.should.have.property('type', 'construction');
    it.value.should.have.length(3);
    it.value[0].should.mapTo({type: "keyword", value: "first"});
  });

  it("should handle composition", function() {
    var it = parse("a:b | c");
    it.should.have.property('type', 'composition');
    it.value.should.have.length(2);
    it.value[1].should.mapTo({type: "keyword", value: "c"});
  });

  it("should handle composition with multiple pipes", function() {
    var it = parse("a:b | c | d");
    it.should.have.property('type', 'composition');
    it.value.should.have.length(2);
    it.value[1].should.have.property('type', 'composition');
    it.value[1].value[1].should.mapTo({type: "keyword", value: "d"});
  });
});
