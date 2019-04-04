METHOD handlein_main_view .


  "message manager global data
  "get message manager
  DATA lo_api_controller     TYPE REF TO if_wd_controller.
  DATA lo_message_manager    TYPE REF TO if_wd_message_manager.


  "read assessment id
  DATA lo_nd_global_data3 TYPE REF TO if_wd_context_node.
  DATA lo_el_global_data3 TYPE REF TO if_wd_context_element.
  DATA ls_global_data3 TYPE wd_this->element_global_data3.
  DATA lv_assessment_id TYPE wd_this->element_global_data3-assessment_id.

* navigate from <CONTEXT> to <GLOBAL_DATA3> via lead selection
  lo_nd_global_data3 = wd_context->get_child_node( name = wd_this->wdctx_global_data3 ).

* get element via lead selection
  lo_el_global_data3 = lo_nd_global_data3->get_element( ).
* @TODO handle not set lead selection
  IF lo_el_global_data3 IS INITIAL.
  ENDIF.

* get single attribute
  lo_el_global_data3->get_attribute(
    EXPORTING
      name =  `ASSESSMENT_ID`
    IMPORTING
      value = lv_assessment_id ).

  "popuate the global node questions for use in views

  DATA lo_nd_questions TYPE REF TO if_wd_context_node.

  DATA lt_questions TYPE wd_this->elements_questions.

* navigate from <CONTEXT> to <QUESTIONS> via lead selection
  lo_nd_questions = wd_context->get_child_node( name = wd_this->wdctx_questions ).

* @TODO handle non existant child
* IF lo_nd_questions IS INITIAL.
* ENDIF.

  zcl_g13_wdc_supplyfunctions=>select_questions(
    EXPORTING
      im_assessment_id        =   lv_assessment_id    " ASU - General ID f.g. sequence number
    CHANGING
      ch_que_bank             =  lt_questions   " Table type que_bank
    EXCEPTIONS
      datanotfound            = 1
      incorrect_noofquestions = 2
      OTHERS                  = 3
  ).

  DATA: errmsg          TYPE string,
        no_of_questions TYPE i.

  IF sy-subrc <> 0.
    IF sy-subrc = 1.
      errmsg = 'Question data not found'.
    ELSEIF sy-subrc = 2.
      errmsg = 'No of questions do not match'.
    ELSE.
      errmsg = 'Internal error'.
    ENDIF.


    lo_api_controller ?= wd_this->wd_get_api( ).

    CALL METHOD lo_api_controller->get_message_manager
      RECEIVING
        message_manager = lo_message_manager.

*     report message
    CALL METHOD lo_message_manager->report_error_message
      EXPORTING
        message_text = errmsg.

  ENDIF.

  DESCRIBE TABLE lt_questions LINES no_of_questions.



** @TODO compute values
** e.g. call a model function
*
  lo_nd_questions->bind_table( new_items = lt_questions set_initial_elements = abap_true ).





  ""initialize selected answers all to '0000'.


  DATA lo_nd_selected_answers TYPE REF TO if_wd_context_node.

  DATA lt_selected_answers TYPE wd_this->elements_selected_answers.

*  navigate from <CONTEXT> to <SELECTED_ANSWERS> via lead selection
  lo_nd_selected_answers = wd_context->get_child_node( name = wd_this->wdctx_selected_answers ).

  zcl_g13_wdc_supplyfunctions=>init_selected_answers(
    EXPORTING
      im_no_of_que        = no_of_questions
    IMPORTING
      ex_selected_answers =  lt_selected_answers
  ).

*
  lo_nd_selected_answers->bind_table( new_items = lt_selected_answers set_initial_elements = abap_true ).





  "init of current question no

  DATA lo_nd_currentq TYPE REF TO if_wd_context_node.

  DATA lo_el_currentq TYPE REF TO if_wd_context_element.
  DATA ls_currentq TYPE wd_this->element_currentq.
  DATA lv_current_question_no TYPE wd_this->element_currentq-current_question_no.

