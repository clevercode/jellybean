(function() {
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  }, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  describe('Jellybean.Model', function() {
    beforeEach(function() {
      return this.Klass = (function() {
        function Klass() {
          Klass.__super__.constructor.apply(this, arguments);
        }
        __extends(Klass, Jellybean.Model);
        Klass.setModelName('Klass');
        Klass.setAttributes(['id', 'text']);
        return Klass;
      })();
    });
    it('should exist', function() {
      return expect(Jellybean.Model).toBeDefined();
    });
    describe('subclassing', function() {
      it('should create a subclass', function() {
        expect(this.Klass).toBeDefined();
        return expect(this.Klass.modelName).toBe('Klass');
      });
      return it('should set attributes', function() {
        expect(this.Klass.attributes).toContain('id');
        return expect(this.Klass.attributes).toContain('text');
      });
    });
    describe('#init(attributes)', function() {
      beforeEach(function() {
        return this.k = this.Klass.init({
          text: 'example'
        });
      });
      it('should create an object of the model type', function() {
        return expect(this.k.modelName).toBe('Klass');
      });
      return it('should create an unsaved object', function() {
        return expect(this.k.newRecord).toBe(true);
      });
    });
    describe('#create(attributes)', function() {
      beforeEach(function() {
        return this.k = this.Klass.create({
          text: 'example'
        });
      });
      return it('should create a saved object', function() {
        return expect(this.k.newRecord).toBe(false);
      });
    });
    return describe('#inst(attributes)', function() {
      beforeEach(function() {
        return this.k = this.Klass.inst({
          id: 1
        });
      });
      it('should create a saved object', function() {
        return expect(this.k.newRecord).toBe(false);
      });
      return it('should require an id', function() {
        var fn;
        fn = __bind(function() {
          return this.Klass.inst({});
        }, this);
        return expect(fn).toThrow("An id is required to reinitialize a record");
      });
    });
  });
}).call(this);
