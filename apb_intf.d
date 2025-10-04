module apb.apb_intf;

import esdl;

class apb_intf(int DW, int AW): VlInterface
{
  Port!(Signal!(ubvec!1)) PCLK;
  Port!(Signal!(ubvec!1)) PRESETn;

  VlPort!(1) PSEL;
  VlPort!(1) PENABLE;
  VlPort!(1) PWRITE;
  VlPort!(1) PREADY;
  VlPort!(1) PSLVERR;
  VlPort!(AW) PADDR;
  VlPort!(DW) PWDATA;
  VlPort!(DW) PRDATA;
}

