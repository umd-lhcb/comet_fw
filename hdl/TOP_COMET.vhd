--------------------------------------------------------------------------------
-- Company: UNIVERSITY OF MARYLAND
--
-- File: TOP_COMET.vhd
-- File history:
--      REV - // SEPT 16, 2015 // INITIAL VERSION
--      REV A // JUNE 6, 2015 // ADDED TOTAL OF 5 ELINKS VIA ELINK_SLAVE MODULES
--      REV B // JUNE 7, 2015 // ADDED TOTAL OF 20 ELINKS VIA ELINK SLAVE MODULES
--
-- Description: USB CONTROLLED PATTERN GENERATOR
--      FUNCTIONS:
--          USB INTERFACE TO PATTERN GENERATOR CONTROL REGISTERS
--          USB INTERFACE TO 1 TFC PATTERN RAM 256 BYTE BL0CK AND UP TO 20 ELINK PATTERN 256 BYTE RAM BLOCKS
--          EACH 256 BYTE RAM BLOCK HAS AN ADDITIONAL 1/2 CONTROLLED BY AN 8TH ADDRESS BIT.  THIS IS FOR FUTURE USE.....
--          RAM BLOCKS CAN BE READ OR WRITTEN.
--                      THE TFC AND ELINK0 CHANNELS OPERATE AS 'MASTERS' WITH ACTIVE TIMING DESKEW ON RX
--                      THE REMAINDER OF THE ELINKS OPERATE AS SLAVES WITH TIME OFFSETS RELATIVE TO THE MASTERS.
--
-- Targeted device: <Family::ProASIC3E> <Die::A3PE1500> <Package::208 PQFP>
-- Author: TOM O'BANNON
--
--##################################################################################################################################
--# !!!!! NOTE !!!!! FPGA_STV_D PAIRS:  23,     22,     19,     20      .......  
--#                  ...ON FPGA PINS:   91/90,  87/86,  85/84,  164/165 ARE FLIPPED (IE INVERTED) ON THE PASSIVE TERMINATION DAUGHTER BOARD
--#                                      ...FOR ELINKS:         0,              1,              4,              3  (ELINK0 IS A MASTER ADDRESSED BELOW, WHEREAS THE OTHER 3 ARE HANDLED VIA ELINK_SLAVE_INV.VHD)
--#                  SO, THE SIGNAL ASSIGNMENTS BELOW FOR THESE SPECIFIC PAIRS ARE INVERTED.
--#                  THE INVERSION NEEDS TO BE DONE IN THE LOGIC RATHER THAN PINS SWAPS SINCE PHYSICAL LIBRARY MACROS ARE BEING INSTANTIATED.
--##################################################################################################################################
-- CAUTION:  SIM_MODE CONSTANT NEEDS TO BE MANUALLY UPDATED!!!!!
--------------------------------------------------------------------------------

library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.STD_LOGIC_MISC.all;

library proasic3e;
use proasic3e.all;

library synplify;
use synplify.attributes.all;

entity TOP_COMET is
  port (
    CLK200_P : in std_logic;            -- EXTERNAL LVDS CLOCK ON COMET BOARDS
    CLK200_N : in std_logic;

    BP_CLK40_P : in std_logic;            -- LVDS CLOCK coming from Pathfinder backplane
    BP_CLK40_N : in std_logic;

    DEV_RST_B : in std_logic;  -- ACTIVE LOW RESET --DEDICATED COMET BOARD RC TIME CONSTANT

-- GPIO TEST AND CONFIG SIGNALS
    DCB_SALT_SEL    : in  std_logic;  -- GPIO_0:  '1'= DCB MODE (IE TFC MASTER TX ENABLED) // '0'=SALT HYBRID MODE (IE TFC MASTER RX W/ SYNC MODE ENABLED)
    EXTCLK_40MHZ    : out std_logic;  -- GPIO_1:  40 MHZ CLOCK- RX VAL FOR SALT, TX VAL FOR DCB CONFIG
    EXT_INT_REF_SEL : in  std_logic;  -- GPIO_9   '1' = CCC USE REC'D REF CLOCKS, '0' BOARD TRANSMITS REF CLOCK SIGNALS

    ALL_PLL_LOCK    : out std_logic;  -- GPIO_10: LOCK STATUS OF BOTH CCC#1 (FIXED) AND CCC #2 (DYNAMIC CLOCK USED FOR THE DESERIALIZER RX)
    P_MASTER_POR_B  : out std_logic;    -- GPIO_2:  MASTER_POR_B
    P_USB_MASTER_EN : out std_logic;    -- GPIO_7:  USB_MASTER_EN
-- SPARE     :   OUT STD_LOGIC;                          -- GPIO_3:  
    P_CLK_40M_GL    : out std_logic;    -- GPIO_4:  CCC#1 FIXED CLOCK OUT
-- SPARE        P_CLK_PH1_160MHZ    :   OUT STD_LOGIC;                          -- GPIO_8:  CCC#1 FIXED CLOCK OUT
    P_CCC_160M_FXD  : out std_logic;    -- GPIO_6:  CCC#1 FIXED 160MHZ CLOCK
    P_CCC_160M_ADJ  : out std_logic;    -- GPIO_5:  CCC#2 ADJ 160MHZ CLOCK

-- I2C PORT CONN BEING USED FOR STATUS
    P_ELK0_SYNC_DET : out std_logic;    -- I2C_SDAT_0
    P_TFC_SYNC_DET  : out std_logic;    -- I2C_SCLK_0

    P_OP_MODE1_SPE : out std_logic;     -- I2C_SCLK_1---SYNC PATT EN
    P_OP_MODE2_TE  : out std_logic;     -- I2C_SDAT_1---TFC EN
    P_OP_MODE5_AAE : out std_logic;     -- I2C_SCLK_2---AUTO ALIGN EN
    P_OP_MODE6_EE  : out std_logic;     -- I2C_SDAT_2---ELINKS EN

-- THESE SIGNALS USE THE CAT6 I/O CONN'S TO PASS REF CLOCKS BETWEEN COMET FPGA'S
    BIDIR_CLK40M_P : inout std_logic;  -- 40 MHZ REF CLOCK FOR CCC#1: EITHER LOCAL OSC OR EXTERNAL REC'D DIFF CLOCK SOURCE
    BIDIR_CLK40M_N : inout std_logic;  -- 40 MHZ REF CLOCK FOR CCC#1: EITHER LOCAL OSC OR EXTERNAL REC'D DIFF CLOCK SOURCE

    TX_CLK40M_P : out std_logic;  -- TX DISTRIBUTION COPY OF 40 MHZ REF CLOCK FOR CCC#1
    TX_CLK40M_N : out std_logic;

-- IO RELATED TO USB INTERFACE (SYNCHRONOUS TO THE USB 60 MHZ CLOCK)
    USBCLK60MHZ : in std_logic;  -- CLOCK FROM THE USM MODULE DERIVED FROM A 12MHZ CRYSTAL ON-BOARD THE USB MODULE PLL

    BIDIR_USB_ADBUS : inout std_logic_vector(7 downto 0);  -- USB:  BI-DIRECTIONAL ADDRESS AND DATA BUS
    USB_OE_B        : out   std_logic;  -- USB:  ACTIVE LOW TURNS ON THE USB DATA BUS OUTPUT MODE

    P_USB_RXF_B : in  std_logic;  -- USB:  ACTIVE LOW SIGNIFIES THAT THE ON-BOARD USB FIFO HAS DATA TO BE READ (IE READ TRANSFER REQUEST)
    USB_RD_B    : out std_logic;  -- USB:  ACTIVE LOW STATE FETCHES NEXT BYTE FROM THE FIFO ON THE NEXT CLK60MHZ CLOCK EDGE

    P_USB_TXE_B : in  std_logic;  -- USB:  ACTIVE LOW SIGNIFIES THAT THE ON-BOARD USB FIFO CAN NOW ACCEPT DATA (IE WRITE TRANSFER ENABLED)
    USB_WR_B    : out std_logic;  -- USB:  ACTIVE LOW STATE ENABLE DATA TO BE WRITTEN TO THE FIFO ON THE NEXT CLK60MHZ CLOCK EDGE

    USB_SIWU_B : out   std_logic;  -- USB:  ACTIVE LOW--Send Immediate / WakeUp signal (CAN BE USED TO OPTIMIZE DATA TRANSFER RATES)
                                     -- TIE HIGH IF NOT USED
-- STAVE IO VIA DAUGHTER BOARDS AND ERM8 CONNS
-- PORT DIRECTIONS DETERMINED BY DCB_SALT_SEL JUMPER
    TFC_DAT_0P : inout std_logic;       -- SERIAL LVDS TFC COMMAND BIDIR PORT
    TFC_DAT_0N : inout std_logic;
    REF_CLK_0P : inout std_logic;  -- 40 MHZ REF CLK LVDS BIDIR PORT SYNCHRONOUS TO THE TCF OUTPUT BYTE RATE.  
    REF_CLK_0N : inout std_logic;  -- DCB MODE TRANSMITS THE REFCLK, SALT MODE RECEIVES THE REFCLK

    ELK0_DAT_P : inout std_logic;       -- SERIAL LVDS ELINK0 DATA BIDIR PORT
    ELK0_DAT_N : inout std_logic;

    ELK1_DAT_P : inout std_logic;       -- SERIAL LVDS ELINK1 DATA BIDIR PORT
    ELK1_DAT_N : inout std_logic;

    ELK2_DAT_P : inout std_logic;       -- SERIAL LVDS ELINK2 DATA BIDIR PORT
    ELK2_DAT_N : inout std_logic;

    ELK3_DAT_P : inout std_logic;       -- SERIAL LVDS ELINK3 DATA BIDIR PORT
    ELK3_DAT_N : inout std_logic;

    ELK4_DAT_P : inout std_logic;       -- SERIAL LVDS ELINK4 DATA BIDIR PORT
    ELK4_DAT_N : inout std_logic;

    ELK5_DAT_P : inout std_logic;       -- SERIAL LVDS ELINK5 DATA BIDIR PORT
    ELK5_DAT_N : inout std_logic;

    ELK6_DAT_P : inout std_logic;       -- SERIAL LVDS ELINK6 DATA BIDIR PORT
    ELK6_DAT_N : inout std_logic;

    ELK7_DAT_P : inout std_logic;       -- SERIAL LVDS ELINK7 DATA BIDIR PORT
    ELK7_DAT_N : inout std_logic;

    ELK8_DAT_P : inout std_logic;       -- SERIAL LVDS ELINK8 DATA BIDIR PORT
    ELK8_DAT_N : inout std_logic;

    ELK9_DAT_P : inout std_logic;       -- SERIAL LVDS ELINK9 DATA BIDIR PORT
    ELK9_DAT_N : inout std_logic;

    ELK10_DAT_P : inout std_logic;      -- SERIAL LVDS ELINK10 DATA BIDIR PORT
    ELK10_DAT_N : inout std_logic;

    ELK11_DAT_P : inout std_logic;      -- SERIAL LVDS ELINK11 DATA BIDIR PORT
    ELK11_DAT_N : inout std_logic;

    ELK12_DAT_P : inout std_logic;      -- SERIAL LVDS ELINK12 DATA BIDIR PORT
    ELK12_DAT_N : inout std_logic;

    ELK13_DAT_P : inout std_logic;      -- SERIAL LVDS ELINK13 DATA BIDIR PORT
    ELK13_DAT_N : inout std_logic;

    ELK14_DAT_P : inout std_logic;      -- SERIAL LVDS ELINK14 DATA BIDIR PORT
    ELK14_DAT_N : inout std_logic;

    ELK15_DAT_P : inout std_logic;      -- SERIAL LVDS ELINK15 DATA BIDIR PORT
    ELK15_DAT_N : inout std_logic;

    ELK16_DAT_P : inout std_logic;      -- SERIAL LVDS ELINK16 DATA BIDIR PORT
    ELK16_DAT_N : inout std_logic;

    ELK17_DAT_P : inout std_logic;      -- SERIAL LVDS ELINK17 DATA BIDIR PORT
    ELK17_DAT_N : inout std_logic;

    ELK18_DAT_P : inout std_logic;      -- SERIAL LVDS ELINK18 DATA BIDIR PORT
    ELK18_DAT_N : inout std_logic;

    ELK19_DAT_P : inout std_logic;      -- SERIAL LVDS ELINK19 DATA BIDIR PORT
    ELK19_DAT_N : inout std_logic;

    ELK20_DAT_P : inout std_logic;      -- SERIAL LVDS ELINK19 DATA BIDIR PORT
    ELK20_DAT_N : inout std_logic;

    ELK21_DAT_P : inout std_logic;      -- SERIAL LVDS ELINK19 DATA BIDIR PORT
    ELK21_DAT_N : inout std_logic;

    ELK22_DAT_P : inout std_logic;      -- SERIAL LVDS ELINK19 DATA BIDIR PORT
    ELK22_DAT_N : inout std_logic;

    ELK23_DAT_P : inout std_logic;      -- SERIAL LVDS ELINK19 DATA BIDIR PORT
    ELK23_DAT_N : inout std_logic

    );

end TOP_COMET;

architecture RTL of TOP_COMET is

-- NOTE:  THE AP3E 208QFP HAS A MAXIMUM OF 6 GLOBAL BUFFERS.  EACH QUADRANT HAS 3 ADDITIONAL GLOBAL QUADRANT BUFFERS.
  attribute syn_global_buffers        : integer;
  attribute syn_global_buffers of RTL : architecture is 7;
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- DEFINE THE COMPONENTS:
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

----------------------------------------------------------------        
-- LVDS INPUT BUFFER
  component LVDS_CLK_IN
    port(
      PADP : in  std_logic;
      PADN : in  std_logic;
      Y    : out std_logic
      );
  end component;

-- LVDS OUTPUT BUFFER
  component LVDS_BUFOUT

    port(
      Data : in  std_logic;
      PADP : out std_logic;
      PADN : out std_logic
      );
  end component;
----------------------------------------------------------------
-- SPECIAL BIDIRECTIONAL LVDS DUAL CLOCK DDR BLOCK (IE RX AND TX CLOCKS ARE SEPARATE)
  component DDR_BIDIR_LVDS_DUAL_CLK is
    port(
      DDR_CLR    : in    std_logic;
      DDR_DIR    : in    std_logic;
      DDR_TX_CLK : in    std_logic;
      DDR_TX_R   : in    std_logic;
      DDR_TX_F   : in    std_logic;
      DDR_RX_CLK : in    std_logic;
      DDR_RX_R   : out   std_logic;
      DDR_RX_F   : out   std_logic;
      PADP       : inout std_logic;
      PADN       : inout std_logic
      );
  end component;
----------------------------------------------------------------

  component BIDIR_LVDS_IO
    port(Data  : in    std_logic;  -- DATA INPUT FOR THE BUFFER THAT DRIVES THE PADS
         Y     : out   std_logic;  -- TRANSPARENT BUFFER CONNECTED TO THE PADS DRVING INTO THE FPGA
         Trien : in    std_logic;  -- TRI-STATE CONTROL ('0' = DRIVER ENABLED)
         PADP  : inout std_logic := 'Z';
         PADN  : inout std_logic := 'Z'
         );
  end component;

----------------------------------------------------------------
-- SIMPLE LVTTL TRI-STATE BUFFER WITH ACTIVE HIGH ENABLE, 24 MA DRIVE, HIGH SLEW, WEAK PULLUP (~30K)
  component tristate_buf
    port(Data  : in  std_logic;
         Trien : in  std_logic;
         PAD   : out std_logic
         );
  end component;

----------------------------------------------------------------
-- EXECUTIVE POWER UP CONFIGURATOR--DETERMINES DCB OR SALT CONFIG AT INITIAL POWER ON
  component EXEC_MODE_CNTL is
    port(
      CCC_160M_FXD    : in std_logic;   -- FIXED 160 MHZ CLOCK SOURCE
      DEV_RST_B       : in std_logic;  -- ACTIVE LOW RESET --DEDICATED COMET BOARD RC TIME CONSTANT
      DCB_SALT_SEL    : in std_logic;  -- '1'= DCB MODE (IE TFC MASTER TX ENABLED) // '0'=SALT HYBRID MODE (IE TFC MASTER RX W/ SYNC MODE ENABLED)
      CCC_1_LOCK_STAT : in std_logic;  -- LOCK STATUS FROM THE CCC_160M_40M_60M MODULE

      CLK_40MHZ_GEN : in  std_logic;  -- CLOCK SYNCHRONOUS TO THE 160MHZ CCC CLOCK FROM THE SERIALIZER
      CLK60MHZ      : in  std_logic;  -- CLOCK FROM THE USM MODULE DERIVED FROM A 12MHZ CRYSTAL ON-BOARD THE USB MODULE PLL
                                      -- THIS CLOCK IS NOT ACTIVE AT POWER ON.  REQUIRES USB HOST ACTION TO ENABLE THE OUTPUT.
      USB_RESET_B   : out std_logic;  -- ACTIVE LOW RESET DEDICATED FOR THE USB VHDL STATE MACHINE--SYCHRONOUS RELEASE RELATIVE TO THE 60 MHZ CLOCK

      MASTER_DCB_POR_B  : out std_logic;  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR DCB CONFIGS
      MASTER_SALT_POR_B : out std_logic;  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR SALT CONFIGS
      MASTER_POR_B      : out std_logic   -- SYNCHRONOUS MASTER POR
      );
  end component;

