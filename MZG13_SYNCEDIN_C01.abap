*&---------------------------------------------------------------------*
*&  Include           MZG13_SYNCEDIN_C01
*&---------------------------------------------------------------------*


CLASS lcl_syncedin IMPLEMENTATION.

  "screen 300 home screen of applicant
  "method populates the table that displays matching jobs of the applicant
  METHOD find_matching_jobs .
    CLEAR itable.
    SELECT * FROM zg13_job_details INTO CORRESPONDING FIELDS OF TABLE itable
      WHERE
       skill_1 = applicant-skill_1 OR skill_1 = applicant-skill_2 OR skill_1 = applicant-skill_3 OR skill_1 = applicant-skill_4
      OR
      ( skill_2 NE ' ' AND ( skill_2 = applicant-skill_1 OR skill_2 = applicant-skill_2 OR skill_2 = applicant-skill_3 OR skill_2 = applicant-skill_4 ) )
      OR
      ( skill_3 NE ' ' AND ( skill_3 = applicant-skill_1 OR skill_3 = applicant-skill_2 OR skill_3 = applicant-skill_3 OR skill_3 = applicant-skill_4 ) )
      OR
      ( skill_4 NE ' ' AND ( skill_4 = applicant-skill_1 OR skill_4 = applicant-skill_2 OR skill_4 = applicant-skill_3 OR skill_4 = applicant-skill_4 ) ).


    "find the count of jobs
    DESCRIBE TABLE itable LINES noofjobs.


  ENDMETHOD.

  "returns the job id of the job selected in the table control
  "raises exception nolineselected if no line was selected when applying for a job.
  METHOD return_selectd_job.

    DATA wa_itable LIKE LINE OF itable.
    CLEAR jobid.

    "the line that is selected gives the value of mark='X'
    LOOP AT itable INTO wa_itable.
      IF wa_itable-mark = 'X'.
        jobid = wa_itable-job_id.
      ENDIF.
    ENDLOOP.

    "jobid is initial means that no line was selected as no
    IF jobid IS INITIAL.
      RAISE nolineselected.
    ENDIF.

  ENDMETHOD.



  "method to fetch the assessment id on click of take assessment
  "if assessment id is not available, -- error message
  "if assessment id with percentage = ' ' is not fetched then add new assesment id
  "returns assessment id
  METHOD get_assessment_id.

    DATA: wa_assmt          TYPE zg13_assessment,
          wa_assmt2         TYPE zg13_assessment,
          max_assessment_id TYPE zg13_assessment-assessement_id,
          max_id1           TYPE string,
          max_id2           TYPE string.

    SELECT SINGLE * FROM zg13_assessment INTO wa_assmt WHERE applicant_id = im_applicant_id AND job_id = im_job_id.

    IF sy-subrc <> 0.
      MESSAGE 'Please apply for the job before taking assessment' TYPE 'I'.
    ELSE .
      SELECT SINGLE * FROM zg13_assessment INTO wa_assmt2
        WHERE applicant_id = im_applicant_id AND job_id = im_job_id
        AND percentage = ' '.

      IF sy-subrc <> 0.
        SELECT MAX( assessement_id ) FROM zg13_assessment INTO max_assessment_id.

        SPLIT max_assessment_id AT 'AS' INTO max_id1 max_id2.
        max_id2 = max_id2 + 1.
        CONCATENATE 'AS' max_id2 INTO max_assessment_id.

        wa_assmt-assessement_id = max_assessment_id.
        CLEAR wa_assmt-percentage.

        INSERT zg13_assessment FROM wa_assmt.
        IF sy-subrc <> 0.
          MESSAGE 'Internal error. Please retry.' TYPE 'I'.
        ELSE.
          ex_assessment_id = wa_assmt-assessement_id.
        ENDIF.

      ELSE.
        ex_assessment_id = wa_assmt2-assessement_id.
      ENDIF.

    ENDIF.







