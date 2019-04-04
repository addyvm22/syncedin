PROCESS BEFORE OUTPUT.
"--> Module to provide GUI functionalities to the screen
  MODULE status_0320.
*
  "--> Screen modification before displaying
  MODULE change_screen_0320.

PROCESS AFTER INPUT.
  CHAIN.
    FIELD: zg13_applicant-password,
            io_new_password
            ,io_conform_password.

    MODULE user_command_0320. "User action module
  ENDCHAIN.