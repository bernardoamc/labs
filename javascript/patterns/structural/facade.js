// The Facade patterns simplifies the Interface. The difference between
// the Facade and the Decorator is that the Decorator pattern increments
// the API of an Object, the Facade pattern does not do that.
// For example Jquery is a Facade implementation of the DOM.

var Task = function (data) {
    this.name = data.name;
    this.priority = data.priority;
    this.project = data.project;
    this.user = data.user;
    this.completed = data.completed;
}

var TaskService = function () {
    return {
        complete: function (task) {
            task.completed = true;
            console.log('completing task: ' + task.name);
        },
        setCompleteDate: function (task) {
            task.completedDate = new Date();
            console.log(task.name + ' completed on ' + task.completedDate);
        },
        notifyCompletion: function (task, user) {
            console.log('Notifying ' + user + ' of the completion of ' + task.name);
        },
        save: function (task) {
            console.log('saving Task: ' + task.name);
        }
    }
}();

// The Facade, so I don't need to call lots of methods
// when I complete my task.
var TaskServiceWrapper = function () {
    var completeAndNotify = function (task) {
        TaskService.complete(myTask);

        if (myTask.completed == true) {
            TaskService.setCompleteDate(myTask);
            TaskService.notifyCompletion(myTask, myTask.user);
            TaskService.save(myTask);
        }
    }

    return {
        completeAndNotify: completeAndNotify
    }
}();

var myTask = new Task({
    name: 'MyTask',
    priority: 1,
    project: 'Courses',
    user: 'Jon',
    completed: false
});

TaskServiceWrapper.completeAndNotify(myTask);
console.log(myTask);
