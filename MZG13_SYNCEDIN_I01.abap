*&---------------------------------------------------------------------*
*&  Include           MZG13_SYNCEDIN_I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*

MODULE user_command_0100 INPUT.
  "----> Local declarations for getting the cursor position
  DATA : lv_cursor_field(20),   "--> Cursor_Field
         lv_cursor_value(20).   "--> Cursor_Value

  "----> Checking the user_action
  CASE ok_code.
    WHEN 'PICK'.
      GET CURSOR FIELD lv_cursor_field VALUE lv_cursor_value.
      IF lv_cursor_field = 'TXT_REGISTRATION'.
*        CALL SCREEN 200.
        CLEAR ok_code.
        CALL SCREEN 110 STARTING AT 95 08   "--> TOP_LEFT position col1 lin1
            ENDING AT 165 12.               "--> BOTTOM_RIGHT position col2 lin2
        IF flag_applicant = 1 OR flag_recruiter = 1.
          CALL SCREEN 200.
        ENDIF.
      ENDIF.

      "--> Action on cliking Forgot Password
    WHEN 'FC_FORGOT_PASSWORD'.
      CALL SCREEN 400.

      "--> Action on cliking Login
    WHEN 'FC_LOGIN'.

      "--> Check if the user is Applicant
      IF zg13_applicant-applicant_id+0(1) = 'A'.

        "--> Method call to validate the Applicant ID
        lcl_syncedin=>validate_applicant(
          EXPORTING
            im_applicant_id   = zg13_applicant-applicant_id
            im_password       = io_password "zg13_applicant-password
          EXCEPTIONS
            invalid_applicant = 1
            OTHERS            = 2
        ).

        IF sy-subrc <> 0.
          CLEAR : zg13_applicant-applicant_id, io_password.
          MESSAGE 'Invalid ID or Password' TYPE 'E'.
        ELSE.
*          MESSAGE 'Valid Applicant' TYPE 'S'.
          CALL SCREEN 300.
        ENDIF.

        "--> Check if the user is Recruiter
      ELSEIF zg13_applicant-applicant_id+0(1) = 'R'.

        "--> Method call to validate the Recruiter ID
        lcl_syncedin=>validate_recruiter(
          EXPORTING
            im_recruiter_id   = zg13_applicant-applicant_id
            im_password       = io_password"zg13_applicant-password
          EXCEPTIONS
            invalid_recruiter = 1
            OTHERS            = 2
        ).
        IF sy-subrc <> 0.
          CLEAR : zg13_applicant-applicant_id, io_password.
          MESSAGE 'Invalid ID or Password' TYPE 'E'.
        ELSE.
*          MESSAGE 'valid Recruiter' TYPE 'S'.
          CALL SCREEN 500.
        ENDIF.

      ELSE.
        CLEAR zg13_applicant-applicant_id.
        CLEAR io_password.
        MESSAGE 'Invalid ID' TYPE 'E'.

      ENDIF .
*  	WHEN OTHERS.
  ENDCASE.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*

MODULE user_command_0200 INPUT.
  "----> Checking the user_action
  CASE ok_code.
*    WHEN 'FC_REFRESH_CAPTCH'.
*      flag_captcha = 0.
    WHEN 'FC_REGISTER'.
      "--> Verifying the captcha text
      IF io_captcha <> io_entered_captcha.

        MESSAGE 'Captcha text does not match! Enter the correct text' TYPE 'E'.
        SET CURSOR FIELD 'IO_ENTERED_CAPTCHA'.
      ENDIF.
*   WHEN OTHERS.
  ENDCASE.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  CHECK_PASSWORD  INPUT
*&---------------------------------------------------------------------*

MODULE check_password INPUT.
  "----> Checking the user_action
  CASE ok_code.
    WHEN 'FC_REGISTER'.
      IF flag_applicant = 1.      "--> Password validation for Appliant
        IF zg13_applicant-password <> io_conform_password.    "--> Matching the passwords for applicant
          MESSAGE 'Applicant password must be same' TYPE 'E'.
          SET CURSOR FIELD 'IO_CONFORM_PASSWORD'.
        ENDIF.
      ELSEIF flag_recruiter = 1.  "--> Password validation for Recruiter
        IF zg13_recruiter-password <> io_conform_password.  "--> Matching the passwords for recruiter
          MESSAGE 'Recruiter password must be same' TYPE 'E'.
          SET CURSOR FIELD 'IO_CONFORM_PASSWORD'.
        ENDIF.
      ENDIF.
  ENDCASE.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0110  INPUT
*&---------------------------------------------------------------------*

MODULE user_command_0110 INPUT.

  "--> Setting the flag for registration
  IF rb_applicant = 'X'.
    flag_applicant = 1.
  ELSEIF rb_recruiter = 'X'.
    flag_recruiter = 1.
  ENDIF.

  "--> Action on registration pop_up
  IF ok_code = 'FC_OK'.
    LEAVE TO SCREEN 0.
  ELSEIF ok_code = 'FC_CANCEL'.
    flag_applicant = 0.
    flag_recruiter = 0.
    LEAVE TO SCREEN 0.
  ENDIF.

ENDMODULE.


"--> Auto generated code for Table Control
*&SPWIZARD: INPUT MODUL FOR TC 'TC_JOB_DETAILS1'. DO NOT CHANGE THIS LIN
*&SPWIZARD: MARK TABLE
MODULE tc_job_details1_mark INPUT.
  DATA: g_tc_job_details1_wa2 LIKE LINE OF it_tc_job_details1.
  IF tc_job_details1-line_sel_mode = 1
  AND wa_tc_job_details1-mark = 'X'.
    LOOP AT it_tc_job_details1 INTO g_tc_job_details1_wa2
      WHERE mark = 'X'.
      g_tc_job_details1_wa2-mark = ''.
      MODIFY it_tc_job_details1
        FROM g_tc_job_details1_wa2
        TRANSPORTING mark.
    ENDLOOP.
  ENDIF.
  MODIFY it_tc_job_details1
    FROM wa_tc_job_details1
    INDEX tc_job_details1-current_line
    TRANSPORTING mark.
ENDMODULE.

*&SPWIZARD: INPUT MODULE FOR TC 'TC_JOB_DETAILS1'. DO NOT CHANGE THIS LI
*&SPWIZARD: PROCESS USER COMMAND
MODULE tc_job_details1_user_command INPUT.
  ok_code = sy-ucomm.
  PERFORM user_ok_tc USING    'TC_JOB_DETAILS1'
                              'IT_TC_JOB_DETAILS1'
                              'MARK'
                     CHANGING ok_code.
  sy-ucomm = ok_code.
ENDMODULE.

