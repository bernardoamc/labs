var task = {
  title: "My task",
  description: "My description"
}

Object.defineProperty(task, 'toString', {
  value: function() {
    return this.title + ' ' + this.description;
  },
  writable: true,
  enumerable: true,
  configurable: true
})

var urgentTask = Object.create(task);

Object.defineProperty(urgentTask, 'toString', {
  value: function() {
    return this.title + ' ' + 'urgent';
  },
  writable: true,
  enumerable: true,
  configurable: true
})

console.log(task.toString());
console.log(urgentTask.toString());
