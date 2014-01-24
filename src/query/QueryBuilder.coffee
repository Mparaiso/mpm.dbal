# "use strict"
# CompositeExpression = require './expression/CompositeExpression'
# Connection = require '../Connection'

# ###
# QueryBuilder class is responsible to dynamically create SQL queries.

# Important: Verify that every feature you use will work with your database vendor.
# SQL Query Builder does not attempt to validate the generated SQL at all.

# The query builder does no validation whatsoever if certain features even work with the
# underlying database vendor. Limit queries and joins are NOT applied to UPDATE and DELETE statements
# even if some vendors such as MySQL support it.
# ###

# class QueryBuilder

#     self = this
#     ###
#     The query types.
#     ###
#     @SELECT = 0 
#     @DELETE = 1 
#     @UPDATE = 2 
#     @INSERT = 3 
#     ###
#     The builder states.
#     ###
#     @STATE_DIRTY = 0 
#     @STATE_CLEAN = 1 
#     ###
#     @property {dbal.Connection} connection The DBAL Connection.
#     @property {Array} sqlParts The array of SQL parts collected.
#     @property {String} [sql] The complete SQL string for this query
#     @property {Array} The query parameters.
#     @property {Array} paramTypes The parameter type map of this query.
#     @property {Number} type The type of query this is. Can be select, update or delete.
#     @property {Number} state The state of the query object. Can be dirty or clean.
#     @property {Number} firstResult The index of the first result to retrieve.
#     @property {Number} maxResults The maximum number of results to retrieve.
#     @property {Number} boundCounter The counter of bound parameters used with @see bindValue).
#     ###

#     ###
#     Initializes a new <tt>QueryBuilder</tt>.
#     @param {dbal.Connection} connection The DBAL Connection.
#      ###
#     constructor:(@connection)->
#         @boundCounter = 0 
#         @maxResults = null 
#         @firstResult=null 
#         @state= self.STATE_CLEAN 
#         @sqlParts = {
#             'select'  : {},
#             'from'    : {},
#             'join'    : {},
#             'set'     : {},
#             'where'   : null,
#             'groupBy' : {},
#             'having'  : null,
#             'orderBy' : {},
#             'values'  : {},
#         }
#         @type= self.SELECT 
#         @paramTypes={} 
#         @params={} 
#         @sql=""

#     ###
#     Gets an ExpressionBuilder used for object-oriented construction of query expressions.
#     This producer method is intended for convenient inline usage. Example:
#       <code>
#      qb = conn.createQueryBuilder()
#          .select('u')
#          .from('users', 'u')
#          .where(qb.expr().eq('u.id', 1)) 
#     </code>
#     For more complex expression construction, consider storing the expression
#     builder object in a local variable.
#       @return \Doctrine\DBAL\Query\Expression\ExpressionBuilder
#     ###
#     pubexpr:()->@connection.getExpressionBuilder() 

#     ###
#      Gets the type of the currently built query.
#           @return integer
#     ###
#     gettype:()->@type 

#     ###
#      Gets the associated DBAL Connection for this query builder.
#     @return dbal.Connection
#     ###
#     getconnection:()->@connection 
    
#     ###
#     Gets the state of this query builder instance.
#     @return {Number} Either QueryBuilder.STATE_DIRTY or QueryBuilder.STATE_CLEAN.
#     ###
#     getstate:()->@state 

#     ###
#     Executes this query using the bound parameters and their types.
#     Uses @see Connection.executeQuery for select statements and @see Connection.executeUpdate
#     for insert, update and delete statements.
#     @return mixed
#     ###
#     execute:()->
#         if @type == self.SELECT
#             @connection.executeQuery(@getSQL(), @params, @paramTypes) 
#          else 
#             @connection.executeUpdate(@getSQL(), @params, @paramTypes) 

