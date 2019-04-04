METHOD onactionprevious_question .

  "import current question no
  " read the attribute current question and increment its value by 1

  DATA lo_nd_currentq TYPE REF TO if_wd_context_node.

  DATA lo_el_currentq TYPE REF TO if_wd_context_element.
  DATA ls_currentq TYPE wd_this->element_currentq.
  DATA lv_current_question_no TYPE wd_this->element_currentq-current_question_no.

  lo_nd_currentq = wd_context->get_child_node( name = wd_this->wdctx_currentq ).

*   get element via lead selection
  lo_el_currentq = lo_nd_currentq->get_element( ).
*   @TODO handle not set lead selection
  IF lo_el_currentq IS INITIAL.
  ENDIF.

*   get single attribute
  lo_el_currentq->get_attribute(
    EXPORTING
      name =  `CURRENT_QUESTION_NO`
    IMPORTING
      value = lv_current_question_no ).




  "read chb_visibility for checkbox status
  DATA lo_nd_global_data TYPE REF TO if_wd_context_node.

  DATA lo_el_global_data TYPE REF TO if_wd_context_element.
  DATA ls_global_data TYPE wd_this->element_global_data.
  DATA lv_chb_visibility TYPE wd_this->element_global_data-chb_visibility.

* navigate from <CONTEXT> to <GLOBAL_DATA> via lead selection
  lo_nd_global_data = wd_context->get_child_node( name = wd_this->wdctx_global_data ).

* @TODO handle non existant child
* IF lo_nd_global_data IS INITIAL.
* ENDIF.

* get element via lead selection
  lo_el_global_data = lo_nd_global_data->get_element( ).
* @TODO handle not set lead selection
  IF lo_el_global_data IS INITIAL.
  ENDIF.

* get single attribute
  lo_el_global_data->get_attribute(
    EXPORTING
      name =  `CHB_VISIBILITY`
    IMPORTING
      value = lv_chb_visibility ).



  "SET THE VALUES OF ANSWERS IN THE NODE SELECTED_ANSWERS



  DATA lo_nd_node_radio TYPE REF TO if_wd_context_node.
  DATA lt_node_radio TYPE wd_this->elements_node_radio.

  DATA: selected_answer_i TYPE i VALUE 0,
        selected_answer   TYPE char4,
        pow               TYPE i,
        index             TYPE i.

* navigate from <CONTEXT> to <NODE_RADIO> via lead selection
  lo_nd_node_radio = wd_context->get_child_node( name = wd_this->wdctx_node_radio ).



  IF lv_chb_visibility = 'X'.

    """"""CHECKBOXES""""""""
    DATA: lt_set TYPE wdr_context_element_set,
          ls_set LIKE LINE OF lt_set.

    CALL METHOD lo_nd_node_radio->get_selected_elements
*      EXPORTING
*        including_lead_selection = ABAP_FALSE
      RECEIVING
        set = lt_set.



    LOOP AT lt_set INTO ls_set.
      index = ls_set->get_index( ).
      pow = 4 - index.
      selected_answer_i = selected_answer_i + 10 ** pow.
    ENDLOOP.

    selected_answer = selected_answer_i.


  ELSE.

    """"""RADIOBUTTONS""""""

    index = lo_nd_node_radio->get_lead_selection_index( ).

    IF index = 5.
      selected_answer_i = 5.
    ELSEIF index >= 1 AND index <= 4.
      pow = 4 - index.
      selected_answer_i = 10 ** pow.
    ENDIF.

    selected_answer = selected_answer_i.

  ENDIF.

  ""read the selected answer in the selected_question node

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

  ls_selected_answers-applicant_answer = selected_answer.

  MODIFY lt_selected_answers FROM ls_selected_answers INDEX lv_current_question_no.

  lo_nd_selected_answers->bind_table( new_items = lt_selected_answers set_initial_elements = abap_true ).



  ""increment question no.
  lv_current_question_no = lv_current_question_no - 1.

  lo_el_currentq->set_attribute(
    EXPORTING
      value =   lv_current_question_no  " Attribute Value
      name  =    `CURRENT_QUESTION_NO` " Web Dynpro: Name of Context Element
  ).





  wd_this->fire_to_v_question_plg(
   ).


ENDMETHOD.