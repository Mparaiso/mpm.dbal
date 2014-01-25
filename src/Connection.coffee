class Connection

	###
	Quotes a given input parameter.
	@param {Any} input The parameter to be quoted.
	@param {String} type  The type of the parameter.
	@return {String} The quoted parameter.
    ###
	quote:(input,type=null)->
		throw 'Not Implemented Yet'

	###
    Gets the binding type of a given type. The given type can be a PDO or DBAL mapping type.
    @param {Any} value The value to bind.
    @param {Any} type  The type to bind (PDO or DBAL).
    
    @return {Array} [0] => the (escaped) value, [1] => the binding type.
    ###
	getBindingInfo:(value,type)->
		throw 'Not Implemented yet'

module.exports = Connection
