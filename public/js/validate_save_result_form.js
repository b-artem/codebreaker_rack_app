$(document).ready(function(){
  $("#save-result-ok-form").submit(function(){
    var name = $("#name-input").val();
    if (name == '') {
      alert("Name must be filled out");
      $('#name-input').focus();
      return false;
    }
  });
});
