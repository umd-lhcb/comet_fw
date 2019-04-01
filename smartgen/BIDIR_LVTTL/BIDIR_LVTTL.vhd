-- Version: v11.5 SP2 11.5.2.6

library ieee;
use ieee.std_logic_1164.all;
library proasic3e;
use proasic3e.all;

entity BIDIR_LVTTL is

    port( Data  : in    std_logic_vector(7 downto 0);
          Y     : out   std_logic_vector(7 downto 0);
          Trien : in    std_logic;
          PAD   : inout std_logic_vector(7 downto 0) := (others => 'Z')
        );

end BIDIR_LVTTL;

architecture DEF_ARCH of BIDIR_LVTTL is 

  component INV
    port( A : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component BIBUF_F_24U
    port( PAD : inout   std_logic;
          D   : in    std_logic := 'U';
          E   : in    std_logic := 'U';
          Y   : out   std_logic
        );
  end component;

    signal TrienAux : std_logic;

begin 


    Inv_Tri : INV
      port map(A => Trien, Y => TrienAux);
    
    \BIBUF_F_24U[3]\ : BIBUF_F_24U
      port map(PAD => PAD(3), D => Data(3), E => TrienAux, Y => 
        Y(3));
    
    \BIBUF_F_24U[4]\ : BIBUF_F_24U
      port map(PAD => PAD(4), D => Data(4), E => TrienAux, Y => 
        Y(4));
    
    \BIBUF_F_24U[5]\ : BIBUF_F_24U
      port map(PAD => PAD(5), D => Data(5), E => TrienAux, Y => 
        Y(5));
    
    \BIBUF_F_24U[2]\ : BIBUF_F_24U
      port map(PAD => PAD(2), D => Data(2), E => TrienAux, Y => 
        Y(2));
    
    \BIBUF_F_24U[6]\ : BIBUF_F_24U
      port map(PAD => PAD(6), D => Data(6), E => TrienAux, Y => 
        Y(6));
    
    \BIBUF_F_24U[1]\ : BIBUF_F_24U
      port map(PAD => PAD(1), D => Data(1), E => TrienAux, Y => 
        Y(1));
    
    \BIBUF_F_24U[0]\ : BIBUF_F_24U
      port map(PAD => PAD(0), D => Data(0), E => TrienAux, Y => 
        Y(0));
    
    \BIBUF_F_24U[7]\ : BIBUF_F_24U
      port map(PAD => PAD(7), D => Data(7), E => TrienAux, Y => 
        Y(7));
    

end DEF_ARCH; 

-- _Disclaimer: Please leave the following comments in the file, they are for internal purposes only._


-- _GEN_File_Contents_

-- Version:11.5.2.6
-- ACTGENU_CALL:1
-- BATCH:T
-- FAM:PA3
-- OUTFORMAT:VHDL
-- LPMTYPE:LPM_IO_BIBUF
-- LPM_HINT:BIBUF_PU
-- INSERT_PAD:NO
-- INSERT_IOREG:NO
-- GEN_BHV_VHDL_VAL:F
-- GEN_BHV_VERILOG_VAL:F
-- MGNTIMER:F
-- MGNCMPL:T
-- DESDIR:D:/0_all_libero_project/CERN_LHCb/COMET_TEST/smartgen\BIDIR_LVTTL
-- GEN_BEHV_MODULE:F
-- SMARTGEN_DIE:IT10X10M3
-- SMARTGEN_PACKAGE:pq208
-- AGENIII_IS_SUBPROJECT_LIBERO:T
-- WIDTH:8
-- TYPE:F_24U
-- TRIEN_POLARITY:0
-- CLR_POLARITY:0

-- _End_Comments_

