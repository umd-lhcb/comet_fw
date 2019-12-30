-- Version: v11.5 SP2 11.5.2.6

library ieee;
use ieee.std_logic_1164.all;
library proasic3e;
use proasic3e.all;

entity DPRT_512X9_SRAM is

    port( TFC_DOUTB_c       : out   std_logic_vector(7 downto 0);
          TFC_ADDRA         : in    std_logic_vector(8 downto 0);
          TFC_ADDRB_c       : in    std_logic_vector(8 downto 0);
          TFC_DINA          : in    std_logic_vector(7 downto 0);
          TFC_BLKA          : in    std_logic;
          TFC_PATT_GEN_EN_c : in    std_logic;
          CLK60MHZ_c        : in    std_logic;
          CLK_40MHZ_GEN_c   : in    std_logic;
          RESETB_c          : in    std_logic;
          TFC_RWA           : in    std_logic;
          TFC_RWB_c         : in    std_logic
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

  component VCC
    port( Y : out   std_logic
        );
  end component;

  component GND
    port( Y : out   std_logic
        );
  end component;

    signal \DOUTA_1[0]\, \DOUTA_1[1]\, \DOUTA_1[2]\, 
        \DOUTA_1[3]\, \DOUTA_1[4]\, \DOUTA_1[5]\, \DOUTA_1[6]\, 
        \DOUTA_1[7]\, \DOUTA_1[8]\, \DOUTB_1[8]\, 
        DPRT_512X9_SRAM_GND, DPRT_512X9_SRAM_VCC : std_logic;

begin 


    DPRT_512X9_SRAM_R0C0 : RAM4K9
      generic map(MEMORYFILE => "DPRT_512X9_SRAM_R0C0.mem")

      port map(ADDRA11 => DPRT_512X9_SRAM_GND, ADDRA10 => 
        DPRT_512X9_SRAM_GND, ADDRA9 => DPRT_512X9_SRAM_GND, 
        ADDRA8 => TFC_ADDRA(8), ADDRA7 => TFC_ADDRA(7), ADDRA6
         => TFC_ADDRA(6), ADDRA5 => TFC_ADDRA(5), ADDRA4 => 
        TFC_ADDRA(4), ADDRA3 => TFC_ADDRA(3), ADDRA2 => 
        TFC_ADDRA(2), ADDRA1 => TFC_ADDRA(1), ADDRA0 => 
        TFC_ADDRA(0), ADDRB11 => DPRT_512X9_SRAM_GND, ADDRB10 => 
        DPRT_512X9_SRAM_GND, ADDRB9 => DPRT_512X9_SRAM_GND, 
        ADDRB8 => TFC_ADDRB_c(8), ADDRB7 => TFC_ADDRB_c(7), 
        ADDRB6 => TFC_ADDRB_c(6), ADDRB5 => TFC_ADDRB_c(5), 
        ADDRB4 => TFC_ADDRB_c(4), ADDRB3 => TFC_ADDRB_c(3), 
        ADDRB2 => TFC_ADDRB_c(2), ADDRB1 => TFC_ADDRB_c(1), 
        ADDRB0 => TFC_ADDRB_c(0), DINA8 => DPRT_512X9_SRAM_GND, 
        DINA7 => TFC_DINA(7), DINA6 => TFC_DINA(6), DINA5 => 
        TFC_DINA(5), DINA4 => TFC_DINA(4), DINA3 => TFC_DINA(3), 
        DINA2 => TFC_DINA(2), DINA1 => TFC_DINA(1), DINA0 => 
        TFC_DINA(0), DINB8 => DPRT_512X9_SRAM_GND, DINB7 => 
        DPRT_512X9_SRAM_GND, DINB6 => DPRT_512X9_SRAM_GND, DINB5
         => DPRT_512X9_SRAM_GND, DINB4 => DPRT_512X9_SRAM_GND, 
        DINB3 => DPRT_512X9_SRAM_GND, DINB2 => 
        DPRT_512X9_SRAM_GND, DINB1 => DPRT_512X9_SRAM_GND, DINB0
         => DPRT_512X9_SRAM_GND, WIDTHA0 => DPRT_512X9_SRAM_VCC, 
        WIDTHA1 => DPRT_512X9_SRAM_VCC, WIDTHB0 => 
        DPRT_512X9_SRAM_VCC, WIDTHB1 => DPRT_512X9_SRAM_VCC, 
        PIPEA => DPRT_512X9_SRAM_VCC, PIPEB => 
        DPRT_512X9_SRAM_VCC, WMODEA => DPRT_512X9_SRAM_GND, 
        WMODEB => DPRT_512X9_SRAM_GND, BLKA => TFC_BLKA, BLKB => 
        TFC_PATT_GEN_EN_c, WENA => TFC_RWA, WENB => TFC_RWB_c, 
        CLKA => CLK60MHZ_c, CLKB => CLK_40MHZ_GEN_c, RESET => 
        RESETB_c, DOUTA8 => \DOUTA_1[8]\, DOUTA7 => \DOUTA_1[7]\, 
        DOUTA6 => \DOUTA_1[6]\, DOUTA5 => \DOUTA_1[5]\, DOUTA4
         => \DOUTA_1[4]\, DOUTA3 => \DOUTA_1[3]\, DOUTA2 => 
        \DOUTA_1[2]\, DOUTA1 => \DOUTA_1[1]\, DOUTA0 => 
        \DOUTA_1[0]\, DOUTB8 => \DOUTB_1[8]\, DOUTB7 => 
        TFC_DOUTB_c(7), DOUTB6 => TFC_DOUTB_c(6), DOUTB5 => 
        TFC_DOUTB_c(5), DOUTB4 => TFC_DOUTB_c(4), DOUTB3 => 
        TFC_DOUTB_c(3), DOUTB2 => TFC_DOUTB_c(2), DOUTB1 => 
        TFC_DOUTB_c(1), DOUTB0 => TFC_DOUTB_c(0));
    
    VCC_i : VCC
      port map(Y => DPRT_512X9_SRAM_VCC);
    
    GND_i : GND
      port map(Y => DPRT_512X9_SRAM_GND);
    

end DEF_ARCH; 

library ieee;
use ieee.std_logic_1164.all;
library proasic3e;
use proasic3e.all;

entity DPRT_512X9_SRAM_0 is

    port( ELINK0_DOUTB_c       : out   std_logic_vector(7 downto 0);
          ELINK0_ADDRA         : in    std_logic_vector(8 downto 0);
          ELINK0_ADDRB_c       : in    std_logic_vector(8 downto 0);
          ELINK0_DINA          : in    std_logic_vector(7 downto 0);
          ELINK0_BLKA          : in    std_logic;
          ELINK0_PATT_GEN_EN_c : in    std_logic;
          CLK60MHZ_c           : in    std_logic;
          CLK_40MHZ_GEN_c      : in    std_logic;
          RESETB_c             : in    std_logic;
          ELINK0_RWA           : in    std_logic;
          ELINK0_RWB_c         : in    std_logic
        );

end DPRT_512X9_SRAM_0;

architecture DEF_ARCH of DPRT_512X9_SRAM_0 is 

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

  component VCC
    port( Y : out   std_logic
        );
  end component;

  component GND
    port( Y : out   std_logic
        );
  end component;

    signal \DOUTA_1[0]\, \DOUTA_1[1]\, \DOUTA_1[2]\, 
        \DOUTA_1[3]\, \DOUTA_1[4]\, \DOUTA_1[5]\, \DOUTA_1[6]\, 
        \DOUTA_1[7]\, \DOUTA_1[8]\, \DOUTB_1[8]\, 
        DPRT_512X9_SRAM_0_GND, DPRT_512X9_SRAM_0_VCC : std_logic;

begin 


    DPRT_512X9_SRAM_R0C0 : RAM4K9
      generic map(MEMORYFILE => "DPRT_512X9_SRAM_R0C0.mem")

      port map(ADDRA11 => DPRT_512X9_SRAM_0_GND, ADDRA10 => 
        DPRT_512X9_SRAM_0_GND, ADDRA9 => DPRT_512X9_SRAM_0_GND, 
        ADDRA8 => ELINK0_ADDRA(8), ADDRA7 => ELINK0_ADDRA(7), 
        ADDRA6 => ELINK0_ADDRA(6), ADDRA5 => ELINK0_ADDRA(5), 
        ADDRA4 => ELINK0_ADDRA(4), ADDRA3 => ELINK0_ADDRA(3), 
        ADDRA2 => ELINK0_ADDRA(2), ADDRA1 => ELINK0_ADDRA(1), 
        ADDRA0 => ELINK0_ADDRA(0), ADDRB11 => 
        DPRT_512X9_SRAM_0_GND, ADDRB10 => DPRT_512X9_SRAM_0_GND, 
        ADDRB9 => DPRT_512X9_SRAM_0_GND, ADDRB8 => 
        ELINK0_ADDRB_c(8), ADDRB7 => ELINK0_ADDRB_c(7), ADDRB6
         => ELINK0_ADDRB_c(6), ADDRB5 => ELINK0_ADDRB_c(5), 
        ADDRB4 => ELINK0_ADDRB_c(4), ADDRB3 => ELINK0_ADDRB_c(3), 
        ADDRB2 => ELINK0_ADDRB_c(2), ADDRB1 => ELINK0_ADDRB_c(1), 
        ADDRB0 => ELINK0_ADDRB_c(0), DINA8 => 
        DPRT_512X9_SRAM_0_GND, DINA7 => ELINK0_DINA(7), DINA6 => 
        ELINK0_DINA(6), DINA5 => ELINK0_DINA(5), DINA4 => 
        ELINK0_DINA(4), DINA3 => ELINK0_DINA(3), DINA2 => 
        ELINK0_DINA(2), DINA1 => ELINK0_DINA(1), DINA0 => 
        ELINK0_DINA(0), DINB8 => DPRT_512X9_SRAM_0_GND, DINB7 => 
        DPRT_512X9_SRAM_0_GND, DINB6 => DPRT_512X9_SRAM_0_GND, 
        DINB5 => DPRT_512X9_SRAM_0_GND, DINB4 => 
        DPRT_512X9_SRAM_0_GND, DINB3 => DPRT_512X9_SRAM_0_GND, 
        DINB2 => DPRT_512X9_SRAM_0_GND, DINB1 => 
        DPRT_512X9_SRAM_0_GND, DINB0 => DPRT_512X9_SRAM_0_GND, 
        WIDTHA0 => DPRT_512X9_SRAM_0_VCC, WIDTHA1 => 
        DPRT_512X9_SRAM_0_VCC, WIDTHB0 => DPRT_512X9_SRAM_0_VCC, 
        WIDTHB1 => DPRT_512X9_SRAM_0_VCC, PIPEA => 
        DPRT_512X9_SRAM_0_VCC, PIPEB => DPRT_512X9_SRAM_0_VCC, 
        WMODEA => DPRT_512X9_SRAM_0_GND, WMODEB => 
        DPRT_512X9_SRAM_0_GND, BLKA => ELINK0_BLKA, BLKB => 
        ELINK0_PATT_GEN_EN_c, WENA => ELINK0_RWA, WENB => 
        ELINK0_RWB_c, CLKA => CLK60MHZ_c, CLKB => CLK_40MHZ_GEN_c, 
        RESET => RESETB_c, DOUTA8 => \DOUTA_1[8]\, DOUTA7 => 
        \DOUTA_1[7]\, DOUTA6 => \DOUTA_1[6]\, DOUTA5 => 
        \DOUTA_1[5]\, DOUTA4 => \DOUTA_1[4]\, DOUTA3 => 
        \DOUTA_1[3]\, DOUTA2 => \DOUTA_1[2]\, DOUTA1 => 
        \DOUTA_1[1]\, DOUTA0 => \DOUTA_1[0]\, DOUTB8 => 
        \DOUTB_1[8]\, DOUTB7 => ELINK0_DOUTB_c(7), DOUTB6 => 
        ELINK0_DOUTB_c(6), DOUTB5 => ELINK0_DOUTB_c(5), DOUTB4
         => ELINK0_DOUTB_c(4), DOUTB3 => ELINK0_DOUTB_c(3), 
        DOUTB2 => ELINK0_DOUTB_c(2), DOUTB1 => ELINK0_DOUTB_c(1), 
        DOUTB0 => ELINK0_DOUTB_c(0));
    
    VCC_i : VCC
      port map(Y => DPRT_512X9_SRAM_0_VCC);
    
    GND_i : GND
      port map(Y => DPRT_512X9_SRAM_0_GND);
    

end DEF_ARCH; 

library ieee;
use ieee.std_logic_1164.all;
library proasic3e;
use proasic3e.all;

entity USB_INTERFACE is

    port( CLK60MHZ           : in    std_logic;
          RESETB             : in    std_logic;
          CLK_40MHZ_GEN      : in    std_logic;
          USB_ADBUS          : in    std_logic_vector(7 downto 0);
          USB_OE_B           : out   std_logic;
          USB_RXF_B          : in    std_logic;
          USB_RD_B           : out   std_logic;
          USB_TXE_B          : in    std_logic;
          USB_WR_B           : out   std_logic;
          USB_SIWU_B         : out   std_logic;
          P_TFC_STRT_ADDR    : out   std_logic_vector(7 downto 0);
          P_TFC_STOP_ADDR    : out   std_logic_vector(7 downto 0);
          TFC_ADDRB          : in    std_logic_vector(8 downto 0);
          TFC_PATT_GEN_EN    : in    std_logic;
          P_TFC_ADDR8B       : out   std_logic;
          PATT_TFC_DAT       : out   std_logic_vector(7 downto 0);
          TFC_RWB            : in    std_logic;
          P_ELINKS_STRT_ADDR : out   std_logic_vector(7 downto 0);
          P_ELINKS_STOP_ADDR : out   std_logic_vector(7 downto 0);
          ELINK0_ADDRB       : in    std_logic_vector(8 downto 0);
          ELINK0_PATT_GEN_EN : in    std_logic;
          P_ELINK0_ADDR8B    : out   std_logic;
          PATT_ELINK0_DAT    : out   std_logic_vector(7 downto 0);
          ELINK0_RWB         : in    std_logic;
          P_OP_MODE          : out   std_logic_vector(7 downto 0);
          TFC_PG_DONE        : in    std_logic;
          ELINK0_PG_DONE     : in    std_logic
        );

end USB_INTERFACE;

architecture DEF_ARCH of USB_INTERFACE is 

  component DFN1E1C0
    port( D   : in    std_logic := 'U';
          CLK : in    std_logic := 'U';
          CLR : in    std_logic := 'U';
          E   : in    std_logic := 'U';
          Q   : out   std_logic
        );
  end component;

  component OUTBUF
    port( D   : in    std_logic := 'U';
          PAD : out   std_logic
        );
  end component;

  component CLKBUF
    port( PAD : in    std_logic := 'U';
          Y   : out   std_logic
        );
  end component;

  component DFN1C0
    port( D   : in    std_logic := 'U';
          CLK : in    std_logic := 'U';
          CLR : in    std_logic := 'U';
          Q   : out   std_logic
        );
  end component;

  component MX2
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          S : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component AO1A
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          C : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component NOR3C
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          C : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component OR2
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component OR2A
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component NOR2A
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component NOR2B
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component XA1C
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          C : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component DFN1E1P0
    port( D   : in    std_logic := 'U';
          CLK : in    std_logic := 'U';
          PRE : in    std_logic := 'U';
          E   : in    std_logic := 'U';
          Q   : out   std_logic
        );
  end component;

  component NOR3
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          C : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component AOI1B
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          C : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component AO1D
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          C : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component INBUF
    port( PAD : in    std_logic := 'U';
          Y   : out   std_logic
        );
  end component;

  component OA1A
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          C : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component AO1
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          C : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component AOI1
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          C : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component NOR3B
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          C : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component MX2A
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          S : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component OR3A
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          C : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component NOR3A
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          C : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component OR3
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          C : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component DFN1P0
    port( D   : in    std_logic := 'U';
          CLK : in    std_logic := 'U';
          PRE : in    std_logic := 'U';
          Q   : out   std_logic
        );
  end component;

  component OAI1
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          C : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component XNOR2
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component NOR2
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component OA1
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          C : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component MIN3X
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          C : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component GND
    port( Y : out   std_logic
        );
  end component;

  component BUFF
    port( A : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component VCC
    port( Y : out   std_logic
        );
  end component;

  component OR2B
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component DPRT_512X9_SRAM
    port( TFC_DOUTB_c       : out   std_logic_vector(7 downto 0);
          TFC_ADDRA         : in    std_logic_vector(8 downto 0) := (others => 'U');
          TFC_ADDRB_c       : in    std_logic_vector(8 downto 0) := (others => 'U');
          TFC_DINA          : in    std_logic_vector(7 downto 0) := (others => 'U');
          TFC_BLKA          : in    std_logic := 'U';
          TFC_PATT_GEN_EN_c : in    std_logic := 'U';
          CLK60MHZ_c        : in    std_logic := 'U';
          CLK_40MHZ_GEN_c   : in    std_logic := 'U';
          RESETB_c          : in    std_logic := 'U';
          TFC_RWA           : in    std_logic := 'U';
          TFC_RWB_c         : in    std_logic := 'U'
        );
  end component;

  component XA1
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          C : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component DPRT_512X9_SRAM_0
    port( ELINK0_DOUTB_c       : out   std_logic_vector(7 downto 0);
          ELINK0_ADDRA         : in    std_logic_vector(8 downto 0) := (others => 'U');
          ELINK0_ADDRB_c       : in    std_logic_vector(8 downto 0) := (others => 'U');
          ELINK0_DINA          : in    std_logic_vector(7 downto 0) := (others => 'U');
          ELINK0_BLKA          : in    std_logic := 'U';
          ELINK0_PATT_GEN_EN_c : in    std_logic := 'U';
          CLK60MHZ_c           : in    std_logic := 'U';
          CLK_40MHZ_GEN_c      : in    std_logic := 'U';
          RESETB_c             : in    std_logic := 'U';
          ELINK0_RWA           : in    std_logic := 'U';
          ELINK0_RWB_c         : in    std_logic := 'U'
        );
  end component;

  component OA1B
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          C : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component XA1B
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          C : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component OA1C
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          C : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component AO1C
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          C : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component OR3C
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          C : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component INV
    port( A : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component DFN1E0P0
    port( D   : in    std_logic := 'U';
          CLK : in    std_logic := 'U';
          PRE : in    std_logic := 'U';
          E   : in    std_logic := 'U';
          Q   : out   std_logic
        );
  end component;

  component AO1B
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          C : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

    signal \TFC_DINA[0]_net_1\, \TFC_DINA[1]_net_1\, 
        \TFC_DINA[2]_net_1\, \TFC_DINA[3]_net_1\, 
        \TFC_DINA[4]_net_1\, \TFC_DINA[5]_net_1\, 
        \TFC_DINA[6]_net_1\, \TFC_DINA[7]_net_1\, \GND\, 
        \TFC_ADDRA[0]_net_1\, \TFC_ADDRA[1]_net_1\, 
        \TFC_ADDRA[2]_net_1\, \TFC_ADDRA[3]_net_1\, 
        \TFC_ADDRA[4]_net_1\, \TFC_ADDRA[5]_net_1\, 
        \TFC_ADDRA[6]_net_1\, \TFC_ADDRA[7]_net_1\, 
        \TFC_ADDRA[8]_net_1\, \TFC_RWA\, \TFC_BLKA\, 
        \ELINK0_DINA[0]_net_1\, \ELINK0_DINA[1]_net_1\, 
        \ELINK0_DINA[2]_net_1\, \ELINK0_DINA[3]_net_1\, 
        \ELINK0_DINA[4]_net_1\, \ELINK0_DINA[5]_net_1\, 
        \ELINK0_DINA[6]_net_1\, \ELINK0_DINA[7]_net_1\, 
        \ELINK0_ADDRA[0]_net_1\, \ELINK0_ADDRA[1]_net_1\, 
        \ELINK0_ADDRA[2]_net_1\, \ELINK0_ADDRA[3]_net_1\, 
        \ELINK0_ADDRA[4]_net_1\, \ELINK0_ADDRA[5]_net_1\, 
        \ELINK0_ADDRA[6]_net_1\, \ELINK0_ADDRA[7]_net_1\, 
        \ELINK0_ADDRA[8]_net_1\, \ELINK0_RWA\, \ELINK0_BLKA\, 
        \USB_RD_DAT[0]_net_1\, \REG_STATE[20]_net_1\, 
        \REG_STATE[16]_net_1\, \REG_STATE[5]_net_1\, 
        \REG_STATE[19]_net_1\, \REG_STATE[17]_net_1\, 
        \REG_STATE[4]_net_1\, \REG_STATE[11]_net_1\, 
        \REG_STATE[12]_net_1\, \REG_STATE[15]_net_1\, 
        \REG_STATE[13]_net_1\, \REG_STATE[14]_net_1\, 
        \USB_RD_ACTIVE\, \REG_ADDR[0]_net_1\, \REG_ADDR[1]_net_1\, 
        \REG_ADDR[2]_net_1\, \REG_ADDR[3]_net_1\, 
        \REG_ADDR[4]_net_1\, \REG_ADDR[5]_net_1\, 
        \REG_ADDR[6]_net_1\, \REG_ADDR[7]_net_1\, 
        \REG_STATE[10]_net_1\, \REG_STATE[2]_net_1\, 
        \USB_RD_DAT[1]_net_1\, \USB_RD_DAT[3]_net_1\, 
        \USB_RD_DAT[5]_net_1\, \USB_RD_DAT[7]_net_1\, 
        \REG_STATE[18]_net_1\, \RET_STATE[20]_net_1\, 
        \RET_STATE[17]_net_1\, \RET_STATE[16]_net_1\, 
        \RET_STATE[15]_net_1\, \RET_STATE[14]_net_1\, 
        \RET_STATE[13]_net_1\, \RET_STATE[12]_net_1\, N_192_i_1, 
        \RET_STATE[5]_net_1\, \RET_STATE[4]_net_1\, 
        \REG_STATE[3]_net_1\, \REG_STATE[1]_net_1\, REG_ADDRe, 
        \TFC_RWA_RNO\, \ELINK0_RWA_RNO\, \USB_RD_ACTIVE_RNO\, 
        \RET_STATE_RNO[17]_net_1\, \RET_STATE_RNO[15]_net_1\, 
        \RET_STATE_RNO[14]_net_1\, \RET_STATE_RNO[13]_net_1\, 
        \RET_STATE_RNO[11]_net_1\, \RET_STATE_RNO[10]_net_1\, 
        \RET_STATE_RNO[5]_net_1\, \RET_STATE_RNO[4]_net_1\, 
        \REG_STATE_ns[3]\, \REG_STATE_ns[4]\, \REG_STATE_ns[5]\, 
        \REG_STATE_ns[6]\, \REG_STATE_ns[7]\, \REG_STATE_ns[8]\, 
        \REG_STATE_ns[9]\, \REG_STATE_ns[10]\, \REG_STATE_ns[15]\, 
        \REG_STATE_ns[16]\, \REG_STATE_ns[17]\, 
        \REG_STATE_RNO[20]_net_1\, \REG_STATE_RNO[19]_net_1\, 
        \RET_STATE_RNO[16]_net_1\, N_OP_MODE_T_0_sqmuxa, 
        N_TFC_RWA_0_sqmuxa, N_ELINK0_RWA_0_sqmuxa, N_252, 
        \USB_RD_DAT_RNO[1]_net_1\, \USB_RD_DAT_RNO[2]_net_1\, 
        \USB_RD_DAT_RNO[3]_net_1\, \USB_RD_DAT_RNO[4]_net_1\, 
        N_29, N_31, N_33, N_44, N_48, N_57, N_250, N_74, N_128, 
        N_134, N_179, N_124, N_130, N_181, N_239, N_872, N_1225, 
        N_272, N_277, N_1482, N_1388, N_1464, N_293, N_1189, 
        N_1431, N_171, N_164, N_317, N_1454, N_1435, N_888_i_0, 
        N_1458, N_889_i_0, N_151, N_127, N_1558, N_1554, N_1551, 
        CLK60MHZ_c, RESETB_c, CLK_40MHZ_GEN_c, \USB_ADBUS_c[0]\, 
        \USB_ADBUS_c[1]\, \USB_ADBUS_c[2]\, \USB_ADBUS_c[3]\, 
        \USB_ADBUS_c[4]\, \USB_ADBUS_c[5]\, \USB_ADBUS_c[6]\, 
        \USB_ADBUS_c[7]\, USB_OE_BI_c, USB_RXF_B_c, USB_RD_BI_c, 
        USB_TXE_B_c, \VCC\, \TFC_STRT_ADDR_c[0]\, 
        \TFC_STRT_ADDR_c[1]\, \TFC_STRT_ADDR_c[2]\, 
        \TFC_STRT_ADDR_c[3]\, \TFC_STRT_ADDR_c[4]\, 
        \TFC_STRT_ADDR_c[5]\, \TFC_STRT_ADDR_c[6]\, 
        \TFC_STRT_ADDR_c[7]\, \TFC_STOP_ADDR_c[0]\, 
        \TFC_STOP_ADDR_c[1]\, \TFC_STOP_ADDR_c[2]\, 
        \TFC_STOP_ADDR_c[3]\, \TFC_STOP_ADDR_c[4]\, 
        \TFC_STOP_ADDR_c[5]\, \TFC_STOP_ADDR_c[6]\, 
        \TFC_STOP_ADDR_c[7]\, \TFC_ADDRB_c[0]\, \TFC_ADDRB_c[1]\, 
        \TFC_ADDRB_c[2]\, \TFC_ADDRB_c[3]\, \TFC_ADDRB_c[4]\, 
        \TFC_ADDRB_c[5]\, \TFC_ADDRB_c[6]\, \TFC_ADDRB_c[7]\, 
        \TFC_ADDRB_c[8]\, TFC_PATT_GEN_EN_c, TFC_ADDR8B_c, 
        \TFC_DOUTB_c[0]\, \TFC_DOUTB_c[1]\, \TFC_DOUTB_c[2]\, 
        \TFC_DOUTB_c[3]\, \TFC_DOUTB_c[4]\, \TFC_DOUTB_c[5]\, 
        \TFC_DOUTB_c[6]\, \TFC_DOUTB_c[7]\, TFC_RWB_c, 
        \ELINKS_STRT_ADDR_c[0]\, \ELINKS_STRT_ADDR_c[1]\, 
        \ELINKS_STRT_ADDR_c[2]\, \ELINKS_STRT_ADDR_c[3]\, 
        \ELINKS_STRT_ADDR_c[4]\, \ELINKS_STRT_ADDR_c[5]\, 
        \ELINKS_STRT_ADDR_c[6]\, \ELINKS_STRT_ADDR_c[7]\, 
        \ELINKS_STOP_ADDR_c[0]\, \ELINKS_STOP_ADDR_c[1]\, 
        \ELINKS_STOP_ADDR_c[2]\, \ELINKS_STOP_ADDR_c[3]\, 
        \ELINKS_STOP_ADDR_c[4]\, \ELINKS_STOP_ADDR_c[5]\, 
        \ELINKS_STOP_ADDR_c[6]\, \ELINKS_STOP_ADDR_c[7]\, 
        \ELINK0_ADDRB_c[0]\, \ELINK0_ADDRB_c[1]\, 
        \ELINK0_ADDRB_c[2]\, \ELINK0_ADDRB_c[3]\, 
        \ELINK0_ADDRB_c[4]\, \ELINK0_ADDRB_c[5]\, 
        \ELINK0_ADDRB_c[6]\, \ELINK0_ADDRB_c[7]\, 
        \ELINK0_ADDRB_c[8]\, ELINK0_PATT_GEN_EN_c, 
        ELINK0_ADDR8B_c, \ELINK0_DOUTB_c[0]\, \ELINK0_DOUTB_c[1]\, 
        \ELINK0_DOUTB_c[2]\, \ELINK0_DOUTB_c[3]\, 
        \ELINK0_DOUTB_c[4]\, \ELINK0_DOUTB_c[5]\, 
        \ELINK0_DOUTB_c[6]\, \ELINK0_DOUTB_c[7]\, ELINK0_RWB_c, 
        \OP_MODE_c[0]\, \OP_MODE_c[1]\, \OP_MODE_c[2]\, 
        \OP_MODE_c[3]\, \OP_MODE_c[4]\, \OP_MODE_c[5]\, 
        \OP_MODE_c[6]\, \OP_MODE_c[7]\, N_307, N_1405, N_304, 
        un1_REG_STATE_23, N_1428, N_1407, N_1420, N_1524, N_828, 
        N_437, N_170, N_1533_2, N_153, N_217, N_161, N_280, N_279, 
        N_162, N_138, N_125, N_ELINKS_STRT_ADDR_T_0_sqmuxa, N_27, 
        N_25, N_19, N_17, N_15, N_129, N_1404, N_1403, N_290, 
        N_23, N_21, N_248, N_154, N_305, N_830, un1_REG_STATE_22, 
        N_5, N_73, N_180, N_219, N_220, N_1457, N_258_2, N_292, 
        N_TFC_STRT_ADDR_T_0_sqmuxa, N_85, N_146, N_314, N_234, 
        N_119, N_TFC_BLKA, N_769, N_771, N_276, N_278, N_274, 
        N_218, N_TFC_STOP_ADDR_T_0_sqmuxa, N_1488, N_68, N_69, 
        N_84, N_65, N_71, N_1536, N_308, N_309, N_186, N_1414, 
        N_313, N_1413, N_222, N_221, un1_REG_STATE_22_0_0_a2_0_2, 
        N_61, un1_REG_STATE_22_0_0_a2_0_0, 
        un1_REG_STATE_22_0_0_a2_0_1, 
        un1_REG_STATE_22_0_0_a2_0_2_0, N_USB_RD_BI_i_0_a2_2_1, 
        N_USB_RD_BI_i_0_a2_2_3, N_USB_RD_BI_i_0_a2_2_4, 
        N_USB_RD_BI_i_0_a2_2_5, \REG_STATE_ns_0_a2_3_0[15]\, 
        \REG_STATE_ns_0_a2_0_0[15]\, \REG_STATE_ns_0_a2_1[5]\, 
        N_USB_RD_BI_i_0_a2_0_1, RET_STATE_161_0_0_a2_0, 
        RET_STATE_163_i_i_a2_0_0, N_USB_OE_BI_i_0_0, 
        \REG_STATE_ns_a2_2_0_a2_0[2]\, RET_STATE_170_0_0_a2_1, 
        RET_STATE_171_0_0_a2_1, \REG_STATE_ns_i_0_a2_0[1]\, 
        \REG_STATE_ns_i_0_a2_2[1]\, \REG_STATE_ns_i_0_a2_3[1]\, 
        RET_STATE_164_0_0_a2_0, RET_STATE_165_0_0_a2_0, 
        RET_STATE_158_0_0_a2_0, RET_STATE_162_0_0_a2_0, 
        RET_STATE_163_i_i_a2_1_0, RET_STATE_160_0_0_a2_0, N_1439, 
        \REG_STATE_ns_i_0_a2_4_1[1]\, 
        \REG_STATE_ns_i_0_a2_27_0[0]\, \REG_STATE_ns_0_a2_1[8]\, 
        \REG_STATE_ns_0_a2_2[8]\, \REG_STATE_ns_0_a2_0_1[7]\, 
        \REG_STATE_ns_0_a2_0_2[7]\, \REG_STATE_ns_i_0_a2_2_0[1]\, 
        \REG_STATE_ns_0_a2_0_0[4]\, RET_STATE_163_i_i_0, 
        \REG_STATE_ns_0_a2_0[3]\, \REG_STATE_ns_0_a2_1[3]\, 
        \REG_STATE_ns_0_a2_0_1[6]\, \REG_STATE_ns_0_a2_0_2[6]\, 
        \REG_STATE_ns_i_0_a2_9_0[1]\, 
        \REG_STATE_ns_i_0_o2_7_0[0]\, \REG_STATE_ns_a2_0_a2_1[9]\, 
        \REG_STATE_ns_i_0_o2_5_0[0]\, \REG_STATE_ns_i_0_0[1]\, 
        \REG_STATE_ns_i_0_1[1]\, \REG_STATE_ns_i_0_3[1]\, 
        N_USB_RD_BI_i_0_a2_0, \REG_STATE_ns_0_a2_0[10]\, 
        un1_REG_STATE_23_0_0_a2_0, un1_REG_STATE_22_0_0_a2_1, 
        \REG_STATE_ns_i_0_a2_12_1[0]\, \REG_STATE_ns_i_0_1[0]\, 
        \USB_RD_DAT_i_0[6]\, \USB_RD_DAT_i_0[4]\, 
        \USB_RD_DAT_i_0[2]\, ELINK0_ADDR8B_c_i, TFC_ADDR8B_c_i, 
        N_1434, N_165, N_303, \REG_STATE_ns_i_0_6[0]\, N_1418, 
        N_1417, N_93, N_315, \REG_STATE_ns_i_0_a2_12_3[0]\, 
        \REG_STATE_ns_i_0_3[0]\, \REG_STATE_ns_i_0_4[0]\, 
        USB_RXF_B_c_0 : std_logic;

    for all : DPRT_512X9_SRAM
	Use entity work.DPRT_512X9_SRAM(DEF_ARCH);
    for all : DPRT_512X9_SRAM_0
	Use entity work.DPRT_512X9_SRAM_0(DEF_ARCH);
begin 


    \ELINK0_ADDRA[4]\ : DFN1E1C0
      port map(D => \REG_ADDR[4]_net_1\, CLK => CLK60MHZ_c, CLR
         => RESETB_c, E => N_ELINK0_RWA_0_sqmuxa, Q => 
        \ELINK0_ADDRA[4]_net_1\);
    
    \P_TFC_STRT_ADDR_pad[1]\ : OUTBUF
      port map(D => \TFC_STRT_ADDR_c[1]\, PAD => 
        P_TFC_STRT_ADDR(1));
    
    \P_ELINKS_STRT_ADDR_pad[3]\ : OUTBUF
      port map(D => \ELINKS_STRT_ADDR_c[3]\, PAD => 
        P_ELINKS_STRT_ADDR(3));
    
    RESETB_pad : CLKBUF
      port map(PAD => RESETB, Y => RESETB_c);
    
    \REG_STATE[3]\ : DFN1C0
      port map(D => \REG_STATE_ns[17]\, CLK => CLK60MHZ_c, CLR
         => RESETB_c, Q => \REG_STATE[3]_net_1\);
    
    \TFC_ADDRA[8]\ : DFN1E1C0
      port map(D => TFC_ADDR8B_c_i, CLK => CLK60MHZ_c, CLR => 
        RESETB_c, E => N_TFC_RWA_0_sqmuxa, Q => 
        \TFC_ADDRA[8]_net_1\);
    
    \RET_STATE[4]\ : DFN1C0
      port map(D => \RET_STATE_RNO[4]_net_1\, CLK => CLK60MHZ_c, 
        CLR => RESETB_c, Q => \RET_STATE[4]_net_1\);
    
    \REG_STATE[11]\ : DFN1C0
      port map(D => \REG_STATE_ns[9]\, CLK => CLK60MHZ_c, CLR => 
        RESETB_c, Q => \REG_STATE[11]_net_1\);
    
    P_TFC_ADDR8B_pad : OUTBUF
      port map(D => TFC_ADDR8B_c, PAD => P_TFC_ADDR8B);
    
    \USB_RD_DAT_RNO[1]\ : MX2
      port map(A => \USB_ADBUS_c[1]\, B => \USB_RD_DAT[1]_net_1\, 
        S => N_61, Y => \USB_RD_DAT_RNO[1]_net_1\);
    
    \USB_RD_DAT_RNO[0]\ : MX2
      port map(A => \USB_ADBUS_c[0]\, B => \USB_RD_DAT[0]_net_1\, 
        S => N_61, Y => N_44);
    
    \RET_STATE_RNO[5]\ : AO1A
      port map(A => N_57, B => RET_STATE_170_0_0_a2_1, C => N_221, 
        Y => \RET_STATE_RNO[5]_net_1\);
    
    \ELINK0_DINA[6]\ : DFN1E1C0
      port map(D => \USB_ADBUS_c[6]\, CLK => CLK60MHZ_c, CLR => 
        RESETB_c, E => N_ELINK0_RWA_0_sqmuxa, Q => 
        \ELINK0_DINA[6]_net_1\);
    
    \REG_STATE_RNO_15[20]\ : NOR3C
      port map(A => N_1457, B => N_1435, C => N_119, Y => N_317);
    
    \REG_STATE_RNIJDEE2[19]\ : OR2
      port map(A => \REG_STATE[19]_net_1\, B => N_154, Y => 
        \REG_STATE_ns_i_0_o2_5_0[0]\);
    
    \P_ELINKS_STOP_ADDR_pad[1]\ : OUTBUF
      port map(D => \ELINKS_STOP_ADDR_c[1]\, PAD => 
        P_ELINKS_STOP_ADDR(1));
    
    \REG_ADDR_RNI6EUD[3]\ : OR2A
      port map(A => \REG_ADDR[3]_net_1\, B => N_128, Y => N_129);
    
    \REG_STATE_RNO_2[13]\ : NOR2A
      port map(A => \RET_STATE[13]_net_1\, B => 
        \RET_STATE[15]_net_1\, Y => \REG_STATE_ns_0_a2_0_1[7]\);
    
    \P_OP_MODE_pad[4]\ : OUTBUF
      port map(D => \OP_MODE_c[4]\, PAD => P_OP_MODE(4));
    
    \RET_STATE_RNO_2[12]\ : NOR2B
      port map(A => RET_STATE_163_i_i_a2_0_0, B => N_250, Y => 
        N_1536);
    
    \REG_ADDR_RNO[2]\ : XA1C
      port map(A => N_125, B => \REG_ADDR[2]_net_1\, C => 
        \REG_STATE[20]_net_1\, Y => N_25);
    
    \P_ELINKS_STRT_ADDR_pad[7]\ : OUTBUF
      port map(D => \ELINKS_STRT_ADDR_c[7]\, PAD => 
        P_ELINKS_STRT_ADDR(7));
    
    ELINK0_BLKA : DFN1E1P0
      port map(D => N_TFC_BLKA, CLK => CLK60MHZ_c, PRE => 
        RESETB_c, E => N_769, Q => \ELINK0_BLKA\);
    
    \P_TFC_STOP_ADDR_pad[0]\ : OUTBUF
      port map(D => \TFC_STOP_ADDR_c[0]\, PAD => 
        P_TFC_STOP_ADDR(0));
    
    \OP_MODE[4]\ : DFN1C0
      port map(D => \OP_MODE_c[4]\, CLK => CLK60MHZ_c, CLR => 
        RESETB_c, Q => \OP_MODE_c[4]\);
    
    \P_TFC_STOP_ADDR_pad[5]\ : OUTBUF
      port map(D => \TFC_STOP_ADDR_c[5]\, PAD => 
        P_TFC_STOP_ADDR(5));
    
    \ELINK0_ADDRA[6]\ : DFN1E1C0
      port map(D => \REG_ADDR[6]_net_1\, CLK => CLK60MHZ_c, CLR
         => RESETB_c, E => N_ELINK0_RWA_0_sqmuxa, Q => 
        \ELINK0_ADDRA[6]_net_1\);
    
    \REG_STATE_RNO_0[16]\ : NOR2A
      port map(A => N_1558, B => \REG_STATE[17]_net_1\, Y => 
        \REG_STATE_ns_0_a2_0_0[4]\);
    
    \REG_STATE_RNO[19]\ : NOR3
      port map(A => \REG_STATE_ns_i_0_3[1]\, B => N_1414, C => 
        N_1413, Y => \REG_STATE_RNO[19]_net_1\);
    
    \RET_STATE_RNO[20]\ : AOI1B
      port map(A => N_74, B => USB_RXF_B_c, C => 
        \RET_STATE[20]_net_1\, Y => N_252);
    
    \REG_STATE_RNO_10[19]\ : AO1D
      port map(A => \REG_STATE[1]_net_1\, B => 
        \REG_STATE[20]_net_1\, C => USB_RXF_B_c_0, Y => 
        \REG_STATE_ns_i_0_0[1]\);
    
    \REG_ADDR_RNIFRTK[5]\ : OR2A
      port map(A => \REG_ADDR[5]_net_1\, B => N_134, Y => N_138);
    
    \USB_ADBUS_pad[4]\ : INBUF
      port map(PAD => USB_ADBUS(4), Y => \USB_ADBUS_c[4]\);
    
    \REG_STATE_RNO_2[5]\ : OA1A
      port map(A => \REG_ADDR[7]_net_1\, B => N_162, C => 
        N_TFC_RWA_0_sqmuxa, Y => N_279);
    
    \P_TFC_STRT_ADDR_pad[4]\ : OUTBUF
      port map(D => \TFC_STRT_ADDR_c[4]\, PAD => 
        P_TFC_STRT_ADDR(4));
    
    \RET_STATE_RNO[14]\ : AO1
      port map(A => RET_STATE_161_0_0_a2_0, B => N_250, C => N_85, 
        Y => \RET_STATE_RNO[14]_net_1\);
    
    USB_RD_BI_RNO : AOI1
      port map(A => N_USB_RD_BI_i_0_a2_0, B => N_151, C => N_1524, 
        Y => N_828);
    
    \REG_STATE[1]\ : DFN1C0
      port map(D => \REG_STATE[2]_net_1\, CLK => CLK60MHZ_c, CLR
         => RESETB_c, Q => \REG_STATE[1]_net_1\);
    
    \ELINKS_STRT_ADDR[4]\ : DFN1C0
      port map(D => \ELINKS_STRT_ADDR_c[4]\, CLK => CLK60MHZ_c, 
        CLR => RESETB_c, Q => \ELINKS_STRT_ADDR_c[4]\);
    
    \USB_RD_DAT_RNO[7]\ : MX2
      port map(A => \USB_ADBUS_c[7]\, B => \USB_RD_DAT[7]_net_1\, 
        S => N_61, Y => N_33);
    
    \REG_STATE_RNO_6[20]\ : NOR3B
      port map(A => USB_TXE_B_c, B => N_192_i_1, C => N_74, Y => 
        N_305);
    
    \USB_RD_DAT_RNO[2]\ : MX2A
      port map(A => \USB_ADBUS_c[2]\, B => \USB_RD_DAT_i_0[2]\, S
         => N_61, Y => \USB_RD_DAT_RNO[2]_net_1\);
    
    \RET_STATE_RNI5CI5A[11]\ : OR3A
      port map(A => N_165, B => N_303, C => N_304, Y => N_93);
    
    \ELINKS_STOP_ADDR[0]\ : DFN1C0
      port map(D => \ELINKS_STOP_ADDR_c[0]\, CLK => CLK60MHZ_c, 
        CLR => RESETB_c, Q => \ELINKS_STOP_ADDR_c[0]\);
    
    \TFC_DINA[1]\ : DFN1E1C0
      port map(D => \USB_ADBUS_c[1]\, CLK => CLK60MHZ_c, CLR => 
        RESETB_c, E => N_TFC_RWA_0_sqmuxa, Q => 
        \TFC_DINA[1]_net_1\);
    
    \PATT_ELINK0_DAT_pad[4]\ : OUTBUF
      port map(D => \ELINK0_DOUTB_c[4]\, PAD => 
        PATT_ELINK0_DAT(4));
    
    \REG_STATE_RNO_0[11]\ : NOR3A
      port map(A => N_124, B => N_192_i_1, C => 
        \REG_STATE[12]_net_1\, Y => \REG_STATE_ns_a2_0_a2_1[9]\);
    
    \REG_STATE_RNO[5]\ : OR3
      port map(A => N_1388, B => N_280, C => N_279, Y => 
        \REG_STATE_ns[15]\);
    
    \RET_STATE_RNO[17]\ : AO1A
      port map(A => N_1488, B => RET_STATE_158_0_0_a2_0, C => 
        N_217, Y => \RET_STATE_RNO[17]_net_1\);
    
    \RET_STATE_RNO[10]\ : AO1
      port map(A => RET_STATE_165_0_0_a2_0, B => N_258_2, C => 
        N_220, Y => \RET_STATE_RNO[10]_net_1\);
    
    \P_TFC_STOP_ADDR_pad[2]\ : OUTBUF
      port map(D => \TFC_STOP_ADDR_c[2]\, PAD => 
        P_TFC_STOP_ADDR(2));
    
    \ELINKS_STRT_ADDR[7]\ : DFN1C0
      port map(D => \ELINKS_STRT_ADDR_c[7]\, CLK => CLK60MHZ_c, 
        CLR => RESETB_c, Q => \ELINKS_STRT_ADDR_c[7]\);
    
    \PATT_ELINK0_DAT_pad[2]\ : OUTBUF
      port map(D => \ELINK0_DOUTB_c[2]\, PAD => 
        PATT_ELINK0_DAT(2));
    
    \ELINKS_STOP_ADDR[2]\ : DFN1C0
      port map(D => \ELINKS_STOP_ADDR_c[2]\, CLK => CLK60MHZ_c, 
        CLR => RESETB_c, Q => \ELINKS_STOP_ADDR_c[2]\);
    
    USB_RXF_B_pad_RNIRP7F1 : AO1A
      port map(A => USB_RXF_B_c, B => N_180, C => 
        \REG_STATE[20]_net_1\, Y => REG_ADDRe);
    
    \ELINKS_STOP_ADDR[3]\ : DFN1C0
      port map(D => \ELINKS_STOP_ADDR_c[3]\, CLK => CLK60MHZ_c, 
        CLR => RESETB_c, Q => \ELINKS_STOP_ADDR_c[3]\);
    
    \ELINK0_DINA[7]\ : DFN1E1C0
      port map(D => \USB_ADBUS_c[7]\, CLK => CLK60MHZ_c, CLR => 
        RESETB_c, E => N_ELINK0_RWA_0_sqmuxa, Q => 
        \ELINK0_DINA[7]_net_1\);
    
    \USB_RD_DAT[6]\ : DFN1P0
      port map(D => N_31, CLK => CLK60MHZ_c, PRE => RESETB_c, Q
         => \USB_RD_DAT_i_0[6]\);
    
    \TFC_STOP_ADDR[1]\ : DFN1C0
      port map(D => \TFC_STOP_ADDR_c[1]\, CLK => CLK60MHZ_c, CLR
         => RESETB_c, Q => \TFC_STOP_ADDR_c[1]\);
    
    \REG_STATE_RNO_8[20]\ : NOR3A
      port map(A => N_234, B => N_5, C => 
        \REG_STATE_ns_i_0_o2_5_0[0]\, Y => N_314);
    
    \P_ELINKS_STOP_ADDR_pad[2]\ : OUTBUF
      port map(D => \ELINKS_STOP_ADDR_c[2]\, PAD => 
        P_ELINKS_STOP_ADDR(2));
    
    \ELINK0_DINA[4]\ : DFN1E1C0
      port map(D => \USB_ADBUS_c[4]\, CLK => CLK60MHZ_c, CLR => 
        RESETB_c, E => N_ELINK0_RWA_0_sqmuxa, Q => 
        \ELINK0_DINA[4]_net_1\);
    
    USB_RXF_B_pad : INBUF
      port map(PAD => USB_RXF_B, Y => USB_RXF_B_c);
    
    \USB_ADBUS_pad_RNI2I08[0]\ : OAI1
      port map(A => \USB_ADBUS_c[1]\, B => \USB_ADBUS_c[5]\, C
         => \USB_ADBUS_c[0]\, Y => un1_REG_STATE_22_0_0_a2_0_2);
    
    \TFC_STOP_ADDR[7]\ : DFN1C0
      port map(D => \TFC_STOP_ADDR_c[7]\, CLK => CLK60MHZ_c, CLR
         => RESETB_c, Q => \TFC_STOP_ADDR_c[7]\);
    
    \REG_STATE_RNIPG2O[5]\ : NOR2A
      port map(A => \REG_STATE[5]_net_1\, B => USB_RXF_B_c, Y => 
        N_TFC_RWA_0_sqmuxa);
    
    \REG_STATE_RNO_7[20]\ : XNOR2
      port map(A => \RET_STATE[5]_net_1\, B => 
        \RET_STATE[4]_net_1\, Y => N_170);
    
    \REG_STATE_RNO_14[20]\ : NOR3B
      port map(A => \REG_STATE_ns_i_0_a2_12_1[0]\, B => N_165, C
         => N_308, Y => \REG_STATE_ns_i_0_a2_12_3[0]\);
    
    \P_TFC_STRT_ADDR_pad[2]\ : OUTBUF
      port map(D => \TFC_STRT_ADDR_c[2]\, PAD => 
        P_TFC_STRT_ADDR(2));
    
    \REG_ADDR_RNILJDO[6]\ : OR2A
      port map(A => \REG_ADDR[6]_net_1\, B => N_138, Y => N_162);
    
    \RET_STATE_RNO_0[13]\ : NOR2A
      port map(A => \RET_STATE[13]_net_1\, B => 
        \REG_STATE[17]_net_1\, Y => RET_STATE_162_0_0_a2_0);
    
    \REG_STATE_RNO_0[14]\ : NOR3A
      port map(A => \REG_STATE_ns_0_a2_0_1[6]\, B => 
        \RET_STATE[17]_net_1\, C => \REG_STATE[15]_net_1\, Y => 
        \REG_STATE_ns_0_a2_0_2[6]\);
    
    \OP_MODE[0]\ : DFN1C0
      port map(D => \OP_MODE_c[0]\, CLK => CLK60MHZ_c, CLR => 
        RESETB_c, Q => \OP_MODE_c[0]\);
    
    \USB_ADBUS_pad_RNIKPBD[4]\ : NOR3A
      port map(A => un1_REG_STATE_22_0_0_a2_0_2, B => 
        \USB_ADBUS_c[6]\, C => \USB_ADBUS_c[4]\, Y => 
        un1_REG_STATE_22_0_0_a2_0_1);
    
    \TFC_STRT_ADDR[2]\ : DFN1C0
      port map(D => \TFC_STRT_ADDR_c[2]\, CLK => CLK60MHZ_c, CLR
         => RESETB_c, Q => \TFC_STRT_ADDR_c[2]\);
    
    \TFC_ADDRB_pad[0]\ : INBUF
      port map(PAD => TFC_ADDRB(0), Y => \TFC_ADDRB_c[0]\);
    
    \OP_MODE[6]\ : DFN1C0
      port map(D => \OP_MODE_c[6]\, CLK => CLK60MHZ_c, CLR => 
        RESETB_c, Q => \OP_MODE_c[6]\);
    
    \REG_STATE_RNO_0[15]\ : NOR3B
      port map(A => \USB_ADBUS_c[0]\, B => N_1454, C => 
        \USB_ADBUS_c[1]\, Y => \REG_STATE_ns_0_a2_1[5]\);
    
    \TFC_STOP_ADDR[6]\ : DFN1C0
      port map(D => \TFC_STOP_ADDR_c[6]\, CLK => CLK60MHZ_c, CLR
         => RESETB_c, Q => \TFC_STOP_ADDR_c[6]\);
    
    \USB_ADBUS_pad_RNII7B5[3]\ : NOR2
      port map(A => \USB_ADBUS_c[7]\, B => \USB_ADBUS_c[3]\, Y
         => N_1435);
    
    USB_RD_BI_RNO_1 : NOR2
      port map(A => \REG_STATE[18]_net_1\, B => 
        \REG_STATE[20]_net_1\, Y => N_USB_RD_BI_i_0_a2_0);
    
    \REG_STATE_RNO_1[19]\ : NOR3B
      port map(A => \RET_STATE[5]_net_1\, B => N_313, C => 
        \RET_STATE[4]_net_1\, Y => N_1414);
    
    \REG_ADDR[1]\ : DFN1E1C0
      port map(D => N_27, CLK => CLK60MHZ_c, CLR => RESETB_c, E
         => REG_ADDRe, Q => \REG_ADDR[1]_net_1\);
    
    \ELINKS_STOP_ADDR[5]\ : DFN1C0
      port map(D => \ELINKS_STOP_ADDR_c[5]\, CLK => CLK60MHZ_c, 
        CLR => RESETB_c, Q => \ELINKS_STOP_ADDR_c[5]\);
    
    \ELINK0_ADDRB_pad[4]\ : INBUF
      port map(PAD => ELINK0_ADDRB(4), Y => \ELINK0_ADDRB_c[4]\);
    
    \TFC_ADDRA[2]\ : DFN1E1C0
      port map(D => \REG_ADDR[2]_net_1\, CLK => CLK60MHZ_c, CLR
         => RESETB_c, E => N_TFC_RWA_0_sqmuxa, Q => 
        \TFC_ADDRA[2]_net_1\);
    
    \REG_ADDR_RNI3PEA[2]\ : OR2A
      port map(A => \REG_ADDR[2]_net_1\, B => N_125, Y => N_128);
    
    \REG_STATE_RNO_2[12]\ : NOR2A
      port map(A => \RET_STATE[12]_net_1\, B => 
        \RET_STATE[15]_net_1\, Y => \REG_STATE_ns_0_a2_1[8]\);
    
    USB_RD_BI_RNO_3 : NOR3
      port map(A => \REG_STATE[20]_net_1\, B => 
        \REG_STATE[1]_net_1\, C => \REG_STATE[18]_net_1\, Y => 
        un1_REG_STATE_23_0_0_a2_0);
    
    USB_OE_BI_RNO_0 : OA1
      port map(A => N_151, B => N_1554, C => 
        un1_REG_STATE_22_0_0_a2_1, Y => un1_REG_STATE_22);
    
    \REG_STATE[12]\ : DFN1C0
      port map(D => \REG_STATE_ns[8]\, CLK => CLK60MHZ_c, CLR => 
        RESETB_c, Q => \REG_STATE[12]_net_1\);
    
    \REG_ADDR_RNO[4]\ : XA1C
      port map(A => \REG_ADDR[4]_net_1\, B => N_129, C => 
        \REG_STATE[20]_net_1\, Y => N_21);
    
    \P_OP_MODE_pad[1]\ : OUTBUF
      port map(D => \OP_MODE_c[1]\, PAD => P_OP_MODE(1));
    
    \USB_ADBUS_pad[7]\ : INBUF
      port map(PAD => USB_ADBUS(7), Y => \USB_ADBUS_c[7]\);
    
    \RET_STATE_RNO[15]\ : AO1A
      port map(A => N_71, B => RET_STATE_160_0_0_a2_0, C => N_84, 
        Y => \RET_STATE_RNO[15]_net_1\);
    
    \REG_STATE_RNO[18]\ : NOR2A
      port map(A => \REG_STATE[19]_net_1\, B => USB_RXF_B_c, Y
         => N_293);
    
    \REG_STATE_RNO_18[20]\ : MIN3X
      port map(A => \USB_ADBUS_c[0]\, B => \USB_ADBUS_c[1]\, C
         => \USB_ADBUS_c[5]\, Y => N_119);
    
    \P_ELINKS_STOP_ADDR_pad[6]\ : OUTBUF
      port map(D => \ELINKS_STOP_ADDR_c[6]\, PAD => 
        P_ELINKS_STOP_ADDR(6));
    
    \USB_RD_DAT_RNO[4]\ : MX2A
      port map(A => \USB_ADBUS_c[4]\, B => \USB_RD_DAT_i_0[4]\, S
         => N_61, Y => \USB_RD_DAT_RNO[4]_net_1\);
    
    \USB_RD_DAT[5]\ : DFN1C0
      port map(D => N_29, CLK => CLK60MHZ_c, CLR => RESETB_c, Q
         => \USB_RD_DAT[5]_net_1\);
    
    \RET_STATE[13]\ : DFN1C0
      port map(D => \RET_STATE_RNO[13]_net_1\, CLK => CLK60MHZ_c, 
        CLR => RESETB_c, Q => \RET_STATE[13]_net_1\);
    
    \P_ELINKS_STOP_ADDR_pad[5]\ : OUTBUF
      port map(D => \ELINKS_STOP_ADDR_c[5]\, PAD => 
        P_ELINKS_STOP_ADDR(5));
    
    \TFC_STRT_ADDR[6]\ : DFN1C0
      port map(D => \TFC_STRT_ADDR_c[6]\, CLK => CLK60MHZ_c, CLR
         => RESETB_c, Q => \TFC_STRT_ADDR_c[6]\);
    
    \REG_STATE_RNINDR52[13]\ : OR2
      port map(A => N_65, B => N_69, Y => N_71);
    
    \RET_STATE_RNO_0[4]\ : NOR3A
      port map(A => \RET_STATE[4]_net_1\, B => 
        \REG_STATE[5]_net_1\, C => N_181, Y => 
        RET_STATE_171_0_0_a2_1);
    
    USB_RD_BI_RNO_0 : OA1
      port map(A => N_151, B => N_1554, C => 
        un1_REG_STATE_23_0_0_a2_0, Y => un1_REG_STATE_23);
    
    \REG_STATE_RNI80M34[1]\ : NOR2B
      port map(A => N_146, B => \REG_STATE[1]_net_1\, Y => N_437);
    
    \REG_ADDR[6]\ : DFN1E1C0
      port map(D => N_17, CLK => CLK60MHZ_c, CLR => RESETB_c, E
         => REG_ADDRe, Q => \REG_ADDR[6]_net_1\);
    
    \P_ELINKS_STOP_ADDR_pad[4]\ : OUTBUF
      port map(D => \ELINKS_STOP_ADDR_c[4]\, PAD => 
        P_ELINKS_STOP_ADDR(4));
    
    \USB_ADBUS_pad_RNI49FB[2]\ : NOR2
      port map(A => \USB_ADBUS_c[2]\, B => USB_RXF_B_c, Y => 
        un1_REG_STATE_22_0_0_a2_0_0);
    
    \TFC_STRT_ADDR[1]\ : DFN1C0
      port map(D => \TFC_STRT_ADDR_c[1]\, CLK => CLK60MHZ_c, CLR
         => RESETB_c, Q => \TFC_STRT_ADDR_c[1]\);
    
    \ELINKS_STOP_ADDR[6]\ : DFN1C0
      port map(D => \ELINKS_STOP_ADDR_c[6]\, CLK => CLK60MHZ_c, 
        CLR => RESETB_c, Q => \ELINKS_STOP_ADDR_c[6]\);
    
    \P_ELINKS_STRT_ADDR_pad[2]\ : OUTBUF
      port map(D => \ELINKS_STRT_ADDR_c[2]\, PAD => 
        P_ELINKS_STRT_ADDR(2));
    
    \USB_RD_DAT_RNI8CBV[0]\ : NOR3B
      port map(A => \USB_RD_DAT_i_0[6]\, B => 
        N_USB_RD_BI_i_0_a2_2_3, C => \USB_RD_DAT[0]_net_1\, Y => 
        N_USB_RD_BI_i_0_a2_2_5);
    
    \REG_STATE_RNO_12[19]\ : NOR2
      port map(A => \RET_STATE[20]_net_1\, B => 
        \REG_STATE[20]_net_1\, Y => \REG_STATE_ns_i_0_a2_0[1]\);
    
    \REG_ADDR_RNO[3]\ : XA1C
      port map(A => \REG_ADDR[3]_net_1\, B => N_128, C => 
        \REG_STATE[20]_net_1\, Y => N_23);
    
    GND_i : GND
      port map(Y => \GND\);
    
    \TFC_ADDRA[0]\ : DFN1E1C0
      port map(D => \REG_ADDR[0]_net_1\, CLK => CLK60MHZ_c, CLR
         => RESETB_c, E => N_TFC_RWA_0_sqmuxa, Q => 
        \TFC_ADDRA[0]_net_1\);
    
    \RET_STATE[16]\ : DFN1C0
      port map(D => \RET_STATE_RNO[16]_net_1\, CLK => CLK60MHZ_c, 
        CLR => RESETB_c, Q => \RET_STATE[16]_net_1\);
    
    \P_OP_MODE_pad[2]\ : OUTBUF
      port map(D => \OP_MODE_c[2]\, PAD => P_OP_MODE(2));
    
    \REG_STATE_RNO_19[20]\ : NOR2A
      port map(A => N_164, B => N_186, Y => N_309);
    
    \P_ELINKS_STRT_ADDR_pad[5]\ : OUTBUF
      port map(D => \ELINKS_STRT_ADDR_c[5]\, PAD => 
        P_ELINKS_STRT_ADDR(5));
    
    \REG_STATE_RNO_2[10]\ : NOR3B
      port map(A => \REG_ADDR[7]_net_1\, B => 
        \REG_STATE_ns_0_a2_0[10]\, C => N_162, Y => N_290);
    
    TFC_PATT_GEN_EN_pad : INBUF
      port map(PAD => TFC_PATT_GEN_EN, Y => TFC_PATT_GEN_EN_c);
    
    \REG_STATE_RNO_7[19]\ : NOR3A
      port map(A => N_1431, B => \REG_STATE[20]_net_1\, C => 
        N_130, Y => \REG_STATE_ns_i_0_a2_4_1[1]\);
    
    \REG_STATE_RNO_5[19]\ : NOR3B
      port map(A => N_1428, B => \REG_STATE_ns_i_0_a2_2_0[1]\, C
         => \REG_STATE[20]_net_1\, Y => N_1405);
    
    \REG_STATE_RNIOAOF[19]\ : OR2
      port map(A => \REG_STATE[19]_net_1\, B => 
        \REG_STATE[20]_net_1\, Y => N_73);
    
    \RET_STATE_RNIQ8U01[12]\ : NOR2B
      port map(A => N_889_i_0, B => N_1189, Y => N_1225);
    
    \REG_STATE_RNO_9[20]\ : AOI1B
      port map(A => N_93, B => N_192_i_1, C => 
        \REG_STATE_ns_i_0_a2_12_3[0]\, Y => N_315);
    
    \REG_STATE[15]\ : DFN1C0
      port map(D => \REG_STATE_ns[5]\, CLK => CLK60MHZ_c, CLR => 
        RESETB_c, Q => \REG_STATE[15]_net_1\);
    
    ELINK0_PATT_GEN_EN_pad : INBUF
      port map(PAD => ELINK0_PATT_GEN_EN, Y => 
        ELINK0_PATT_GEN_EN_c);
    
    \P_TFC_STRT_ADDR_pad[0]\ : OUTBUF
      port map(D => \TFC_STRT_ADDR_c[0]\, PAD => 
        P_TFC_STRT_ADDR(0));
    
    \REG_STATE_RNO_3[4]\ : NOR3A
      port map(A => \USB_ADBUS_c[5]\, B => \USB_ADBUS_c[0]\, C
         => \USB_ADBUS_c[1]\, Y => N_1482);
    
    \TFC_STRT_ADDR[0]\ : DFN1C0
      port map(D => \TFC_STRT_ADDR_c[0]\, CLK => CLK60MHZ_c, CLR
         => RESETB_c, Q => \TFC_STRT_ADDR_c[0]\);
    
    \RET_STATE[17]\ : DFN1C0
      port map(D => \RET_STATE_RNO[17]_net_1\, CLK => CLK60MHZ_c, 
        CLR => RESETB_c, Q => \RET_STATE[17]_net_1\);
    
    ELINK0_RWA_RNO : NOR2A
      port map(A => \ELINK0_RWA\, B => N_ELINK0_RWA_0_sqmuxa, Y
         => \ELINK0_RWA_RNO\);
    
    \RET_STATE_RNO[16]\ : AOI1B
      port map(A => N_74, B => USB_RXF_B_c_0, C => 
        \RET_STATE[16]_net_1\, Y => \RET_STATE_RNO[16]_net_1\);
    
    \REG_STATE_RNO_1[5]\ : NOR3C
      port map(A => N_1454, B => \REG_STATE_ns_0_a2_0_0[15]\, C
         => N_1457, Y => N_280);
    
    \RET_STATE_RNO_0[12]\ : NOR2A
      port map(A => \RET_STATE[12]_net_1\, B => 
        \REG_STATE[15]_net_1\, Y => RET_STATE_163_i_i_a2_1_0);
    
    \OP_MODE[2]\ : DFN1C0
      port map(D => \OP_MODE_c[2]\, CLK => CLK60MHZ_c, CLR => 
        RESETB_c, Q => \OP_MODE_c[2]\);
    
    \P_TFC_STRT_ADDR_pad[5]\ : OUTBUF
      port map(D => \TFC_STRT_ADDR_c[5]\, PAD => 
        P_TFC_STRT_ADDR(5));
    
    \ELINK0_ADDRA[1]\ : DFN1E1C0
      port map(D => \REG_ADDR[1]_net_1\, CLK => CLK60MHZ_c, CLR
         => RESETB_c, E => N_ELINK0_RWA_0_sqmuxa, Q => 
        \ELINK0_ADDRA[1]_net_1\);
    
    \RET_STATE_RNO_1[5]\ : MX2
      port map(A => \RET_STATE[5]_net_1\, B => 
        \REG_STATE[5]_net_1\, S => USB_RXF_B_c_0, Y => N_221);
    
    \RET_STATE_RNO[13]\ : AO1A
      port map(A => N_1488, B => RET_STATE_162_0_0_a2_0, C => 
        N_218, Y => \RET_STATE_RNO[13]_net_1\);
    
    \ELINK0_ADDRA[8]\ : DFN1E1C0
      port map(D => ELINK0_ADDR8B_c_i, CLK => CLK60MHZ_c, CLR => 
        RESETB_c, E => N_ELINK0_RWA_0_sqmuxa, Q => 
        \ELINK0_ADDRA[8]_net_1\);
    
    USB_TXE_B_pad_RNI2BUA3 : OA1A
      port map(A => USB_TXE_B_c, B => N_74, C => 
        \REG_STATE[1]_net_1\, Y => N_303);
    
    \RET_STATE_RNI95H4[10]\ : OR2
      port map(A => N_192_i_1, B => N_124, Y => N_130);
    
    TFC_BLKA : DFN1E1P0
      port map(D => N_TFC_BLKA, CLK => CLK60MHZ_c, PRE => 
        RESETB_c, E => N_771, Q => \TFC_BLKA\);
    
    \RET_STATE_RNO[12]\ : AO1A
      port map(A => N_71, B => RET_STATE_163_i_i_a2_1_0, C => 
        RET_STATE_163_i_i_0, Y => N_48);
    
    \REG_STATE_RNO[3]\ : AO1
      port map(A => N_74, B => USB_RXF_B_c_0, C => N_274, Y => 
        \REG_STATE_ns[17]\);
    
    \REG_STATE_RNITJR52[14]\ : NOR2
      port map(A => N_57, B => N_180, Y => N_258_2);
    
    \REG_STATE_RNO_17[20]\ : NOR3C
      port map(A => \REG_STATE[1]_net_1\, B => N_1428, C => N_171, 
        Y => N_308);
    
    TFC_ADDR8B : DFN1C0
      port map(D => TFC_ADDR8B_c, CLK => CLK60MHZ_c, CLR => 
        RESETB_c, Q => TFC_ADDR8B_c);
    
    \P_OP_MODE_pad[6]\ : OUTBUF
      port map(D => \OP_MODE_c[6]\, PAD => P_OP_MODE(6));
    
    \REG_STATE_RNO_0[3]\ : OA1A
      port map(A => \USB_RD_ACTIVE\, B => USB_RXF_B_c, C => 
        \REG_STATE[3]_net_1\, Y => N_274);
    
    \PATT_ELINK0_DAT_pad[6]\ : OUTBUF
      port map(D => \ELINK0_DOUTB_c[6]\, PAD => 
        PATT_ELINK0_DAT(6));
    
    \RET_STATE_RNIOSTF_1[20]\ : NOR3B
      port map(A => N_888_i_0, B => N_889_i_0, C => 
        \RET_STATE[20]_net_1\, Y => N_1428);
    
    \USB_RD_DAT[7]\ : DFN1C0
      port map(D => N_33, CLK => CLK60MHZ_c, CLR => RESETB_c, Q
         => \USB_RD_DAT[7]_net_1\);
    
    \USB_ADBUS_pad[0]\ : INBUF
      port map(PAD => USB_ADBUS(0), Y => \USB_ADBUS_c[0]\);
    
    \RET_STATE_RNI1GU01[16]\ : NOR2B
      port map(A => N_1189, B => N_888_i_0, Y => N_153);
    
    \RET_STATE[11]\ : DFN1C0
      port map(D => \RET_STATE_RNO[11]_net_1\, CLK => CLK60MHZ_c, 
        CLR => RESETB_c, Q => N_124);
    
    \REG_STATE_RNO_2[17]\ : NOR2A
      port map(A => \RET_STATE[17]_net_1\, B => 
        \REG_STATE[18]_net_1\, Y => \REG_STATE_ns_0_a2_0[3]\);
    
    CLK60MHZ_pad : CLKBUF
      port map(PAD => CLK60MHZ, Y => CLK60MHZ_c);
    
    \RET_STATE_RNO[11]\ : AO1
      port map(A => RET_STATE_164_0_0_a2_0, B => N_258_2, C => 
        N_219, Y => \RET_STATE_RNO[11]_net_1\);
    
    \RET_STATE_RNO_0[10]\ : NOR2A
      port map(A => N_192_i_1, B => \REG_STATE[11]_net_1\, Y => 
        RET_STATE_165_0_0_a2_0);
    
    \P_ELINKS_STRT_ADDR_pad[0]\ : OUTBUF
      port map(D => \ELINKS_STRT_ADDR_c[0]\, PAD => 
        P_ELINKS_STRT_ADDR(0));
    
    \ELINK0_ADDRA[0]\ : DFN1E1C0
      port map(D => \REG_ADDR[0]_net_1\, CLK => CLK60MHZ_c, CLR
         => RESETB_c, E => N_ELINK0_RWA_0_sqmuxa, Q => 
        \ELINK0_ADDRA[0]_net_1\);
    
    \REG_STATE_RNO_3[19]\ : OA1A
      port map(A => N_179, B => N_164, C => 
        \REG_STATE_ns_i_0_a2_4_1[1]\, Y => N_1407);
    
    \REG_STATE_RNIPJBS[20]\ : NOR3A
      port map(A => N_1428, B => \REG_STATE[20]_net_1\, C => 
        N_130, Y => N_313);
    
    USB_RXF_B_pad_RNIEOP8 : BUFF
      port map(A => USB_RXF_B_c, Y => USB_RXF_B_c_0);
    
    \REG_STATE_RNO_0[19]\ : OR3
      port map(A => N_1407, B => \REG_STATE_ns_i_0_1[1]\, C => 
        N_1405, Y => \REG_STATE_ns_i_0_3[1]\);
    
    \ELINKS_STRT_ADDR[0]\ : DFN1C0
      port map(D => \ELINKS_STRT_ADDR_c[0]\, CLK => CLK60MHZ_c, 
        CLR => RESETB_c, Q => \ELINKS_STRT_ADDR_c[0]\);
    
    \TFC_DINA[3]\ : DFN1E1C0
      port map(D => \USB_ADBUS_c[3]\, CLK => CLK60MHZ_c, CLR => 
        RESETB_c, E => N_TFC_RWA_0_sqmuxa, Q => 
        \TFC_DINA[3]_net_1\);
    
    VCC_i : VCC
      port map(Y => \VCC\);
    
    \PATT_TFC_DAT_pad[4]\ : OUTBUF
      port map(D => \TFC_DOUTB_c[4]\, PAD => PATT_TFC_DAT(4));
    
    \USB_ADBUS_pad[3]\ : INBUF
      port map(PAD => USB_ADBUS(3), Y => \USB_ADBUS_c[3]\);
    
    \REG_STATE_RNO[2]\ : NOR3B
      port map(A => \USB_RD_ACTIVE\, B => \REG_STATE[3]_net_1\, C
         => USB_RXF_B_c, Y => N_272);
    
    \ELINKS_STRT_ADDR[3]\ : DFN1C0
      port map(D => \ELINKS_STRT_ADDR_c[3]\, CLK => CLK60MHZ_c, 
        CLR => RESETB_c, Q => \ELINKS_STRT_ADDR_c[3]\);
    
    \TFC_ADDRA[6]\ : DFN1E1C0
      port map(D => \REG_ADDR[6]_net_1\, CLK => CLK60MHZ_c, CLR
         => RESETB_c, E => N_TFC_RWA_0_sqmuxa, Q => 
        \TFC_ADDRA[6]_net_1\);
    
    \ELINK0_DINA[0]\ : DFN1E1C0
      port map(D => \USB_ADBUS_c[0]\, CLK => CLK60MHZ_c, CLR => 
        RESETB_c, E => N_ELINK0_RWA_0_sqmuxa, Q => 
        \ELINK0_DINA[0]_net_1\);
    
    \USB_RD_DAT[1]\ : DFN1C0
      port map(D => \USB_RD_DAT_RNO[1]_net_1\, CLK => CLK60MHZ_c, 
        CLR => RESETB_c, Q => \USB_RD_DAT[1]_net_1\);
    
    \ELINKS_STOP_ADDR[4]\ : DFN1C0
      port map(D => \ELINKS_STOP_ADDR_c[4]\, CLK => CLK60MHZ_c, 
        CLR => RESETB_c, Q => \ELINKS_STOP_ADDR_c[4]\);
    
    \REG_ADDR_RNI15V6[1]\ : OR2B
      port map(A => \REG_ADDR[0]_net_1\, B => \REG_ADDR[1]_net_1\, 
        Y => N_125);
    
    \USB_RD_DAT_RNI4MLF[2]\ : NOR2B
      port map(A => \USB_RD_DAT_i_0[4]\, B => \USB_RD_DAT_i_0[2]\, 
        Y => N_USB_RD_BI_i_0_a2_2_3);
    
    \ELINK0_ADDRB_pad[7]\ : INBUF
      port map(PAD => ELINK0_ADDRB(7), Y => \ELINK0_ADDRB_c[7]\);
    
    U0_PATT_TFC_BLK : DPRT_512X9_SRAM
      port map(TFC_DOUTB_c(7) => \TFC_DOUTB_c[7]\, TFC_DOUTB_c(6)
         => \TFC_DOUTB_c[6]\, TFC_DOUTB_c(5) => \TFC_DOUTB_c[5]\, 
        TFC_DOUTB_c(4) => \TFC_DOUTB_c[4]\, TFC_DOUTB_c(3) => 
        \TFC_DOUTB_c[3]\, TFC_DOUTB_c(2) => \TFC_DOUTB_c[2]\, 
        TFC_DOUTB_c(1) => \TFC_DOUTB_c[1]\, TFC_DOUTB_c(0) => 
        \TFC_DOUTB_c[0]\, TFC_ADDRA(8) => \TFC_ADDRA[8]_net_1\, 
        TFC_ADDRA(7) => \TFC_ADDRA[7]_net_1\, TFC_ADDRA(6) => 
        \TFC_ADDRA[6]_net_1\, TFC_ADDRA(5) => 
        \TFC_ADDRA[5]_net_1\, TFC_ADDRA(4) => 
        \TFC_ADDRA[4]_net_1\, TFC_ADDRA(3) => 
        \TFC_ADDRA[3]_net_1\, TFC_ADDRA(2) => 
        \TFC_ADDRA[2]_net_1\, TFC_ADDRA(1) => 
        \TFC_ADDRA[1]_net_1\, TFC_ADDRA(0) => 
        \TFC_ADDRA[0]_net_1\, TFC_ADDRB_c(8) => \TFC_ADDRB_c[8]\, 
        TFC_ADDRB_c(7) => \TFC_ADDRB_c[7]\, TFC_ADDRB_c(6) => 
        \TFC_ADDRB_c[6]\, TFC_ADDRB_c(5) => \TFC_ADDRB_c[5]\, 
        TFC_ADDRB_c(4) => \TFC_ADDRB_c[4]\, TFC_ADDRB_c(3) => 
        \TFC_ADDRB_c[3]\, TFC_ADDRB_c(2) => \TFC_ADDRB_c[2]\, 
        TFC_ADDRB_c(1) => \TFC_ADDRB_c[1]\, TFC_ADDRB_c(0) => 
        \TFC_ADDRB_c[0]\, TFC_DINA(7) => \TFC_DINA[7]_net_1\, 
        TFC_DINA(6) => \TFC_DINA[6]_net_1\, TFC_DINA(5) => 
        \TFC_DINA[5]_net_1\, TFC_DINA(4) => \TFC_DINA[4]_net_1\, 
        TFC_DINA(3) => \TFC_DINA[3]_net_1\, TFC_DINA(2) => 
        \TFC_DINA[2]_net_1\, TFC_DINA(1) => \TFC_DINA[1]_net_1\, 
        TFC_DINA(0) => \TFC_DINA[0]_net_1\, TFC_BLKA => 
        \TFC_BLKA\, TFC_PATT_GEN_EN_c => TFC_PATT_GEN_EN_c, 
        CLK60MHZ_c => CLK60MHZ_c, CLK_40MHZ_GEN_c => 
        CLK_40MHZ_GEN_c, RESETB_c => RESETB_c, TFC_RWA => 
        \TFC_RWA\, TFC_RWB_c => TFC_RWB_c);
    
    \REG_STATE_RNIV34M1[14]\ : OR2A
      port map(A => N_250, B => \REG_STATE[14]_net_1\, Y => N_69);
    
    \RET_STATE_RNO_1[13]\ : MX2
      port map(A => \RET_STATE[13]_net_1\, B => 
        \REG_STATE[13]_net_1\, S => USB_RXF_B_c_0, Y => N_218);
    
    \REG_STATE_RNO_1[13]\ : NOR2A
      port map(A => \REG_STATE[14]_net_1\, B => USB_RXF_B_c, Y
         => N_TFC_STRT_ADDR_T_0_sqmuxa);
    
    \PATT_TFC_DAT_pad[1]\ : OUTBUF
      port map(D => \TFC_DOUTB_c[1]\, PAD => PATT_TFC_DAT(1));
    
    USB_WR_B_pad : OUTBUF
      port map(D => \VCC\, PAD => USB_WR_B);
    
    \RET_STATE_RNIOSTF_0[20]\ : NOR3B
      port map(A => N_888_i_0, B => N_161, C => 
        \RET_STATE[20]_net_1\, Y => N_164);
    
    P_ELINK0_ADDR8B_pad : OUTBUF
      port map(D => ELINK0_ADDR8B_c, PAD => P_ELINK0_ADDR8B);
    
    \REG_STATE_RNO_11[19]\ : XA1
      port map(A => N_124, B => N_192_i_1, C => N_1431, Y => 
        \REG_STATE_ns_i_0_a2_2_0[1]\);
    
    \REG_STATE_RNO_4[20]\ : NOR2B
      port map(A => N_437, B => \RET_STATE[4]_net_1\, Y => N_1420);
    
    \P_TFC_STRT_ADDR_pad[7]\ : OUTBUF
      port map(D => \TFC_STRT_ADDR_c[7]\, PAD => 
        P_TFC_STRT_ADDR(7));
    
    \P_ELINKS_STRT_ADDR_pad[4]\ : OUTBUF
      port map(D => \ELINKS_STRT_ADDR_c[4]\, PAD => 
        P_ELINKS_STRT_ADDR(4));
    
    \RET_STATE_RNO_0[17]\ : NOR2A
      port map(A => \RET_STATE[17]_net_1\, B => 
        \REG_STATE[13]_net_1\, Y => RET_STATE_158_0_0_a2_0);
    
    \REG_STATE_RNO_1[4]\ : NOR3C
      port map(A => N_1457, B => N_1435, C => N_1482, Y => N_277);
    
    \TFC_ADDRA[4]\ : DFN1E1C0
      port map(D => \REG_ADDR[4]_net_1\, CLK => CLK60MHZ_c, CLR
         => RESETB_c, E => N_TFC_RWA_0_sqmuxa, Q => 
        \TFC_ADDRA[4]_net_1\);
    
    \PATT_ELINK0_DAT_pad[5]\ : OUTBUF
      port map(D => \ELINK0_DOUTB_c[5]\, PAD => 
        PATT_ELINK0_DAT(5));
    
    \USB_ADBUS_pad_RNI8O08[2]\ : NOR3
      port map(A => \USB_ADBUS_c[6]\, B => \USB_ADBUS_c[4]\, C
         => \USB_ADBUS_c[2]\, Y => \REG_STATE_ns_0_a2_3_0[15]\);
    
    \TFC_STOP_ADDR[2]\ : DFN1C0
      port map(D => \TFC_STOP_ADDR_c[2]\, CLK => CLK60MHZ_c, CLR
         => RESETB_c, Q => \TFC_STOP_ADDR_c[2]\);
    
    \REG_STATE_RNI46FT2[20]\ : OR2
      port map(A => \REG_STATE[20]_net_1\, B => N_74, Y => N_5);
    
    \TFC_ADDRB_pad[4]\ : INBUF
      port map(PAD => TFC_ADDRB(4), Y => \TFC_ADDRB_c[4]\);
    
    \REG_STATE[4]\ : DFN1C0
      port map(D => \REG_STATE_ns[16]\, CLK => CLK60MHZ_c, CLR
         => RESETB_c, Q => \REG_STATE[4]_net_1\);
    
    \REG_ADDR_RNIKUP31[7]\ : AO1A
      port map(A => N_162, B => \REG_ADDR[7]_net_1\, C => 
        \REG_STATE[20]_net_1\, Y => N_TFC_BLKA);
    
    U1_PATT_ELINK_BLK : DPRT_512X9_SRAM_0
      port map(ELINK0_DOUTB_c(7) => \ELINK0_DOUTB_c[7]\, 
        ELINK0_DOUTB_c(6) => \ELINK0_DOUTB_c[6]\, 
        ELINK0_DOUTB_c(5) => \ELINK0_DOUTB_c[5]\, 
        ELINK0_DOUTB_c(4) => \ELINK0_DOUTB_c[4]\, 
        ELINK0_DOUTB_c(3) => \ELINK0_DOUTB_c[3]\, 
        ELINK0_DOUTB_c(2) => \ELINK0_DOUTB_c[2]\, 
        ELINK0_DOUTB_c(1) => \ELINK0_DOUTB_c[1]\, 
        ELINK0_DOUTB_c(0) => \ELINK0_DOUTB_c[0]\, ELINK0_ADDRA(8)
         => \ELINK0_ADDRA[8]_net_1\, ELINK0_ADDRA(7) => 
        \ELINK0_ADDRA[7]_net_1\, ELINK0_ADDRA(6) => 
        \ELINK0_ADDRA[6]_net_1\, ELINK0_ADDRA(5) => 
        \ELINK0_ADDRA[5]_net_1\, ELINK0_ADDRA(4) => 
        \ELINK0_ADDRA[4]_net_1\, ELINK0_ADDRA(3) => 
        \ELINK0_ADDRA[3]_net_1\, ELINK0_ADDRA(2) => 
        \ELINK0_ADDRA[2]_net_1\, ELINK0_ADDRA(1) => 
        \ELINK0_ADDRA[1]_net_1\, ELINK0_ADDRA(0) => 
        \ELINK0_ADDRA[0]_net_1\, ELINK0_ADDRB_c(8) => 
        \ELINK0_ADDRB_c[8]\, ELINK0_ADDRB_c(7) => 
        \ELINK0_ADDRB_c[7]\, ELINK0_ADDRB_c(6) => 
        \ELINK0_ADDRB_c[6]\, ELINK0_ADDRB_c(5) => 
        \ELINK0_ADDRB_c[5]\, ELINK0_ADDRB_c(4) => 
        \ELINK0_ADDRB_c[4]\, ELINK0_ADDRB_c(3) => 
        \ELINK0_ADDRB_c[3]\, ELINK0_ADDRB_c(2) => 
        \ELINK0_ADDRB_c[2]\, ELINK0_ADDRB_c(1) => 
        \ELINK0_ADDRB_c[1]\, ELINK0_ADDRB_c(0) => 
        \ELINK0_ADDRB_c[0]\, ELINK0_DINA(7) => 
        \ELINK0_DINA[7]_net_1\, ELINK0_DINA(6) => 
        \ELINK0_DINA[6]_net_1\, ELINK0_DINA(5) => 
        \ELINK0_DINA[5]_net_1\, ELINK0_DINA(4) => 
        \ELINK0_DINA[4]_net_1\, ELINK0_DINA(3) => 
        \ELINK0_DINA[3]_net_1\, ELINK0_DINA(2) => 
        \ELINK0_DINA[2]_net_1\, ELINK0_DINA(1) => 
        \ELINK0_DINA[1]_net_1\, ELINK0_DINA(0) => 
        \ELINK0_DINA[0]_net_1\, ELINK0_BLKA => \ELINK0_BLKA\, 
        ELINK0_PATT_GEN_EN_c => ELINK0_PATT_GEN_EN_c, CLK60MHZ_c
         => CLK60MHZ_c, CLK_40MHZ_GEN_c => CLK_40MHZ_GEN_c, 
        RESETB_c => RESETB_c, ELINK0_RWA => \ELINK0_RWA\, 
        ELINK0_RWB_c => ELINK0_RWB_c);
    
    ELINK0_RWA : DFN1P0
      port map(D => \ELINK0_RWA_RNO\, CLK => CLK60MHZ_c, PRE => 
        RESETB_c, Q => \ELINK0_RWA\);
    
    USB_RD_ACTIVE_RNO : AO1A
      port map(A => \REG_STATE[20]_net_1\, B => \USB_RD_ACTIVE\, 
        C => \REG_STATE[17]_net_1\, Y => \USB_RD_ACTIVE_RNO\);
    
    \RET_STATE_RNIT7Q6[16]\ : NOR3
      port map(A => \RET_STATE[14]_net_1\, B => 
        \RET_STATE[17]_net_1\, C => \RET_STATE[16]_net_1\, Y => 
        N_888_i_0);
    
    \REG_STATE_RNO[4]\ : OR3
      port map(A => N_278, B => N_277, C => N_276, Y => 
        \REG_STATE_ns[16]\);
    
    \USB_ADBUS_pad[6]\ : INBUF
      port map(PAD => USB_ADBUS(6), Y => \USB_ADBUS_c[6]\);
    
    \REG_STATE[18]\ : DFN1C0
      port map(D => N_293, CLK => CLK60MHZ_c, CLR => RESETB_c, Q
         => \REG_STATE[18]_net_1\);
    
    \TFC_ADDRB_pad[1]\ : INBUF
      port map(PAD => TFC_ADDRB(1), Y => \TFC_ADDRB_c[1]\);
    
    \TFC_ADDRB_pad[3]\ : INBUF
      port map(PAD => TFC_ADDRB(3), Y => \TFC_ADDRB_c[3]\);
    
    \REG_STATE_RNO[20]\ : NOR3
      port map(A => \REG_STATE_ns_i_0_6[0]\, B => N_1418, C => 
        N_1417, Y => \REG_STATE_RNO[20]_net_1\);
    
    \REG_STATE_RNI8MN31[1]\ : NOR3B
      port map(A => \REG_STATE[1]_net_1\, B => N_1428, C => N_130, 
        Y => N_1464);
    
    \USB_ADBUS_pad[2]\ : INBUF
      port map(PAD => USB_ADBUS(2), Y => \USB_ADBUS_c[2]\);
    
    \USB_RD_DAT_RNO[5]\ : MX2
      port map(A => \USB_ADBUS_c[5]\, B => \USB_RD_DAT[5]_net_1\, 
        S => N_61, Y => N_29);
    
    \REG_STATE_RNO_3[5]\ : NOR2A
      port map(A => \USB_ADBUS_c[1]\, B => \USB_ADBUS_c[0]\, Y
         => \REG_STATE_ns_0_a2_0_0[15]\);
    
    \REG_STATE_RNO_3[20]\ : OR3
      port map(A => N_239, B => \REG_STATE_ns_i_0_1[0]\, C => 
        N_1434, Y => \REG_STATE_ns_i_0_3[0]\);
    
    \REG_STATE_RNI4G8E1[4]\ : NOR2
      port map(A => N_181, B => N_180, Y => N_250);
    
    \OP_MODE[5]\ : DFN1C0
      port map(D => \OP_MODE_c[5]\, CLK => CLK60MHZ_c, CLR => 
        RESETB_c, Q => \OP_MODE_c[5]\);
    
    \PATT_ELINK0_DAT_pad[7]\ : OUTBUF
      port map(D => \ELINK0_DOUTB_c[7]\, PAD => 
        PATT_ELINK0_DAT(7));
    
    \ELINK0_DINA[5]\ : DFN1E1C0
      port map(D => \USB_ADBUS_c[5]\, CLK => CLK60MHZ_c, CLR => 
        RESETB_c, E => N_ELINK0_RWA_0_sqmuxa, Q => 
        \ELINK0_DINA[5]_net_1\);
    
    \TFC_DINA[2]\ : DFN1E1C0
      port map(D => \USB_ADBUS_c[2]\, CLK => CLK60MHZ_c, CLR => 
        RESETB_c, E => N_TFC_RWA_0_sqmuxa, Q => 
        \TFC_DINA[2]_net_1\);
    
    \P_TFC_STOP_ADDR_pad[3]\ : OUTBUF
      port map(D => \TFC_STOP_ADDR_c[3]\, PAD => 
        P_TFC_STOP_ADDR(3));
    
    \TFC_STRT_ADDR[4]\ : DFN1C0
      port map(D => \TFC_STRT_ADDR_c[4]\, CLK => CLK60MHZ_c, CLR
         => RESETB_c, Q => \TFC_STRT_ADDR_c[4]\);
    
    \REG_STATE_RNO_11[20]\ : OR3
      port map(A => \REG_STATE[2]_net_1\, B => 
        \REG_STATE[3]_net_1\, C => N_317, Y => 
        \REG_STATE_ns_i_0_1[0]\);
    
    \REG_STATE_RNO[14]\ : AO1
      port map(A => \REG_STATE_ns_0_a2_0_2[6]\, B => N_1225, C
         => N_OP_MODE_T_0_sqmuxa, Y => \REG_STATE_ns[6]\);
    
    USB_TXE_B_pad_RNITQSE : OR2B
      port map(A => USB_TXE_B_c, B => USB_RXF_B_c, Y => 
        \REG_STATE_ns_i_0_o2_7_0[0]\);
    
    \RET_STATE[12]\ : DFN1C0
      port map(D => N_48, CLK => CLK60MHZ_c, CLR => RESETB_c, Q
         => \RET_STATE[12]_net_1\);
    
    \REG_STATE_RNO_2[16]\ : NOR3A
      port map(A => \RET_STATE[16]_net_1\, B => 
        \RET_STATE[14]_net_1\, C => \RET_STATE[17]_net_1\, Y => 
        N_1558);
    
    \ELINK0_ADDRB_pad[6]\ : INBUF
      port map(PAD => ELINK0_ADDRB(6), Y => \ELINK0_ADDRB_c[6]\);
    
    \TFC_STRT_ADDR[5]\ : DFN1C0
      port map(D => \TFC_STRT_ADDR_c[5]\, CLK => CLK60MHZ_c, CLR
         => RESETB_c, Q => \TFC_STRT_ADDR_c[5]\);
    
    \USB_RD_DAT_RNICGBV[5]\ : NOR3C
      port map(A => \USB_RD_DAT[5]_net_1\, B => 
        \USB_RD_DAT[7]_net_1\, C => N_USB_RD_BI_i_0_a2_2_1, Y => 
        N_USB_RD_BI_i_0_a2_2_4);
    
    \ELINK0_ADDRB_pad[8]\ : INBUF
      port map(PAD => ELINK0_ADDRB(8), Y => \ELINK0_ADDRB_c[8]\);
    
    \P_OP_MODE_pad[7]\ : OUTBUF
      port map(D => \OP_MODE_c[7]\, PAD => P_OP_MODE(7));
    
    \REG_STATE_RNO_12[20]\ : OA1B
      port map(A => N_5, B => \REG_STATE_ns_i_0_o2_5_0[0]\, C => 
        USB_RXF_B_c_0, Y => N_1434);
    
    \REG_STATE_RNO[17]\ : AO1A
      port map(A => USB_RXF_B_c_0, B => N_154, C => N_1551, Y => 
        \REG_STATE_ns[3]\);
    
    \REG_STATE_RNO[10]\ : OR3
      port map(A => N_1404, B => N_1403, C => N_290, Y => 
        \REG_STATE_ns[10]\);
    
    \REG_STATE_RNO_10[20]\ : NOR2B
      port map(A => N_1225, B => N_872, Y => N_239);
    
    \RET_STATE_RNIM0Q6[12]\ : NOR3
      port map(A => \RET_STATE[13]_net_1\, B => 
        \RET_STATE[12]_net_1\, C => \RET_STATE[15]_net_1\, Y => 
        N_889_i_0);
    
    \REG_STATE_RNO_9[19]\ : NOR2A
      port map(A => N_872, B => N_130, Y => 
        \REG_STATE_ns_i_0_a2_2[1]\);
    
    \REG_ADDR[2]\ : DFN1E1C0
      port map(D => N_25, CLK => CLK60MHZ_c, CLR => RESETB_c, E
         => REG_ADDRe, Q => \REG_ADDR[2]_net_1\);
    
    \P_ELINKS_STOP_ADDR_pad[7]\ : OUTBUF
      port map(D => \ELINKS_STOP_ADDR_c[7]\, PAD => 
        P_ELINKS_STOP_ADDR(7));
    
    \P_ELINKS_STRT_ADDR_pad[1]\ : OUTBUF
      port map(D => \ELINKS_STRT_ADDR_c[1]\, PAD => 
        P_ELINKS_STRT_ADDR(1));
    
    \ELINK0_ADDRB_pad[1]\ : INBUF
      port map(PAD => ELINK0_ADDRB(1), Y => \ELINK0_ADDRB_c[1]\);
    
    \TFC_ADDRB_pad[5]\ : INBUF
      port map(PAD => TFC_ADDRB(5), Y => \TFC_ADDRB_c[5]\);
    
    \RET_STATE_RNO_1[12]\ : AO1A
      port map(A => USB_RXF_B_c_0, B => \RET_STATE[12]_net_1\, C
         => N_1536, Y => RET_STATE_163_i_i_0);
    
    \REG_STATE_RNO_1[12]\ : NOR2A
      port map(A => \REG_STATE[13]_net_1\, B => USB_RXF_B_c, Y
         => N_TFC_STOP_ADDR_T_0_sqmuxa);
    
    \REG_ADDR_RNO[1]\ : XA1B
      port map(A => \REG_ADDR[1]_net_1\, B => \REG_ADDR[0]_net_1\, 
        C => \REG_STATE[20]_net_1\, Y => N_27);
    
    \REG_STATE_RNIKAR52[14]\ : OR2
      port map(A => N_69, B => N_68, Y => N_1488);
    
    TFC_BLKA_RNO : OR2
      port map(A => N_TFC_RWA_0_sqmuxa, B => 
        \REG_STATE[20]_net_1\, Y => N_771);
    
    \REG_ADDR[5]\ : DFN1E1C0
      port map(D => N_19, CLK => CLK60MHZ_c, CLR => RESETB_c, E
         => REG_ADDRe, Q => \REG_ADDR[5]_net_1\);
    
    \REG_STATE_RNIN2863[16]\ : AOI1
      port map(A => N_74, B => USB_RXF_B_c_0, C => 
        \REG_STATE[16]_net_1\, Y => N_151);
    
    \ELINK0_ADDRA[2]\ : DFN1E1C0
      port map(D => \REG_ADDR[2]_net_1\, CLK => CLK60MHZ_c, CLR
         => RESETB_c, E => N_ELINK0_RWA_0_sqmuxa, Q => 
        \ELINK0_ADDRA[2]_net_1\);
    
    USB_RD_ACTIVE : DFN1C0
      port map(D => \USB_RD_ACTIVE_RNO\, CLK => CLK60MHZ_c, CLR
         => RESETB_c, Q => \USB_RD_ACTIVE\);
    
    \RET_STATE_RNO_0[5]\ : NOR3A
      port map(A => \RET_STATE[5]_net_1\, B => 
        \REG_STATE[4]_net_1\, C => N_181, Y => 
        RET_STATE_170_0_0_a2_1);
    
    USB_OE_BI_RNO_2 : AO1A
      port map(A => USB_RXF_B_c_0, B => N_73, C => 
        \REG_STATE[2]_net_1\, Y => N_USB_OE_BI_i_0_0);
    
    \USB_ADBUS_pad[1]\ : INBUF
      port map(PAD => USB_ADBUS(1), Y => \USB_ADBUS_c[1]\);
    
    \RET_STATE[5]\ : DFN1C0
      port map(D => \RET_STATE_RNO[5]_net_1\, CLK => CLK60MHZ_c, 
        CLR => RESETB_c, Q => \RET_STATE[5]_net_1\);
    
    \P_OP_MODE_pad[3]\ : OUTBUF
      port map(D => \OP_MODE_c[3]\, PAD => P_OP_MODE(3));
    
    \ELINKS_STOP_ADDR[1]\ : DFN1C0
      port map(D => \ELINKS_STOP_ADDR_c[1]\, CLK => CLK60MHZ_c, 
        CLR => RESETB_c, Q => \ELINKS_STOP_ADDR_c[1]\);
    
    ELINK0_RWB_pad : INBUF
      port map(PAD => ELINK0_RWB, Y => ELINK0_RWB_c);
    
    \RET_STATE[15]\ : DFN1C0
      port map(D => \RET_STATE_RNO[15]_net_1\, CLK => CLK60MHZ_c, 
        CLR => RESETB_c, Q => \RET_STATE[15]_net_1\);
    
    \ELINKS_STOP_ADDR[7]\ : DFN1C0
      port map(D => \ELINKS_STOP_ADDR_c[7]\, CLK => CLK60MHZ_c, 
        CLR => RESETB_c, Q => \ELINKS_STOP_ADDR_c[7]\);
    
    \TFC_STRT_ADDR[7]\ : DFN1C0
      port map(D => \TFC_STRT_ADDR_c[7]\, CLK => CLK60MHZ_c, CLR
         => RESETB_c, Q => \TFC_STRT_ADDR_c[7]\);
    
    \REG_STATE_RNO_4[19]\ : AO1
      port map(A => \REG_STATE_ns_i_0_a2_3[1]\, B => 
        \REG_STATE_ns_i_0_a2_2[1]\, C => \REG_STATE_ns_i_0_0[1]\, 
        Y => \REG_STATE_ns_i_0_1[1]\);
    
    \REG_STATE_RNO_0[13]\ : NOR3A
      port map(A => \REG_STATE_ns_0_a2_0_1[7]\, B => 
        \RET_STATE[12]_net_1\, C => \REG_STATE[14]_net_1\, Y => 
        \REG_STATE_ns_0_a2_0_2[7]\);
    
    \TFC_DINA[4]\ : DFN1E1C0
      port map(D => \USB_ADBUS_c[4]\, CLK => CLK60MHZ_c, CLR => 
        RESETB_c, E => N_TFC_RWA_0_sqmuxa, Q => 
        \TFC_DINA[4]_net_1\);
    
    \TFC_ADDRB_pad[2]\ : INBUF
      port map(PAD => TFC_ADDRB(2), Y => \TFC_ADDRB_c[2]\);
    
    \REG_STATE_RNO_2[14]\ : NOR2A
      port map(A => \RET_STATE[14]_net_1\, B => 
        \RET_STATE[16]_net_1\, Y => \REG_STATE_ns_0_a2_0_1[6]\);
    
    \USB_RD_DAT_RNO[6]\ : MX2A
      port map(A => \USB_ADBUS_c[6]\, B => \USB_RD_DAT_i_0[6]\, S
         => N_61, Y => N_31);
    
    \REG_STATE_RNO_0[20]\ : OR3
      port map(A => \REG_STATE_ns_i_0_3[0]\, B => N_1420, C => 
        \REG_STATE_ns_i_0_4[0]\, Y => \REG_STATE_ns_i_0_6[0]\);
    
    USB_TXE_B_pad : INBUF
      port map(PAD => USB_TXE_B, Y => USB_TXE_B_c);
    
    \TFC_ADDRB_pad[8]\ : INBUF
      port map(PAD => TFC_ADDRB(8), Y => \TFC_ADDRB_c[8]\);
    
    \RET_STATE_RNO_1[10]\ : MX2
      port map(A => N_192_i_1, B => \REG_STATE[10]_net_1\, S => 
        USB_RXF_B_c, Y => N_220);
    
    \REG_STATE_RNO_1[10]\ : NOR2A
      port map(A => N_181, B => USB_RXF_B_c, Y => N_1403);
    
    \REG_STATE[14]\ : DFN1C0
      port map(D => \REG_STATE_ns[6]\, CLK => CLK60MHZ_c, CLR => 
        RESETB_c, Q => \REG_STATE[14]_net_1\);
    
    \REG_STATE_RNO_2[15]\ : NOR3A
      port map(A => \RET_STATE[15]_net_1\, B => 
        \RET_STATE[13]_net_1\, C => \RET_STATE[12]_net_1\, Y => 
        N_1439);
    
    \ELINKS_STRT_ADDR[2]\ : DFN1C0
      port map(D => \ELINKS_STRT_ADDR_c[2]\, CLK => CLK60MHZ_c, 
        CLR => RESETB_c, Q => \ELINKS_STRT_ADDR_c[2]\);
    
    \REG_STATE_RNIJ6MO[16]\ : NOR3B
      port map(A => \REG_STATE_ns_0_a2_3_0[15]\, B => 
        \REG_STATE[16]_net_1\, C => USB_RXF_B_c_0, Y => N_1457);
    
    \ELINK0_ADDRB_pad[5]\ : INBUF
      port map(PAD => ELINK0_ADDRB(5), Y => \ELINK0_ADDRB_c[5]\);
    
    \REG_ADDR[3]\ : DFN1E1C0
      port map(D => N_23, CLK => CLK60MHZ_c, CLR => RESETB_c, E
         => REG_ADDRe, Q => \REG_ADDR[3]_net_1\);
    
    \REG_STATE_RNO[15]\ : AO1
      port map(A => \REG_STATE_ns_0_a2_1[5]\, B => N_1457, C => 
        N_292, Y => \REG_STATE_ns[5]\);
    
    \RET_STATE_RNO_0[11]\ : NOR2A
      port map(A => N_124, B => \REG_STATE[10]_net_1\, Y => 
        RET_STATE_164_0_0_a2_0);
    
    \ELINKS_STRT_ADDR[6]\ : DFN1C0
      port map(D => \ELINKS_STRT_ADDR_c[6]\, CLK => CLK60MHZ_c, 
        CLR => RESETB_c, Q => \ELINKS_STRT_ADDR_c[6]\);
    
    USB_OE_BI_RNO : OA1C
      port map(A => N_154, B => USB_RXF_B_c_0, C => 
        N_USB_OE_BI_i_0_0, Y => N_830);
    
    \RET_STATE_RNO_3[12]\ : NOR2B
      port map(A => USB_RXF_B_c, B => \REG_STATE[12]_net_1\, Y
         => RET_STATE_163_i_i_a2_0_0);
    
    \RET_STATE_RNO[4]\ : AO1A
      port map(A => N_57, B => RET_STATE_171_0_0_a2_1, C => N_222, 
        Y => \RET_STATE_RNO[4]_net_1\);
    
    \REG_STATE[10]\ : DFN1C0
      port map(D => \REG_STATE_ns[10]\, CLK => CLK60MHZ_c, CLR
         => RESETB_c, Q => \REG_STATE[10]_net_1\);
    
    \USB_ADBUS_pad_RNI0BMA[5]\ : AOI1B
      port map(A => \USB_ADBUS_c[5]\, B => \USB_ADBUS_c[1]\, C
         => N_1435, Y => un1_REG_STATE_22_0_0_a2_0_2_0);
    
    \OP_MODE[3]\ : DFN1C0
      port map(D => \OP_MODE_c[3]\, CLK => CLK60MHZ_c, CLR => 
        RESETB_c, Q => \OP_MODE_c[3]\);
    
    \PATT_TFC_DAT_pad[5]\ : OUTBUF
      port map(D => \TFC_DOUTB_c[5]\, PAD => PATT_TFC_DAT(5));
    
    \REG_ADDR[7]\ : DFN1E1C0
      port map(D => N_15, CLK => CLK60MHZ_c, CLR => RESETB_c, E
         => REG_ADDRe, Q => \REG_ADDR[7]_net_1\);
    
    \TFC_ADDRA[3]\ : DFN1E1C0
      port map(D => \REG_ADDR[3]_net_1\, CLK => CLK60MHZ_c, CLR
         => RESETB_c, E => N_TFC_RWA_0_sqmuxa, Q => 
        \TFC_ADDRA[3]_net_1\);
    
    \PATT_TFC_DAT_pad[2]\ : OUTBUF
      port map(D => \TFC_DOUTB_c[2]\, PAD => PATT_TFC_DAT(2));
    
    \RET_STATE_RNIT7Q6_0[16]\ : MIN3X
      port map(A => \RET_STATE[14]_net_1\, B => 
        \RET_STATE[17]_net_1\, C => \RET_STATE[16]_net_1\, Y => 
        N_872);
    
    \RET_STATE_RNO_0[14]\ : NOR2B
      port map(A => \RET_STATE[14]_net_1\, B => N_1533_2, Y => 
        RET_STATE_161_0_0_a2_0);
    
    \ELINK0_DINA[2]\ : DFN1E1C0
      port map(D => \USB_ADBUS_c[2]\, CLK => CLK60MHZ_c, CLR => 
        RESETB_c, E => N_ELINK0_RWA_0_sqmuxa, Q => 
        \ELINK0_DINA[2]_net_1\);
    
    \USB_RD_DAT[0]\ : DFN1C0
      port map(D => N_44, CLK => CLK60MHZ_c, CLR => RESETB_c, Q
         => \USB_RD_DAT[0]_net_1\);
    
    \PATT_ELINK0_DAT_pad[3]\ : OUTBUF
      port map(D => \ELINK0_DOUTB_c[3]\, PAD => 
        PATT_ELINK0_DAT(3));
    
    \RET_STATE_RNO_1[17]\ : MX2
      port map(A => \RET_STATE[17]_net_1\, B => 
        \REG_STATE[17]_net_1\, S => USB_RXF_B_c, Y => N_217);
    
    \REG_STATE_RNO_1[17]\ : NOR2
      port map(A => \RET_STATE[14]_net_1\, B => 
        \RET_STATE[16]_net_1\, Y => \REG_STATE_ns_0_a2_1[3]\);
    
    \P_ELINKS_STOP_ADDR_pad[3]\ : OUTBUF
      port map(D => \ELINKS_STOP_ADDR_c[3]\, PAD => 
        P_ELINKS_STOP_ADDR(3));
    
    \PATT_TFC_DAT_pad[3]\ : OUTBUF
      port map(D => \TFC_DOUTB_c[3]\, PAD => PATT_TFC_DAT(3));
    
    \REG_STATE_RNO_0[4]\ : NOR3B
      port map(A => \RET_STATE[4]_net_1\, B => N_1464, C => 
        \RET_STATE[5]_net_1\, Y => N_278);
    
    \REG_ADDR_RNO[5]\ : XA1C
      port map(A => \REG_ADDR[5]_net_1\, B => N_134, C => 
        \REG_STATE[20]_net_1\, Y => N_19);
    
    \ELINK0_ADDRB_pad[0]\ : INBUF
      port map(PAD => ELINK0_ADDRB(0), Y => \ELINK0_ADDRB_c[0]\);
    
    \USB_RD_DAT_RNI2KLF[1]\ : NOR2B
      port map(A => \USB_RD_DAT[3]_net_1\, B => 
        \USB_RD_DAT[1]_net_1\, Y => N_USB_RD_BI_i_0_a2_2_1);
    
    USB_OE_BI_RNO_1 : NOR3
      port map(A => \REG_STATE[18]_net_1\, B => 
        \REG_STATE[2]_net_1\, C => N_73, Y => 
        un1_REG_STATE_22_0_0_a2_1);
    
    \ELINK0_ADDRA[3]\ : DFN1E1C0
      port map(D => \REG_ADDR[3]_net_1\, CLK => CLK60MHZ_c, CLR
         => RESETB_c, E => N_ELINK0_RWA_0_sqmuxa, Q => 
        \ELINK0_ADDRA[3]_net_1\);
    
    \REG_STATE_RNO_16[20]\ : NOR3A
      port map(A => USB_RXF_B_c_0, B => N_309, C => N_307, Y => 
        \REG_STATE_ns_i_0_a2_12_1[0]\);
    
    \USB_RD_DAT_RNO[3]\ : MX2
      port map(A => \USB_ADBUS_c[3]\, B => \USB_RD_DAT[3]_net_1\, 
        S => N_61, Y => \USB_RD_DAT_RNO[3]_net_1\);
    
    \RET_STATE_RNO_0[15]\ : NOR2A
      port map(A => \RET_STATE[15]_net_1\, B => 
        \REG_STATE[12]_net_1\, Y => RET_STATE_160_0_0_a2_0);
    
    \RET_STATE_RNIM0Q6_0[12]\ : MIN3X
      port map(A => \RET_STATE[13]_net_1\, B => 
        \RET_STATE[12]_net_1\, C => \RET_STATE[15]_net_1\, Y => 
        N_161);
    
    USB_TXE_B_pad_RNIVS4P5 : AO1C
      port map(A => N_74, B => USB_TXE_B_c, C => N_5, Y => N_165);
    
    \TFC_STOP_ADDR[4]\ : DFN1C0
      port map(D => \TFC_STOP_ADDR_c[4]\, CLK => CLK60MHZ_c, CLR
         => RESETB_c, Q => \TFC_STOP_ADDR_c[4]\);
    
    \RET_STATE_RNI44F11[11]\ : NOR3B
      port map(A => \REG_STATE[1]_net_1\, B => N_1428, C => N_124, 
        Y => N_304);
    
    \REG_STATE_RNO[16]\ : AO1
      port map(A => \REG_STATE_ns_0_a2_0_0[4]\, B => N_1225, C
         => N_127, Y => \REG_STATE_ns[4]\);
    
    \ELINK0_ADDRB_pad[2]\ : INBUF
      port map(PAD => ELINK0_ADDRB(2), Y => \ELINK0_ADDRB_c[2]\);
    
    \P_TFC_STRT_ADDR_pad[6]\ : OUTBUF
      port map(D => \TFC_STRT_ADDR_c[6]\, PAD => 
        P_TFC_STRT_ADDR(6));
    
    \REG_STATE_RNIJKI62[18]\ : NOR3C
      port map(A => N_USB_RD_BI_i_0_a2_2_4, B => 
        N_USB_RD_BI_i_0_a2_2_5, C => \REG_STATE[18]_net_1\, Y => 
        N_154);
    
    \REG_ADDR_RNO[0]\ : NOR2
      port map(A => \REG_STATE[20]_net_1\, B => 
        \REG_ADDR[0]_net_1\, Y => N_248);
    
    TFC_RWB_pad : INBUF
      port map(PAD => TFC_RWB, Y => TFC_RWB_c);
    
    \REG_STATE_RNO[13]\ : AO1
      port map(A => \REG_STATE_ns_0_a2_0_2[7]\, B => N_153, C => 
        N_TFC_STRT_ADDR_T_0_sqmuxa, Y => \REG_STATE_ns[7]\);
    
    \REG_STATE_RNICKIL2[12]\ : OR2
      port map(A => N_68, B => N_71, Y => N_74);
    
    \REG_STATE_RNO_0[12]\ : NOR3A
      port map(A => \REG_STATE_ns_0_a2_1[8]\, B => 
        \RET_STATE[13]_net_1\, C => \REG_STATE[13]_net_1\, Y => 
        \REG_STATE_ns_0_a2_2[8]\);
    
    \REG_ADDR[4]\ : DFN1E1C0
      port map(D => N_21, CLK => CLK60MHZ_c, CLR => RESETB_c, E
         => REG_ADDRe, Q => \REG_ADDR[4]_net_1\);
    
    \REG_STATE_RNIGPPJ[1]\ : OR2A
      port map(A => \REG_STATE[1]_net_1\, B => N_130, Y => N_186);
    
    \REG_STATE_RNO[12]\ : AO1
      port map(A => \REG_STATE_ns_0_a2_2[8]\, B => N_153, C => 
        N_TFC_STOP_ADDR_T_0_sqmuxa, Y => \REG_STATE_ns[8]\);
    
    \OP_MODE[7]\ : DFN1C0
      port map(D => \OP_MODE_c[7]\, CLK => CLK60MHZ_c, CLR => 
        RESETB_c, Q => \OP_MODE_c[7]\);
    
    \TFC_STOP_ADDR[5]\ : DFN1C0
      port map(D => \TFC_STOP_ADDR_c[5]\, CLK => CLK60MHZ_c, CLR
         => RESETB_c, Q => \TFC_STOP_ADDR_c[5]\);
    
    \P_TFC_STOP_ADDR_pad[1]\ : OUTBUF
      port map(D => \TFC_STOP_ADDR_c[1]\, PAD => 
        P_TFC_STOP_ADDR(1));
    
    \REG_STATE_RNIO9NF[13]\ : OR2
      port map(A => \REG_STATE[17]_net_1\, B => 
        \REG_STATE[13]_net_1\, Y => N_65);
    
    \P_OP_MODE_pad[0]\ : OUTBUF
      port map(D => \OP_MODE_c[0]\, PAD => P_OP_MODE(0));
    
    \RET_STATE_RNIOSTF[20]\ : OR3C
      port map(A => N_888_i_0, B => N_889_i_0, C => 
        \RET_STATE[20]_net_1\, Y => N_179);
    
    \USB_ADBUS_pad[5]\ : INBUF
      port map(PAD => USB_ADBUS(5), Y => \USB_ADBUS_c[5]\);
    
    \REG_STATE[2]\ : DFN1C0
      port map(D => N_272, CLK => CLK60MHZ_c, CLR => RESETB_c, Q
         => \REG_STATE[2]_net_1\);
    
    \ELINK0_ADDRB_pad[3]\ : INBUF
      port map(PAD => ELINK0_ADDRB(3), Y => \ELINK0_ADDRB_c[3]\);
    
    USB_RD_BI_RNO_4 : NOR3
      port map(A => \REG_STATE[16]_net_1\, B => USB_RXF_B_c_0, C
         => \REG_STATE[20]_net_1\, Y => N_USB_RD_BI_i_0_a2_0_1);
    
    \REG_STATE_RNO[11]\ : AO1
      port map(A => \REG_STATE_ns_a2_0_a2_1[9]\, B => N_1458, C
         => N_ELINKS_STRT_ADDR_T_0_sqmuxa, Y => \REG_STATE_ns[9]\);
    
    \TFC_ADDRA_RNO[8]\ : INV
      port map(A => TFC_ADDR8B_c, Y => TFC_ADDR8B_c_i);
    
    \REG_STATE[19]\ : DFN1C0
      port map(D => \REG_STATE_RNO[19]_net_1\, CLK => CLK60MHZ_c, 
        CLR => RESETB_c, Q => \REG_STATE[19]_net_1\);
    
    \P_ELINKS_STOP_ADDR_pad[0]\ : OUTBUF
      port map(D => \ELINKS_STOP_ADDR_c[0]\, PAD => 
        P_ELINKS_STOP_ADDR(0));
    
    \REG_STATE_RNILFHU[4]\ : OR2
      port map(A => \REG_STATE[5]_net_1\, B => 
        \REG_STATE[4]_net_1\, Y => N_180);
    
    \TFC_STOP_ADDR[3]\ : DFN1C0
      port map(D => \TFC_STOP_ADDR_c[3]\, CLK => CLK60MHZ_c, CLR
         => RESETB_c, Q => \TFC_STOP_ADDR_c[3]\);
    
    USB_OE_BI : DFN1E0P0
      port map(D => N_830, CLK => CLK60MHZ_c, PRE => RESETB_c, E
         => un1_REG_STATE_22, Q => USB_OE_BI_c);
    
    \REG_STATE_RNO_3[10]\ : NOR2
      port map(A => USB_RXF_B_c, B => N_250, Y => 
        \REG_STATE_ns_0_a2_0[10]\);
    
    \REG_STATE_RNO_2[20]\ : NOR3A
      port map(A => N_1431, B => N_314, C => N_315, Y => N_1417);
    
    CLK_40MHZ_GEN_pad : CLKBUF
      port map(PAD => CLK_40MHZ_GEN, Y => CLK_40MHZ_GEN_c);
    
    \REG_STATE_RNO_13[20]\ : OAI1
      port map(A => N_179, B => N_130, C => \REG_STATE[1]_net_1\, 
        Y => N_234);
    
    \REG_STATE_RNO_0[10]\ : NOR3B
      port map(A => N_192_i_1, B => N_1458, C => N_124, Y => 
        N_1404);
    
    \REG_STATE_RNIDGEV[13]\ : NOR2
      port map(A => N_65, B => N_68, Y => N_1533_2);
    
    \REG_ADDR_RNO[6]\ : XA1C
      port map(A => N_138, B => \REG_ADDR[6]_net_1\, C => 
        \REG_STATE[20]_net_1\, Y => N_17);
    
    USB_RD_BI_RNO_2 : NOR3C
      port map(A => N_USB_RD_BI_i_0_a2_2_4, B => 
        N_USB_RD_BI_i_0_a2_2_5, C => N_USB_RD_BI_i_0_a2_0_1, Y
         => N_1524);
    
    TFC_RWA_RNO : NOR2A
      port map(A => \TFC_RWA\, B => N_TFC_RWA_0_sqmuxa, Y => 
        \TFC_RWA_RNO\);
    
    \PATT_TFC_DAT_pad[6]\ : OUTBUF
      port map(D => \TFC_DOUTB_c[6]\, PAD => PATT_TFC_DAT(6));
    
    \REG_STATE_RNIC8HO[19]\ : AO1D
      port map(A => \REG_STATE[17]_net_1\, B => 
        \REG_STATE[19]_net_1\, C => USB_RXF_B_c_0, Y => N_61);
    
    \P_TFC_STRT_ADDR_pad[3]\ : OUTBUF
      port map(D => \TFC_STRT_ADDR_c[3]\, PAD => 
        P_TFC_STRT_ADDR(3));
    
    ELINK0_BLKA_RNO : OR2
      port map(A => N_ELINK0_RWA_0_sqmuxa, B => 
        \REG_STATE[20]_net_1\, Y => N_769);
    
    USB_TXE_B_pad_RNI1CDK3 : AO1
      port map(A => N_1428, B => N_74, C => 
        \REG_STATE_ns_i_0_o2_7_0[0]\, Y => N_146);
    
    \REG_STATE_RNO_2[19]\ : OA1
      port map(A => USB_RXF_B_c_0, B => N_313, C => 
        \REG_STATE_ns_i_0_a2_9_0[1]\, Y => N_1413);
    
    \ELINK0_DINA[1]\ : DFN1E1C0
      port map(D => \USB_ADBUS_c[1]\, CLK => CLK60MHZ_c, CLR => 
        RESETB_c, E => N_ELINK0_RWA_0_sqmuxa, Q => 
        \ELINK0_DINA[1]_net_1\);
    
    \TFC_STRT_ADDR[3]\ : DFN1C0
      port map(D => \TFC_STRT_ADDR_c[3]\, CLK => CLK60MHZ_c, CLR
         => RESETB_c, Q => \TFC_STRT_ADDR_c[3]\);
    
    \REG_STATE_RNIF0NF[10]\ : OR2
      port map(A => \REG_STATE[11]_net_1\, B => 
        \REG_STATE[10]_net_1\, Y => N_181);
    
    \REG_STATE_RNI84A71[14]\ : OR2A
      port map(A => N_1533_2, B => \REG_STATE[14]_net_1\, Y => 
        N_57);
    
    \REG_STATE_RNO_0[5]\ : NOR3B
      port map(A => \RET_STATE[5]_net_1\, B => N_1464, C => 
        \RET_STATE[4]_net_1\, Y => N_1388);
    
    \TFC_ADDRA[5]\ : DFN1E1C0
      port map(D => \REG_ADDR[5]_net_1\, CLK => CLK60MHZ_c, CLR
         => RESETB_c, E => N_TFC_RWA_0_sqmuxa, Q => 
        \TFC_ADDRA[5]_net_1\);
    
    ELINK0_ADDR8B : DFN1C0
      port map(D => ELINK0_ADDR8B_c, CLK => CLK60MHZ_c, CLR => 
        RESETB_c, Q => ELINK0_ADDR8B_c);
    
    \OP_MODE[1]\ : DFN1C0
      port map(D => \OP_MODE_c[1]\, CLK => CLK60MHZ_c, CLR => 
        RESETB_c, Q => \OP_MODE_c[1]\);
    
    TFC_RWA : DFN1P0
      port map(D => \TFC_RWA_RNO\, CLK => CLK60MHZ_c, PRE => 
        RESETB_c, Q => \TFC_RWA\);
    
    \PATT_ELINK0_DAT_pad[0]\ : OUTBUF
      port map(D => \ELINK0_DOUTB_c[0]\, PAD => 
        PATT_ELINK0_DAT(0));
    
    \ELINK0_ADDRA_RNO[8]\ : INV
      port map(A => ELINK0_ADDR8B_c, Y => ELINK0_ADDR8B_c_i);
    
    \TFC_ADDRA[7]\ : DFN1E1C0
      port map(D => \REG_ADDR[7]_net_1\, CLK => CLK60MHZ_c, CLR
         => RESETB_c, E => N_TFC_RWA_0_sqmuxa, Q => 
        \TFC_ADDRA[7]_net_1\);
    
    \USB_RD_DAT[3]\ : DFN1C0
      port map(D => \USB_RD_DAT_RNO[3]_net_1\, CLK => CLK60MHZ_c, 
        CLR => RESETB_c, Q => \USB_RD_DAT[3]_net_1\);
    
    \P_TFC_STOP_ADDR_pad[6]\ : OUTBUF
      port map(D => \TFC_STOP_ADDR_c[6]\, PAD => 
        P_TFC_STOP_ADDR(6));
    
    \P_ELINKS_STRT_ADDR_pad[6]\ : OUTBUF
      port map(D => \ELINKS_STRT_ADDR_c[6]\, PAD => 
        P_ELINKS_STRT_ADDR(6));
    
    USB_RD_B_pad : OUTBUF
      port map(D => USB_RD_BI_c, PAD => USB_RD_B);
    
    USB_RD_BI : DFN1E0P0
      port map(D => N_828, CLK => CLK60MHZ_c, PRE => RESETB_c, E
         => un1_REG_STATE_23, Q => USB_RD_BI_c);
    
    \REG_STATE_RNO_6[19]\ : OA1A
      port map(A => \RET_STATE[5]_net_1\, B => USB_RXF_B_c_0, C
         => \RET_STATE[4]_net_1\, Y => 
        \REG_STATE_ns_i_0_a2_9_0[1]\);
    
    \REG_STATE_RNIOF2O[4]\ : NOR2A
      port map(A => \REG_STATE[4]_net_1\, B => USB_RXF_B_c, Y => 
        N_ELINK0_RWA_0_sqmuxa);
    
    \ELINK0_ADDRA[7]\ : DFN1E1C0
      port map(D => \REG_ADDR[7]_net_1\, CLK => CLK60MHZ_c, CLR
         => RESETB_c, E => N_ELINK0_RWA_0_sqmuxa, Q => 
        \ELINK0_ADDRA[7]_net_1\);
    
    USB_SIWU_B_pad : OUTBUF
      port map(D => \VCC\, PAD => USB_SIWU_B);
    
    \RET_STATE_RNI484Q[20]\ : NOR2A
      port map(A => \REG_STATE_ns_a2_2_0_a2_0[2]\, B => N_186, Y
         => N_1189);
    
    \USB_ADBUS_pad_RNIBR08[5]\ : NOR2A
      port map(A => N_1435, B => \USB_ADBUS_c[5]\, Y => N_1454);
    
    \TFC_DINA[6]\ : DFN1E1C0
      port map(D => \USB_ADBUS_c[6]\, CLK => CLK60MHZ_c, CLR => 
        RESETB_c, E => N_TFC_RWA_0_sqmuxa, Q => 
        \TFC_DINA[6]_net_1\);
    
    \ELINKS_STRT_ADDR[1]\ : DFN1C0
      port map(D => \ELINKS_STRT_ADDR_c[1]\, CLK => CLK60MHZ_c, 
        CLR => RESETB_c, Q => \ELINKS_STRT_ADDR_c[1]\);
    
    \REG_STATE_RNO_1[16]\ : NOR2A
      port map(A => \REG_STATE[17]_net_1\, B => USB_RXF_B_c, Y
         => N_127);
    
    \REG_STATE_RNO_0[17]\ : NOR3C
      port map(A => \REG_STATE_ns_0_a2_1[3]\, B => 
        \REG_STATE_ns_0_a2_0[3]\, C => N_1225, Y => N_1551);
    
    \TFC_DINA[7]\ : DFN1E1C0
      port map(D => \USB_ADBUS_c[7]\, CLK => CLK60MHZ_c, CLR => 
        RESETB_c, E => N_TFC_RWA_0_sqmuxa, Q => 
        \TFC_DINA[7]_net_1\);
    
    \REG_ADDR_RNO[7]\ : XA1C
      port map(A => N_162, B => \REG_ADDR[7]_net_1\, C => 
        \REG_STATE[20]_net_1\, Y => N_15);
    
    \REG_ADDR_RNIA4EH[4]\ : OR2A
      port map(A => \REG_ADDR[4]_net_1\, B => N_129, Y => N_134);
    
    \RET_STATE[20]\ : DFN1P0
      port map(D => N_252, CLK => CLK60MHZ_c, PRE => RESETB_c, Q
         => \RET_STATE[20]_net_1\);
    
    \REG_STATE[13]\ : DFN1C0
      port map(D => \REG_STATE_ns[7]\, CLK => CLK60MHZ_c, CLR => 
        RESETB_c, Q => \REG_STATE[13]_net_1\);
    
    \REG_STATE[5]\ : DFN1C0
      port map(D => \REG_STATE_ns[15]\, CLK => CLK60MHZ_c, CLR
         => RESETB_c, Q => \REG_STATE[5]_net_1\);
    
    \PATT_TFC_DAT_pad[0]\ : OUTBUF
      port map(D => \TFC_DOUTB_c[0]\, PAD => PATT_TFC_DAT(0));
    
    \REG_STATE[20]\ : DFN1P0
      port map(D => \REG_STATE_RNO[20]_net_1\, CLK => CLK60MHZ_c, 
        PRE => RESETB_c, Q => \REG_STATE[20]_net_1\);
    
    \REG_STATE_RNIL6NF[12]\ : OR2
      port map(A => \REG_STATE[15]_net_1\, B => 
        \REG_STATE[12]_net_1\, Y => N_68);
    
    \P_OP_MODE_pad[5]\ : OUTBUF
      port map(D => \OP_MODE_c[5]\, PAD => P_OP_MODE(5));
    
    \ELINK0_ADDRA[5]\ : DFN1E1C0
      port map(D => \REG_ADDR[5]_net_1\, CLK => CLK60MHZ_c, CLR
         => RESETB_c, E => N_ELINK0_RWA_0_sqmuxa, Q => 
        \ELINK0_ADDRA[5]_net_1\);
    
    USB_OE_B_pad : OUTBUF
      port map(D => USB_OE_BI_c, PAD => USB_OE_B);
    
    \P_TFC_STOP_ADDR_pad[7]\ : OUTBUF
      port map(D => \TFC_STOP_ADDR_c[7]\, PAD => 
        P_TFC_STOP_ADDR(7));
    
    \USB_RD_DAT[4]\ : DFN1P0
      port map(D => \USB_RD_DAT_RNO[4]_net_1\, CLK => CLK60MHZ_c, 
        PRE => RESETB_c, Q => \USB_RD_DAT_i_0[4]\);
    
    \RET_STATE_RNO_1[11]\ : MX2
      port map(A => N_124, B => \REG_STATE[11]_net_1\, S => 
        USB_RXF_B_c_0, Y => N_219);
    
    \REG_STATE_RNO_1[11]\ : NOR2A
      port map(A => \REG_STATE[12]_net_1\, B => USB_RXF_B_c, Y
         => N_ELINKS_STRT_ADDR_T_0_sqmuxa);
    
    \TFC_ADDRB_pad[7]\ : INBUF
      port map(PAD => TFC_ADDRB(7), Y => \TFC_ADDRB_c[7]\);
    
    \REG_STATE[16]\ : DFN1C0
      port map(D => \REG_STATE_ns[4]\, CLK => CLK60MHZ_c, CLR => 
        RESETB_c, Q => \REG_STATE[16]_net_1\);
    
    \TFC_ADDRA[1]\ : DFN1E1C0
      port map(D => \REG_ADDR[1]_net_1\, CLK => CLK60MHZ_c, CLR
         => RESETB_c, E => N_TFC_RWA_0_sqmuxa, Q => 
        \TFC_ADDRA[1]_net_1\);
    
    \REG_STATE_RNO_5[20]\ : AO1B
      port map(A => N_437, B => \RET_STATE[5]_net_1\, C => N_165, 
        Y => \REG_STATE_ns_i_0_4[0]\);
    
    \PATT_TFC_DAT_pad[7]\ : OUTBUF
      port map(D => \TFC_DOUTB_c[7]\, PAD => PATT_TFC_DAT(7));
    
    \P_TFC_STOP_ADDR_pad[4]\ : OUTBUF
      port map(D => \TFC_STOP_ADDR_c[4]\, PAD => 
        P_TFC_STOP_ADDR(4));
    
    \RET_STATE[14]\ : DFN1C0
      port map(D => \RET_STATE_RNO[14]_net_1\, CLK => CLK60MHZ_c, 
        CLR => RESETB_c, Q => \RET_STATE[14]_net_1\);
    
    \USB_RD_DAT[2]\ : DFN1P0
      port map(D => \USB_RD_DAT_RNO[2]_net_1\, CLK => CLK60MHZ_c, 
        PRE => RESETB_c, Q => \USB_RD_DAT_i_0[2]\);
    
    \REG_STATE_RNO_21[20]\ : NOR2A
      port map(A => N_124, B => N_192_i_1, Y => N_171);
    
    \REG_STATE_RNO_1[20]\ : NOR3A
      port map(A => N_93, B => N_305, C => N_170, Y => N_1418);
    
    \TFC_ADDRB_pad[6]\ : INBUF
      port map(PAD => TFC_ADDRB(6), Y => \TFC_ADDRB_c[6]\);
    
    \TFC_STOP_ADDR[0]\ : DFN1C0
      port map(D => \TFC_STOP_ADDR_c[0]\, CLK => CLK60MHZ_c, CLR
         => RESETB_c, Q => \TFC_STOP_ADDR_c[0]\);
    
    \REG_STATE_RNO_2[4]\ : OA1A
      port map(A => \REG_ADDR[7]_net_1\, B => N_162, C => 
        N_ELINK0_RWA_0_sqmuxa, Y => N_276);
    
    \RET_STATE_RNIKEA6[20]\ : NOR2A
      port map(A => N_1431, B => \RET_STATE[20]_net_1\, Y => 
        \REG_STATE_ns_a2_2_0_a2_0[2]\);
    
    \REG_STATE_RNIEB731[1]\ : NOR3C
      port map(A => \REG_STATE[1]_net_1\, B => N_1428, C => 
        N_1431, Y => N_1458);
    
    \REG_STATE[17]\ : DFN1C0
      port map(D => \REG_STATE_ns[3]\, CLK => CLK60MHZ_c, CLR => 
        RESETB_c, Q => \REG_STATE[17]_net_1\);
    
    \ELINK0_DINA[3]\ : DFN1E1C0
      port map(D => \USB_ADBUS_c[3]\, CLK => CLK60MHZ_c, CLR => 
        RESETB_c, E => N_ELINK0_RWA_0_sqmuxa, Q => 
        \ELINK0_DINA[3]_net_1\);
    
    \ELINKS_STRT_ADDR[5]\ : DFN1C0
      port map(D => \ELINKS_STRT_ADDR_c[5]\, CLK => CLK60MHZ_c, 
        CLR => RESETB_c, Q => \ELINKS_STRT_ADDR_c[5]\);
    
    \REG_STATE_RNO_8[19]\ : NOR3C
      port map(A => N_1431, B => \REG_STATE_ns_i_0_a2_0[1]\, C
         => N_889_i_0, Y => \REG_STATE_ns_i_0_a2_3[1]\);
    
    \RET_STATE_RNO_1[14]\ : MX2
      port map(A => \RET_STATE[14]_net_1\, B => 
        \REG_STATE[14]_net_1\, S => USB_RXF_B_c, Y => N_85);
    
    \REG_STATE_RNO_1[14]\ : NOR2A
      port map(A => \REG_STATE[15]_net_1\, B => USB_RXF_B_c, Y
         => N_OP_MODE_T_0_sqmuxa);
    
    \TFC_DINA[5]\ : DFN1E1C0
      port map(D => \USB_ADBUS_c[5]\, CLK => CLK60MHZ_c, CLR => 
        RESETB_c, E => N_TFC_RWA_0_sqmuxa, Q => 
        \TFC_DINA[5]_net_1\);
    
    \REG_STATE_RNO_22[20]\ : NOR2A
      port map(A => \REG_STATE[1]_net_1\, B => USB_TXE_B_c, Y => 
        \REG_STATE_ns_i_0_a2_27_0[0]\);
    
    \PATT_ELINK0_DAT_pad[1]\ : OUTBUF
      port map(D => \ELINK0_DOUTB_c[1]\, PAD => 
        PATT_ELINK0_DAT(1));
    
    \RET_STATE_RNIFQ04[4]\ : NOR2
      port map(A => \RET_STATE[5]_net_1\, B => 
        \RET_STATE[4]_net_1\, Y => N_1431);
    
    \REG_STATE_RNO_20[20]\ : OA1
      port map(A => N_124, B => N_179, C => 
        \REG_STATE_ns_i_0_a2_27_0[0]\, Y => N_307);
    
    \TFC_DINA[0]\ : DFN1E1C0
      port map(D => \USB_ADBUS_c[0]\, CLK => CLK60MHZ_c, CLR => 
        RESETB_c, E => N_TFC_RWA_0_sqmuxa, Q => 
        \TFC_DINA[0]_net_1\);
    
    \RET_STATE_RNO_1[4]\ : MX2
      port map(A => \RET_STATE[4]_net_1\, B => 
        \REG_STATE[4]_net_1\, S => USB_RXF_B_c_0, Y => N_222);
    
    \REG_ADDR[0]\ : DFN1E1C0
      port map(D => N_248, CLK => CLK60MHZ_c, CLR => RESETB_c, E
         => REG_ADDRe, Q => \REG_ADDR[0]_net_1\);
    
    \RET_STATE_RNO_1[15]\ : MX2
      port map(A => \RET_STATE[15]_net_1\, B => 
        \REG_STATE[15]_net_1\, S => USB_RXF_B_c_0, Y => N_84);
    
    \REG_STATE_RNO_1[15]\ : NOR2B
      port map(A => N_1439, B => N_153, Y => N_292);
    
    \RET_STATE[10]\ : DFN1C0
      port map(D => \RET_STATE_RNO[10]_net_1\, CLK => CLK60MHZ_c, 
        CLR => RESETB_c, Q => N_192_i_1);
    
    \USB_ADBUS_pad_RNIODH31[2]\ : NOR3C
      port map(A => un1_REG_STATE_22_0_0_a2_0_1, B => 
        un1_REG_STATE_22_0_0_a2_0_0, C => 
        un1_REG_STATE_22_0_0_a2_0_2_0, Y => N_1554);
    

end DEF_ARCH; 
