METHOD handleto_view .

  "global data declaration
  "get message manager
  DATA lo_api_controller     TYPE REF TO if_wd_controller.
  DATA lo_message_manager    TYPE REF TO if_wd_message_manager.


  "Read current question no.
  DATA lo_nd_currentq TYPE REF TO if_wd_context_node.

  DATA lo_el_currentq TYPE REF TO if_wd_context_element.
  DATA ls_currentq TYPE wd_this->element_currentq.
  DATA lv_current_question_no TYPE wd_this->element_currentq-current_question_no.

* navigate from <CONTEXT> to <CURRENTQ> via lead selection
  lo_nd_currentq = wd_context->get_child_node( name = wd_this->wdctx_currentq ).

* get element via lead selection
  lo_el_currentq = lo_nd_currentq->get_element( ).
* @TODO handle not set lead selection
  IF lo_el_currentq IS INITIAL.
  ENDIF.

* get single attribute
  lo_el_currentq->get_attribute(
    EXPORTING
      name =  `CURRENT_QUESTION_NO`
    IMPORTING
      value = lv_current_question_no ).



  "read questions node

  DATA lo_nd_questions TYPE REF TO if_wd_context_node.

  DATA lt_questions TYPE wd_this->elements_questions.

* navigate from <CONTEXT> to <QUESTIONS> via lead selection
  lo_nd_questions = wd_context->get_child_node( name = wd_this->wdctx_questions ).

* @TODO handle non existant child
* IF lo_nd_questions IS INITIAL.
* ENDIF.

  lo_nd_questions->get_static_attributes_table( IMPORTING table = lt_questions ).




  " reads the question no into the work area

  DATA wa_questions LIKE LINE OF lt_questions.
  CLEAR wa_questions.
  READ TABLE lt_questions INTO wa_questions INDEX lv_current_question_no.



  "set question text


  DATA lo_el_context TYPE REF TO if_wd_context_element.
  DATA ls_context TYPE wd_this->element_context.
  DATA lv_question_text TYPE wd_this->element_context-question_text.

* get element via lead selection
  lo_el_context = wd_context->get_element( ).

* @TODO handle not set lead selection
  IF lo_el_context IS INITIAL.
  ENDIF.

* @TODO fill attribute
* lv_question_text = 1.

* set single attribute
  lo_el_context->set_attribute(
    name =  `QUESTION_TEXT`
    value = wa_questions-question ).




  """"""method to check CHECKBOX OR RADIOBUTTON

  ""1
  "call method to check whether the question is checkbox type or not
  DATA flag_is_chb.

  zcl_g13_wdc_supplyfunctions=>is_answer_chb_type(
    EXPORTING
      im_answer =  wa_questions-answer   " Not More Closely Defined Area, Possibly Used for Patchlevels
    IMPORTING
      ex_is_chb =  flag_is_chb   " Single-Character Flag
  ).

  ""2 set attribute CHB_VISIBILITY
  "read and then set CHB_VISIBILITY

  DATA lo_nd_global_data TYPE REF TO if_wd_context_node.

  DATA lo_el_global_data TYPE REF TO if_wd_context_element.
  DATA ls_global_data TYPE wd_this->element_global_data.
  DATA lv_chb_visibility TYPE wd_this->element_global_data-chb_visibility.

*     navigate from <CONTEXT> to <GLOBAL_DATA> via lead selection
  lo_nd_global_data = wd_context->get_child_node( name = wd_this->wdctx_global_data ).

*     @TODO handle non existant child
*     IF lo_nd_global_data IS INITIAL.
*     ENDIF.

*     get element via lead selection
  lo_el_global_data = lo_nd_global_data->get_element( ).

*     @TODO handle not set lead selection
  IF lo_el_global_data IS INITIAL.
  ENDIF.



  ""3 set text for lo_nd_node_radio
  " data declaration for set radio buttons and checkboxes OPTIONS
  DATA lo_nd_node_radio TYPE REF TO if_wd_context_node.
  DATA lt_node_radio TYPE wd_this->elements_node_radio.
  DATA ls_node_radio LIKE LINE OF lt_node_radio.