#     ###
#     Gets the complete SQL string formed by the current specifications of this QueryBuilder.
#     <code>
#          qb = em.createQueryBuilder()
#              .select('u')
#              .from('User', 'u')
#          echo qb.getSQL()  // SELECT u FROM User u
#      </code>
#     @return string The SQL query string.
#     ###
#     getsql:()->
#         if @sql != null && @state == self.STATE_CLEAN
#             return @sql 
#         switch @type
#             when self.INSERT
#                 sql = @getSQLForInsert() 
#             when self.DELETE
#                 sql = @getSQLForDelete() 
#             when self.UPDATE
#                 sql = @getSQLForUpdate() 
#             when self.SELECT
#             else
#                 sql = @getSQLForSelect() 
#         @state = self.STATE_CLEAN 
#         @sql = sql 
#         return sql 

#     ###
#     Sets a query parameter for the query being constructed.
#     <code>
#          qb = conn.createQueryBuilder()
#              .select('u')
#              .from('users', 'u')
#              .where('u.id = :user_id')
#              .setParameter(':user_id', 1) 
#      </code>
#     @param {String|Number} key   The parameter position or name.
#     @param {Any}          value The parameter value.
#     @param {String|Null}    type  One of the PDO.PARAM_* constants.
#     @return QueryBuilder This QueryBuilder instance.
#     ###
#     setparameter:(key, Value, type = null)->
    
#         if type != null
#             @paramTypes[key] = type 
#         @params[key] = value 
#         return this 

#     ###
#     Sets a collection of query parameters for the query being constructed.
#     <code>
#          qb = conn.createQueryBuilder()
#              .select('u')
#              .from('users', 'u')
#              .where('u.id = :user_id1 OR u.id = :user_id2')
#              .setParameters({
#                  ':user_id1' : 1,
#                  ':user_id2' : 2
#             }) 
#     </code>
#     @param {Object} params The query parameters to set.
#     @param {Object} types  The query parameters types to set.
#     @return QueryBuilder This QueryBuilder instance.
#     ###
#     setparameters:(params,types = {})->
#         @paramTypes = types 
#         @params = params 
#         return this 

#     ###
#     Gets all defined query parameters for the query being constructed.
#     @return {Object} The currently defined query parameters.
#      ###
#     getparameters:()->return @params 
    

#     ###
#     Gets a (previously set) query parameter of the query being constructed.
#     @param mixed key The key (index or name) of the bound parameter.
#     @return mixed The value of the bound parameter.
#      ###
#     getparameter:(key)-> @params[key]
    

#     ###
#     Sets the position of the first result to retrieve (the "offset").
#     @param {Number} firstResult The first result to return.
#     @return QueryBuilder This QueryBuilder instance.
#     ###
#     setfirstresult:(firstResult)->
#         @state = self.STATE_DIRTY 
#         @firstResult = firstResult 
#         return this 
    

#     ###
#     Gets the position of the first result the query object was set to retrieve (the "offset").
#     Returns NULL if @link setFirstResult was not applied to this QueryBuilder.
#     @return integer The position of the first result.
#     ###
#     getfirstresult:()->@firstResult 

#     ###
#     Sets the maximum number of results to retrieve (the "limit").
#     @param integer maxResults The maximum number of results to retrieve.
#     @return \Doctrine\DBAL\Query\QueryBuilder This QueryBuilder instance.
#     ###
#     setmaxResults:(maxResuLts)->
#         @state = self.STATE_DIRTY 
#         @maxResults = maxResults 
#         return this 

#     ###
#     Gets the maximum number of results the query object was set to retrieve (the "limit").
#     Returns NULL if @link setMaxResults was not applied to this query builder.
#     @return integer The maximum number of results.
#     ###
#     getmaxResults:()->@maxResults 

#     ###
#     Either appends to or replaces a single, generic query part.
#     The available parts are: 'select', 'from', 'set', 'where',
#     'groupBy', 'having' and 'orderBy'.
#     @param string  sqlPartName
#     @param string  sqlPart
#     @param boolean append
#     @return \Doctrine\DBAL\Query\QueryBuilder This QueryBuilder instance.
#     ###
#     add:(sqlPartName, sqlPart, append = False)->
    
