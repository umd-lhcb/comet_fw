-- Version: v11.5 SP2 11.5.2.6

library ieee;
use ieee.std_logic_1164.all;
library proasic3e;
use proasic3e.all;

entity BIDIR_LVDS_IO is

    port( Data  : in    std_logic;
          Y     : out   std_logic;
          Trien : in    std_logic;
          PADP  : inout std_logic := 'Z';
          PADN  : inout std_logic := 'Z'
        );

end BIDIR_LVDS_IO;

architecture DEF_ARCH of BIDIR_LVDS_IO is 

  component INV
    port( A : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component BIBUF_LVDS
    port( PADP : inout   std_logic;
          PADN : inout   std_logic;
          D    : in    std_logic := 'U';
          E    : in    std_logic := 'U';
          Y    : out   std_logic
        );
  end component;

    signal TrienAux : std_logic;

begin 


    Inv_Tri : INV
      port map(A => Trien, Y => TrienAux);
    
    \BIBUF_LVDS[0]\ : BIBUF_LVDS
      port map(PADP => PADP, PADN => PADN, D => Data, E => 
        TrienAux, Y => Y);
    

end DEF_ARCH; 

-- _Disclaimer: Please leave the following comments in the file, they are for internal purposes only._


-- _GEN_File_Contents_

-- Version:11.5.2.6
-- ACTGENU_CALL:1
-- BATCH:T
-- FAM:PA3
-- OUTFORMAT:VHDL
-- LPMTYPE:LPM_IO_BIBUF
-- LPM_HINT:BIBUF_SP
-- INSERT_PAD:NO
-- INSERT_IOREG:NO
-- GEN_BHV_VHDL_VAL:F
-- GEN_BHV_VERILOG_VAL:F
-- MGNTIMER:F
-- MGNCMPL:T
-- DESDIR:D:/0_all_libero_project/CERN_LHCb/COMET_TEST/smartgen\BIDIR_LVDS_IO
-- GEN_BEHV_MODULE:F
-- SMARTGEN_DIE:IT10X10M3
-- SMARTGEN_PACKAGE:pq208
-- AGENIII_IS_SUBPROJECT_LIBERO:T
-- WIDTH:1
-- TYPE:LVDS
-- TRIEN_POLARITY:0
-- CLR_POLARITY:0

-- _End_Comments_