*   navigate from <CONTEXT> to <NODE_RADIO> via lead selection
  lo_nd_node_radio = wd_context->get_child_node( name = wd_this->wdctx_node_radio ).



  ""4
  "code to set the previously marked questions
  "first read node selected_answers

  DATA lo_nd_selected_answers TYPE REF TO if_wd_context_node.

  DATA lt_selected_answers TYPE wd_this->elements_selected_answers.
  DATA ls_selected_answers LIKE LINE OF lt_selected_answers.

*   navigate from <CONTEXT> to <SELECTED_ANSWERS> via lead selection
  lo_nd_selected_answers = wd_context->get_child_node( name = wd_this->wdctx_selected_answers ).

*   @TODO handle non existant child
*   IF lo_nd_selected_answers IS INITIAL.
*   ENDIF.

  lo_nd_selected_answers->get_static_attributes_table( IMPORTING table = lt_selected_answers ).
  READ TABLE lt_selected_answers INTO ls_selected_answers INDEX lv_current_question_no.


  IF flag_is_chb = 'X'.
    """""""""""""""""""""""""""""""CHECKBOXES""""""""""""""""""""""""""""""""
    "checkbox question
    lv_chb_visibility = 'X'.


*   @TODO handle non existant child
*   IF lo_nd_node_radio IS INITIAL.
*   ENDIF.

    ls_node_radio-button = wa_questions-option1.
    APPEND ls_node_radio TO lt_node_radio.
    CLEAR ls_node_radio.

    ls_node_radio-button = wa_questions-option2.
    APPEND ls_node_radio TO lt_node_radio.
    CLEAR ls_node_radio.

    ls_node_radio-button = wa_questions-option3.
    APPEND ls_node_radio TO lt_node_radio.
    CLEAR ls_node_radio.

    ls_node_radio-button = wa_questions-option4.
    APPEND ls_node_radio TO lt_node_radio.
    CLEAR ls_node_radio.