----------------------------------------------------------------
-- GENERATES A 40 MHZ CLOCK BY DIVIDING THE 200 MHZ BY 5.  DUTY CYCLE IS 40/60.
  component REF_CLK_DIV_GEN is
    port (
      CLK_200MHZ      : in  std_logic;  -- 200 MHZ OSCILLATOR SOURCE
      POR_N           : in  std_logic;  -- ACTIVE LOW POWER-ON RESET
      CLK40M_10NS_REF : out std_logic  -- 40 MHZ WITH 40/60 DUTY CYCLE (IE 0 NS PW) DERIVED FROM 200 MHZ
      );
  end component;
----------------------------------------------------------------
-- CCC THAT GENERATES FIXED 40 and 160 MHZ CLOCKS AS WELL AS BUFFERS THE 60 MHZ FROM THE USB MODULE.  THE 60 MHZ IS SOURCED BY THE USB MODULE AND IS FULLY ASYCHRONOUS TO THE OTHER CLOCKS
-- !!!!!!!! TIMING NOTES !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
--      THE REF CLOCK AND USB CLOCK SOURCES ARE EXT I/O CONNECTIONS.
--  THE USB 60 MHZ CLOCK ROUTED THRU THE CCC GLOBAL BUFFER NEEDS TO BE DELAYED BY 6.335 NS TO ESTABLISH A PROPER PIPELINE DELAY 
--  THE FIXED 40MHZ OUTPUT HAS 0 NS DELAY
--      THE FIXED 160MHZ OUTPUT HAS A 0.735 NS DELAY
--      THE DELAY OF THE TWO PLL OUTPUTS RELATIVE TO THE TUNABLE 160 MHZ CLOCKS IN CCC#2 ARE ADJUSTED VIA FEEDBACK DELAY SET TO 3.335NS.
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  component CLK_FXD_40_160_A60M is

    port(POWERDOWN : in  std_logic;
         CLKA      : in  std_logic;
         LOCK      : out std_logic;
         GLA       : out std_logic;
         GLB       : out std_logic;
         GLC       : out std_logic;
         SDIN      : in  std_logic;
         SCLK      : in  std_logic;
         SSHIFT    : in  std_logic;
         SUPDATE   : in  std_logic;
         MODE      : in  std_logic;
         SDOUT     : out std_logic;
         CLKC      : in  std_logic
         );
  end component;

----------------------------------------------------------------
-- MULTIPLEXOR FOR THE TX SERIAL DATA SOURCE
  component SYNC_DAT_SEL
    port (
      CLK40M_GEN : in std_logic;  -- 40 MHZ CLOCK WHERE RISE EDGE IS DELAYED 2.5 NS FROM THE FIXED 160 MHZ RISE EDGE
      RESET_B    : in std_logic;        -- ACTIVE LOW RESET    

      ALIGN_MODE_EN : in std_logic;  -- '1' ENABLES THE AUTO BIT AND BYTE ALIGNMENT FUNCTION. PULSED INPUT MUST BE LOW BEFORE ALIGNMENT COMPLETE
      ALIGN_PATT    : in std_logic_vector(7 downto 0);  -- PATTERN USED TO DETERMINE ALIGNMENT (EG A5 HEX)

      SER_DAT_IN : in std_logic_vector(7 downto 0);  -- SERIAL DATA BYTE

      P_SERDAT : out std_logic_vector(7 downto 0)  -- SERIAL DATA BYTE FOR TX
      );
  end component;

----------------------------------------------------------------
-- BASIC 8-BIT PARALLEL-TO-SERIAL TX 
  component SER320M
    port (
      DDR_160M_CLK : in std_logic;      -- FIXED 160 MHZ DDR CLOCK
      CLK40M_GEN   : in std_logic;  -- 40 MHZ CLOCK DERIVED FROM PLL CLOCK DELAYED BY ~2.5NS FROM THE RISING EDGE OF THE FIXED DDR_160M_CLK

      RESET_B           : in std_logic;  -- ACTIVE LOW RESET    
      NEXT_SER_CMD_WORD : in std_logic_vector(7 downto 0);  -- 8 BIT COMMAND INPUT WORD    
      SERIAL_TX_EN      : in std_logic;  -- ENABLE FOR THE SERIAL TX

      SER_OUT_R : out std_logic;  -- SERIALIZED COMMAND 160MHZ RISE CLOCK DATA-- 12 COPIES
      SER_OUT_F : out std_logic  -- SERIALIZED COMMAND 160MHZ FALL CLOCK DATA-- 12 COPIES
      );
  end component;

----------------------------------------------------------------
-- MASTER 8-BIT SERIAL-TO-PARALLEL RX.  
  component TOP_MASTER_DES320M is
    port (
      CLK_40M_GL   : in std_logic;      -- ON-BOARD CCC1 40 MHZ CLOCK
      CCC_160M_FXD : in std_logic;      -- FIXED PHASE 160 MHZ DDR CLOCK

      CLK_40M_BUF_RECD : in std_logic;  -- 40 MHZ REF CLOCK DISTRIBUTED BY THE 'MASTER FPGA' ON THE MASTER DCB CONFIGURED COMET
      MASTER_POR_B     : in std_logic;  -- MASTER POWER-ON-RESET: SYNCHRONOUS RESET WAITS FOR CCC1 TO BE LOCKED AND STABLE

      DCB_SALT_SEL  : in std_logic;     -- '1'=DCB, '0'=SALT
      ALIGN_MODE_EN : in std_logic;     -- '1'= AUTO ALIGN ENABLED
      SIM_MODE      : in std_logic;  -- GPIO_1:  '1' = SIM MODE, '0' = REAL TIME OP MODE

      MAN_BIT_OS     : in std_logic_vector(3 downto 0);  -- MANUAL BIT OFFSET ADJUSTMENT (THESE 3 MANUAL MODE INPUTS CAN BE HARD-WIRED INACTIVE AT NEXT LEVEL)
      MAN_PHASE_ADJ  : in std_logic_vector(4 downto 0);  -- MANUAL PHASE ADJUSTMENT 
      MAN_AUTO_ALIGN : in std_logic;  -- '1'=MANUAL , '0'= AUTO PHASE ADJ MODE

      ELINK0_DDR_R : in std_logic;      -- ELINK0 DDR RISE SERIAL DATA
      ELINK0_DDR_F : in std_logic;      -- ELINK0 DDR FALL SERIAL DATA
      TFC_DDR_R    : in std_logic;      -- TFC DDR RISE SERIAL DATA
      TFC_DDR_F    : in std_logic;      -- TFC DDR FALL SERIAL DATA

      CH0_RAM_BPORT  : out std_logic_vector(7 downto 0);  -- SERIAL DATA GETS ROUTED TO THE RAM CH0 STORAGE ALLOCATED FOR TFC WHEN FPGA CONSIGD AS SALT
      CH1_RAM_BPORT  : out std_logic_vector(7 downto 0);  -- SERIAL DATA GETS ROUTED TO THE RAM CH1 STORAGE ALLOCATED FOR ELINK0
      P_BIT_OS_SEL   : out std_logic_vector(2 downto 0);  -- BIT ALIGNMENT OFFSET VALUE DETERMINED BY MASTER DES320M AND USE DY ALL SLAVES
      P_ALIGN_ACTIVE : out std_logic;  -- '1' INDICATES THE AUTO ALIGN FUNCTION IS ACTIVE

      P_CCC_RX_CLK_LOCK : out std_logic;  -- CCC2 LOCK STATUS
      P_CCC_160M_ADJ    : out std_logic;  -- CCC2 PHASE ADJUSTABLE 160 MHZ CLOCK--BASELINE PHASE
      P_CCC_160M_1ADJ   : out std_logic;  -- CCC2 PHASE ADJUSTABLE 160 MHZ CLOCK--ADD'L PHASE OFFSET 1 
      P_CCC_160M_2ADJ   : out std_logic  -- CCC2 PHASE ADJUSTABLE 160 MHZ CLOCK--ADD'L PHASE OFFSET 2
      );
  end component;

----------------------------------------------------------------
-- GENERAL PURPOSE PATTERN GENERATOR
  component GP_PATT_GEN
    port (
      CLK_40MHZ_GEN : in std_logic;  -- CLOCK SYNCHRONOUS BUT DELAYED BY !2.5NS FROM THE FIXED 160MHZ CCC CLOCK FROM THE SERIALIZER
      RESET_B       : in std_logic;     -- ACTIVE LOW RESET    
      USB_MASTER_EN : in std_logic;  -- '1' SIGNIFIES THAT THE USB MODULE IS NOW ACTIVE

      STRT_ADDR   : in std_logic_vector(7 downto 0);  -- START ADDRESS FOR A PATTERN GENERATOR
      STOP_ADDR   : in std_logic_vector(7 downto 0);  -- STOP ADDRESS FOR A PATTERN GENERATOR
      ACT_BLK_SEL : in std_logic;  -- ACTIVE RAM BLOCK SELECT (IE ADDR BIT 8 FOR 512 BYTE RAM CONTROLLED IN THE USB MODULE)
      DIR_MODE    : in std_logic;       -- '1'= TX MODE, '0'= RX MODE

      ALIGN_PATT  : in std_logic_vector(7 downto 0);  -- ALIGNMENT PATTERN
      RX_SER_WORD : in std_logic_vector(7 downto 0);  -- RECEIVED SERIAL BYTE STREAM

      GP_PATT_GEN_EN : in std_logic;    -- PATERN GENERATOR ENABLE
      REPEAT_EN      : in std_logic;  -- '1' CAUSES PATTERN GENERATOR TO AUTO REPEAT CONTINUOUSLY WHEN THE PATTERN GENERATOR IS ENABLED
      ALIGN_ACTIVE   : in std_logic;  -- '1' INDICATES THAT THE ALIGN MODE IS ACTIVE

      RAM_ADDR : out std_logic_vector(8 downto 0);  -- START ADDRESS FOR A PATTERN GENERATOR (USES B PORT SIDE OF DUAL PORT RAM BLOCKS)
      RAM_BLKB : out std_logic;         -- PORT B RAM BLOCK ENABLE
      RAM_RWB  : out std_logic          -- PORT B RAM READ/WRITE CONTROL
      );
  end component;

----------------------------------------------------------------
-- SLAVE ELINK MODULE
  component ELINK_SLAVE
    port (
      CLK_40M_GL   : in std_logic;      -- CCC#1 FIXED 40MHZ CLOCK OUT
      CCC_160M_FXD : in std_logic;      -- CCC#1 FIXED 160MHZ CLOCK
      CCC_160M_ADJ : in std_logic;      -- CCC#2 ADJ 160MHZ CLOCK

      DEV_RST_B         : in std_logic;  -- ACTIVE LOW ASYNC RESET --DEDICATED COMET BOARD RC TIME CONSTANT
      MASTER_POR_B      : in std_logic;  -- MASTER_POR_B
      MASTER_DCB_POR_B  : in std_logic;  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR DCB CONFIGS
      MASTER_SALT_POR_B : in std_logic;  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR SALT CONFIGS

      DCB_SALT_SEL : in std_logic;  -- '1'= DCB MODE (IE TFC MASTER TX ENABLED) // '0'=SALT HYBRID MODE (IE TFC MASTER RX W/ SYNC MODE ENABLED)

      OP_MODE1_SPE : in std_logic;      -- OP_MODE BIT 1 = SYNC PATT EN
      F_ALIGN_PATT : in std_logic_vector(7 downto 0);  -- FIXED SYNC / ALIGNMENT PATTERN BYTE
      PATT_ELK_DAT : in std_logic_vector(7 downto 0);  -- ELINK PATTERN TX DATA

      BIT_OS_SEL : in std_logic_vector(2 downto 0);  -- BIT ALIGNMENT OFFSET VALUE DETERMINED BY MASTER DES320M AND USE DY ALL SLAVES

      ELK_DAT_P : inout std_logic;      -- SERIAL LVDS ELINK0 DATA BIDIR PORT
      ELK_DAT_N : inout std_logic;      --  ""

      ELK_RX_SER_WORD : out std_logic_vector(7 downto 0)  -- OUTPUT WORD OF THE ELINK DE-SERIALIZER

      );
  end component;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- SLAVE ELINK MODULE+++++++INVERTED SERIAL DATA PATH PER NOTE AT BEGINNING OF THIS FILE+++++++
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  component ELINK_SLAVE_INV
    port (
      CLK_40M_GL   : in std_logic;      -- CCC#1 FIXED 40MHZ CLOCK OUT
      CCC_160M_FXD : in std_logic;      -- CCC#1 FIXED 160MHZ CLOCK
      CCC_160M_ADJ : in std_logic;      -- CCC#2 ADJ 160MHZ CLOCK

      DEV_RST_B         : in std_logic;  -- ACTIVE LOW ASYNC RESET --DEDICATED COMET BOARD RC TIME CONSTANT
      MASTER_POR_B      : in std_logic;  -- MASTER_POR_B
      MASTER_DCB_POR_B  : in std_logic;  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR DCB CONFIGS
      MASTER_SALT_POR_B : in std_logic;  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR SALT CONFIGS

      DCB_SALT_SEL : in std_logic;  -- '1'= DCB MODE (IE TFC MASTER TX ENABLED) // '0'=SALT HYBRID MODE (IE TFC MASTER RX W/ SYNC MODE ENABLED)

      OP_MODE1_SPE : in std_logic;      -- OP_MODE BIT 1 = SYNC PATT EN
      F_ALIGN_PATT : in std_logic_vector(7 downto 0);  -- FIXED SYNC / ALIGNMENT PATTERN BYTE
      PATT_ELK_DAT : in std_logic_vector(7 downto 0);  -- ELINK PATTERN TX DATA

      BIT_OS_SEL : in std_logic_vector(2 downto 0);  -- BIT ALIGNMENT OFFSET VALUE DETERMINED BY MASTER DES320M AND USE DY ALL SLAVES

      ELK_DAT_P : inout std_logic;      -- SERIAL LVDS ELINK0 DATA BIDIR PORT
      ELK_DAT_N : inout std_logic;      --  ""

      ELK_RX_SER_WORD : out std_logic_vector(7 downto 0)  -- OUTPUT WORD OF THE ELINK DE-SERIALIZER

      );
  end component;
