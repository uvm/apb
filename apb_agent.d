module apb.apb_agent;

import esdl;
import uvm;

import apb.apb_monitor: apb_monitor;
import apb.apb_driver: apb_driver;
import apb.apb_sequencer: apb_sequencer;

class apb_agent(int DW, int AW): uvm_agent
{
  mixin uvm_component_utils;

  @UVM_BUILD {
    apb_monitor!(DW, AW)    monitor;
  }

  @UVM_BUILD_IF_ACTIVE {
    apb_sequencer!(DW, AW)  sequencer;
    apb_driver!(DW, AW)     driver;
  }

  this(string name, uvm_component parent) {
    super(name, parent);
  }

  override void connect_phase(uvm_phase phase) {
    super.connect_phase(phase);
    if (get_is_active() == UVM_ACTIVE) {
      driver.seq_item_port.connect(sequencer.seq_item_export);
    }
  }
}