#         isArray = sqlPart instanceof Array
#         isMultiple = typeof @sqlParts[sqlPartName] == 'object'

#         if (isMultiple && !isArray) 
#             sqlPart = [sqlPart]

#         @state = self.STATE_DIRTY 

#         if append
#             if sqlPartName == "orderBy" || sqlPartName == "groupBy" || sqlPartName == "select" || sqlPartName == "set" 
#                 for part in sqlPart
#                     @sqlParts[sqlPartName].push(part)
                
#             #else if  isArray && is_array(sqlPart[key(sqlPart)])) 
#             #    key = key(sqlPart) 
#             #    @sqlParts[sqlPartName][key].push(sqlPart[key])
#             else if isMultiple
#                 @sqlParts[sqlPartName].push(sqlPart)
#             else 
#                 @sqlParts[sqlPartName].push(sqlPart)
#             return this 
#         else
#             @sqlParts[sqlPartName] = sqlPart 
#             return this 

#     ###
#     Specifies an item that is to be returned in the query result.
#     Replaces any previously specified selections, if any.
#     <code>
#     qb = conn.createQueryBuilder()
#         .select('u.id', 'p.id')
#         .from('users', 'u')
#         .leftJoin('u', 'phonenumbers', 'p', 'u.id = p.user_id') 
#     </code>
#     @param mixed select The selection expressions.
#     @return {QueryBuilder} This QueryBuilder instance.
#     ###
#     select:(select)->
#         @type = self.SELECT 
#         if !select
#             return this 
#         selects = if select instanceof Array then select else [].slice.apply(arguments)
#         return @add('select', selects, false) 

#     ###
#     Adds an item that is to be returned in the query result.
#     <code>
#          qb = conn.createQueryBuilder()
#              .select('u.id')
#              .addSelect('p.id')
#              .from('users', 'u')
#              .leftJoin('u', 'phonenumbers', 'u.id = p.user_id') 
#     </code>
#     @param mixed select The selection expression.
#     @return {QueryBuilder} This QueryBuilder instance.
#     ###
#     addselect:(select = null)->
    
#     @type = self.SELECT 
#     if not select
#         return this 
#     else
#         selects = if select instanceof Array then select else arguments
#         return @add('select', selects, true) 

#     ###
#     Turns the query being built into a bulk delete query that ranges over
#     a certain table.
#     <code>
#         qb = conn.createQueryBuilder()
#              .delete('users', 'u')
#              .where('u.id = :user_id') 
#              .setParameter(':user_id', 1) 
#      </code>
#     @param {String} delete The table whose rows are subject to the deletion.
#     @param {String} alias  The table alias used in the constructed query.
#     @return {QueryBuilder} This QueryBuilder instance.
#     ###
#     delete:(_delete = null, alias = null)->
#         @type = self.DELETE 
#         if  not _delete
#             return this 
#         else
#             return @add('from',{'table' : _delete,'alias' : alias})

#     ###
#      Turns the query being built into a bulk update query that ranges over
#      a certain table
#           <code>
#          qb = conn.createQueryBuilder()
#              .update('users', 'u')
#              .set('u.password', md5('password'))
#              .where('u.id = ?') 
#      </code>
#     @param string update The table whose rows are subject to the update.
#     @param string alias  The table alias used in the constructed query.
#     @return \Doctrine\DBAL\Query\QueryBuilder This QueryBuilder instance.
#     ###
#     update:(update = null, alias = null)->
#         @type = self.UPDATE 
#         if ( ! update) 
#             return this 
#         return @add('from', {'table' : update,'alias' : alias})

