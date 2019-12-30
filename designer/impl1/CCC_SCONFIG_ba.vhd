-- Version: v11.5 SP2 11.5.2.6
-- File used only for Simulation

library ieee;
use ieee.std_logic_1164.all;
library proasic3e;
use proasic3e.all;

entity CCC_SCONFIG is

    port( CLK_PH1_160MHZ : in    std_logic;
          DEV_RST_B      : in    std_logic;
          CLK40M_GEN     : in    std_logic;
          DYN_SMODE      : in    std_logic;
          STATASEL_Q     : in    std_logic;
          STATBSEL_R     : in    std_logic;
          STATCSEL_S     : in    std_logic;
          DYNASEL_U      : in    std_logic;
          DYNBSEL_V      : in    std_logic;
          DYNCSEL_W      : in    std_logic;
          PHASE_ADJ_L    : in    std_logic_vector(50 downto 46);
          LOCK_STATUS    : out   std_logic;
          CCC_160M_ADJ   : out   std_logic
        );

end CCC_SCONFIG;

architecture DEF_ARCH of CCC_SCONFIG is 

  component DFN1C0
    port( D   : in    std_logic := 'U';
          CLK : in    std_logic := 'U';
          CLR : in    std_logic := 'U';
          Q   : out   std_logic
        );
  end component;

  component NOR3C
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          C : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component DYNCCC
    generic (VCOFREQUENCY:real := 0.0);

    port( CLKA      : in    std_logic := 'U';
          EXTFB     : in    std_logic := 'U';
          POWERDOWN : in    std_logic := 'U';
          GLA       : out   std_logic;
          LOCK      : out   std_logic;
          CLKB      : in    std_logic := 'U';
          GLB       : out   std_logic;
          YB        : out   std_logic;
          CLKC      : in    std_logic := 'U';
          GLC       : out   std_logic;
          YC        : out   std_logic;
          SDIN      : in    std_logic := 'U';
          SCLK      : in    std_logic := 'U';
          SSHIFT    : in    std_logic := 'U';
          SUPDATE   : in    std_logic := 'U';
          MODE      : in    std_logic := 'U';
          SDOUT     : out   std_logic;
          OADIV0    : in    std_logic := 'U';
          OADIV1    : in    std_logic := 'U';
          OADIV2    : in    std_logic := 'U';
          OADIV3    : in    std_logic := 'U';
          OADIV4    : in    std_logic := 'U';
          OAMUX0    : in    std_logic := 'U';
          OAMUX1    : in    std_logic := 'U';
          OAMUX2    : in    std_logic := 'U';
          DLYGLA0   : in    std_logic := 'U';
          DLYGLA1   : in    std_logic := 'U';
          DLYGLA2   : in    std_logic := 'U';
          DLYGLA3   : in    std_logic := 'U';
          DLYGLA4   : in    std_logic := 'U';
          OBDIV0    : in    std_logic := 'U';
          OBDIV1    : in    std_logic := 'U';
          OBDIV2    : in    std_logic := 'U';
          OBDIV3    : in    std_logic := 'U';
          OBDIV4    : in    std_logic := 'U';
          OBMUX0    : in    std_logic := 'U';
          OBMUX1    : in    std_logic := 'U';
          OBMUX2    : in    std_logic := 'U';
          DLYYB0    : in    std_logic := 'U';
          DLYYB1    : in    std_logic := 'U';
          DLYYB2    : in    std_logic := 'U';
          DLYYB3    : in    std_logic := 'U';
          DLYYB4    : in    std_logic := 'U';
          DLYGLB0   : in    std_logic := 'U';
          DLYGLB1   : in    std_logic := 'U';
          DLYGLB2   : in    std_logic := 'U';
          DLYGLB3   : in    std_logic := 'U';
          DLYGLB4   : in    std_logic := 'U';
          OCDIV0    : in    std_logic := 'U';
          OCDIV1    : in    std_logic := 'U';
          OCDIV2    : in    std_logic := 'U';
          OCDIV3    : in    std_logic := 'U';
          OCDIV4    : in    std_logic := 'U';
          OCMUX0    : in    std_logic := 'U';
          OCMUX1    : in    std_logic := 'U';
          OCMUX2    : in    std_logic := 'U';
          DLYYC0    : in    std_logic := 'U';
          DLYYC1    : in    std_logic := 'U';
          DLYYC2    : in    std_logic := 'U';
          DLYYC3    : in    std_logic := 'U';
          DLYYC4    : in    std_logic := 'U';
          DLYGLC0   : in    std_logic := 'U';
          DLYGLC1   : in    std_logic := 'U';
          DLYGLC2   : in    std_logic := 'U';
          DLYGLC3   : in    std_logic := 'U';
          DLYGLC4   : in    std_logic := 'U';
          FINDIV0   : in    std_logic := 'U';
          FINDIV1   : in    std_logic := 'U';
          FINDIV2   : in    std_logic := 'U';
          FINDIV3   : in    std_logic := 'U';
          FINDIV4   : in    std_logic := 'U';
          FINDIV5   : in    std_logic := 'U';
          FINDIV6   : in    std_logic := 'U';
          FBDIV0    : in    std_logic := 'U';
          FBDIV1    : in    std_logic := 'U';
          FBDIV2    : in    std_logic := 'U';
          FBDIV3    : in    std_logic := 'U';
          FBDIV4    : in    std_logic := 'U';
          FBDIV5    : in    std_logic := 'U';
          FBDIV6    : in    std_logic := 'U';
          FBDLY0    : in    std_logic := 'U';
          FBDLY1    : in    std_logic := 'U';
          FBDLY2    : in    std_logic := 'U';
          FBDLY3    : in    std_logic := 'U';
          FBDLY4    : in    std_logic := 'U';
          FBSEL0    : in    std_logic := 'U';
          FBSEL1    : in    std_logic := 'U';
          XDLYSEL   : in    std_logic := 'U';
          VCOSEL0   : in    std_logic := 'U';
          VCOSEL1   : in    std_logic := 'U';
          VCOSEL2   : in    std_logic := 'U'
        );
  end component;

  component OA1C
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          C : in    std_logic := 'U';
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

  component OR2
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component MX2
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          S : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component IOPAD_IN
    port( PAD : in    std_logic := 'U';
          Y   : out   std_logic
        );
  end component;

  component NOR2B
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
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

  component OR2B
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component IOIN_IB
    port( YIN : in    std_logic := 'U';
          Y   : out   std_logic
        );
  end component;

  component NOR3A
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

  component NOR2
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
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

  component IOPAD_TRI
    port( D   : in    std_logic := 'U';
          E   : in    std_logic := 'U';
          PAD : out   std_logic
        );
  end component;

  component AO1C
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          C : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component NOR2A
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

  component CLKIO
    port( A : in    std_logic := 'U';
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

  component IOTRI_OB_EB
    port( D    : in    std_logic := 'U';
          E    : in    std_logic := 'U';
          DOUT : out   std_logic;
          EOUT : out   std_logic
        );
  end component;

  component DFN1P0
    port( D   : in    std_logic := 'U';
          CLK : in    std_logic := 'U';
          PRE : in    std_logic := 'U';
          Q   : out   std_logic
        );
  end component;

  component OR3
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

  component AO1A
    port( A : in    std_logic := 'U';
          B : in    std_logic := 'U';
          C : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

  component BUFF
    port( A : in    std_logic := 'U';
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

  component GND
    port(Y : out std_logic); 
  end component;

  component VCC
    port(Y : out std_logic); 
  end component;

    signal SDIN, SSHIFT, SUPDATE, \ALL81BITS[46]\, 
        \ALL81BITS[47]\, \ALL81BITS[48]\, \ALL81BITS[49]\, 
        \ALL81BITS[50]\, \SHIFT_SM[4]_net_1\, \ALL81BITS[2]\, 
        \ALL81BITS[71]\, \ALL81BITS[72]\, \ALL81BITS[73]\, 
        \ALL81BITS[76]_net_1\, \ALL81BITS[77]\, \ALL81BITS[78]\, 
        \ALL81BITS[79]\, \BITCNT[0]\, \BITCNT[1]\, \BITCNT[2]\, 
        \BITCNT[3]\, \BITCNT[4]\, \BITCNT[5]\, \BITCNT[6]\, 
        \SHIFT_SM[2]_net_1\, \SHIFT_SM[0]_net_1\, 
        \SHIFT_SM[5]_net_1\, \SHIFT_SM_RNO[1]_net_1\, 
        \SHIFT_SM_RNO[0]_net_1\, \SHIFT_SM_ns[0]\, N_73, N_74, 
        N_20, CLK_PH1_160MHZ_c, DEV_RST_B_c, CLK40M_GEN_c, 
        DYN_SMODE_c, STATASEL_Q_c, STATBSEL_R_c, STATCSEL_S_c, 
        DYNASEL_U_c, DYNBSEL_V_c, DYNCSEL_W_c, 
        \PHASE_ADJ_L_c[46]\, \PHASE_ADJ_L_c[47]\, 
        \PHASE_ADJ_L_c[48]\, \PHASE_ADJ_L_c[49]\, 
        \PHASE_ADJ_L_c[50]\, LOCK_STATUS_c, CCC_160M_ADJ_c, N_291, 
        N_SUPDATE_0_sqmuxa, N_10, BITCNTe, N_12, N_14, N_16, N_9, 
        N_18, N_69, N_37, N_32, N_15, un1_SHIFT_SM_4_i_1, N_89, 
        N_76, N_77, N_34, N_93, N_31, N_35, N_21, N_303_1, N_78, 
        N_58_2, N_33, N_53, N_51, N_55, N_44, N_90, N_54, N_42, 
        N_58, N_40, N_59, N_60, N_61, N_63, \CCC_CFG.N_SDIN_2\, 
        N_45, N_50, N_91, N_43, 
        \CCC_CFG.N_SDIN_2_0_iv_0_173_net_1\, 
        \CCC_CFG.N_SDIN_2_0_iv_0_a3_2_2_net_1\, 
        \CCC_CFG.N_SDIN_2_0_iv_0_a3_8_2_net_1\, 
        \CCC_CFG.N_SDIN_2_0_iv_0_a3_2_2_0_net_1\, 
        \CCC_CFG.N_SDIN_2_0_iv_0_a3_4_2_net_1\, 
        \CCC_CFG.N_SDIN_2_0_iv_0_a3_8_2_0_net_1\, 
        \CCC_CFG.N_SDIN_2_0_iv_0_a3_9_1_net_1\, 
        \CCC_CFG.N_SDIN_2_0_iv_0_a3_9_2_net_1\, 
        \CCC_CFG.N_SDIN_2_0_iv_0_a3_0_1_net_1\, 
        \CCC_CFG.N_SDIN_2_0_iv_0_a3_5_0_net_1\, 
        \CCC_CFG.N_SDIN_2_0_iv_0_a3_3_0_net_1\, 
        N_SUPDATE_0_sqmuxa_0_a2_4_a3_1, 
        \CCC_CFG.N_SDIN_2_0_iv_0_a3_7_0_net_1\, 
        \CCC_CFG.N_SDIN_2_0_iv_0_a3_6_0_net_1\, 
        \CCC_CFG.N_SDIN_2_0_iv_0_a3_4_1\, 
        \CCC_CFG.N_SDIN_2_0_iv_0_a3_10_2_net_1\, 
        \CCC_CFG.N_SDIN_2_0_iv_0_2_net_1\, 
        \CCC_CFG.N_SDIN_2_0_iv_0_4_net_1\, 
        \CCC_CFG.N_SDIN_2_0_iv_0_5_net_1\, 
        \CCC_CFG.N_SDIN_2_0_iv_0_6_net_1\, 
        \CCC_CFG.N_SDIN_2_0_iv_0_7_net_1\, BITCNT_n3_i_0, 
        BITCNT_n5_i_0, \SHIFT_SM_i_0[1]\, \SHIFT_SM_i_0[3]\, 
        \SHIFT_SM_i[4]\, DEV_RST_B_c_0, \GND\, \VCC\, 
        \DYNCSEL_W_pad/U0/NET1\, \DEV_RST_B_pad/U0/NET1\, 
        \STATBSEL_R_pad/U0/NET1\, \PHASE_ADJ_L_pad[48]/U0/NET1\, 
        \PHASE_ADJ_L_pad[46]/U0/NET1\, \STATCSEL_S_pad/U0/NET1\, 
        \STATASEL_Q_pad/U0/NET1\, \PHASE_ADJ_L_pad[50]/U0/NET1\, 
        \DYNBSEL_V_pad/U0/NET1\, \PHASE_ADJ_L_pad[49]/U0/NET1\, 
        \PHASE_ADJ_L_pad[47]/U0/NET1\, \CLK40M_GEN_pad/U0/NET1\, 
        \CCC_160M_ADJ_pad/U0/NET1\, \CCC_160M_ADJ_pad/U0/NET2\, 
        \LOCK_STATUS_pad/U0/NET1\, \LOCK_STATUS_pad/U0/NET2\, 
        \DYN_SMODE_pad/U0/NET1\, \CLK_PH1_160MHZ_pad/U0/NET1\, 
        \DYNASEL_U_pad/U0/NET1\, \BITCNT[0]/Y\, \BITCNT[5]/Y\, 
        \ALL81BITS[79]/Y\, \SUPDATE/Y\, \ALL81BITS[78]/Y\, 
        \ALL81BITS[72]/Y\, \BITCNT[1]/Y\, \ALL81BITS[77]/Y\, 
        \ALL81BITS[71]/Y\, \BITCNT[4]/Y\, \ALL81BITS[73]/Y\, 
        \BITCNT[2]/Y\, \ALL81BITS[49]/Y\, \SSHIFT/Y\, 
        \ALL81BITS[48]/Y\, \ALL81BITS[47]/Y\, \ALL81BITS[50]/Y\, 
        \BITCNT[3]/Y\, \ALL81BITS[46]/Y\, \BITCNT[6]/Y\, \SDIN/Y\, 
        AFLSDF_VCC, AFLSDF_GND, \AFLSDF_INV_0\ : std_logic;
    signal GND_power_net1 : std_logic;
    signal VCC_power_net1 : std_logic;

begin 

    AFLSDF_GND <= GND_power_net1;
    \GND\ <= GND_power_net1;
    \VCC\ <= VCC_power_net1;
    AFLSDF_VCC <= VCC_power_net1;

    \BITCNT[1]/U1\ : DFN1C0
      port map(D => \BITCNT[1]/Y\, CLK => CLK40M_GEN_c, CLR => 
        DEV_RST_B_c_0, Q => \BITCNT[1]\);
    
    \CCC_CFG.N_SDIN_2_0_iv_0_a3_10_2\ : NOR3C
      port map(A => \BITCNT[5]\, B => \ALL81BITS[47]\, C => 
        \CCC_CFG.N_SDIN_2_0_iv_0_a3_4_1\, Y => 
        \CCC_CFG.N_SDIN_2_0_iv_0_a3_10_2_net_1\);
    
    \U1_CCC/Core\ : DYNCCC
      generic map(VCOFREQUENCY => 160.315)

      port map(CLKA => CLK_PH1_160MHZ_c, EXTFB => \GND\, 
        POWERDOWN => \VCC\, GLA => CCC_160M_ADJ_c, LOCK => 
        LOCK_STATUS_c, CLKB => \GND\, GLB => OPEN, YB => OPEN, 
        CLKC => \GND\, GLC => OPEN, YC => OPEN, SDIN => SDIN, 
        SCLK => \AFLSDF_INV_0\, SSHIFT => SSHIFT, SUPDATE => 
        SUPDATE, MODE => DYN_SMODE_c, SDOUT => OPEN, OADIV0 => 
        \GND\, OADIV1 => \GND\, OADIV2 => \GND\, OADIV3 => \GND\, 
        OADIV4 => \GND\, OAMUX0 => \GND\, OAMUX1 => \GND\, OAMUX2
         => \VCC\, DLYGLA0 => \VCC\, DLYGLA1 => \GND\, DLYGLA2
         => \VCC\, DLYGLA3 => \GND\, DLYGLA4 => \GND\, OBDIV0 => 
        \VCC\, OBDIV1 => \VCC\, OBDIV2 => \VCC\, OBDIV3 => \VCC\, 
        OBDIV4 => \VCC\, OBMUX0 => \GND\, OBMUX1 => \GND\, OBMUX2
         => \GND\, DLYYB0 => \GND\, DLYYB1 => \GND\, DLYYB2 => 
        \GND\, DLYYB3 => \GND\, DLYYB4 => \GND\, DLYGLB0 => \GND\, 
        DLYGLB1 => \GND\, DLYGLB2 => \GND\, DLYGLB3 => \GND\, 
        DLYGLB4 => \GND\, OCDIV0 => \VCC\, OCDIV1 => \VCC\, 
        OCDIV2 => \VCC\, OCDIV3 => \VCC\, OCDIV4 => \VCC\, OCMUX0
         => \GND\, OCMUX1 => \GND\, OCMUX2 => \GND\, DLYYC0 => 
        \GND\, DLYYC1 => \GND\, DLYYC2 => \GND\, DLYYC3 => \GND\, 
        DLYYC4 => \GND\, DLYGLC0 => \GND\, DLYGLC1 => \GND\, 
        DLYGLC2 => \GND\, DLYGLC3 => \GND\, DLYGLC4 => \GND\, 
        FINDIV0 => \VCC\, FINDIV1 => \GND\, FINDIV2 => \VCC\, 
        FINDIV3 => \VCC\, FINDIV4 => \VCC\, FINDIV5 => \GND\, 
        FINDIV6 => \GND\, FBDIV0 => \VCC\, FBDIV1 => \GND\, 
        FBDIV2 => \VCC\, FBDIV3 => \VCC\, FBDIV4 => \VCC\, FBDIV5
         => \GND\, FBDIV6 => \GND\, FBDLY0 => \GND\, FBDLY1 => 
        \GND\, FBDLY2 => \GND\, FBDLY3 => \GND\, FBDLY4 => \GND\, 
        FBSEL0 => \VCC\, FBSEL1 => \GND\, XDLYSEL => \GND\, 
        VCOSEL0 => \GND\, VCOSEL1 => \GND\, VCOSEL2 => \VCC\);
    
    \BITCNT_RNO_0[3]\ : OA1C
      port map(A => \BITCNT[2]\, B => N_15, C => \BITCNT[3]\, Y
         => BITCNT_n3_i_0);
    
    \BITCNT_RNO[4]\ : XA1C
      port map(A => \BITCNT[4]\, B => N_32, C => 
        un1_SHIFT_SM_4_i_1, Y => N_14);
    
    \ALL81BITS_RNO[76]\ : OR2
      port map(A => \ALL81BITS[76]_net_1\, B => 
        \SHIFT_SM[4]_net_1\, Y => N_73);
    
    \ALL81BITS[50]/U0\ : MX2
      port map(A => \ALL81BITS[50]\, B => \PHASE_ADJ_L_c[50]\, S
         => \SHIFT_SM[4]_net_1\, Y => \ALL81BITS[50]/Y\);
    
    \STATASEL_Q_pad/U0/U0\ : IOPAD_IN
      port map(PAD => STATASEL_Q, Y => \STATASEL_Q_pad/U0/NET1\);
    
    \SDIN/U0\ : MX2
      port map(A => SDIN, B => \CCC_CFG.N_SDIN_2\, S => 
        \SHIFT_SM[2]_net_1\, Y => \SDIN/Y\);
    
    \BITCNT_RNIJVQK[6]\ : NOR2B
      port map(A => N_34, B => \BITCNT[6]\, Y => N_21);
    
    \PHASE_ADJ_L_pad[48]/U0/U0\ : IOPAD_IN
      port map(PAD => PHASE_ADJ_L(48), Y => 
        \PHASE_ADJ_L_pad[48]/U0/NET1\);
    
    \SDIN/U1\ : DFN1C0
      port map(D => \SDIN/Y\, CLK => CLK40M_GEN_c, CLR => 
        DEV_RST_B_c, Q => SDIN);
    
    \ALL81BITS[46]/U1\ : DFN1C0
      port map(D => \ALL81BITS[46]/Y\, CLK => CLK40M_GEN_c, CLR
         => DEV_RST_B_c_0, Q => \ALL81BITS[46]\);
    
    \DYN_SMODE_pad/U0/U0\ : IOPAD_IN
      port map(PAD => DYN_SMODE, Y => \DYN_SMODE_pad/U0/NET1\);
    
    \PHASE_ADJ_L_pad[49]/U0/U0\ : IOPAD_IN
      port map(PAD => PHASE_ADJ_L(49), Y => 
        \PHASE_ADJ_L_pad[49]/U0/NET1\);
    
    \CCC_CFG.N_SDIN_2_0_iv_0_a3_9_1\ : NOR2B
      port map(A => \BITCNT[4]\, B => \BITCNT[6]\, Y => 
        \CCC_CFG.N_SDIN_2_0_iv_0_a3_9_1_net_1\);
    
    \ALL81BITS[71]/U0\ : MX2
      port map(A => \ALL81BITS[71]\, B => STATASEL_Q_c, S => 
        \SHIFT_SM[4]_net_1\, Y => \ALL81BITS[71]/Y\);
    
    \CCC_CFG.N_SDIN_2_0_iv_0_a3_6\ : NOR3B
      port map(A => N_76, B => 
        \CCC_CFG.N_SDIN_2_0_iv_0_a3_6_0_net_1\, C => N_34, Y => 
        N_60);
    
    \BITCNT[5]/U1\ : DFN1C0
      port map(D => \BITCNT[5]/Y\, CLK => CLK40M_GEN_c, CLR => 
        DEV_RST_B_c_0, Q => \BITCNT[5]\);
    
    \BITCNT_RNIPBSD[0]\ : OR2B
      port map(A => \BITCNT[0]\, B => \BITCNT[1]\, Y => N_15);
    
    \STATBSEL_R_pad/U0/U0\ : IOPAD_IN
      port map(PAD => STATBSEL_R, Y => \STATBSEL_R_pad/U0/NET1\);
    
    \CCC_CFG.N_SDIN_2_0_iv_0_m2\ : MX2
      port map(A => \ALL81BITS[2]\, B => \ALL81BITS[46]\, S => 
        \BITCNT[3]\, Y => N_40);
    
    \STATBSEL_R_pad/U0/U1\ : IOIN_IB
      port map(YIN => \STATBSEL_R_pad/U0/NET1\, Y => STATBSEL_R_c);
    
    \ALL81BITS_RNO[0]\ : OR2
      port map(A => \ALL81BITS[2]\, B => \SHIFT_SM[4]_net_1\, Y
         => N_74);
    
    \CCC_CFG.N_SDIN_2_0_iv_0_a3_0_1\ : NOR3A
      port map(A => N_78, B => N_35, C => \BITCNT[6]\, Y => 
        \CCC_CFG.N_SDIN_2_0_iv_0_a3_0_1_net_1\);
    
    \BITCNT_RNO[3]\ : NOR3A
      port map(A => N_32, B => BITCNT_n3_i_0, C => 
        un1_SHIFT_SM_4_i_1, Y => N_16);
    
    \SHIFT_SM[4]\ : DFN1C0
      port map(D => \SHIFT_SM[5]_net_1\, CLK => CLK40M_GEN_c, CLR
         => DEV_RST_B_c, Q => \SHIFT_SM[4]_net_1\);
    
    \SHIFT_SM_RNO[5]\ : NOR2B
      port map(A => N_89, B => \SHIFT_SM[0]_net_1\, Y => 
        \SHIFT_SM_ns[0]\);
    
    \ALL81BITS[72]/U1\ : DFN1C0
      port map(D => \ALL81BITS[72]/Y\, CLK => CLK40M_GEN_c, CLR
         => DEV_RST_B_c, Q => \ALL81BITS[72]\);
    
    AFLSDF_INV_0 : INV
      port map(A => CLK40M_GEN_c, Y => \AFLSDF_INV_0\);
    
    \CCC_CFG.N_SDIN_2_0_iv_0_o2_1_RNIN6AS\ : OR2
      port map(A => N_31, B => N_15, Y => N_32);
    
    \ALL81BITS[77]/U1\ : DFN1C0
      port map(D => \ALL81BITS[77]/Y\, CLK => CLK40M_GEN_c, CLR
         => DEV_RST_B_c, Q => \ALL81BITS[77]\);
    
    \CCC_CFG.N_SDIN_2_0_iv_0_a3_10_1\ : NOR2
      port map(A => \BITCNT[4]\, B => \BITCNT[6]\, Y => 
        \CCC_CFG.N_SDIN_2_0_iv_0_a3_4_1\);
    
    \ALL81BITS[46]/U0\ : MX2
      port map(A => \ALL81BITS[46]\, B => \PHASE_ADJ_L_c[46]\, S
         => \SHIFT_SM[4]_net_1\, Y => \ALL81BITS[46]/Y\);
    
    \DYN_SMODE_pad/U0/U1\ : IOIN_IB
      port map(YIN => \DYN_SMODE_pad/U0/NET1\, Y => DYN_SMODE_c);
    
    \CCC_CFG.N_SDIN_2_0_iv_0_a3_7_0\ : NOR2
      port map(A => \BITCNT[3]\, B => N_33, Y => 
        \CCC_CFG.N_SDIN_2_0_iv_0_a3_7_0_net_1\);
    
    \PHASE_ADJ_L_pad[47]/U0/U1\ : IOIN_IB
      port map(YIN => \PHASE_ADJ_L_pad[47]/U0/NET1\, Y => 
        \PHASE_ADJ_L_c[47]\);
    
    \DEV_RST_B_pad/U0/U1\ : IOIN_IB
      port map(YIN => \DEV_RST_B_pad/U0/NET1\, Y => DEV_RST_B_c);
    
    \PHASE_ADJ_L_pad[50]/U0/U1\ : IOIN_IB
      port map(YIN => \PHASE_ADJ_L_pad[50]/U0/NET1\, Y => 
        \PHASE_ADJ_L_c[50]\);
    
    \BITCNT_RNO[0]\ : NOR2
      port map(A => N_303_1, B => \BITCNT[0]\, Y => N_69);
    
    \ALL81BITS[49]/U1\ : DFN1C0
      port map(D => \ALL81BITS[49]/Y\, CLK => CLK40M_GEN_c, CLR
         => DEV_RST_B_c_0, Q => \ALL81BITS[49]\);
    
    \ALL81BITS[79]/U0\ : MX2
      port map(A => \ALL81BITS[79]\, B => DYNCSEL_W_c, S => 
        \SHIFT_SM[4]_net_1\, Y => \ALL81BITS[79]/Y\);
    
    \SHIFT_SM_RNIN5DM[1]\ : NOR2B
      port map(A => \SHIFT_SM_i_0[1]\, B => N_291, Y => BITCNTe);
    
    \SHIFT_SM_RNI7DFL2[0]\ : OR2
      port map(A => N_303_1, B => N_89, Y => un1_SHIFT_SM_4_i_1);
    
    \CCC_CFG.N_SDIN_2_0_iv_0_a3_9_2\ : NOR3B
      port map(A => \ALL81BITS[76]_net_1\, B => 
        \CCC_CFG.N_SDIN_2_0_iv_0_a3_9_1_net_1\, C => \BITCNT[5]\, 
        Y => \CCC_CFG.N_SDIN_2_0_iv_0_a3_9_2_net_1\);
    
    \SHIFT_SM_RNO[1]\ : OR3C
      port map(A => \BITCNT[6]\, B => \SHIFT_SM[2]_net_1\, C => 
        N_34, Y => \SHIFT_SM_RNO[1]_net_1\);
    
    \BITCNT_RNO[6]\ : OA1C
      port map(A => N_37, B => \BITCNT[6]\, C => 
        un1_SHIFT_SM_4_i_1, Y => N_10);
    
    \LOCK_STATUS_pad/U0/U0\ : IOPAD_TRI
      port map(D => \LOCK_STATUS_pad/U0/NET1\, E => 
        \LOCK_STATUS_pad/U0/NET2\, PAD => LOCK_STATUS);
    
    \BITCNT[1]/U0\ : MX2
      port map(A => \BITCNT[1]\, B => N_18, S => BITCNTe, Y => 
        \BITCNT[1]/Y\);
    
    \SHIFT_SM_RNO[2]\ : AO1C
      port map(A => N_21, B => \SHIFT_SM[2]_net_1\, C => 
        \SHIFT_SM_i_0[3]\, Y => N_20);
    
    \BITCNT[3]/U1\ : DFN1C0
      port map(D => \BITCNT[3]/Y\, CLK => CLK40M_GEN_c, CLR => 
        DEV_RST_B_c_0, Q => \BITCNT[3]\);
    
    \BITCNT_RNO[5]\ : NOR3A
      port map(A => N_37, B => BITCNT_n5_i_0, C => 
        un1_SHIFT_SM_4_i_1, Y => N_12);
    
    \ALL81BITS[78]/U0\ : MX2
      port map(A => \ALL81BITS[78]\, B => DYNBSEL_V_c, S => 
        \SHIFT_SM[4]_net_1\, Y => \ALL81BITS[78]/Y\);
    
    \PHASE_ADJ_L_pad[46]/U0/U1\ : IOIN_IB
      port map(YIN => \PHASE_ADJ_L_pad[46]/U0/NET1\, Y => 
        \PHASE_ADJ_L_c[46]\);
    
    \ALL81BITS[71]/U1\ : DFN1C0
      port map(D => \ALL81BITS[71]/Y\, CLK => CLK40M_GEN_c, CLR
         => DEV_RST_B_c_0, Q => \ALL81BITS[71]\);
    
    \SSHIFT/U1\ : DFN1C0
      port map(D => \SSHIFT/Y\, CLK => CLK40M_GEN_c, CLR => 
        DEV_RST_B_c_0, Q => SSHIFT);
    
    \CCC_CFG.N_SDIN_2_0_iv_0_a3_2_2\ : NOR3C
      port map(A => \CCC_CFG.N_SDIN_2_0_iv_0_a3_2_2_0_net_1\, B
         => \BITCNT[3]\, C => N_42, Y => 
        \CCC_CFG.N_SDIN_2_0_iv_0_a3_2_2_net_1\);
    
    \ALL81BITS[50]/U1\ : DFN1C0
      port map(D => \ALL81BITS[50]/Y\, CLK => CLK40M_GEN_c, CLR
         => DEV_RST_B_c_0, Q => \ALL81BITS[50]\);
    
    \CCC_CFG.N_SDIN_2_0_iv_0_m2_3\ : MX2
      port map(A => \ALL81BITS[76]_net_1\, B => \ALL81BITS[78]\, 
        S => \BITCNT[1]\, Y => N_45);
    
    \CCC_CFG.N_SDIN_2_0_iv_0_a3_6_0\ : NOR2A
      port map(A => \BITCNT[1]\, B => \BITCNT[2]\, Y => 
        \CCC_CFG.N_SDIN_2_0_iv_0_a3_6_0_net_1\);
    
    \CCC_CFG.N_SDIN_2_0_iv_0_173\ : OA1
      port map(A => \CCC_CFG.N_SDIN_2_0_iv_0_a3_2_2_net_1\, B => 
        \CCC_CFG.N_SDIN_2_0_iv_0_a3_8_2_net_1\, C => N_77, Y => 
        \CCC_CFG.N_SDIN_2_0_iv_0_173_net_1\);
    
    \CCC_CFG.N_SDIN_2_0_iv_0_a2_3\ : NOR2A
      port map(A => N_76, B => \BITCNT[5]\, Y => N_93);
    
    \DYNASEL_U_pad/U0/U1\ : IOIN_IB
      port map(YIN => \DYNASEL_U_pad/U0/NET1\, Y => DYNASEL_U_c);
    
    \SUPDATE/U1\ : DFN1C0
      port map(D => \SUPDATE/Y\, CLK => CLK40M_GEN_c, CLR => 
        DEV_RST_B_c_0, Q => SUPDATE);
    
    \CLK40M_GEN_pad/U0/U1\ : CLKIO
      port map(A => \CLK40M_GEN_pad/U0/NET1\, Y => CLK40M_GEN_c);
    
    \CCC_CFG.N_SDIN_2_0_iv_0_m2_2\ : MX2A
      port map(A => \BITCNT[4]\, B => \BITCNT[2]\, S => N_33, Y
         => N_44);
    
    \ALL81BITS[76]\ : DFN1C0
      port map(D => N_73, CLK => CLK40M_GEN_c, CLR => DEV_RST_B_c, 
        Q => \ALL81BITS[76]_net_1\);
    
    \CCC_CFG.N_SDIN_2_0_iv_0_o2_1\ : OR2B
      port map(A => \BITCNT[2]\, B => \BITCNT[3]\, Y => N_31);
    
    \CCC_CFG.N_SDIN_2_0_iv_0_a3_5_0\ : NOR2B
      port map(A => \BITCNT[4]\, B => \BITCNT[2]\, Y => 
        \CCC_CFG.N_SDIN_2_0_iv_0_a3_5_0_net_1\);
    
    \CLK_PH1_160MHZ_pad/U0/U0\ : IOPAD_IN
      port map(PAD => CLK_PH1_160MHZ, Y => 
        \CLK_PH1_160MHZ_pad/U0/NET1\);
    
    \CCC_CFG.N_SDIN_2_0_iv_0_a2_2\ : NOR2A
      port map(A => N_43, B => \BITCNT[0]\, Y => N_91);
    
    \CCC_CFG.N_SDIN_2_0_iv_0_a3_4\ : NOR3C
      port map(A => N_40, B => \CCC_CFG.N_SDIN_2_0_iv_0_a3_4_1\, 
        C => \CCC_CFG.N_SDIN_2_0_iv_0_a3_4_2_net_1\, Y => N_58);
    
    \STATASEL_Q_pad/U0/U1\ : IOIN_IB
      port map(YIN => \STATASEL_Q_pad/U0/NET1\, Y => STATASEL_Q_c);
    
    \BITCNT[3]/U0\ : MX2
      port map(A => \BITCNT[3]\, B => N_16, S => BITCNTe, Y => 
        \BITCNT[3]/Y\);
    
    \ALL81BITS[48]/U1\ : DFN1C0
      port map(D => \ALL81BITS[48]/Y\, CLK => CLK40M_GEN_c, CLR
         => DEV_RST_B_c_0, Q => \ALL81BITS[48]\);
    
    \LOCK_STATUS_pad/U0/U1\ : IOTRI_OB_EB
      port map(D => LOCK_STATUS_c, E => \VCC\, DOUT => 
        \LOCK_STATUS_pad/U0/NET1\, EOUT => 
        \LOCK_STATUS_pad/U0/NET2\);
    
    \DYNCSEL_W_pad/U0/U0\ : IOPAD_IN
      port map(PAD => DYNCSEL_W, Y => \DYNCSEL_W_pad/U0/NET1\);
    
    \ALL81BITS[47]/U0\ : MX2
      port map(A => \ALL81BITS[47]\, B => \PHASE_ADJ_L_c[47]\, S
         => \SHIFT_SM[4]_net_1\, Y => \ALL81BITS[47]/Y\);
    
    \SHIFT_SM_RNO[0]\ : AO1C
      port map(A => N_89, B => \SHIFT_SM[0]_net_1\, C => 
        \SHIFT_SM_i_0[1]\, Y => \SHIFT_SM_RNO[0]_net_1\);
    
    \PHASE_ADJ_L_pad[50]/U0/U0\ : IOPAD_IN
      port map(PAD => PHASE_ADJ_L(50), Y => 
        \PHASE_ADJ_L_pad[50]/U0/NET1\);
    
    \CCC_CFG.N_SDIN_2_0_iv_0_m2_5\ : MX2
      port map(A => \ALL81BITS[48]\, B => \ALL81BITS[50]\, S => 
        \BITCNT[1]\, Y => N_43);
    
    \CCC_CFG.N_SDIN_2_0_iv_0_a3_0\ : OA1
      port map(A => N_91, B => N_90, C => 
        \CCC_CFG.N_SDIN_2_0_iv_0_a3_0_1_net_1\, Y => N_54);
    
    \BITCNT[4]/U1\ : DFN1C0
      port map(D => \BITCNT[4]/Y\, CLK => CLK40M_GEN_c, CLR => 
        DEV_RST_B_c_0, Q => \BITCNT[4]\);
    
    \BITCNT[2]/U1\ : DFN1C0
      port map(D => \BITCNT[2]/Y\, CLK => CLK40M_GEN_c, CLR => 
        DEV_RST_B_c_0, Q => \BITCNT[2]\);
    
    \DYNCSEL_W_pad/U0/U1\ : IOIN_IB
      port map(YIN => \DYNCSEL_W_pad/U0/NET1\, Y => DYNCSEL_W_c);
    
    \SHIFT_SM[3]\ : DFN1P0
      port map(D => \SHIFT_SM_i[4]\, CLK => CLK40M_GEN_c, PRE => 
        DEV_RST_B_c, Q => \SHIFT_SM_i_0[3]\);
    
    \STATCSEL_S_pad/U0/U1\ : IOIN_IB
      port map(YIN => \STATCSEL_S_pad/U0/NET1\, Y => STATCSEL_S_c);
    
    \CLK40M_GEN_pad/U0/U0\ : IOPAD_IN
      port map(PAD => CLK40M_GEN, Y => \CLK40M_GEN_pad/U0/NET1\);
    
    \ALL81BITS[0]\ : DFN1C0
      port map(D => N_74, CLK => CLK40M_GEN_c, CLR => DEV_RST_B_c, 
        Q => \ALL81BITS[2]\);
    
    \SSHIFT/U0\ : MX2
      port map(A => SSHIFT, B => \SHIFT_SM[2]_net_1\, S => N_291, 
        Y => \SSHIFT/Y\);
    
    \PHASE_ADJ_L_pad[48]/U0/U1\ : IOIN_IB
      port map(YIN => \PHASE_ADJ_L_pad[48]/U0/NET1\, Y => 
        \PHASE_ADJ_L_c[48]\);
    
    \SUPDATE/U0\ : MX2
      port map(A => SUPDATE, B => N_SUPDATE_0_sqmuxa, S => N_291, 
        Y => \SUPDATE/Y\);
    
    \CCC_CFG.N_SDIN_2_0_iv_0_a3_8_2\ : NOR3A
      port map(A => \CCC_CFG.N_SDIN_2_0_iv_0_a3_8_2_0_net_1\, B
         => \BITCNT[3]\, C => N_15, Y => 
        \CCC_CFG.N_SDIN_2_0_iv_0_a3_8_2_net_1\);
    
    \BITCNT[6]/U0\ : MX2
      port map(A => \BITCNT[6]\, B => N_10, S => BITCNTe, Y => 
        \BITCNT[6]/Y\);
    
    \PHASE_ADJ_L_pad[49]/U0/U1\ : IOIN_IB
      port map(YIN => \PHASE_ADJ_L_pad[49]/U0/NET1\, Y => 
        \PHASE_ADJ_L_c[49]\);
    
    \CCC_CFG.N_SDIN_2_0_iv_0_a3_2_2_0\ : NOR2
      port map(A => \BITCNT[2]\, B => \BITCNT[1]\, Y => 
        \CCC_CFG.N_SDIN_2_0_iv_0_a3_2_2_0_net_1\);
    
    \CCC_CFG.N_SDIN_2_0_iv_0_a2\ : NOR2A
      port map(A => \ALL81BITS[2]\, B => \BITCNT[6]\, Y => N_76);
    
    \CCC_CFG.N_SDIN_2_0_iv_0_m2_4\ : MX2
      port map(A => \ALL81BITS[77]\, B => \ALL81BITS[79]\, S => 
        \BITCNT[1]\, Y => N_50);
    
    \CCC_CFG.N_SDIN_2_0_iv_0_o2_2_RNIM1OA1\ : OR2
      port map(A => N_35, B => N_32, Y => N_37);
    
    \ALL81BITS[79]/U1\ : DFN1C0
      port map(D => \ALL81BITS[79]/Y\, CLK => CLK40M_GEN_c, CLR
         => DEV_RST_B_c, Q => \ALL81BITS[79]\);
    
    \CCC_CFG.N_SDIN_2_0_iv_0_a3\ : NOR3B
      port map(A => N_51, B => N_77, C => N_31, Y => N_53);
    
    \CCC_CFG.N_SDIN_2_0_iv_0_6\ : OR3
      port map(A => N_53, B => N_61, C => 
        \CCC_CFG.N_SDIN_2_0_iv_0_2_net_1\, Y => 
        \CCC_CFG.N_SDIN_2_0_iv_0_6_net_1\);
    
    \SHIFT_SM[5]\ : DFN1P0
      port map(D => \SHIFT_SM_ns[0]\, CLK => CLK40M_GEN_c, PRE
         => DEV_RST_B_c, Q => \SHIFT_SM[5]_net_1\);
    
    \BITCNT_RNO_0[5]\ : OA1C
      port map(A => \BITCNT[4]\, B => N_32, C => \BITCNT[5]\, Y
         => BITCNT_n5_i_0);
    
    \BITCNT[2]/U0\ : MX2
      port map(A => \BITCNT[2]\, B => N_9, S => BITCNTe, Y => 
        \BITCNT[2]/Y\);
    
    \BITCNT_RNO[2]\ : XA1C
      port map(A => \BITCNT[2]\, B => N_15, C => 
        un1_SHIFT_SM_4_i_1, Y => N_9);
    
    \BITCNT_RNO[1]\ : XA1B
      port map(A => \BITCNT[1]\, B => \BITCNT[0]\, C => 
        un1_SHIFT_SM_4_i_1, Y => N_18);
    
    \STATCSEL_S_pad/U0/U0\ : IOPAD_IN
      port map(PAD => STATCSEL_S, Y => \STATCSEL_S_pad/U0/NET1\);
    
    \SHIFT_SM_RNO[3]\ : INV
      port map(A => \SHIFT_SM[4]_net_1\, Y => \SHIFT_SM_i[4]\);
    
    \CCC_CFG.N_SDIN_2_0_iv_0_a3_5\ : NOR3B
      port map(A => \CCC_CFG.N_SDIN_2_0_iv_0_a3_5_0_net_1\, B => 
        N_93, C => \BITCNT[3]\, Y => N_59);
    
    \CCC_CFG.N_SDIN_2_0_iv_0_7\ : AO1A
      port map(A => N_32, B => 
        \CCC_CFG.N_SDIN_2_0_iv_0_a3_10_2_net_1\, C => 
        \CCC_CFG.N_SDIN_2_0_iv_0_4_net_1\, Y => 
        \CCC_CFG.N_SDIN_2_0_iv_0_7_net_1\);
    
    \BITCNT[4]/U0\ : MX2
      port map(A => \BITCNT[4]\, B => N_14, S => BITCNTe, Y => 
        \BITCNT[4]/Y\);
    
    \CCC_CFG.N_SDIN_2_0_iv_0\ : OR3
      port map(A => \CCC_CFG.N_SDIN_2_0_iv_0_6_net_1\, B => 
        \CCC_CFG.N_SDIN_2_0_iv_0_5_net_1\, C => 
        \CCC_CFG.N_SDIN_2_0_iv_0_7_net_1\, Y => 
        \CCC_CFG.N_SDIN_2\);
    
    \CCC_CFG.N_SDIN_2_0_iv_0_4\ : OR3
      port map(A => N_63, B => N_58, C => N_55, Y => 
        \CCC_CFG.N_SDIN_2_0_iv_0_4_net_1\);
    
    \PHASE_ADJ_L_pad[47]/U0/U0\ : IOPAD_IN
      port map(PAD => PHASE_ADJ_L(47), Y => 
        \PHASE_ADJ_L_pad[47]/U0/NET1\);
    
    \CCC_CFG.N_SDIN_2_0_iv_0_a3_7\ : NOR3B
      port map(A => N_76, B => 
        \CCC_CFG.N_SDIN_2_0_iv_0_a3_7_0_net_1\, C => N_34, Y => 
        N_61);
    
    \SHIFT_SM[1]\ : DFN1P0
      port map(D => \SHIFT_SM_RNO[1]_net_1\, CLK => CLK40M_GEN_c, 
        PRE => DEV_RST_B_c, Q => \SHIFT_SM_i_0[1]\);
    
    \ALL81BITS[73]/U1\ : DFN1C0
      port map(D => \ALL81BITS[73]/Y\, CLK => CLK40M_GEN_c, CLR
         => DEV_RST_B_c, Q => \ALL81BITS[73]\);
    
    \CCC_CFG.N_SDIN_2_0_iv_0_a3_4_2_0\ : NOR3C
      port map(A => \BITCNT[2]\, B => \BITCNT[5]\, C => N_58_2, Y
         => \CCC_CFG.N_SDIN_2_0_iv_0_a3_4_2_net_1\);
    
    \SHIFT_SM[0]\ : DFN1C0
      port map(D => \SHIFT_SM_RNO[0]_net_1\, CLK => CLK40M_GEN_c, 
        CLR => DEV_RST_B_c, Q => \SHIFT_SM[0]_net_1\);
    
    \SHIFT_SM_RNIH5UE[3]\ : NOR2A
      port map(A => \SHIFT_SM_i_0[3]\, B => \SHIFT_SM[4]_net_1\, 
        Y => N_291);
    
    \BITCNT[0]/U0\ : MX2
      port map(A => \BITCNT[0]\, B => N_69, S => BITCNTe, Y => 
        \BITCNT[0]/Y\);
    
    \ALL81BITS[73]/U0\ : MX2
      port map(A => \ALL81BITS[73]\, B => STATCSEL_S_c, S => 
        \SHIFT_SM[4]_net_1\, Y => \ALL81BITS[73]/Y\);
    
    \BITCNT_RNI1KSD[5]\ : OR2
      port map(A => \BITCNT[5]\, B => \BITCNT[4]\, Y => N_34);
    
    \PHASE_ADJ_L_pad[46]/U0/U0\ : IOPAD_IN
      port map(PAD => PHASE_ADJ_L(46), Y => 
        \PHASE_ADJ_L_pad[46]/U0/NET1\);
    
    \ALL81BITS[47]/U1\ : DFN1C0
      port map(D => \ALL81BITS[47]/Y\, CLK => CLK40M_GEN_c, CLR
         => DEV_RST_B_c_0, Q => \ALL81BITS[47]\);
    
    SUPDATE_RNO_0 : NOR3B
      port map(A => \SHIFT_SM[0]_net_1\, B => N_58_2, C => 
        \BITCNT[6]\, Y => N_SUPDATE_0_sqmuxa_0_a2_4_a3_1);
    
    \CCC_CFG.N_SDIN_2_0_iv_0_a3_3_0\ : OA1C
      port map(A => \BITCNT[3]\, B => \BITCNT[4]\, C => N_15, Y
         => \CCC_CFG.N_SDIN_2_0_iv_0_a3_3_0_net_1\);
    
    \DYNBSEL_V_pad/U0/U1\ : IOIN_IB
      port map(YIN => \DYNBSEL_V_pad/U0/NET1\, Y => DYNBSEL_V_c);
    
    \SHIFT_SM_RNIVVO31[0]\ : OA1C
      port map(A => \SHIFT_SM[2]_net_1\, B => N_21, C => 
        \SHIFT_SM[0]_net_1\, Y => N_303_1);
    
    \CCC_CFG.N_SDIN_2_0_iv_0_a3_8_2_0\ : NOR2B
      port map(A => \ALL81BITS[71]\, B => \BITCNT[2]\, Y => 
        \CCC_CFG.N_SDIN_2_0_iv_0_a3_8_2_0_net_1\);
    
    \DEV_RST_B_pad/U0/U0\ : IOPAD_IN
      port map(PAD => DEV_RST_B, Y => \DEV_RST_B_pad/U0/NET1\);
    
    SUPDATE_RNO : NOR3B
      port map(A => N_78, B => N_SUPDATE_0_sqmuxa_0_a2_4_a3_1, C
         => N_34, Y => N_SUPDATE_0_sqmuxa);
    
    \CCC_160M_ADJ_pad/U0/U1\ : IOTRI_OB_EB
      port map(D => CCC_160M_ADJ_c, E => \VCC\, DOUT => 
        \CCC_160M_ADJ_pad/U0/NET1\, EOUT => 
        \CCC_160M_ADJ_pad/U0/NET2\);
    
    \DYNBSEL_V_pad/U0/U0\ : IOPAD_IN
      port map(PAD => DYNBSEL_V, Y => \DYNBSEL_V_pad/U0/NET1\);
    
    \ALL81BITS[78]/U1\ : DFN1C0
      port map(D => \ALL81BITS[78]/Y\, CLK => CLK40M_GEN_c, CLR
         => DEV_RST_B_c, Q => \ALL81BITS[78]\);
    
    \BITCNT_RNITFSD[2]\ : NOR2
      port map(A => \BITCNT[2]\, B => \BITCNT[3]\, Y => N_78);
    
    \ALL81BITS[49]/U0\ : MX2
      port map(A => \ALL81BITS[49]\, B => \PHASE_ADJ_L_c[49]\, S
         => \SHIFT_SM[4]_net_1\, Y => \ALL81BITS[49]/Y\);
    
    DEV_RST_B_pad_RNICBV3 : BUFF
      port map(A => DEV_RST_B_c, Y => DEV_RST_B_c_0);
    
    \DYNASEL_U_pad/U0/U0\ : IOPAD_IN
      port map(PAD => DYNASEL_U, Y => \DYNASEL_U_pad/U0/NET1\);
    
    \CCC_CFG.N_SDIN_2_0_iv_0_2\ : AO1
      port map(A => \CCC_CFG.N_SDIN_2_0_iv_0_a3_3_0_net_1\, B => 
        N_93, C => N_60, Y => \CCC_CFG.N_SDIN_2_0_iv_0_2_net_1\);
    
    \BITCNT_RNI8DMH1[6]\ : NOR2A
      port map(A => \BITCNT[6]\, B => N_37, Y => N_89);
    
    \ALL81BITS[77]/U0\ : MX2
      port map(A => \ALL81BITS[77]\, B => DYNASEL_U_c, S => 
        \SHIFT_SM[4]_net_1\, Y => \ALL81BITS[77]/Y\);
    
    \BITCNT_RNIPBSD_0[0]\ : OR2
      port map(A => \BITCNT[0]\, B => \BITCNT[1]\, Y => N_33);
    
    \CCC_CFG.N_SDIN_2_0_iv_0_m2_0\ : MX2
      port map(A => \ALL81BITS[72]\, B => \ALL81BITS[73]\, S => 
        \BITCNT[0]\, Y => N_42);
    
    \CCC_CFG.N_SDIN_2_0_iv_0_m2_1\ : MX2
      port map(A => N_45, B => N_50, S => \BITCNT[0]\, Y => N_51);
    
    \CCC_160M_ADJ_pad/U0/U0\ : IOPAD_TRI
      port map(D => \CCC_160M_ADJ_pad/U0/NET1\, E => 
        \CCC_160M_ADJ_pad/U0/NET2\, PAD => CCC_160M_ADJ);
    
    \CLK_PH1_160MHZ_pad/U0/U1\ : IOIN_IB
      port map(YIN => \CLK_PH1_160MHZ_pad/U0/NET1\, Y => 
        CLK_PH1_160MHZ_c);
    
    \BITCNT[5]/U0\ : MX2
      port map(A => \BITCNT[5]\, B => N_12, S => BITCNTe, Y => 
        \BITCNT[5]/Y\);
    
    \CCC_CFG.N_SDIN_2_0_iv_0_a3_1\ : NOR3B
      port map(A => N_93, B => \BITCNT[3]\, C => N_44, Y => N_55);
    
    \CCC_CFG.N_SDIN_2_0_iv_0_o2_2\ : OR2B
      port map(A => \BITCNT[5]\, B => \BITCNT[4]\, Y => N_35);
    
    \BITCNT[0]/U1\ : DFN1C0
      port map(D => \BITCNT[0]/Y\, CLK => CLK40M_GEN_c, CLR => 
        DEV_RST_B_c_0, Q => \BITCNT[0]\);
    
    \ALL81BITS[48]/U0\ : MX2
      port map(A => \ALL81BITS[48]\, B => \PHASE_ADJ_L_c[48]\, S
         => \SHIFT_SM[4]_net_1\, Y => \ALL81BITS[48]/Y\);
    
    \CCC_CFG.N_SDIN_2_0_iv_0_5\ : OR3
      port map(A => N_54, B => N_59, C => 
        \CCC_CFG.N_SDIN_2_0_iv_0_173_net_1\, Y => 
        \CCC_CFG.N_SDIN_2_0_iv_0_5_net_1\);
    
    \CCC_CFG.N_SDIN_2_0_iv_0_a2_0\ : NOR2A
      port map(A => \BITCNT[6]\, B => N_34, Y => N_77);
    
    \CCC_CFG.N_SDIN_2_0_iv_0_a2_1\ : NOR3B
      port map(A => \BITCNT[0]\, B => \ALL81BITS[49]\, C => 
        \BITCNT[1]\, Y => N_90);
    
    \ALL81BITS[72]/U0\ : MX2
      port map(A => \ALL81BITS[72]\, B => STATBSEL_R_c, S => 
        \SHIFT_SM[4]_net_1\, Y => \ALL81BITS[72]/Y\);
    
    \CCC_CFG.N_SDIN_2_0_iv_0_a3_4_2\ : NOR2A
      port map(A => \BITCNT[1]\, B => \BITCNT[0]\, Y => N_58_2);
    
    \CCC_CFG.N_SDIN_2_0_iv_0_a3_9\ : NOR3B
      port map(A => \CCC_CFG.N_SDIN_2_0_iv_0_a3_9_2_net_1\, B => 
        N_78, C => N_33, Y => N_63);
    
    \BITCNT[6]/U1\ : DFN1C0
      port map(D => \BITCNT[6]/Y\, CLK => CLK40M_GEN_c, CLR => 
        DEV_RST_B_c_0, Q => \BITCNT[6]\);
    
    \SHIFT_SM[2]\ : DFN1C0
      port map(D => N_20, CLK => CLK40M_GEN_c, CLR => DEV_RST_B_c, 
        Q => \SHIFT_SM[2]_net_1\);
    
    GND_power_inst1 : GND
      port map( Y => GND_power_net1);

    VCC_power_inst1 : VCC
      port map( Y => VCC_power_net1);


end DEF_ARCH; 
