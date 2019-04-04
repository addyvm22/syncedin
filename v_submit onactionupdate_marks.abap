METHOD onactionupdate_marks .

*   get message manager
  DATA lo_api_controller     TYPE REF TO if_wd_controller.
  DATA lo_message_manager    TYPE REF TO if_wd_message_manager.

  DATA lo_el_context TYPE REF TO if_wd_context_element.
  DATA ls_context TYPE wd_this->element_context.
  DATA lv_percentage TYPE wd_this->element_context-percentage.

*   get element via lead selection
  lo_el_context = wd_context->get_element( ).
*   @TODO handle not set lead selection
  IF lo_el_context IS INITIAL.
  ENDIF.

*   get single attribute
  lo_el_context->get_attribute(
    EXPORTING
      name =  `PERCENTAGE`
    IMPORTING
      value = lv_percentage ).


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
      im_percentage    =  lv_percentage   " Percentage
      im_assessment_id =  lv_assessment_id   " ASU - General ID f.g. sequence number
    EXCEPTIONS
      updatefailed     = 1
      others           = 2
  ).

  IF sy-subrc <> 0.
    lo_api_controller ?= wd_this->wd_get_api( ).

    CALL METHOD lo_api_controller->get_message_manager
      RECEIVING
        message_manager = lo_message_manager.

*   report message
    CALL METHOD lo_message_manager->report_warning
      EXPORTING
        message_text = 'Please retry Updating marks'.

  ELSE.

    DATA lv_marks_update_error TYPE wd_this->element_context-marks_update_error.
*     get element via lead selection
    lo_el_context = wd_context->get_element( ).
*     @TODO handle not set lead selection
    IF lo_el_context IS INITIAL.
    ENDIF.
*     set single attribute
    lo_el_context->set_attribute(
      name =  `MARKS_UPDATE_ERROR`
      value = ' ').

    DATA lv_marks_update_text TYPE wd_this->element_context-marks_update_text.

*     get element via lead selection
    lo_el_context = wd_context->get_element( ).

*     set single attribute
    lo_el_context->set_attribute(
      name =  `MARKS_UPDATE_TEXT`
      value = 'Marks updated successfully!!' ).





    lo_api_controller ?= wd_this->wd_get_api( ).

    CALL METHOD lo_api_controller->get_message_manager
      RECEIVING
        message_manager = lo_message_manager.

*   report message
    CALL METHOD lo_message_manager->report_warning
      EXPORTING
        message_text = 'Marks updated Successfully'.

  ENDIF.

ENDMETHOD.