#     ###
#      Turns the query being built into an insert query that inserts into
#      a certain table
#           <code>
#          qb = conn.createQueryBuilder()
#              .insert('users')
#              .values(
#                  array(
#                      'name' : '?',
#                      'password' : '?'
#                  )
#              ) 
#      </code>
#      @param {string} insert The table into which the rows should be inserted.
#     @return {QueryBuilder} This QueryBuilder instance.
#     ###
#     insert:(insert = null)->
#         @type = self.INSERT 
#         if not insert
#             return this 
#         return @add('from', 'table' : insert)

#     ###
#      Creates and adds a query root corresponding to the table identified by the
#      given alias, forming a cartesian product with any existing query roots.
#           <code>
#          qb = conn.createQueryBuilder()
#              .select('u.id')
#              .from('users', 'u')
#      </code>
#     @param {string} from   The table.
#     @param {string} alias  The alias of the table.
#     @return {QueryBuilder} This QueryBuilder instance.
#     ###
#     from:(from, alias)->
#         return @add('from', {'table' : from,'alias' : alias},true)

#     ###
#      Creates and adds a join to the query.
#           <code>
#          qb = conn.createQueryBuilder()
#              .select('u.name')
#              .from('users', 'u')
#              .join('u', 'phonenumbers', 'p', 'p.is_primary = 1') 
#      </code>
#     @param string fromAlias The alias that points to a from clause.
#     @param string join      The table name to join.
#     @param {string} alias     The alias of the join table.
#     @param {string} condition The condition for the join.
#     @return \Doctrine\DBAL\Query\QueryBuilder This QueryBuilder instance.
#     ###
#     join:(fromalias, join, alIas, condition = null)->
#         return @innerJoin(fromAlias, join, alias, condition) 
    
#     ###
#      Creates and adds a join to the query.
#           <code>
#          qb = conn.createQueryBuilder()
#              .select('u.name')
#              .from('users', 'u')
#              .innerJoin('u', 'phonenumbers', 'p', 'p.is_primary = 1') 
#      </code>
#     @param string fromAlias The alias that points to a from clause.
#     @param string join      The table name to join.
#     @param string alias     The alias of the join table.
#     @param string condition The condition for the join.
#     @return \Doctrine\DBAL\Query\QueryBuilder This QueryBuilder instance.
#     ###
#     innerjoin:(fromAlias, join, alIas, condition = null)->
#         return @add('join',{
#             fromAlias :{
#                 'joinType'      : 'inner',
#                 'joinTable'     : join,
#                 'joinAlias'     : alias,
#                 'joinCondition' : condition
#             }
#         }, true) 
    

#     ###
#     Creates and adds a left join to the query.
#           <code>
#          qb = conn.createQueryBuilder()
#              .select('u.name')
#              .from('users', 'u')
#              .leftJoin('u', 'phonenumbers', 'p', 'p.is_primary = 1') 
#      </code>
#     @param string fromAlias The alias that points to a from clause.
#     @param string join      The table name to join.
#     @param string alias     The alias of the join table.
#     @param string condition The condition for the join.
#     @return \Doctrine\DBAL\Query\QueryBuilder This QueryBuilder instance.
#     ###
#     leftjoin:(fromalias, join, alIas, condition = null)->
#         return @add('join', {
#             fromAlias : {
#                 'joinType'      : 'left',
#                 'joinTable'     : join,
#                 'joinAlias'     : alias,
#                 'joinCondition' : condition
#             }
#         }, true) 
    

#     ###
#      Creates and adds a right join to the query.
#           <code>
#          qb = conn.createQueryBuilder()
#              .select('u.name')
#              .from('users', 'u')
#              .rightJoin('u', 'phonenumbers', 'p', 'p.is_primary = 1') 
#      </code>
#     @param string fromAlias The alias that points to a from clause.
#     @param string join      The table name to join.
#     @param string alias     The alias of the join table.
#     @param string condition The condition for the join.
#     @return \Doctrine\DBAL\Query\QueryBuilder This QueryBuilder instance.
#     ###
#     rightjoin:(fromAlias, join, alIas, condition = null)->
#         return @add('join', {
#             fromAlias : {
#                 'joinType'      : 'right',
#                 'joinTable'     : join,
#                 'joinAlias'     : alias,
#                 'joinCondition' : condition
#             }
#         }, true) 
    

