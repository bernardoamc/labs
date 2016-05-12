var repo = {
    tasks: {},
    commands: [],
    select: function (id) {
        console.log('Getting task ' + id);
        return this.tasks[id];
    },

    save: function (task) {
        this.tasks[task.id] = task;
        console.log('Saving ' + task.name + ' to the db');
    }
}

repo.replay = function() {
  for(var i = 0, len = repo.commands.length; i < len; i++) {
    var command = repo.commands[i];
    repo.executeNoLog(command.name, command.obj);
  }
};

repo.execute = function(name){
    var args = Array.prototype.slice.call(arguments, 1);

    repo.commands.push({
      name: name,
      obj: args[0]
    });

    if(repo[name]) {
        return repo[name].apply(repo, args)
    }

    return false;
};

repo.executeNoLog = function(name){
    var args = Array.prototype.slice.call(arguments, 1);

    if(repo[name]) {
        return repo[name].apply(repo, args)
    }

    return false;
};


repo.execute('save', {
  id: 1,
  name: 'Task 1'
});

repo.execute('save', {
  id: 2,
  name: 'Task 2'
});

repo.execute('save', {
  id: 3,
  name: 'Task 3'
});

var task = repo.execute('select', 1);
console.log(task);
console.log(repo.commands);
repo.tasks = {};
console.log(repo.tasks);
repo.replay();
console.log(repo.tasks);
