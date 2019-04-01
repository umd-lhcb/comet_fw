-- Version: v11.5 SP2 11.5.2.6

library ieee;
use ieee.std_logic_1164.all;
library proasic3e;
use proasic3e.all;

entity DPRT_512X9_SRAM is

    port( DINA  : in    std_logic_vector(8 downto 0);
          DOUTA : out   std_logic_vector(8 downto 0);
          DINB  : in    std_logic_vector(8 downto 0);
          DOUTB : out   std_logic_vector(8 downto 0);
          ADDRA : in    std_logic_vector(8 downto 0);
          ADDRB : in    std_logic_vector(8 downto 0);
          RWA   : in    std_logic;
          RWB   : in    std_logic;
          BLKA  : in    std_logic;
          BLKB  : in    std_logic;
          CLKA  : in    std_logic;
          CLKB  : in    std_logic;
          RESET : in    std_logic
        );

end DPRT_512X9_SRAM;

architecture DEF_ARCH of DPRT_512X9_SRAM is 

  component RAM4K9
    generic (MEMORYFILE:string := "");

    port( ADDRA11 : in    std_logic := 'U';
          ADDRA10 : in    std_logic := 'U';
          ADDRA9  : in    std_logic := 'U';
          ADDRA8  : in    std_logic := 'U';
          ADDRA7  : in    std_logic := 'U';
          ADDRA6  : in    std_logic := 'U';
          ADDRA5  : in    std_logic := 'U';
          ADDRA4  : in    std_logic := 'U';
          ADDRA3  : in    std_logic := 'U';
          ADDRA2  : in    std_logic := 'U';
          ADDRA1  : in    std_logic := 'U';
          ADDRA0  : in    std_logic := 'U';
          ADDRB11 : in    std_logic := 'U';
          ADDRB10 : in    std_logic := 'U';
          ADDRB9  : in    std_logic := 'U';
          ADDRB8  : in    std_logic := 'U';
          ADDRB7  : in    std_logic := 'U';
          ADDRB6  : in    std_logic := 'U';
          ADDRB5  : in    std_logic := 'U';
          ADDRB4  : in    std_logic := 'U';
          ADDRB3  : in    std_logic := 'U';
          ADDRB2  : in    std_logic := 'U';
          ADDRB1  : in    std_logic := 'U';
          ADDRB0  : in    std_logic := 'U';
          DINA8   : in    std_logic := 'U';
          DINA7   : in    std_logic := 'U';
          DINA6   : in    std_logic := 'U';
          DINA5   : in    std_logic := 'U';
          DINA4   : in    std_logic := 'U';
          DINA3   : in    std_logic := 'U';
          DINA2   : in    std_logic := 'U';
          DINA1   : in    std_logic := 'U';
          DINA0   : in    std_logic := 'U';
          DINB8   : in    std_logic := 'U';
          DINB7   : in    std_logic := 'U';
          DINB6   : in    std_logic := 'U';
          DINB5   : in    std_logic := 'U';
          DINB4   : in    std_logic := 'U';
          DINB3   : in    std_logic := 'U';
          DINB2   : in    std_logic := 'U';
          DINB1   : in    std_logic := 'U';
          DINB0   : in    std_logic := 'U';
          WIDTHA0 : in    std_logic := 'U';
          WIDTHA1 : in    std_logic := 'U';
          WIDTHB0 : in    std_logic := 'U';
          WIDTHB1 : in    std_logic := 'U';
          PIPEA   : in    std_logic := 'U';
          PIPEB   : in    std_logic := 'U';
          WMODEA  : in    std_logic := 'U';
          WMODEB  : in    std_logic := 'U';
          BLKA    : in    std_logic := 'U';
          BLKB    : in    std_logic := 'U';
          WENA    : in    std_logic := 'U';
          WENB    : in    std_logic := 'U';
          CLKA    : in    std_logic := 'U';
          CLKB    : in    std_logic := 'U';
          RESET   : in    std_logic := 'U';
          DOUTA8  : out   std_logic;
          DOUTA7  : out   std_logic;
          DOUTA6  : out   std_logic;
          DOUTA5  : out   std_logic;
          DOUTA4  : out   std_logic;
          DOUTA3  : out   std_logic;
          DOUTA2  : out   std_logic;
          DOUTA1  : out   std_logic;
          DOUTA0  : out   std_logic;
          DOUTB8  : out   std_logic;
          DOUTB7  : out   std_logic;
          DOUTB6  : out   std_logic;
          DOUTB5  : out   std_logic;
          DOUTB4  : out   std_logic;
          DOUTB3  : out   std_logic;
          DOUTB2  : out   std_logic;
          DOUTB1  : out   std_logic;
          DOUTB0  : out   std_logic
        );
  end component;

  component GND
    port(Y : out std_logic); 
  end component;

  component VCC
    port(Y : out std_logic); 
  end component;

    signal \VCC\, \GND\ : std_logic;
    signal GND_power_net1 : std_logic;
    signal VCC_power_net1 : std_logic;

