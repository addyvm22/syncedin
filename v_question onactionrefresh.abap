METHOD onactionrefresh .

  "------- Reading the Timer --------------
  DATA lo_nd_global_data4 TYPE REF TO if_wd_context_node.

  DATA lo_el_global_data4 TYPE REF TO if_wd_context_element.
  DATA ls_global_data4 TYPE wd_this->element_global_data4.
  DATA lv_time_left TYPE wd_this->element_global_data4-time_left.

*   navigate from <CONTEXT> to <GLOBAL_DATA4> via lead selection
  lo_nd_global_data4 = wd_context->get_child_node( name = wd_this->wdctx_global_data4 ).

*   @TODO handle non existant child
*   IF lo_nd_global_data4 IS INITIAL.
*   ENDIF.

*   get element via lead selection
  lo_el_global_data4 = lo_nd_global_data4->get_element( ).
*   @TODO handle not set lead selection
  IF lo_el_global_data4 IS INITIAL.
  ENDIF.

*   get single attribute
  lo_el_global_data4->get_attribute(
    EXPORTING
      name =  `TIME_LEFT`
    IMPORTING
      value = lv_time_left ).

  "------- If timer is 0 then navigate to Scores_View --------------
  IF lv_time_left EQ 0.


    wd_this->fire_to_v_scores_plg(
    ).

*    ------- Message if the timer is less than 1 Min --------------
  ELSEIF lv_time_left LE 60.
* get message manager
    DATA lo_api_controller     TYPE REF TO if_wd_controller.
    DATA lo_message_manager    TYPE REF TO if_wd_message_manager.

    lo_api_controller ?= wd_this->wd_get_api( ).

    CALL METHOD lo_api_controller->get_message_manager
      RECEIVING
        message_manager = lo_message_manager.

* report message
    CALL METHOD lo_message_manager->report_warning
      EXPORTING
        message_text = 'You have less than 1 miniute left!'.

  ENDIF.
  "------- Reducing the Timer by 1 Sec --------------
  lv_time_left = lv_time_left - 1.


  "------- Setting the timer --------------
*   set single attribute
    lo_el_global_data4->set_attribute(
      name =  `TIME_LEFT`
      value = lv_time_left ).







ENDMETHOD.