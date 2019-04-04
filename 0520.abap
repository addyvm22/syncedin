PROCESS BEFORE OUTPUT.
* MODULE STATUS_0520.
  "--> Module to set the screen before display
  MODULE change_screen_0520.

PROCESS AFTER INPUT.
  "--> Module on user action
  CHAIN.
    field ZG13_JOB_DETAILS-QUESTION_COUNT.
    FIELD zg13_job_details-description.
    FIELD zg13_job_details-location.
    FIELD io_questin_file_path.
    FIELD: zg13_job_details-min_sal ,zg13_job_details-max_sal.
    FIELD: zg13_job_details-skill_1,zg13_job_details-skill_2,
    zg13_job_details-skill_3,zg13_job_details-skill_4.
  MODULE user_command_0520.
  ENDCHAIN.

  "---> Module for browsing the File using 'F4'
  PROCESS ON VALUE-REQUEST.
   FIELD IO_QUESTIN_FILE_PATH MODULE BROWSE_FILE.