**&---------------------------------------------------------------------*
**&      Module  STATUS_0300  OUTPUT
**&---------------------------------------------------------------------*
*
*MODULE status_0300 OUTPUT.
*
*  SET PF-STATUS 'GUI_0300'.
*  SET TITLEBAR 'TITLE_0300' WITH login_applicant-name.
*
*ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*

MODULE user_command_0300 INPUT.

  "--> Action to take the assessment
  IF ok_code = 'FC_TAKE_A'.

    "--> Method call to get the selected Job ID
    lcl_syncedin=>return_selectd_job(
      EXPORTING
        itable         = it_tc_job_details1
      IMPORTING
        jobid          = selected_job_id
      EXCEPTIONS
        nolineselected = 1
        OTHERS         = 2
    ).

    IF sy-subrc <> 0.
      IF sy-subrc = 1.    "--> No line is selected
        MESSAGE 'Please select the assessment you want to take!' TYPE 'I'.
      ENDIF.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                 WITH 'Please select the assessment you want to take'.

    ELSEIF sy-subrc = 0.
      CLEAR assessment_id.

      "--> Method call to get the assessment id
      lcl_syncedin=>get_assessment_id(
        EXPORTING
          im_applicant_id  = zg13_applicant-applicant_id
          im_job_id        = selected_job_id
        IMPORTING
          ex_assessment_id = assessment_id
      ).

      IF assessment_id IS NOT INITIAL.
        assessment_id_str = assessment_id.

        "---> Calling the WDC application <---

        "--> Method call to construct url for app
        CALL METHOD cl_wd_utilities=>construct_wd_url
          EXPORTING
            application_name = 'ZWDC_G13_LETS_SYNC_APP'
          IMPORTING
            out_absolute_url = gv_url_string.


        "--> Method call to append assessment id into the url
        CALL METHOD cl_http_server=>append_field_url
          EXPORTING
            name  = 'ASSESSMENT_ID'   " Name
            value = assessment_id_str  " Value
          CHANGING
            url   = gv_url_string.     " URL

        gv_url_c = gv_url_string.

        "--> Function call to call the browser
        CALL FUNCTION 'CALL_BROWSER'
          EXPORTING
            url                    = gv_url_c
*           WINDOW_NAME            = ' '
            new_window             = 'X'
*           BROWSER_TYPE           =
*           CONTEXTSTRING          =
          EXCEPTIONS
            frontend_not_supported = 1
            frontend_error         = 2
            prog_not_found         = 3
            no_batch               = 4
            unspecified_error      = 5
            OTHERS                 = 6.

        IF sy-subrc <> 0.
          MESSAGE 'An error occured while transferring to the web dyn pro application' TYPE 'E'.
        ENDIF.

      ENDIF.
    ENDIF.

    "--> Action on selecting the past assessments
  ELSEIF ok_code = 'FC_PAST_A'.

    DATA : lv_assessment_count TYPE i.

    "--> Method call to get the count of past assessments
    lcl_syncedin=>get_assessment_count(
      EXPORTING
        im_id    =  zg13_applicant-applicant_id
      IMPORTING
        ex_count = lv_assessment_count
    ).

    IF lv_assessment_count = 0.   "--> No past assessments
      MESSAGE 'You have not taken any assessment!' TYPE 'I'.
    ELSE.
      "--> Calling the function to get the FM name
      CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
        EXPORTING
          formname = 'ZSF_G13_SCORES'
*         VARIANT  = ' '
*         DIRECT_CALL              = ' '
        IMPORTING
          fm_name  = fmname
*         NO_FORM  = 1
*         NO_FUNCTION_MODULE       = 2
*         OTHERS   = 3
        .

      IF sy-subrc <> 0.
* Implement suitable error handling here if required
      ENDIF.


      "Calling the Smartform using the function module name
      CALL FUNCTION fmname
        EXPORTING
          im_applicant_id = zg13_applicant-applicant_id.
*       EXCEPTIONS
*         FORMATTING_ERROR           = 1
*         INTERNAL_ERROR  = 2
*         SEND_ERROR      = 3
*         USER_CANCELED   = 4
*         OTHERS          = 5.
    ENDIF.

    "--> Action on Apply for Job
  ELSEIF ok_code = 'FC_APPLY'.
    lcl_syncedin=>return_selectd_job(     "--> Method call to get the selected Job ID
      EXPORTING
        itable         = it_tc_job_details1
      IMPORTING
        jobid          = selected_job_id
      EXCEPTIONS
        nolineselected = 1
        OTHERS         = 2
    ).

    IF sy-subrc <> 0.   "--> Exception: No job selected
      MESSAGE 'Select the job you want apply for!' TYPE 'I'.
    ELSEIF sy-subrc = 0.

      "--> Method call to apply for the job and update DDIC table
      lcl_syncedin=>apply_job(
        EXPORTING
          im_applicant_id   = zg13_applicant-applicant_id
          im_job_id         =  selected_job_id
        EXCEPTIONS
          already_appied    = 1
          data_not_inserted = 2
          OTHERS            = 3
      ).

      IF sy-subrc = 1.      "--> Exception: When already applied for the job
        MESSAGE 'You have already applied for this job!' TYPE 'I'.
      ELSEIF sy-subrc = 2.
*        MESSAGE 'Data not inserted' TYPE 'E'.
        MESSAGE 'Failed to apply for the selected job!' TYPE 'E'.
      ELSEIF sy-subrc = 0.
        MESSAGE 'Applied for the selected job sucessfully!' TYPE 'S'.
      ENDIF.
    ENDIF.

    "--> On action of View_Applicant_Profile
  ELSEIF ok_code = 'FC_VIEW_PR'.
    CALL SCREEN '0310'.
  ENDIF.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  CHECK_PASSWORD_FORMAT  INPUT
*&---------------------------------------------------------------------*
*       Password Validation Module
*----------------------------------------------------------------------*
MODULE check_password_format INPUT.
  IF flag_captcha = 0.

    DATA pass TYPE zg13_applicant-password.

    "--> Applicant password identification
    IF flag_applicant = 1.
      pass = zg13_applicant-password.
      SET CURSOR FIELD  'ZG13_APPLICANT-PASSWORD' .

      "--> Recruiter password identification
    ELSEIF flag_recruiter = 1.
      pass = zg13_recruiter-password.
      SET CURSOR FIELD  'ZG13_RECRUITER-PASSWORD' .
    ENDIF.

    "--> Password Validation
    IF strlen( pass ) >= 6 AND strlen( pass ) <= 12  .
      IF pass CA string1 .
        IF pass CA string2.
          IF pass CA string3.
            IF pass CA string4 .
