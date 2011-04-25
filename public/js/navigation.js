$(function() {

  $("#new-game-header").click(function() {
    $("#new-game-form").toggle("slow");
  });

  $("#join-game-header").click(function() {
    $("#join-game-form").toggle("slow");
  });

  $("#new-game-form").submit(function() {
    if($("#game-name").val() == "Enter a game title..." || $("#game-jql").val() == "Enter your Jira JQL here...") {
      alert("Please enter a game name and JQL query.");
      return false;    
    }
  });

    $("#join-game-form").submit(function() {
    if($("#game-id-select").val() == "") {
      alert("Please select a game to join.");
      return false;    
    }
  });

});
