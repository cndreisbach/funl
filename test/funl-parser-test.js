var should = require('chai').should();
var Assertion = require('chai').Assertion;
var parse = require('../lib/funl-parser').Parser.parse;
var eparse = function(code) {
  return parse(code, "expression");
}

Assertion.addMethod('mapTo', function (compObj) {
  var obj = this._obj;
  for (var prop in compObj) {
    obj.should.have.property(prop, compObj[prop]);
  };
});

describe("The FunL parser", function() {
  it("should parse integers", function() {
    eparse("1").should.mapTo({type: 'int', value: 1});
  });

  it("should parse floats", function() {
    eparse("3.14").should.mapTo({type: 'float', value: 3.14});
  });

  it("should parse strings", function() {
    eparse('"hello world"').should.mapTo({type: 'string', value: "hello world"});
  });

  it("should parse strings with embedded newlines and escape codes", function() {
    eparse("\"hello\nworld\"").should.mapTo({type: 'string', value: "hello\nworld"});
    eparse("\"hello\\\nworld\"").should.mapTo({type: 'string', value: "hello\nworld"});
  });

  it("should parse booleans", function() {
    eparse("#t").should.mapTo({type: 'boolean', value: true});
    eparse("#f").should.mapTo({type: 'boolean', value: false});
  });

  it("should parse keywords", function() {
    eparse("range").should.mapTo({type: 'keyword', value: 'range'});
  });

  it("should parse sequences", function() {
    var it = eparse('[1 "two" 3]');
    it.should.have.property('type', 'seq');
    it.value.should.have.length(3);
    it.value[0].should.mapTo({type: 'int', value: 1});
  });

  it("should parse sequences with complex values", function() {
    var it = eparse('[inc:2 4 "hello"]');
    it.should.have.property('type', 'seq');
    it.value.should.have.length(3);
    it.value[0].should.have.property('type', 'application');
  });

  it("should parse maps", function() {
    var it = eparse('{"foo" 1 "bar" 2}');
    it.should.have.property('type', 'map');
    it.value.should.have.length(4);
    it.value[0].should.mapTo({type: "string", value: "foo"});
    it.value[1].should.mapTo({type: "int", value: 1});
  });

  it("can handle whitespace and newlines", function() {
    var it = eparse("[ 1\n  2  \n 3 ]\n");
    it.should.have.property('type', 'seq');
    it.value.should.have.length(3);
  });

  it("should parse function application", function() {
    var it = eparse("range:[1, 10]");
    it.should.have.property('type', 'application');
    it.value[0].should.mapTo({type: "keyword", value: "range"});
  });

  it("should parse tightly-bound function application", function() {
    var it = eparse("map[1]");
    it.should.have.property('type', 'application');
    it.value[0].should.mapTo({type: "keyword", value: "map"});
    it.value[1].should.mapTo({type: "int", value: 1});
  });

  it("should nest application right-to-left", function() {
    var it = eparse("first: second: third");
    it.value[0].should.mapTo({type: "keyword", value: "first"});
    it.value[1].should.have.property('type', 'application');
  });

  it("should use parentheses to nest application differently", function() {
    var it = eparse("(first:second):third");
    it.value[0].should.have.property('type', 'application');
    it.value[1].should.mapTo({type: "keyword", value: "third"});
  });

  it("should nest application differently with brackets", function() {
    var it = eparse("map[1]: [1, 2, 3]");
    it.type.should.eq("application");
    it.value[0].type.should.eq("application");
    it.value[0].value[0].should.mapTo({type: "keyword", value: "map"});
    it.value[1].type.should.eq("seq");
  });

  it("should handle construction", function() {
    var it = eparse("<first second third>");
    it.should.have.property('type', 'construction');
    it.value.should.have.length(3);
    it.value[0].should.mapTo({type: "keyword", value: "first"});
  });

  it("should handle composition", function() {
    var it = eparse("a:b | c");
    it.should.have.property('type', 'composition');
    it.value.should.have.length(2);
    it.value[1].should.mapTo({type: "keyword", value: "c"});
  });

  it("should handle composition with multiple pipes", function() {
    var it = eparse("a:b | c | d");
    it.should.have.property('type', 'composition');
    it.value.should.have.length(2);
    it.value[1].should.have.property('type', 'composition');
    it.value[1].value[1].should.mapTo({type: "keyword", value: "d"});
  });

  it("should handle conditionals", function() {
    var it = eparse("a ? b ; c");
    it.should.have.property("type", "conditional");
    it.value.should.have.length(3);
  });

  it("should be able to handle complex conditionals", function() {
    var it = eparse("(a | b):1 ? ~b:2 ; <b, c>");
    it.type.should.eq("conditional");
    it.value[0].type.should.eq("application");
    it.value[1].type.should.eq("application");
    it.value[2].type.should.eq("construction");
  });

  it("should handle definitions", function() {
    var it = eparse("length = (map:1) | (fold:+)");
    it.type.should.eq("definition");
    it.value.should.have.length(2);
    it.value[0].should.mapTo({type: "keyword", value: "length"});
  });

  it("should handle programs", function() {
    var it = parse("length = map[1] | fold[+] \nlength: [1, 2, 3]\n");
    it.type.should.eq("program");
    it.value.should.have.length(2);
    it.value[0].type.should.eq("definition");
    it.value[1].type.should.eq("application");
  });
});
