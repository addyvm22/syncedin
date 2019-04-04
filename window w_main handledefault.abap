METHOD handledefault .


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

* @TODO fill attribute
* lv_assessment_id = 1.

* set single attribute
  lo_el_global_data3->set_attribute(
    name =  `ASSESSMENT_ID`
    value = assessment_id ).

ENDMETHOD.