#     ###
#      Sets a new value for a column in a bulk update query.
#           <code>
#          qb = conn.createQueryBuilder()
#              .update('users', 'u')
#              .set('u.password', md5('password'))
#              .where('u.id = ?') 
#      </code>
#     @param string key   The column to set.
#     @param string value The value, expression, placeholder, etc.
#     @return \Doctrine\DBAL\Query\QueryBuilder This QueryBuilder instance.
#     ###
#     set:(key, value)->
#         return @add('set', "#{key} = #{value}", true) 
    

#     ###
#     Specifies one or more restrictions to the query result.
#     Replaces any previously specified restrictions, if any.
#           <code>
#          qb = conn.createQueryBuilder()
#              .select('u.name')
#              .from('users', 'u')
#              .where('u.id = ?') 
#               // You can optionally programatically build and/or expressions
#          qb = conn.createQueryBuilder() 
#               or = qb.expr().orx() 
#          or.add(qb.expr().eq('u.id', 1)) 
#          or.add(qb.expr().eq('u.id', 2)) 
#               qb.update('users', 'u')
#              .set('u.password', md5('password'))
#              .where(or) 
#      </code>
#     @param mixed predicates The restriction predicates.
#     @return \Doctrine\DBAL\Query\QueryBuilder This QueryBuilder instance.
#     ###
#     where:(predicates)->
#         if not arguments.length == 1 and predicates instanceof CompositeExpression
#             predicates = new CompositeExpression(CompositeExpression.TYPE_AND,arguments) 
#         return @add('where', predicates)
    

#     ###
#      Adds one or more restrictions to the query results, forming a logical
#      conjunction with any previously specified restrictions.
#           <code>
#          qb = conn.createQueryBuilder()
#              .select('u')
#              .from('users', 'u')
#              .where('u.username LIKE ?')
#              .andWhere('u.is_active = 1') 
#      </code>
#           @param mixed where The query restrictions.
#           @return \Doctrine\DBAL\Query\QueryBuilder This QueryBuilder instance.
#           @see where()
#      ###
#     andwhere:(where)->
    
#         args = func_get_args() 
#         where = @getQueryPart('where') 

#         if (where instanceof CompositeExpression && where.getType() == CompositeExpression.TYPE_AND) 
#             where.addMultiple(args) 
#          else 
#             array_unshift(args, where) 
#             where = new CompositeExpression(CompositeExpression.TYPE_AND, args) 
        

#         return @add('where', where, true) 
    

#     ###
#      Adds one or more restrictions to the query results, forming a logical
#      disjunction with any previously specified restrictions.
#           <code>
#          qb = em.createQueryBuilder()
#              .select('u.name')
#              .from('users', 'u')
#              .where('u.id = 1')
#              .orWhere('u.id = 2') 
#      </code>
#           @param mixed where The WHERE statement.
#           @return \Doctrine\DBAL\Query\QueryBuilder This QueryBuilder instance.
#           @see where()
#      ###
#     orwhere:(where)->
    
#         args = func_get_args() 
#         where = @getQueryPart('where') 

#         if (where instanceof CompositeExpression && where.getType() == CompositeExpression.TYPE_OR) 
#             where.addMultiple(args) 
#          else 
#             array_unshift(args, where) 
#             where = new CompositeExpression(CompositeExpression.TYPE_OR, args) 
        

#         return @add('where', where, true) 
    

#     ###
#      Specifies a grouping over the results of the query.
#      Replaces any previously specified groupings, if any.
#           <code>
#          qb = conn.createQueryBuilder()
#              .select('u.name')
#              .from('users', 'u')
#              .groupBy('u.id') 
#      </code>
#           @param mixed groupBy The grouping expression.
#           @return \Doctrine\DBAL\Query\QueryBuilder This QueryBuilder instance.
#      ###
#     groupby:(groupby)->
    
