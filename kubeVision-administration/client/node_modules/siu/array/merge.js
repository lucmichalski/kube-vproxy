var _              = require('lodash');
var isImmutable    = require('../utils/isImmutable');
var wrapAsArray    = require('../utils/wrapAsArray');
var asImmutable    = require('../utils/asImmutable');
var addCIds        = require('./addCIds');

/**
If a record has a cid then it is coming from the server
in this case it needs to replace a record in the store with with id set to cid
cid should be discarded after use otherwise it will trigger further 'creates'

@param  {array} records Records to process
@return {object}        Records processed into a map based on cid/id
*/

function merge(array, recordOrRecords, key) {
	if (!isImmutable(array))           throw new Error('Array must be immutable');
	if (!isImmutable(recordOrRecords)) throw new Error('recordOrRecords must be immutable');
	if (!key)                          throw new Error('Expected key');

	var updatedRecords = wrapAsArray(recordOrRecords);

	// merge all records with a key
	var recordsWithKey = _.filter(updatedRecords, function (record) {
		return record[key] != null;
	});

	var recordsWithoutKey = _.filter(updatedRecords, function (record) {
		return record[key] == null;
	});

	var recordsWithKeyMap = _.indexBy(recordsWithKey, key);

	// add the rest

	array = array.map(function(existingRecord) {
		if (!existingRecord[key]) throw new Error('Expected exiting record.' + key);

		var existingId = existingRecord[key];

		var record = recordsWithKeyMap[existingId];
		if (record) {
			recordsWithKeyMap = _.omit(recordsWithKeyMap, existingId);
			return record;
		} else {
			return existingRecord;
		}

	});

	// insert new records with key
	var newRecords = _.values(recordsWithKeyMap);
	array = array.concat(newRecords);

	// add records without keys
	array = array.concat(recordsWithoutKey);


	return array;
}

module.exports = merge;

