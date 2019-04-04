METHOD wddoinit .


  "get questions table
  DATA lo_nd_questions TYPE REF TO if_wd_context_node.
  DATA lt_questions TYPE wd_this->elements_questions.
*   navigate from <CONTEXT> to <QUESTIONS> via lead selection
  lo_nd_questions = wd_context->get_child_node( name = wd_this->wdctx_questions ).
  lo_nd_questions->get_static_attributes_table( IMPORTING table = lt_questions ).



  "get selected answers table
  DATA lo_nd_selected_answers TYPE REF TO if_wd_context_node.
  DATA lt_selected_answers TYPE wd_this->elements_selected_answers.
* navigate from <CONTEXT> to <SELECTED_ANSWERS> via lead selection
  lo_nd_selected_answers = wd_context->get_child_node( name = wd_this->wdctx_selected_answers ).
  lo_nd_selected_answers->get_static_attributes_table( IMPORTING table = lt_selected_answers ).




  "no of questions
  DATA lo_nd_global_data2 TYPE REF TO if_wd_context_node.
  DATA lo_el_global_data2 TYPE REF TO if_wd_context_element.
  DATA ls_global_data2 TYPE wd_this->element_global_data2.
  DATA lv_no_of_questions TYPE wd_this->element_global_data2-no_of_questions.
*   navigate from <CONTEXT> to <GLOBAL_DATA2> via lead selection
  lo_nd_global_data2 = wd_context->get_child_node( name = wd_this->wdctx_global_data2 ).
*   get element via lead selection
  lo_el_global_data2 = lo_nd_global_data2->get_element( ).
*   @TODO handle not set lead selection
  IF lo_el_global_data2 IS INITIAL.
  ENDIF.
*   get single attribute
  lo_el_global_data2->get_attribute(
    EXPORTING
      name =  `NO_OF_QUESTIONS`
    IMPORTING
      value = lv_no_of_questions ).




  "calculate scored marks
  DATA: ans           TYPE i,
        applicant_ans TYPE i,
        marks         TYPE i,
        total_marks   TYPE i.

  WHILE sy-index LE lv_no_of_questions.

    READ TABLE lt_questions INTO DATA(wa1) INDEX sy-index.
    READ TABLE lt_selected_answers INTO DATA(wa2) INDEX sy-index.

    ans = wa1-answer.
    applicant_ans = wa2-applicant_answer.

    IF ans = applicant_ans.
      marks = marks + 5.
    ENDIF.

  ENDWHILE.


  "total marks
  total_marks = lv_no_of_questions * 5.


  "set percentage
  DATA lo_el_context TYPE REF TO if_wd_context_element.
  DATA ls_context TYPE wd_this->element_context.
*   get element via lead selection
  lo_el_context = wd_context->get_element( ).

*   set single attribute
  lo_el_context->set_attribute(
    name =  `MARKS_OBTAINED`
    value = marks ).

*   set single attribute
  lo_el_context->set_attribute(
    name =  `MAX_MARKS`
    value = total_marks ).

  DATA percentage TYPE char6.
  percentage = marks / total_marks.
  percentage = percentage * 100.

*   set single attribute
  lo_el_context->set_attribute(
    name =  `PERCENTAGE`
    value = percentage ).



  "read assessment id.
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





  zcl_g13_wdc_supplyfunctions=>update_percentage(
    EXPORTING
      im_percentage    = percentage    " Percentage
      im_assessment_id = lv_assessment_id   " ASU - General ID f.g. sequence number
  EXCEPTIONS
    updatefailed     = 1
    OTHERS           = 2
  ).
  IF sy-subrc <> 0.

    DATA lv_marks_update_error TYPE wd_this->element_context-marks_update_error.
*     get element via lead selection
    lo_el_context = wd_context->get_element( ).
*     @TODO handle not set lead selection
    IF lo_el_context IS INITIAL.
    ENDIF.
*     set single attribute
    lo_el_context->set_attribute(
      name =  `MARKS_UPDATE_ERROR`
      value = 'X' ).


      DATA lv_marks_update_text TYPE wd_this->element_context-marks_update_text.

*     get element via lead selection
      lo_el_context = wd_context->get_element( ).

*     set single attribute
      lo_el_context->set_attribute(
        name =  `MARKS_UPDATE_TEXT`
        value = 'An error occured when storing your assessment marks. Please retry updating after 5 minutes.' ).



  ENDIF.

ENDMETHOD.