*              MESSAGE 'Password Validated!' TYPE 'I'.
            ELSE.
              MESSAGE 'Password must contain at least one digit' TYPE 'E'.
            ENDIF.
          ELSE.
            MESSAGE 'Password must contain at least one special character' TYPE 'E'.
          ENDIF.

        ELSE.
          MESSAGE 'Password must contain at least one capital letter' TYPE 'E'.
        ENDIF.
      ELSE.
        MESSAGE 'Password must contain at least one small letter' TYPE 'E'.

      ENDIF.
    ELSE.
      MESSAGE 'Password length must be between 6 to 12' TYPE 'E'.
    ENDIF.

  ENDIF.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  VALIDATE_EMAIL  INPUT
*&---------------------------------------------------------------------*
*       Module for email validation
*----------------------------------------------------------------------*

MODULE validate_email INPUT.
  IF   flag_captcha = 0.
    DATA: go_regex   TYPE REF TO cl_abap_regex,
          go_matcher TYPE REF TO cl_abap_matcher,
          go_match   TYPE c LENGTH 1,
          gv_msg     TYPE string.

    "--> Email validation for appliacnt
    IF flag_applicant = 1.
*    email = zg13_applicant-email_id.
      CREATE OBJECT go_regex
        EXPORTING
          pattern     = '\w+(\.\w+)*@(\w+\.)+(\w{2,4})'
          ignore_case = abap_true.

      go_matcher = go_regex->create_matcher( text =   zg13_applicant-email_id ).

      IF go_matcher->match( ) IS INITIAL.
*        gv_msg = 'Email address is invalid'.
        gv_msg = 'Please provide your Email ID'.
        SET CURSOR FIELD 'ZG13_APPLICANT-EMAIL_ID'.
        MESSAGE gv_msg TYPE 'E'.
      ELSE.
        gv_msg = 'Email address is valid'.

*        MESSAGE gv_msg TYPE 'I'.
      ENDIF.

      "--> Email validation for Recruiter
    ELSEIF flag_recruiter = 1.
*    email  = zg13_recruiter-email_id.

      CREATE OBJECT go_regex
        EXPORTING
          pattern     = '\w+(\.\w+)*@(\w+\.)+(\w{2,4})'
          ignore_case = abap_true.

      go_matcher = go_regex->create_matcher( text =   zg13_recruiter-email_id ).

      IF go_matcher->match( ) IS INITIAL.
        gv_msg = 'Email address is invalid'.
        SET CURSOR FIELD 'ZG13_RECRUITER-EMAIL_ID'.
        MESSAGE gv_msg TYPE 'E'.
      ELSE.
        gv_msg = 'Email address is valid'.
*        MESSAGE gv_msg TYPE 'I'.
      ENDIF.
    ENDIF.

  ENDIF.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0400  INPUT
*&---------------------------------------------------------------------*

MODULE user_command_0400 INPUT.
  DATA: importing_id TYPE zg13_applicant-applicant_id.

  "--> Action on clicking the Change Password Button
  IF ok_code = 'FC_CHANGE_PASSWORD'.
    IF zg13_applicant-applicant_id IS NOT INITIAL AND zg13_recruiter-recruiter_id IS NOT INITIAL.
      MESSAGE 'Plesae select only one option' TYPE 'E'. "--> If both IDs are provided
    ELSE.
      DATA pass1 TYPE zg13_applicant-password.
      pass1 = zg13_recruiter-password.
      IF strlen( pass1 ) >= 6 AND strlen( pass1 ) <= 12 . "--> Length validation
        IF pass1 CA string1 .         "--> Small letter validation
          IF pass1 CA string2.        "--> Capital letter validation
            IF pass1 CA string3.      "--> Special character validation
              IF pass1 CA string4 .   "--> Digit letter validation
                IF pass1 <> io_conform_password.  "--> Password mis-match validation
                  MESSAGE 'Both password must be same' TYPE 'E'.
                ENDIF.
              ELSE.
                MESSAGE 'Password must contain at least one digit' TYPE 'E'.
              ENDIF.
            ELSE.
              MESSAGE 'Password must contain at least one special character' TYPE 'E'.
            ENDIF.
          ELSE.
            MESSAGE 'Password must contain at least one capital letter' TYPE 'E'.
          ENDIF.
        ELSE.
          MESSAGE 'Password must contain at least one small letter' TYPE 'E'.
        ENDIF.
      ELSE.
        MESSAGE 'Password length must be between 6 to 12' TYPE 'E'.
      ENDIF.

      IF zg13_applicant-applicant_id IS NOT INITIAL.
        importing_id = zg13_applicant-applicant_id.
      ELSEIF zg13_recruiter-recruiter_id IS NOT INITIAL.
        importing_id = zg13_recruiter-recruiter_id.
      ENDIF.

      "--> Method call to update the DDIC table with new password
      lcl_syncedin=>forgot_password(
        EXPORTING
          im_id                = importing_id
          im_security_que      = zg13_applicant-security_que
          im_security_ans      = zg13_applicant-security_ans
          im_password          = zg13_recruiter-password
        EXCEPTIONS
          password_not_updated = 1
          OTHERS               = 2
      ).

      IF sy-subrc <> 0.   "--> Failed to reset the Password
*  MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*             WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        CLEAR zg13_applicant.
        CLEAR io_conform_password.
        CLEAR zg13_recruiter.
        MESSAGE 'Failed to update the password. Provide correct security question and answer.' TYPE 'E'.
      ELSEIF sy-subrc = 0.    "--> Password reset successfull
        CLEAR zg13_applicant.
        CLEAR io_conform_password.
        CLEAR zg13_recruiter.
        MESSAGE 'Password updated successfully. You are redirected to login page'  TYPE 'S'.
        LEAVE TO SCREEN 0.
      ENDIF.
    ENDIF.
  ENDIF.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  REGISTER_DATA  INPUT
*&---------------------------------------------------------------------*
*       New user registration
*----------------------------------------------------------------------*

