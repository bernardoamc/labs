// Used to encapsulate a group of similar methods.
// You can think about it as a toolbox, or a service.
// Normally it is just a object literal.

/*
var Module = {
  method: function() {},
  nextMethod: function() {}
}
/*

// or if you want to create private variables

/*
var newModule = function() {
  var privateVar = 'I am private...';

  return {
    method: function() {},
    nextMethod: function() {}
  }
}
*/

var repo = function () {
  var db = {};

  var get = function (id) {
    console.log('Getting task ' + id);
    return {
      name: 'new task from db'
    }
  }

  var save = function (task) {
    console.log('Saving ' + task.name + ' to the db');
  }

  return {
    get: get,
    save: save
  }
}

module.exports = repo();