----------------------------------------------------------------
-- USB INTERFACE
-- CONTAINS USB INTERFACE LOGIC, CONTROL REGISTERS, STATUS REGISTERS, ONE TFC PATTERN REGISTER BANK, AND UP TO 20 ELINK PATTERN REGISTER BANKS
  component USB_INTERFACE
    port(
      CLK60MHZ      : in std_logic;  -- CLOCK FROM THE USM MODULE DERIVED FROM A 12MHZ CRYSTAL ON-BOARD THE USB MODULE PLL
      RESETB        : in std_logic;     -- ACTIVE LOW RESET
      MASTER_POR_B  : in std_logic;  -- RESET SYNCHRONOUS TO THE 160 MHZ AND 40 MHZ CLOCKS
      CLK_40MHZ_GEN : in std_logic;  -- CLOCK SYNCHRONOUS TO THE 160MHZ CCC CLOCK FROM THE SERIALIZER            

      -- USB INTERFACE SIGNALS (SYNCHRONOUS TO CLK60MHZ)
      BIDIR_USB_ADBUS : inout std_logic_vector(7 downto 0);  -- USB:  BI-DIRECTIONAL ADDRESS AND DATA BUS
      USB_OE_B        : out   std_logic;  -- USB:  ACTIVE LOW TURNS ON THE USB DATA BUS OUTPUT MODE

      P_USB_RXF_B : in  std_logic;  -- USB:  ACTIVE LOW SIGNIFIES THAT THE ON-BOARD USB FIFO HAS DATA TO BE READ (IE READ TRANSFER REQUEST)
      USB_RD_B    : out std_logic;  -- USB:  ACTIVE LOW STATE FETCHES NEXT BYTE FROM THE FIFO ON THE NEXT CLK60MHZ CLOCK EDGE

      P_USB_TXE_B : in  std_logic;  -- USB:  ACTIVE LOW SIGNIFIES THAT THE ON-BOARD USB FIFO CAN NOW ACCEPT DATA (IE WRITE TRANSFER ENABLED)
      USB_WR_B    : out std_logic;  -- USB:  ACTIVE LOW STATE ENABLE DATA TO BE WRITTEN TO THE FIFO ON THE NEXT CLK60MHZ CLOCK EDGE

      USB_SIWU_B      : out std_logic;  -- USB:  ACTIVE LOW--Send Immediate / WakeUp signal (CAN BE USED TO OPTIMIZE DATA TRANSFER RATES)
                                        -- TIE HIGH IF NOT USED
      -- EXTERNAL PATTERN GEN INTERFACES (SYNCHRONOUS TO CLK_40MHZ_GEN)
      P_TFC_STRT_ADDR : out std_logic_vector(7 downto 0);  -- START ADDRESS FOR THE TFC PATTERN GENERATOR
      P_TFC_STOP_ADDR : out std_logic_vector(7 downto 0);  -- STOP ADDRESS FOR THE TFC PATTERN GENERATOR
      TFC_ADDRB       : in  std_logic_vector(8 downto 0);  -- TFC RAM BLOCK PORT B ADDRESS
      TFC_RAM_BLKB_EN : in  std_logic;  -- TFC RAM BLOCK PORT B ACTIVE LOW RAM BLOCK ENABLE
      P_TFC_ADDR8B    : out std_logic;  -- 8TH ADDR BIT FOR THE TFC PATT B PORT INDICATES WHICH 1/2 THE PATT GEN IS USING
      TFC_DAT_OUT     : out std_logic_vector(7 downto 0);  -- TFC RAM BLOCK PORT B DATA OUT
      TFC_DAT_IN      : in  std_logic_vector(7 downto 0);  -- TFC RAM BLOCK PORT B DATA IN
      TFC_RWB         : in  std_logic;  -- TFC RAM BLOCK PORT B READ WRITE CONTROL

      P_ELINKS_STRT_ADDR : out std_logic_vector(7 downto 0);  -- START ADDRESS FOR THE ELINKS PATTERN GENERATOR
      P_ELINKS_STOP_ADDR : out std_logic_vector(7 downto 0);  -- STOP ADDRESS FOR THE ELINKS PATTERN GENERATOR
      ELINK_ADDRB        : in  std_logic_vector(8 downto 0);  -- COMMON ELINKS RAM BLOCK PORT B ADDRESS
      ELINK_PATT_GEN_EN  : in  std_logic;  -- COMMON ELINKS RAM BLOCK PORT B ACTIVE LOW RAM BLOCK ENABLE
      P_ELINK_ADDR8B     : out std_logic;  -- 8TH ADDR BIT FOR THE ELINK 0 PORT B INDICATES WHICH 1/2 THE PATT GEN IS USING
      ELINK_RWB          : in  std_logic;  -- COMMON ELINKS RAM BLOCK PORT B READ WRITE CONTROL

      ELINK0_DAT_OUT : out std_logic_vector(7 downto 0);  -- ELINK0 RAM BLOCK PORT B DATA OUT
      ELINK0_DAT_IN  : in  std_logic_vector(7 downto 0);  -- ELINK0 RAM BLOCK PORT B DATA IN

      ELINK1_DAT_OUT : out std_logic_vector(7 downto 0);  -- ELINK1 RAM BLOCK PORT B DATA OUT
      ELINK1_DAT_IN  : in  std_logic_vector(7 downto 0);  -- ELINK1 RAM BLOCK PORT B DATA IN

      ELINK2_DAT_OUT : out std_logic_vector(7 downto 0);  -- ELINK2 RAM BLOCK PORT B DATA OUT
      ELINK2_DAT_IN  : in  std_logic_vector(7 downto 0);  -- ELINK2 RAM BLOCK PORT B DATA IN

      ELINK3_DAT_OUT : out std_logic_vector(7 downto 0);  -- ELINK3 RAM BLOCK PORT B DATA OUT
      ELINK3_DAT_IN  : in  std_logic_vector(7 downto 0);  -- ELINK3 RAM BLOCK PORT B DATA IN

      ELINK4_DAT_OUT : out std_logic_vector(7 downto 0);  -- ELINK4 RAM BLOCK PORT B DATA OUT
      ELINK4_DAT_IN  : in  std_logic_vector(7 downto 0);  -- ELINK4 RAM BLOCK PORT B DATA IN

      ELINK5_DAT_OUT : out std_logic_vector(7 downto 0);  -- ELINK5 RAM BLOCK PORT B DATA OUT
      ELINK5_DAT_IN  : in  std_logic_vector(7 downto 0);  -- ELINK5 RAM BLOCK PORT B DATA IN

      ELINK6_DAT_OUT : out std_logic_vector(7 downto 0);  -- ELINK6 RAM BLOCK PORT B DATA OUT
      ELINK6_DAT_IN  : in  std_logic_vector(7 downto 0);  -- ELINK6 RAM BLOCK PORT B DATA IN

      ELINK7_DAT_OUT : out std_logic_vector(7 downto 0);  -- ELINK7 RAM BLOCK PORT B DATA OUT
      ELINK7_DAT_IN  : in  std_logic_vector(7 downto 0);  -- ELINK7 RAM BLOCK PORT B DATA IN

      ELINK8_DAT_OUT : out std_logic_vector(7 downto 0);  -- ELINK8 RAM BLOCK PORT B DATA OUT
      ELINK8_DAT_IN  : in  std_logic_vector(7 downto 0);  -- ELINK8 RAM BLOCK PORT B DATA IN

      ELINK9_DAT_OUT : out std_logic_vector(7 downto 0);  -- ELINK9 RAM BLOCK PORT B DATA OUT
      ELINK9_DAT_IN  : in  std_logic_vector(7 downto 0);  -- ELINK9 RAM BLOCK PORT B DATA IN

      ELINK10_DAT_OUT : out std_logic_vector(7 downto 0);  -- ELINK10 RAM BLOCK PORT B DATA OUT
      ELINK10_DAT_IN  : in  std_logic_vector(7 downto 0);  -- ELINK10 RAM BLOCK PORT B DATA IN

      ELINK11_DAT_OUT : out std_logic_vector(7 downto 0);  -- ELINK11 RAM BLOCK PORT B DATA OUT
      ELINK11_DAT_IN  : in  std_logic_vector(7 downto 0);  -- ELINK11 RAM BLOCK PORT B DATA IN

      ELINK12_DAT_OUT : out std_logic_vector(7 downto 0);  -- ELINK12 RAM BLOCK PORT B DATA OUT
      ELINK12_DAT_IN  : in  std_logic_vector(7 downto 0);  -- ELINK12 RAM BLOCK PORT B DATA IN

      ELINK13_DAT_OUT : out std_logic_vector(7 downto 0);  -- ELINK13 RAM BLOCK PORT B DATA OUT
      ELINK13_DAT_IN  : in  std_logic_vector(7 downto 0);  -- ELINK13 RAM BLOCK PORT B DATA IN

      ELINK14_DAT_OUT : out std_logic_vector(7 downto 0);  -- ELINK14 RAM BLOCK PORT B DATA OUT
      ELINK14_DAT_IN  : in  std_logic_vector(7 downto 0);  -- ELINK14 RAM BLOCK PORT B DATA IN

      ELINK15_DAT_OUT : out std_logic_vector(7 downto 0);  -- ELINK15 RAM BLOCK PORT B DATA OUT
      ELINK15_DAT_IN  : in  std_logic_vector(7 downto 0);  -- ELINK15 RAM BLOCK PORT B DATA IN

      ELINK16_DAT_OUT : out std_logic_vector(7 downto 0);  -- ELINK16 RAM BLOCK PORT B DATA OUT
      ELINK16_DAT_IN  : in  std_logic_vector(7 downto 0);  -- ELINK16 RAM BLOCK PORT B DATA IN

      ELINK17_DAT_OUT : out std_logic_vector(7 downto 0);  -- ELINK17 RAM BLOCK PORT B DATA OUT
      ELINK17_DAT_IN  : in  std_logic_vector(7 downto 0);  -- ELINK17 RAM BLOCK PORT B DATA IN

      ELINK18_DAT_OUT : out std_logic_vector(7 downto 0);  -- ELINK18 RAM BLOCK PORT B DATA OUT
      ELINK18_DAT_IN  : in  std_logic_vector(7 downto 0);  -- ELINK18 RAM BLOCK PORT B DATA IN

      ELINK19_DAT_OUT : out std_logic_vector(7 downto 0);  -- ELINK19 RAM BLOCK PORT B DATA OUT
      ELINK19_DAT_IN  : in  std_logic_vector(7 downto 0);  -- ELINK19 RAM BLOCK PORT B DATA IN

      P_OP_MODE : out std_logic_vector(7 downto 0)  -- PATTERN GENERATOR OPERATING MODE

      );
  end component;


--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- DEFINE INTERNAL SIGNALS
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  signal RAW_CLK_200M : std_logic;  -- DIRECT FROM LVDS RECV BUFF: OSC REF CLOCK

-- SIGNALS ASSOCIATED WITH THE MAIN CCC
  signal CLK_40M_BUF_RECD : std_logic;  -- BIDIR_LVDS_BUF_RX SIGNAL 'Y': DIV-BY-5 OF 200 MHZ OSC REF CLOCK
  signal CCC_160M_FXD     : std_logic;  -- CCC1 GENERATED FIXED 160 MHZ
  signal CCC_MAIN_LOCK    : std_logic;  -- LOCK FOR THE MAIN CCC THAT GENERATES THE 160 MHZ AND 40 MHZ CLOCKS
  signal CLK40M_10NS_REF  : std_logic;  -- REF 40 MHZ DERIVED BY DIV-BY-5 OF 200 MHZ (USED AS CCC1 REF CLOCK SOURCE)
  signal CLK_40M_GL       : std_logic;  -- 40 MHZ CLOCK---GLOBAL USED AS REF TO CCC#2
  signal CLK60MHZ         : std_logic;  -- CCC 60 MHZ DERIVED FROM THE USB 60 MHZ, BUT WITH A FIXED 'LEADING PHASE'.

  attribute syn_keep of CLK_40M_GL    : signal is true;
  attribute alspreserve of CLK_40M_GL : signal is true;

  attribute syn_keep of CCC_160M_FXD    : signal is true;
  attribute alspreserve of CCC_160M_FXD : signal is true;

  attribute syn_keep of CLK60MHZ    : signal is true;
  attribute alspreserve of CLK60MHZ : signal is true;


-- SIGNALS ASSOCIATED WITH THE AUX CCC 
  signal CCC_160M_ADJ    : std_logic;  -- PHASE ADJ 160 MHZ CLOCK FOR THE SERDES.
  signal CCC_RX_CLK_LOCK : std_logic;   -- CCC#2 LOCK STATUS


-- ELINK BLOCK RAMS WITH 'A' AND 'B' PORTS
  type ELINK_BUS_SIGS is array (19 downto 0) of std_logic_vector (8 downto 0);
  type ELINK_SIGNALS is array (19 downto 0) of std_logic;
  type ELINK_BYTES is array (23 downto 0) of std_logic_vector (7 downto 0);

-- DATA FLOW SIGNALS
  signal TFC_OUT_R              : std_logic;  -- TFC LVDS OUTPUT --RISE EDGE
  signal TFC_OUT_F              : std_logic;  -- TFC LVDS OUTPUT --FALL EDGE
  signal TFC_IN_DDR_R, TFC_IN_R : std_logic;  -- TFC INPUT BIT -- RISE EDGE (DDR VERSION IS STRAIGHT FROM DDR REG, OTHER IS DELAYED BY 1 FF )
  signal TFC_IN_DDR_F, TFC_IN_F : std_logic;  -- TFC INPUT BIT -- FALL EDGE (DDR VERSION IS STRAIGHT FROM DDR REG, OTHER IS DELAYED BY 1 FF )

  signal ELK0_OUT_R               : std_logic;  -- ELINK0 LVDS OUTPUTS --RISE EDGE
  signal ELK0_OUT_F               : std_logic;  -- ELINK0 LVDS OUTPUTS --FALL EDGE
  signal ELK0_IN_DDR_R, ELK0_IN_R : std_logic;  -- ELINK0 INPUT BITS -- RISE EDGE (DDR VERSION IS STRAIGHT FROM DDR REG, OTHER IS DELAYED BY 1 FF )
  signal ELK0_IN_DDR_F, ELK0_IN_F : std_logic;  -- ELINK0 INPUT BITS -- FALL EDGE (DDR VERSION IS STRAIGHT FROM DDR REG, OTHER IS DELAYED BY 1 FF )

  signal USB_RD_BI   : std_logic;       -- INTERNAL VERSION OF USB_RD_B
  signal USB_WR_BI   : std_logic;       -- INTERNAL VERSION OF USB_WR_B
  signal USB_OE_BI   : std_logic;       -- INTERNAL VERSION OF USB_OE_B
  signal USB_SIWU_BI : std_logic;       -- INTERNAL VERSION OF USB_SIWU_B

  signal USB_MASTER_EN : std_logic;  -- USED TO ENABLE THE VHDL MODULE AFTER THE PHY USB MODULE IS GENERATING A STABLE 60 MHZ CLOCK

-- PATTERN GENERATOR RELATED SIGNALS
  signal ALIGN_ACTIVE : std_logic;  -- '1' INDICATES THAT THE ALIGN MODE IS ACTIVE

  signal TFC_STRT_ADDR   : std_logic_vector(7 downto 0);  -- START ADDRESS FOR THE TFC PATTERN GENERATOR
  signal TFC_STOP_ADDR   : std_logic_vector(7 downto 0);  -- STOP ADDRESS FOR THE TFC PATTERN GENERATOR
  signal TFC_ADDRB       : std_logic_vector(8 downto 0);  -- TFC RAM BANK, B PORT ADDRESS FROM THE PATTERN GEN
  signal PATT_TFC_DAT    : std_logic_vector(7 downto 0);  -- TFC RAM BLOCK PORT B DATA OUT
  signal TFC_RX_SER_WORD : std_logic_vector(7 downto 0);  -- OUTPUT WORD OF THE TFC DE-SERIALIZER
  signal TFC_TX_DAT      : std_logic_vector(7 downto 0);  -- CONNECTION BETWEEN TFC SOURCE DATA MUX AND THE TFS TX SERIALIZER
  signal TFC_ACT_BLK_SEL : std_logic;   -- ACTIVE RAM BLOCK SELECT
  signal TFC_RAM_BLKB_EN : std_logic;   -- TFC RAM BLOCK B PORT ENABLE
  signal TFC_RWB         : std_logic;   -- TFC RAM BLOCK B PORT R/W CONTROL
  signal OP_MODE         : std_logic_vector(7 downto 0);  -- DEFINES THE OPERATING MODE FOR ALL PATTERN GENERATORS

  signal ELKS_STRT_ADDR   : std_logic_vector(7 downto 0);  -- COMMON START ADDRESS FOR THE ELINKS PATTERN GENERATOR
  signal ELKS_STOP_ADDR   : std_logic_vector(7 downto 0);  -- COMMON STOP ADDRESS FOR THE ELINKS PATTERN GENERATOR
  signal ELKS_ADDRB       : std_logic_vector(8 downto 0);  -- ELINKS RAM BANK, B PORT ADDRESS FROM THE PATTERN GEN
  signal ELKS_ACT_BLK_SEL : std_logic;  -- ACTIVE RAM BLOCK SELECT
  signal ELKS_RAM_BLKB_EN : std_logic;  -- ELINKS RAM BLOCK B PORT ENABLE
  signal ELKS_RWB         : std_logic;  -- ELINK 0 RAM BLOCK B PORT R/W CONTROL

--+++++++
  signal PATT_ELK_DAT : ELINK_BYTES;    -- ELINK PATTERN TX DATA (X20 BYTES)

  signal ELK_RX_SER_WORD : ELINK_BYTES;  -- OUTPUT WORDS OF THE ELINK DE-SERIALIZERS (X20 BYTES)
  signal ELK0_TX_DAT     : std_logic_vector(7 downto 0);  -- CONNECTION BETWEEN ELINK0 SOURCE DATA MUX AND THE ELINKS TX SERIALIZER
--+++++++

  signal BIT_OS_SEL  : std_logic_vector(2 downto 0);  -- BIT ALIGNMENT OFFSET VALUE DETERMINED BY MASTER DES320M AND USE DY ALL SLAVES
  signal DDR_Q0_RISE : std_logic;  -- TEST PORT VALUE OF THE REC'D DDR BIT STREAM (RISE)
  signal DDR_Q1_FALL : std_logic;  -- TEST PORT VALUE OF THE REC'D DDR BIT STREAM (FALL)

-- THESE SIGNALS ARE USED FOR INITIAL CONFIG AND POWER ON RESET
  signal MASTER_POR_B      : std_logic;  -- MASTER POR (INTERNAL COPY)
  signal MASTER_DCB_POR_B  : std_logic;  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR DCB CONFIGS
  signal MASTER_SALT_POR_B : std_logic;  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR SALT CONFIGS