MODULE register_data INPUT.
  IF flag_captcha = 0.

    "--> Registration for new Applicant
    IF zg13_applicant-applicant_id IS NOT INITIAL.
      lcl_syncedin=>register_applicant(   "--> Method call to register new applicant
        EXPORTING
          im_applicant        = zg13_applicant
        EXCEPTIONS
          registration_failed = 1
          OTHERS              = 2
      ).

      IF sy-subrc <> 0.
        MESSAGE 'Registration failed. Try Again!' TYPE 'E'.
      ELSE.
        flag_register = 1.
        MESSAGE 'Registration successful' TYPE 'S'.
      ENDIF.

      "--> Registration for new Recruiter
    ELSEIF  zg13_recruiter-recruiter_id IS NOT INITIAL.
      zg13_recruiter-security_que = zg13_applicant-security_que.
      zg13_recruiter-security_ans = zg13_applicant-security_ans.

      lcl_syncedin=>register_recruiter(   "--> Method call to register new recruiter
        EXPORTING
          im_register         = zg13_recruiter
        EXCEPTIONS
          registration_failed = 1
          alredy_present      = 2
          OTHERS              = 3
      ).
      IF sy-subrc = 0.
        flag_register = 1.
        MESSAGE 'Registration successful' TYPE 'S'.
      ELSEIF sy-subrc = 1.
        MESSAGE 'Registration Failed. Try Again' TYPE 'E'.
      ELSEIF sy-subrc = 2.
        MESSAGE 'User already exist' TYPE 'E'.
      ENDIF.

    ENDIF.
  ELSE.
    flag_captcha = 0.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_MODULE_0200  INPUT
*&---------------------------------------------------------------------*

MODULE exit_module_0200 INPUT.

  IF ok_code = 'FC_BACK'.
    flag_captcha = 0.
    CLEAR io_password.
    flag_captcha = 0.
    flag_change_password = 0.
    flag_register = 0.
    flag_recruiter = 0.
    flag_applicant = 0.
    CLEAR io_conform_password.
    CLEAR zg13_applicant.
    CLEAR zg13_recruiter.
    LEAVE TO SCREEN 0.
  ELSEIF ok_code = 'FC_EXIT'.
*    LEAVE PROGRAM.

    CALL FUNCTION 'POPUP_WITH_2_BUTTONS_TO_CHOOSE'
      EXPORTING
*       DEFAULTOPTION = '1'
        diagnosetext1 = 'Do you want to exit?'
*       DIAGNOSETEXT2 = ' '
*       DIAGNOSETEXT3 = ' '
        textline1     = 'Yes or No'
*       TEXTLINE2     = ' '
*       TEXTLINE3     = ' '
        text_option1  = 'Yes'
        text_option2  = 'No'
        titel         = 'Exit'
      IMPORTING
        answer        = ans.

    CASE ans.
      WHEN '1'. " when yes leave program
        LEAVE PROGRAM.
      WHEN '2'." when no back to program
        flag_captcha = 1.
      WHEN OTHERS.
    ENDCASE.
  ELSEIF ok_code = 'FC_CANCEL'.
    flag_captcha = 0.
    flag_change_password = 0.
    flag_register = 0.
    CLEAR io_conform_password.
    CLEAR io_password.
    CLEAR zg13_applicant.
    CLEAR zg13_recruiter.
*    LEAVE TO SCREEN 200.
    LEAVE TO SCREEN sy-dynnr.

  ELSEIF ok_code = 'FC_REFRESH_CAPTCH'.
    flag_captcha = 1.
*        LEAVE TO SCREEN 200.
    CLEAR ok_code.

  ENDIF.

ENDMODULE.
**&---------------------------------------------------------------------*
**&      Module  STATUS_0310  OUTPUT
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
*MODULE status_0310 OUTPUT.
*
*  IF flag_edit_details = 1.
*    SET PF-STATUS 'GUI_0310'.   "Sets the screen toolbars
*
*  ELSEIF flag_edit_details = 0.
*    wa_ok_code_table-ok_code = 'FC_SAVE'.
*    APPEND wa_ok_code_table TO it_ok_code_table.
*    CLEAR wa_ok_code_table.
*    wa_ok_code_table-ok_code = 'FC_DETAIL'.
*    APPEND wa_ok_code_table TO it_ok_code_table.
*    CLEAR wa_ok_code_table.
*    SET PF-STATUS 'GUI_0310' EXCLUDING it_ok_code_table.
*
*  ENDIF.
*
*  SET TITLEBAR 'TITLE_0310' WITH zg13_applicant-name.
*
*ENDMODULE.

*&SPWIZARD: INPUT MODULE FOR TS 'TB_POSTED_JOB'. DO NOT CHANGE THIS LINE
*&SPWIZARD: GETS ACTIVE TAB
MODULE tb_posted_job_active_tab_get INPUT.
  ok_code = sy-ucomm.
  CASE ok_code.
    WHEN c_tb_posted_job-tab1.
      g_tb_posted_job-pressed_tab = c_tb_posted_job-tab1.
    WHEN c_tb_posted_job-tab2.
      g_tb_posted_job-pressed_tab = c_tb_posted_job-tab2.
    WHEN OTHERS.
*&SPWIZARD:      DO NOTHING
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0510  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0510 INPUT.
  IF ok_code  = 'FC_VIEW_APPLICATION'.

    CALL METHOD g_alv_grid_ref->get_selected_rows
      IMPORTING
*       et_index_rows =   " Indexes of Selected Rows
        et_row_no = it_selected_posted_job_num_id.  " Numeric IDs of Selected Rows

    IF it_selected_posted_job_num_id IS INITIAL.
      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
        EXPORTING
          titel     = 'Information'
          textline1 = 'Please select at least one row'
*         TEXTLINE2 = ' '
*         START_COLUMN       = 25
*         START_ROW = 6
        .
    ELSE.
      REFRESH it_selected_posted_job.
      LOOP AT it_selected_posted_job_num_id INTO wa_selected_posted_job_num_id.
        READ TABLE it_posted_job_table INTO  wa_selected_posted_job-job_id INDEX wa_selected_posted_job_num_id-row_id.
*          wa_selected_posted_job-job_id
        CONDENSE  wa_selected_posted_job-job_id NO-GAPS.
        APPEND  wa_selected_posted_job-job_id TO it_selected_posted_job.
      ENDLOOP.
      DATA: it TYPE zg13_recruiter-recruiter_id VALUE 'R1002'.
*      SET PARAMETER ID 'ID_IT_TABLE' FIELD it_selected_posted_job.
      EXPORT it_selected_posted_job TO SHARED BUFFER indx(st) ID 'ID_IT_TABLE'.
      SET PARAMETER ID 'ID_RECRUITER_ID' FIELD it.
      CALL TRANSACTION 'ZRPRG13_TRANSACTION' .
*      CALL SCREEN 600.
    ENDIF.

  ENDIF.


ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_0500  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_0500 INPUT.

  IF ok_code = 'FC_EXIT'.
*    LEAVE PROGRAM.
    CALL FUNCTION 'POPUP_WITH_2_BUTTONS_TO_CHOOSE'
      EXPORTING
*       DEFAULTOPTION = '1'
        diagnosetext1 = 'Do you want to exit?'
*       DIAGNOSETEXT2 = ' '
*       DIAGNOSETEXT3 = ' '
        textline1     = 'Yes or No'
