{{name}}
========

{{description}}

version: {{version}}

author : {{author}}

license: {{license}}

inspired by https://github.com/doctrine/dbal

[![Build Status](https://travis-ci.org/Mparaiso/mpm.dbal.png?branch=master)](https://travis-ci.org/Mparaiso/mpm.dbal)

###INSTALLATION

	npm install {{name}}

###DEPENDENCIES

{%_.forEach(dependencies,function(dep,key){print("- ".concat(key).concat("\r\n"))}) %}

###TODO 
- write doc
- review all comments
- correct all operations related to db connection since Connection is not implemented yet
- pass all tests

