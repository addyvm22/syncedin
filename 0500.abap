PROCESS BEFORE OUTPUT.
*&SPWIZARD: PBO FLOW LOGIC FOR TABSTRIP 'TB_POSTED_JOB'
  MODULE tb_posted_job_active_tab_set.
  CALL SUBSCREEN tb_posted_job_sca
    INCLUDING g_tb_posted_job-prog g_tb_posted_job-subscreen.

  "--> Module to provide GUI functionalities to the screen
  MODULE status_0500.
*
PROCESS AFTER INPUT.
*&SPWIZARD: PAI FLOW LOGIC FOR TABSTRIP 'TB_POSTED_JOB'
  CALL SUBSCREEN tb_posted_job_sca.
  MODULE tb_posted_job_active_tab_get.
* MODULE USER_COMMAND_0500.

  "---> Module to provide screen exit functionalities
  MODULE exit_0500 AT EXIT-COMMAND.