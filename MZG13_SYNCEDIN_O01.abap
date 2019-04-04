*&---------------------------------------------------------------------*
*&  Include           MZG13_SYNCEDIN_O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  DISPLAY_LOGO  OUTPUT
*&---------------------------------------------------------------------*

MODULE display_logo OUTPUT.

  "----> Clearing the Input fields
  CLEAR zg13_applicant-applicant_id.
  CLEAR io_password.

  "----> Method call to clear the Container
  CALL METHOD cl_gui_cfw=>flush.

  CREATE OBJECT:
  container EXPORTING container_name = 'PICTURE_CONTAINER',
  picture EXPORTING parent = container.

  "----> Calling the method to get the LOGO_Image
  CALL METHOD cl_ssf_xsf_utilities=>get_bds_graphic_as_bmp
    EXPORTING
      p_object  = 'GRAPHICS'           "--> Type of the object
      p_name    = 'G13_SYNCEDIN_LOGO'  "--> Name of the image
      p_id      = 'BMAP'               "--> Graphic Management ID
      p_btype   = 'BCOL'               "--> Type of Graphic
    RECEIVING
      p_bmp     = l_graphic_xstr
    EXCEPTIONS
      not_found = 1
*     INTERNAL_ERROR = 2
*     others    = 3
    .

  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    MESSAGE 'Image not found!' TYPE 'I'.
  ENDIF.

  "Setting the size of the image
  graphic_size = xstrlen( l_graphic_xstr ).
  l_graphic_conv = graphic_size.
  l_graphic_offs = 0.

  WHILE l_graphic_conv > 255.
    graphic_table-line = l_graphic_xstr+l_graphic_offs(255).
    APPEND graphic_table.
    l_graphic_offs = l_graphic_offs + 255.
    l_graphic_conv = l_graphic_conv - 255.
  ENDWHILE.

  graphic_table-line = l_graphic_xstr+l_graphic_offs(l_graphic_conv).
  APPEND graphic_table.

  "--> Generates a temporary URL that displays in a temporary table.
  CALL FUNCTION 'DP_CREATE_URL'
    EXPORTING
      type     = 'IMAGE'
      subtype  = 'X-UNKNOWN'
      size     = graphic_size
      lifetime = 'T'
    TABLES
      data     = graphic_table
    CHANGING
      url      = url.

  "--> Loading picture from URL
  CALL METHOD picture->load_picture_from_url
    EXPORTING
      url = url.

  "--> Setting the position of picture
  CALL METHOD picture->set_display_mode
    EXPORTING
      display_mode = picture->display_mode_fit_center.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*

MODULE status_0100 OUTPUT.
  SET PF-STATUS 'GUISTATUS_0100'. "--> Setting the GUI functionalities to the screen
  SET TITLEBAR 'TITLE_0100'.      "--> Setting the Title
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  AUTO_DISPLAY_DATA_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE auto_display_data_0200 OUTPUT.

  IF flag_captcha = 0.


    CALL FUNCTION 'GENERAL_GET_RANDOM_STRING'
      EXPORTING
        number_chars  = 6
      IMPORTING
        random_string = io_captcha.
*    flag_captcha = 1.

  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_0110  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0110 OUTPUT.
  SET PF-STATUS 'GUI_STATUS_0110'.  "--> Setting the GUI functionalities to the screen

*  SET TITLEBAR 'xxx'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHANGE_SCREEN_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE change_screen_0200 OUTPUT.
  IF flag_recruiter = 1.


    LOOP AT SCREEN.
      IF screen-group1 = 'G1'.
        screen-active = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
    lcl_syncedin=>recruiter_max_id(
      IMPORTING
        ex_recruiter_id = zg13_recruiter-recruiter_id
    ).

  ELSEIF flag_applicant = 1.
    LOOP AT SCREEN.
      IF screen-group1 = 'G2'.
        screen-active = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
    lcl_syncedin=>applicant_max_id(
      IMPORTING
        ex_appicant_id =  zg13_applicant-applicant_id
    ).
  ENDIF.
  IF flag_register = 1.
    IF flag_recruiter = 1.
      LOOP AT SCREEN.
        IF screen-group1 = 'G2'.
          screen-input = 0.
        ENDIF.
        IF screen-name = 'ZG13_RECRUITER-PASSWORD' OR screen-name = 'ZG13_applicant-PASSWORD'
          OR screen-name = 'IO_CONFORM_PASSWORD'.
