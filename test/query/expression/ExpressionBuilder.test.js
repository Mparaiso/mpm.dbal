/*global describe,it,before,after,beforeEach,afterEach*/
"use strict"
var assert, expect, dbal, ExpressionBuilder, CompositeExpression;
expect = require('chai').expect;
assert = require('assert');
dbal = require('../../../index');
ExpressionBuilder = dbal.query.expression.ExpressionBuilder;
CompositeExpression = dbal.query.expression.CompositeExpression;
/**
 * dbal.query.expression.ExpressionBuilder
 */
describe('dbal.query.expression.ExpressionBuilder', function() {

	beforeEach(function() {
		this.conn = {};
		this.expr = new ExpressionBuilder({});
	});

	describe('#andX', function() {
		var dataForAndX = [
            [
                ['u.user = 1'],
                'u.user = 1'
            ],
            [
                ['u.user = 1', 'u.group_id = 1'],
                '(u.user = 1) AND (u.group_id = 1)'
            ],
            [
                ['u.user = 1'],
                'u.user = 1'
            ],
            [
                ['u.group_id = 1', 'u.group_id = 2'],
                '(u.group_id = 1) AND (u.group_id = 2)'
            ],
            [
                [
                    'u.user = 1',
                    new CompositeExpression(
						CompositeExpression.TYPE_OR, ['u.group_id = 1', 'u.group_id = 2'])
                ],
                '(u.user = 1) AND ((u.group_id = 1) OR (u.group_id = 2))'
            ],
            [
                [
                    'u.group_id = 1',
                    new CompositeExpression(
						CompositeExpression.TYPE_AND, ['u.user = 1', 'u.group_id = 2'])
                ],
                '(u.group_id = 1) AND ((u.user = 1) AND (u.group_id = 2))'
            ],
        ];

		dataForAndX.forEach(function(data) {
			it('should yield ' + data[1], function() {
				var composite = this.expr.andX();
				data[0].forEach(function(part) {
					composite.add(part);
				});
				assert.equal(composite.toString(), data[1]);
			});
		});
	});
	/**
     * @dataProvider provideDataForOrX
     
    public function testOrX(parts, expected]
    {
        composite = this.expr.orX();

        foreach (parts as part) {
            composite.add(part);
        }

        assert.equal(expected, (string) composite);
    }

    public function provideDataForOrX()
    {
        return [
            [
                ['u.user = 1'),
                'u.user = 1'
            ),
            [
                ['u.user = 1', 'u.group_id = 1'),
                '(u.user = 1) OR (u.group_id = 1)'
            ),
            [
                ['u.user = 1'),
                'u.user = 1'
            ),
            [
                ['u.group_id = 1', 'u.group_id = 2'),
                '(u.group_id = 1) OR (u.group_id = 2)'
            ),
            [
                [
                    'u.user = 1',
                    new CompositeExpression(
                        CompositeExpression.TYPE_OR,
                        ['u.group_id = 1', 'u.group_id = 2']
                    ]
                ),
                '(u.user = 1) OR ((u.group_id = 1) OR (u.group_id = 2))'
            ),
            [
                [
                    'u.group_id = 1',
                    new CompositeExpression(
                        CompositeExpression.TYPE_AND,
                        ['u.user = 1', 'u.group_id = 2']
                    ]
                ),
                '(u.group_id = 1) OR ((u.user = 1) AND (u.group_id = 2))'
            ),
        );
    }

*/
	describe('#comparison', function() {
    [
            ['u.user_id', ExpressionBuilder.EQ, '1', 'u.user_id = 1'],
            ['u.user_id', ExpressionBuilder.NEQ, '1', 'u.user_id <> 1'],
            ['u.salary', ExpressionBuilder.LT, '10000', 'u.salary < 10000'],
            ['u.salary', ExpressionBuilder.LTE, '10000', 'u.salary <= 10000'],
            ['u.salary', ExpressionBuilder.GT, '10000', 'u.salary > 10000'],
            ['u.salary', ExpressionBuilder.GTE, '10000', 'u.salary >= 10000'],
    ].forEach(function(data) {
			it('should yield ' + data[3], function() {
				var part = this.expr.comparison(data[0], data[1], data[2]);
				assert.equal(data[3], part.toString());
			});
		});
	});

	describe('#eq', function() {
		it('', function() {
			assert.equal('u.user_id = 1', this.expr.eq('u.user_id', '1'));
		});
	});

	describe('#neq', function() {
		it('', function() {
			assert.equal('u.user_id <> 1', this.expr.neq('u.user_id', '1'));
		});
	});

	describe('#lt', function() {
		it('', function() {
			assert.equal('u.salary < 10000', this.expr.lt('u.salary', '10000'));
		});
	});

	describe('#lte', function() {
		it('', function() {
			assert.equal('u.salary <= 10000', this.expr.lte('u.salary', '10000'));
		});
	});

	describe('#gt', function() {
		it('', function() {
			assert.equal('u.salary > 10000', this.expr.gt('u.salary', '10000'));
		});
	});

	describe('#gte', function() {
		it('', function() {
			assert.equal('u.salary >= 10000', this.expr.gte('u.salary', '10000'));
		});
	});

	describe('#isNull', function() {
		it('', function() {
			assert.equal('u.deleted IS NULL', this.expr.isNull('u.deleted'));
		});
	});

	describe('#isNotNull', function() {
		it('', function() {
			assert.equal('u.updated IS NOT NULL', this.expr.isNotNull('u.updated'));
		});
	});
	describe('#in', function() {
		it('', function() {
			assert.equal('u.groups IN (1, 3, 4, 7)', this.expr. in ('u.groups', [1, 3, 4, 7]));
		});
	});
	describe('#notIn', function() {
		it('', function() {
			assert.equal('u.groups NOT IN (1, 3, 4, 7)', this.expr.notIn('u.groups', [1, 3, 4, 7]));
		});
	});

});