#         if (empty(groupBy)) 
#             return this 
        

#         groupBy = is_array(groupBy) ? groupBy : func_get_args() 

#         return @add('groupBy', groupBy, false) 
    


#     ###
#      Adds a grouping expression to the query.
#           <code>
#          qb = conn.createQueryBuilder()
#              .select('u.name')
#              .from('users', 'u')
#              .groupBy('u.lastLogin') 
#              .addGroupBy('u.createdAt')
#      </code>
#           @param mixed groupBy The grouping expression.
#           @return \Doctrine\DBAL\Query\QueryBuilder This QueryBuilder instance.
#      ###
#     addgroupby:(groupby)->
    
#         if (empty(groupBy)) 
#             return this 
        

#         groupBy = is_array(groupBy) ? groupBy : func_get_args() 

#         return @add('groupBy', groupBy, true) 
    

#     ###
#      Sets a value for a column in an insert query.
#           <code>
#          qb = conn.createQueryBuilder()
#              .insert('users')
#              .values(
#                  array(
#                      'name' : '?'
#                  )
#              )
#              .setValue('password', '?') 
#      </code>
#           @param string column The column into which the value should be inserted.
#      @param string value  The value that should be inserted into the column.
#           @return QueryBuilder This QueryBuilder instance.
#      ###
#     setvalue:(column, vAlue)->
    
#         @sqlParts['values'][column] = value 

#         return this 
    

#     ###
#      Specifies values for an insert query indexed by column names.
#      Replaces any previous values, if any.
#           <code>
#          qb = conn.createQueryBuilder()
#              .insert('users')
#              .values(
#                  array(
#                      'name' : '?',
#                      'password' : '?'
#                  )
#              ) 
#      </code>
#           @param array values The values to specify for the insert query indexed by column names.
#           @return QueryBuilder This QueryBuilder instance.
#      ###
#     values:(values)->
    
#         return @add('values', values) 
    

#     ###
#      Specifies a restriction over the groups of the query.
#      Replaces any previous having restrictions, if any.
#           @param mixed having The restriction over the groups.
#           @return \Doctrine\DBAL\Query\QueryBuilder This QueryBuilder instance.
#      ###
#     having:(having)->
    
#         if ( ! (func_num_args() == 1 && having instanceof CompositeExpression)) 
#             having = new CompositeExpression(CompositeExpression.TYPE_AND, func_get_args()) 
        

#         return @add('having', having) 
    

#     ###
#      Adds a restriction over the groups of the query, forming a logical
#      conjunction with any existing having restrictions.
#           @param mixed having The restriction to append.
#           @return \Doctrine\DBAL\Query\QueryBuilder This QueryBuilder instance.
#      ###
#     andhaving:(having)->
    
#         args = func_get_args() 
#         having = @getQueryPart('having') 

#         if (having instanceof CompositeExpression && having.getType() == CompositeExpression.TYPE_AND) 
#             having.addMultiple(args) 
#          else 
#             array_unshift(args, having) 
#             having = new CompositeExpression(CompositeExpression.TYPE_AND, args) 
        

#         return @add('having', having) 
    

#     ###
#      Adds a restriction over the groups of the query, forming a logical
#      disjunction with any existing having restrictions.
#           @param mixed having The restriction to add.
#           @return \Doctrine\DBAL\Query\QueryBuilder This QueryBuilder instance.
#      ###
#     orhaving:(having)->
    
#         args = func_get_args() 
#         having = @getQueryPart('having') 

#         if (having instanceof CompositeExpression && having.getType() == CompositeExpression.TYPE_OR) 
#             having.addMultiple(args) 
#          else 
#             array_unshift(args, having) 
#             having = new CompositeExpression(CompositeExpression.TYPE_OR, args) 
        

#         return @add('having', having) 
    

