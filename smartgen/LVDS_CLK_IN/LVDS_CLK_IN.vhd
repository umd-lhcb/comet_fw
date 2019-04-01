-- Version: v11.5 SP2 11.5.2.6

library ieee;
use ieee.std_logic_1164.all;
library proasic3e;
use proasic3e.all;

entity LVDS_CLK_IN is

    port( PADP : in    std_logic;
          PADN : in    std_logic;
          Y    : out   std_logic
        );

end LVDS_CLK_IN;

architecture DEF_ARCH of LVDS_CLK_IN is 

  component INBUF_LVDS
    port( PADP : in    std_logic := 'U';
          PADN : in    std_logic := 'U';
          Y    : out   std_logic
        );
  end component;


begin 


    \INBUF_LVDS[0]\ : INBUF_LVDS
      port map(PADP => PADP, PADN => PADN, Y => Y);
    

end DEF_ARCH; 

-- _Disclaimer: Please leave the following comments in the file, they are for internal purposes only._


-- _GEN_File_Contents_

-- Version:11.5.2.6
-- ACTGENU_CALL:1
-- BATCH:T
-- FAM:PA3
-- OUTFORMAT:VHDL
-- LPMTYPE:LPM_IO_INBUF
-- LPM_HINT:INBUF_SP
-- INSERT_PAD:NO
-- INSERT_IOREG:NO
-- GEN_BHV_VHDL_VAL:F
-- GEN_BHV_VERILOG_VAL:F
-- MGNTIMER:F
-- MGNCMPL:T
-- DESDIR:D:/0_all_libero_project/CERN_LHCb/COMET_TEST/smartgen\LVDS_CLK_IN
-- GEN_BEHV_MODULE:F
-- SMARTGEN_DIE:IT10X10M3
-- SMARTGEN_PACKAGE:pq208
-- AGENIII_IS_SUBPROJECT_LIBERO:T
-- WIDTH:1
-- TYPE:LVDS
-- TRIEN_POLARITY:0
-- CLR_POLARITY:0

-- _End_Comments_

