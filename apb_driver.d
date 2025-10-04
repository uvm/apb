module apb.apb_driver;

import esdl;
import uvm;

import apb.apb_seq_item: apb_seq_item, access_enum;
import apb.apb_intf: apb_intf;

class apb_driver(int DW, int AW): uvm_driver!(apb_seq_item!(DW, AW))
{
  enum BW = DW/8;
    
  alias REQ=apb_seq_item!(DW, AW);
  
  mixin uvm_component_utils;

  apb_intf!(DW, AW) apb_if;
  
  REQ tr;

  this(string name, uvm_component parent) {
    super(name,parent);
  }

  override void connect_phase(uvm_phase phase) {
    alias ApbIf = apb_intf!(DW, AW);
    super.connect_phase(phase);
    uvm_config_db!ApbIf.get(this, "", "apb_if", apb_if);
    assert (apb_if !is null);
  }
  
  override void run_phase(uvm_phase phase) {
    super.run_phase(phase);
    get_and_drive(phase);
  }
            
  void write(ubvec!AW addr,
             ubvec!DW data) {
    wait (apb_if.PCLK.negedge());
         
    apb_if.PADDR = addr;
    apb_if.PWDATA = data;
    apb_if.PWRITE = true;
    apb_if.PENABLE = true;
    apb_if.PSEL = true;
    wait (apb_if.PCLK.posedge());
  }

  void read(ubvec!AW addr) {
    wait (apb_if.PCLK.negedge());

    apb_if.PADDR = addr;
    apb_if.PWRITE = false;
    apb_if.PENABLE = true;
    apb_if.PSEL = true;
    wait (apb_if.PCLK.posedge());
  }

  void idle() {
    wait (apb_if.PCLK.negedge());
  }
  
  void get_and_drive(uvm_phase phase) {
    wait (apb_if.PCLK.posedge());
    while(true) {
      while (apb_if.PRESETn == false) {
        wait (apb_if.PCLK.posedge());
      }
      seq_item_port.get_next_item(req);
      if (req.type == access_enum.WRITE) {
        write(req.addr, req.data);
      }
      else {
        read(req.addr);
      }
      while (~ apb_if.PREADY) {
        wait (apb_if.PCLK.posedge());
      }
      wait (apb_if.PCLK.negedge());
      if (req.type == access_enum.READ) req.data = apb_if.PRDATA;
      apb_if.PADDR = UBVEC!(8, 0);
      apb_if.PENABLE = false;
      apb_if.PWDATA = UBVEC!(32, 0);;
      apb_if.PWRITE = false;
      apb_if.PSEL = false;
      seq_item_port.item_done();
    }
  }

}