*          screen-invisible = 0.
          screen-input = 0.
        ENDIF.
        IF  screen-name = 'IO_SECURITY_QUESTION'
          OR  screen-name = 'ZG13_APPLICANT-SECURITY_QUE' OR  screen-name = 'ZG13_APPLICANT-SECURITY_ANS'
          OR screen-name = 'IO_ENTERED_CAPTCHA'.
          screen-input = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
    ELSEIF flag_applicant = 1.
      LOOP AT SCREEN.
        IF screen-group1 = 'G1'.
          screen-input = 0.
        ENDIF.
        IF screen-name = 'ZG13_RECRUITER-PASSWORD' OR screen-name = 'ZG13_applicant-PASSWORD'
         OR screen-name = 'IO_CONFORM_PASSWORD'.
*          screen-invisible = 0.
          screen-input = 0.
        ENDIF.
        IF  screen-name = 'IO_SECURITY_QUESTION'
        OR  screen-name = 'ZG13_APPLICANT-SECURITY_QUE' OR  screen-name = 'ZG13_APPLICANT-SECURITY_ANS'
          OR screen-name = 'IO_ENTERED_CAPTCHA'.
          screen-input = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDMODULE.

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_JOB_DETAILS1'. DO NOT CHANGE THIS L
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE tc_job_details1_change_tc_attr OUTPUT.
  DESCRIBE TABLE it_tc_job_details1 LINES tc_job_details1-lines.
ENDMODULE.

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_JOB_DETAILS1'. DO NOT CHANGE THIS L
*&SPWIZARD: GET LINES OF TABLECONTROL
MODULE tc_job_details1_get_lines OUTPUT.
  g_tc_job_details1_lines = sy-loopc.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  CHANGE_SCREEN_0400  OUTPUT
*&---------------------------------------------------------------------*

MODULE change_screen_0400 OUTPUT.
CLEAR zg13_applicant.
CLEAR zg13_recruiter.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*

MODULE status_0200 OUTPUT.
  SET PF-STATUS 'GUI_0200'.
  SET TITLEBAR 'TITLE_0200'.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  EXIT_MODULE_0100  INPUT
*&---------------------------------------------------------------------*

MODULE exit_module_0100 INPUT.
  IF ok_code = 'FC_EXIT'.
*    LEAVE PROGRAM.        "----> Exits the application

    CALL FUNCTION 'POPUP_WITH_2_BUTTONS_TO_CHOOSE'
      EXPORTING
*       DEFAULTOPTION       = '1'
        diagnosetext1       = 'Do you want to exit?'
*       DIAGNOSETEXT2       = ' '
*       DIAGNOSETEXT3       = ' '
        textline1           = 'Yes or No'
*       TEXTLINE2           = ' '
*       TEXTLINE3           = ' '
        text_option1        = 'Yes'
        text_option2        = 'No'
        titel               = 'Exit'
     IMPORTING
       ANSWER              = ans
              .

    CASE ans.
      WHEN '1'. " when yes leave program
        leave program.
      WHEN '2'." when no back to program
      WHEN OTHERS.
    ENDCASE.


  ELSEIF ok_code = 'FC_CANCEL'.
    flag_applicant = 0.
    flag_register = 0.
    flag_captcha = 0.
    flag_change_password = 0.
    flag_recruiter = 0.
    CLEAR : zg13_applicant, zg13_recruiter.   "----> Clears all screen fields
*    LEAVE TO SCREEN 100.  "----> Calls same screen again
    LEAVE TO SCREEN sy-dynnr.   "----> Calls same screen again
  ENDIF.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  FETCH_DATA_0510  OUTPUT