*       TEXTLINE2     = ' '
*       TEXTLINE3     = ' '
        text_option1  = 'Yes'
        text_option2  = 'No'
        titel         = 'Exit'
      IMPORTING
        answer        = ans.

    CASE ans.
      WHEN '1'. " when yes leave program
        LEAVE PROGRAM.
      WHEN '2'." when no back to program
        flag_captcha = 1.
      WHEN OTHERS.
    ENDCASE.
  ELSEIF ok_code = 'FC_CANCEL'.
    CLEAR zg13_job_details.
    CLEAR io_questin_file_path.
    LEAVE TO SCREEN 500.
  ELSEIF ok_code = 'FC_LOGOUT'.
    CLEAR zg13_recruiter.
    CLEAR io_password.
    CLEAR zg13_applicant.
    CLEAR zg13_job_details.
    CLEAR io_questin_file_path.
    LEAVE TO SCREEN 100.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  DESCRIPTION_VALIDATION_0520  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE description_validation_0520 INPUT.
  IF zg13_job_details-description IS INITIAL.   "--> Empty description validation
    MESSAGE 'Please enter the description of job' TYPE 'E'.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  LOCATION_VALIDATION_0520  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE location_validation_0520 INPUT.

  IF zg13_job_details-location IS INITIAL.  "--> Empty location validation
    MESSAGE 'Please enter the location of job' TYPE 'E'.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  SALARY_VALIDATION_0520  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE salary_validation_0520 INPUT.
  IF zg13_job_details-min_sal IS INITIAL .  "--> Empty Min Salary validation
    MESSAGE 'Please Fill the Minimum Salary of Job' TYPE 'E'.
  ELSEIF zg13_job_details-max_sal IS INITIAL. "--> Empty Max Salary validation
    MESSAGE 'Please Fill the Maximum Salary of Job' TYPE 'E'.
  ELSEIF zg13_job_details-min_sal  > zg13_job_details-max_sal.  "Max sal must be greater than Min
    MESSAGE 'Min Salary Must be lesser than Max Salary' TYPE 'E'.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  SKILL_VALIDATION_0520  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE skill_validation_0520 INPUT.
  IF zg13_job_details-skill_1 IS INITIAL
    AND zg13_job_details-skill_2 IS INITIAL
    AND zg13_job_details-skill_3 IS INITIAL
    AND zg13_job_details-skill_4 IS INITIAL.
    MESSAGE 'Please fill at least one skill' TYPE 'E'.

  ELSEIF zg13_job_details-skill_1 IS INITIAL
    AND zg13_job_details-skill_2 IS NOT INITIAL
    OR zg13_job_details-skill_3 IS NOT  INITIAL
    OR zg13_job_details-skill_4 IS NOT  INITIAL.
    MESSAGE 'First skill can not be empty' TYPE 'E'.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0520  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0520 INPUT.
  IF ok_code = 'FC_SAVE'.

    " Description Field Validation
    IF zg13_job_details-description IS INITIAL.
      SET CURSOR FIELD 'ZG13_JOB_DETAILS-DESCRIPTION'.
      MESSAGE 'Please Fill the Description of Job' TYPE 'E'.

      " Location Field Validation
    ELSEIF zg13_job_details-location IS INITIAL.
      SET CURSOR FIELD 'ZG13_JOB_DETAILS-LOCATION'.
      MESSAGE 'Please Fill the location of Job' TYPE 'E'.

      " Salary Field Validation
    ELSEIF zg13_job_details-min_sal IS INITIAL .
      SET CURSOR FIELD 'ZG13_JOB_DETAILS-MIN_SAL'.
      MESSAGE 'Please Fill the Minimum Salary of Job' TYPE 'E'.
    ELSEIF zg13_job_details-max_sal IS INITIAL.
      SET CURSOR FIELD 'ZG13_JOB_DETAILS-MAX_SAL'.
      MESSAGE 'Please Fill the Maximum Salary of Job' TYPE 'E'.
    ELSEIF zg13_job_details-min_sal  > zg13_job_details-max_sal.
      SET CURSOR FIELD 'ZG13_JOB_DETAILS-MIN_SAL'.
      MESSAGE 'Min Salary Must be lesser than Max Salary' TYPE 'E'.

      "skill validation
    ELSEIF zg13_job_details-skill_1 IS INITIAL
      AND zg13_job_details-skill_2 IS INITIAL
      AND zg13_job_details-skill_3 IS INITIAL
      AND zg13_job_details-skill_4 IS INITIAL.
      SET CURSOR FIELD 'ZG13_JOB_DETAILS-SKILL_1'.
      MESSAGE 'Please Fill at least one skill' TYPE 'E'.

    ELSEIF zg13_job_details-skill_1 IS INITIAL
      AND zg13_job_details-skill_2 IS NOT INITIAL
      OR zg13_job_details-skill_3 IS NOT  INITIAL
      OR zg13_job_details-skill_4 IS NOT  INITIAL.
      SET CURSOR FIELD 'ZG13_JOB_DETAILS-SKILL_1'.
      MESSAGE 'First skill can not be empty' TYPE 'E'.
    ELSEIF zg13_job_details-question_count IS INITIAL.
      SET CURSOR FIELD 'ZG13_JOB_DETAILS-QUESTION_COUNT'.
      MESSAGE 'Enter no of questions' TYPE 'E'.
    ELSEIF zg13_job_details-question_count CN string4.
      SET CURSOR FIELD 'ZG13_JOB_DETAILS-QUESTION_COUNT'.
      MESSAGE 'Invalid questions count' TYPE 'E'.
    ELSE.
      zg13_job_details-recruiter_id = zg13_applicant-applicant_id.
*      lcl_syncedin=>question_count_for_job(
*        EXPORTING
*          im_table =  zg13_job_details
*        IMPORTING
*          ex_count = zg13_job_details-question_count
*      ).
*      DATA q TYPE string.
*      q = zg13_job_details-question_count.
*      SHIFT q LEFT DELETING LEADING '0'.
*      zg13_job_details-question_count = q.

*   MESSAGE Q TYPE 'I'.

      INSERT zg13_job_details.
      IF sy-subrc <> 0.
        MESSAGE 'Data not inserted' TYPE 'E'.
      ELSEIF sy-subrc = 0.
        MESSAGE 'Data Inserted Sucessfully' TYPE 'I'.
        CLEAR zg13_job_details.
        CLEAR io_questin_file_path.
      ENDIF.
    ENDIF.
  ELSEIF ok_code = 'FC_UPLOAD'.
    "--> If no file is selected
    IF io_questin_file_path IS INITIAL.
      MESSAGE 'Please select file to upload' TYPE 'I'.
    ELSE.
      "-->  Function call for file upload
      CALL FUNCTION 'GUI_UPLOAD'
        EXPORTING
          filename            = io_questin_file_path
          has_field_separator = 'X'
        TABLES
          data_tab            = it_take_data.
      IF sy-subrc <> 0.
