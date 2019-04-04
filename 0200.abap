PROCESS BEFORE OUTPUT.
  "--> Module to provide GUI functionalities to the screen
  MODULE status_0200.
*
  MODULE auto_display_data_0200." AUTO DISPLAY APPLIANT ID AND CAPTCHA
  MODULE change_screen_0200. " change screen active elements

PROCESS AFTER INPUT.


  " contact_validation
  CHAIN.
    "LOCATION VALIDATION
    FIELD : zg13_recruiter-location MODULE location_validate.
    FIELD zg13_applicant-name.
*    FIELD zg13_recruiter-location.
*    FIELD zg13_recruiter-company_name.

    "--> Contact  VALIDATION
    FIELD: zg13_applicant-contact,
           zg13_recruiter-contact MODULE contact_validation.


    "--> COMAPANY Name VALIDATE
    FIELD : zg13_recruiter-company_name MODULE company_validate.

    "--> Skill VALIDATION
    FIELD : zg13_applicant-skill_1,
     zg13_applicant-skill_2,
     zg13_applicant-skill_3,
     zg13_applicant-skill_4 MODULE skill_validation.

    "--> Password format validation
    FIELD : zg13_applicant-password , zg13_recruiter-password ,
          io_conform_password MODULE check_password_format .


    "--> Matching the Password fields
    FIELD : zg13_applicant-password , zg13_recruiter-password ,
          io_conform_password MODULE check_password .

    " check email format
    FIELD :  zg13_applicant-email_id , zg13_recruiter-email_id
              MODULE validate_email .


    "--> Security question validation
    FIELD:   zg13_applicant-security_que,
       zg13_applicant-security_ans MODULE validate_security_question.

    "--> User action module
    FIELD : io_entered_captcha MODULE user_command_0200.

  ENDCHAIN.

  CHAIN.
    "--> New user registration
    FIELD :  zg13_applicant-password , zg13_recruiter-password ,
              io_conform_password,zg13_applicant-email_id ,
              zg13_recruiter-email_id,
              zg13_applicant-security_que,
              zg13_applicant-security_ans,zg13_applicant-applicant_id ,
              zg13_recruiter-recruiter_id,
              zg13_applicant-skill_1 , zg13_applicant-skill_2 ,
              zg13_applicant-skill_3,
              zg13_applicant-skill_4,
              zg13_recruiter-company_name,
              zg13_recruiter-location ,
              zg13_recruiter-contact,
              zg13_applicant-contact,
              io_entered_captcha MODULE register_data.

  ENDCHAIN.

  "---> Module to provide screen exit functionalities
  MODULE exit_module_0200 AT EXIT-COMMAND.