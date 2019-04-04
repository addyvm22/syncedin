PROCESS BEFORE OUTPUT.

  "module to add data into the table control
  MODULE get_data_0300 ." get data

  "Module to set gui status
  MODULE status_0300.


*&SPWIZARD: PBO FLOW LOGIC FOR TABLECONTROL 'TC_JOB_DETAILS1'
  MODULE tc_job_details1_change_tc_attr.
*&SPWIZARD: MODULE TC_JOB_DETAILS1_CHANGE_COL_ATTR.
  LOOP AT   it_tc_job_details1
       INTO wa_tc_job_details1
       WITH CONTROL tc_job_details1
       CURSOR tc_job_details1-current_line.
    MODULE tc_job_details1_get_lines.
*&SPWIZARD:   MODULE TC_JOB_DETAILS1_CHANGE_FIELD_ATTR
  ENDLOOP.



PROCESS AFTER INPUT.
*&SPWIZARD: PAI FLOW LOGIC FOR TABLECONTROL 'TC_JOB_DETAILS1'
  LOOP AT it_tc_job_details1.
    CHAIN.
      FIELD wa_tc_job_details1-job_id.
      FIELD wa_tc_job_details1-recruiter_id.
      FIELD wa_tc_job_details1-description.
      FIELD wa_tc_job_details1-location.
      FIELD wa_tc_job_details1-min_sal.
      FIELD wa_tc_job_details1-max_sal.
      FIELD wa_tc_job_details1-question_count.
      FIELD wa_tc_job_details1-skill_1.
      FIELD wa_tc_job_details1-skill_2.
      FIELD wa_tc_job_details1-skill_3.
      FIELD wa_tc_job_details1-skill_4.
    ENDCHAIN.
    FIELD wa_tc_job_details1-mark
      MODULE tc_job_details1_mark ON REQUEST.
  ENDLOOP.
  MODULE tc_job_details1_user_command.



*&SPWIZARD: MODULE TC_JOB_DETAILS1_CHANGE_TC_ATTR.
*&SPWIZARD: MODULE TC_JOB_DETAILS1_CHANGE_COL_ATTR.

  "--> User action module
  MODULE user_command_0300.

  "---> Module to provide screen exit functionalities
  MODULE exit_0300 AT EXIT-COMMAND." EXIT COMMAND MODULE