begin 

    \GND\ <= GND_power_net1;
    \VCC\ <= VCC_power_net1;

    DPRT_512X9_SRAM_R0C0 : RAM4K9
      generic map(MEMORYFILE => "DPRT_512X9_SRAM_R0C0.mem")

      port map(ADDRA11 => \GND\, ADDRA10 => \GND\, ADDRA9 => 
        \GND\, ADDRA8 => ADDRA(8), ADDRA7 => ADDRA(7), ADDRA6 => 
        ADDRA(6), ADDRA5 => ADDRA(5), ADDRA4 => ADDRA(4), ADDRA3
         => ADDRA(3), ADDRA2 => ADDRA(2), ADDRA1 => ADDRA(1), 
        ADDRA0 => ADDRA(0), ADDRB11 => \GND\, ADDRB10 => \GND\, 
        ADDRB9 => \GND\, ADDRB8 => ADDRB(8), ADDRB7 => ADDRB(7), 
        ADDRB6 => ADDRB(6), ADDRB5 => ADDRB(5), ADDRB4 => 
        ADDRB(4), ADDRB3 => ADDRB(3), ADDRB2 => ADDRB(2), ADDRB1
         => ADDRB(1), ADDRB0 => ADDRB(0), DINA8 => DINA(8), DINA7
         => DINA(7), DINA6 => DINA(6), DINA5 => DINA(5), DINA4
         => DINA(4), DINA3 => DINA(3), DINA2 => DINA(2), DINA1
         => DINA(1), DINA0 => DINA(0), DINB8 => DINB(8), DINB7
         => DINB(7), DINB6 => DINB(6), DINB5 => DINB(5), DINB4
         => DINB(4), DINB3 => DINB(3), DINB2 => DINB(2), DINB1
         => DINB(1), DINB0 => DINB(0), WIDTHA0 => \VCC\, WIDTHA1
         => \VCC\, WIDTHB0 => \VCC\, WIDTHB1 => \VCC\, PIPEA => 
        \VCC\, PIPEB => \VCC\, WMODEA => \GND\, WMODEB => \GND\, 
        BLKA => BLKA, BLKB => BLKB, WENA => RWA, WENB => RWB, 
        CLKA => CLKA, CLKB => CLKB, RESET => RESET, DOUTA8 => 
        DOUTA(8), DOUTA7 => DOUTA(7), DOUTA6 => DOUTA(6), DOUTA5
         => DOUTA(5), DOUTA4 => DOUTA(4), DOUTA3 => DOUTA(3), 
        DOUTA2 => DOUTA(2), DOUTA1 => DOUTA(1), DOUTA0 => 
        DOUTA(0), DOUTB8 => DOUTB(8), DOUTB7 => DOUTB(7), DOUTB6
         => DOUTB(6), DOUTB5 => DOUTB(5), DOUTB4 => DOUTB(4), 
        DOUTB3 => DOUTB(3), DOUTB2 => DOUTB(2), DOUTB1 => 
        DOUTB(1), DOUTB0 => DOUTB(0));
    
    GND_power_inst1 : GND
      port map( Y => GND_power_net1);

    VCC_power_inst1 : VCC
      port map( Y => VCC_power_net1);


end DEF_ARCH; 

-- _Disclaimer: Please leave the following comments in the file, they are for internal purposes only._


-- _GEN_File_Contents_

-- Version:11.5.2.6
-- ACTGENU_CALL:1
-- BATCH:T
-- FAM:PA3
-- OUTFORMAT:VHDL
-- LPMTYPE:LPM_RAM
-- LPM_HINT:DUAL
-- INSERT_PAD:NO
-- INSERT_IOREG:NO
-- GEN_BHV_VHDL_VAL:F
-- GEN_BHV_VERILOG_VAL:F
-- MGNTIMER:F
-- MGNCMPL:T
-- DESDIR:D:/0_all_libero_project/CERN_LHCb/COMET_TEST/smartgen\DPRT_512X9_SRAM
-- GEN_BEHV_MODULE:F
-- SMARTGEN_DIE:IT10X10M3
-- SMARTGEN_PACKAGE:pq208
-- AGENIII_IS_SUBPROJECT_LIBERO:T
-- WWIDTH:9
-- WDEPTH:512
-- RWIDTH:9
-- RDEPTH:512
-- CLKS:2
-- RESET_PN:RESET
-- RESET_POLARITY:0
-- INIT_RAM:T
-- DEFAULT_WORD:0x000
-- CASCADE:0
-- WCLK_EDGE:RISE
-- RCLK_EDGE:RISE
-- CLKA_PN:CLKA
-- CLKB_PN:CLKB
-- WMODE1:0
-- WMODE2:0
-- PMODE1:1
-- PMODE2:1
-- DATAA_IN_PN:DINA
-- DATAA_OUT_PN:DOUTA
-- ADDRESSA_PN:ADDRA
-- RWA_PN:RWA
-- BLKA_PN:BLKA
-- DATAB_IN_PN:DINB
-- DATAB_OUT_PN:DOUTB
-- ADDRESSB_PN:ADDRB
-- RWB_PN:RWB
-- BLKB_PN:BLKB
-- WE_POLARITY:0
-- RE_POLARITY:0
-- PTYPE:2

-- _End_Comments_

