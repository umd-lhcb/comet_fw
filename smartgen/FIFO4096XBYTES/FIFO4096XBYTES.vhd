-- Version: v11.5 SP2 11.5.2.6

library ieee;
use ieee.std_logic_1164.all;
library proasic3e;
use proasic3e.all;

entity FIFO4096XBYTES is

    port( DATA_IN  : in    std_logic_vector(7 downto 0);
          DATA_OUT : out   std_logic_vector(7 downto 0);
          WE_B     : in    std_logic;
          RE_B     : in    std_logic;
          WCLOCK   : in    std_logic;
          RCLOCK   : in    std_logic;
          FULL     : out   std_logic;
          EMPTY    : out   std_logic;
          RESET    : in    std_logic
        );

end FIFO4096XBYTES;

architecture DEF_ARCH of FIFO4096XBYTES is 

  component XNOR3
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          C : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component DFN1C0
    port( D   : in    std_logic := 'U';
          CLK : in    std_logic := 'U';
          CLR : in    std_logic := 'U';
          Q   : out   std_logic
        );
  end component;

  component AND2
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component AND3
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          C : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component XOR3
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

  component AO1
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          C : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component XOR2
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

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

  component BUFF
    port( A : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component INV
    port( A : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component DFN1E1C0
    port( D   : in    std_logic := 'U';
          CLK : in    std_logic := 'U';
          CLR : in    std_logic := 'U';
          E   : in    std_logic := 'U';
          Q   : out   std_logic
        );
  end component;

  component NAND2
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component AND2A
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
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

  component GND
    port(Y : out std_logic); 
  end component;

  component VCC
    port(Y : out std_logic); 
  end component;

    signal \FULL\, \EMPTY\, WEP, REP, READ_RESET_P, WRITE_RESET_P, 
        \MEM_RADDR[0]\, \RBINNXTSHIFT[0]\, \WBINSYNCSHIFT[0]\, 
        \MEM_WADDR[0]\, \WBINNXTSHIFT[0]\, \RBINSYNCSHIFT[0]\, 
        \MEM_RADDR[1]\, \RBINNXTSHIFT[1]\, \WBINSYNCSHIFT[1]\, 
        \MEM_WADDR[1]\, \WBINNXTSHIFT[1]\, \RBINSYNCSHIFT[1]\, 
        \MEM_RADDR[2]\, \RBINNXTSHIFT[2]\, \WBINSYNCSHIFT[2]\, 
        \MEM_WADDR[2]\, \WBINNXTSHIFT[2]\, \RBINSYNCSHIFT[2]\, 
        \MEM_RADDR[3]\, \RBINNXTSHIFT[3]\, \WBINSYNCSHIFT[3]\, 
        \MEM_WADDR[3]\, \WBINNXTSHIFT[3]\, \RBINSYNCSHIFT[3]\, 
        \MEM_RADDR[4]\, \RBINNXTSHIFT[4]\, \WBINSYNCSHIFT[4]\, 
        \MEM_WADDR[4]\, \WBINNXTSHIFT[4]\, \RBINSYNCSHIFT[4]\, 
        \MEM_RADDR[5]\, \RBINNXTSHIFT[5]\, \WBINSYNCSHIFT[5]\, 
        \MEM_WADDR[5]\, \WBINNXTSHIFT[5]\, \RBINSYNCSHIFT[5]\, 
        \MEM_RADDR[6]\, \RBINNXTSHIFT[6]\, \WBINSYNCSHIFT[6]\, 
        \MEM_WADDR[6]\, \WBINNXTSHIFT[6]\, \RBINSYNCSHIFT[6]\, 
        \MEM_RADDR[7]\, \RBINNXTSHIFT[7]\, \WBINSYNCSHIFT[7]\, 
        \MEM_WADDR[7]\, \WBINNXTSHIFT[7]\, \RBINSYNCSHIFT[7]\, 
        \MEM_RADDR[8]\, \RBINNXTSHIFT[8]\, \WBINSYNCSHIFT[8]\, 
        \MEM_WADDR[8]\, \WBINNXTSHIFT[8]\, \RBINSYNCSHIFT[8]\, 
        \MEM_RADDR[9]\, \RBINNXTSHIFT[9]\, \WBINSYNCSHIFT[9]\, 
        \MEM_WADDR[9]\, \WBINNXTSHIFT[9]\, \RBINSYNCSHIFT[9]\, 
        \MEM_RADDR[10]\, \RBINNXTSHIFT[10]\, \WBINSYNCSHIFT[10]\, 
        \MEM_WADDR[10]\, \WBINNXTSHIFT[10]\, \RBINSYNCSHIFT[10]\, 
        \MEM_RADDR[11]\, \RBINNXTSHIFT[11]\, \WBINSYNCSHIFT[11]\, 
        \MEM_WADDR[11]\, \WBINNXTSHIFT[11]\, \RBINSYNCSHIFT[11]\, 
        \MEM_RADDR[12]\, \RBINNXTSHIFT[12]\, READDOMAIN_WMSB, 
        \MEM_WADDR[12]\, \WBINNXTSHIFT[12]\, \RBINSYNCSHIFT[12]\, 
        FULLINT, MEMORYWE, MEMWENEG, \WGRY[0]\, \WGRY[1]\, 
        \WGRY[2]\, \WGRY[3]\, \WGRY[4]\, \WGRY[5]\, \WGRY[6]\, 
        \WGRY[7]\, \WGRY[8]\, \WGRY[9]\, \WGRY[10]\, \WGRY[11]\, 
        \WGRY[12]\, \RGRYSYNC[0]\, \RGRYSYNC[1]\, \RGRYSYNC[2]\, 
        \RGRYSYNC[3]\, \RGRYSYNC[4]\, \RGRYSYNC[5]\, 
        \RGRYSYNC[6]\, \RGRYSYNC[7]\, \RGRYSYNC[8]\, 
        \RGRYSYNC[9]\, \RGRYSYNC[10]\, \RGRYSYNC[11]\, 
        \RGRYSYNC[12]\, EMPTYINT, MEMORYRE, MEMRENEG, DVLDI, 
        DVLDX, \RGRY[0]\, \RGRY[1]\, \RGRY[2]\, \RGRY[3]\, 
        \RGRY[4]\, \RGRY[5]\, \RGRY[6]\, \RGRY[7]\, \RGRY[8]\, 
        \RGRY[9]\, \RGRY[10]\, \RGRY[11]\, \RGRY[12]\, 
        \WGRYSYNC[0]\, \WGRYSYNC[1]\, \WGRYSYNC[2]\, 
        \WGRYSYNC[3]\, \WGRYSYNC[4]\, \WGRYSYNC[5]\, 
        \WGRYSYNC[6]\, \WGRYSYNC[7]\, \WGRYSYNC[8]\, 
        \WGRYSYNC[9]\, \WGRYSYNC[10]\, \WGRYSYNC[11]\, 
        \WGRYSYNC[12]\, \QXI[0]\, \QXI[1]\, \QXI[2]\, \QXI[3]\, 
        \QXI[4]\, \QXI[5]\, \QXI[6]\, \QXI[7]\, DFN1C0_13_Q, 
        DFN1C0_10_Q, DFN1C0_11_Q, DFN1C0_26_Q, DFN1C0_5_Q, 
        DFN1C0_24_Q, DFN1C0_20_Q, DFN1C0_8_Q, DFN1C0_23_Q, 
        DFN1C0_22_Q, DFN1C0_2_Q, DFN1C0_12_Q, DFN1C0_17_Q, 
        XNOR3_1_Y, XNOR3_39_Y, XOR3_2_Y, XNOR3_47_Y, XNOR3_46_Y, 
        XNOR3_0_Y, XOR3_5_Y, XNOR3_24_Y, XNOR3_51_Y, XOR3_1_Y, 
        XNOR3_42_Y, XNOR3_45_Y, XNOR3_10_Y, XNOR3_3_Y, XNOR3_44_Y, 
        XOR3_7_Y, XNOR3_49_Y, XNOR3_7_Y, XNOR3_19_Y, XNOR3_2_Y, 
        XNOR3_37_Y, XNOR3_36_Y, XNOR3_41_Y, XNOR3_9_Y, XNOR3_30_Y, 
        XNOR3_23_Y, XNOR3_43_Y, XNOR3_12_Y, XNOR3_6_Y, XNOR3_5_Y, 
        XOR2_13_Y, XOR2_21_Y, XOR2_42_Y, XOR2_43_Y, XOR2_64_Y, 
        XOR2_70_Y, XOR2_56_Y, XOR2_18_Y, XOR2_55_Y, XOR2_32_Y, 
        XOR2_67_Y, XOR2_5_Y, XOR2_33_Y, AND2_35_Y, AND2_15_Y, 
        AND2_46_Y, AND2_4_Y, AND2_14_Y, AND2_1_Y, AND2_30_Y, 
        AND2_24_Y, AND2_33_Y, AND2_26_Y, AND2_32_Y, AND2_57_Y, 
        XOR2_57_Y, XOR2_6_Y, XOR2_9_Y, XOR2_3_Y, XOR2_10_Y, 
        XOR2_23_Y, XOR2_53_Y, XOR2_4_Y, XOR2_14_Y, XOR2_65_Y, 
        XOR2_50_Y, XOR2_7_Y, XOR2_71_Y, AND2_16_Y, AO1_30_Y, 
        AND2_53_Y, AO1_8_Y, AND2_19_Y, AO1_37_Y, AND2_31_Y, 
        AO1_32_Y, AND2_48_Y, AO1_15_Y, AND2_41_Y, AND2_60_Y, 
        AO1_33_Y, AND2_3_Y, AO1_0_Y, AND2_56_Y, AND2_0_Y, 
        AND2_63_Y, AND2_36_Y, AND2_64_Y, AND2_11_Y, AND2_34_Y, 
        AND2_28_Y, AND2_38_Y, AND2_62_Y, AO1_31_Y, AND2_47_Y, 
        AND2_61_Y, AO1_14_Y, AO1_24_Y, AO1_6_Y, AO1_11_Y, AO1_2_Y, 
        AO1_21_Y, AO1_18_Y, AO1_7_Y, AO1_16_Y, AO1_36_Y, AO1_34_Y, 
        XOR2_36_Y, XOR2_34_Y, XOR2_51_Y, XOR2_72_Y, XOR2_20_Y, 
        XOR2_68_Y, XOR2_63_Y, XOR2_73_Y, XOR2_8_Y, XOR2_29_Y, 
        XOR2_76_Y, XOR2_74_Y, NAND2_1_Y, XOR2_31_Y, XOR2_26_Y, 
        XOR2_17_Y, XOR2_54_Y, XOR2_46_Y, XOR2_28_Y, XOR2_37_Y, 
        XOR2_44_Y, XOR2_45_Y, XOR2_15_Y, XOR2_39_Y, XOR2_2_Y, 
        XOR2_52_Y, AND2_45_Y, AND2_9_Y, AND2_6_Y, AND2_49_Y, 
        AND2_10_Y, AND2_52_Y, AND2_13_Y, AND2_58_Y, AND2_50_Y, 
        AND2_2_Y, AND2_5_Y, AND2_23_Y, XOR2_35_Y, XOR2_30_Y, 
        XOR2_16_Y, XOR2_66_Y, XOR2_62_Y, XOR2_58_Y, XOR2_0_Y, 
        XOR2_47_Y, XOR2_19_Y, XOR2_41_Y, XOR2_60_Y, XOR2_22_Y, 
        XOR2_25_Y, AND2_55_Y, AO1_20_Y, AND2_54_Y, AO1_3_Y, 
        AND2_59_Y, AO1_4_Y, AND2_44_Y, AO1_17_Y, AND2_8_Y, 
        AO1_35_Y, AND2_12_Y, AND2_29_Y, AO1_23_Y, AND2_25_Y, 
        AO1_28_Y, AND2_43_Y, AND2_40_Y, AND2_21_Y, AND2_20_Y, 
        AND2_22_Y, AND2_7_Y, AND2_37_Y, AND2_42_Y, AND2_51_Y, 
        AND2_18_Y, AO1_22_Y, AND2_39_Y, AND2_27_Y, AO1_1_Y, 
        AO1_26_Y, AO1_25_Y, AO1_19_Y, AO1_9_Y, AO1_10_Y, AO1_5_Y, 
        AO1_27_Y, AO1_12_Y, AO1_29_Y, AO1_13_Y, XOR2_48_Y, 
        XOR2_11_Y, XOR2_69_Y, XOR2_75_Y, XOR2_38_Y, XOR2_59_Y, 
        XOR2_24_Y, XOR2_1_Y, XOR2_61_Y, XOR2_27_Y, XOR2_49_Y, 
        XOR2_12_Y, XNOR3_27_Y, XNOR3_8_Y, XOR3_0_Y, XNOR3_18_Y, 
        XNOR3_22_Y, XNOR3_26_Y, XOR3_3_Y, XNOR3_50_Y, XNOR3_25_Y, 
        XOR3_6_Y, XNOR3_14_Y, XNOR3_21_Y, XNOR3_33_Y, XNOR3_29_Y, 
        XNOR3_16_Y, XOR3_4_Y, XNOR3_20_Y, XNOR3_31_Y, XNOR3_38_Y, 
        XNOR3_28_Y, XNOR3_17_Y, XNOR3_40_Y, XNOR3_13_Y, 
        XNOR3_32_Y, XNOR3_4_Y, XNOR3_48_Y, XNOR3_15_Y, XNOR3_34_Y, 
        XNOR3_35_Y, XNOR3_11_Y, DFN1C0_27_Q, DFN1C0_0_Q, 
        DFN1C0_6_Q, DFN1C0_18_Q, DFN1C0_4_Q, DFN1C0_14_Q, 
        DFN1C0_21_Q, DFN1C0_16_Q, DFN1C0_25_Q, DFN1C0_1_Q, 
        DFN1C0_7_Q, DFN1C0_9_Q, DFN1C0_19_Q, 
        \RAM4K9_QXI[0]_DOUTA0\, \RAM4K9_QXI[1]_DOUTA0\, 
        \RAM4K9_QXI[2]_DOUTA0\, \RAM4K9_QXI[3]_DOUTA0\, 
        \RAM4K9_QXI[4]_DOUTA0\, \RAM4K9_QXI[5]_DOUTA0\, 
        \RAM4K9_QXI[6]_DOUTA0\, \RAM4K9_QXI[7]_DOUTA0\, AND3_0_Y, 
        XNOR2_22_Y, XNOR2_12_Y, XNOR2_7_Y, XNOR2_13_Y, XNOR2_14_Y, 
        XNOR2_24_Y, XNOR2_10_Y, XNOR2_18_Y, XNOR2_20_Y, 
        XNOR2_16_Y, XNOR2_9_Y, XNOR2_23_Y, XNOR2_4_Y, AND3_7_Y, 
        AND3_8_Y, AND2_17_Y, AND3_9_Y, AND3_6_Y, DFN1C0_15_Q, 
        AND2A_0_Y, DFN1C0_3_Q, AND3_1_Y, XOR2_40_Y, XNOR2_1_Y, 
        XNOR2_17_Y, XNOR2_21_Y, XNOR2_19_Y, XNOR2_0_Y, XNOR2_5_Y, 
        XNOR2_15_Y, XNOR2_8_Y, XNOR2_2_Y, XNOR2_3_Y, XNOR2_6_Y, 
        XNOR2_11_Y, AND3_5_Y, AND3_2_Y, AND2_65_Y, AND3_4_Y, 
        AND3_3_Y, NAND2_0_Y, \VCC\, \GND\ : std_logic;
    signal GND_power_net1 : std_logic;
    signal VCC_power_net1 : std_logic;

begin 

    FULL <= \FULL\;
    EMPTY <= \EMPTY\;
    \GND\ <= GND_power_net1;
    \VCC\ <= VCC_power_net1;

    XNOR3_14 : XNOR3
      port map(A => \WGRYSYNC[9]\, B => \WGRYSYNC[8]\, C => 
        \WGRYSYNC[7]\, Y => XNOR3_14_Y);
    
    XNOR3_5 : XNOR3
      port map(A => \RGRYSYNC[0]\, B => XNOR3_6_Y, C => 
        XNOR3_23_Y, Y => XNOR3_5_Y);
    
    \DFN1C0_RGRYSYNC[4]\ : DFN1C0
      port map(D => DFN1C0_4_Q, CLK => WCLOCK, CLR => 
        WRITE_RESET_P, Q => \RGRYSYNC[4]\);
    
    XNOR3_45 : XNOR3
      port map(A => \RGRYSYNC[12]\, B => \RGRYSYNC[11]\, C => 
        \RGRYSYNC[10]\, Y => XNOR3_45_Y);
    
    AND2_2 : AND2
      port map(A => \MEM_WADDR[10]\, B => \GND\, Y => AND2_2_Y);
    
    AND3_6 : AND3
      port map(A => XNOR2_14_Y, B => XNOR2_24_Y, C => XNOR2_10_Y, 
        Y => AND3_6_Y);
    
    \XOR3_WBINSYNCSHIFT[10]\ : XOR3
      port map(A => \WGRYSYNC[12]\, B => \WGRYSYNC[11]\, C => 
        \WGRYSYNC[10]\, Y => \WBINSYNCSHIFT[10]\);
    
    AND2_20 : AND2
      port map(A => AND2_29_Y, B => AND2_59_Y, Y => AND2_20_Y);
    
    XNOR2_13 : XNOR2
      port map(A => \RBINNXTSHIFT[2]\, B => \WBINSYNCSHIFT[2]\, Y
         => XNOR2_13_Y);
    
    AO1_11 : AO1
      port map(A => XOR2_10_Y, B => AO1_6_Y, C => AND2_4_Y, Y => 
        AO1_11_Y);
    
    AND2_11 : AND2
      port map(A => AND2_16_Y, B => XOR2_9_Y, Y => AND2_11_Y);
    
    \XOR2_WBINNXTSHIFT[2]\ : XOR2
      port map(A => XOR2_11_Y, B => AO1_1_Y, Y => 
        \WBINNXTSHIFT[2]\);
    
    XNOR3_34 : XNOR3
      port map(A => \WGRYSYNC[3]\, B => \WGRYSYNC[2]\, C => 
        \WGRYSYNC[1]\, Y => XNOR3_34_Y);
    
    XNOR3_25 : XNOR3
      port map(A => \WGRYSYNC[9]\, B => \WGRYSYNC[8]\, C => 
        \WGRYSYNC[7]\, Y => XNOR3_25_Y);
    
    AND2_22 : AND2
      port map(A => AND2_40_Y, B => AND2_8_Y, Y => AND2_22_Y);
    
    \DFN1C0_RGRY[9]\ : DFN1C0
      port map(D => XOR2_32_Y, CLK => RCLOCK, CLR => READ_RESET_P, 
        Q => \RGRY[9]\);
    
    DFN1C0_FULL : DFN1C0
      port map(D => FULLINT, CLK => WCLOCK, CLR => WRITE_RESET_P, 
        Q => \FULL\);
    
    XNOR2_9 : XNOR2
      port map(A => \RBINNXTSHIFT[9]\, B => \WBINSYNCSHIFT[9]\, Y
         => XNOR2_9_Y);
    
    \XOR3_RBINSYNCSHIFT[10]\ : XOR3
      port map(A => \RGRYSYNC[12]\, B => \RGRYSYNC[11]\, C => 
        \RGRYSYNC[10]\, Y => \RBINSYNCSHIFT[10]\);
    
    DFN1C0_17 : DFN1C0
      port map(D => \WGRY[12]\, CLK => RCLOCK, CLR => 
        READ_RESET_P, Q => DFN1C0_17_Q);
    
    XOR2_19 : XOR2
      port map(A => \MEM_WADDR[8]\, B => \GND\, Y => XOR2_19_Y);
    
    AND2_44 : AND2
      port map(A => XOR2_0_Y, B => XOR2_47_Y, Y => AND2_44_Y);
    
    \RAM4K9_QXI[6]\ : RAM4K9
      port map(ADDRA11 => \MEM_WADDR[11]\, ADDRA10 => 
        \MEM_WADDR[10]\, ADDRA9 => \MEM_WADDR[9]\, ADDRA8 => 
        \MEM_WADDR[8]\, ADDRA7 => \MEM_WADDR[7]\, ADDRA6 => 
        \MEM_WADDR[6]\, ADDRA5 => \MEM_WADDR[5]\, ADDRA4 => 
        \MEM_WADDR[4]\, ADDRA3 => \MEM_WADDR[3]\, ADDRA2 => 
        \MEM_WADDR[2]\, ADDRA1 => \MEM_WADDR[1]\, ADDRA0 => 
        \MEM_WADDR[0]\, ADDRB11 => \MEM_RADDR[11]\, ADDRB10 => 
        \MEM_RADDR[10]\, ADDRB9 => \MEM_RADDR[9]\, ADDRB8 => 
        \MEM_RADDR[8]\, ADDRB7 => \MEM_RADDR[7]\, ADDRB6 => 
        \MEM_RADDR[6]\, ADDRB5 => \MEM_RADDR[5]\, ADDRB4 => 
        \MEM_RADDR[4]\, ADDRB3 => \MEM_RADDR[3]\, ADDRB2 => 
        \MEM_RADDR[2]\, ADDRB1 => \MEM_RADDR[1]\, ADDRB0 => 
        \MEM_RADDR[0]\, DINA8 => \GND\, DINA7 => \GND\, DINA6 => 
        \GND\, DINA5 => \GND\, DINA4 => \GND\, DINA3 => \GND\, 
        DINA2 => \GND\, DINA1 => \GND\, DINA0 => DATA_IN(6), 
        DINB8 => \GND\, DINB7 => \GND\, DINB6 => \GND\, DINB5 => 
        \GND\, DINB4 => \GND\, DINB3 => \GND\, DINB2 => \GND\, 
        DINB1 => \GND\, DINB0 => \GND\, WIDTHA0 => \GND\, WIDTHA1
         => \GND\, WIDTHB0 => \GND\, WIDTHB1 => \GND\, PIPEA => 
        \GND\, PIPEB => \GND\, WMODEA => \GND\, WMODEB => \GND\, 
        BLKA => MEMWENEG, BLKB => MEMRENEG, WENA => \GND\, WENB
         => \VCC\, CLKA => WCLOCK, CLKB => RCLOCK, RESET => 
        WRITE_RESET_P, DOUTA8 => OPEN, DOUTA7 => OPEN, DOUTA6 => 
        OPEN, DOUTA5 => OPEN, DOUTA4 => OPEN, DOUTA3 => OPEN, 
        DOUTA2 => OPEN, DOUTA1 => OPEN, DOUTA0 => 
        \RAM4K9_QXI[6]_DOUTA0\, DOUTB8 => OPEN, DOUTB7 => OPEN, 
        DOUTB6 => OPEN, DOUTB5 => OPEN, DOUTB4 => OPEN, DOUTB3
         => OPEN, DOUTB2 => OPEN, DOUTB1 => OPEN, DOUTB0 => 
        \QXI[6]\);
    
    AO1_31 : AO1
      port map(A => XOR2_71_Y, B => AO1_34_Y, C => AND2_57_Y, Y
         => AO1_31_Y);
    
    XOR2_23 : XOR2
      port map(A => \MEM_RADDR[5]\, B => \GND\, Y => XOR2_23_Y);
    
    XOR2_1 : XOR2
      port map(A => \MEM_WADDR[8]\, B => \GND\, Y => XOR2_1_Y);
    
    XNOR3_13 : XNOR3
      port map(A => \WGRYSYNC[9]\, B => \WGRYSYNC[8]\, C => 
        \WGRYSYNC[7]\, Y => XNOR3_13_Y);
    
    \DFN1C0_RGRYSYNC[3]\ : DFN1C0
      port map(D => DFN1C0_18_Q, CLK => WCLOCK, CLR => 
        WRITE_RESET_P, Q => \RGRYSYNC[3]\);
    
    XOR2_47 : XOR2
      port map(A => \MEM_WADDR[7]\, B => \GND\, Y => XOR2_47_Y);
    
    XOR2_38 : XOR2
      port map(A => \MEM_WADDR[5]\, B => \GND\, Y => XOR2_38_Y);
    
    BUFF_READDOMAIN_WMSB : BUFF
      port map(A => \WGRYSYNC[12]\, Y => READDOMAIN_WMSB);
    
    \XOR2_RBINNXTSHIFT[0]\ : XOR2
      port map(A => \MEM_RADDR[0]\, B => MEMORYRE, Y => 
        \RBINNXTSHIFT[0]\);
    
    AO1_7 : AO1
      port map(A => XOR2_14_Y, B => AO1_18_Y, C => AND2_24_Y, Y
         => AO1_7_Y);
    
    DFN1C0_9 : DFN1C0
      port map(D => \RGRY[11]\, CLK => WCLOCK, CLR => 
        WRITE_RESET_P, Q => DFN1C0_9_Q);
    
    \DFN1C0_WGRY[6]\ : DFN1C0
      port map(D => XOR2_37_Y, CLK => WCLOCK, CLR => 
        WRITE_RESET_P, Q => \WGRY[6]\);
    
    AND2_18 : AND2
      port map(A => AND2_22_Y, B => XOR2_60_Y, Y => AND2_18_Y);
    
    AND2_15 : AND2
      port map(A => \MEM_RADDR[2]\, B => \GND\, Y => AND2_15_Y);
    
    XNOR3_33 : XNOR3
      port map(A => \WGRYSYNC[6]\, B => \WGRYSYNC[5]\, C => 
        XNOR3_21_Y, Y => XNOR3_33_Y);
    
    AO1_25 : AO1
      port map(A => AND2_54_Y, B => AO1_1_Y, C => AO1_20_Y, Y => 
        AO1_25_Y);
    
    DFN1C0_WRITE_RESET_P : DFN1C0
      port map(D => DFN1C0_15_Q, CLK => WCLOCK, CLR => RESET, Q
         => WRITE_RESET_P);
    
    DFN1C0_26 : DFN1C0
      port map(D => \WGRY[3]\, CLK => RCLOCK, CLR => READ_RESET_P, 
        Q => DFN1C0_26_Q);
    
    XOR2_45 : XOR2
      port map(A => \WBINNXTSHIFT[8]\, B => \WBINNXTSHIFT[9]\, Y
         => XOR2_45_Y);
    
    \DFN1C0_RGRYSYNC[7]\ : DFN1C0
      port map(D => DFN1C0_16_Q, CLK => WCLOCK, CLR => 
        WRITE_RESET_P, Q => \RGRYSYNC[7]\);
    
    \XOR2_RBINNXTSHIFT[9]\ : XOR2
      port map(A => XOR2_8_Y, B => AO1_7_Y, Y => 
        \RBINNXTSHIFT[9]\);
    
    DFN1C0_11 : DFN1C0
      port map(D => \WGRY[2]\, CLK => RCLOCK, CLR => READ_RESET_P, 
        Q => DFN1C0_11_Q);
    
    DFN1C0_0 : DFN1C0
      port map(D => \RGRY[1]\, CLK => WCLOCK, CLR => 
        WRITE_RESET_P, Q => DFN1C0_0_Q);
    
    \BUFF_RBINSYNCSHIFT[12]\ : BUFF
      port map(A => \RGRYSYNC[12]\, Y => \RBINSYNCSHIFT[12]\);
    
    AND2_1 : AND2
      port map(A => \MEM_RADDR[6]\, B => \GND\, Y => AND2_1_Y);
    
    \DFN1C0_MEM_WADDR[0]\ : DFN1C0
      port map(D => \WBINNXTSHIFT[0]\, CLK => WCLOCK, CLR => 
        WRITE_RESET_P, Q => \MEM_WADDR[0]\);
    
    XNOR2_21 : XNOR2
      port map(A => \RBINSYNCSHIFT[2]\, B => \WBINNXTSHIFT[2]\, Y
         => XNOR2_21_Y);
    
    AND2_49 : AND2
      port map(A => \MEM_WADDR[4]\, B => \GND\, Y => AND2_49_Y);
    
    \DFN1C0_MEM_WADDR[3]\ : DFN1C0
      port map(D => \WBINNXTSHIFT[3]\, CLK => WCLOCK, CLR => 
        WRITE_RESET_P, Q => \MEM_WADDR[3]\);
    
    \DFN1C0_MEM_RADDR[1]\ : DFN1C0
      port map(D => \RBINNXTSHIFT[1]\, CLK => RCLOCK, CLR => 
        READ_RESET_P, Q => \MEM_RADDR[1]\);
    
    AO1_8 : AO1
      port map(A => XOR2_23_Y, B => AND2_4_Y, C => AND2_14_Y, Y
         => AO1_8_Y);
    
    DFN1C0_20 : DFN1C0
      port map(D => \WGRY[6]\, CLK => RCLOCK, CLR => READ_RESET_P, 
        Q => DFN1C0_20_Q);
    
    AND2_10 : AND2
      port map(A => \MEM_WADDR[5]\, B => \GND\, Y => AND2_10_Y);
    
    \DFN1C0_RGRYSYNC[6]\ : DFN1C0
      port map(D => DFN1C0_21_Q, CLK => WCLOCK, CLR => 
        WRITE_RESET_P, Q => \RGRYSYNC[6]\);
    
    AND2_7 : AND2
      port map(A => AND2_55_Y, B => XOR2_16_Y, Y => AND2_7_Y);
    
    XOR2_20 : XOR2
      port map(A => \MEM_RADDR[5]\, B => \GND\, Y => XOR2_20_Y);
    
    XOR2_63 : XOR2
      port map(A => \MEM_RADDR[7]\, B => \GND\, Y => XOR2_63_Y);
    
    AND2_12 : AND2
      port map(A => XOR2_60_Y, B => XOR2_22_Y, Y => AND2_12_Y);
    
    \RAM4K9_QXI[2]\ : RAM4K9
      port map(ADDRA11 => \MEM_WADDR[11]\, ADDRA10 => 
        \MEM_WADDR[10]\, ADDRA9 => \MEM_WADDR[9]\, ADDRA8 => 
        \MEM_WADDR[8]\, ADDRA7 => \MEM_WADDR[7]\, ADDRA6 => 
        \MEM_WADDR[6]\, ADDRA5 => \MEM_WADDR[5]\, ADDRA4 => 
        \MEM_WADDR[4]\, ADDRA3 => \MEM_WADDR[3]\, ADDRA2 => 
        \MEM_WADDR[2]\, ADDRA1 => \MEM_WADDR[1]\, ADDRA0 => 
        \MEM_WADDR[0]\, ADDRB11 => \MEM_RADDR[11]\, ADDRB10 => 
        \MEM_RADDR[10]\, ADDRB9 => \MEM_RADDR[9]\, ADDRB8 => 
        \MEM_RADDR[8]\, ADDRB7 => \MEM_RADDR[7]\, ADDRB6 => 
        \MEM_RADDR[6]\, ADDRB5 => \MEM_RADDR[5]\, ADDRB4 => 
        \MEM_RADDR[4]\, ADDRB3 => \MEM_RADDR[3]\, ADDRB2 => 
        \MEM_RADDR[2]\, ADDRB1 => \MEM_RADDR[1]\, ADDRB0 => 
        \MEM_RADDR[0]\, DINA8 => \GND\, DINA7 => \GND\, DINA6 => 
        \GND\, DINA5 => \GND\, DINA4 => \GND\, DINA3 => \GND\, 
        DINA2 => \GND\, DINA1 => \GND\, DINA0 => DATA_IN(2), 
        DINB8 => \GND\, DINB7 => \GND\, DINB6 => \GND\, DINB5 => 
        \GND\, DINB4 => \GND\, DINB3 => \GND\, DINB2 => \GND\, 
        DINB1 => \GND\, DINB0 => \GND\, WIDTHA0 => \GND\, WIDTHA1
         => \GND\, WIDTHB0 => \GND\, WIDTHB1 => \GND\, PIPEA => 
        \GND\, PIPEB => \GND\, WMODEA => \GND\, WMODEB => \GND\, 
        BLKA => MEMWENEG, BLKB => MEMRENEG, WENA => \GND\, WENB
         => \VCC\, CLKA => WCLOCK, CLKB => RCLOCK, RESET => 
        WRITE_RESET_P, DOUTA8 => OPEN, DOUTA7 => OPEN, DOUTA6 => 
        OPEN, DOUTA5 => OPEN, DOUTA4 => OPEN, DOUTA3 => OPEN, 
        DOUTA2 => OPEN, DOUTA1 => OPEN, DOUTA0 => 
        \RAM4K9_QXI[2]_DOUTA0\, DOUTB8 => OPEN, DOUTB7 => OPEN, 
        DOUTB6 => OPEN, DOUTB5 => OPEN, DOUTB4 => OPEN, DOUTB3
         => OPEN, DOUTB2 => OPEN, DOUTB1 => OPEN, DOUTB0 => 
        \QXI[2]\);
    
    \DFN1C0_WGRY[5]\ : DFN1C0
      port map(D => XOR2_28_Y, CLK => WCLOCK, CLR => 
        WRITE_RESET_P, Q => \WGRY[5]\);
    
    XOR2_52 : XOR2
      port map(A => \WBINNXTSHIFT[12]\, B => \GND\, Y => 
        XOR2_52_Y);
    
    XNOR3_40 : XNOR3
      port map(A => XNOR3_17_Y, B => XNOR3_31_Y, C => XNOR3_38_Y, 
        Y => XNOR3_40_Y);
    
    AND2_61 : AND2
      port map(A => \MEM_RADDR[0]\, B => MEMORYRE, Y => AND2_61_Y);
    
    \XOR2_WBINNXTSHIFT[0]\ : XOR2
      port map(A => \MEM_WADDR[0]\, B => MEMORYWE, Y => 
        \WBINNXTSHIFT[0]\);
    
    \DFN1C0_MEM_WADDR[4]\ : DFN1C0
      port map(D => \WBINNXTSHIFT[4]\, CLK => WCLOCK, CLR => 
        WRITE_RESET_P, Q => \MEM_WADDR[4]\);
    
    AO1_15 : AO1
      port map(A => XOR2_7_Y, B => AND2_26_Y, C => AND2_32_Y, Y
         => AO1_15_Y);
    
    \DFN1C0_WGRY[7]\ : DFN1C0
      port map(D => XOR2_44_Y, CLK => WCLOCK, CLR => 
        WRITE_RESET_P, Q => \WGRY[7]\);
    
    \DFN1C0_MEM_WADDR[12]\ : DFN1C0
      port map(D => \WBINNXTSHIFT[12]\, CLK => WCLOCK, CLR => 
        WRITE_RESET_P, Q => \MEM_WADDR[12]\);
    
    DFN1C0_READ_RESET_P : DFN1C0
      port map(D => DFN1C0_3_Q, CLK => RCLOCK, CLR => RESET, Q
         => READ_RESET_P);
    
    \XNOR3_WBINSYNCSHIFT[2]\ : XNOR3
      port map(A => XNOR3_29_Y, B => XNOR3_16_Y, C => XNOR3_20_Y, 
        Y => \WBINSYNCSHIFT[2]\);
    
    AND2_EMPTYINT : AND2
      port map(A => AND3_0_Y, B => XNOR2_22_Y, Y => EMPTYINT);
    
    \XNOR2_RBINSYNCSHIFT[5]\ : XNOR2
      port map(A => XNOR3_42_Y, B => XNOR3_10_Y, Y => 
        \RBINSYNCSHIFT[5]\);
    
    XOR2_24 : XOR2
      port map(A => \MEM_WADDR[7]\, B => \GND\, Y => XOR2_24_Y);
    
    AND2_57 : AND2
      port map(A => \MEM_RADDR[12]\, B => \GND\, Y => AND2_57_Y);
    
    XNOR3_20 : XNOR3
      port map(A => \WGRYSYNC[3]\, B => \WGRYSYNC[2]\, C => 
        XOR3_4_Y, Y => XNOR3_20_Y);
    
    XOR2_21 : XOR2
      port map(A => \RBINNXTSHIFT[1]\, B => \RBINNXTSHIFT[2]\, Y
         => XOR2_21_Y);
    
    AO1_35 : AO1
      port map(A => XOR2_22_Y, B => AND2_2_Y, C => AND2_5_Y, Y
         => AO1_35_Y);
    
    \XOR2_WBINNXTSHIFT[9]\ : XOR2
      port map(A => XOR2_61_Y, B => AO1_27_Y, Y => 
        \WBINNXTSHIFT[9]\);
    
    \DFN1C0_WGRYSYNC[11]\ : DFN1C0
      port map(D => DFN1C0_12_Q, CLK => RCLOCK, CLR => 
        READ_RESET_P, Q => \WGRYSYNC[11]\);
    
    \XNOR2_RBINSYNCSHIFT[9]\ : XNOR2
      port map(A => \RGRYSYNC[9]\, B => XNOR3_46_Y, Y => 
        \RBINSYNCSHIFT[9]\);
    
    \DFN1C0_WGRYSYNC[12]\ : DFN1C0
      port map(D => DFN1C0_17_Q, CLK => RCLOCK, CLR => 
        READ_RESET_P, Q => \WGRYSYNC[12]\);
    
    AND2_46 : AND2
      port map(A => \MEM_RADDR[3]\, B => \GND\, Y => AND2_46_Y);
    
    XNOR3_9 : XNOR3
      port map(A => \RGRYSYNC[6]\, B => \RGRYSYNC[5]\, C => 
        \RGRYSYNC[4]\, Y => XNOR3_9_Y);
    
    XNOR3_8 : XNOR3
      port map(A => \WGRYSYNC[6]\, B => \WGRYSYNC[5]\, C => 
        \WGRYSYNC[4]\, Y => XNOR3_8_Y);
    
    \XOR2_RBINNXTSHIFT[8]\ : XOR2
      port map(A => XOR2_73_Y, B => AO1_18_Y, Y => 
        \RBINNXTSHIFT[8]\);
    
    \XNOR2_RBINSYNCSHIFT[1]\ : XNOR2
      port map(A => XNOR3_2_Y, B => XNOR3_36_Y, Y => 
        \RBINSYNCSHIFT[1]\);
    
    XNOR3_50 : XNOR3
      port map(A => \WGRYSYNC[12]\, B => \WGRYSYNC[11]\, C => 
        \WGRYSYNC[10]\, Y => XNOR3_50_Y);
    
    XOR2_16 : XOR2
      port map(A => \MEM_WADDR[2]\, B => \GND\, Y => XOR2_16_Y);
    
    DFN1C0_4 : DFN1C0
      port map(D => \RGRY[4]\, CLK => WCLOCK, CLR => 
        WRITE_RESET_P, Q => DFN1C0_4_Q);
    
    XOR2_60 : XOR2
      port map(A => \MEM_WADDR[10]\, B => \GND\, Y => XOR2_60_Y);
    
    DFN1C0_14 : DFN1C0
      port map(D => \RGRY[5]\, CLK => WCLOCK, CLR => 
        WRITE_RESET_P, Q => DFN1C0_14_Q);
    
    AND2_65 : AND2
      port map(A => XNOR2_6_Y, B => XNOR2_11_Y, Y => AND2_65_Y);
    
    AND2_43 : AND2
      port map(A => AND2_8_Y, B => AND2_12_Y, Y => AND2_43_Y);
    
    AO1_24 : AO1
      port map(A => XOR2_9_Y, B => AO1_14_Y, C => AND2_15_Y, Y
         => AO1_24_Y);
    
    \XNOR3_WBINSYNCSHIFT[8]\ : XNOR3
      port map(A => \WGRYSYNC[9]\, B => \WGRYSYNC[8]\, C => 
        XNOR3_50_Y, Y => \WBINSYNCSHIFT[8]\);
    
    AND3_3 : AND3
      port map(A => XNOR2_19_Y, B => XNOR2_0_Y, C => XNOR2_5_Y, Y
         => AND3_3_Y);
    
    MEMWEBUBBLE : INV
      port map(A => MEMORYWE, Y => MEMWENEG);
    
    AND2_6 : AND2
      port map(A => \MEM_WADDR[3]\, B => \GND\, Y => AND2_6_Y);
    
    \RAM4K9_QXI[1]\ : RAM4K9
      port map(ADDRA11 => \MEM_WADDR[11]\, ADDRA10 => 
        \MEM_WADDR[10]\, ADDRA9 => \MEM_WADDR[9]\, ADDRA8 => 
        \MEM_WADDR[8]\, ADDRA7 => \MEM_WADDR[7]\, ADDRA6 => 
        \MEM_WADDR[6]\, ADDRA5 => \MEM_WADDR[5]\, ADDRA4 => 
        \MEM_WADDR[4]\, ADDRA3 => \MEM_WADDR[3]\, ADDRA2 => 
        \MEM_WADDR[2]\, ADDRA1 => \MEM_WADDR[1]\, ADDRA0 => 
        \MEM_WADDR[0]\, ADDRB11 => \MEM_RADDR[11]\, ADDRB10 => 
        \MEM_RADDR[10]\, ADDRB9 => \MEM_RADDR[9]\, ADDRB8 => 
        \MEM_RADDR[8]\, ADDRB7 => \MEM_RADDR[7]\, ADDRB6 => 
        \MEM_RADDR[6]\, ADDRB5 => \MEM_RADDR[5]\, ADDRB4 => 
        \MEM_RADDR[4]\, ADDRB3 => \MEM_RADDR[3]\, ADDRB2 => 
        \MEM_RADDR[2]\, ADDRB1 => \MEM_RADDR[1]\, ADDRB0 => 
        \MEM_RADDR[0]\, DINA8 => \GND\, DINA7 => \GND\, DINA6 => 
        \GND\, DINA5 => \GND\, DINA4 => \GND\, DINA3 => \GND\, 
        DINA2 => \GND\, DINA1 => \GND\, DINA0 => DATA_IN(1), 
        DINB8 => \GND\, DINB7 => \GND\, DINB6 => \GND\, DINB5 => 
        \GND\, DINB4 => \GND\, DINB3 => \GND\, DINB2 => \GND\, 
        DINB1 => \GND\, DINB0 => \GND\, WIDTHA0 => \GND\, WIDTHA1
         => \GND\, WIDTHB0 => \GND\, WIDTHB1 => \GND\, PIPEA => 
        \GND\, PIPEB => \GND\, WMODEA => \GND\, WMODEB => \GND\, 
        BLKA => MEMWENEG, BLKB => MEMRENEG, WENA => \GND\, WENB
         => \VCC\, CLKA => WCLOCK, CLKB => RCLOCK, RESET => 
        WRITE_RESET_P, DOUTA8 => OPEN, DOUTA7 => OPEN, DOUTA6 => 
        OPEN, DOUTA5 => OPEN, DOUTA4 => OPEN, DOUTA3 => OPEN, 
        DOUTA2 => OPEN, DOUTA1 => OPEN, DOUTA0 => 
        \RAM4K9_QXI[1]_DOUTA0\, DOUTB8 => OPEN, DOUTB7 => OPEN, 
        DOUTB6 => OPEN, DOUTB5 => OPEN, DOUTB4 => OPEN, DOUTB3
         => OPEN, DOUTB2 => OPEN, DOUTB1 => OPEN, DOUTB0 => 
        \QXI[1]\);
    
    XOR2_64 : XOR2
      port map(A => \RBINNXTSHIFT[4]\, B => \RBINNXTSHIFT[5]\, Y
         => XOR2_64_Y);
    
    AND3_0 : AND3
      port map(A => XNOR2_9_Y, B => AND3_8_Y, C => AND2_17_Y, Y
         => AND3_0_Y);
    
    \DFN1C0_MEM_RADDR[2]\ : DFN1C0
      port map(D => \RBINNXTSHIFT[2]\, CLK => RCLOCK, CLR => 
        READ_RESET_P, Q => \MEM_RADDR[2]\);
    
    AND2_60 : AND2
      port map(A => AND2_16_Y, B => AND2_53_Y, Y => AND2_60_Y);
    
    \DFN1E1C0_DATA_OUT[0]\ : DFN1E1C0
      port map(D => \QXI[0]\, CLK => RCLOCK, CLR => READ_RESET_P, 
        E => DVLDI, Q => DATA_OUT(0));
    
    \DFN1C0_RGRYSYNC[11]\ : DFN1C0
      port map(D => DFN1C0_9_Q, CLK => WCLOCK, CLR => 
        WRITE_RESET_P, Q => \RGRYSYNC[11]\);
    
    XOR2_61 : XOR2
      port map(A => \MEM_WADDR[9]\, B => \GND\, Y => XOR2_61_Y);
    
    XOR2_57 : XOR2
      port map(A => \MEM_RADDR[0]\, B => MEMORYRE, Y => XOR2_57_Y);
    
    \DFN1C0_RGRY[2]\ : DFN1C0
      port map(D => XOR2_42_Y, CLK => RCLOCK, CLR => READ_RESET_P, 
        Q => \RGRY[2]\);
    
    AND2_62 : AND2
      port map(A => AND2_64_Y, B => XOR2_50_Y, Y => AND2_62_Y);
    
    XOR2_33 : XOR2
      port map(A => \RBINNXTSHIFT[12]\, B => \GND\, Y => 
        XOR2_33_Y);
    
    XNOR2_2 : XNOR2
      port map(A => \RBINSYNCSHIFT[8]\, B => \WBINNXTSHIFT[8]\, Y
         => XNOR2_2_Y);
    
    XNOR2_19 : XNOR2
      port map(A => \RBINSYNCSHIFT[3]\, B => \WBINNXTSHIFT[3]\, Y
         => XNOR2_19_Y);
    
    XOR2_49 : XOR2
      port map(A => \MEM_WADDR[11]\, B => \GND\, Y => XOR2_49_Y);
    
    \XOR2_WBINNXTSHIFT[8]\ : XOR2
      port map(A => XOR2_1_Y, B => AO1_5_Y, Y => 
        \WBINNXTSHIFT[8]\);
    
    AO1_14 : AO1
      port map(A => XOR2_6_Y, B => AND2_61_Y, C => AND2_35_Y, Y
         => AO1_14_Y);
    
    XOR2_4 : XOR2
      port map(A => \MEM_RADDR[7]\, B => \GND\, Y => XOR2_4_Y);
    
    \XNOR2_WBINSYNCSHIFT[3]\ : XNOR2
      port map(A => XNOR3_8_Y, B => XNOR3_18_Y, Y => 
        \WBINSYNCSHIFT[3]\);
    
    AND3_1 : AND3
      port map(A => XNOR2_3_Y, B => AND3_2_Y, C => AND2_65_Y, Y
         => AND3_1_Y);
    
    \DFN1E1C0_DATA_OUT[7]\ : DFN1E1C0
      port map(D => \QXI[7]\, CLK => RCLOCK, CLR => READ_RESET_P, 
        E => DVLDI, Q => DATA_OUT(7));
    
    XOR2_55 : XOR2
      port map(A => \RBINNXTSHIFT[8]\, B => \RBINNXTSHIFT[9]\, Y
         => XOR2_55_Y);
    
    AND2_24 : AND2
      port map(A => \MEM_RADDR[8]\, B => \GND\, Y => AND2_24_Y);
    
    \DFN1E1C0_DATA_OUT[5]\ : DFN1E1C0
      port map(D => \QXI[5]\, CLK => RCLOCK, CLR => READ_RESET_P, 
        E => DVLDI, Q => DATA_OUT(5));
    
    XOR2_72 : XOR2
      port map(A => \MEM_RADDR[4]\, B => \GND\, Y => XOR2_72_Y);
    
    XNOR2_0 : XNOR2
      port map(A => \RBINSYNCSHIFT[4]\, B => \WBINNXTSHIFT[4]\, Y
         => XNOR2_0_Y);
    
    AND2_31 : AND2
      port map(A => XOR2_53_Y, B => XOR2_4_Y, Y => AND2_31_Y);
    
    \DFN1C0_MEM_WADDR[10]\ : DFN1C0
      port map(D => \WBINNXTSHIFT[10]\, CLK => WCLOCK, CLR => 
        WRITE_RESET_P, Q => \MEM_WADDR[10]\);
    
    DFN1C0_15 : DFN1C0
      port map(D => \VCC\, CLK => WCLOCK, CLR => RESET, Q => 
        DFN1C0_15_Q);
    
    AO1_34 : AO1
      port map(A => AND2_56_Y, B => AO1_18_Y, C => AO1_0_Y, Y => 
        AO1_34_Y);
    
    XNOR3_42 : XNOR3
      port map(A => \RGRYSYNC[9]\, B => \RGRYSYNC[8]\, C => 
        \RGRYSYNC[7]\, Y => XNOR3_42_Y);
    
    DFN1C0_12 : DFN1C0
      port map(D => \WGRY[11]\, CLK => RCLOCK, CLR => 
        READ_RESET_P, Q => DFN1C0_12_Q);
    
    \XOR2_RBINNXTSHIFT[12]\ : XOR2
      port map(A => XOR2_74_Y, B => AO1_34_Y, Y => 
        \RBINNXTSHIFT[12]\);
    
    XOR2_18 : XOR2
      port map(A => \RBINNXTSHIFT[7]\, B => \RBINNXTSHIFT[8]\, Y
         => XOR2_18_Y);
    
    XNOR3_19 : XNOR3
      port map(A => \RGRYSYNC[6]\, B => \RGRYSYNC[5]\, C => 
        \RGRYSYNC[4]\, Y => XNOR3_19_Y);
    
    \DFN1C0_RGRY[11]\ : DFN1C0
      port map(D => XOR2_5_Y, CLK => RCLOCK, CLR => READ_RESET_P, 
        Q => \RGRY[11]\);
    
    \DFN1C0_WGRYSYNC[9]\ : DFN1C0
      port map(D => DFN1C0_22_Q, CLK => RCLOCK, CLR => 
        READ_RESET_P, Q => \WGRYSYNC[9]\);
    
    \XOR2_RBINNXTSHIFT[4]\ : XOR2
      port map(A => XOR2_72_Y, B => AO1_6_Y, Y => 
        \RBINNXTSHIFT[4]\);
    
    \DFN1C0_MEM_WADDR[8]\ : DFN1C0
      port map(D => \WBINNXTSHIFT[8]\, CLK => WCLOCK, CLR => 
        WRITE_RESET_P, Q => \MEM_WADDR[8]\);
    
    XNOR3_22 : XNOR3
      port map(A => \WGRYSYNC[12]\, B => \WGRYSYNC[11]\, C => 
        \WGRYSYNC[10]\, Y => XNOR3_22_Y);
    
    \DFN1C0_RGRY[1]\ : DFN1C0
      port map(D => XOR2_21_Y, CLK => RCLOCK, CLR => READ_RESET_P, 
        Q => \RGRY[1]\);
    
    \DFN1C0_RGRYSYNC[5]\ : DFN1C0
      port map(D => DFN1C0_14_Q, CLK => WCLOCK, CLR => 
        WRITE_RESET_P, Q => \RGRYSYNC[5]\);
    
    \DFN1C0_WGRY[3]\ : DFN1C0
      port map(D => XOR2_54_Y, CLK => WCLOCK, CLR => 
        WRITE_RESET_P, Q => \WGRY[3]\);
    
    XOR2_8 : XOR2
      port map(A => \MEM_RADDR[9]\, B => \GND\, Y => XOR2_8_Y);
    
    \XOR2_RBINNXTSHIFT[6]\ : XOR2
      port map(A => XOR2_68_Y, B => AO1_2_Y, Y => 
        \RBINNXTSHIFT[6]\);
    
    XNOR3_39 : XNOR3
      port map(A => \RGRYSYNC[6]\, B => \RGRYSYNC[5]\, C => 
        \RGRYSYNC[4]\, Y => XNOR3_39_Y);
    
    XOR2_30 : XOR2
      port map(A => \MEM_WADDR[1]\, B => \GND\, Y => XOR2_30_Y);
    
    AND2_38 : AND2
      port map(A => AND2_0_Y, B => XOR2_14_Y, Y => AND2_38_Y);
    
    AND2_35 : AND2
      port map(A => \MEM_RADDR[1]\, B => \GND\, Y => AND2_35_Y);
    
    MEMREBUBBLE : INV
      port map(A => MEMORYRE, Y => MEMRENEG);
    
    \DFN1C0_MEM_WADDR[7]\ : DFN1C0
      port map(D => \WBINNXTSHIFT[7]\, CLK => WCLOCK, CLR => 
        WRITE_RESET_P, Q => \MEM_WADDR[7]\);
    
    \DFN1C0_WGRY[11]\ : DFN1C0
      port map(D => XOR2_2_Y, CLK => WCLOCK, CLR => WRITE_RESET_P, 
        Q => \WGRY[11]\);
    
    AND2_29 : AND2
      port map(A => AND2_55_Y, B => AND2_54_Y, Y => AND2_29_Y);
    
    \DFN1C0_MEM_RADDR[4]\ : DFN1C0
      port map(D => \RBINNXTSHIFT[4]\, CLK => RCLOCK, CLR => 
        READ_RESET_P, Q => \MEM_RADDR[4]\);
    
    XNOR3_7 : XNOR3
      port map(A => \RGRYSYNC[9]\, B => \RGRYSYNC[8]\, C => 
        \RGRYSYNC[7]\, Y => XNOR3_7_Y);
    
    XNOR3_46 : XNOR3
      port map(A => \RGRYSYNC[12]\, B => \RGRYSYNC[11]\, C => 
        \RGRYSYNC[10]\, Y => XNOR3_46_Y);
    
    \XOR2_WBINNXTSHIFT[12]\ : XOR2
      port map(A => XOR2_12_Y, B => AO1_13_Y, Y => 
        \WBINNXTSHIFT[12]\);
    
    XOR2_34 : XOR2
      port map(A => \MEM_RADDR[2]\, B => \GND\, Y => XOR2_34_Y);
    
    XOR2_31 : XOR2
      port map(A => \WBINNXTSHIFT[0]\, B => \WBINNXTSHIFT[1]\, Y
         => XOR2_31_Y);
    
    WEBUBBLE : INV
      port map(A => WE_B, Y => WEP);
    
    AND2_3 : AND2
      port map(A => AND2_19_Y, B => AND2_31_Y, Y => AND2_3_Y);
    
    \DFN1C0_MEM_WADDR[11]\ : DFN1C0
      port map(D => \WBINNXTSHIFT[11]\, CLK => WCLOCK, CLR => 
        WRITE_RESET_P, Q => \MEM_WADDR[11]\);
    
    AND2_30 : AND2
      port map(A => \MEM_RADDR[7]\, B => \GND\, Y => AND2_30_Y);
    
    \XOR2_WBINNXTSHIFT[4]\ : XOR2
      port map(A => XOR2_75_Y, B => AO1_25_Y, Y => 
        \WBINNXTSHIFT[4]\);
    
    XNOR3_26 : XNOR3
      port map(A => \WGRYSYNC[9]\, B => \WGRYSYNC[8]\, C => 
        \WGRYSYNC[7]\, Y => XNOR3_26_Y);
    
    XNOR2_6 : XNOR2
      port map(A => \RBINSYNCSHIFT[10]\, B => \WBINNXTSHIFT[10]\, 
        Y => XNOR2_6_Y);
    
    AND2_14 : AND2
      port map(A => \MEM_RADDR[5]\, B => \GND\, Y => AND2_14_Y);
    
    AND2_32 : AND2
      port map(A => \MEM_RADDR[11]\, B => \GND\, Y => AND2_32_Y);
    
    \XOR2_WBINNXTSHIFT[6]\ : XOR2
      port map(A => XOR2_59_Y, B => AO1_9_Y, Y => 
        \WBINNXTSHIFT[6]\);
    
    \DFN1C0_MEM_RADDR[5]\ : DFN1C0
      port map(D => \RBINNXTSHIFT[5]\, CLK => RCLOCK, CLR => 
        READ_RESET_P, Q => \MEM_RADDR[5]\);
    
    AND3_8 : AND3
      port map(A => AND3_9_Y, B => AND3_7_Y, C => AND3_6_Y, Y => 
        AND3_8_Y);
    
    XOR3_4 : XOR3
      port map(A => \WGRYSYNC[12]\, B => \WGRYSYNC[11]\, C => 
        \WGRYSYNC[10]\, Y => XOR3_4_Y);
    
    XOR2_46 : XOR2
      port map(A => \WBINNXTSHIFT[4]\, B => \WBINNXTSHIFT[5]\, Y
         => XOR2_46_Y);
    
    XNOR2_11 : XNOR2
      port map(A => \RBINSYNCSHIFT[11]\, B => \WBINNXTSHIFT[11]\, 
        Y => XNOR2_11_Y);
    
    AO1_2 : AO1
      port map(A => AND2_19_Y, B => AO1_6_Y, C => AO1_8_Y, Y => 
        AO1_2_Y);
    
    \DFN1C0_MEM_RADDR[8]\ : DFN1C0
      port map(D => \RBINNXTSHIFT[8]\, CLK => RCLOCK, CLR => 
        READ_RESET_P, Q => \MEM_RADDR[8]\);
    
    \DFN1C0_WGRY[0]\ : DFN1C0
      port map(D => XOR2_31_Y, CLK => WCLOCK, CLR => 
        WRITE_RESET_P, Q => \WGRY[0]\);
    
    XOR2_75 : XOR2
      port map(A => \MEM_WADDR[4]\, B => \GND\, Y => XOR2_75_Y);
    
    AND2_26 : AND2
      port map(A => \MEM_RADDR[10]\, B => \GND\, Y => AND2_26_Y);
    
    XOR2_9 : XOR2
      port map(A => \MEM_RADDR[2]\, B => \GND\, Y => XOR2_9_Y);
    
    \RAM4K9_QXI[7]\ : RAM4K9
      port map(ADDRA11 => \MEM_WADDR[11]\, ADDRA10 => 
        \MEM_WADDR[10]\, ADDRA9 => \MEM_WADDR[9]\, ADDRA8 => 
        \MEM_WADDR[8]\, ADDRA7 => \MEM_WADDR[7]\, ADDRA6 => 
        \MEM_WADDR[6]\, ADDRA5 => \MEM_WADDR[5]\, ADDRA4 => 
        \MEM_WADDR[4]\, ADDRA3 => \MEM_WADDR[3]\, ADDRA2 => 
        \MEM_WADDR[2]\, ADDRA1 => \MEM_WADDR[1]\, ADDRA0 => 
        \MEM_WADDR[0]\, ADDRB11 => \MEM_RADDR[11]\, ADDRB10 => 
        \MEM_RADDR[10]\, ADDRB9 => \MEM_RADDR[9]\, ADDRB8 => 
        \MEM_RADDR[8]\, ADDRB7 => \MEM_RADDR[7]\, ADDRB6 => 
        \MEM_RADDR[6]\, ADDRB5 => \MEM_RADDR[5]\, ADDRB4 => 
        \MEM_RADDR[4]\, ADDRB3 => \MEM_RADDR[3]\, ADDRB2 => 
        \MEM_RADDR[2]\, ADDRB1 => \MEM_RADDR[1]\, ADDRB0 => 
        \MEM_RADDR[0]\, DINA8 => \GND\, DINA7 => \GND\, DINA6 => 
        \GND\, DINA5 => \GND\, DINA4 => \GND\, DINA3 => \GND\, 
        DINA2 => \GND\, DINA1 => \GND\, DINA0 => DATA_IN(7), 
        DINB8 => \GND\, DINB7 => \GND\, DINB6 => \GND\, DINB5 => 
        \GND\, DINB4 => \GND\, DINB3 => \GND\, DINB2 => \GND\, 
        DINB1 => \GND\, DINB0 => \GND\, WIDTHA0 => \GND\, WIDTHA1
         => \GND\, WIDTHB0 => \GND\, WIDTHB1 => \GND\, PIPEA => 
        \GND\, PIPEB => \GND\, WMODEA => \GND\, WMODEB => \GND\, 
        BLKA => MEMWENEG, BLKB => MEMRENEG, WENA => \GND\, WENB
         => \VCC\, CLKA => WCLOCK, CLKB => RCLOCK, RESET => 
        WRITE_RESET_P, DOUTA8 => OPEN, DOUTA7 => OPEN, DOUTA6 => 
        OPEN, DOUTA5 => OPEN, DOUTA4 => OPEN, DOUTA3 => OPEN, 
        DOUTA2 => OPEN, DOUTA1 => OPEN, DOUTA0 => 
        \RAM4K9_QXI[7]_DOUTA0\, DOUTB8 => OPEN, DOUTB7 => OPEN, 
        DOUTB6 => OPEN, DOUTB5 => OPEN, DOUTB4 => OPEN, DOUTB3
         => OPEN, DOUTB2 => OPEN, DOUTB1 => OPEN, DOUTB0 => 
        \QXI[7]\);
    
    AND3_5 : AND3
      port map(A => XNOR2_1_Y, B => XNOR2_17_Y, C => XNOR2_21_Y, 
        Y => AND3_5_Y);
    
    \XNOR2_WBINSYNCSHIFT[5]\ : XNOR2
      port map(A => XNOR3_14_Y, B => XNOR3_33_Y, Y => 
        \WBINSYNCSHIFT[5]\);
    
    XOR2_59 : XOR2
      port map(A => \MEM_WADDR[6]\, B => \GND\, Y => XOR2_59_Y);
    
    AND2_23 : AND2
      port map(A => \MEM_WADDR[12]\, B => \GND\, Y => AND2_23_Y);
    
    \DFN1C0_MEM_WADDR[9]\ : DFN1C0
      port map(D => \WBINNXTSHIFT[9]\, CLK => WCLOCK, CLR => 
        WRITE_RESET_P, Q => \MEM_WADDR[9]\);
    
    \DFN1C0_WGRYSYNC[1]\ : DFN1C0
      port map(D => DFN1C0_10_Q, CLK => RCLOCK, CLR => 
        READ_RESET_P, Q => \WGRYSYNC[1]\);
    
    XNOR2_4 : XNOR2
      port map(A => \RBINNXTSHIFT[11]\, B => \WBINSYNCSHIFT[11]\, 
        Y => XNOR2_4_Y);
    
    \DFN1C0_RGRY[8]\ : DFN1C0
      port map(D => XOR2_55_Y, CLK => RCLOCK, CLR => READ_RESET_P, 
        Q => \RGRY[8]\);
    
    XOR2_5 : XOR2
      port map(A => \RBINNXTSHIFT[11]\, B => \RBINNXTSHIFT[12]\, 
        Y => XOR2_5_Y);
    
    XNOR3_47 : XNOR3
      port map(A => \RGRYSYNC[3]\, B => XOR3_2_Y, C => XNOR3_1_Y, 
        Y => XNOR3_47_Y);
    
    XNOR2_20 : XNOR2
      port map(A => \RBINNXTSHIFT[7]\, B => \WBINSYNCSHIFT[7]\, Y
         => XNOR2_20_Y);
    
    DFN1C0_16 : DFN1C0
      port map(D => \RGRY[7]\, CLK => WCLOCK, CLR => 
        WRITE_RESET_P, Q => DFN1C0_16_Q);
    
    XNOR3_11 : XNOR3
      port map(A => \WGRYSYNC[0]\, B => XNOR3_35_Y, C => 
        XNOR3_48_Y, Y => XNOR3_11_Y);
    
    AO1_28 : AO1
      port map(A => AND2_12_Y, B => AO1_17_Y, C => AO1_35_Y, Y
         => AO1_28_Y);
    
    AND2_19 : AND2
      port map(A => XOR2_10_Y, B => XOR2_23_Y, Y => AND2_19_Y);
    
    DFN1C0_6 : DFN1C0
      port map(D => \RGRY[2]\, CLK => WCLOCK, CLR => 
        WRITE_RESET_P, Q => DFN1C0_6_Q);
    
    \XNOR2_WBINSYNCSHIFT[7]\ : XNOR2
      port map(A => XOR3_6_Y, B => XNOR3_25_Y, Y => 
        \WBINSYNCSHIFT[7]\);
    
    \DFN1C0_MEM_RADDR[6]\ : DFN1C0
      port map(D => \RBINNXTSHIFT[6]\, CLK => RCLOCK, CLR => 
        READ_RESET_P, Q => \MEM_RADDR[6]\);
    
    XNOR3_27 : XNOR3
      port map(A => \WGRYSYNC[9]\, B => \WGRYSYNC[8]\, C => 
        \WGRYSYNC[7]\, Y => XNOR3_27_Y);
    
    XOR2_22 : XOR2
      port map(A => \MEM_WADDR[11]\, B => \GND\, Y => XOR2_22_Y);
    
    \XNOR3_RBINSYNCSHIFT[8]\ : XNOR3
      port map(A => \RGRYSYNC[9]\, B => \RGRYSYNC[8]\, C => 
        XNOR3_24_Y, Y => \RBINSYNCSHIFT[8]\);
    
    AO1_1 : AO1
      port map(A => XOR2_30_Y, B => AND2_27_Y, C => AND2_45_Y, Y
         => AO1_1_Y);
    
    DFN1C0_10 : DFN1C0
      port map(D => \WGRY[1]\, CLK => RCLOCK, CLR => READ_RESET_P, 
        Q => DFN1C0_10_Q);
    
    XOR2_13 : XOR2
      port map(A => \RBINNXTSHIFT[0]\, B => \RBINNXTSHIFT[1]\, Y
         => XOR2_13_Y);
    
    \DFN1C0_WGRYSYNC[2]\ : DFN1C0
      port map(D => DFN1C0_11_Q, CLK => RCLOCK, CLR => 
        READ_RESET_P, Q => \WGRYSYNC[2]\);
    
    XNOR3_31 : XNOR3
      port map(A => \WGRYSYNC[9]\, B => \WGRYSYNC[8]\, C => 
        \WGRYSYNC[7]\, Y => XNOR3_31_Y);
    
    \DFN1C0_WGRYSYNC[0]\ : DFN1C0
      port map(D => DFN1C0_13_Q, CLK => RCLOCK, CLR => 
        READ_RESET_P, Q => \WGRYSYNC[0]\);
    
    XNOR2_18 : XNOR2
      port map(A => \RBINNXTSHIFT[6]\, B => \WBINSYNCSHIFT[6]\, Y
         => XNOR2_18_Y);
    
    AND2_51 : AND2
      port map(A => AND2_40_Y, B => XOR2_19_Y, Y => AND2_51_Y);
    
    REBUBBLE : INV
      port map(A => RE_B, Y => REP);
    
    \DFN1E1C0_DATA_OUT[3]\ : DFN1E1C0
      port map(D => \QXI[3]\, CLK => RCLOCK, CLR => READ_RESET_P, 
        E => DVLDI, Q => DATA_OUT(3));
    
    AO1_3 : AO1
      port map(A => XOR2_58_Y, B => AND2_49_Y, C => AND2_10_Y, Y
         => AO1_3_Y);
    
    AND2_64 : AND2
      port map(A => AND2_0_Y, B => AND2_48_Y, Y => AND2_64_Y);
    
    AND2_47 : AND2
      port map(A => AND2_63_Y, B => XOR2_71_Y, Y => AND2_47_Y);
    
    XNOR3_44 : XNOR3
      port map(A => \RGRYSYNC[6]\, B => \RGRYSYNC[5]\, C => 
        \RGRYSYNC[4]\, Y => XNOR3_44_Y);
    
    AO1_18 : AO1
      port map(A => AND2_3_Y, B => AO1_6_Y, C => AO1_33_Y, Y => 
        AO1_18_Y);
    
    XOR2_48 : XOR2
      port map(A => \MEM_WADDR[1]\, B => \GND\, Y => XOR2_48_Y);
    
    \XOR2_RBINNXTSHIFT[3]\ : XOR2
      port map(A => XOR2_51_Y, B => AO1_24_Y, Y => 
        \RBINNXTSHIFT[3]\);
    
    DFN1C0_3 : DFN1C0
      port map(D => \VCC\, CLK => RCLOCK, CLR => RESET, Q => 
        DFN1C0_3_Q);
    
    \DFN1C0_MEM_RADDR[7]\ : DFN1C0
      port map(D => \RBINNXTSHIFT[7]\, CLK => RCLOCK, CLR => 
        READ_RESET_P, Q => \MEM_RADDR[7]\);
    
    AND2_16 : AND2
      port map(A => XOR2_57_Y, B => XOR2_6_Y, Y => AND2_16_Y);
    
    XNOR3_18 : XNOR3
      port map(A => \WGRYSYNC[3]\, B => XOR3_0_Y, C => XNOR3_27_Y, 
        Y => XNOR3_18_Y);
    
    XNOR3_24 : XNOR3
      port map(A => \RGRYSYNC[12]\, B => \RGRYSYNC[11]\, C => 
        \RGRYSYNC[10]\, Y => XNOR3_24_Y);
    
    \DFN1C0_WGRY[9]\ : DFN1C0
      port map(D => XOR2_15_Y, CLK => WCLOCK, CLR => 
        WRITE_RESET_P, Q => \WGRY[9]\);
    
    XOR2_62 : XOR2
      port map(A => \MEM_WADDR[4]\, B => \GND\, Y => XOR2_62_Y);
    
    AND2_13 : AND2
      port map(A => \MEM_WADDR[7]\, B => \GND\, Y => AND2_13_Y);
    
    DFN1C0_18 : DFN1C0
      port map(D => \RGRY[3]\, CLK => WCLOCK, CLR => 
        WRITE_RESET_P, Q => DFN1C0_18_Q);
    
    XOR2_10 : XOR2
      port map(A => \MEM_RADDR[4]\, B => \GND\, Y => XOR2_10_Y);
    
    XNOR2_1 : XNOR2
      port map(A => \RBINSYNCSHIFT[0]\, B => \WBINNXTSHIFT[0]\, Y
         => XNOR2_1_Y);
    
    AND2_58 : AND2
      port map(A => \MEM_WADDR[8]\, B => \GND\, Y => AND2_58_Y);
    
    AND2_55 : AND2
      port map(A => XOR2_35_Y, B => XOR2_30_Y, Y => AND2_55_Y);
    
    XNOR3_38 : XNOR3
      port map(A => \WGRYSYNC[6]\, B => \WGRYSYNC[5]\, C => 
        \WGRYSYNC[4]\, Y => XNOR3_38_Y);
    
    \RAM4K9_QXI[0]\ : RAM4K9
      port map(ADDRA11 => \MEM_WADDR[11]\, ADDRA10 => 
        \MEM_WADDR[10]\, ADDRA9 => \MEM_WADDR[9]\, ADDRA8 => 
        \MEM_WADDR[8]\, ADDRA7 => \MEM_WADDR[7]\, ADDRA6 => 
        \MEM_WADDR[6]\, ADDRA5 => \MEM_WADDR[5]\, ADDRA4 => 
        \MEM_WADDR[4]\, ADDRA3 => \MEM_WADDR[3]\, ADDRA2 => 
        \MEM_WADDR[2]\, ADDRA1 => \MEM_WADDR[1]\, ADDRA0 => 
        \MEM_WADDR[0]\, ADDRB11 => \MEM_RADDR[11]\, ADDRB10 => 
        \MEM_RADDR[10]\, ADDRB9 => \MEM_RADDR[9]\, ADDRB8 => 
        \MEM_RADDR[8]\, ADDRB7 => \MEM_RADDR[7]\, ADDRB6 => 
        \MEM_RADDR[6]\, ADDRB5 => \MEM_RADDR[5]\, ADDRB4 => 
        \MEM_RADDR[4]\, ADDRB3 => \MEM_RADDR[3]\, ADDRB2 => 
        \MEM_RADDR[2]\, ADDRB1 => \MEM_RADDR[1]\, ADDRB0 => 
        \MEM_RADDR[0]\, DINA8 => \GND\, DINA7 => \GND\, DINA6 => 
        \GND\, DINA5 => \GND\, DINA4 => \GND\, DINA3 => \GND\, 
        DINA2 => \GND\, DINA1 => \GND\, DINA0 => DATA_IN(0), 
        DINB8 => \GND\, DINB7 => \GND\, DINB6 => \GND\, DINB5 => 
        \GND\, DINB4 => \GND\, DINB3 => \GND\, DINB2 => \GND\, 
        DINB1 => \GND\, DINB0 => \GND\, WIDTHA0 => \GND\, WIDTHA1
         => \GND\, WIDTHB0 => \GND\, WIDTHB1 => \GND\, PIPEA => 
        \GND\, PIPEB => \GND\, WMODEA => \GND\, WMODEB => \GND\, 
        BLKA => MEMWENEG, BLKB => MEMRENEG, WENA => \GND\, WENB
         => \VCC\, CLKA => WCLOCK, CLKB => RCLOCK, RESET => 
        WRITE_RESET_P, DOUTA8 => OPEN, DOUTA7 => OPEN, DOUTA6 => 
        OPEN, DOUTA5 => OPEN, DOUTA4 => OPEN, DOUTA3 => OPEN, 
        DOUTA2 => OPEN, DOUTA1 => OPEN, DOUTA0 => 
        \RAM4K9_QXI[0]_DOUTA0\, DOUTB8 => OPEN, DOUTB7 => OPEN, 
        DOUTB6 => OPEN, DOUTB5 => OPEN, DOUTB4 => OPEN, DOUTB3
         => OPEN, DOUTB2 => OPEN, DOUTB1 => OPEN, DOUTB0 => 
        \QXI[0]\);
    
    XNOR3_6 : XNOR3
      port map(A => \RGRYSYNC[12]\, B => \RGRYSYNC[11]\, C => 
        \RGRYSYNC[10]\, Y => XNOR3_6_Y);
    
    \DFN1C0_RGRY[4]\ : DFN1C0
      port map(D => XOR2_64_Y, CLK => RCLOCK, CLR => READ_RESET_P, 
        Q => \RGRY[4]\);
    
    DFN1C0_2 : DFN1C0
      port map(D => \WGRY[10]\, CLK => RCLOCK, CLR => 
        READ_RESET_P, Q => DFN1C0_2_Q);
    
    XNOR3_43 : XNOR3
      port map(A => \RGRYSYNC[6]\, B => \RGRYSYNC[5]\, C => 
        \RGRYSYNC[4]\, Y => XNOR3_43_Y);
    
    \DFN1C0_MEM_WADDR[2]\ : DFN1C0
      port map(D => \WBINNXTSHIFT[2]\, CLK => WCLOCK, CLR => 
        WRITE_RESET_P, Q => \MEM_WADDR[2]\);
    
    XOR3_3 : XOR3
      port map(A => \WGRYSYNC[12]\, B => \WGRYSYNC[11]\, C => 
        \WGRYSYNC[10]\, Y => XOR3_3_Y);
    
    XOR2_27 : XOR2
      port map(A => \MEM_WADDR[10]\, B => \GND\, Y => XOR2_27_Y);
    
    AND2_MEMORYRE : AND2
      port map(A => NAND2_1_Y, B => REP, Y => MEMORYRE);
    
    XOR2_7 : XOR2
      port map(A => \MEM_RADDR[11]\, B => \GND\, Y => XOR2_7_Y);
    
    AND2_5 : AND2
      port map(A => \MEM_WADDR[11]\, B => \GND\, Y => AND2_5_Y);
    
    \XOR2_WBINNXTSHIFT[3]\ : XOR2
      port map(A => XOR2_69_Y, B => AO1_26_Y, Y => 
        \WBINNXTSHIFT[3]\);
    
    XOR2_56 : XOR2
      port map(A => \RBINNXTSHIFT[6]\, B => \RBINNXTSHIFT[7]\, Y
         => XOR2_56_Y);
    
    \RAM4K9_QXI[4]\ : RAM4K9
      port map(ADDRA11 => \MEM_WADDR[11]\, ADDRA10 => 
        \MEM_WADDR[10]\, ADDRA9 => \MEM_WADDR[9]\, ADDRA8 => 
        \MEM_WADDR[8]\, ADDRA7 => \MEM_WADDR[7]\, ADDRA6 => 
        \MEM_WADDR[6]\, ADDRA5 => \MEM_WADDR[5]\, ADDRA4 => 
        \MEM_WADDR[4]\, ADDRA3 => \MEM_WADDR[3]\, ADDRA2 => 
        \MEM_WADDR[2]\, ADDRA1 => \MEM_WADDR[1]\, ADDRA0 => 
        \MEM_WADDR[0]\, ADDRB11 => \MEM_RADDR[11]\, ADDRB10 => 
        \MEM_RADDR[10]\, ADDRB9 => \MEM_RADDR[9]\, ADDRB8 => 
        \MEM_RADDR[8]\, ADDRB7 => \MEM_RADDR[7]\, ADDRB6 => 
        \MEM_RADDR[6]\, ADDRB5 => \MEM_RADDR[5]\, ADDRB4 => 
        \MEM_RADDR[4]\, ADDRB3 => \MEM_RADDR[3]\, ADDRB2 => 
        \MEM_RADDR[2]\, ADDRB1 => \MEM_RADDR[1]\, ADDRB0 => 
        \MEM_RADDR[0]\, DINA8 => \GND\, DINA7 => \GND\, DINA6 => 
        \GND\, DINA5 => \GND\, DINA4 => \GND\, DINA3 => \GND\, 
        DINA2 => \GND\, DINA1 => \GND\, DINA0 => DATA_IN(4), 
        DINB8 => \GND\, DINB7 => \GND\, DINB6 => \GND\, DINB5 => 
        \GND\, DINB4 => \GND\, DINB3 => \GND\, DINB2 => \GND\, 
        DINB1 => \GND\, DINB0 => \GND\, WIDTHA0 => \GND\, WIDTHA1
         => \GND\, WIDTHB0 => \GND\, WIDTHB1 => \GND\, PIPEA => 
        \GND\, PIPEB => \GND\, WMODEA => \GND\, WMODEB => \GND\, 
        BLKA => MEMWENEG, BLKB => MEMRENEG, WENA => \GND\, WENB
         => \VCC\, CLKA => WCLOCK, CLKB => RCLOCK, RESET => 
        WRITE_RESET_P, DOUTA8 => OPEN, DOUTA7 => OPEN, DOUTA6 => 
        OPEN, DOUTA5 => OPEN, DOUTA4 => OPEN, DOUTA3 => OPEN, 
        DOUTA2 => OPEN, DOUTA1 => OPEN, DOUTA0 => 
        \RAM4K9_QXI[4]_DOUTA0\, DOUTB8 => OPEN, DOUTB7 => OPEN, 
        DOUTB6 => OPEN, DOUTB5 => OPEN, DOUTB4 => OPEN, DOUTB3
         => OPEN, DOUTB2 => OPEN, DOUTB1 => OPEN, DOUTB0 => 
        \QXI[4]\);
    
    XOR2_14 : XOR2
      port map(A => \MEM_RADDR[8]\, B => \GND\, Y => XOR2_14_Y);
    
    AND2_50 : AND2
      port map(A => \MEM_WADDR[9]\, B => \GND\, Y => AND2_50_Y);
    
    XNOR3_23 : XNOR3
      port map(A => \RGRYSYNC[9]\, B => \RGRYSYNC[8]\, C => 
        \RGRYSYNC[7]\, Y => XNOR3_23_Y);
    
    XNOR3_1 : XNOR3
      port map(A => \RGRYSYNC[9]\, B => \RGRYSYNC[8]\, C => 
        \RGRYSYNC[7]\, Y => XNOR3_1_Y);
    
    DFN1C0_7 : DFN1C0
      port map(D => \RGRY[10]\, CLK => WCLOCK, CLR => 
        WRITE_RESET_P, Q => DFN1C0_7_Q);
    
    XNOR2_3 : XNOR2
      port map(A => \RBINSYNCSHIFT[9]\, B => \WBINNXTSHIFT[9]\, Y
         => XNOR2_3_Y);
    
    XOR2_11 : XOR2
      port map(A => \MEM_WADDR[2]\, B => \GND\, Y => XOR2_11_Y);
    
    XNOR2_22 : XNOR2
      port map(A => \RBINNXTSHIFT[12]\, B => READDOMAIN_WMSB, Y
         => XNOR2_22_Y);
    
    XOR3_6 : XOR3
      port map(A => \WGRYSYNC[12]\, B => \WGRYSYNC[11]\, C => 
        \WGRYSYNC[10]\, Y => XOR3_6_Y);
    
    AND2_52 : AND2
      port map(A => \MEM_WADDR[6]\, B => \GND\, Y => AND2_52_Y);
    
    XOR2_25 : XOR2
      port map(A => \MEM_WADDR[12]\, B => \GND\, Y => XOR2_25_Y);
    
    XNOR2_15 : XNOR2
      port map(A => \RBINSYNCSHIFT[6]\, B => \WBINNXTSHIFT[6]\, Y
         => XNOR2_15_Y);
    
    AO1_22 : AO1
      port map(A => XOR2_25_Y, B => AO1_13_Y, C => AND2_23_Y, Y
         => AO1_22_Y);
    
    XNOR3_3 : XNOR3
      port map(A => \RGRYSYNC[9]\, B => \RGRYSYNC[8]\, C => 
        \RGRYSYNC[7]\, Y => XNOR3_3_Y);
    
    \XNOR2_RBINSYNCSHIFT[7]\ : XNOR2
      port map(A => XOR3_1_Y, B => XNOR3_51_Y, Y => 
        \RBINSYNCSHIFT[7]\);
    
    \DFN1C0_RGRYSYNC[10]\ : DFN1C0
      port map(D => DFN1C0_7_Q, CLK => WCLOCK, CLR => 
        WRITE_RESET_P, Q => \RGRYSYNC[10]\);
    
    \DFN1C0_RGRYSYNC[9]\ : DFN1C0
      port map(D => DFN1C0_1_Q, CLK => WCLOCK, CLR => 
        WRITE_RESET_P, Q => \RGRYSYNC[9]\);
    
    AND2_34 : AND2
      port map(A => AND2_60_Y, B => XOR2_10_Y, Y => AND2_34_Y);
    
    AO1_6 : AO1
      port map(A => AND2_53_Y, B => AO1_14_Y, C => AO1_30_Y, Y
         => AO1_6_Y);
    
    XNOR3_15 : XNOR3
      port map(A => \WGRYSYNC[6]\, B => \WGRYSYNC[5]\, C => 
        \WGRYSYNC[4]\, Y => XNOR3_15_Y);
    
    \DFN1C0_MEM_RADDR[3]\ : DFN1C0
      port map(D => \RBINNXTSHIFT[3]\, CLK => RCLOCK, CLR => 
        READ_RESET_P, Q => \MEM_RADDR[3]\);
    
    XOR2_67 : XOR2
      port map(A => \RBINNXTSHIFT[10]\, B => \RBINNXTSHIFT[11]\, 
        Y => XOR2_67_Y);
    
    DFN1C0_23 : DFN1C0
      port map(D => \WGRY[8]\, CLK => RCLOCK, CLR => READ_RESET_P, 
        Q => DFN1C0_23_Q);
    
    AND2_63 : AND2
      port map(A => AND2_0_Y, B => AND2_56_Y, Y => AND2_63_Y);
    
    AND3_2 : AND3
      port map(A => AND3_4_Y, B => AND3_5_Y, C => AND3_3_Y, Y => 
        AND3_2_Y);
    
    AO1_12 : AO1
      port map(A => AND2_8_Y, B => AO1_5_Y, C => AO1_17_Y, Y => 
        AO1_12_Y);
    
    XOR2_32 : XOR2
      port map(A => \RBINNXTSHIFT[9]\, B => \RBINNXTSHIFT[10]\, Y
         => XOR2_32_Y);
    
    XNOR3_35 : XNOR3
      port map(A => \WGRYSYNC[12]\, B => \WGRYSYNC[11]\, C => 
        \WGRYSYNC[10]\, Y => XNOR3_35_Y);
    
    AND2_9 : AND2
      port map(A => \MEM_WADDR[2]\, B => \GND\, Y => AND2_9_Y);
    
    XOR2_65 : XOR2
      port map(A => \MEM_RADDR[9]\, B => \GND\, Y => XOR2_65_Y);
    
    XOR2_58 : XOR2
      port map(A => \MEM_WADDR[5]\, B => \GND\, Y => XOR2_58_Y);
    
    AO1_32 : AO1
      port map(A => XOR2_65_Y, B => AND2_24_Y, C => AND2_33_Y, Y
         => AO1_32_Y);
    
    XOR2_43 : XOR2
      port map(A => \RBINNXTSHIFT[3]\, B => \RBINNXTSHIFT[4]\, Y
         => XOR2_43_Y);
    
    \XNOR2_RBINSYNCSHIFT[3]\ : XNOR2
      port map(A => XNOR3_39_Y, B => XNOR3_47_Y, Y => 
        \RBINSYNCSHIFT[3]\);
    
    \DFN1C0_RGRYSYNC[12]\ : DFN1C0
      port map(D => DFN1C0_19_Q, CLK => WCLOCK, CLR => 
        WRITE_RESET_P, Q => \RGRYSYNC[12]\);
    
    AO1_9 : AO1
      port map(A => AND2_59_Y, B => AO1_25_Y, C => AO1_3_Y, Y => 
        AO1_9_Y);
    
    DFN1C0_DVLDX : DFN1C0
      port map(D => DVLDI, CLK => RCLOCK, CLR => READ_RESET_P, Q
         => DVLDX);
    
    AND2_39 : AND2
      port map(A => AND2_21_Y, B => XOR2_25_Y, Y => AND2_39_Y);
    
    NAND2_0 : NAND2
      port map(A => \FULL\, B => \VCC\, Y => NAND2_0_Y);
    
    XNOR3_0 : XNOR3
      port map(A => \RGRYSYNC[9]\, B => \RGRYSYNC[8]\, C => 
        \RGRYSYNC[7]\, Y => XNOR3_0_Y);
    
    \DFN1C0_WGRYSYNC[10]\ : DFN1C0
      port map(D => DFN1C0_2_Q, CLK => RCLOCK, CLR => 
        READ_RESET_P, Q => \WGRYSYNC[10]\);
    
    \DFN1C0_RGRY[6]\ : DFN1C0
      port map(D => XOR2_56_Y, CLK => RCLOCK, CLR => READ_RESET_P, 
        Q => \RGRY[6]\);
    
    XOR2_76 : XOR2
      port map(A => \MEM_RADDR[11]\, B => \GND\, Y => XOR2_76_Y);
    
    AND2_27 : AND2
      port map(A => \MEM_WADDR[0]\, B => MEMORYWE, Y => AND2_27_Y);
    
    DFN1C0_DVLDI : DFN1C0
      port map(D => AND2A_0_Y, CLK => RCLOCK, CLR => READ_RESET_P, 
        Q => DVLDI);
    
    XNOR2_10 : XNOR2
      port map(A => \RBINNXTSHIFT[5]\, B => \WBINSYNCSHIFT[5]\, Y
         => XNOR2_10_Y);
    
    AND2_MEMORYWE : AND2
      port map(A => NAND2_0_Y, B => WEP, Y => MEMORYWE);
    
    AO1_20 : AO1
      port map(A => XOR2_66_Y, B => AND2_9_Y, C => AND2_6_Y, Y
         => AO1_20_Y);
    
    \DFN1E1C0_DATA_OUT[1]\ : DFN1E1C0
      port map(D => \QXI[1]\, CLK => RCLOCK, CLR => READ_RESET_P, 
        E => DVLDI, Q => DATA_OUT(1));
    
    \DFN1C0_WGRY[2]\ : DFN1C0
      port map(D => XOR2_17_Y, CLK => WCLOCK, CLR => 
        WRITE_RESET_P, Q => \WGRY[2]\);
    
    AO1_0 : AO1
      port map(A => AND2_41_Y, B => AO1_32_Y, C => AO1_15_Y, Y
         => AO1_0_Y);
    
    XOR2_29 : XOR2
      port map(A => \MEM_RADDR[10]\, B => \GND\, Y => XOR2_29_Y);
    
    \DFN1C0_WGRYSYNC[8]\ : DFN1C0
      port map(D => DFN1C0_23_Q, CLK => RCLOCK, CLR => 
        READ_RESET_P, Q => \WGRYSYNC[8]\);
    
    XOR2_40 : XOR2
      port map(A => \RBINSYNCSHIFT[12]\, B => \WBINNXTSHIFT[12]\, 
        Y => XOR2_40_Y);
    
    \DFN1C0_RGRYSYNC[1]\ : DFN1C0
      port map(D => DFN1C0_0_Q, CLK => WCLOCK, CLR => 
        WRITE_RESET_P, Q => \RGRYSYNC[1]\);
    
    XOR3_0 : XOR3
      port map(A => \WGRYSYNC[12]\, B => \WGRYSYNC[11]\, C => 
        \WGRYSYNC[10]\, Y => XOR3_0_Y);
    
    XOR2_2 : XOR2
      port map(A => \WBINNXTSHIFT[11]\, B => \WBINNXTSHIFT[12]\, 
        Y => XOR2_2_Y);
    
    DFN1C0_8 : DFN1C0
      port map(D => \WGRY[7]\, CLK => RCLOCK, CLR => READ_RESET_P, 
        Q => DFN1C0_8_Q);
    
    \DFN1C0_RGRY[5]\ : DFN1C0
      port map(D => XOR2_70_Y, CLK => RCLOCK, CLR => READ_RESET_P, 
        Q => \RGRY[5]\);
    
    XNOR3_10 : XNOR3
      port map(A => \RGRYSYNC[6]\, B => \RGRYSYNC[5]\, C => 
        XNOR3_45_Y, Y => XNOR3_10_Y);
    
    AND2_36 : AND2
      port map(A => AND2_60_Y, B => AND2_19_Y, Y => AND2_36_Y);
    
    XOR2_37 : XOR2
      port map(A => \WBINNXTSHIFT[6]\, B => \WBINNXTSHIFT[7]\, Y
         => XOR2_37_Y);
    
    AND2A_0 : AND2A
      port map(A => \EMPTY\, B => REP, Y => AND2A_0_Y);
    
    AO1_26 : AO1
      port map(A => XOR2_16_Y, B => AO1_1_Y, C => AND2_9_Y, Y => 
        AO1_26_Y);
    
    \DFN1C0_WGRY[10]\ : DFN1C0
      port map(D => XOR2_39_Y, CLK => WCLOCK, CLR => 
        WRITE_RESET_P, Q => \WGRY[10]\);
    
    \XNOR3_WBINSYNCSHIFT[0]\ : XNOR3
      port map(A => XNOR3_15_Y, B => XNOR3_34_Y, C => XNOR3_11_Y, 
        Y => \WBINSYNCSHIFT[0]\);
    
    \DFN1C0_RGRY[7]\ : DFN1C0
      port map(D => XOR2_18_Y, CLK => RCLOCK, CLR => READ_RESET_P, 
        Q => \RGRY[7]\);
    
    AND3_9 : AND3
      port map(A => XNOR2_18_Y, B => XNOR2_20_Y, C => XNOR2_16_Y, 
        Y => AND3_9_Y);
    
    XOR3_5 : XOR3
      port map(A => \RGRYSYNC[12]\, B => \RGRYSYNC[11]\, C => 
        \RGRYSYNC[10]\, Y => XOR3_5_Y);
    
    \XOR2_RBINNXTSHIFT[5]\ : XOR2
      port map(A => XOR2_20_Y, B => AO1_11_Y, Y => 
        \RBINNXTSHIFT[5]\);
    
    AO1_23 : AO1
      port map(A => AND2_44_Y, B => AO1_3_Y, C => AO1_4_Y, Y => 
        AO1_23_Y);
    
    AND2_33 : AND2
      port map(A => \MEM_RADDR[9]\, B => \GND\, Y => AND2_33_Y);
    
    XOR2_44 : XOR2
      port map(A => \WBINNXTSHIFT[7]\, B => \WBINNXTSHIFT[8]\, Y
         => XOR2_44_Y);
    
    \DFN1C0_RGRYSYNC[2]\ : DFN1C0
      port map(D => DFN1C0_6_Q, CLK => WCLOCK, CLR => 
        WRITE_RESET_P, Q => \RGRYSYNC[2]\);
    
    AO1_10 : AO1
      port map(A => XOR2_0_Y, B => AO1_9_Y, C => AND2_52_Y, Y => 
        AO1_10_Y);
    
    XNOR3_49 : XNOR3
      port map(A => \RGRYSYNC[3]\, B => \RGRYSYNC[2]\, C => 
        XOR3_7_Y, Y => XNOR3_49_Y);
    
    XOR2_41 : XOR2
      port map(A => \MEM_WADDR[9]\, B => \GND\, Y => XOR2_41_Y);
    
    XOR2_35 : XOR2
      port map(A => \MEM_WADDR[0]\, B => MEMORYWE, Y => XOR2_35_Y);
    
    XNOR3_30 : XNOR3
      port map(A => \RGRYSYNC[12]\, B => \RGRYSYNC[11]\, C => 
        \RGRYSYNC[10]\, Y => XNOR3_30_Y);
    
    XNOR2_24 : XNOR2
      port map(A => \RBINNXTSHIFT[4]\, B => \WBINSYNCSHIFT[4]\, Y
         => XNOR2_24_Y);
    
    \DFN1C0_RGRYSYNC[0]\ : DFN1C0
      port map(D => DFN1C0_27_Q, CLK => WCLOCK, CLR => 
        WRITE_RESET_P, Q => \RGRYSYNC[0]\);
    
    \XOR2_RBINNXTSHIFT[10]\ : XOR2
      port map(A => XOR2_29_Y, B => AO1_16_Y, Y => 
        \RBINNXTSHIFT[10]\);
    
    \DFN1C0_WGRY[1]\ : DFN1C0
      port map(D => XOR2_26_Y, CLK => WCLOCK, CLR => 
        WRITE_RESET_P, Q => \WGRY[1]\);
    
    \DFN1E1C0_DATA_OUT[2]\ : DFN1E1C0
      port map(D => \QXI[2]\, CLK => RCLOCK, CLR => READ_RESET_P, 
        E => DVLDI, Q => DATA_OUT(2));
    
    DFN1P0_EMPTY : DFN1P0
      port map(D => EMPTYINT, CLK => RCLOCK, PRE => READ_RESET_P, 
        Q => \EMPTY\);
    
    \DFN1C0_WGRYSYNC[4]\ : DFN1C0
      port map(D => DFN1C0_5_Q, CLK => RCLOCK, CLR => 
        READ_RESET_P, Q => \WGRYSYNC[4]\);
    
    XNOR3_29 : XNOR3
      port map(A => \WGRYSYNC[9]\, B => \WGRYSYNC[8]\, C => 
        \WGRYSYNC[7]\, Y => XNOR3_29_Y);
    
    \XNOR3_RBINSYNCSHIFT[4]\ : XNOR3
      port map(A => XNOR3_30_Y, B => XNOR3_41_Y, C => XNOR3_9_Y, 
        Y => \RBINSYNCSHIFT[4]\);
    
    DFN1C0_27 : DFN1C0
      port map(D => \RGRY[0]\, CLK => WCLOCK, CLR => 
        WRITE_RESET_P, Q => DFN1C0_27_Q);
    
    AO1_30 : AO1
      port map(A => XOR2_3_Y, B => AND2_15_Y, C => AND2_46_Y, Y
         => AO1_30_Y);
    
    \XOR2_WBINSYNCSHIFT[11]\ : XOR2
      port map(A => \WGRYSYNC[12]\, B => \WGRYSYNC[11]\, Y => 
        \WBINSYNCSHIFT[11]\);
    
    \XOR2_RBINNXTSHIFT[7]\ : XOR2
      port map(A => XOR2_63_Y, B => AO1_21_Y, Y => 
        \RBINNXTSHIFT[7]\);
    
    AND2_41 : AND2
      port map(A => XOR2_50_Y, B => XOR2_7_Y, Y => AND2_41_Y);
    
    AND2_0 : AND2
      port map(A => AND2_60_Y, B => AND2_3_Y, Y => AND2_0_Y);
    
    XOR2_69 : XOR2
      port map(A => \MEM_WADDR[3]\, B => \GND\, Y => XOR2_69_Y);
    
    \DFN1C0_RGRY[12]\ : DFN1C0
      port map(D => XOR2_33_Y, CLK => RCLOCK, CLR => READ_RESET_P, 
        Q => \RGRY[12]\);
    
    AO1_16 : AO1
      port map(A => AND2_48_Y, B => AO1_18_Y, C => AO1_32_Y, Y
         => AO1_16_Y);
    
    AND2_17 : AND2
      port map(A => XNOR2_23_Y, B => XNOR2_4_Y, Y => AND2_17_Y);
    
    \XNOR2_WBINSYNCSHIFT[1]\ : XNOR2
      port map(A => XNOR3_28_Y, B => XNOR3_40_Y, Y => 
        \WBINSYNCSHIFT[1]\);
    
    AO1_29 : AO1
      port map(A => XOR2_60_Y, B => AO1_12_Y, C => AND2_2_Y, Y
         => AO1_29_Y);
    
    XOR2_6 : XOR2
      port map(A => \MEM_RADDR[1]\, B => \GND\, Y => XOR2_6_Y);
    
    \DFN1C0_WGRY[12]\ : DFN1C0
      port map(D => XOR2_52_Y, CLK => WCLOCK, CLR => 
        WRITE_RESET_P, Q => \WGRY[12]\);
    
    AND2_54 : AND2
      port map(A => XOR2_16_Y, B => XOR2_66_Y, Y => AND2_54_Y);
    
    AO1_13 : AO1
      port map(A => AND2_43_Y, B => AO1_5_Y, C => AO1_28_Y, Y => 
        AO1_13_Y);
    
    \XNOR3_RBINSYNCSHIFT[2]\ : XNOR3
      port map(A => XNOR3_3_Y, B => XNOR3_44_Y, C => XNOR3_49_Y, 
        Y => \RBINSYNCSHIFT[2]\);
    
    \DFN1C0_MEM_WADDR[6]\ : DFN1C0
      port map(D => \WBINNXTSHIFT[6]\, CLK => WCLOCK, CLR => 
        WRITE_RESET_P, Q => \MEM_WADDR[6]\);
    
    \XOR2_WBINNXTSHIFT[5]\ : XOR2
      port map(A => XOR2_38_Y, B => AO1_19_Y, Y => 
        \WBINNXTSHIFT[5]\);
    
    \DFN1E1C0_DATA_OUT[6]\ : DFN1E1C0
      port map(D => \QXI[6]\, CLK => RCLOCK, CLR => READ_RESET_P, 
        E => DVLDI, Q => DATA_OUT(6));
    
    AO1_36 : AO1
      port map(A => XOR2_50_Y, B => AO1_16_Y, C => AND2_26_Y, Y
         => AO1_36_Y);
    
    XOR2_53 : XOR2
      port map(A => \MEM_RADDR[6]\, B => \GND\, Y => XOR2_53_Y);
    
    XNOR2_23 : XNOR2
      port map(A => \RBINNXTSHIFT[10]\, B => \WBINSYNCSHIFT[10]\, 
        Y => XNOR2_23_Y);
    
    \XOR2_WBINNXTSHIFT[10]\ : XOR2
      port map(A => XOR2_27_Y, B => AO1_12_Y, Y => 
        \WBINNXTSHIFT[10]\);
    
    AO1_33 : AO1
      port map(A => AND2_31_Y, B => AO1_8_Y, C => AO1_37_Y, Y => 
        AO1_33_Y);
    
    DFN1C0_19 : DFN1C0
      port map(D => \RGRY[12]\, CLK => WCLOCK, CLR => 
        WRITE_RESET_P, Q => DFN1C0_19_Q);
    
    \DFN1C0_WGRYSYNC[3]\ : DFN1C0
      port map(D => DFN1C0_26_Q, CLK => RCLOCK, CLR => 
        READ_RESET_P, Q => \WGRYSYNC[3]\);
    
    XNOR2_12 : XNOR2
      port map(A => \RBINNXTSHIFT[0]\, B => \WBINSYNCSHIFT[0]\, Y
         => XNOR2_12_Y);
    
    XNOR2_7 : XNOR2
      port map(A => \RBINNXTSHIFT[1]\, B => \WBINSYNCSHIFT[1]\, Y
         => XNOR2_7_Y);
    
    XOR2_12 : XOR2
      port map(A => \MEM_WADDR[12]\, B => \GND\, Y => XOR2_12_Y);
    
    AND2_48 : AND2
      port map(A => XOR2_14_Y, B => XOR2_65_Y, Y => AND2_48_Y);
    
    AND2_45 : AND2
      port map(A => \MEM_WADDR[1]\, B => \GND\, Y => AND2_45_Y);
    
    DFN1C0_5 : DFN1C0
      port map(D => \WGRY[4]\, CLK => RCLOCK, CLR => READ_RESET_P, 
        Q => DFN1C0_5_Q);
    
    DFN1C0_21 : DFN1C0
      port map(D => \RGRY[6]\, CLK => WCLOCK, CLR => 
        WRITE_RESET_P, Q => DFN1C0_21_Q);
    
    AO1_19 : AO1
      port map(A => XOR2_62_Y, B => AO1_25_Y, C => AND2_49_Y, Y
         => AO1_19_Y);
    
    \XOR2_WBINNXTSHIFT[7]\ : XOR2
      port map(A => XOR2_24_Y, B => AO1_10_Y, Y => 
        \WBINNXTSHIFT[7]\);
    
    \RAM4K9_QXI[5]\ : RAM4K9
      port map(ADDRA11 => \MEM_WADDR[11]\, ADDRA10 => 
        \MEM_WADDR[10]\, ADDRA9 => \MEM_WADDR[9]\, ADDRA8 => 
        \MEM_WADDR[8]\, ADDRA7 => \MEM_WADDR[7]\, ADDRA6 => 
        \MEM_WADDR[6]\, ADDRA5 => \MEM_WADDR[5]\, ADDRA4 => 
        \MEM_WADDR[4]\, ADDRA3 => \MEM_WADDR[3]\, ADDRA2 => 
        \MEM_WADDR[2]\, ADDRA1 => \MEM_WADDR[1]\, ADDRA0 => 
        \MEM_WADDR[0]\, ADDRB11 => \MEM_RADDR[11]\, ADDRB10 => 
        \MEM_RADDR[10]\, ADDRB9 => \MEM_RADDR[9]\, ADDRB8 => 
        \MEM_RADDR[8]\, ADDRB7 => \MEM_RADDR[7]\, ADDRB6 => 
        \MEM_RADDR[6]\, ADDRB5 => \MEM_RADDR[5]\, ADDRB4 => 
        \MEM_RADDR[4]\, ADDRB3 => \MEM_RADDR[3]\, ADDRB2 => 
        \MEM_RADDR[2]\, ADDRB1 => \MEM_RADDR[1]\, ADDRB0 => 
        \MEM_RADDR[0]\, DINA8 => \GND\, DINA7 => \GND\, DINA6 => 
        \GND\, DINA5 => \GND\, DINA4 => \GND\, DINA3 => \GND\, 
        DINA2 => \GND\, DINA1 => \GND\, DINA0 => DATA_IN(5), 
        DINB8 => \GND\, DINB7 => \GND\, DINB6 => \GND\, DINB5 => 
        \GND\, DINB4 => \GND\, DINB3 => \GND\, DINB2 => \GND\, 
        DINB1 => \GND\, DINB0 => \GND\, WIDTHA0 => \GND\, WIDTHA1
         => \GND\, WIDTHB0 => \GND\, WIDTHB1 => \GND\, PIPEA => 
        \GND\, PIPEB => \GND\, WMODEA => \GND\, WMODEB => \GND\, 
        BLKA => MEMWENEG, BLKB => MEMRENEG, WENA => \GND\, WENB
         => \VCC\, CLKA => WCLOCK, CLKB => RCLOCK, RESET => 
        WRITE_RESET_P, DOUTA8 => OPEN, DOUTA7 => OPEN, DOUTA6 => 
        OPEN, DOUTA5 => OPEN, DOUTA4 => OPEN, DOUTA3 => OPEN, 
        DOUTA2 => OPEN, DOUTA1 => OPEN, DOUTA0 => 
        \RAM4K9_QXI[5]_DOUTA0\, DOUTB8 => OPEN, DOUTB7 => OPEN, 
        DOUTB6 => OPEN, DOUTB5 => OPEN, DOUTB4 => OPEN, DOUTB3
         => OPEN, DOUTB2 => OPEN, DOUTB1 => OPEN, DOUTB0 => 
        \QXI[5]\);
    
    \DFN1C0_MEM_RADDR[12]\ : DFN1C0
      port map(D => \RBINNXTSHIFT[12]\, CLK => RCLOCK, CLR => 
        READ_RESET_P, Q => \MEM_RADDR[12]\);
    
    XOR2_26 : XOR2
      port map(A => \WBINNXTSHIFT[1]\, B => \WBINNXTSHIFT[2]\, Y
         => XOR2_26_Y);
    
    DFN1C0_1 : DFN1C0
      port map(D => \RGRY[9]\, CLK => WCLOCK, CLR => 
        WRITE_RESET_P, Q => DFN1C0_1_Q);
    
    AND2_59 : AND2
      port map(A => XOR2_62_Y, B => XOR2_58_Y, Y => AND2_59_Y);
    
    \DFN1C0_RGRY[10]\ : DFN1C0
      port map(D => XOR2_67_Y, CLK => RCLOCK, CLR => READ_RESET_P, 
        Q => \RGRY[10]\);
    
    \DFN1C0_WGRYSYNC[7]\ : DFN1C0
      port map(D => DFN1C0_8_Q, CLK => RCLOCK, CLR => 
        READ_RESET_P, Q => \WGRYSYNC[7]\);
    
    AND2_4 : AND2
      port map(A => \MEM_RADDR[4]\, B => \GND\, Y => AND2_4_Y);
    
    AND2_FULLINT : AND2
      port map(A => AND3_1_Y, B => XOR2_40_Y, Y => FULLINT);
    
    AND2_40 : AND2
      port map(A => AND2_29_Y, B => AND2_25_Y, Y => AND2_40_Y);
    
    XNOR3_12 : XNOR3
      port map(A => \RGRYSYNC[3]\, B => \RGRYSYNC[2]\, C => 
        \RGRYSYNC[1]\, Y => XNOR3_12_Y);
    
    XOR2_50 : XOR2
      port map(A => \MEM_RADDR[10]\, B => \GND\, Y => XOR2_50_Y);
    
    \DFN1C0_WGRYSYNC[6]\ : DFN1C0
      port map(D => DFN1C0_20_Q, CLK => RCLOCK, CLR => 
        READ_RESET_P, Q => \WGRYSYNC[6]\);
    
    AND2_42 : AND2
      port map(A => AND2_20_Y, B => XOR2_0_Y, Y => AND2_42_Y);
    
    \DFN1C0_WGRY[8]\ : DFN1C0
      port map(D => XOR2_45_Y, CLK => WCLOCK, CLR => 
        WRITE_RESET_P, Q => \WGRY[8]\);
    
    XNOR2_5 : XNOR2
      port map(A => \RBINSYNCSHIFT[5]\, B => \WBINNXTSHIFT[5]\, Y
         => XNOR2_5_Y);
    
    AO1_5 : AO1
      port map(A => AND2_25_Y, B => AO1_25_Y, C => AO1_23_Y, Y
         => AO1_5_Y);
    
    XNOR2_16 : XNOR2
      port map(A => \RBINNXTSHIFT[8]\, B => \WBINSYNCSHIFT[8]\, Y
         => XNOR2_16_Y);
    
    \XOR2_RBINSYNCSHIFT[11]\ : XOR2
      port map(A => \RGRYSYNC[12]\, B => \RGRYSYNC[11]\, Y => 
        \RBINSYNCSHIFT[11]\);
    
    XNOR3_41 : XNOR3
      port map(A => \RGRYSYNC[9]\, B => \RGRYSYNC[8]\, C => 
        \RGRYSYNC[7]\, Y => XNOR3_41_Y);
    
    XNOR3_32 : XNOR3
      port map(A => \WGRYSYNC[6]\, B => \WGRYSYNC[5]\, C => 
        \WGRYSYNC[4]\, Y => XNOR3_32_Y);
    
    \DFN1C0_RGRY[3]\ : DFN1C0
      port map(D => XOR2_43_Y, CLK => RCLOCK, CLR => READ_RESET_P, 
        Q => \RGRY[3]\);
    
    XOR3_2 : XOR3
      port map(A => \RGRYSYNC[12]\, B => \RGRYSYNC[11]\, C => 
        \RGRYSYNC[10]\, Y => XOR3_2_Y);
    
    XOR2_39 : XOR2
      port map(A => \WBINNXTSHIFT[10]\, B => \WBINNXTSHIFT[11]\, 
        Y => XOR2_39_Y);
    
    AND2_8 : AND2
      port map(A => XOR2_19_Y, B => XOR2_41_Y, Y => AND2_8_Y);
    
    \XNOR2_WBINSYNCSHIFT[9]\ : XNOR2
      port map(A => \WGRYSYNC[9]\, B => XNOR3_22_Y, Y => 
        \WBINSYNCSHIFT[9]\);
    
    XOR2_3 : XOR2
      port map(A => \MEM_RADDR[3]\, B => \GND\, Y => XOR2_3_Y);
    
    XOR2_54 : XOR2
      port map(A => \WBINNXTSHIFT[3]\, B => \WBINNXTSHIFT[4]\, Y
         => XOR2_54_Y);
    
    XNOR3_21 : XNOR3
      port map(A => \WGRYSYNC[12]\, B => \WGRYSYNC[11]\, C => 
        \WGRYSYNC[10]\, Y => XNOR3_21_Y);
    
    XOR3_1 : XOR3
      port map(A => \RGRYSYNC[12]\, B => \RGRYSYNC[11]\, C => 
        \RGRYSYNC[10]\, Y => XOR3_1_Y);
    
    \XOR2_RBINNXTSHIFT[11]\ : XOR2
      port map(A => XOR2_76_Y, B => AO1_36_Y, Y => 
        \RBINNXTSHIFT[11]\);
    
    AO1_27 : AO1
      port map(A => XOR2_19_Y, B => AO1_5_Y, C => AND2_58_Y, Y
         => AO1_27_Y);
    
    XOR2_51 : XOR2
      port map(A => \MEM_RADDR[3]\, B => \GND\, Y => XOR2_51_Y);
    
    XOR2_66 : XOR2
      port map(A => \MEM_WADDR[3]\, B => \GND\, Y => XOR2_66_Y);
    
    DFN1C0_24 : DFN1C0
      port map(D => \WGRY[5]\, CLK => RCLOCK, CLR => READ_RESET_P, 
        Q => DFN1C0_24_Q);
    
    AND2_56 : AND2
      port map(A => AND2_48_Y, B => AND2_41_Y, Y => AND2_56_Y);
    
    \XNOR3_RBINSYNCSHIFT[0]\ : XNOR3
      port map(A => XNOR3_43_Y, B => XNOR3_12_Y, C => XNOR3_5_Y, 
        Y => \RBINSYNCSHIFT[0]\);
    
    \DFN1C0_MEM_WADDR[1]\ : DFN1C0
      port map(D => \WBINNXTSHIFT[1]\, CLK => WCLOCK, CLR => 
        WRITE_RESET_P, Q => \MEM_WADDR[1]\);
    
    XNOR3_16 : XNOR3
      port map(A => \WGRYSYNC[6]\, B => \WGRYSYNC[5]\, C => 
        \WGRYSYNC[4]\, Y => XNOR3_16_Y);
    
    \XOR2_RBINNXTSHIFT[1]\ : XOR2
      port map(A => XOR2_36_Y, B => AND2_61_Y, Y => 
        \RBINNXTSHIFT[1]\);
    
    XOR2_17 : XOR2
      port map(A => \WBINNXTSHIFT[2]\, B => \WBINNXTSHIFT[3]\, Y
         => XOR2_17_Y);
    
    XOR2_73 : XOR2
      port map(A => \MEM_RADDR[8]\, B => \GND\, Y => XOR2_73_Y);
    
    AND2_53 : AND2
      port map(A => XOR2_9_Y, B => XOR2_3_Y, Y => AND2_53_Y);
    
    DFN1C0_13 : DFN1C0
      port map(D => \WGRY[0]\, CLK => RCLOCK, CLR => READ_RESET_P, 
        Q => DFN1C0_13_Q);
    
    XNOR3_51 : XNOR3
      port map(A => \RGRYSYNC[9]\, B => \RGRYSYNC[8]\, C => 
        \RGRYSYNC[7]\, Y => XNOR3_51_Y);
    
    AND3_7 : AND3
      port map(A => XNOR2_12_Y, B => XNOR2_7_Y, C => XNOR2_13_Y, 
        Y => AND3_7_Y);
    
    XOR2_28 : XOR2
      port map(A => \WBINNXTSHIFT[5]\, B => \WBINNXTSHIFT[6]\, Y
         => XOR2_28_Y);
    
    XNOR3_36 : XNOR3
      port map(A => XNOR3_37_Y, B => XNOR3_7_Y, C => XNOR3_19_Y, 
        Y => XNOR3_36_Y);
    
    \DFN1C0_MEM_WADDR[5]\ : DFN1C0
      port map(D => \WBINNXTSHIFT[5]\, CLK => WCLOCK, CLR => 
        WRITE_RESET_P, Q => \MEM_WADDR[5]\);
    
    XOR2_15 : XOR2
      port map(A => \WBINNXTSHIFT[9]\, B => \WBINNXTSHIFT[10]\, Y
         => XOR2_15_Y);
    
    XNOR3_48 : XNOR3
      port map(A => \WGRYSYNC[9]\, B => \WGRYSYNC[8]\, C => 
        \WGRYSYNC[7]\, Y => XNOR3_48_Y);
    
    \DFN1C0_MEM_RADDR[0]\ : DFN1C0
      port map(D => \RBINNXTSHIFT[0]\, CLK => RCLOCK, CLR => 
        READ_RESET_P, Q => \MEM_RADDR[0]\);
    
    AO1_17 : AO1
      port map(A => XOR2_41_Y, B => AND2_58_Y, C => AND2_50_Y, Y
         => AO1_17_Y);
    
    \RAM4K9_QXI[3]\ : RAM4K9
      port map(ADDRA11 => \MEM_WADDR[11]\, ADDRA10 => 
        \MEM_WADDR[10]\, ADDRA9 => \MEM_WADDR[9]\, ADDRA8 => 
        \MEM_WADDR[8]\, ADDRA7 => \MEM_WADDR[7]\, ADDRA6 => 
        \MEM_WADDR[6]\, ADDRA5 => \MEM_WADDR[5]\, ADDRA4 => 
        \MEM_WADDR[4]\, ADDRA3 => \MEM_WADDR[3]\, ADDRA2 => 
        \MEM_WADDR[2]\, ADDRA1 => \MEM_WADDR[1]\, ADDRA0 => 
        \MEM_WADDR[0]\, ADDRB11 => \MEM_RADDR[11]\, ADDRB10 => 
        \MEM_RADDR[10]\, ADDRB9 => \MEM_RADDR[9]\, ADDRB8 => 
        \MEM_RADDR[8]\, ADDRB7 => \MEM_RADDR[7]\, ADDRB6 => 
        \MEM_RADDR[6]\, ADDRB5 => \MEM_RADDR[5]\, ADDRB4 => 
        \MEM_RADDR[4]\, ADDRB3 => \MEM_RADDR[3]\, ADDRB2 => 
        \MEM_RADDR[2]\, ADDRB1 => \MEM_RADDR[1]\, ADDRB0 => 
        \MEM_RADDR[0]\, DINA8 => \GND\, DINA7 => \GND\, DINA6 => 
        \GND\, DINA5 => \GND\, DINA4 => \GND\, DINA3 => \GND\, 
        DINA2 => \GND\, DINA1 => \GND\, DINA0 => DATA_IN(3), 
        DINB8 => \GND\, DINB7 => \GND\, DINB6 => \GND\, DINB5 => 
        \GND\, DINB4 => \GND\, DINB3 => \GND\, DINB2 => \GND\, 
        DINB1 => \GND\, DINB0 => \GND\, WIDTHA0 => \GND\, WIDTHA1
         => \GND\, WIDTHB0 => \GND\, WIDTHB1 => \GND\, PIPEA => 
        \GND\, PIPEB => \GND\, WMODEA => \GND\, WMODEB => \GND\, 
        BLKA => MEMWENEG, BLKB => MEMRENEG, WENA => \GND\, WENB
         => \VCC\, CLKA => WCLOCK, CLKB => RCLOCK, RESET => 
        WRITE_RESET_P, DOUTA8 => OPEN, DOUTA7 => OPEN, DOUTA6 => 
        OPEN, DOUTA5 => OPEN, DOUTA4 => OPEN, DOUTA3 => OPEN, 
        DOUTA2 => OPEN, DOUTA1 => OPEN, DOUTA0 => 
        \RAM4K9_QXI[3]_DOUTA0\, DOUTB8 => OPEN, DOUTB7 => OPEN, 
        DOUTB6 => OPEN, DOUTB5 => OPEN, DOUTB4 => OPEN, DOUTB3
         => OPEN, DOUTB2 => OPEN, DOUTB1 => OPEN, DOUTB0 => 
        \QXI[3]\);
    
    \XNOR3_WBINSYNCSHIFT[4]\ : XNOR3
      port map(A => XNOR3_4_Y, B => XNOR3_13_Y, C => XNOR3_32_Y, 
        Y => \WBINSYNCSHIFT[4]\);
    
    XNOR2_17 : XNOR2
      port map(A => \RBINSYNCSHIFT[1]\, B => \WBINNXTSHIFT[1]\, Y
         => XNOR2_17_Y);
    
    \DFN1C0_MEM_RADDR[10]\ : DFN1C0
      port map(D => \RBINNXTSHIFT[10]\, CLK => RCLOCK, CLR => 
        READ_RESET_P, Q => \MEM_RADDR[10]\);
    
    \XOR2_WBINNXTSHIFT[11]\ : XOR2
      port map(A => XOR2_49_Y, B => AO1_29_Y, Y => 
        \WBINNXTSHIFT[11]\);
    
    AND3_4 : AND3
      port map(A => XNOR2_15_Y, B => XNOR2_8_Y, C => XNOR2_2_Y, Y
         => AND3_4_Y);
    
    XNOR3_28 : XNOR3
      port map(A => \WGRYSYNC[3]\, B => \WGRYSYNC[2]\, C => 
        \WGRYSYNC[1]\, Y => XNOR3_28_Y);
    
    \DFN1C0_RGRY[0]\ : DFN1C0
      port map(D => XOR2_13_Y, CLK => RCLOCK, CLR => READ_RESET_P, 
        Q => \RGRY[0]\);
    
    \XOR2_WBINNXTSHIFT[1]\ : XOR2
      port map(A => XOR2_48_Y, B => AND2_27_Y, Y => 
        \WBINNXTSHIFT[1]\);
    
    AND2_21 : AND2
      port map(A => AND2_40_Y, B => AND2_43_Y, Y => AND2_21_Y);
    
    AO1_37 : AO1
      port map(A => XOR2_4_Y, B => AND2_1_Y, C => AND2_30_Y, Y
         => AO1_37_Y);
    
    XOR3_7 : XOR3
      port map(A => \RGRYSYNC[12]\, B => \RGRYSYNC[11]\, C => 
        \RGRYSYNC[10]\, Y => XOR3_7_Y);
    
    \DFN1C0_WGRY[4]\ : DFN1C0
      port map(D => XOR2_46_Y, CLK => WCLOCK, CLR => 
        WRITE_RESET_P, Q => \WGRY[4]\);
    
    DFN1C0_25 : DFN1C0
      port map(D => \RGRY[8]\, CLK => WCLOCK, CLR => 
        WRITE_RESET_P, Q => DFN1C0_25_Q);
    
    XNOR3_17 : XNOR3
      port map(A => \WGRYSYNC[12]\, B => \WGRYSYNC[11]\, C => 
        \WGRYSYNC[10]\, Y => XNOR3_17_Y);
    
    XOR2_0 : XOR2
      port map(A => \MEM_WADDR[6]\, B => \GND\, Y => XOR2_0_Y);
    
    XOR2_70 : XOR2
      port map(A => \RBINNXTSHIFT[5]\, B => \RBINNXTSHIFT[6]\, Y
         => XOR2_70_Y);
    
    NAND2_1 : NAND2
      port map(A => \EMPTY\, B => \VCC\, Y => NAND2_1_Y);
    
    DFN1C0_22 : DFN1C0
      port map(D => \WGRY[9]\, CLK => RCLOCK, CLR => READ_RESET_P, 
        Q => DFN1C0_22_Q);
    
    \XNOR3_WBINSYNCSHIFT[6]\ : XNOR3
      port map(A => \WGRYSYNC[6]\, B => XOR3_3_Y, C => XNOR3_26_Y, 
        Y => \WBINSYNCSHIFT[6]\);
    
    \DFN1C0_RGRYSYNC[8]\ : DFN1C0
      port map(D => DFN1C0_25_Q, CLK => WCLOCK, CLR => 
        WRITE_RESET_P, Q => \RGRYSYNC[8]\);
    
    AO1_4 : AO1
      port map(A => XOR2_47_Y, B => AND2_52_Y, C => AND2_13_Y, Y
         => AO1_4_Y);
    
    XOR2_68 : XOR2
      port map(A => \MEM_RADDR[6]\, B => \GND\, Y => XOR2_68_Y);
    
    AND2_37 : AND2
      port map(A => AND2_29_Y, B => XOR2_62_Y, Y => AND2_37_Y);
    
    XNOR3_4 : XNOR3
      port map(A => \WGRYSYNC[12]\, B => \WGRYSYNC[11]\, C => 
        \WGRYSYNC[10]\, Y => XNOR3_4_Y);
    
    \DFN1E1C0_DATA_OUT[4]\ : DFN1E1C0
      port map(D => \QXI[4]\, CLK => RCLOCK, CLR => READ_RESET_P, 
        E => DVLDI, Q => DATA_OUT(4));
    
    XNOR2_14 : XNOR2
      port map(A => \RBINNXTSHIFT[3]\, B => \WBINSYNCSHIFT[3]\, Y
         => XNOR2_14_Y);
    
    XOR2_42 : XOR2
      port map(A => \RBINNXTSHIFT[2]\, B => \RBINNXTSHIFT[3]\, Y
         => XOR2_42_Y);
    
    \XOR2_RBINNXTSHIFT[2]\ : XOR2
      port map(A => XOR2_34_Y, B => AO1_14_Y, Y => 
        \RBINNXTSHIFT[2]\);
    
    XNOR3_37 : XNOR3
      port map(A => \RGRYSYNC[12]\, B => \RGRYSYNC[11]\, C => 
        \RGRYSYNC[10]\, Y => XNOR3_37_Y);
    
    AO1_21 : AO1
      port map(A => XOR2_53_Y, B => AO1_2_Y, C => AND2_1_Y, Y => 
        AO1_21_Y);
    
    \DFN1C0_MEM_RADDR[9]\ : DFN1C0
      port map(D => \RBINNXTSHIFT[9]\, CLK => RCLOCK, CLR => 
        READ_RESET_P, Q => \MEM_RADDR[9]\);
    
    XOR2_36 : XOR2
      port map(A => \MEM_RADDR[1]\, B => \GND\, Y => XOR2_36_Y);
    
    XOR2_74 : XOR2
      port map(A => \MEM_RADDR[12]\, B => \GND\, Y => XOR2_74_Y);
    
    \XNOR3_RBINSYNCSHIFT[6]\ : XNOR3
      port map(A => \RGRYSYNC[6]\, B => XOR3_5_Y, C => XNOR3_0_Y, 
        Y => \RBINSYNCSHIFT[6]\);
    
    XNOR2_8 : XNOR2
      port map(A => \RBINSYNCSHIFT[7]\, B => \WBINNXTSHIFT[7]\, Y
         => XNOR2_8_Y);
    
    XNOR3_2 : XNOR3
      port map(A => \RGRYSYNC[3]\, B => \RGRYSYNC[2]\, C => 
        \RGRYSYNC[1]\, Y => XNOR3_2_Y);
    
    XOR2_71 : XOR2
      port map(A => \MEM_RADDR[12]\, B => \GND\, Y => XOR2_71_Y);
    
    AND2_28 : AND2
      port map(A => AND2_36_Y, B => XOR2_53_Y, Y => AND2_28_Y);
    
    AND2_25 : AND2
      port map(A => AND2_59_Y, B => AND2_44_Y, Y => AND2_25_Y);
    
    \DFN1C0_MEM_RADDR[11]\ : DFN1C0
      port map(D => \RBINNXTSHIFT[11]\, CLK => RCLOCK, CLR => 
        READ_RESET_P, Q => \MEM_RADDR[11]\);
    
    \DFN1C0_WGRYSYNC[5]\ : DFN1C0
      port map(D => DFN1C0_24_Q, CLK => RCLOCK, CLR => 
        READ_RESET_P, Q => \WGRYSYNC[5]\);
    
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
-- LPMTYPE:LPM_SOFTFIFO
-- LPM_HINT:MEMFF
-- INSERT_PAD:NO
-- INSERT_IOREG:NO
-- GEN_BHV_VHDL_VAL:F
-- GEN_BHV_VERILOG_VAL:F
-- MGNTIMER:F
-- MGNCMPL:T
-- DESDIR:D:/0_all_libero_project/CERN_LHCb/COMET_TEST/smartgen\FIFO4096XBYTES
-- GEN_BEHV_MODULE:F
-- SMARTGEN_DIE:IT10X10M3
-- SMARTGEN_PACKAGE:pq208
-- AGENIII_IS_SUBPROJECT_LIBERO:T
-- WWIDTH:8
-- WDEPTH:4096
-- RWIDTH:8
-- RDEPTH:4096
-- CLKS:2
-- WCLOCK_PN:WCLOCK
-- RCLOCK_PN:RCLOCK
-- WCLK_EDGE:RISE
-- RCLK_EDGE:RISE
-- ACLR_PN:RESET
-- RESET_POLARITY:0
-- INIT_RAM:F
-- WE_POLARITY:0
-- RE_POLARITY:0
-- FF_PN:FULL
-- AF_PN:AFULL
-- WACK_PN:WACK
-- OVRFLOW_PN:OVERFLOW
-- WRCNT_PN:WRCNT
-- WE_PN:WE_B
-- EF_PN:EMPTY
-- AE_PN:AEMPTY
-- DVLD_PN:DVLD
-- UDRFLOW_PN:UNDERFLOW
-- RDCNT_PN:RDCNT
-- RE_PN:RE_B
-- CONTROLLERONLY:F
-- FSTOP:YES
-- ESTOP:YES
-- WRITEACK:NO
-- OVERFLOW:NO
-- WRCOUNT:NO
-- DATAVALID:NO
-- UNDERFLOW:NO
-- RDCOUNT:NO
-- AF_PORT_PN:AFVAL
-- AE_PORT_PN:AEVAL
-- AFFLAG:NONE
-- AEFLAG:NONE
-- DATA_IN_PN:DATA_IN
-- DATA_OUT_PN:DATA_OUT
-- CASCADE:0

-- _End_Comments_

