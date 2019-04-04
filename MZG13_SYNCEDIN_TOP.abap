*&---------------------------------------------------------------------*
*& Include MZG13_SYNCEDIN_TOP                                Module Pool      SAPMZG13_SYNCEDIN
*&
*&---------------------------------------------------------------------*
PROGRAM sapmzg13_syncedin.

*-------------------- image data declaration ----------------------

DATA: w_lines TYPE i.
TYPES pict_line(256) TYPE c.
DATA :
  container TYPE REF TO cl_gui_custom_container, " COANTAAINER REFERENCE VARIABLE
  editor    TYPE REF TO cl_gui_textedit, " EDITOR REFERENCE VARIABLE
  picture   TYPE REF TO cl_gui_picture, " PICTURE REFERENCE VARIABLE
  pict_tab  TYPE TABLE OF pict_line, " PICTT_TABLE
  url(255)  TYPE c. " URL STRING
DATA: graphic_url(255).
" STARTURRE FOR GRAPICS
DATA: BEGIN OF graphic_table OCCURS 0,
        line(255) TYPE x,
      END OF graphic_table.
DATA: l_graphic_conv TYPE i.
DATA: l_graphic_offs TYPE i.
DATA: graphic_size TYPE i.
DATA: l_graphic_xstr TYPE xstring.

*-------------------------------------- object Declaration for  login Screen ----------------------

TABLES : zg13_applicant, zg13_recruiter,zg13_job_details.
DATA fmname TYPE rs38l_fnam. " smart form name
DATA : ok_code TYPE sy-ucomm. " ok_code for map user action

" ALL FLAG DECLARATION
DATA : flag_captcha         TYPE i, " CAPTCHA FLAG
       flag_applicant       TYPE i, " APPLICANT FLAG FOR REGISTRATION
       flag_recruiter       TYPE i, " RECRUITER FLAG FOR REISTRATION
       flag_register        TYPE i, " REGISTER FLAG
       flag_change_password TYPE i, " CHANGE PASSWORD FLAG
       flag_edit_details    TYPE i, " APPLICANT EDIT DETAILS TOGGLE FLAG
       flag_toggle_password TYPE i. " PASSWORD TOGGLE FLAG


*STRUCTURE FOR OK_CODE VALUE
TYPES : BEGIN OF ty_ok_code_table,
          ok_code TYPE sy-ucomm,
        END OF ty_ok_code_table.
" INTERNAL TABLE ANDD WORK AREA FOR OK_CODE VALUE
DATA: it_ok_code_table TYPE TABLE OF ty_ok_code_table,
      wa_ok_code_table LIKE LINE OF it_ok_code_table.

" BASIC REQUIRED VARIABLES

DATA: io_captcha              TYPE string, " STORE CAPTCHA DATA
      io_entered_captcha      TYPE string, " ENTERED CAPTCHA DATA
      io_conform_password(12),  " conform password field
      rb_recruiter , " Recruiter radio button
      rb_applicant, " applicant radio button
      io_password             TYPE zg13_recruiter-password, " password field
      io_questin_file_path    TYPE string , " input filed for file path

      io_new_password         TYPE string. " new Passssword

DATA: it_posted_job_table TYPE TABLE OF zstg13_posted_job_table, " stored applicant posted job
      wa_posted_job_table LIKE LINE OF  it_posted_job_table.
" local structure for job id
TYPES: BEGIN OF ty_seleted_posted_job,

         job_id TYPE zg13_job_details-job_id,
       END OF ty_seleted_posted_job.
DATA : it_selected_posted_job TYPE TABLE OF  ty_seleted_posted_job, " table stores job id
       wa_selected_posted_job LIKE LINE OF it_selected_posted_job.
DATA : it_selected_posted_job_num_id TYPE lvc_t_roid, " seleted row in number count
       wa_selected_posted_job_num_id LIKE LINE OF it_selected_posted_job_num_id.

DATA: it_assessment_table TYPE  zg13_assessment. " assessment work area


 data ans type string." stores answer of button yes or no popup window of exit




*--------------------------------------------------------------------------------------------

"validation strings for password
DATA string1 TYPE string VALUE 'abcdefghtiklmnopqestuvwxyz'.
DATA string2 TYPE string VALUE 'ABCDEFGHTIKLMNOPQESTUVWXYZ'.
DATA string3 TYPE string VALUE '@$#!%'.
DATA string4 TYPE string VALUE '1234567890'.



