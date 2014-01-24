/*global describe,it,before,after,beforeEach,afterEach*/

"use strict";
var assert, expect, dbal, CompositeExpression;
expect = require('chai').expect;
assert = require('assert');
dbal = require('../../../index');
CompositeExpression = dbal.query.expression.CompositeExpression;

/**
 * dbal.query.expression.CompositeExpression
 */
describe('dbal.query.expression.CompositeExpression', function() {
	it('Exists', function() {
		assert((new CompositeExpression()) instanceof CompositeExpression);
	});
	describe('#toString', function() {
		var data = [[
                CompositeExpression.TYPE_AND,
                ['u.user = 1'],
                'u.user = 1'
            ],
            [
                CompositeExpression.TYPE_AND,
                ['u.user = 1', 'u.group_id = 1'],
                '(u.user = 1) AND (u.group_id = 1)'
            ],
            [
                CompositeExpression.TYPE_OR,
                ['u.user = 1'],
                'u.user = 1'
            ],
            [
                CompositeExpression.TYPE_OR,
                ['u.group_id = 1', 'u.group_id = 2'],
                '(u.group_id = 1) OR (u.group_id = 2)'
            ],
            [
                CompositeExpression.TYPE_AND,
                [
                    'u.user = 1',
                    new CompositeExpression(
						CompositeExpression.TYPE_OR, ['u.group_id = 1', 'u.group_id = 2']
                    )
                ],
                '(u.user = 1) AND ((u.group_id = 1) OR (u.group_id = 2))'
            ],
            [
                CompositeExpression.TYPE_OR,
                [
                    'u.group_id = 1',
                    new CompositeExpression(
						CompositeExpression.TYPE_AND, ['u.user = 1', 'u.group_id = 2']
                    )
                ],
                '(u.group_id = 1) OR ((u.user = 1) AND (u.group_id = 2))'
            ], ];
		data.forEach(function(data) {
			it('should yield : '+data[2], function() {
				var expr = new CompositeExpression(data[0], data[1]);
				assert.equal(data[2], expr.toString());
			});
		});
	});
	describe('#length', function() {
		it("should count parts", function() {
			var expr = new CompositeExpression(CompositeExpression.TYPE_OR, ['u.group_id = 1']);
			assert.equal(expr.length, 1);
			expr.add('u.group_id = 2');
			assert.equal(expr.length, 2);
		});
	});
});