*  * @TODO compute values
*  * e.g. call a model function
*
    lo_nd_node_radio->bind_table( new_items = lt_node_radio set_initial_elements = abap_true ).

    "set initial options

    IF ls_selected_answers-applicant_answer <> '0000'.

      DATA numeric_answer TYPE i.
      numeric_answer = ls_selected_answers-applicant_answer .

      IF numeric_answer > 999.
        lo_nd_node_radio->set_selected(
          EXPORTING
            flag  = abap_true    " Value with Which Property Is to Filled
            index = 1    " Index of Context Element
        ).
      ENDIF.

      numeric_answer = numeric_answer MOD 1000.
      IF numeric_answer > 99.
        lo_nd_node_radio->set_selected(
          EXPORTING
            flag  = abap_true    " Value with Which Property Is to Filled
            index = 2    " Index of Context Element
        ).
      ENDIF.

      numeric_answer = numeric_answer MOD 100.
      IF numeric_answer > 9.
        lo_nd_node_radio->set_selected(
          EXPORTING
            flag  = abap_true    " Value with Which Property Is to Filled
            index = 3    " Index of Context Element
        ).
      ENDIF.

      numeric_answer = numeric_answer MOD 10.
      IF numeric_answer > 0.
        lo_nd_node_radio->set_selected(
          EXPORTING
            flag  = abap_true    " Value with Which Property Is to Filled
            index = 4    " Index of Context Element
        ).
      ENDIF.

    ENDIF.

  ELSE.
    "thus flag_is_chb = ' '
    """""""""""""""""""""""""""""""RADIOBUTTONS"""""""""""""""""""""""""""""

    "radiobutton question
    lv_chb_visibility = ' '.

    ls_node_radio-button = wa_questions-option1.
    APPEND ls_node_radio TO lt_node_radio.
    CLEAR ls_node_radio.

    ls_node_radio-button = wa_questions-option2.
    APPEND ls_node_radio TO lt_node_radio.
    CLEAR ls_node_radio.

    ls_node_radio-button = wa_questions-option3.
    APPEND ls_node_radio TO lt_node_radio.
    CLEAR ls_node_radio.

    ls_node_radio-button = wa_questions-option4.
    APPEND ls_node_radio TO lt_node_radio.
    CLEAR ls_node_radio.


    ls_node_radio-button = 'Not Selected'.
    APPEND ls_node_radio TO lt_node_radio.
    CLEAR ls_node_radio.



*  * @TODO compute values
*  * e.g. call a model function
*
    lo_nd_node_radio->bind_table( new_items = lt_node_radio set_initial_elements = abap_true ).


    "set initial option
    IF ls_selected_answers-applicant_answer <> '0000'.
      DATA: selected_rb_index TYPE i,
            app_answer        TYPE i.
      app_answer = ls_selected_answers-applicant_answer.
      CASE app_answer.
        WHEN 1000.
          selected_rb_index = 1.
        WHEN 100.
          selected_rb_index = 2.
        WHEN 10.
          selected_rb_index = 3.
        WHEN 1.
          selected_rb_index = 4.
        WHEN 5.
          selected_rb_index = 5.
      ENDCASE.

      lo_nd_node_radio->set_lead_selection_index( index = selected_rb_index ).

    ELSE.
      lo_nd_node_radio->set_lead_selection_index( index = 0 ).
    ENDIF.

  ENDIF.

  ""2
*set single attribute
  lo_el_global_data->set_attribute(
    name =  `CHB_VISIBILITY`
    value = lv_chb_visibility ).


  "Setting the question Number ============

*  DATA lo_el_context TYPE REF TO if_wd_context_element.
*  DATA ls_context TYPE wd_this->element_context.
  DATA lv_atr_question_title TYPE wd_this->element_context-atr_question_title.

*   get element via lead selection
  lo_el_context = wd_context->get_element( ).

*   @TODO handle not set lead selection
  IF lo_el_context IS INITIAL.
  ENDIF.

  DATA : lv_que_id TYPE string.
  lv_que_id = lv_current_question_no.

  CONCATENATE 'Question No :' lv_que_id INTO lv_atr_question_title SEPARATED BY ' '.

*   set single attribute
  lo_el_context->set_attribute(
    name =  `ATR_QUESTION_TITLE`
    value = lv_atr_question_title ).






  ""visibility of prev and next button
  DATA lv_flag_first_q TYPE wd_this->element_global_data-flag_first_q.
  DATA lv_flag_last_q TYPE wd_this->element_global_data-flag_last_q.

  DATA lo_nd_global_data2 TYPE REF TO if_wd_context_node.

  DATA lo_el_global_data2 TYPE REF TO if_wd_context_element.
  DATA ls_global_data2 TYPE wd_this->element_global_data2.
  DATA lv_no_of_questions TYPE wd_this->element_global_data2-no_of_questions.

*  navigate from <CONTEXT> to <GLOBAL_DATA2> via lead selection
  lo_nd_global_data2 = wd_context->get_child_node( name = wd_this->wdctx_global_data2 ).
*  get element via lead selection
  lo_el_global_data2 = lo_nd_global_data2->get_element( ).

*  get single attribute
  lo_el_global_data2->get_attribute(
    EXPORTING
      name =  `NO_OF_QUESTIONS`
    IMPORTING
      value = lv_no_of_questions ).


  IF lv_current_question_no = 1.
    lv_flag_first_q = 'X'.
  ELSE.
    lv_flag_first_q = ' '.
  ENDIF.

  IF lv_current_question_no = lv_no_of_questions. "no of questions
    lv_flag_last_q = 'X'.
  ELSE.
    lv_flag_last_q = ' '.
  ENDIF.


  "set single attribute flag first question
  lo_el_global_data->set_attribute(
    name =  `FLAG_FIRST_Q`
    value = lv_flag_first_q ).


  "set single attribute flag last question
  lo_el_global_data->set_attribute(
    name =  `FLAG_LAST_Q`
    value = lv_flag_last_q ).



ENDMETHOD.