-- SYNC DETECTION STATUS SIGNALS:  ='1' WHEN DATA CONNECTED TO RAM BLOCK INPUT IS 8E HEX
  signal ELK0_SYNC_DET : std_logic;
  signal TFC_SYNC_DET  : std_logic;

  constant F_ALIGN_PATT : std_logic_vector(7 downto 0) := "10001110";  -- 8E HEX FIXED SYNC / ALIGNMENT PATTERN BYTE
  constant TFC_1_CMD    : std_logic_vector(7 downto 0) := "01010001";  -- FOR TEST USAGE
  constant TFC_2_CMD    : std_logic_vector(7 downto 0) := "01010010";  -- FOR TEST USAGE
  constant TFC_3_CMD    : std_logic_vector(7 downto 0) := "01010011";  -- FOR TEST USAGE
  constant TFC_4_CMD    : std_logic_vector(7 downto 0) := "01010100";  -- FOR TEST USAGE
  constant TFC_5_CMD    : std_logic_vector(7 downto 0) := "01010101";  -- FOR TEST USAGE
  constant TFC_6_CMD    : std_logic_vector(7 downto 0) := "01010110";  -- FOR TEST USAGE
  constant TFC_7_CMD    : std_logic_vector(7 downto 0) := "01010111";  -- FOR TEST USAGE
  constant TFC_8_CMD    : std_logic_vector(7 downto 0) := "01011000";  -- FOR TEST USAGE
  constant TFC_9_CMD    : std_logic_vector(7 downto 0) := "01011001";  -- FOR TEST USAGE
  constant TFC_10_CMD   : std_logic_vector(7 downto 0) := "01011010";  -- FOR TEST USAGE
  constant TFC_11_CMD   : std_logic_vector(7 downto 0) := "01011011";  -- FOR TEST USAGE
  constant TFC_12_CMD   : std_logic_vector(7 downto 0) := "01011100";  -- FOR TEST USAGE
  constant TFC_13_CMD   : std_logic_vector(7 downto 0) := "01011101";  -- FOR TEST USAGE
  constant TFC_14_CMD   : std_logic_vector(7 downto 0) := "01011110";  -- FOR TEST USAGE


  constant SIM_MODE : std_logic := '0';  -- '1' = SIM MODE, '0' = REAL TIME OP MODE

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
begin
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- CREATE A FEW PIPELINE DELAY REGISTERS FOR THE DDR RECEIVE SIGNALS ASSOCIATED WITH TFC AND ELINKS (GIVES P&R MORE LATITUDE TO CLOSE TIMING)
-- THESE PIPELINE REGISTERS ARE FOR THE MASTER DESERILIZER 
-- SIMILAR PIPELINE REGISTERS ARE LOCATED INSIDE THE SLAVE DESERILIZER MODULES
  REG : process(DEV_RST_B, CCC_160M_ADJ)
  begin
    if DEV_RST_B = '0' then
      TFC_IN_R <= '0';
      TFC_IN_F <= '0';

      ELK0_IN_R <= '0';
      ELK0_IN_F <= '0';

    elsif (CCC_160M_ADJ'event and CCC_160M_ADJ = '1') then
      TFC_IN_R <= TFC_IN_DDR_R;
      TFC_IN_F <= TFC_IN_DDR_F;

      ELK0_IN_R <= not(ELK0_IN_DDR_R);  -- ++++INVERTED PER NOTE A BEGINNING OF THIS FILE++++
      ELK0_IN_F <= not(ELK0_IN_DDR_F);  -- ++++INVERTED PER NOTE A BEGINNING OF THIS FILE++++


    end if;

  end process REG;
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- INSTANTIATE MODULES AND DEFINE CORRESPONDING SIGNAL PORT MAP CONNECTIONS

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- BOTH CCC'S REQUIRE A 40 MHZ REF CLOCK SOURCE.  THE SOURCE IS EITHER DERIVED FROM THE LOCAL ON-BOARD OSC OR RECEIVED FROM EXTERNAL LVDS DRIVER.
-- THE SOURCE IS SELECTED BY EXT_INT_REF_SEL.  THIS ALLOWS ONE COMET TO BE THE MASTER REFERENCE CLOCK SOURCE FOR ALL OTHER BOARDS IN THE SYSTEM.
-- NOTE--THE CCC SOURCE IS PERMANENTLY CONNECTED TO THE ALWAYS ACTIVE 'Y' READBACK PORT OF THE BI-DIR LVDS BUFFER.  
-- EXT_INT_REF_SEL DETERMINES IF THE BUFFER IS DRIVING OR RECEIVING.
-- +++++++++++++++++++++++++++++++++++++++++++++++
-- +++ CLOCK TREE CONNECTION NOTES:
--
--      EACH COMET FPGA DRIVES 2 CAT5 CONNS ON THE ASSOCIATED PASSIVE DAUGHTER BOARD,  1 CONN HAS THE BIDIR PORT WHILE THE OTHER HAS THE TX-ONLY PORT
--      THIS ALLOWS THE MASTER TX ONLY TO CONNECT TO THE DOWNSTREAM SLAVE BIDIR PORT.  THE REST OF THE SLAVES ARE THEN CONNECTED IN A SIMILAR DAISY CHAIN FASHION.
--  ONLY ONE FPGA SHOULD BE CONFIGURED AS MASTER TO ENSURE COMMON DETERMINISTIC REF CLOCK PHASES THRUOUT THE SYSTEM.
--  THEREFORE, THE BIDIR PORT OF THE MASTER FPGA SHOULD BE CONNECTED TO THE BIDIR 'SLAVE' CONFIGURED ADJACENT FPGA LOCATED ON THE SAME BOARD AS THE MASTER FPGA.
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- THIS IS THE LVDS INPUT FOR THE COMET 200 MHZ OSC 
  U0_200M_BUF : LVDS_CLK_IN
    port map (
      PADP => CLK200_P,
      PADN => CLK200_N,
      Y    => RAW_CLK_200M
      );

  U0_40M_BUF : LVDS_CLK_IN
    port map (
      PADP => BP_CLK40_P,
      PADN => BP_CLK40_N,
      Y    => CLK40M_10NS_REF
      );

-- LVDS CLOCK BI-DIR BUFFER OF THE COMET 40 MHZ CLOCK DERIVED FROM THE 200 MHZ OSC CLOCK TO BE USED AS A MAIN CCC REF CLOCK
-- EXT_INT_REF_SEL = '1' => DCB RX OF CLOCK (IE USE EXT REF CLK).  DCB_SALT_SEL = '0' => DCB TX REF CLOCKS (IE DRIVER OUT ENABLED).  
  U0A_40M_REFCLK : BIDIR_LVDS_IO
    port map (Data  => CLK40M_10NS_REF,  -- DATA INPUT FOR THE BUFFER THAT DRIVES THE PADS
              Y     => CLK_40M_BUF_RECD,  -- TRANSPARENT BUFFER CONNECTED TO THE PADS DRIVING INTO THE FPGA (IE SEES EITHER TX OR RX VERSION OF CLOCK)
              Trien => EXT_INT_REF_SEL,  -- TRI-STATE CONTROL ('0' = DRIVER ENABLED)
              PADP  => BIDIR_CLK40M_P,  -- PHYSICAL I/O PAD
              PADN  => BIDIR_CLK40M_N   -- PHYSCIAL I/O PAD
              );

-- LVDS DRIVER USED FOR DISTRIBUTION COPY OF CLK_40M_BUF_RECD (IE 10NS HIGH / 15NS LOW)
  U0B_TX40M_REFCLK : LVDS_BUFOUT
    port map (
      Data => CLK_40M_BUF_RECD,
      PADP => TX_CLK40M_P,
      PADN => TX_CLK40M_N
      );

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- THIS IS THE EXECUTIVE CCC CONFIG-AT-POWER-ON AND MASTER RESET MODULE
  U_EXEC_MASTER : EXEC_MODE_CNTL
    port map (
      CCC_160M_FXD    => CCC_160M_FXD,  -- FIXED 160 MHZ COMET CLOCK
      DEV_RST_B       => DEV_RST_B,     -- COMET BOARD POWER ON RESET
      DCB_SALT_SEL    => DCB_SALT_SEL,  -- DETERMINES INITIAL POWER ON CONDITIONS
      CCC_1_LOCK_STAT => CCC_MAIN_LOCK,

      CLK_40MHZ_GEN => CLK_40M_GL,  -- 40MHZ CLOCK SYNCHRONOUS TO THE 160MHZ CCC CLOCKS FROM THE SERDES CCC2
      CLK60MHZ      => CLK60MHZ,  -- CLOCK FROM THE USM MODULE DERIVED FROM A 12MHZ CRYSTAL ON-BOARD THE USB MODULE PLL
                                   -- THIS CLOCK IS NOT ACTIVE AT POWER ON.  REQUIRES USB HOST ACTION TO ENABLE THE OUTPUT.
      USB_RESET_B   => USB_MASTER_EN,  -- ACTIVE LOW RESET DEDICATED FOR THE USB VHDL STATE MACHINE--SYCHRONOUS RELEASE RELATIVE TO THE 60 MHZ CLOCK

      MASTER_DCB_POR_B  => MASTER_DCB_POR_B,  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR DCB CONFIGS
      MASTER_SALT_POR_B => MASTER_SALT_POR_B,  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR SALT CONFIGS
      MASTER_POR_B      => MASTER_POR_B
      );

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- GENERATES A 40 MHZ CLOCK BY DIVIDING THE 200 MHZ BY 5.  DUTY CYCLE IS 40/60.
  U_GEN_REF_CLK : REF_CLK_DIV_GEN
    port map (
      CLK_200MHZ      => RAW_CLK_200M,  -- 200 MHZ OSCILLATOR SOURCE
      POR_N           => DEV_RST_B,     -- ACTIVE LOW POWER-ON RESET
      CLK40M_10NS_REF => open  -- 40 MHZ WITH 40/60 DUTY CYCLE (IE 0 NS PW) DERIVED FROM 200 MHZ
      );
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- THIS IS THE CCC USED TO GENERATE THE FIXED 40 AND 160 MHZ CLOCK SOURCES AS WELL AS THE ASYNCHRONOUS USB 60 MHZ GLOBAL CLOCK BUFFER WITH FIXED DELAY OFFSET.  
-- CCC #1
  U_MAINCLKGEN : CLK_FXD_40_160_A60M
    port map (
      POWERDOWN => '1',                 -- '1' POWERS THE PLL
      CLKA      => CLK_40M_BUF_RECD,  -- 40 MHZ REFERENCE WITH A 40/60 DUTY CYCLE (IE 10NS PULSE) DERIVED FROMTHE 200 MHZ OSCILLATOR
      LOCK      => CCC_MAIN_LOCK,
      GLA       => CLK_40M_GL,  -- GLOBAL 40 MHZ CLOCK USED FOR ALL TIMING REFERENCES--RISE EDGE 1/2 CYCLE DELAYED REALTIVE TO 160M FIXED RISE EDGE
      GLB       => CCC_160M_FXD,        -- FIXED GLOBAL 160 MHZ CLOCK
      GLC       => CLK60MHZ,  -- GLOBAL 60 MHZ CLOCK FROM THE USB MODULE (ASYNC TO OTHER CLOCKS!)
      SDIN      => '0',                 --
      SCLK      => '0',                 --
      SSHIFT    => '0',                 --
      SUPDATE   => '0',                 --
      MODE      => '0',                 --
      SDOUT     => open,
      CLKC      => USBCLK60MHZ          -- SOURCE CLOCK FROM THE USB MODULE
      );
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- CHANNEL 0 TFC DCB TX MODULES (AND RX DDR OUTPUTS):
-- THE SERIAL TFC TX CONSISTS OF SERIAL DATA SELECT MUX, SERIALZER, BI-DIRECTIONAL DDR REGISTER FOR TFC, AND BIDIRECTIONAL BUFFER FOR THE REFCLOCK.
-- THE DATA SELECT MUX DETERMINES WHETHER TO SEND NORMAL DATA FROM THE RAM OR FIXED ALIGNMENT PATTERN DATA.

  U_TFC_SERDAT_SOURCE : SYNC_DAT_SEL
    port map (
      CLK40M_GEN => CLK_40M_GL,  -- FIXED CCC MAIN (#1) 40 MHZ TX WORD RATE CLOCK
      RESET_B    => MASTER_DCB_POR_B,  -- ONLY COME OUT OF RESET AND ENABLE IF CONFIGURED AS A DCB

      ALIGN_MODE_EN => OP_MODE(1),      -- '1' ENABLES THE SYNC PATTERN
      ALIGN_PATT    => F_ALIGN_PATT,

      SER_DAT_IN => PATT_TFC_DAT,

      P_SERDAT => TFC_TX_DAT
      );


  U_TFC_CMD_TX : SER320M
    port map (
      DDR_160M_CLK => CCC_160M_FXD,
      CLK40M_GEN   => CLK_40M_GL,  -- FROM PLL SYNCHRONOUS TO THE 160 MHZ SERDES CLOCKS

      RESET_B           => MASTER_DCB_POR_B,  -- ONLY COME OUT OF RESET AND ENABLE IF CONFIGURED AS A DCB
      NEXT_SER_CMD_WORD => TFC_TX_DAT,
      SERIAL_TX_EN      => '1',         -- ENABLE FOR THE SERIAL TX

      SER_OUT_R => TFC_OUT_R,
      SER_OUT_F => TFC_OUT_F
      );

-- ######################################################################################################################################
-- ######################################################################################################################################

  U_DDR_TFC : DDR_BIDIR_LVDS_DUAL_CLK
    port map (
      DDR_CLR    => MASTER_POR_B,       -- ACTIVE LOW CLEAR
      DDR_DIR    => DCB_SALT_SEL,  -- ENABLE OUTPUT(IE '1'= OUTPUT)==> TX ON FOR DCB MODE // RX ON FOR SALT MODE)
      DDR_TX_CLK => CCC_160M_FXD,       -- FIXED TX CLOCK
      DDR_TX_R   => TFC_OUT_R,          -- DATA TO BE TRANSMITTED
      DDR_TX_F   => TFC_OUT_F,          --   "
      DDR_RX_CLK => CCC_160M_ADJ,       -- PHASE DELAY TUNABLE RX CLOCK
      DDR_RX_R   => TFC_IN_DDR_R,       -- DATA BEING RECEIVED 
      DDR_RX_F   => TFC_IN_DDR_F,       --  "                   
      PADP       => TFC_DAT_0P,         -- 
      PADN       => TFC_DAT_0N          -- 
      );


  U_REFCLKBUF : BIDIR_LVDS_IO
    port map (Data  => CLK_40M_GL,      -- 
              Y     => EXTCLK_40MHZ,  -- RX COPY OF DISTRIBUTED 40 MHX FIXED CLOCK FROM THE DCB CONFIGURED COMET
              TRIEN => not(DCB_SALT_SEL),  -- ACTIVE LOW ENABLE (IE '1'=TRI-STATED)==> TX ON FOR DCB MODE // RX ON FOR SALT MODE)
              PADP  => REF_CLK_0P,      -- 
              PADN  => REF_CLK_0N       -- 
              );
-- ######################################################################################################################################
-- ######################################################################################################################################


--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- RAM BLOCK CH 1 MASTER ELINK0 TX DATA SOURCE MODULES (AND RX DDR OUTPUTS)FOR A SALT CONFIGURED COMET
-- THE MASTER SERIAL ELINK0 TX CONSISTS OF SERIAL DATA SELECT MUX, SERIALZER, AND BI-DIRECTIONAL DDR REGISTER FOR ELINK0
-- THE DATA SELECT MUX DETERMINES WHETHER TO SEND NORMAL DATA FROM THE RAM OR FIXED ALIGNMENT PATTERN DATA.

  U_ELK0_SERDAT_SOURCE : SYNC_DAT_SEL
    port map (
      CLK40M_GEN => CLK_40M_GL,  -- FIXED CCC MAIN (#1) 40 MHZ TX WORD RATE CLOCK
      RESET_B    => MASTER_SALT_POR_B,  -- ONLY COME OUT OF RESET AND ENABLE IF CONFIGURED AS A SALT

      ALIGN_MODE_EN => OP_MODE(1),      -- '1' ENABLES THE SYNC PATTERN
      ALIGN_PATT    => F_ALIGN_PATT,

      SER_DAT_IN => PATT_ELK_DAT(0),

      P_SERDAT => ELK0_TX_DAT
      );


  U_ELK0_CMD_TX : SER320M
    port map (
      DDR_160M_CLK => CCC_160M_FXD,
      CLK40M_GEN   => CLK_40M_GL,  -- FROM PLL SYNCHRONOUS TO 160MHZ SERDES CLOCKS

      RESET_B           => MASTER_SALT_POR_B,  -- ONLY COME OUT OF RESET AND ENABLE IF CONFIGURED AS A SALT
      NEXT_SER_CMD_WORD => ELK0_TX_DAT,
      SERIAL_TX_EN      => '1',         -- ENABLE FOR THE SERIAL TX

      SER_OUT_R => ELK0_OUT_R,
      SER_OUT_F => ELK0_OUT_F
      );

  U_DDR_ELK0 : DDR_BIDIR_LVDS_DUAL_CLK
    port map (
      DDR_CLR    => MASTER_POR_B,       -- ACTIVE LOW CLEAR
      DDR_DIR    => not(DCB_SALT_SEL),  -- ENABLE OUTPUT(IE '1'= OUTPUT)==> ELK TX ON FOR SALT MODE // ELK RX ON FOR DCB MODE)
      DDR_TX_CLK => CCC_160M_FXD,       -- FIXED TX CLOCK
      DDR_TX_R   => not(ELK0_OUT_R),  -- DATA TO BE TRANSMITTED ++++INVERTED PER NOTE A BEGINNING OF THIS FILE++++
      DDR_TX_F   => not(ELK0_OUT_F),  --  "                                         ++++INVERTED PER NOTE A BEGINNING OF THIS FILE++++
      DDR_RX_CLK => CCC_160M_ADJ,       -- PHASE DELAY TUNABLE RX CLOCK
      DDR_RX_R   => ELK0_IN_DDR_R,      -- DATA BEING RECEIVED
      DDR_RX_F   => ELK0_IN_DDR_F,      --  "
      PADP       => ELK0_DAT_P,
      PADN       => ELK0_DAT_N
      );

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- RAM BLOCKS CH0 AND CH1 MASTER DESERIALIZER WITH BUILT-IN INPUT AND OUTPUT DATA MUX LOGIC.  
-- DCB_SALT_SEL= '0' / '1' DETERMINE WHETHER DATA INTERFACES ARE TFC OR ELINK0
-- CONTAINS DYNAMICALLY ADJUSTED CCC2 WHICH GENERATES THE PHASE ADJUSTABLE 160 MHZ DESERIALIZER CLOCK.
-- INPUT REF CLOCK ASSUMED TO BE 160.0317 MHZ DERIVED FROM THE MASTER FPGA OF THE MASTER DCB-CONFIG'D COMET.

  U_MASTER_DES : TOP_MASTER_DES320M
    port map (
      CLK_40M_GL   => CLK_40M_GL,       -- ON-BOARD CCC1 40 MHZ CLOCK
      CCC_160M_FXD => CCC_160M_FXD,     -- FIXED PHASE 160 MHZ DDR CLOCK

      CLK_40M_BUF_RECD => CLK_40M_BUF_RECD,  -- RECEIVED 40 MHZ REF CLOCK DISTRIBUTED BY THE 'MASTER FPGA' ON THE MASTER DCB CONFIGURED COMET
      MASTER_POR_B     => MASTER_POR_B,  -- MASTER POWER-ON-RESET: SYNCHRONOUS RESET WAITS FOR CCC1 TO BE LOCKED AND STABLE

      DCB_SALT_SEL  => DCB_SALT_SEL,    -- '1'=DCB, '0'=SALT
      ALIGN_MODE_EN => OP_MODE(5),      -- '1'= AUTO ALIGN ENABLED
      SIM_MODE      => SIM_MODE,  -- GPIO_1:  '1' = SIM MODE, '0' = REAL TIME OP MODE

      MAN_BIT_OS     => "0000",  -- MANUAL BIT OFFSET ADJUSTMENT (THESE 3 MANUAL MODE INPUTS CAN BE HARD-WIRED INACTIVE AT NEXT LEVEL)
      MAN_PHASE_ADJ  => "00000",        -- MANUAL PHASE ADJUSTMENT 
      MAN_AUTO_ALIGN => '0',  -- '1'=MANUAL , '0'= AUTO PHASE ADJ MODE

      ELINK0_DDR_R => ELK0_IN_R,        -- ELINK0 DDR RISE SERIAL DATA
      ELINK0_DDR_F => ELK0_IN_F,        -- ELINK0 DDR FALL SERIAL DATA
      TFC_DDR_R    => TFC_IN_R,         -- TFC DDR RISE SERIAL DATA
      TFC_DDR_F    => TFC_IN_F,         -- TFC DDR FALL SERIAL DATA

      CH0_RAM_BPORT  => TFC_RX_SER_WORD,  -- SERIAL DATA GETS ROUTED TO THE RAM CH0 STORAGE ALLOCATED FOR TFC WHEN FPGA CONSIGD AS SALT
      CH1_RAM_BPORT  => ELK_RX_SER_WORD(0),  -- SERIAL DATA GETS ROUTED TO THE RAM CH1 STORAGE ALLOCATED FOR ELINK0
      P_BIT_OS_SEL   => BIT_OS_SEL,  -- BIT ALIGNMENT OFFSET VALUE DETERMINED BY MASTER DES320M AND USE DY ALL SLAVES
      P_ALIGN_ACTIVE => ALIGN_ACTIVE,  -- '1' INDICATES THE AUTO ALIGN FUNCTION IS ACTIVE

      P_CCC_RX_CLK_LOCK => CCC_RX_CLK_LOCK,  -- CCC2 LOCK STATUS
      P_CCC_160M_ADJ    => CCC_160M_ADJ,  -- CCC2 PHASE ADJUSTABLE 160 MHZ CLOCK--BASELINE PHASE
      P_CCC_160M_1ADJ   => open,  -- CCC2 PHASE ADJUSTABLE 160 MHZ CLOCK--ADD'L PHASE OFFSET 1 
      P_CCC_160M_2ADJ   => open  -- CCC2 PHASE ADJUSTABLE 160 MHZ CLOCK--ADD'L PHASE OFFSET 2
      );

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ELINK 1 -----OPERATES AS A SLAVE DESERIALIER 
--       +++++++INVERTED SERIAL DATA PATH PER NOTE AT BEGINNING OF THIS FILE+++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  U_ELK1_CH : ELINK_SLAVE_INV
    port map (
      CLK_40M_GL   => CLK_40M_GL,       -- CCC#1 FIXED 40MHZ CLOCK OUT
      CCC_160M_FXD => CCC_160M_FXD,     -- CCC#1 FIXED 160MHZ CLOCK
      CCC_160M_ADJ => CCC_160M_ADJ,     -- CCC#2 ADJ 160MHZ CLOCK

      DEV_RST_B         => DEV_RST_B,  -- ACTIVE LOW ASYNC RESET --DEDICATED COMET BOARD RC TIME CONSTANT
      MASTER_POR_B      => MASTER_POR_B,      -- MASTER_POR_B
      MASTER_DCB_POR_B  => MASTER_DCB_POR_B,  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR DCB CONFIGS
      MASTER_SALT_POR_B => MASTER_SALT_POR_B,  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR SALT CONFIGS

      DCB_SALT_SEL => DCB_SALT_SEL,  -- '1'= DCB MODE (IE TFC MASTER TX ENABLED) // '0'=SALT HYBRID MODE (IE TFC MASTER RX W/ SYNC MODE ENABLED)

      OP_MODE1_SPE => OP_MODE(1),       -- OP_MODE BIT 1 = SYNC PATT EN
      F_ALIGN_PATT => F_ALIGN_PATT,     -- FIXED SYNC / ALIGNMENT PATTERN BYTE
      PATT_ELK_DAT => PATT_ELK_DAT(1),  -- ELINK PATTERN TX DATA

      BIT_OS_SEL => BIT_OS_SEL,  -- BIT ALIGNMENT OFFSET VALUE DETERMINED BY MASTER DES320M AND USE DY ALL SLAVES

      ELK_DAT_P => ELK1_DAT_P,          -- SERIAL LVDS ELINK1 DATA BIDIR PORT
      ELK_DAT_N => ELK1_DAT_N,          --      ""

      ELK_RX_SER_WORD => ELK_RX_SER_WORD(1)  -- OUTPUT WORD OF THE ELINK DE-SERIALIZER
      );
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ELINK 2 -----OPERATES AS A SLAVE DESERIALIER
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  U_ELK2_CH : ELINK_SLAVE
    port map (
      CLK_40M_GL   => CLK_40M_GL,       -- CCC#1 FIXED 40MHZ CLOCK OUT
      CCC_160M_FXD => CCC_160M_FXD,     -- CCC#1 FIXED 160MHZ CLOCK
      CCC_160M_ADJ => CCC_160M_ADJ,     -- CCC#2 ADJ 160MHZ CLOCK

      DEV_RST_B         => DEV_RST_B,  -- ACTIVE LOW ASYNC RESET --DEDICATED COMET BOARD RC TIME CONSTANT
      MASTER_POR_B      => MASTER_POR_B,      -- MASTER_POR_B
      MASTER_DCB_POR_B  => MASTER_DCB_POR_B,  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR DCB CONFIGS
      MASTER_SALT_POR_B => MASTER_SALT_POR_B,  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR SALT CONFIGS

      DCB_SALT_SEL => DCB_SALT_SEL,  -- '1'= DCB MODE (IE TFC MASTER TX ENABLED) // '0'=SALT HYBRID MODE (IE TFC MASTER RX W/ SYNC MODE ENABLED)

      OP_MODE1_SPE => OP_MODE(1),       -- OP_MODE BIT 1 = SYNC PATT EN
      F_ALIGN_PATT => F_ALIGN_PATT,     -- FIXED SYNC / ALIGNMENT PATTERN BYTE
      PATT_ELK_DAT => PATT_ELK_DAT(2),  -- ELINK PATTERN TX DATA

      BIT_OS_SEL => BIT_OS_SEL,  -- BIT ALIGNMENT OFFSET VALUE DETERMINED BY MASTER DES320M AND USE DY ALL SLAVES

      ELK_DAT_P => ELK2_DAT_P,          -- SERIAL LVDS ELINK2 DATA BIDIR PORT
      ELK_DAT_N => ELK2_DAT_N,          --      ""

      ELK_RX_SER_WORD => ELK_RX_SER_WORD(2)  -- OUTPUT WORD OF THE ELINK DE-SERIALIZER
      );

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ELINK 3 -----OPERATES AS A SLAVE DESERIALIER
--       +++++++INVERTED SERIAL DATA PATH PER NOTE AT BEGINNING OF THIS FILE+++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  U_ELK3_CH : ELINK_SLAVE_INV
    port map (
      CLK_40M_GL   => CLK_40M_GL,       -- CCC#1 FIXED 40MHZ CLOCK OUT
      CCC_160M_FXD => CCC_160M_FXD,     -- CCC#1 FIXED 160MHZ CLOCK
      CCC_160M_ADJ => CCC_160M_ADJ,     -- CCC#2 ADJ 160MHZ CLOCK

      DEV_RST_B         => DEV_RST_B,  -- ACTIVE LOW ASYNC RESET --DEDICATED COMET BOARD RC TIME CONSTANT
      MASTER_POR_B      => MASTER_POR_B,      -- MASTER_POR_B
      MASTER_DCB_POR_B  => MASTER_DCB_POR_B,  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR DCB CONFIGS
      MASTER_SALT_POR_B => MASTER_SALT_POR_B,  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR SALT CONFIGS

      DCB_SALT_SEL => DCB_SALT_SEL,  -- '1'= DCB MODE (IE TFC MASTER TX ENABLED) // '0'=SALT HYBRID MODE (IE TFC MASTER RX W/ SYNC MODE ENABLED)

      OP_MODE1_SPE => OP_MODE(1),       -- OP_MODE BIT 1 = SYNC PATT EN
      F_ALIGN_PATT => F_ALIGN_PATT,     -- FIXED SYNC / ALIGNMENT PATTERN BYTE
      PATT_ELK_DAT => PATT_ELK_DAT(3),  -- ELINK PATTERN TX DATA

      BIT_OS_SEL => BIT_OS_SEL,  -- BIT ALIGNMENT OFFSET VALUE DETERMINED BY MASTER DES320M AND USE DY ALL SLAVES

      ELK_DAT_P => ELK3_DAT_P,          -- SERIAL LVDS ELINK0 DATA BIDIR PORT
      ELK_DAT_N => ELK3_DAT_N,          --      ""

      ELK_RX_SER_WORD => ELK_RX_SER_WORD(3)  -- OUTPUT WORD OF THE ELINK DE-SERIALIZER
      );

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ELINK 4 -----OPERATES AS A SLAVE DESERIALIER
--       +++++++INVERTED SERIAL DATA PATH PER NOTE AT BEGINNING OF THIS FILE+++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  U_ELK4_CH : ELINK_SLAVE_INV
    port map (
      CLK_40M_GL   => CLK_40M_GL,       -- CCC#1 FIXED 40MHZ CLOCK OUT
      CCC_160M_FXD => CCC_160M_FXD,     -- CCC#1 FIXED 160MHZ CLOCK
      CCC_160M_ADJ => CCC_160M_ADJ,     -- CCC#2 ADJ 160MHZ CLOCK

      DEV_RST_B         => DEV_RST_B,  -- ACTIVE LOW ASYNC RESET --DEDICATED COMET BOARD RC TIME CONSTANT
      MASTER_POR_B      => MASTER_POR_B,      -- MASTER_POR_B
      MASTER_DCB_POR_B  => MASTER_DCB_POR_B,  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR DCB CONFIGS
      MASTER_SALT_POR_B => MASTER_SALT_POR_B,  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR SALT CONFIGS

      DCB_SALT_SEL => DCB_SALT_SEL,  -- '1'= DCB MODE (IE TFC MASTER TX ENABLED) // '0'=SALT HYBRID MODE (IE TFC MASTER RX W/ SYNC MODE ENABLED)

      OP_MODE1_SPE => OP_MODE(1),       -- OP_MODE BIT 1 = SYNC PATT EN
      F_ALIGN_PATT => F_ALIGN_PATT,     -- FIXED SYNC / ALIGNMENT PATTERN BYTE
      PATT_ELK_DAT => PATT_ELK_DAT(4),  -- ELINK PATTERN TX DATA

      BIT_OS_SEL => BIT_OS_SEL,  -- BIT ALIGNMENT OFFSET VALUE DETERMINED BY MASTER DES320M AND USE DY ALL SLAVES

      ELK_DAT_P => ELK4_DAT_P,          -- SERIAL LVDS ELINK0 DATA BIDIR PORT
      ELK_DAT_N => ELK4_DAT_N,          --      ""

      ELK_RX_SER_WORD => ELK_RX_SER_WORD(4)  -- OUTPUT WORD OF THE ELINK DE-SERIALIZER
      );

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ELINK 5 -----OPERATES AS A SLAVE DESERIALIER
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  U_ELK5_CH : ELINK_SLAVE
    port map (
      CLK_40M_GL   => CLK_40M_GL,       -- CCC#1 FIXED 40MHZ CLOCK OUT
      CCC_160M_FXD => CCC_160M_FXD,     -- CCC#1 FIXED 160MHZ CLOCK
      CCC_160M_ADJ => CCC_160M_ADJ,     -- CCC#2 ADJ 160MHZ CLOCK

      DEV_RST_B         => DEV_RST_B,  -- ACTIVE LOW ASYNC RESET --DEDICATED COMET BOARD RC TIME CONSTANT
      MASTER_POR_B      => MASTER_POR_B,      -- MASTER_POR_B
      MASTER_DCB_POR_B  => MASTER_DCB_POR_B,  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR DCB CONFIGS
      MASTER_SALT_POR_B => MASTER_SALT_POR_B,  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR SALT CONFIGS

      DCB_SALT_SEL => DCB_SALT_SEL,  -- '1'= DCB MODE (IE TFC MASTER TX ENABLED) // '0'=SALT HYBRID MODE (IE TFC MASTER RX W/ SYNC MODE ENABLED)

      OP_MODE1_SPE => OP_MODE(1),       -- OP_MODE BIT 1 = SYNC PATT EN
      F_ALIGN_PATT => F_ALIGN_PATT,     -- FIXED SYNC / ALIGNMENT PATTERN BYTE
      PATT_ELK_DAT => PATT_ELK_DAT(5),  -- ELINK PATTERN TX DATA

      BIT_OS_SEL => BIT_OS_SEL,  -- BIT ALIGNMENT OFFSET VALUE DETERMINED BY MASTER DES320M AND USE DY ALL SLAVES

      ELK_DAT_P => ELK5_DAT_P,          -- SERIAL LVDS ELINK0 DATA BIDIR PORT
      ELK_DAT_N => ELK5_DAT_N,          --      ""

      ELK_RX_SER_WORD => ELK_RX_SER_WORD(5)  -- OUTPUT WORD OF THE ELINK DE-SERIALIZER
      );

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ELINK 6 -----OPERATES AS A SLAVE DESERIALIER
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  U_ELK6_CH : ELINK_SLAVE
    port map (
      CLK_40M_GL   => CLK_40M_GL,       -- CCC#1 FIXED 40MHZ CLOCK OUT
      CCC_160M_FXD => CCC_160M_FXD,     -- CCC#1 FIXED 160MHZ CLOCK
      CCC_160M_ADJ => CCC_160M_ADJ,     -- CCC#2 ADJ 160MHZ CLOCK

      DEV_RST_B         => DEV_RST_B,  -- ACTIVE LOW ASYNC RESET --DEDICATED COMET BOARD RC TIME CONSTANT
      MASTER_POR_B      => MASTER_POR_B,      -- MASTER_POR_B
      MASTER_DCB_POR_B  => MASTER_DCB_POR_B,  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR DCB CONFIGS
      MASTER_SALT_POR_B => MASTER_SALT_POR_B,  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR SALT CONFIGS

      DCB_SALT_SEL => DCB_SALT_SEL,  -- '1'= DCB MODE (IE TFC MASTER TX ENABLED) // '0'=SALT HYBRID MODE (IE TFC MASTER RX W/ SYNC MODE ENABLED)

      OP_MODE1_SPE => OP_MODE(1),       -- OP_MODE BIT 1 = SYNC PATT EN
      F_ALIGN_PATT => F_ALIGN_PATT,     -- FIXED SYNC / ALIGNMENT PATTERN BYTE
      PATT_ELK_DAT => PATT_ELK_DAT(6),  -- ELINK PATTERN TX DATA

      BIT_OS_SEL => BIT_OS_SEL,  -- BIT ALIGNMENT OFFSET VALUE DETERMINED BY MASTER DES320M AND USE DY ALL SLAVES

      ELK_DAT_P => ELK6_DAT_P,          -- SERIAL LVDS ELINK0 DATA BIDIR PORT
      ELK_DAT_N => ELK6_DAT_N,          --      ""

      ELK_RX_SER_WORD => ELK_RX_SER_WORD(6)  -- OUTPUT WORD OF THE ELINK DE-SERIALIZER
      );

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ELINK 7 -----OPERATES AS A SLAVE DESERIALIER
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  U_ELK7_CH : ELINK_SLAVE
    port map (
      CLK_40M_GL   => CLK_40M_GL,       -- CCC#1 FIXED 40MHZ CLOCK OUT
      CCC_160M_FXD => CCC_160M_FXD,     -- CCC#1 FIXED 160MHZ CLOCK
      CCC_160M_ADJ => CCC_160M_ADJ,     -- CCC#2 ADJ 160MHZ CLOCK

      DEV_RST_B         => DEV_RST_B,  -- ACTIVE LOW ASYNC RESET --DEDICATED COMET BOARD RC TIME CONSTANT
      MASTER_POR_B      => MASTER_POR_B,      -- MASTER_POR_B
      MASTER_DCB_POR_B  => MASTER_DCB_POR_B,  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR DCB CONFIGS
      MASTER_SALT_POR_B => MASTER_SALT_POR_B,  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR SALT CONFIGS

      DCB_SALT_SEL => DCB_SALT_SEL,  -- '1'= DCB MODE (IE TFC MASTER TX ENABLED) // '0'=SALT HYBRID MODE (IE TFC MASTER RX W/ SYNC MODE ENABLED)

      OP_MODE1_SPE => OP_MODE(1),       -- OP_MODE BIT 1 = SYNC PATT EN
      F_ALIGN_PATT => F_ALIGN_PATT,     -- FIXED SYNC / ALIGNMENT PATTERN BYTE
      PATT_ELK_DAT => PATT_ELK_DAT(7),  -- ELINK PATTERN TX DATA

      BIT_OS_SEL => BIT_OS_SEL,  -- BIT ALIGNMENT OFFSET VALUE DETERMINED BY MASTER DES320M AND USE DY ALL SLAVES

      ELK_DAT_P => ELK7_DAT_P,          -- SERIAL LVDS ELINK0 DATA BIDIR PORT
      ELK_DAT_N => ELK7_DAT_N,          --      ""

      ELK_RX_SER_WORD => ELK_RX_SER_WORD(7)  -- OUTPUT WORD OF THE ELINK DE-SERIALIZER
      );

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ELINK 8 -----OPERATES AS A SLAVE DESERIALIER
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  U_ELK8_CH : ELINK_SLAVE
    port map (
      CLK_40M_GL   => CLK_40M_GL,       -- CCC#1 FIXED 40MHZ CLOCK OUT
      CCC_160M_FXD => CCC_160M_FXD,     -- CCC#1 FIXED 160MHZ CLOCK
      CCC_160M_ADJ => CCC_160M_ADJ,     -- CCC#2 ADJ 160MHZ CLOCK

      DEV_RST_B         => DEV_RST_B,  -- ACTIVE LOW ASYNC RESET --DEDICATED COMET BOARD RC TIME CONSTANT
      MASTER_POR_B      => MASTER_POR_B,      -- MASTER_POR_B
      MASTER_DCB_POR_B  => MASTER_DCB_POR_B,  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR DCB CONFIGS
      MASTER_SALT_POR_B => MASTER_SALT_POR_B,  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR SALT CONFIGS

      DCB_SALT_SEL => DCB_SALT_SEL,  -- '1'= DCB MODE (IE TFC MASTER TX ENABLED) // '0'=SALT HYBRID MODE (IE TFC MASTER RX W/ SYNC MODE ENABLED)

      OP_MODE1_SPE => OP_MODE(1),       -- OP_MODE BIT 1 = SYNC PATT EN
      F_ALIGN_PATT => F_ALIGN_PATT,     -- FIXED SYNC / ALIGNMENT PATTERN BYTE
      PATT_ELK_DAT => PATT_ELK_DAT(8),  -- ELINK PATTERN TX DATA

      BIT_OS_SEL => BIT_OS_SEL,  -- BIT ALIGNMENT OFFSET VALUE DETERMINED BY MASTER DES320M AND USE DY ALL SLAVES

      ELK_DAT_P => ELK8_DAT_P,          -- SERIAL LVDS ELINK0 DATA BIDIR PORT
      ELK_DAT_N => ELK8_DAT_N,          --      ""

      ELK_RX_SER_WORD => ELK_RX_SER_WORD(8)  -- OUTPUT WORD OF THE ELINK DE-SERIALIZER
      );

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ELINK 9 -----OPERATES AS A SLAVE DESERIALIER
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  U_ELK9_CH : ELINK_SLAVE
    port map (
      CLK_40M_GL   => CLK_40M_GL,       -- CCC#1 FIXED 40MHZ CLOCK OUT
      CCC_160M_FXD => CCC_160M_FXD,     -- CCC#1 FIXED 160MHZ CLOCK
      CCC_160M_ADJ => CCC_160M_ADJ,     -- CCC#2 ADJ 160MHZ CLOCK

      DEV_RST_B         => DEV_RST_B,  -- ACTIVE LOW ASYNC RESET --DEDICATED COMET BOARD RC TIME CONSTANT
      MASTER_POR_B      => MASTER_POR_B,      -- MASTER_POR_B
      MASTER_DCB_POR_B  => MASTER_DCB_POR_B,  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR DCB CONFIGS
      MASTER_SALT_POR_B => MASTER_SALT_POR_B,  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR SALT CONFIGS

      DCB_SALT_SEL => DCB_SALT_SEL,  -- '1'= DCB MODE (IE TFC MASTER TX ENABLED) // '0'=SALT HYBRID MODE (IE TFC MASTER RX W/ SYNC MODE ENABLED)

      OP_MODE1_SPE => OP_MODE(1),       -- OP_MODE BIT 1 = SYNC PATT EN
      F_ALIGN_PATT => F_ALIGN_PATT,     -- FIXED SYNC / ALIGNMENT PATTERN BYTE
      PATT_ELK_DAT => PATT_ELK_DAT(9),  -- ELINK PATTERN TX DATA

      BIT_OS_SEL => BIT_OS_SEL,  -- BIT ALIGNMENT OFFSET VALUE DETERMINED BY MASTER DES320M AND USE DY ALL SLAVES

      ELK_DAT_P => ELK9_DAT_P,          -- SERIAL LVDS ELINK0 DATA BIDIR PORT
      ELK_DAT_N => ELK9_DAT_N,          --      ""

      ELK_RX_SER_WORD => ELK_RX_SER_WORD(9)  -- OUTPUT WORD OF THE ELINK DE-SERIALIZER
      );

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ELINK 10 -----OPERATES AS A SLAVE DESERIALIER
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  U_ELK10_CH : ELINK_SLAVE
    port map (
      CLK_40M_GL   => CLK_40M_GL,       -- CCC#1 FIXED 40MHZ CLOCK OUT
      CCC_160M_FXD => CCC_160M_FXD,     -- CCC#1 FIXED 160MHZ CLOCK
      CCC_160M_ADJ => CCC_160M_ADJ,     -- CCC#2 ADJ 160MHZ CLOCK

      DEV_RST_B         => DEV_RST_B,  -- ACTIVE LOW ASYNC RESET --DEDICATED COMET BOARD RC TIME CONSTANT
      MASTER_POR_B      => MASTER_POR_B,      -- MASTER_POR_B
      MASTER_DCB_POR_B  => MASTER_DCB_POR_B,  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR DCB CONFIGS
      MASTER_SALT_POR_B => MASTER_SALT_POR_B,  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR SALT CONFIGS

      DCB_SALT_SEL => DCB_SALT_SEL,  -- '1'= DCB MODE (IE TFC MASTER TX ENABLED) // '0'=SALT HYBRID MODE (IE TFC MASTER RX W/ SYNC MODE ENABLED)

      OP_MODE1_SPE => OP_MODE(1),        -- OP_MODE BIT 1 = SYNC PATT EN
      F_ALIGN_PATT => F_ALIGN_PATT,      -- FIXED SYNC / ALIGNMENT PATTERN BYTE
      PATT_ELK_DAT => PATT_ELK_DAT(10),  -- ELINK PATTERN TX DATA

      BIT_OS_SEL => BIT_OS_SEL,  -- BIT ALIGNMENT OFFSET VALUE DETERMINED BY MASTER DES320M AND USE DY ALL SLAVES

      ELK_DAT_P => ELK10_DAT_P,         -- SERIAL LVDS ELINK0 DATA BIDIR PORT
      ELK_DAT_N => ELK10_DAT_N,         --     ""

      ELK_RX_SER_WORD => ELK_RX_SER_WORD(10)  -- OUTPUT WORD OF THE ELINK DE-SERIALIZER
      );

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ELINK 11 -----OPERATES AS A SLAVE DESERIALIER
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  U_ELK11_CH : ELINK_SLAVE
    port map (
      CLK_40M_GL   => CLK_40M_GL,       -- CCC#1 FIXED 40MHZ CLOCK OUT
      CCC_160M_FXD => CCC_160M_FXD,     -- CCC#1 FIXED 160MHZ CLOCK
      CCC_160M_ADJ => CCC_160M_ADJ,     -- CCC#2 ADJ 160MHZ CLOCK

      DEV_RST_B         => DEV_RST_B,  -- ACTIVE LOW ASYNC RESET --DEDICATED COMET BOARD RC TIME CONSTANT
      MASTER_POR_B      => MASTER_POR_B,      -- MASTER_POR_B
      MASTER_DCB_POR_B  => MASTER_DCB_POR_B,  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR DCB CONFIGS
      MASTER_SALT_POR_B => MASTER_SALT_POR_B,  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR SALT CONFIGS

      DCB_SALT_SEL => DCB_SALT_SEL,  -- '1'= DCB MODE (IE TFC MASTER TX ENABLED) // '0'=SALT HYBRID MODE (IE TFC MASTER RX W/ SYNC MODE ENABLED)

      OP_MODE1_SPE => OP_MODE(1),        -- OP_MODE BIT 1 = SYNC PATT EN
      F_ALIGN_PATT => F_ALIGN_PATT,      -- FIXED SYNC / ALIGNMENT PATTERN BYTE
      PATT_ELK_DAT => PATT_ELK_DAT(11),  -- ELINK PATTERN TX DATA

      BIT_OS_SEL => BIT_OS_SEL,  -- BIT ALIGNMENT OFFSET VALUE DETERMINED BY MASTER DES320M AND USE DY ALL SLAVES

      ELK_DAT_P => ELK11_DAT_P,         -- SERIAL LVDS ELINK0 DATA BIDIR PORT
      ELK_DAT_N => ELK11_DAT_N,         --     ""

      ELK_RX_SER_WORD => ELK_RX_SER_WORD(11)  -- OUTPUT WORD OF THE ELINK DE-SERIALIZER
      );

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ELINK 12 -----OPERATES AS A SLAVE DESERIALIER
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  U_ELK12_CH : ELINK_SLAVE
    port map (
      CLK_40M_GL   => CLK_40M_GL,       -- CCC#1 FIXED 40MHZ CLOCK OUT
      CCC_160M_FXD => CCC_160M_FXD,     -- CCC#1 FIXED 160MHZ CLOCK
      CCC_160M_ADJ => CCC_160M_ADJ,     -- CCC#2 ADJ 160MHZ CLOCK

      DEV_RST_B         => DEV_RST_B,  -- ACTIVE LOW ASYNC RESET --DEDICATED COMET BOARD RC TIME CONSTANT
      MASTER_POR_B      => MASTER_POR_B,      -- MASTER_POR_B
      MASTER_DCB_POR_B  => MASTER_DCB_POR_B,  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR DCB CONFIGS
      MASTER_SALT_POR_B => MASTER_SALT_POR_B,  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR SALT CONFIGS

      DCB_SALT_SEL => DCB_SALT_SEL,  -- '1'= DCB MODE (IE TFC MASTER TX ENABLED) // '0'=SALT HYBRID MODE (IE TFC MASTER RX W/ SYNC MODE ENABLED)

      OP_MODE1_SPE => OP_MODE(1),        -- OP_MODE BIT 1 = SYNC PATT EN
      F_ALIGN_PATT => F_ALIGN_PATT,      -- FIXED SYNC / ALIGNMENT PATTERN BYTE
      PATT_ELK_DAT => PATT_ELK_DAT(12),  -- ELINK PATTERN TX DATA

      BIT_OS_SEL => BIT_OS_SEL,  -- BIT ALIGNMENT OFFSET VALUE DETERMINED BY MASTER DES320M AND USE DY ALL SLAVES

      ELK_DAT_P => ELK12_DAT_P,         -- SERIAL LVDS ELINK0 DATA BIDIR PORT
      ELK_DAT_N => ELK12_DAT_N,         --     ""

      ELK_RX_SER_WORD => ELK_RX_SER_WORD(12)  -- OUTPUT WORD OF THE ELINK DE-SERIALIZER
      );

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ELINK 13 -----OPERATES AS A SLAVE DESERIALIER
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  U_ELK13_CH : ELINK_SLAVE
    port map (
      CLK_40M_GL   => CLK_40M_GL,       -- CCC#1 FIXED 40MHZ CLOCK OUT
      CCC_160M_FXD => CCC_160M_FXD,     -- CCC#1 FIXED 160MHZ CLOCK
      CCC_160M_ADJ => CCC_160M_ADJ,     -- CCC#2 ADJ 160MHZ CLOCK

      DEV_RST_B         => DEV_RST_B,  -- ACTIVE LOW ASYNC RESET --DEDICATED COMET BOARD RC TIME CONSTANT
      MASTER_POR_B      => MASTER_POR_B,      -- MASTER_POR_B
      MASTER_DCB_POR_B  => MASTER_DCB_POR_B,  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR DCB CONFIGS
      MASTER_SALT_POR_B => MASTER_SALT_POR_B,  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR SALT CONFIGS

      DCB_SALT_SEL => DCB_SALT_SEL,  -- '1'= DCB MODE (IE TFC MASTER TX ENABLED) // '0'=SALT HYBRID MODE (IE TFC MASTER RX W/ SYNC MODE ENABLED)

      OP_MODE1_SPE => OP_MODE(1),        -- OP_MODE BIT 1 = SYNC PATT EN
      F_ALIGN_PATT => F_ALIGN_PATT,      -- FIXED SYNC / ALIGNMENT PATTERN BYTE
      PATT_ELK_DAT => PATT_ELK_DAT(13),  -- ELINK PATTERN TX DATA

      BIT_OS_SEL => BIT_OS_SEL,  -- BIT ALIGNMENT OFFSET VALUE DETERMINED BY MASTER DES320M AND USE DY ALL SLAVES

      ELK_DAT_P => ELK13_DAT_P,         -- SERIAL LVDS ELINK0 DATA BIDIR PORT
      ELK_DAT_N => ELK13_DAT_N,         --     ""

      ELK_RX_SER_WORD => ELK_RX_SER_WORD(13)  -- OUTPUT WORD OF THE ELINK DE-SERIALIZER
      );

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ELINK 14 -----OPERATES AS A SLAVE DESERIALIER
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  U_ELK14_CH : ELINK_SLAVE
    port map (
      CLK_40M_GL   => CLK_40M_GL,       -- CCC#1 FIXED 40MHZ CLOCK OUT
      CCC_160M_FXD => CCC_160M_FXD,     -- CCC#1 FIXED 160MHZ CLOCK
      CCC_160M_ADJ => CCC_160M_ADJ,     -- CCC#2 ADJ 160MHZ CLOCK

      DEV_RST_B         => DEV_RST_B,  -- ACTIVE LOW ASYNC RESET --DEDICATED COMET BOARD RC TIME CONSTANT
      MASTER_POR_B      => MASTER_POR_B,      -- MASTER_POR_B
      MASTER_DCB_POR_B  => MASTER_DCB_POR_B,  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR DCB CONFIGS
      MASTER_SALT_POR_B => MASTER_SALT_POR_B,  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR SALT CONFIGS

      DCB_SALT_SEL => DCB_SALT_SEL,  -- '1'= DCB MODE (IE TFC MASTER TX ENABLED) // '0'=SALT HYBRID MODE (IE TFC MASTER RX W/ SYNC MODE ENABLED)

      OP_MODE1_SPE => OP_MODE(1),        -- OP_MODE BIT 1 = SYNC PATT EN
      F_ALIGN_PATT => F_ALIGN_PATT,      -- FIXED SYNC / ALIGNMENT PATTERN BYTE
      PATT_ELK_DAT => PATT_ELK_DAT(14),  -- ELINK PATTERN TX DATA

      BIT_OS_SEL => BIT_OS_SEL,  -- BIT ALIGNMENT OFFSET VALUE DETERMINED BY MASTER DES320M AND USE DY ALL SLAVES

      ELK_DAT_P => ELK14_DAT_P,         -- SERIAL LVDS ELINK0 DATA BIDIR PORT
      ELK_DAT_N => ELK14_DAT_N,         --     ""

      ELK_RX_SER_WORD => ELK_RX_SER_WORD(14)  -- OUTPUT WORD OF THE ELINK DE-SERIALIZER
      );

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ELINK 15 -----OPERATES AS A SLAVE DESERIALIER
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  U_ELK15_CH : ELINK_SLAVE
    port map (
      CLK_40M_GL   => CLK_40M_GL,       -- CCC#1 FIXED 40MHZ CLOCK OUT
      CCC_160M_FXD => CCC_160M_FXD,     -- CCC#1 FIXED 160MHZ CLOCK
      CCC_160M_ADJ => CCC_160M_ADJ,     -- CCC#2 ADJ 160MHZ CLOCK

      DEV_RST_B         => DEV_RST_B,  -- ACTIVE LOW ASYNC RESET --DEDICATED COMET BOARD RC TIME CONSTANT
      MASTER_POR_B      => MASTER_POR_B,      -- MASTER_POR_B
      MASTER_DCB_POR_B  => MASTER_DCB_POR_B,  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR DCB CONFIGS
      MASTER_SALT_POR_B => MASTER_SALT_POR_B,  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR SALT CONFIGS

      DCB_SALT_SEL => DCB_SALT_SEL,  -- '1'= DCB MODE (IE TFC MASTER TX ENABLED) // '0'=SALT HYBRID MODE (IE TFC MASTER RX W/ SYNC MODE ENABLED)

      OP_MODE1_SPE => OP_MODE(1),        -- OP_MODE BIT 1 = SYNC PATT EN
      F_ALIGN_PATT => F_ALIGN_PATT,      -- FIXED SYNC / ALIGNMENT PATTERN BYTE
      PATT_ELK_DAT => PATT_ELK_DAT(15),  -- ELINK PATTERN TX DATA

      BIT_OS_SEL => BIT_OS_SEL,  -- BIT ALIGNMENT OFFSET VALUE DETERMINED BY MASTER DES320M AND USE DY ALL SLAVES

      ELK_DAT_P => ELK15_DAT_P,         -- SERIAL LVDS ELINK0 DATA BIDIR PORT
      ELK_DAT_N => ELK15_DAT_N,         --     ""

      ELK_RX_SER_WORD => ELK_RX_SER_WORD(15)  -- OUTPUT WORD OF THE ELINK DE-SERIALIZER
      );

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ELINK 16 -----OPERATES AS A SLAVE DESERIALIER
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  U_ELK16_CH : ELINK_SLAVE
    port map (
      CLK_40M_GL   => CLK_40M_GL,       -- CCC#1 FIXED 40MHZ CLOCK OUT
      CCC_160M_FXD => CCC_160M_FXD,     -- CCC#1 FIXED 160MHZ CLOCK
      CCC_160M_ADJ => CCC_160M_ADJ,     -- CCC#2 ADJ 160MHZ CLOCK

      DEV_RST_B         => DEV_RST_B,  -- ACTIVE LOW ASYNC RESET --DEDICATED COMET BOARD RC TIME CONSTANT
      MASTER_POR_B      => MASTER_POR_B,      -- MASTER_POR_B
      MASTER_DCB_POR_B  => MASTER_DCB_POR_B,  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR DCB CONFIGS
      MASTER_SALT_POR_B => MASTER_SALT_POR_B,  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR SALT CONFIGS

      DCB_SALT_SEL => DCB_SALT_SEL,  -- '1'= DCB MODE (IE TFC MASTER TX ENABLED) // '0'=SALT HYBRID MODE (IE TFC MASTER RX W/ SYNC MODE ENABLED)

      OP_MODE1_SPE => OP_MODE(1),        -- OP_MODE BIT 1 = SYNC PATT EN
      F_ALIGN_PATT => F_ALIGN_PATT,      -- FIXED SYNC / ALIGNMENT PATTERN BYTE
      PATT_ELK_DAT => PATT_ELK_DAT(16),  -- ELINK PATTERN TX DATA

      BIT_OS_SEL => BIT_OS_SEL,  -- BIT ALIGNMENT OFFSET VALUE DETERMINED BY MASTER DES320M AND USE DY ALL SLAVES

      ELK_DAT_P => ELK16_DAT_P,         -- SERIAL LVDS ELINK0 DATA BIDIR PORT
      ELK_DAT_N => ELK16_DAT_N,         --     ""

      ELK_RX_SER_WORD => ELK_RX_SER_WORD(16)  -- OUTPUT WORD OF THE ELINK DE-SERIALIZER
      );

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ELINK 17 -----OPERATES AS A SLAVE DESERIALIER
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  U_ELK17_CH : ELINK_SLAVE
    port map (
      CLK_40M_GL   => CLK_40M_GL,       -- CCC#1 FIXED 40MHZ CLOCK OUT
      CCC_160M_FXD => CCC_160M_FXD,     -- CCC#1 FIXED 160MHZ CLOCK
      CCC_160M_ADJ => CCC_160M_ADJ,     -- CCC#2 ADJ 160MHZ CLOCK

      DEV_RST_B         => DEV_RST_B,  -- ACTIVE LOW ASYNC RESET --DEDICATED COMET BOARD RC TIME CONSTANT
      MASTER_POR_B      => MASTER_POR_B,      -- MASTER_POR_B
      MASTER_DCB_POR_B  => MASTER_DCB_POR_B,  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR DCB CONFIGS
      MASTER_SALT_POR_B => MASTER_SALT_POR_B,  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR SALT CONFIGS

      DCB_SALT_SEL => DCB_SALT_SEL,  -- '1'= DCB MODE (IE TFC MASTER TX ENABLED) // '0'=SALT HYBRID MODE (IE TFC MASTER RX W/ SYNC MODE ENABLED)

      OP_MODE1_SPE => OP_MODE(1),        -- OP_MODE BIT 1 = SYNC PATT EN
      F_ALIGN_PATT => F_ALIGN_PATT,      -- FIXED SYNC / ALIGNMENT PATTERN BYTE
      PATT_ELK_DAT => PATT_ELK_DAT(17),  -- ELINK PATTERN TX DATA

      BIT_OS_SEL => BIT_OS_SEL,  -- BIT ALIGNMENT OFFSET VALUE DETERMINED BY MASTER DES320M AND USE DY ALL SLAVES

      ELK_DAT_P => ELK17_DAT_P,         -- SERIAL LVDS ELINK0 DATA BIDIR PORT
      ELK_DAT_N => ELK17_DAT_N,         --     ""

      ELK_RX_SER_WORD => ELK_RX_SER_WORD(17)  -- OUTPUT WORD OF THE ELINK DE-SERIALIZER
      );

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ELINK 18 -----OPERATES AS A SLAVE DESERIALIER
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  U_ELK18_CH : ELINK_SLAVE
    port map (
      CLK_40M_GL   => CLK_40M_GL,       -- CCC#1 FIXED 40MHZ CLOCK OUT
      CCC_160M_FXD => CCC_160M_FXD,     -- CCC#1 FIXED 160MHZ CLOCK
      CCC_160M_ADJ => CCC_160M_ADJ,     -- CCC#2 ADJ 160MHZ CLOCK

      DEV_RST_B         => DEV_RST_B,  -- ACTIVE LOW ASYNC RESET --DEDICATED COMET BOARD RC TIME CONSTANT
      MASTER_POR_B      => MASTER_POR_B,      -- MASTER_POR_B
      MASTER_DCB_POR_B  => MASTER_DCB_POR_B,  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR DCB CONFIGS
      MASTER_SALT_POR_B => MASTER_SALT_POR_B,  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR SALT CONFIGS

      DCB_SALT_SEL => DCB_SALT_SEL,  -- '1'= DCB MODE (IE TFC MASTER TX ENABLED) // '0'=SALT HYBRID MODE (IE TFC MASTER RX W/ SYNC MODE ENABLED)

      OP_MODE1_SPE => OP_MODE(1),        -- OP_MODE BIT 1 = SYNC PATT EN
      F_ALIGN_PATT => F_ALIGN_PATT,      -- FIXED SYNC / ALIGNMENT PATTERN BYTE
      PATT_ELK_DAT => PATT_ELK_DAT(18),  -- ELINK PATTERN TX DATA

      BIT_OS_SEL => BIT_OS_SEL,  -- BIT ALIGNMENT OFFSET VALUE DETERMINED BY MASTER DES320M AND USE DY ALL SLAVES

      ELK_DAT_P => ELK18_DAT_P,         -- SERIAL LVDS ELINK0 DATA BIDIR PORT
      ELK_DAT_N => ELK18_DAT_N,         --     ""

      ELK_RX_SER_WORD => ELK_RX_SER_WORD(18)  -- OUTPUT WORD OF THE ELINK DE-SERIALIZER
      );

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ELINK 19 -----OPERATES AS A SLAVE DESERIALIER
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  U_ELK19_CH : ELINK_SLAVE
    port map (
      CLK_40M_GL   => CLK_40M_GL,       -- CCC#1 FIXED 40MHZ CLOCK OUT
      CCC_160M_FXD => CCC_160M_FXD,     -- CCC#1 FIXED 160MHZ CLOCK
      CCC_160M_ADJ => CCC_160M_ADJ,     -- CCC#2 ADJ 160MHZ CLOCK

      DEV_RST_B         => DEV_RST_B,  -- ACTIVE LOW ASYNC RESET --DEDICATED COMET BOARD RC TIME CONSTANT
      MASTER_POR_B      => MASTER_POR_B,      -- MASTER_POR_B
      MASTER_DCB_POR_B  => MASTER_DCB_POR_B,  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR DCB CONFIGS
      MASTER_SALT_POR_B => MASTER_SALT_POR_B,  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR SALT CONFIGS

      DCB_SALT_SEL => DCB_SALT_SEL,  -- '1'= DCB MODE (IE TFC MASTER TX ENABLED) // '0'=SALT HYBRID MODE (IE TFC MASTER RX W/ SYNC MODE ENABLED)

      OP_MODE1_SPE => OP_MODE(1),        -- OP_MODE BIT 1 = SYNC PATT EN
      F_ALIGN_PATT => F_ALIGN_PATT,      -- FIXED SYNC / ALIGNMENT PATTERN BYTE
      PATT_ELK_DAT => PATT_ELK_DAT(19),  -- ELINK PATTERN TX DATA

      BIT_OS_SEL => BIT_OS_SEL,  -- BIT ALIGNMENT OFFSET VALUE DETERMINED BY MASTER DES320M AND USE DY ALL SLAVES

      ELK_DAT_P => ELK19_DAT_P,     -- SERIAL LVDS ELINK0 DATA BIDIR PORT
      ELK_DAT_N => ELK19_DAT_N,     -- ""

      ELK_RX_SER_WORD => ELK_RX_SER_WORD(19)  -- OUTPUT WORD OF THE ELINK DE-SERIALIZER
      );

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ELINK 20 -----OPERATES AS A SLAVE DESERIALIER
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  U_ELK20_CH : ELINK_SLAVE
    port map (
      CLK_40M_GL   => CLK_40M_GL,       -- CCC#1 FIXED 40MHZ CLOCK OUT
      CCC_160M_FXD => CCC_160M_FXD,     -- CCC#1 FIXED 160MHZ CLOCK
      CCC_160M_ADJ => CCC_160M_ADJ,     -- CCC#2 ADJ 160MHZ CLOCK

      DEV_RST_B         => DEV_RST_B,  -- ACTIVE LOW ASYNC RESET --DEDICATED COMET BOARD RC TIME CONSTANT
      MASTER_POR_B      => MASTER_POR_B,      -- MASTER_POR_B
      MASTER_DCB_POR_B  => MASTER_DCB_POR_B,  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR DCB CONFIGS
      MASTER_SALT_POR_B => MASTER_SALT_POR_B,  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR SALT CONFIGS

      DCB_SALT_SEL => DCB_SALT_SEL,  -- '1'= DCB MODE (IE TFC MASTER TX ENABLED) // '0'=SALT HYBRID MODE (IE TFC MASTER RX W/ SYNC MODE ENABLED)

      OP_MODE1_SPE => OP_MODE(1),        -- OP_MODE BIT 1 = SYNC PATT EN
      F_ALIGN_PATT => F_ALIGN_PATT,      -- FIXED SYNC / ALIGNMENT PATTERN BYTE
      PATT_ELK_DAT => PATT_ELK_DAT(19),  -- ELINK PATTERN TX DATA

      BIT_OS_SEL => BIT_OS_SEL,  -- BIT ALIGNMENT OFFSET VALUE DETERMINED BY MASTER DES320M AND USE DY ALL SLAVES

      ELK_DAT_P => ELK20_DAT_P,     -- SERIAL LVDS ELINK0 DATA BIDIR PORT
      ELK_DAT_N => ELK20_DAT_N,     -- ""

      ELK_RX_SER_WORD => ELK_RX_SER_WORD(20)  -- OUTPUT WORD OF THE ELINK DE-SERIALIZER
      );


--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ELINK 21 -----OPERATES AS A SLAVE DESERIALIER
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  U_ELK21_CH : ELINK_SLAVE
    port map (
      CLK_40M_GL   => CLK_40M_GL,       -- CCC#1 FIXED 40MHZ CLOCK OUT
      CCC_160M_FXD => CCC_160M_FXD,     -- CCC#1 FIXED 160MHZ CLOCK
      CCC_160M_ADJ => CCC_160M_ADJ,     -- CCC#2 ADJ 160MHZ CLOCK

      DEV_RST_B         => DEV_RST_B,  -- ACTIVE LOW ASYNC RESET --DEDICATED COMET BOARD RC TIME CONSTANT
      MASTER_POR_B      => MASTER_POR_B,      -- MASTER_POR_B
      MASTER_DCB_POR_B  => MASTER_DCB_POR_B,  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR DCB CONFIGS
      MASTER_SALT_POR_B => MASTER_SALT_POR_B,  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR SALT CONFIGS

      DCB_SALT_SEL => DCB_SALT_SEL,  -- '1'= DCB MODE (IE TFC MASTER TX ENABLED) // '0'=SALT HYBRID MODE (IE TFC MASTER RX W/ SYNC MODE ENABLED)

      OP_MODE1_SPE => OP_MODE(1),        -- OP_MODE BIT 1 = SYNC PATT EN
      F_ALIGN_PATT => F_ALIGN_PATT,      -- FIXED SYNC / ALIGNMENT PATTERN BYTE
      PATT_ELK_DAT => PATT_ELK_DAT(19),  -- ELINK PATTERN TX DATA

      BIT_OS_SEL => BIT_OS_SEL,  -- BIT ALIGNMENT OFFSET VALUE DETERMINED BY MASTER DES320M AND USE DY ALL SLAVES

      ELK_DAT_P => ELK21_DAT_P,     -- SERIAL LVDS ELINK0 DATA BIDIR PORT
      ELK_DAT_N => ELK21_DAT_N,     -- ""

      ELK_RX_SER_WORD => ELK_RX_SER_WORD(21)  -- OUTPUT WORD OF THE ELINK DE-SERIALIZER
      );


--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ELINK 22 -----OPERATES AS A SLAVE DESERIALIER
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  U_ELK22_CH : ELINK_SLAVE
    port map (
      CLK_40M_GL   => CLK_40M_GL,       -- CCC#1 FIXED 40MHZ CLOCK OUT
      CCC_160M_FXD => CCC_160M_FXD,     -- CCC#1 FIXED 160MHZ CLOCK
      CCC_160M_ADJ => CCC_160M_ADJ,     -- CCC#2 ADJ 160MHZ CLOCK

      DEV_RST_B         => DEV_RST_B,  -- ACTIVE LOW ASYNC RESET --DEDICATED COMET BOARD RC TIME CONSTANT
      MASTER_POR_B      => MASTER_POR_B,      -- MASTER_POR_B
      MASTER_DCB_POR_B  => MASTER_DCB_POR_B,  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR DCB CONFIGS
      MASTER_SALT_POR_B => MASTER_SALT_POR_B,  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR SALT CONFIGS

      DCB_SALT_SEL => DCB_SALT_SEL,  -- '1'= DCB MODE (IE TFC MASTER TX ENABLED) // '0'=SALT HYBRID MODE (IE TFC MASTER RX W/ SYNC MODE ENABLED)

      OP_MODE1_SPE => OP_MODE(1),        -- OP_MODE BIT 1 = SYNC PATT EN
      F_ALIGN_PATT => F_ALIGN_PATT,      -- FIXED SYNC / ALIGNMENT PATTERN BYTE
      PATT_ELK_DAT => PATT_ELK_DAT(19),  -- ELINK PATTERN TX DATA

      BIT_OS_SEL => BIT_OS_SEL,  -- BIT ALIGNMENT OFFSET VALUE DETERMINED BY MASTER DES320M AND USE DY ALL SLAVES

      ELK_DAT_P => ELK22_DAT_P,     -- SERIAL LVDS ELINK0 DATA BIDIR PORT
      ELK_DAT_N => ELK22_DAT_N,     -- ""

      ELK_RX_SER_WORD => ELK_RX_SER_WORD(22)  -- OUTPUT WORD OF THE ELINK DE-SERIALIZER
      );


--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ELINK 23 -----OPERATES AS A SLAVE DESERIALIER
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  U_ELK23_CH : ELINK_SLAVE
    port map (
      CLK_40M_GL   => CLK_40M_GL,       -- CCC#1 FIXED 40MHZ CLOCK OUT
      CCC_160M_FXD => CCC_160M_FXD,     -- CCC#1 FIXED 160MHZ CLOCK
      CCC_160M_ADJ => CCC_160M_ADJ,     -- CCC#2 ADJ 160MHZ CLOCK

      DEV_RST_B         => DEV_RST_B,  -- ACTIVE LOW ASYNC RESET --DEDICATED COMET BOARD RC TIME CONSTANT
      MASTER_POR_B      => MASTER_POR_B,      -- MASTER_POR_B
      MASTER_DCB_POR_B  => MASTER_DCB_POR_B,  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR DCB CONFIGS
      MASTER_SALT_POR_B => MASTER_SALT_POR_B,  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR SALT CONFIGS

      DCB_SALT_SEL => DCB_SALT_SEL,  -- '1'= DCB MODE (IE TFC MASTER TX ENABLED) // '0'=SALT HYBRID MODE (IE TFC MASTER RX W/ SYNC MODE ENABLED)

      OP_MODE1_SPE => OP_MODE(1),        -- OP_MODE BIT 1 = SYNC PATT EN
      F_ALIGN_PATT => F_ALIGN_PATT,      -- FIXED SYNC / ALIGNMENT PATTERN BYTE
      PATT_ELK_DAT => PATT_ELK_DAT(19),  -- ELINK PATTERN TX DATA

      BIT_OS_SEL => BIT_OS_SEL,  -- BIT ALIGNMENT OFFSET VALUE DETERMINED BY MASTER DES320M AND USE DY ALL SLAVES

      ELK_DAT_P => ELK23_DAT_P,     -- SERIAL LVDS ELINK0 DATA BIDIR PORT
      ELK_DAT_N => ELK23_DAT_N,     -- ""

      ELK_RX_SER_WORD => ELK_RX_SER_WORD(23)  -- OUTPUT WORD OF THE ELINK DE-SERIALIZER
      );



--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- INSTANTIATE THE MODULE CONTAINING THE USB HOST AND STORAGE INTERFACES
  U50_PATTERNS : USB_INTERFACE
    port map (
      CLK60MHZ      => CLK60MHZ,        -- 
      RESETB        => USB_MASTER_EN,  -- ENABLE THE VHDL MODULE AFTER THE PHY USB MODULE IS GENERATING A STABLE 60 MHZ CLOCK
      MASTER_POR_B  => MASTER_POR_B,  -- RESET SYNCHRONOUS TO THE 160 MHZ AND 40 MHZ CLOCKS
      CLK_40MHZ_GEN => CLK_40M_GL,      -- 

      -- USB INTERFACE SIGNALS (SYNCHRONOUS TO CLK60MHZ)
      BIDIR_USB_ADBUS => BIDIR_USB_ADBUS,  -- 
      USB_OE_B        => USB_OE_BI,        -- 

      P_USB_RXF_B => P_USB_RXF_B,       -- 
      USB_RD_B    => USB_RD_BI,         -- 

      P_USB_TXE_B => P_USB_TXE_B,       -- 
      USB_WR_B    => USB_WR_BI,         -- 

      USB_SIWU_B      => USB_SIWU_BI,   -- 
                                        -- 
      -- EXTERNAL PATTERN GEN INTERFACES (SYNCHRONOUS TO CLK_40MHZ_GEN)
      P_TFC_STRT_ADDR => TFC_STRT_ADDR,    -- 
      P_TFC_STOP_ADDR => TFC_STOP_ADDR,    -- 
      TFC_ADDRB       => TFC_ADDRB,  -- TFC ADDR INPUTS FOR THE B PORT PATT GEN SIDE
      TFC_RAM_BLKB_EN => TFC_RAM_BLKB_EN,  -- 
      P_TFC_ADDR8B    => TFC_ACT_BLK_SEL,  -- TFC ACTIVE BLOCK SELECT FOR THE TFC RAM BANK
      TFC_DAT_OUT     => PATT_TFC_DAT,  -- TFC RAM BLOCK PORT B DATA OUT
      TFC_DAT_IN      => TFC_RX_SER_WORD,  -- TFC RAM BLOCK PORT B DATA IN
      TFC_RWB         => TFC_RWB,       -- TFC R/W FOR THE RAM B-PORT

                                        -- SIGNALS COMMON TO ALL ELINKS
      P_ELINKS_STRT_ADDR => ELKS_STRT_ADDR,    -- 
      P_ELINKS_STOP_ADDR => ELKS_STOP_ADDR,    -- 
      ELINK_ADDRB        => ELKS_ADDRB,  -- ADDR INPUTS FOR THE B PORT PATT GEN SIDE
      ELINK_PATT_GEN_EN  => ELKS_RAM_BLKB_EN,  -- TFC ACTIVE BLOCK SELECT FOR THE TFC RAM BANK(ACTIVE LOW SIGNAL)
      P_ELINK_ADDR8B     => ELKS_ACT_BLK_SEL,  -- ELINKS ACTIVE BLOCK SELECT FOR THE ELINKS RAM BANK
      ELINK_RWB          => ELKS_RWB,   -- COMMON ELINK R/W FOR THE RAM B-PORTS

      ELINK0_DAT_OUT => PATT_ELK_DAT(0),     -- 
      ELINK0_DAT_IN  => ELK_RX_SER_WORD(0),  -- ELINK0 RAM BLOCK PORT B DATA IN

      ELINK1_DAT_OUT => PATT_ELK_DAT(1),     -- 
      ELINK1_DAT_IN  => ELK_RX_SER_WORD(1),  -- ELINK1 RAM BLOCK PORT B DATA IN

      ELINK2_DAT_OUT => PATT_ELK_DAT(2),     -- 
      ELINK2_DAT_IN  => ELK_RX_SER_WORD(2),  -- ELINK2 RAM BLOCK PORT B DATA IN

      ELINK3_DAT_OUT => PATT_ELK_DAT(3),     -- 
      ELINK3_DAT_IN  => ELK_RX_SER_WORD(3),  -- ELINK3 RAM BLOCK PORT B DATA IN

      ELINK4_DAT_OUT => PATT_ELK_DAT(4),     -- 
      ELINK4_DAT_IN  => ELK_RX_SER_WORD(4),  -- ELINK4 RAM BLOCK PORT B DATA IN

      ELINK5_DAT_OUT => PATT_ELK_DAT(5),     -- 
      ELINK5_DAT_IN  => ELK_RX_SER_WORD(5),  -- ELINK5 RAM BLOCK PORT B DATA IN

      ELINK6_DAT_OUT => PATT_ELK_DAT(6),     -- 
      ELINK6_DAT_IN  => ELK_RX_SER_WORD(6),  -- ELINK6 RAM BLOCK PORT B DATA IN

      ELINK7_DAT_OUT => PATT_ELK_DAT(7),     -- 
      ELINK7_DAT_IN  => ELK_RX_SER_WORD(7),  -- ELINK7 RAM BLOCK PORT B DATA IN

      ELINK8_DAT_OUT => PATT_ELK_DAT(8),     -- 
      ELINK8_DAT_IN  => ELK_RX_SER_WORD(8),  -- ELINK8 RAM BLOCK PORT B DATA IN

      ELINK9_DAT_OUT => PATT_ELK_DAT(9),     -- 
      ELINK9_DAT_IN  => ELK_RX_SER_WORD(9),  -- ELINK9 RAM BLOCK PORT B DATA IN

      ELINK10_DAT_OUT => PATT_ELK_DAT(10),     -- 
      ELINK10_DAT_IN  => ELK_RX_SER_WORD(10),  -- ELINK10 RAM BLOCK PORT B DATA IN

      ELINK11_DAT_OUT => PATT_ELK_DAT(11),     -- 
      ELINK11_DAT_IN  => ELK_RX_SER_WORD(11),  -- ELINK11 RAM BLOCK PORT B DATA IN

      ELINK12_DAT_OUT => PATT_ELK_DAT(12),     -- 
      ELINK12_DAT_IN  => ELK_RX_SER_WORD(12),  -- ELINK12 RAM BLOCK PORT B DATA IN

      ELINK13_DAT_OUT => PATT_ELK_DAT(13),     -- 
      ELINK13_DAT_IN  => ELK_RX_SER_WORD(13),  -- ELINK13 RAM BLOCK PORT B DATA IN

      ELINK14_DAT_OUT => PATT_ELK_DAT(14),     -- 
      ELINK14_DAT_IN  => ELK_RX_SER_WORD(14),  -- ELINK14 RAM BLOCK PORT B DATA IN

      ELINK15_DAT_OUT => PATT_ELK_DAT(15),     -- 
      ELINK15_DAT_IN  => ELK_RX_SER_WORD(15),  -- ELINK15 RAM BLOCK PORT B DATA IN

      ELINK16_DAT_OUT => PATT_ELK_DAT(16),     -- 
      ELINK16_DAT_IN  => ELK_RX_SER_WORD(16),  -- ELINK16 RAM BLOCK PORT B DATA IN

      ELINK17_DAT_OUT => PATT_ELK_DAT(17),     -- 
      ELINK17_DAT_IN  => ELK_RX_SER_WORD(17),  -- ELINK17 RAM BLOCK PORT B DATA IN

      ELINK18_DAT_OUT => PATT_ELK_DAT(18),     -- 
      ELINK18_DAT_IN  => ELK_RX_SER_WORD(18),  -- ELINK18 RAM BLOCK PORT B DATA IN

      ELINK19_DAT_OUT => PATT_ELK_DAT(19),     -- 
      ELINK19_DAT_IN  => ELK_RX_SER_WORD(19),  -- ELINK19 RAM BLOCK PORT B DATA IN

      P_OP_MODE => OP_MODE              -- 
      );

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- INSTANTIATE TRI-STATE BUFFERS FOR ALL USB CONTROL LINES THAT ARE HELD IN TRI-STATE UNTIL THE USB MODULE IS ENABLED
  U60_TS_RD_BUF : tristate_buf
    port map (
      Data  => USB_RD_BI,
      Trien => USB_MASTER_EN,
      PAD   => USB_RD_B
      );

  U61_TS_WR_BUF : tristate_buf
    port map (
      Data  => USB_WR_BI,
      Trien => USB_MASTER_EN,
      PAD   => USB_WR_B
      );

  U62_TS_OE_BUF : tristate_buf
    port map (
      Data  => USB_OE_BI,
      Trien => USB_MASTER_EN,
      PAD   => USB_OE_B
      );

  U63_TS_SIWU_BUF : tristate_buf
    port map (
      Data  => USB_SIWU_BI,
      Trien => USB_MASTER_EN,
      PAD   => USB_SIWU_B
      );

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--PATTERN GENERATOR FOR THE TFC SEQUENCE
-- CONTROLS BOTH THE TX AND RX OPERATIONS!
  U200A_TFC : GP_PATT_GEN
    port map (
      CLK_40MHZ_GEN => CLK_40M_GL,
      RESET_B       => MASTER_POR_B,    -- POR SYNCHRONIZED TO LOCAL CLOCKS
      USB_MASTER_EN => USB_MASTER_EN,  -- '1' SIGNIFIES THAT THE USB MODULE IS NOW ACTIVE

      STRT_ADDR   => TFC_STRT_ADDR,
      STOP_ADDR   => TFC_STOP_ADDR,
      ACT_BLK_SEL => TFC_ACT_BLK_SEL,  -- SELECTS THE UPPER OR LOWER BLOCK OF THE RAM BANK
      DIR_MODE    => DCB_SALT_SEL,  -- DEDICATED TFC PATTERN TX OR RX SELECT BIT ('1'= TX MODE, '0'= RX MODE)

      ALIGN_PATT  => F_ALIGN_PATT,      -- FIXED ALIGNMENT PATTERN
      RX_SER_WORD => TFC_RX_SER_WORD,  -- RECEIVED TFC SERIAL BYTE STREAM--USED TO SYNCHRONIZE DATA FLOW.

      GP_PATT_GEN_EN => OP_MODE(2),  -- OP_MODE(2)--> '1'= TFC TX/RX FUNCTION ENABLE
      REPEAT_EN      => OP_MODE(0),  -- DEDICATED TFC PATTERN REPEAT/SINGLE-SHOT SELECT
      ALIGN_ACTIVE   => ALIGN_ACTIVE,  -- USED AN A QUALIFYING ENABLE OF THE PATTERN GENERATION FUNCTION

      RAM_ADDR => TFC_ADDRB,
      RAM_BLKB => TFC_RAM_BLKB_EN,
      RAM_RWB  => TFC_RWB
      );
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--PATTERN GENERATOR FOR THE ELINKS SEQUENCE
-- CONTROLS BOTH THE TX AND RX OPERATIONS!
-- ONLY USES ELINK0 TO SYNC THE DATA FLOW
  U200B_ELINKS : GP_PATT_GEN
    port map (
      CLK_40MHZ_GEN => CLK_40M_GL,
      RESET_B       => MASTER_POR_B,    -- POR SYNCHRONIZED TO LOCAL CLOCKS
      USB_MASTER_EN => USB_MASTER_EN,  -- '1' SIGNIFIES THAT THE USB MODULE IS NOW ACTIVE

      STRT_ADDR   => ELKS_STRT_ADDR,    -- COMMON START ADDRESS FOR ALL ELINKS
      STOP_ADDR   => ELKS_STOP_ADDR,    -- COMMON STOP ADDRESS FOR ALL ELINKS
      ACT_BLK_SEL => ELKS_ACT_BLK_SEL,  -- SELECTS THE UPPER OR LOWER BLOCK OF THE RAM BANK
      DIR_MODE    => not(DCB_SALT_SEL),  -- DEDICATED ELINKS PATTERN TX OR RX SELECT BIT ('1'= TX MODE, '0'= RX MODE)

      ALIGN_PATT  => F_ALIGN_PATT,      -- FIXED ALIGNMENT PATTERN
      RX_SER_WORD => ELK_RX_SER_WORD(0),  -- RECEIVED MASTER ELINK0 SERIAL BYTE STREAM--USED TO SYNCHRONIZE DATA FLOW.

      GP_PATT_GEN_EN => OP_MODE(6),  -- OP_MODE(6)--> '1'= ELINKS TX/RX FUNCTION ENABLE
      REPEAT_EN      => OP_MODE(4),  -- DEDICATED ELINK PATTERN REPEAT/SINGLE-SHOT SELECT
      ALIGN_ACTIVE   => ALIGN_ACTIVE,  -- USED AN A QUALIFYING ENABLE OF THE PATTERN GENERATION FUNCTION

      RAM_ADDR => ELKS_ADDRB,
      RAM_BLKB => ELKS_RAM_BLKB_EN,
      RAM_RWB  => ELKS_RWB
      );

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- SYNC STATUS PROCESS:  FLAGS='1' WHEN RECEIVE WORDS ARE 8E HEX
  SYNC_STAT_DET : process(CLK_40M_GL, MASTER_POR_B)
  begin
    if MASTER_POR_B = '0' then
      ELK0_SYNC_DET <= '0';
      TFC_SYNC_DET  <= '0';
    elsif (CLK_40M_GL'event and CLK_40M_GL = '1') then
      ELK0_SYNC_DET <= ELK_RX_SER_WORD(0)(7) and not(ELK_RX_SER_WORD(0)(6)) and not(ELK_RX_SER_WORD(0)(5)) and not(ELK_RX_SER_WORD(0)(4)) and
                       ELK_RX_SER_WORD(0)(3) and ELK_RX_SER_WORD(0)(2) and ELK_RX_SER_WORD(0)(1) and not(ELK_RX_SER_WORD(0)(0));

      TFC_SYNC_DET <= TFC_RX_SER_WORD(7) and not(TFC_RX_SER_WORD(6)) and not(TFC_RX_SER_WORD(5)) and not(TFC_RX_SER_WORD(4)) and
                      TFC_RX_SER_WORD(3) and TFC_RX_SER_WORD(2) and TFC_RX_SER_WORD(1) and not(TFC_RX_SER_WORD(0));

    end if;
  end process SYNC_STAT_DET;

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- CONNECT INTERNAL SIGNALS TO EXTERNAL PORTS
  ALL_PLL_LOCK    <= CCC_RX_CLK_LOCK and CCC_MAIN_LOCK;  -- BOTH ARE ACTIVE HIGH FOR LOCK CONDITION TRUE
  P_MASTER_POR_B  <= MASTER_POR_B;  -- THIS IS THE NON-GLOBAL BUFFER VERSION
  P_USB_MASTER_EN <= USB_MASTER_EN;
  P_CLK_40M_GL    <= CLK_40M_GL;
  P_CCC_160M_FXD  <= CCC_160M_FXD;
  P_CCC_160M_ADJ  <= CCC_160M_ADJ;

  P_ELK0_SYNC_DET <= ELK0_SYNC_DET;
  P_TFC_SYNC_DET  <= TFC_SYNC_DET;

  P_OP_MODE1_SPE <= OP_MODE(1);         -- I2C_SCLK_1---SYNC PATT EN
  P_OP_MODE2_TE  <= OP_MODE(2);         -- I2C_SDAT_1---TFC EN
  P_OP_MODE5_AAE <= OP_MODE(5);         -- I2C_SCLK_2---AUTO ALIGN EN
  P_OP_MODE6_EE  <= OP_MODE(6);         -- I2C_SDAT_2---ELINKS EN


end RTL;
