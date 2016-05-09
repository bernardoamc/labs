var Task = function(data) {
  this.name = data.name;
  this.completed = data.completed;
}

Task.prototype.complete = function() {
  this.completed = true;
}

Task.prototype.save = function() {
  console.log("saving " + this.name + " ..");
}

var task1 = new Task({name: 'create a demo for constructors'});
var task2 = new Task({name: 'such a nice task'});
task1.save();
task2.save();

var DecoratedTask = function(name, priority) {
  Task.call(this, {name: name, completed: true});
  this.priority = priority;
}
DecoratedTask.prototype = Object.create(Task.prototype);

DecoratedTask.prototype.save = function() {
  Task.prototype.save.call(this);
  console.log("wow, save is decorated! =O");
}

var task3 = new DecoratedTask('decorated task', 5);
console.log(task3);
task3.save();