*   im_applicant_id  TYPE zg13_applicant-applicant_id
*   im_job_id        TYPE zg13_job_details-job_id
*   EXPORTING ex_assessment_id""



  ENDMETHOD.



  " validate applicant
  METHOD validate_applicant.
    " local variable for count
    DATA : lv_count TYPE i.
    SELECT COUNT(*) FROM zg13_applicant INTO lv_count
    WHERE  password = im_password  AND applicant_id = im_applicant_id .

    IF lv_count = 0.

      RAISE invalid_applicant. " if applicant  entry is not present in database then raise exception
    ENDIF.

  ENDMETHOD.


  " validate recruiter
  METHOD validate_recruiter.
    " local variable for count
    DATA : lv_count TYPE i.
    SELECT COUNT(*) FROM zg13_recruiter INTO lv_count
    WHERE  password = im_password AND recruiter_id = im_recruiter_id .
    IF lv_count = 0.
      RAISE invalid_recruiter. " if recruiter  entry is not present in database then raise exception
    ENDIF.

  ENDMETHOD.

  " REGISTER APPLICANT
  METHOD register_applicant.

    INSERT zg13_applicant FROM im_applicant.
    IF sy-subrc <> 0.
      RAISE  registration_failed.
    ENDIF.
  ENDMETHOD.

  "REGISTER RECRUITER
  METHOD register_recruiter.
    " STRUCTURE FOR LOCATION VALUE
    TYPES : BEGIN OF ty_struct,
              location TYPE zg13_recruiter-location,
            END OF ty_struct.
    DATA : it_table_location TYPE TABLE OF ty_struct, " INTERNAL TABLE STORES LOCATION
           wa_table_location LIKE LINE OF it_table_location.
    DATA: lv_count TYPE i.
    DATA : lv_location TYPE zg13_recruiter-location.
    lv_location = im_register-location.
    TRANSLATE lv_location TO LOWER CASE.
    " SELECT LOCATION FORM RECTUITER TABLE
    SELECT location FROM zg13_recruiter INTO TABLE it_table_location
    WHERE recruiter_id = im_register-recruiter_id.

    IF it_table_location IS INITIAL.
      INSERT zg13_recruiter FROM  im_register. " INSERT DATA
      IF sy-subrc <> 0.
        RAISE  registration_failed.
      ENDIF.
    ELSE.
      LOOP AT it_table_location INTO wa_table_location.
        TRANSLATE  wa_table_location-location  TO LOWER CASE.
        IF wa_table_location-location = lv_location.
          lv_count = lv_count + 1.
        ENDIF.
      ENDLOOP.
      IF lv_count = 0.
        INSERT zg13_recruiter FROM  im_register.
        IF sy-subrc <> 0.
          RAISE  registration_failed.
        ENDIF.
      ELSE.
        RAISE alredy_present.
      ENDIF.
    ENDIF.

*      SELECT COUNT(*) FROM zg13_recruiter INTO  lv_count WHERE
*         recruiter_id = im_register-recruiter_id AND  location    =  im_register-location  .
*      IF lv_count = 0.
*
*
*      ELSE.
*        RAISE alredy_present.
*      ENDIF.

  ENDMETHOD.


  " MAX APPLICANT ID
  METHOD applicant_max_id.

    DATA : lv_temp TYPE c,
           lv_id   TYPE zg13_applicant-applicant_id.
    SELECT MAX( applicant_id ) FROM zg13_applicant INTO lv_id.
    SPLIT lv_id AT 'A' INTO lv_temp lv_id.
    lv_id = lv_id + 1.
    SHIFT lv_id LEFT DELETING LEADING ' '.
    CONCATENATE 'A' lv_id INTO lv_id.
    ex_appicant_id = lv_id.

  ENDMETHOD.
  " MAX APPLICANT ID
  METHOD recruiter_max_id.

    DATA : lv_temp TYPE c,
           lv_id   TYPE zg13_recruiter-recruiter_id.
    SELECT MAX( recruiter_id ) FROM zg13_recruiter INTO lv_id.
    SPLIT lv_id AT 'R' INTO lv_temp lv_id.
    lv_id = lv_id + 1.
    SHIFT lv_id LEFT DELETING LEADING ' '.
    CONCATENATE 'R' lv_id INTO lv_id.
    ex_recruiter_id = lv_id.

  ENDMETHOD.

  " FORGOT PASSWORD METHOD
  METHOD forgot_password.
    DATA : lv_count TYPE i.
    IF im_id+0(1) = 'A'." IF APPLICANT
      SELECT COUNT(*) FROM zg13_applicant INTO lv_count
      WHERE applicant_id = im_id AND security_que = im_security_que
      AND security_ans = im_security_ans.
      IF lv_count = 0. " IF SECURITY QUESTION NOT MATCH
        RAISE password_not_updated.
      ELSE. " IF SECURITY QUESTION  MATCH
        UPDATE zg13_applicant SET password = im_password WHERE applicant_id = im_id.
      ENDIF.
    ELSEIF im_id+0(1) = 'R'. " IF RECRUITER
      SELECT COUNT(*) FROM zg13_recruiter INTO lv_count
      WHERE recruiter_id = im_id AND security_que = im_security_que
      AND security_ans = im_security_ans.
      IF lv_count = 0. " IF SECURITY QUESTION NOT MATCH
        RAISE password_not_updated.
      ELSE." IF SECURITY QUESTION  MATCH
        UPDATE zg13_recruiter SET password = im_password WHERE recruiter_id = im_id.

      ENDIF.
    ENDIF.

  ENDMETHOD.

  " GET APPLICANT DETAILS
  METHOD get_applicant.

    SELECT SINGLE * FROM zg13_applicant INTO ex_applicant WHERE applicant_id = im_id.

    IF sy-subrc <> 0.
      RAISE applicantnotfound.
    ENDIF.

  ENDMETHOD.


  " GET POSTED JOBS  BASED ON RECRUITER
  METHOD get_posted_job.
    SELECT * FROM zg13_job_details INTO CORRESPONDING FIELDS OF TABLE it_posted_job_table
   WHERE recruiter_id = im_id.

  ENDMETHOD.


  " AUTO GENERATE JOB ID
  METHOD auto_generate_job_id.
    DATA : lv_temp TYPE c,
           lv_id   TYPE zg13_job_details-job_id.
    SELECT MAX( job_id ) FROM zg13_job_details INTO lv_id. " SLECT MAX JOB ID
    SPLIT lv_id AT 'J' INTO lv_temp lv_id.
    lv_id = lv_id + 1.
    SHIFT lv_id LEFT DELETING LEADING ' '.
    CONCATENATE 'J' lv_id INTO lv_id.
    ex_job_id = lv_id.

  ENDMETHOD.

  " GET COMPANY NAME BASED ON RECRUITER
  METHOD get_comapany_name.
    SELECT SINGLE company_name FROM zg13_recruiter INTO ex_comapany_name
     WHERE recruiter_id = im_id.