* Implement suitable error handling here
        MESSAGE 'File not Read' TYPE 'I'.
      ELSEIF sy-subrc = 0.
        DATA : max_id TYPE zg13_que_bank-question_id.
        SELECT MAX( question_id )  FROM zg13_que_bank INTO max_id." GET MAX ID
        MOVE-CORRESPONDING it_take_data TO it_upload_data. " MOVE DATA TO IT_UPLOAD TTABLE
        LOOP AT it_upload_data INTO wa_upload_data. " LOOP FOR TRANSLATE DATA IN UPPER CASE
          TRANSLATE wa_upload_data TO UPPER CASE.
          MODIFY it_upload_data FROM wa_upload_data.
        ENDLOOP.
        DATA : count TYPE i.
        DATA : count1 TYPE string.
        DATA : lv_question_count TYPE i ." question count that to be not uploaded

        LOOP AT it_upload_data INTO wa_upload_data. " LLOP FFOR CHECK DATA FROMAT IN FILE

          DATA len TYPE i.

          IF wa_upload_data-question IS  INITIAL
            OR wa_upload_data-option1 IS INITIAL
            OR wa_upload_data-option2 IS  INITIAL
            OR wa_upload_data-option3 IS  INITIAL
            OR wa_upload_data-option4 IS  INITIAL
            OR wa_upload_data-answer IS INITIAL
            OR wa_upload_data-skill IS INITIAL
*            OR wa_upload_data-answer CA '23456789'.
            OR wa_upload_data-answer CN '01'.


*                 MESSAGE 'BOOOO' TYPE 'I'.
            lv_question_count = lv_question_count + 1.
            DELETE TABLE it_upload_data FROM wa_upload_data.
          ELSE.
            SPLIT max_id AT 'Q' INTO part1 split_id.
            split_id = split_id + 1.
            CONCATENATE 'Q' split_id INTO max_id.
*              MESSAGE MAX_ID TYPE 'I'.
            wa_upload_data-question_id = max_id.
            MODIFY it_upload_data FROM wa_upload_data TRANSPORTING question_id.
          ENDIF.
        ENDLOOP.

        IF it_upload_data IS NOT INITIAL.

          INSERT zg13_que_bank FROM TABLE it_upload_data. "Sending data to database table
          IF sy-subrc = 0.
*            DATA: it_job      TYPE TABLE OF zg13_job_details,
*                  wa_job      LIKE LINE OF it_job,
*                  it_question TYPE TABLE OF zg13_que_bank,
*                  wa_question LIKE LINE OF it_question.
*            lcl_syncedin=>get_update_count(
*              EXPORTING
*                im_option      =  'F'
**                    im_job_table   =
*              IMPORTING
*                ex_job_table   = it_job
*                ex_que_table   = it_question
**                  EXCEPTIONS
**                    fecting_failed = 1
**                    not_updated    = 2
**                    others         = 3
*            ).
*            IF sy-subrc = 0.
**                 MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
**                            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*              DATA :lv_counter TYPE i.
*              LOOP AT it_job INTO wa_job.
*                LOOP AT it_question INTO wa_question.
*
*                  IF wa_question-skill = wa_job-skill_1
*                    OR wa_question-skill = wa_job-skill_2
*                    OR wa_question-skill = wa_job-skill_3
*                    OR wa_question-skill = wa_job-skill_4.
*                    lv_counter = lv_counter + 1.
*                  ENDIF.
*
*                ENDLOOP.
*                wa_job-question_count =  lv_counter.
*                lv_counter = 0.
*                MODIFY it_job FROM wa_job.
*              ENDLOOP.
*              lcl_syncedin=>get_update_count(
*                EXPORTING
*                  im_option      = 'U'
*                  im_job_table   = it_job
**                IMPORTING
**                  ex_job_table   =
**                  ex_que_table   =
**                EXCEPTIONS
**                  fecting_failed = 1
**                  not_updated    = 2
**                  others         = 3
*              ).
*              IF sy-subrc = 0.
**               MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
**                          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*
*              ENDIF.
*
*
*            ENDIF.
            CLEAR io_questin_file_path.
            IF lv_question_count = 0.
              MESSAGE 'Insertion successful' TYPE 'I'.
            ELSE.
              DATA: str_lv_question_count TYPE string.
              str_lv_question_count = lv_question_count.
              IF str_lv_question_count = 1.
                CONCATENATE 'Your' str_lv_question_count 'question is not inserted'
                INTO str_lv_question_count SEPARATED BY ' '.
              ELSE.
                CONCATENATE 'Your' str_lv_question_count 'questions are not inserted'
              INTO str_lv_question_count SEPARATED BY ' '.
              ENDIF.
              MESSAGE str_lv_question_count TYPE 'I'.
            ENDIF.
            "Customized message
          ELSEIF sy-subrc <> 0.
            CLEAR io_questin_file_path.
            MESSAGE 'Insertion failed Error in Your Question File' TYPE 'I'. "Customized message
          ENDIF.
        ELSE.
          CLEAR io_questin_file_path.
          MESSAGE 'Questions are not Inserted bcoz error in text file' TYPE 'I'.

        ENDIF.

      ENDIF.

    ENDIF.

  ENDIF.
  CLEAR ok_code.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  BROWSE_FILE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE browse_file INPUT.

  DATA: lv_title     TYPE string VALUE 'Browse File', " title
        lt_filetable TYPE filetable, " file internal table
        lv_rc        TYPE i, " Recturn code
        lv_file(200) TYPE c. " file path
  DATA: lwa_filetable LIKE LINE OF lt_filetable. " work area of type filetable

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title = lv_title    " Title Of File Open Dialog
*     default_extension       =     " Default Extension
*     default_filename        =     " Default File Name
*     file_filter  =     " File Extension Filter String
*     with_encoding           =     " File Encoding
*     initial_directory       =     " Initial Directory
*     multiselection          =     " Multiple selections poss.
    CHANGING
      file_table   = lt_filetable   " Table Holding Selected Files
      rc           = lv_rc  " Return Code, Number of Files or -1 If Error Occurred
*     user_action  =     " User Action (See Class Constants ACTION_OK, ACTION_CANCEL)
*     file_encoding           =
*        EXCEPTIONS
*     file_open_dialog_failed = 1
*     cntl_error   = 2
*     error_no_gui = 3
*     not_supported_by_gui    = 4
*     others       = 5
    .
  IF sy-subrc = 0.
    READ TABLE lt_filetable INTO lwa_filetable INDEX 1.
    IF sy-subrc EQ 0.
      lv_file  = lwa_filetable-filename.

      IF sy-subrc EQ 0.
        TRANSLATE lv_file TO UPPER CASE.
        io_questin_file_path = lv_file.
