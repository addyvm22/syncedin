PROCESS BEFORE OUTPUT.

  "--> Module to provide GUI functionalities to the screen
  MODULE status_0100.

  MODULE display_logo. "---> Module for display screen logo

PROCESS AFTER INPUT.
  CHAIN.
    "---> Perform login operation
    FIELD : zg13_applicant-applicant_id,
            io_password MODULE user_command_0100.
  ENDCHAIN.

  "---> Module to provide screen exit functionalities
  MODULE exit_module_0100 AT EXIT-COMMAND.