*    IF sy-subrc <> 0.
*      MESSAGE 'Comapnay name not found' TYPE 'I'.
*    ENDIF.
  ENDMETHOD.

  " GET QUESTION COUNT FOR JOB
  METHOD  question_count_for_job.

    SELECT COUNT(*) FROM zg13_que_bank INTO ex_count
      WHERE skill = im_table-skill_1
      OR skill = im_table-skill_2
      OR skill = im_table-skill_3 OR skill = im_table-skill_4.
*    IF sy-subrc <> 0.
*      MESSAGE 'Please Insert Quetions for Assessement' TYPE 'I'.
*    ENDIF.


  ENDMETHOD.


  " UPDATE APPLICANT DATA
  METHOD update_applicant_data.
    UPDATE zg13_applicant FROM im_applicant. "update applicant data
    IF sy-subrc <> 0.
      RAISE data_not_updated.
    ENDIF.
  ENDMETHOD.

  " DELETE APPLICANT DATA
  METHOD delete_applicant_data.

    DELETE zg13_applicant FROM im_applicant.
    IF sy-subrc <> 0.
      RAISE data_not_deleted.
    ENDIF.

  ENDMETHOD.

  "CHECK OLD PASSWORD OF APPLICANT
  METHOD check_old_password.
    DATA : lv_count TYPE i.
    SELECT COUNT(*) FROM zg13_applicant INTO lv_count
    WHERE applicant_id = im_applicant_id AND password = im_password." check old password is mateches or not
    IF lv_count  = 0.
      RAISE invalid_password.
    ENDIF.
  ENDMETHOD.

  " update old password based on applicant id
  METHOD update_old_password.
    UPDATE zg13_applicant SET password = im_password WHERE applicant_id = im_applicant_id.
    IF sy-subrc <> 0.
      RAISE password_not_updated.
    ENDIF.

  ENDMETHOD.

  METHOD apply_job.
    DATA : lv_count TYPE i." local counter
    DATA :max_assessment_id TYPE zg13_assessment-assessement_id.  " assessement id
    DATA : part1  TYPE string,
           max_id TYPE string. " max id

    "fetch applied job
    SELECT COUNT( * ) FROM zg13_assessment INTO lv_count
    WHERE applicant_id = im_applicant_id AND job_id = im_job_id.
    IF lv_count > 0.
      RAISE already_appied.
    ELSEIF lv_count = 0.

      "select max assessment id
      SELECT MAX( assessement_id ) FROM zg13_assessment INTO
      max_assessment_id.
      SPLIT max_assessment_id AT 'AS' INTO part1 max_id.
      max_id = max_id + 1.
      CONCATENATE 'AS' max_id INTO max_assessment_id. " concate max id with AS
      it_assessment_table-assessement_id = max_assessment_id.
      it_assessment_table-applicant_id = im_applicant_id.
      it_assessment_table-job_id = im_job_id.


      INSERT  zg13_assessment FROM it_assessment_table . " insert into assessment table
      IF sy-subrc = 0.
        CLEAR  it_assessment_table.
      ELSE.
        RAISE data_not_inserted.

      ENDIF.
    ENDIF.


  ENDMETHOD.

  " GET AND UPDATE QUESTION COUNT
  METHOD get_update_count.
    IF im_option = 'F'.
      SELECT *  FROM zg13_job_details INTO TABLE ex_job_table." FETCH JOB TABLE DATA
      IF sy-subrc <> 0.
        RAISE fecting_failed.
      ENDIF.
      SELECT *  FROM zg13_que_bank INTO TABLE ex_que_table ." FETCH QUESTION TABLE DATA
      IF sy-subrc <> 0.
        RAISE fecting_failed.
      ENDIF.
    ELSEIF  im_option = 'U'.
      UPDATE zg13_job_details FROM TABLE im_job_table. " UPDATE JOB TABLE DATA
    ENDIF.

  ENDMETHOD.

  METHOD get_assessment_count.
    " get count of assessment
    SELECT COUNT(*) FROM zg13_assessment INTO ex_count WHERE
     applicant_id = im_id AND percentage NE ''.

  ENDMETHOD.


ENDCLASS.