*----------------------data for screen 300 ---------------------------

DATA : it_tc_job_details1 TYPE TABLE OF zstg13_job_details_mark,
       wa_tc_job_details1 LIKE LINE OF it_tc_job_details1.

*&SPWIZARD: DECLARATION OF TABLECONTROL 'TC_JOB_DETAILS1' ITSELF
CONTROLS: tc_job_details1 TYPE TABLEVIEW USING SCREEN 0300.

*&SPWIZARD: LINES OF TABLECONTROL 'TC_JOB_DETAILS1'
DATA:     g_tc_job_details1_lines  LIKE sy-loopc.


DATA : selected_job_id      TYPE zg13_job_details-job_id,
       noofjobs             TYPE i,
       noofjobs_ch          TYPE string,
       tc_job_details_title TYPE string,
       login_applicant      TYPE zg13_applicant,

       gv_url_string        TYPE string,
       gv_url_c             TYPE char255,
       assessment_id        TYPE zg13_assessment-assessement_id,
       assessment_id_str    TYPE string.



*--------------------------------------- UPLOAD DATA FROM TEXT FILE -------------------------

TYPES  : BEGIN OF ty_take_data,
           skill    TYPE zg13_que_bank-skill,
           question TYPE zg13_que_bank-question,
           option1  TYPE zg13_que_bank-option1,
           option2  TYPE zg13_que_bank-option2,
           option3  TYPE zg13_que_bank-option3,
           option4  TYPE zg13_que_bank-option4,
           answer   TYPE zg13_que_bank-answer,
         END OF ty_take_data.
" INTERNAL TABLE AND WORK AREA FOR GET DATA FROM TEXT FILE
DATA: it_take_data TYPE TABLE OF ty_take_data,
      wa_take_data LIKE LINE OF it_take_data.
" INTERNAL TABLE AND WORK AREA FOR UPDATE DATA IN QUETION BANK TABLE
DATA: it_upload_data TYPE TABLE OF zg13_que_bank,
      wa_upload_data LIKE LINE OF it_upload_data.
" LOCAL VARIABLES FOR CALCULATE MAX ID
DATA : split_id TYPE string.
DATA : part1 TYPE string.

*------------------------------------------------------------------ class DECLARATION.



