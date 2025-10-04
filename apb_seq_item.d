module apb.apb_seq_item;

import esdl;
import uvm;

enum access_enum: bool {READ, WRITE}

class apb_seq_item(int DW, int AW): uvm_sequence_item
{
  mixin uvm_object_utils;
  
  this(string name="") {
    super(name);
  }
  
  enum BW = DW/8;

  @UVM_DEFAULT {
    @rand ubvec!AW addr;
    @rand ubvec!DW  data;
    @rand access_enum type;
    @UVM_BIN                    // print in binary format
      @rand ubvec!BW strb;
  }

  constraint! q{
    (addr >> 2) < 4;
    addr % BW == 0;
  } addrCst;

}