*&---------------------------------------------------------------------*

MODULE fetch_data_0510 OUTPUT.
  "Method call to get the POSTED JOBS based on the RECRUITER
  lcl_syncedin=>get_posted_job( im_id = zg13_applicant-applicant_id ).

*  SELECT *  FROM zg13_job_details INTO CORRESPONDING FIELDS OF TABLE it_posted_job_table
*   WHERE recruiter_id = 'R1002'.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  FIELD_CAT_0510  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE field_cat_0510 OUTPUT.
  gw_fcat-col_pos = 1.
  gw_fcat-fieldname = 'JOB_ID'.
  gw_fcat-tabname =  'IT_POSTED_JOB_TABLE'.
*  gw_fcat-col_opt = 'X'.
  gw_fcat-outputlen = 15.
  gw_fcat-scrtext_l = 'Job Id'.
  gw_fcat-scrtext_m = 'Job Id'.
  gw_fcat-scrtext_s = 'Job Id'.
  APPEND gw_fcat TO gt_fcat.
  CLEAR gw_fcat.

  gw_fcat-col_pos = 2.
  gw_fcat-fieldname = 'DESCRIPTION'.
  gw_fcat-tabname =  'IT_POSTED_JOB_TABLE'.
*  gw_fcat-col_opt = 'X'.
  gw_fcat-outputlen = 30.
  gw_fcat-scrtext_l = 'DESCRIPTION'.
  gw_fcat-scrtext_m = 'DESCRIPTION'.
  gw_fcat-scrtext_s = 'Descr'.
  APPEND gw_fcat TO gt_fcat.
  CLEAR gw_fcat.


  gw_fcat-col_pos = 3.
  gw_fcat-fieldname = 'SKILL_1'.
  gw_fcat-tabname =  'IT_POSTED_JOB_TABLE'.
*  gw_fcat-col_opt = 'X'.
  gw_fcat-outputlen = 20.
  gw_fcat-scrtext_l = 'Skill 1'.
  gw_fcat-scrtext_m = 'Skill 1'.
  gw_fcat-scrtext_s = 'Skill 1'.
  APPEND gw_fcat TO gt_fcat.
  CLEAR gw_fcat.

  gw_fcat-col_pos = 4.
  gw_fcat-fieldname = 'SKILL_2'.
  gw_fcat-tabname =  'IT_POSTED_JOB_TABLE'.
*  gw_fcat-col_opt = 'X'.
  gw_fcat-outputlen = 20.
  gw_fcat-scrtext_l = 'Skill 2(Optional)'.
  gw_fcat-scrtext_m = 'Skill 2(Optional)'.
  gw_fcat-scrtext_s = 'Skill 2(Optional)'.
  APPEND gw_fcat TO gt_fcat.
  CLEAR gw_fcat.


  gw_fcat-col_pos = 5.
  gw_fcat-fieldname = 'SKILL_3'.
  gw_fcat-tabname =  'IT_POSTED_JOB_TABLE'.
*  gw_fcat-col_opt = 'X'.
  gw_fcat-outputlen = 20.
  gw_fcat-scrtext_l = 'Skill 3(Optional)'.
  gw_fcat-scrtext_m = 'Skill 3(Optional)'.
  gw_fcat-scrtext_s = 'Skill 3(Optional)'.
  APPEND gw_fcat TO gt_fcat.
  CLEAR gw_fcat.


  gw_fcat-col_pos = 6.
  gw_fcat-fieldname = 'SKILL_4'.
  gw_fcat-tabname =  'IT_POSTED_JOB_TABLE'.
*  gw_fcat-col_opt = 'X'.
  gw_fcat-outputlen = 20.
  gw_fcat-scrtext_l = 'Skill 4(Optional)'.
  gw_fcat-scrtext_m = 'Skill 4(Optional)'.
  gw_fcat-scrtext_s = 'Skill 4(Optional)'.
  APPEND gw_fcat TO gt_fcat.
  CLEAR gw_fcat.



  gw_fcat-col_pos = 7.
  gw_fcat-fieldname = 'MIN_SAL'.
  gw_fcat-tabname =  'IT_POSTED_JOB_TABLE'.
