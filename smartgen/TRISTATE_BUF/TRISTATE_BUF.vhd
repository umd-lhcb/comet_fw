-- Version: v11.5 SP2 11.5.2.6

library ieee;
use ieee.std_logic_1164.all;
library proasic3e;
use proasic3e.all;

entity tristate_buf is

    port( Data  : in    std_logic;
          Trien : in    std_logic;
          PAD   : out   std_logic
        );

end tristate_buf;

architecture DEF_ARCH of tristate_buf is 

  component TRIBUFF_F_24U
    port( D   : in    std_logic := 'U';
          E   : in    std_logic := 'U';
          PAD : out   std_logic
        );
  end component;


begin 


    \TRIBUFF_F_24U[0]\ : TRIBUFF_F_24U
      port map(D => Data, E => Trien, PAD => PAD);
    

end DEF_ARCH; 

-- _Disclaimer: Please leave the following comments in the file, they are for internal purposes only._


-- _GEN_File_Contents_

-- Version:11.5.2.6
-- ACTGENU_CALL:1
-- BATCH:T
-- FAM:PA3
-- OUTFORMAT:VHDL
-- LPMTYPE:LPM_IO_TRIBUFF
-- LPM_HINT:TRIBUFF_PU
-- INSERT_PAD:NO
-- INSERT_IOREG:NO
-- GEN_BHV_VHDL_VAL:F
-- GEN_BHV_VERILOG_VAL:F
-- MGNTIMER:F
-- MGNCMPL:T
-- DESDIR:D:/0_all_libero_project/CERN_LHCb/COMET_TEST/smartgen\tristate_buf
-- GEN_BEHV_MODULE:F
-- SMARTGEN_DIE:IT10X10M3
-- SMARTGEN_PACKAGE:pq208
-- AGENIII_IS_SUBPROJECT_LIBERO:T
-- WIDTH:1
-- TYPE:F_24U
-- TRIEN_POLARITY:1
-- CLR_POLARITY:0

-- _End_Comments_
