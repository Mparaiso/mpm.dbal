/*jslint regexp:true*/
"use strict";
/**
 * CREATE README.md file from template and datas
 */
var _, _package, data, fs,filename,path,tpl;

_ = require('underscore');
_package = require('../package.json');
data = require('../README.json');
fs = require("fs");
data = _.extend(_package, data);
path=require('path');
filename=path.join(__dirname,"../README.md");

_.templateSettings = {
	interpolate: /\{\{(.+?)\}\}/g,
	evaluate: /\{\%(.+?)\%\}/g
};

tpl = _.template(fs.readFileSync(__dirname+"/../README.tpl", "utf-8"));
fs.writeFileSync(filename, tpl(data), "utf-8");