*          MESSAGE lv_file TYPE 'I'.
      ENDIF.
    ENDIF.
  ENDIF.
  CLEAR ok_code.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_0400  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_0400 INPUT.

  IF ok_code = 'FC_EXIT'.
    LEAVE PROGRAM.
  ELSEIF ok_code = 'FC_BACK'.
    CLEAR zg13_applicant-applicant_id.
    CLEAR zg13_recruiter-recruiter_id.
    CLEAR zg13_applicant-security_que.
    CLEAR zg13_applicant-security_ans.
    CLEAR zg13_recruiter-password.
    CLEAR io_conform_password.
    LEAVE TO SCREEN 0.
  ELSEIF ok_code = 'FC_CANCEL'.
    CLEAR zg13_applicant-applicant_id.
    CLEAR zg13_recruiter-recruiter_id.
    CLEAR zg13_applicant-security_que.
    CLEAR zg13_applicant-security_ans.
    CLEAR zg13_recruiter-password.
    CLEAR io_conform_password.
    LEAVE TO SCREEN 400.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_0310  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_0310 INPUT.

  IF ok_code = 'FC_BACK'.
    flag_edit_details = 0.
    LEAVE TO SCREEN 0.
  ELSEIF ok_code = 'FC_EXIT'.
*    LEAVE PROGRAM.
    CALL FUNCTION 'POPUP_WITH_2_BUTTONS_TO_CHOOSE'
      EXPORTING
*       DEFAULTOPTION = '1'
        diagnosetext1 = 'Do you want to exit?'
*       DIAGNOSETEXT2 = ' '
*       DIAGNOSETEXT3 = ' '
        textline1     = 'Yes or No'
*       TEXTLINE2     = ' '
*       TEXTLINE3     = ' '
        text_option1  = 'Yes'
        text_option2  = 'No'
        titel         = 'Exit'
      IMPORTING
        answer        = ans.

    CASE ans.
      WHEN '1'. " when yes leave program
        LEAVE PROGRAM.
      WHEN '2'." when no back to program
        flag_captcha = 1.
      WHEN OTHERS.
    ENDCASE.
  ELSEIF ok_code = 'FC_CANCEL'.
    LEAVE TO SCREEN 310.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0310  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0310 INPUT.

  IF ok_code = 'FC_EDIT'.
    IF flag_edit_details = 1.
      flag_edit_details = 0.
    ELSEIF flag_edit_details = 0.
      flag_edit_details = 1.
    ENDIF.

  ELSEIF ok_code = 'FC_SAVE'.
*    MESSAGE zg13_applicant TYPE 'I'.
    lcl_syncedin=>update_applicant_data(
      EXPORTING
        im_applicant     = zg13_applicant
      EXCEPTIONS
        data_not_updated = 1
        OTHERS           = 2
    ).
    IF sy-subrc <> 0.
*     MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      MESSAGE 'Data not updated' TYPE 'E'.
    ELSEIF sy-subrc = 0.
      flag_edit_details = 0.
      MESSAGE 'Data Updated' TYPE 'I'.
    ENDIF.
  ELSEIF ok_code = 'FC_DELETE'.

    lcl_syncedin=>delete_applicant_data(
      EXPORTING
        im_applicant     = zg13_applicant
      EXCEPTIONS
        data_not_deleted = 1
        OTHERS           = 2
    ).
    IF sy-subrc <> 0.
*     MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      MESSAGE 'Data Not Deleleted' TYPE 'I'.
    ELSEIF sy-subrc = 0.
      CLEAR zg13_applicant.
      MESSAGE 'Data Deleted Sucessfully' TYPE 'I'.
      LEAVE TO SCREEN 100.
    ENDIF.
  ELSEIF ok_code = 'FC_DETAIL'.

    CLEAR ok_code.
    CLEAR zg13_applicant-password.
    CALL SCREEN 320 STARTING AT 10 08 " TOP LEFT
        ENDING AT 100 20. " BOTTOM RIGHT " 20 FOR HEIGHT 100 FOR WIDTH

  ENDIF.
  CLEAR ok_code.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_0300 INPUT.

  IF ok_code = 'FC_EXIT'.
*    LEAVE PROGRAM.
    CALL FUNCTION 'POPUP_WITH_2_BUTTONS_TO_CHOOSE'
      EXPORTING
*       DEFAULTOPTION = '1'
        diagnosetext1 = 'Do you want to exit?'
*       DIAGNOSETEXT2 = ' '
*       DIAGNOSETEXT3 = ' '
        textline1     = 'Yes or No'
*       TEXTLINE2     = ' '
*       TEXTLINE3     = ' '
        text_option1  = 'Yes'
        text_option2  = 'No'
        titel         = 'Exit'
      IMPORTING
        answer        = ans.

    CASE ans.
      WHEN '1'. " when yes leave program
        LEAVE PROGRAM.
      WHEN '2'." when no back to program
        flag_captcha = 1.
      WHEN OTHERS.
    ENDCASE.
  ELSEIF ok_code = 'FC_CANCEL'.

    LEAVE TO SCREEN 300.
  ELSEIF ok_code = 'FC_LOGOUT'.
    flag_applicant = 0.
    flag_register = 0.
    flag_captcha = 0.
    flag_change_password = 0.
    flag_recruiter = 0.
    CLEAR io_password .
    CLEAR zg13_applicant.
    CLEAR zg13_recruiter.
    LEAVE TO SCREEN 100.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0320  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0320 INPUT.

  IF ok_code = 'FC_TOGGLE'.
    IF flag_toggle_password = 0.
      flag_toggle_password = 1.
    ELSEIF flag_toggle_password = 1.
      flag_toggle_password = 0.
    ENDIF.
  ELSEIF ok_code = 'FC_OK'.
    CLEAR io_conform_password.
    CLEAR io_new_password.
    CLEAR zg13_applicant-password.
    LEAVE TO SCREEN 0.

  ELSEIF ok_code = 'FC_CANCLE'.
    CLEAR io_conform_password.
    CLEAR io_new_password.
    CLEAR zg13_applicant-password.
    LEAVE TO SCREEN 0.
  ELSEIF ok_code = 'FC_CHANGE_PASSWORD'.



    IF zg13_applicant-password IS INITIAL
      OR io_new_password IS INITIAL
      OR io_conform_password IS INITIAL .
      MESSAGE 'Please Fill All the Fileds' TYPE 'E'.
    ELSE.
      " Check Old Password
      lcl_syncedin=>check_old_password(
        EXPORTING
          im_password      =  zg13_applicant-password
          im_applicant_id  =  zg13_applicant-applicant_id
        EXCEPTIONS
          invalid_password = 1
          OTHERS           = 2
      ).
      IF sy-subrc <> 0.
