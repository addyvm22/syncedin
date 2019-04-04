PROCESS BEFORE OUTPUT.
  "--> Module to provide GUI functionalities to the screen
  MODULE status_0400.

  "--> Module to set the screen layout before display
  MODULE change_screen_0400.

PROCESS AFTER INPUT.
  "--> Module on user action
  CHAIN.
    FIELD :
    zg13_applicant-applicant_id ,
    zg13_recruiter-recruiter_id,
    zg13_applicant-security_que,
    zg13_applicant-security_ans,
    io_conform_password,
    zg13_recruiter-password
     MODULE user_command_0400.
  ENDCHAIN.

  "---> Module to provide screen exit functionalities
  MODULE exit_0400 AT EXIT-COMMAND.