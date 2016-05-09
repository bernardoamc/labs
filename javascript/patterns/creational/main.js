var Task = require('./constructor');
var Repo = require('./module');

var task1 = new Task({name: 'create a demo for constructors'});
var task2 = new Task(Repo.get(1));
task1.save();
task2.save();
