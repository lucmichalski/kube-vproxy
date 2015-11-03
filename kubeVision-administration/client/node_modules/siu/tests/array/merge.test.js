var test  = require('tape-catch');
var SI    = require('seamless-immutable');
var siu   = require('../../index.js');

test('raise if not immutable', function(t) {
	var items = [{
		name: 'Sara'
	}];

	function merge() {
		siu.a.merge(items, items, 'id');
	}

	t.throws(merge);
	t.end();

});

test('updates an existing item', function (t) {
	var items = SI([{
		id: 1,
		name: 'Sara'
	}]);

	var moreItems = SI([{
		id: 1,
		name: 'Julia'
	}]);

	var newItems = siu.a.merge(items, moreItems, 'id');

	t.ok(newItems.length === 1);
	t.ok(newItems[0].name === 'Julia');
	t.end();
});

test('updates using a given key', function (t) {
	var items = SI([{
		_id: 1,
		name: 'Sara'
	}]);

	var moreItems = SI([{
		_id: 1,
		name: 'Julia'
	}]);

	var newItems = siu.a.merge(items, moreItems, '_id');

	t.ok(newItems.length === 1);
	t.ok(newItems[0].name === 'Julia');
	t.end();
});

test('adds a new item', function(t) {
	var items = SI([{
		id: 1,
		name: 'Sara'
	}]);

	var moreItems = SI([{
		id: 2,
		name: 'Julia'
	}]);

	var newItems = siu.a.merge(items, moreItems, 'id');

	t.ok(newItems.length === 2);
	t.end();
});

test('adds one item', function(t) {
	var items = SI([{
		id: 1,
		name: 'Sara'
	}]);

	var item = SI({
		id: 2,
		name: 'Julia'
	});

	var newItems = siu.a.merge(items, item, 'id');

	t.ok(newItems.length === 2);
	t.end();
});


