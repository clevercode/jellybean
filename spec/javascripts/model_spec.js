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
    var Klass;
    Klass = (function() {
      function Klass() {
        Klass.__super__.constructor.apply(this, arguments);
      }
      __extends(Klass, Jellybean.Model);
      Klass.setModelName('Klass');
      Klass.setAttributes(['id', 'text']);
      return Klass;
    })();
    it('should exist', function() {
      return expect(Jellybean.Model).toBeDefined();
    });
    describe('subclassing', function() {
      it('should create a subclass', function() {
        expect(Klass).toBeDefined();
        return expect(Klass.modelName).toBe('Klass');
      });
      return it('should set attributes', function() {
        expect(Klass.attributes).toContain('id');
        return expect(Klass.attributes).toContain('text');
      });
    });
    describe('Model.init(attributes)', function() {
      beforeEach(function() {
        return this.k = Klass.init({
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
    describe('Model.create(attributes)', function() {
      beforeEach(function() {
        return this.k = Klass.create({
          text: 'example'
        });
      });
      return it('should create a saved object', function() {
        return expect(this.k.newRecord).toBe(false);
      });
    });
    describe('Model.inst(attributes)', function() {
      beforeEach(function() {
        return this.k = Klass.inst({
          id: 1
        });
      });
      it('should create a saved object', function() {
        return expect(this.k.newRecord).toBe(false);
      });
      return it('should require an id', function() {
        var fn;
        fn = __bind(function() {
          return Klass.inst({});
        }, this);
        return expect(fn).toThrow("An id is required to reinitialize a record");
      });
    });
    describe('Model.allocate', function() {
      return it('should create the object without initializing it', function() {
        this.k = Klass.allocate();
        expect(this.k.newRecord).not.toBeDefined();
        return expect(this.k.attributes).toBeNull();
      });
    });
    describe('#read(attr)', function() {
      beforeEach(function() {
        return this.k = Klass.init({
          text: 'example text'
        });
      });
      it('should return the value from the attributes hash', function() {
        return expect(this.k.read('text')).toEqual('example text');
      });
      return it('should be used by the property accessor', function() {
        spyOn(this.k, 'read');
        this.k.text;
        return expect(this.k.read).toHaveBeenCalledWith('text');
      });
    });
    describe('#write(attr, val)', function() {
      it('should return the value assigned to it', function() {
        var k, result;
        k = Klass.init({});
        result = k.write('text', 'example text');
        return expect(result).toEqual('example text');
      });
      it('should be used by the property accessor', function() {
        var k;
        k = Klass.init({});
        spyOn(k, 'write');
        k.text = 'example text';
        return expect(k.write).toHaveBeenCalledWith('text', 'example text');
      });
      return it('should be used when initializing the attributes', function() {
        var k;
        spyOn(Klass.prototype, 'write');
        k = Klass.init({
          text: 'example text'
        });
        return expect(Klass.prototype.write).toHaveBeenCalledWith('text', 'example text');
      });
    });
    return describe('#clone()', function() {
      var c, k;
      k = null;
      c = null;
      beforeEach(function() {
        k = Klass.init();
        return c = k.clone();
      });
      it('should create a copy with entangled attributes', function() {
        k.text = 'example text';
        expect(c.text).toEqual(k.text);
        k.text = 'new example text';
        expect(c.text).toEqual(k.text);
        c.text = 'quantum entanglement';
        return expect(k.text).toEqual(c.text);
      });
      return it('should create a copy with entangled events', function() {
        var callback1, callback2;
        callback1 = jasmine.createSpy();
        callback2 = jasmine.createSpy();
        k.bind('call1', callback1);
        c.trigger('call1');
        expect(callback1).toHaveBeenCalled();
        c.bind('call2', callback2);
        k.trigger('call2');
        return expect(callback2).toHaveBeenCalled();
      });
    });
  });
}).call(this);
