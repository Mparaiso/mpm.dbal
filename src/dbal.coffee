"use strict"

dbal=
	query:
		expression:
			CompositeExpression:require './query/expression/CompositeExpression'
			ExpressionBuilder:require './query/expression/ExpressionBuilder'
			
module.exports = dbal