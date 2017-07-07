$(document).ready(function(){
  $("#guess-form").submit(function(){
    pattern = /^[1-6]{4}$/
    var guess = $('#guess').val();
    var res = pattern.test(guess);
    if (res == false) {
      alert("Code must contain 4 numbers from 1 to 6. Please try again");
      $('#guess').val('').focus();
      return false;
    }
  });
});
