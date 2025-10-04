module apb.apb_sequencer;

import esdl;
import uvm;

import apb.apb_seq_item: apb_seq_item;

class apb_sequencer(int DW, int AW):
  uvm_sequencer!(apb_seq_item!(DW, AW))
{
  mixin uvm_component_utils;

  this(string name, uvm_component parent=null) {
    super(name, parent);
  }
}

