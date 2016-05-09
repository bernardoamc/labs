'use strict'


class Task {
  constructor(name) {
    this.name = name;
    this.completed = false;
  };

  complete() {
    this.completed = true;
  };

  save() {
    console.log('Saving Task ' + this.name);
  };
}

module.exports = Task;