*   navigate from <CONTEXT> to <CURRENTQ> via lead selection
  lo_nd_currentq = wd_context->get_child_node( name = wd_this->wdctx_currentq ).

*   @TODO handle non existant child
*   IF lo_nd_currentq IS INITIAL.
*   ENDIF.

*   get element via lead selection
  lo_el_currentq = lo_nd_currentq->get_element( ).

*   @TODO handle not set lead selection
  IF lo_el_currentq IS INITIAL.
  ENDIF.

*   @TODO fill attribute
  lv_current_question_no = 1.

*   set single attribute
  lo_el_currentq->set_attribute(
    name =  `CURRENT_QUESTION_NO`
    value = lv_current_question_no ).




  ""set no of questions

  DATA lo_nd_global_data2 TYPE REF TO if_wd_context_node.

  DATA lo_el_global_data2 TYPE REF TO if_wd_context_element.
  DATA ls_global_data2 TYPE wd_this->element_global_data2.
  DATA lv_no_of_questions TYPE wd_this->element_global_data2-no_of_questions.

* navigate from <CONTEXT> to <GLOBAL_DATA2> via lead selection
  lo_nd_global_data2 = wd_context->get_child_node( name = wd_this->wdctx_global_data2 ).

* @TODO handle non existant child
* IF lo_nd_global_data2 IS INITIAL.
* ENDIF.

* get element via lead selection
  lo_el_global_data2 = lo_nd_global_data2->get_element( ).

* @TODO handle not set lead selection
  IF lo_el_global_data2 IS INITIAL.
  ENDIF.

* @TODO fill attribute
  lv_no_of_questions = no_of_questions.

* set single attribute
  lo_el_global_data2->set_attribute(
    name =  `NO_OF_QUESTIONS`
    value = lv_no_of_questions ).


  "set time left.

  DATA lo_nd_global_data4 TYPE REF TO if_wd_context_node.

  DATA lo_el_global_data4 TYPE REF TO if_wd_context_element.
  DATA ls_global_data4 TYPE wd_this->element_global_data4.
  DATA lv_time_left TYPE wd_this->element_global_data4-time_left.
  DATA: nmins     TYPE n LENGTH 2,
        nhrs      TYPE n LENGTH 2,
        time_left TYPE string.

* navigate from <CONTEXT> to <GLOBAL_DATA4> via lead selection
  lo_nd_global_data4 = wd_context->get_child_node( name = wd_this->wdctx_global_data4 ).

* get element via lead selection
  lo_el_global_data4 = lo_nd_global_data4->get_element( ).

* @TODO handle not set lead selection
  IF lo_el_global_data4 IS INITIAL.
  ENDIF.

  nmins = lv_no_of_questions * 2.
  nhrs = nmins DIV 60.
  nmins = nmins MOD 60.

  CONCATENATE nhrs nmins '00' INTO time_left.


  lv_time_left = time_left.
* set single attribute
  lo_el_global_data4->set_attribute(
    name =  `TIME_LEFT`
    value = lv_time_left ).



  "set company name

  DATA lo_el_context TYPE REF TO if_wd_context_element.
  DATA ls_context TYPE wd_this->element_context.
  DATA lv_company_name TYPE wd_this->element_context-company_name.
* get element via lead selection
  lo_el_context = wd_context->get_element( ).
* @TODO handle not set lead selection
  IF lo_el_context IS INITIAL.
  ENDIF.

  zcl_g13_wdc_supplyfunctions=>get_company_name(
    EXPORTING
      im_assessment_id =  lv_assessment_id    " ASU - General ID f.g. sequence number
    IMPORTING
      ex_company_name  =    lv_company_name " Company name
    EXCEPTIONS
      datanotfound     = 1
      OTHERS           = 2
  ).
  IF sy-subrc <> 0.
    lv_company_name = 'ABC Corp'.

  ENDIF.


* set single attribute
  lo_el_context->set_attribute(
    name =  `COMPANY_NAME`
    value = lv_company_name ).



ENDMETHOD.