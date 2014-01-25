"use strict"

Connection = require '../../Connection'
CompositeExpression= require './CompositeExpression'

###
ExpressionBuilder class is responsible to dynamically create SQL query parts.
###
class ExpressionBuilder

    self = this
    @EQ  = '='
    @NEQ = '<>'
    @LT  = '<'
    @LTE = '<='
    @GT  = '>'
    @GTE = '>='

    ###
    The DBAL Connection.
    
    @property {Connection}
    ###

    ###
    Initializes a new <tt>ExpressionBuilder</tt>.
    
    @param {Connection} connection The DBAL Connection.
    ###
    constructor:(connection=null)->
    
        this.connection = connection
    

    ###
    Creates a conjunction of the given boolean expressions.
    
    Example:
    
        
        // (u.type = ?) AND (u.role = ?)
        expr.andX('u.type = ?', 'u.role = ?'))
    
    @param mixed x Optional clause. Defaults = null, but requires
                    at least one defined when converting to string.
    
    @return \Doctrine\DBAL\Query\Expression\CompositeExpression
    ###
    andX:(x = null)->
    
        return new CompositeExpression(CompositeExpression.TYPE_AND, arguments)
    

    ###
    Creates a disjunction of the given boolean expressions.
    
    Example:
    
        
        // (u.type = ?) OR (u.role = ?)
        qb.where(qb.expr().orX('u.type = ?', 'u.role = ?'))
    
    @param mixed x Optional clause. Defaults = null, but requires
                    at least one defined when converting to string.
    
    @return \Doctrine\DBAL\Query\Expression\CompositeExpression
    ###
    orX:(x = null)->
    
        return new CompositeExpression(CompositeExpression.TYPE_OR, arguments)
    

    ###
    Creates a comparison expression.
    
    @param mixed  x        The left expression.
    @param string operator One of the ExpressionBuilder.* constants.
    @param mixed  y        The right expression.
    
    @return string
    ###
    comparison:(x, operator, y)->
    
        return x + ' ' + operator + ' ' + y
    

    ###
    Creates an equality comparison expression with the given arguments.
    
    First argument is considered the left expression and the second is the right expression.
    When converted to string, it will generated a <left expr> = <right expr>. Example:
    
        // u.id = ?
        expr.eq('u.id', '?')
    
    @param mixed x The left expression.
    @param mixed y The right expression.
    
    @return string
    ###
    eq:(x, y)->
        return this.comparison(x, self.EQ, y)

    ###
    Creates a non equality comparison expression with the given arguments.
    First argument is considered the left expression and the second is the right expression.
    When converted to string, it will generated a <left expr> <> <right expr>. Example:
    
        
        // u.id <> 1
        q.where(q.expr().neq('u.id', '1'))
    
    @param mixed x The left expression.
    @param mixed y The right expression.
    
    @return string
    ###
    neq:(x, y)->
        return this.comparison(x, self.NEQ, y)

    ###
    Creates a lower-than comparison expression with the given arguments.
    First argument is considered the left expression and the second is the right expression.
    When converted to string, it will generated a <left expr> < <right expr>. Example:
    
        
        // u.id < ?
        q.where(q.expr().lt('u.id', '?'))
    
    @param mixed x The left expression.
    @param mixed y The right expression.
    
    @return string
    ###
    lt:(x, y)->
        return this.comparison(x, self.LT, y)

    ###
    Creates a lower-than-equal comparison expression with the given arguments.
    First argument is considered the left expression and the second is the right expression.
    When converted to string, it will generated a <left expr> <= <right expr>. Example:
    
        
        // u.id <= ?
        q.where(q.expr().lte('u.id', '?'))
    
    @param mixed x The left expression.
    @param mixed y The right expression.
    
    @return string
    ###
    lte:(x, y)->
        return this.comparison(x, self.LTE, y)

    ###
    Creates a greater-than comparison expression with the given arguments.
    First argument is considered the left expression and the second is the right expression.
    When converted to string, it will generated a <left expr> > <right expr>. Example:
    
        
        // u.id > ?
        q.where(q.expr().gt('u.id', '?'))
    
    @param mixed x The left expression.
    @param mixed y The right expression.
    
    @return string
    ###
    gt:(x, y)->
    
        return this.comparison(x, self.GT, y)

    ###
    Creates a greater-than-equal comparison expression with the given arguments.
    First argument is considered the left expression and the second is the right expression.
    When converted to string, it will generated a <left expr> >= <right expr>. Example:
    
        
        // u.id >= ?
        q.where(q.expr().gte('u.id', '?'))
    
    @param mixed x The left expression.
    @param mixed y The right expression.
    
    @return string
    ###
    gte:(x, y)->
        return this.comparison(x, self.GTE, y)
    

    ###
    Creates an IS NULL expression with the given arguments.
    
    @param string x The field in string format to be restricted by IS NULL.
    
    @return string
    ###
    isNull:(x)->
        return x + ' IS NULL'

    ###
    Creates an IS NOT NULL expression with the given arguments.
    
    @param string x The field in string format to be restricted by IS NOT NULL.
    
    @return string
    ###
    isNotNull:(x)->
        return x + ' IS NOT NULL'

    ###
    Creates a LIKE() comparison expression with the given arguments.
    
    @param string x Field in string format to be inspected by LIKE() comparison.
    @param mixed  y Argument to be used in LIKE() comparison.
    
    @return string
    ###
    like:(x, y)->
        return this.comparison(x, 'LIKE', y)

    ###
    Creates a NOT LIKE() comparison expression with the given arguments.
    
    @param string x Field in string format to be inspected by NOT LIKE() comparison.
    @param mixed y Argument to be used in NOT LIKE() comparison.
    
    @return string
    ###
    notLike:(x, y)->
        return this.comparison(x, 'NOT LIKE', y)

    ###
    Creates a IN () comparison expression with the given arguments.
    
    @param string x The field in string format to be inspected by IN() comparison.
    @param array  y The array of values to be used by IN() comparison.
    
    @return string
    ###
    in:(x,y)->
        return this.comparison(x, 'IN', '('+y.join(', ')+')')

    ###
    Creates a NOT IN () comparison expression with the given arguments.
    
    @param {string} x The field in string format to be inspected by NOT IN() comparison.
    @param {array} y  The array of values to be used by NOT IN() comparison.
    
    @return string
    ###
    notIn:(x,y)->
        return this.comparison(x, 'NOT IN', '('+y.join(', ')+')')

    notin: @::notIn

    ###
    Quotes a given input parameter.
    
    @param mixed       input The parameter to be quoted.
    @param string|null type  The type of the parameter.
    
    @return string
    ###
    literal:(input, type = null)->
        ###@TODO edit quoting###
        #return this.connection.quote(input, type)
        if typeof input == 'string'
            "'#{input}'"
        else
            input
    
module.exports = ExpressionBuilder