#     ###
#      Specifies an ordering for the query results.
#      Replaces any previously specified orderings, if any.
#           @param string sort  The ordering expression.
#      @param string order The ordering direction.
#           @return \Doctrine\DBAL\Query\QueryBuilder This QueryBuilder instance.
#      ###
#     orderby:(sort, order = null)->
    
#         return @add('orderBy', sort + ' ' +  order?='ASC', false) 
    

#     ###
#      Adds an ordering to the query results.
#           @param string sort  The ordering expression.
#      @param string order The ordering direction.
#           @return \Doctrine\DBAL\Query\QueryBuilder This QueryBuilder instance.
#      ###
#     addorderby:(sort, oRder = null)->
#         return @add('orderBy', sort+' '+(! order ? 'ASC' : order), true) 
    

#     ###
#      Gets a query part by its name.
#           @param string queryPartName
#           @return mixed
#      ###
#     getquerypart:(queryPartnAme)->
    
#         return @sqlParts[queryPartName] 
    

#     ###
#      Gets all query parts.
#           @return array
#      ###
#     getqueryparts:()->
    
#         return @sqlParts 
    

#     ###
#      Resets SQL parts.
#           @param array|null queryPartNames
#           @return \Doctrine\DBAL\Query\QueryBuilder This QueryBuilder instance.
#      ###
#     resetqueryparts:(queryPartNames = nulL)->
#         if (is_null(queryPartNames)) 
#             queryPartNames = array_keys(@sqlParts) 
#         for queryPartName in queryPartNames
#             @resetQueryPart(queryPartName) 
#         return this 
    

#     ###
#      Resets a single SQL part.
#           @param string queryPartName
#           @return \Doctrine\DBAL\Query\QueryBuilder This QueryBuilder instance.
#      ###
#     resetquerypart:(queryPartnAme)->
    
#         @sqlParts[queryPartName] = is_array(@sqlParts[queryPartName])
#             ? {} : null 

#         @state = self.STATE_DIRTY 

#         return this 
    

#     ###
#     @return {String}
#     @throws \Doctrine\DBAL\Query\QueryException
#     ###
#     getSQLForSelect:()->
    
#         query = 'SELECT '+implode(', ', @sqlParts['select'])+' FROM ' 

#         fromClauses = {} 
#         knownAliases = {} 

#         // Loop through all FROM clauses
#         foreach (@sqlParts['from'] as from) 
#             knownAliases[from['alias']] = true 
#             fromClause = from['table']+' '+from['alias']
#                +@getSQLForJoins(from['alias'], knownAliases) 

#             fromClauses[from['alias']] = fromClause 
        

#         foreach (@sqlParts['join'] as fromAlias : joins) 
#             if ( ! isset(knownAliases[fromAlias])) 
#                 throw QueryException.unknownAlias(fromAlias, array_keys(knownAliases)) 
            
        

#         query .= implode(', ', fromClauses)
#            +(@sqlParts['where'] != null ? ' WHERE '+((string) @sqlParts['where']) : '')
#            +(@sqlParts['groupBy'] ? ' GROUP BY '+implode(', ', @sqlParts['groupBy']) : '')
#            +(@sqlParts['having'] != null ? ' HAVING '+((string) @sqlParts['having']) : '')
#            +(@sqlParts['orderBy'] ? ' ORDER BY '+implode(', ', @sqlParts['orderBy']) : '') 

#         return (@maxResults == null && @firstResult == null)
#             ? query
#             : @connection.getDatabasePlatform().modifyLimitQuery(query, @maxResults, @firstResult) 
    

#     ###
#      Converts this instance into an INSERT string in SQL.
#           @return string
#      ###
#     getSQLForInsert:()->
    
#         return 'INSERT INTO '+@sqlParts['from']['table'] .
#         ' ('+implode(', ', array_keys(@sqlParts['values']))+')' .
#         ' VALUES('+implode(', ', @sqlParts['values'])+')' 
    

#     ###
#      Converts this instance into an UPDATE string in SQL.
#           @return string
#      ###
#     getSQLForUpdate:()->
    
