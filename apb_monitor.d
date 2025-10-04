module apb.apb_monitor;

import esdl;
import uvm;

import apb.apb_seq_item: apb_seq_item, access_enum;
import apb.apb_intf: apb_intf;

class apb_monitor(int DW, int AW): uvm_monitor
{
  mixin uvm_component_utils;

  apb_intf!(DW, AW) apb_if;
  
  this(string name, uvm_component parent) {
    super(name, parent);
  }

  @UVM_BUILD uvm_analysis_port!(apb_seq_item!(DW, AW)) egress;

  override void connect_phase(uvm_phase phase) {
    alias ApbIf = apb_intf!(DW, AW);
    super.connect_phase(phase);
    
    uvm_config_db!ApbIf.get(this, "", "apb_if", apb_if);
    assert (apb_if !is null);
  }
  
  override void run_phase(uvm_phase phase) {
    import std.format: format;
    
    super.run_phase(phase);

    while (true) {
      wait (apb_if.PCLK.posedge());
      if (apb_if.PRESETn == 0 || apb_if.PSEL == 0) continue;

      apb_seq_item!(DW, AW) item =
        apb_seq_item!(DW, AW).type_id.create(get_full_name() ~
                                             ".apb_seq_item");

      item.addr  = apb_if.PADDR;

      while (apb_if.PENABLE == 0 || apb_if.PREADY == 0) {
        wait (apb_if.PCLK.posedge());
      }

      // item.err  = apb_if.PSLVERR;

      if (apb_if.PWRITE) {
        item.type = access_enum.WRITE;
        item.data = apb_if.PWDATA;
      }
      else {
        item.type = access_enum.READ;
        item.data = apb_if.PRDATA;
      }
      uvm_info("APB: ITEM", format("\n%s", item.sprint()), UVM_DEBUG);
      egress.write(item);
    }
  }
}