*  gw_fcat-col_opt = 'X'.
  gw_fcat-outputlen = 20.
  gw_fcat-scrtext_l = 'Minimum Salary'.
  gw_fcat-scrtext_m = 'Min Sal'.
  gw_fcat-scrtext_s = 'Min Sal'.
  APPEND gw_fcat TO gt_fcat.
  CLEAR gw_fcat.


  gw_fcat-col_pos = 8.
  gw_fcat-fieldname = 'MAX_SAL'.
  gw_fcat-tabname =  'IT_POSTED_JOB_TABLE'.
  gw_fcat-col_opt = 'X'.
  gw_fcat-outputlen = 20.
  gw_fcat-scrtext_l = 'Maximum Salary'.
  gw_fcat-scrtext_m = 'Max Sal'.
  gw_fcat-scrtext_s = 'Max Sal'.
  APPEND gw_fcat TO gt_fcat.
  CLEAR gw_fcat.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CALL_GRID_0510  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE call_grid_0510 OUTPUT.
  IF g_custom_container IS INITIAL.
    "create custom container
    CREATE OBJECT g_custom_container
      EXPORTING
        container_name = 'CUSTOM_AREA'.

    " create alv grid ref object
    CREATE OBJECT g_alv_grid_ref
      EXPORTING
        i_parent = g_custom_container.
*  call method set_table_for_first_display
    CALL METHOD g_alv_grid_ref->set_table_for_first_display
      EXPORTING
*       i_buffer_active =     " Buffering Active
*       i_bypassing_buffer            =     " Switch Off Buffer
*       i_consistency_check           =     " Starting Consistency Check for Interface Error Recognition
*       i_structure_name              =  'ZSTG13_POSTED_JOB_TABLE'   " Internal Output Table Structure Name
*       is_variant      =     " Layout
*       i_save          =     " Save Layout
*       i_default       = 'X'    " Default Display Variant
        is_layout       = wa_layout   " Layout
*       is_print        =     " Print Control
*       it_special_groups             =     " Field Groups
*       it_toolbar_excluding          =     " Excluded Toolbar Standard Functions
*       it_hyperlink    =     " Hyperlinks
*       it_alv_graphics =     " Table of Structure DTC_S_TC
*       it_except_qinfo =     " Table for Exception Quickinfo
*       ir_salv_adapter =     " Interface ALV Adapter
      CHANGING
        it_outtab       = it_posted_job_table  " Output Table
        it_fieldcatalog = gt_fcat   " Field Catalog
*       it_sort         =     " Sort Criteria
*       it_filter       =     " Filter Criteria
*        EXCEPTIONS
*       invalid_parameter_combination = 1
*       program_error   = 2
*       too_many_lines  = 3
*       others          = 4
      .
    IF sy-subrc <> 0.
*       MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ELSE.
    CALL METHOD g_alv_grid_ref->refresh_table_display.
  ENDIF.


ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  ALV_LAYOUT_0510  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE alv_layout_0510 OUTPUT.

*  wa_layout-col_opt = 'X'.
  wa_layout-zebra = 'X'.
  wa_layout-sel_mode = 'A'. " MULTIPLE SELECTION

ENDMODULE.

*&SPWIZARD: OUTPUT MODULE FOR TS 'TB_POSTED_JOB'. DO NOT CHANGE THIS LIN
*&SPWIZARD: SETS ACTIVE TAB
MODULE tb_posted_job_active_tab_set OUTPUT.
  tb_posted_job-activetab = g_tb_posted_job-pressed_tab.
  CASE g_tb_posted_job-pressed_tab.
    WHEN c_tb_posted_job-tab1.
      g_tb_posted_job-subscreen = '0510'.
    WHEN c_tb_posted_job-tab2.
      g_tb_posted_job-subscreen = '0520'.
    WHEN OTHERS.