CLASS lcl_syncedin DEFINITION.

  PUBLIC SECTION.

    CLASS-METHODS:

      "finds jobs matching by skills of the aplicant
      "changes the internal table passed adds the job details
      find_matching_jobs
        IMPORTING applicant TYPE zg13_applicant
        EXPORTING noofjobs  TYPE i
        CHANGING  itable    TYPE zttg13_job_details_mark,

      "returns the job id of the field that is selected by the aplicant
      "in the table control on applicant home screen.
      return_selectd_job
        IMPORTING  itable TYPE zttg13_job_details_mark
        EXPORTING  jobid  TYPE zg13_job_details-job_id
        EXCEPTIONS nolineselected,


      "check whether applicant has applied to the job or not .
      "returns assessment id.

      get_assessment_id
        IMPORTING im_applicant_id  TYPE zg13_applicant-applicant_id
                  im_job_id        TYPE zg13_job_details-job_id
        EXPORTING ex_assessment_id TYPE zg13_assessment-assessement_id,


      " validate applicant
      validate_applicant
        IMPORTING  im_applicant_id TYPE zg13_applicant-applicant_id
                   im_password     TYPE zg13_applicant-password
        EXCEPTIONS invalid_applicant,


      " validate recruiter
      validate_recruiter
        IMPORTING  im_recruiter_id TYPE zg13_recruiter-recruiter_id
                   im_password     TYPE zg13_recruiter-password
        EXCEPTIONS invalid_recruiter,

      " RECRUTER REGISTER
      register_recruiter
        IMPORTING  im_register TYPE zg13_recruiter
        EXCEPTIONS registration_failed alredy_present,

      " APPLICANT REGISTER
      register_applicant
        IMPORTING  im_applicant TYPE zg13_applicant
        EXCEPTIONS registration_failed ,

      " FIND APPLICANT MAX ID
      applicant_max_id
        EXPORTING ex_appicant_id TYPE zg13_applicant-applicant_id,


      recruiter_max_id
        EXPORTING ex_recruiter_id TYPE zg13_recruiter-recruiter_id,
      " FORGOT PASSWORD
      forgot_password
        IMPORTING  im_id           TYPE zg13_applicant-applicant_id
                   im_security_que TYPE zg13_applicant-security_que
                   im_security_ans TYPE zg13_applicant-security_ans
                   im_password     TYPE zg13_applicant-password
        EXCEPTIONS password_not_updated,


      "exports the applicant from applicant_id
      get_applicant
        IMPORTING  im_id        TYPE zg13_applicant-applicant_id
        EXPORTING  ex_applicant TYPE zg13_applicant
        EXCEPTIONS applicantnotfound,

      " GET POSTED JOBS
      get_posted_job
        IMPORTING im_id TYPE zg13_applicant-applicant_id,

      " GET MAX JOB ID
      auto_generate_job_id
        EXPORTING ex_job_id TYPE zg13_job_details-job_id,

      " get company name
      get_comapany_name
        IMPORTING im_id            TYPE zg13_recruiter-recruiter_id
        EXPORTING ex_comapany_name TYPE zg13_recruiter-company_name,

      " GET QUESTION COUNT FOR JOB
      question_count_for_job
        IMPORTING im_table TYPE zg13_job_details
        EXPORTING ex_count TYPE snoque,

      " UPDATE APPLICANT DATA
      update_applicant_data
        IMPORTING  im_applicant TYPE  zg13_applicant
        EXCEPTIONS data_not_updated,

      " DELETE APPLICANT DATA
      delete_applicant_data
        IMPORTING  im_applicant TYPE  zg13_applicant
        EXCEPTIONS data_not_deleted,

      " CHECK OLD PASSWORD
      check_old_password
        IMPORTING  im_password     TYPE zg13_applicant-password
                   im_applicant_id TYPE zg13_applicant-applicant_id
        EXCEPTIONS invalid_password,

      " UPDATE OLD PASSWORD
      update_old_password
        IMPORTING  im_password     TYPE string
                   im_applicant_id TYPE zg13_applicant-applicant_id
        EXCEPTIONS password_not_updated,


      "apply job
      apply_job
        IMPORTING  im_applicant_id TYPE zg13_applicant-applicant_id
                   im_job_id       TYPE zg13_job_details-job_id
        EXCEPTIONS already_appied data_not_inserted,

      " GETAND UPDATE QUETION COUNT
      get_update_count
        IMPORTING  im_option    TYPE c
                   im_job_table TYPE zttg13_job_details OPTIONAL
        EXPORTING  ex_job_table TYPE zttg13_job_details
                   ex_que_table TYPE zttg13_que_bank
        EXCEPTIONS fecting_failed not_updated,

      " get assessment count
      get_assessment_count
        IMPORTING im_id    TYPE zg13_applicant-applicant_id
        EXPORTING ex_count TYPE i.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

*----------------------- posted job table ---------------------------------

DATA :wa_layout TYPE lvc_s_layo,
      gt_fcat   TYPE lvc_t_fcat, " FIELD CATLOG ITNTRER TABLE
      gw_fcat   TYPE lvc_s_fcat. " WORK AREA

DATA: g_custom_container TYPE REF TO cl_gui_custom_container, " CUSTOM CINTAINER
      g_alv_grid_ref     TYPE REF TO cl_gui_alv_grid. " GRID REFERENCE

*&SPWIZARD: FUNCTION CODES FOR TABSTRIP 'TB_POSTED_JOB'
CONSTANTS: BEGIN OF c_tb_posted_job,
             tab1 LIKE sy-ucomm VALUE 'TB_POSTED_JOB_FC1',
             tab2 LIKE sy-ucomm VALUE 'TB_POSTED_JOB_FC2',
           END OF c_tb_posted_job.
*&SPWIZARD: DATA FOR TABSTRIP 'TB_POSTED_JOB'
CONTROLS:  tb_posted_job TYPE TABSTRIP.
DATA: BEGIN OF g_tb_posted_job,
        subscreen   LIKE sy-dynnr,
        prog        LIKE sy-repid VALUE 'SAPMZG13_SYNCEDIN',
        pressed_tab LIKE sy-ucomm VALUE c_tb_posted_job-tab1,
      END OF g_tb_posted_job.