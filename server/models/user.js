var mongoose = require('mongoose');

var userSchema = mongoose.Schema({
  uuid: String,
  created_on: Date
});

userSchema.pre('save', function(next) {
  if (!this.created_on)
    this.created_on = new Date;

  next();
});

var User = mongoose.model('User', userSchema);

module.exports = User;