

###
Composite expression is responsible to build a group of similar expression.

###
class CompositeExpression 

    self= this
    get =(o)=> Object.defineProperty(@::,k,{get:v}) for k,v of o
    ###
    Constant that represents an AND composite expression.
    ###
    @TYPE_AND = 'AND'

    ###
    Constant that represents an OR composite expression.
    ###
    @TYPE_OR  = 'OR'

    ###*
    @property {String} type The instance type of composite expression.
    @property {Array} parts Each expression part of the composite expression.
    ###

    ###*
    Constructor.
    
    @param {String} type  Instance type of composite expression.
    @param {Array}  parts Composition of expressions to be joined on composite expression.
    ###
    constructor:(type, parts = [])->
        this.type = type
        this.parts = []
        this.addMultiple(parts)


    ###*
    Adds multiple parts to composite expression.
    
    @param {Array} parts
    @return {CompositeExpression}
    ###
    addMultiple:( parts = [])->
        for part in parts
            this.add(part)
        return this

    ###
    Adds an expression to composite expression.
    
    @param {Array} part
    @return {CompositeExpression}
    ###
    add:(part)->
        if part.length>0 or (part instanceof self and part.length > 0)
            this.parts.push(part)
        return this

    ###
    @property {Number} Retrieves the amount of expressions on composite expression.
    ###
    get length:->this.parts.length
    
    ###
    Retrieves the string representation of this composite expression.
    
    @return {String}
    ###
    toString:()->
        if this.parts.length == 1
            return this.parts[0]
        else
            return '(' + this.parts.join(") #{this.type} (") + ')'

    ###
    Returns the type of this composite expression (AND/OR).
    
    @return {String}
    ###
    gettype:()-> this.type

module.exports = CompositeExpression