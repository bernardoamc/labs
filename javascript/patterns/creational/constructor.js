// Use to create new objects with their own object scope.
// Uses the 'new' keyword for a constructor function.
// What the constructor function does is:
//   - Creates a new object
//   - Links to an object prototype
//   - Binds 'this' tot the new object scope.
//   - Implicitly returns 'this'

var Repo = require('./module');

var Task = function(data) {
  this.name = data.name;
  this.completed = data.completed;
}

Task.prototype.complete = function() {
  this.completed = true;
}

Task.prototype.save = function() {
  Repo.save(this);
}

module.exports = Task;
