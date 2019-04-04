PROCESS BEFORE OUTPUT.
  MODULE get_data_0310. " FETCH APPLICANT DATA

  "--> Module to provide GUI functionalities to the screen
  MODULE status_0310.


  " changing screen with active-inactive elements
  MODULE change_screen_0310.

PROCESS AFTER INPUT.

  "user commands - function codes
  MODULE user_command_0310.

  "---> Module to provide screen exit functionalities
  MODULE exit_0310 AT EXIT-COMMAND.