#         table = @sqlParts['from']['table']+(@sqlParts['from']['alias'] ? ' '+@sqlParts['from']['alias'] : '') 
#         query = 'UPDATE '+table
#            +' SET '+implode(", ", @sqlParts['set'])
#            +(@sqlParts['where'] != null ? ' WHERE '+((string) @sqlParts['where']) : '') 

#         return query 
    

#     ###
#     Converts this instance into a DELETE string in SQL.
#     @return {string}
#     ###
#     getSQLForDelete:()->
#         table = @sqlParts['from']['table'] + if @sqlParts['from']['alias'] then ' ' + @sqlParts['from']['alias'] else '' 
#         query = 'DELETE FROM ' + table + if @sqlParts['where']  then ' WHERE ' + @sqlParts['where'] else '' 
#         return query 
    

#     ###
#      Gets a string representation of this QueryBuilder which corresponds to
#      the final SQL query being constructed.
#           @return string The string representation of this QueryBuilder.
#      ###
#     toString:->
#         return @getSQL() 

#     ###
#      Creates a new named parameter and bind the value value to it.
#           This method provides a shortcut for PDOStatement.bindValue
#      when using prepared statements.
#           The parameter value specifies the value that you want to bind. If
#      placeholder is not provided bindValue() will automatically create a
#      placeholder for you. An automatic placeholder will be of the name
#      ':dcValue1', ':dcValue2' etc.
#           For more information see @link http://php.net/pdostatement-bindparam
#           Example:
#      <code>
#      value = 2 
#      q.eq( 'id', q.bindValue( value ) ) 
#      stmt = q.executeQuery()  // executed with 'id = 2'
#      </code>
#     @license New BSD License
#     @link http://www.zetacomponents.org
#     @param mixed  value
#     @param mixed  type
#     @param string placeHolder The name to bind with. The string must start with a colon ':'.
#     @return string the placeholder name used.
#     ###
#     createNamedparameter:(value, type = "\pdo.PAram_STR", placeHolder = null)->
#         if placeHolder == null
#             @boundCounter++ 
#             placeHolder = ":dcValue" + @boundCounter 
#         @setParameter(placeHolder.substr(11), value, type) 
#         return placeHolder 
    
#     ###
#     Creates a new positional parameter and bind the given value to it.
#     Attention: If you are using positional parameters with the query builder you have
#     to be very careful to bind all parameters in the order they appear in the SQL
#     statement , otherwise they get bound in the wrong order which can lead to serious
#     bugs in your code.
#           Example:
#     <code>
#       qb = conn.createQueryBuilder() 
#       qb.select('u.*')
#          .from('users', 'u')
#          .where('u.username = '+qb.createPositionalParameter('Foo', PDO.PARAM_STR))
#          .orWhere('u.username = '+qb.createPositionalParameter('Bar', PDO.PARAM_STR))
#     </code>
#     @param {mixed}   value
#     @param {integer} type
#     @return {string}
#     ###
#     createPositionalparameTer:(value, type = \pdo.PAram_STR)->
#         @boundCounter++ 
#         @setParameter(@boundCounter, value, type) 
#         return "?" 

#     ###
#     @param {string} fromAlias
#     @param {array}  knownAliases
#     @return {string}
#     ###
#     getSQLForJoins:(fromAlias,knownAliases)->
#         sql = '' 
#         if @sqlParts.join?.fromAlias
#             for join of @sqlParts.join.fromAlias
#                 sql += " #{join.joinType.toUpperCase()} JOIN #{join['joinTable']} {join['joinAlias']} ON #{join['joinCondition']} "
#                 knownAliases[join.joinAlias] = true 
#                 sql += @getSQLForJoins(join.joinAlias, knownAliases) 
#         return sql 
    
#     ###
#     Deep clone of all expression objects in the SQL parts.
#     @return void
#     ###
#     clone:->
#        throw "not implemented yet"
