module.exports = {
	isImmutable: require('./utils/isImmutable'),
	asImmutable: require('./utils/asImmutable'),
	o: {
		addCId:       require('./object/addCId'),
		merge:        require('./object/merge'),
	},
	a: {
		addCIds:      require('./array/addCIds'),
		merge:        require('./array/merge'),
		filter:       require('./array/filter'),
		find:         require('./array/find'),
		get:          require('./array/get'),
		reject:       require('./array/reject'),
	}
}