*&SPWIZARD:      DO NOTHING
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHANGE_SCREEN_0520  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE change_screen_0520 OUTPUT.
  lcl_syncedin=>auto_generate_job_id(
    IMPORTING
      ex_job_id =  zg13_job_details-job_id
  ).

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_0500  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0500 OUTPUT.
  DATA: company_name TYPE zg13_recruiter-company_name.
  SET PF-STATUS 'GUI_0500'.
  lcl_syncedin=>get_comapany_name(
    EXPORTING
      im_id            = zg13_applicant-applicant_id
    IMPORTING
      ex_comapany_name = company_name
  ).
  SET TITLEBAR 'TITLE_0500'WITH company_name.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_0400  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0400 OUTPUT.
  SET PF-STATUS 'GUI_0400'.
  SET TITLEBAR 'TITLE_0400'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  GET_DATA_0310  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_data_0310 OUTPUT.

  lcl_syncedin=>get_applicant(
EXPORTING
  im_id             = zg13_applicant-applicant_id
IMPORTING
  ex_applicant      = zg13_applicant
EXCEPTIONS
  applicantnotfound = 1
  OTHERS            = 2
).
  IF sy-subrc <> 0.
    MESSAGE 'Applicant not found ( on click of view profile)' TYPE 'E'.
*   MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHANGE_SCREEN_0310  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE change_screen_0310 OUTPUT.

  IF flag_edit_details = 1.
    LOOP AT SCREEN.
      IF screen-group1 = 'G1'.
        screen-input = 1.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.

  ELSEIF flag_edit_details = 0.
    LOOP AT SCREEN.
      IF screen-group1 = 'G1'.
        screen-input = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  GET_DATA_0300  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_data_0300 OUTPUT.

  lcl_syncedin=>get_applicant(
    EXPORTING
      im_id        = zg13_applicant-applicant_id
    IMPORTING
      ex_applicant = login_applicant
  ).


  lcl_syncedin=>find_matching_jobs(
    EXPORTING
      applicant = login_applicant
    IMPORTING
      noofjobs  = noofjobs
    CHANGING
      itable    = it_tc_job_details1
  ).

  "converting int into string
  noofjobs_ch = noofjobs.
  CONCATENATE ' '  noofjobs_ch INTO noofjobs_ch.

  CONCATENATE 'We have found' noofjobs_ch INTO tc_job_details_title SEPARATED BY ' '.
  CONCATENATE tc_job_details_title 'jobs that match your skills' INTO tc_job_details_title SEPARATED BY ' '.


ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_0320  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0320 OUTPUT.
  SET PF-STATUS 'GUI_0320'.
  SET TITLEBAR 'TITLE_0320'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHANGE_SCREEN_0320  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE change_screen_0320 OUTPUT.

  IF flag_toggle_password = 1.
    LOOP AT SCREEN.
      IF screen-group1 = 'G1'.
        screen-invisible = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ELSEIF  flag_toggle_password = 0.
    LOOP AT SCREEN.
      IF screen-group1 = 'G1'.
        screen-invisible = 1.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0300 OUTPUT.
  SET PF-STATUS 'GUI_0300'.
  SET TITLEBAR 'TITLE_0300' WITH login_applicant-name.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_0310  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0310 OUTPUT.
  IF flag_edit_details = 1.
    SET PF-STATUS 'GUI_0310'.   "Sets the screen toolbars

  ELSEIF flag_edit_details = 0.
    wa_ok_code_table-ok_code = 'FC_SAVE'.
    APPEND wa_ok_code_table TO it_ok_code_table.
    CLEAR wa_ok_code_table.
    wa_ok_code_table-ok_code = 'FC_DETAIL'.
    APPEND wa_ok_code_table TO it_ok_code_table.
    CLEAR wa_ok_code_table.
    SET PF-STATUS 'GUI_0310' EXCLUDING it_ok_code_table.

  ENDIF.

  SET TITLEBAR 'TITLE_0310' WITH zg13_applicant-name.
ENDMODULE.