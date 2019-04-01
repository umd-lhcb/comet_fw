-- Version: v11.7 11.7.0.119

library ieee;
use ieee.std_logic_1164.all;
library proasic3e;
use proasic3e.all;

entity LVDS_BUFOUT is

    port( Data : in    std_logic;
          PADP : out   std_logic;
          PADN : out   std_logic
        );

end LVDS_BUFOUT;

architecture DEF_ARCH of LVDS_BUFOUT is 

  component OUTBUF_LVDS
    port( D    : in    std_logic := 'U';
          PADP : out   std_logic;
          PADN : out   std_logic
        );
  end component;

  component VCC
    port(Y : out std_logic); 
  end component;

    signal \VCC\ : std_logic;
    signal VCC_power_net1 : std_logic;

begin 

    \VCC\ <= VCC_power_net1;

    \OUTBUF_LVDS[0]\ : OUTBUF_LVDS
      port map(D => Data, PADP => PADP, PADN => PADN);
    
    VCC_power_inst1 : VCC
      port map( Y => VCC_power_net1);


end DEF_ARCH; 

-- _Disclaimer: Please leave the following comments in the file, they are for internal purposes only._


-- _GEN_File_Contents_

-- Version:11.7.0.119
-- ACTGENU_CALL:1
-- BATCH:T
-- FAM:PA3
-- OUTFORMAT:VHDL
-- LPMTYPE:LPM_IO_OUTBUF
-- LPM_HINT:OUTBUF_SP
-- INSERT_PAD:NO
-- INSERT_IOREG:NO
-- GEN_BHV_VHDL_VAL:F
-- GEN_BHV_VERILOG_VAL:F
-- MGNTIMER:F
-- MGNCMPL:T
-- DESDIR:F:/0_all_libero_project/CERN_LHCb/COMET_TEST_Apr18_2016_NEW_Clk_Arch_1elinkPlusInvTFC/COMET_TEST/smartgen\LVDS_BUFOUT
-- GEN_BEHV_MODULE:F
-- SMARTGEN_DIE:IT10X10M3
-- SMARTGEN_PACKAGE:pq208
-- AGENIII_IS_SUBPROJECT_LIBERO:T
-- WIDTH:1
-- TYPE:LVDS
-- TRIEN_POLARITY:0
-- CLR_POLARITY:0

-- _End_Comments_