*     MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        MESSAGE 'Old PAssword Does Not Match' TYPE 'E'.
      ELSEIF sy-subrc = 0.
        " check password format
        IF strlen( io_new_password ) >= 6 AND strlen( io_new_password ) <= 12  .
          IF io_new_password CA string1 .
            IF io_new_password CA string2.
              IF io_new_password CA string3.
                IF io_new_password CA string4 .
                  IF io_new_password = io_conform_password.


                    " update old password
                    lcl_syncedin=>update_old_password(
                      EXPORTING
                        im_password          = io_new_password
                        im_applicant_id      = zg13_applicant-applicant_id
                      EXCEPTIONS
                        password_not_updated = 1
                        OTHERS               = 2
                    ).
                    IF sy-subrc <> 0.
*       MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
                      MESSAGE 'Password not updated' TYPE 'E'.
                    ELSEIF sy-subrc = 0.
                      MESSAGE 'Password Updated' TYPE 'I'.
                      CLEAR ok_code.
                      CLEAR io_conform_password.
                      CLEAR io_new_password.
                      CLEAR zg13_applicant-password.
                      LEAVE TO SCREEN 0.
                    ENDIF.
                  ELSE .
                    MESSAGE 'Password not Match' TYPE 'E'.
                  ENDIF.

                ELSE.
                  MESSAGE 'Password Must contain at least one Digit' TYPE 'E'.
                ENDIF.
              ELSE.
                MESSAGE 'Password Must contain at least one Special Character' TYPE 'E'.
              ENDIF.

            ELSE.
              MESSAGE 'Password Must contain at least one Capital letter' TYPE 'E'.
            ENDIF.
          ELSE.
            MESSAGE 'Password Must contain at least one Small Letter' TYPE 'E'.

          ENDIF.
        ELSE.
          MESSAGE 'Password Length Must between 6 to 12' TYPE 'E'.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
  CLEAR ok_code.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  PASSWORD_CHECK_0320  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE password_check_0320 INPUT.


ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CONTACT_VALIDATION  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE contact_validation INPUT.
  IF flag_captcha = 0.


    IF zg13_applicant-applicant_id IS NOT INITIAL.

      IF zg13_applicant-contact IS INITIAL.
        SET CURSOR FIELD 'ZG13_APPLICANT-CONTACT'.
        MESSAGE 'PLEASE PROVIDE CONTACT' TYPE 'E'.
      ELSEIF  zg13_applicant-contact  > 9999999999 OR zg13_applicant-contact  < 1000000000 .
        SET CURSOR FIELD 'ZG13_APPLICANT-CONTACT'.
        MESSAGE 'Contact Length Must be 10' TYPE 'E'.
      ELSEIF zg13_applicant-contact CA string1 OR zg13_applicant-contact CA string2
        OR zg13_applicant-contact CA '~!@#$%^&*()_+/*-+'.
        SET CURSOR FIELD 'ZG13_APPLICANT-CONTACT'.
        MESSAGE 'Invalid Contact' TYPE 'E'.
      ENDIF.

    ELSEIF zg13_recruiter-recruiter_id IS NOT INITIAL.

      IF zg13_recruiter-contact IS INITIAL.
        SET CURSOR FIELD 'ZG13_RECRUITER-CONTACT'.
        MESSAGE 'PLEASE PROVIDE CONTACT' TYPE 'E'.
      ELSEIF  zg13_recruiter-contact  > 9999999999 OR zg13_recruiter-contact  < 1000000000 .
        SET CURSOR FIELD 'ZG13_RECRUITER-CONTACT'.
        MESSAGE 'Contact Length Must be 10' TYPE 'E'.
      ELSEIF zg13_recruiter-contact CA string1 OR zg13_recruiter-contact CA string2
        OR zg13_recruiter-contact CA '~!@#$%^&*()_+/*-+'.
        SET CURSOR FIELD 'ZG13_RECRUITER-CONTACT'.
        MESSAGE 'Invalid Contact' TYPE 'E'.
      ENDIF.

    ENDIF.

  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  SKILL_VALIDATION  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE skill_validation INPUT.

  IF flag_captcha = 0.
    IF zg13_applicant-applicant_id IS NOT INITIAL.
      IF zg13_applicant-skill_1 IS INITIAL AND
        zg13_applicant-skill_4 IS INITIAL AND
        zg13_applicant-skill_3 IS INITIAL AND
        zg13_applicant-skill_2 IS INITIAL .
        SET CURSOR FIELD 'ZG13_APPLICANT-SKILL_1'.
        MESSAGE 'Please Enter Your Skill' TYPE 'E'.

      ELSEIF zg13_applicant-skill_1 IS INITIAL .
        SET CURSOR FIELD 'ZG13_APPLICANT-SKILL_1'.
        MESSAGE 'Please Fill the Skill Sequentially' TYPE 'E'.
*     ELSEIF
      ENDIF.
    ENDIF.

  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  VALIDATE_SECURITY_QUESTION  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_security_question INPUT.

  IF flag_captcha = 0.

    IF zg13_applicant-security_que  IS INITIAL.
      SET CURSOR FIELD 'ZG13_APPLICANT-SECURITY_QUE'.
      MESSAGE 'Please enter the security question ' TYPE 'E'.
    ELSEIF  zg13_applicant-security_ans IS INITIAL.
      SET CURSOR FIELD 'ZG13_APPLICANT-SECURITY_ANS'.
      MESSAGE 'Please enter the security answer ' TYPE 'E'.
    ENDIF.

  ENDIF.


ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  LOCATION_VALIDATE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE location_validate INPUT.
  IF flag_captcha = 0.

    IF zg13_recruiter-recruiter_id IS NOT INITIAL.
      IF zg13_recruiter-location IS INITIAL.
        MESSAGE 'Plese fill location' TYPE 'E'.
        SET CURSOR FIELD 'ZG13_RECRUITER-LOCATION'.
      ENDIF.
    ENDIF.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  COMPANY_VALIDATE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE company_validate INPUT.
  IF flag_captcha = 0.

    IF zg13_recruiter-recruiter_id IS NOT INITIAL.
      IF zg13_recruiter-company_name IS INITIAL.
        SET CURSOR FIELD 'ZG13_RECRUITER-COMPANY_NAME'.
        MESSAGE 'Plese fill comapany name' TYPE 'E'.
      ENDIF.
    ENDIF.
  ENDIF.

ENDMODULE.