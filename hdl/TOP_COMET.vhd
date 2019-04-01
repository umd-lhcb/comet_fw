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
-- 			THE TFC AND ELINK0 CHANNELS OPERATE AS 'MASTERS' WITH ACTIVE TIMING DESKEW ON RX
--			THE REMAINDER OF THE ELINKS OPERATE AS SLAVES WITH TIME OFFSETS RELATIVE TO THE MASTERS.
--
-- Targeted device: <Family::ProASIC3E> <Die::A3PE1500> <Package::208 PQFP>
-- Author: TOM O'BANNON
--
--##################################################################################################################################
--# !!!!! NOTE !!!!! FPGA_STV_D PAIRS:  23,     22,     19,     20      .......  
--#                  ...ON FPGA PINS:   91/90,  87/86,  85/84,  164/165 ARE FLIPPED (IE INVERTED) ON THE PASSIVE TERMINATION DAUGHTER BOARD
--#					 ...FOR ELINKS:		0,		1,		4,		3  (ELINK0 IS A MASTER ADDRESSED BELOW, WHEREAS THE OTHER 3 ARE HANDLED VIA ELINK_SLAVE_INV.VHD)
--#                  SO, THE SIGNAL ASSIGNMENTS BELOW FOR THESE SPECIFIC PAIRS ARE INVERTED.
--#                  THE INVERSION NEEDS TO BE DONE IN THE LOGIC RATHER THAN PINS SWAPS SINCE PHYSICAL LIBRARY MACROS ARE BEING INSTANTIATED.
--##################################################################################################################################
-- CAUTION:  SIM_MODE CONSTANT NEEDS TO BE MANUALLY UPDATED!!!!!
--------------------------------------------------------------------------------

library IEEE;

use IEEE.std_logic_1164.all;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.STD_LOGIC_MISC.ALL;

library proasic3e;
use proasic3e.all;

library synplify;
use synplify.attributes.all;

entity TOP_COMET is
port (
        CLK200_P            :   IN  STD_LOGIC;                          -- EXTERNAL LVDS CLOCK ON COMET BOARDS
        CLK200_N            :   IN  STD_LOGIC;

        DEV_RST_B           :   IN  STD_LOGIC;                          -- ACTIVE LOW RESET --DEDICATED COMET BOARD RC TIME CONSTANT

-- GPIO TEST AND CONFIG SIGNALS
        DCB_SALT_SEL        :   IN  STD_LOGIC;                          -- GPIO_0:  '1'= DCB MODE (IE TFC MASTER TX ENABLED) // '0'=SALT HYBRID MODE (IE TFC MASTER RX W/ SYNC MODE ENABLED)
        EXTCLK_40MHZ        :   OUT  STD_LOGIC;                         -- GPIO_1:  40 MHZ CLOCK- RX VAL FOR SALT, TX VAL FOR DCB CONFIG
        EXT_INT_REF_SEL     :   IN  STD_LOGIC;                          -- GPIO_9   '1' = CCC USE REC'D REF CLOCKS, '0' BOARD TRANSMITS REF CLOCK SIGNALS

        ALL_PLL_LOCK        :   OUT STD_LOGIC;                          -- GPIO_10: LOCK STATUS OF BOTH CCC#1 (FIXED) AND CCC #2 (DYNAMIC CLOCK USED FOR THE DESERIALIZER RX)
        P_MASTER_POR_B      :   OUT STD_LOGIC;                          -- GPIO_2:  MASTER_POR_B
        P_USB_MASTER_EN     :   OUT STD_LOGIC;                          -- GPIO_7:  USB_MASTER_EN
-- SPARE     :   OUT STD_LOGIC;                          -- GPIO_3:  
        P_CLK_40M_GL        :   OUT STD_LOGIC;                          -- GPIO_4:  CCC#1 FIXED CLOCK OUT
-- SPARE        P_CLK_PH1_160MHZ    :   OUT STD_LOGIC;                          -- GPIO_8:  CCC#1 FIXED CLOCK OUT
        P_CCC_160M_FXD      :   OUT STD_LOGIC;                          -- GPIO_6:  CCC#1 FIXED 160MHZ CLOCK
        P_CCC_160M_ADJ      :   OUT STD_LOGIC;                          -- GPIO_5:  CCC#2 ADJ 160MHZ CLOCK

-- I2C PORT CONN BEING USED FOR STATUS
        P_ELK0_SYNC_DET     :   OUT STD_LOGIC;                          -- I2C_SDAT_0
        P_TFC_SYNC_DET      :   OUT STD_LOGIC;                          -- I2C_SCLK_0

        P_OP_MODE1_SPE      :   OUT STD_LOGIC;                          -- I2C_SCLK_1---SYNC PATT EN
        P_OP_MODE2_TE       :   OUT STD_LOGIC;                          -- I2C_SDAT_1---TFC EN
        P_OP_MODE5_AAE      :   OUT STD_LOGIC;                          -- I2C_SCLK_2---AUTO ALIGN EN
        P_OP_MODE6_EE       :   OUT STD_LOGIC;                          -- I2C_SDAT_2---ELINKS EN

-- THESE SIGNALS USE THE CAT6 I/O CONN'S TO PASS REF CLOCKS BETWEEN COMET FPGA'S
        BIDIR_CLK40M_P      :   INOUT   STD_LOGIC;                      -- 40 MHZ REF CLOCK FOR CCC#1: EITHER LOCAL OSC OR EXTERNAL REC'D DIFF CLOCK SOURCE
        BIDIR_CLK40M_N      :   INOUT   STD_LOGIC;                      -- 40 MHZ REF CLOCK FOR CCC#1: EITHER LOCAL OSC OR EXTERNAL REC'D DIFF CLOCK SOURCE
		
		TX_CLK40M_P			:	OUT		STD_LOGIC;						-- TX DISTRIBUTION COPY OF 40 MHZ REF CLOCK FOR CCC#1
		TX_CLK40M_N			:	OUT		STD_LOGIC;

-- IO RELATED TO USB INTERFACE (SYNCHRONOUS TO THE USB 60 MHZ CLOCK)
        USBCLK60MHZ         :   IN      STD_LOGIC;                      -- CLOCK FROM THE USM MODULE DERIVED FROM A 12MHZ CRYSTAL ON-BOARD THE USB MODULE PLL

        BIDIR_USB_ADBUS     :   INOUT   STD_LOGIC_VECTOR(7 DOWNTO 0);   -- USB:  BI-DIRECTIONAL ADDRESS AND DATA BUS
        USB_OE_B            :   OUT     STD_LOGIC;                      -- USB:  ACTIVE LOW TURNS ON THE USB DATA BUS OUTPUT MODE

        P_USB_RXF_B         :   IN      STD_LOGIC;                      -- USB:  ACTIVE LOW SIGNIFIES THAT THE ON-BOARD USB FIFO HAS DATA TO BE READ (IE READ TRANSFER REQUEST)
        USB_RD_B            :   OUT     STD_LOGIC;                      -- USB:  ACTIVE LOW STATE FETCHES NEXT BYTE FROM THE FIFO ON THE NEXT CLK60MHZ CLOCK EDGE

        P_USB_TXE_B         :   IN      STD_LOGIC;                      -- USB:  ACTIVE LOW SIGNIFIES THAT THE ON-BOARD USB FIFO CAN NOW ACCEPT DATA (IE WRITE TRANSFER ENABLED)
        USB_WR_B            :   OUT     STD_LOGIC;                      -- USB:  ACTIVE LOW STATE ENABLE DATA TO BE WRITTEN TO THE FIFO ON THE NEXT CLK60MHZ CLOCK EDGE

        USB_SIWU_B          :   OUT     STD_LOGIC;                      -- USB:  ACTIVE LOW--Send Immediate / WakeUp signal (CAN BE USED TO OPTIMIZE DATA TRANSFER RATES)
                                                                        -- TIE HIGH IF NOT USED
-- STAVE IO VIA DAUGHTER BOARDS AND ERM8 CONNS
-- PORT DIRECTIONS DETERMINED BY DCB_SALT_SEL JUMPER
        TFC_DAT_0P          :   INOUT STD_LOGIC;                        -- SERIAL LVDS TFC COMMAND BIDIR PORT
        TFC_DAT_0N          :   INOUT STD_LOGIC; 
        REF_CLK_0P          :   INOUT STD_LOGIC;                        -- 40 MHZ REF CLK LVDS BIDIR PORT SYNCHRONOUS TO THE TCF OUTPUT BYTE RATE.  
        REF_CLK_0N          :   INOUT STD_LOGIC;                        -- DCB MODE TRANSMITS THE REFCLK, SALT MODE RECEIVES THE REFCLK

        ELK0_DAT_P         	:   INOUT STD_LOGIC;                        -- SERIAL LVDS ELINK0 DATA BIDIR PORT
        ELK0_DAT_N         	:   INOUT STD_LOGIC;

        ELK1_DAT_P         	:   INOUT STD_LOGIC;                        -- SERIAL LVDS ELINK1 DATA BIDIR PORT
        ELK1_DAT_N         	:   INOUT STD_LOGIC;
		
        ELK2_DAT_P         	:   INOUT STD_LOGIC;                        -- SERIAL LVDS ELINK2 DATA BIDIR PORT
        ELK2_DAT_N         	:   INOUT STD_LOGIC;

        ELK3_DAT_P         	:   INOUT STD_LOGIC;                        -- SERIAL LVDS ELINK3 DATA BIDIR PORT
        ELK3_DAT_N         	:   INOUT STD_LOGIC;

        ELK4_DAT_P         	:   INOUT STD_LOGIC;                        -- SERIAL LVDS ELINK4 DATA BIDIR PORT
        ELK4_DAT_N         	:   INOUT STD_LOGIC;

        ELK5_DAT_P         	:   INOUT STD_LOGIC;                        -- SERIAL LVDS ELINK5 DATA BIDIR PORT
        ELK5_DAT_N         	:   INOUT STD_LOGIC;

        ELK6_DAT_P         	:   INOUT STD_LOGIC;                        -- SERIAL LVDS ELINK6 DATA BIDIR PORT
        ELK6_DAT_N         	:   INOUT STD_LOGIC;

        ELK7_DAT_P         	:   INOUT STD_LOGIC;                        -- SERIAL LVDS ELINK7 DATA BIDIR PORT
        ELK7_DAT_N         	:   INOUT STD_LOGIC;

        ELK8_DAT_P         	:   INOUT STD_LOGIC;                        -- SERIAL LVDS ELINK8 DATA BIDIR PORT
        ELK8_DAT_N         	:   INOUT STD_LOGIC;

        ELK9_DAT_P         	:   INOUT STD_LOGIC;                        -- SERIAL LVDS ELINK9 DATA BIDIR PORT
        ELK9_DAT_N         	:   INOUT STD_LOGIC;

        ELK10_DAT_P         :   INOUT STD_LOGIC;                        -- SERIAL LVDS ELINK10 DATA BIDIR PORT
        ELK10_DAT_N        	:   INOUT STD_LOGIC;

        ELK11_DAT_P         :   INOUT STD_LOGIC;                        -- SERIAL LVDS ELINK11 DATA BIDIR PORT
        ELK11_DAT_N         :   INOUT STD_LOGIC;

        ELK12_DAT_P         :   INOUT STD_LOGIC;                        -- SERIAL LVDS ELINK12 DATA BIDIR PORT
        ELK12_DAT_N         :   INOUT STD_LOGIC;

        ELK13_DAT_P         :   INOUT STD_LOGIC;                        -- SERIAL LVDS ELINK13 DATA BIDIR PORT
        ELK13_DAT_N         :   INOUT STD_LOGIC;

        ELK14_DAT_P         :   INOUT STD_LOGIC;                        -- SERIAL LVDS ELINK14 DATA BIDIR PORT
        ELK14_DAT_N         :   INOUT STD_LOGIC;

        ELK15_DAT_P         :   INOUT STD_LOGIC;                        -- SERIAL LVDS ELINK15 DATA BIDIR PORT
        ELK15_DAT_N         :   INOUT STD_LOGIC;

        ELK16_DAT_P         :   INOUT STD_LOGIC;                        -- SERIAL LVDS ELINK16 DATA BIDIR PORT
        ELK16_DAT_N         :   INOUT STD_LOGIC;

        ELK17_DAT_P         :   INOUT STD_LOGIC;                        -- SERIAL LVDS ELINK17 DATA BIDIR PORT
        ELK17_DAT_N         :   INOUT STD_LOGIC;

        ELK18_DAT_P         :   INOUT STD_LOGIC;                        -- SERIAL LVDS ELINK18 DATA BIDIR PORT
        ELK18_DAT_N         :   INOUT STD_LOGIC;

        ELK19_DAT_P         :   INOUT STD_LOGIC;                        -- SERIAL LVDS ELINK19 DATA BIDIR PORT
        ELK19_DAT_N         :   INOUT STD_LOGIC

		);

end TOP_COMET;

architecture RTL of TOP_COMET is

-- NOTE:  THE AP3E 208QFP HAS A MAXIMUM OF 6 GLOBAL BUFFERS.  EACH QUADRANT HAS 3 ADDITIONAL GLOBAL QUADRANT BUFFERS.
attribute syn_global_buffers : integer;
attribute syn_global_buffers of RTL : architecture is 7;
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- DEFINE THE COMPONENTS:
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

----------------------------------------------------------------        
-- LVDS INPUT BUFFER
COMPONENT LVDS_CLK_IN
    port( 
            PADP            : in    std_logic;
            PADN            : in    std_logic;
            Y               : out   std_logic
        );
END COMPONENT;

-- LVDS OUTPUT BUFFER
COMPONENT LVDS_BUFOUT

    port( 
			Data 		: in    std_logic;
			PADP 		: out   std_logic;
			PADN 		: out   std_logic
        );
END COMPONENT;
----------------------------------------------------------------
-- SPECIAL BIDIRECTIONAL LVDS DUAL CLOCK DDR BLOCK (IE RX AND TX CLOCKS ARE SEPARATE)
COMPONENT DDR_BIDIR_LVDS_DUAL_CLK is
    port(
            DDR_CLR     : in    std_logic;
            DDR_DIR     : in    std_logic;
            DDR_TX_CLK  : in    std_logic;
            DDR_TX_R    : in    std_logic;
            DDR_TX_F    : in    std_logic;
            DDR_RX_CLK  : in    std_logic;
            DDR_RX_R    : out   std_logic;
            DDR_RX_F    : out   std_logic;
            PADP        : inout std_logic;
            PADN        : inout std_logic
        );
END COMPONENT;
----------------------------------------------------------------

COMPONENT BIDIR_LVDS_IO
    port( Data  : in    std_logic;                          -- DATA INPUT FOR THE BUFFER THAT DRIVES THE PADS
          Y     : out   std_logic;                          -- TRANSPARENT BUFFER CONNECTED TO THE PADS DRVING INTO THE FPGA
          Trien : in    std_logic;                          -- TRI-STATE CONTROL ('0' = DRIVER ENABLED)
          PADP  : inout std_logic := 'Z';
          PADN  : inout std_logic := 'Z'
        );
END COMPONENT;

----------------------------------------------------------------
-- SIMPLE LVTTL TRI-STATE BUFFER WITH ACTIVE HIGH ENABLE, 24 MA DRIVE, HIGH SLEW, WEAK PULLUP (~30K)
COMPONENT tristate_buf
    port(   Data  : in    std_logic;
            Trien : in    std_logic;
            PAD   : out   std_logic
        );
END COMPONENT;

----------------------------------------------------------------
-- EXECUTIVE POWER UP CONFIGURATOR--DETERMINES DCB OR SALT CONFIG AT INITIAL POWER ON
COMPONENT EXEC_MODE_CNTL is
    port(
            CCC_160M_FXD        :   IN  STD_LOGIC;                          -- FIXED 160 MHZ CLOCK SOURCE
            DEV_RST_B           :   IN  STD_LOGIC;                          -- ACTIVE LOW RESET --DEDICATED COMET BOARD RC TIME CONSTANT
            DCB_SALT_SEL        :   IN  STD_LOGIC;                          -- '1'= DCB MODE (IE TFC MASTER TX ENABLED) // '0'=SALT HYBRID MODE (IE TFC MASTER RX W/ SYNC MODE ENABLED)
            CCC_1_LOCK_STAT     :   IN  STD_LOGIC;                          -- LOCK STATUS FROM THE CCC_160M_40M_60M MODULE

            CLK_40MHZ_GEN       :   IN  STD_LOGIC;                          -- CLOCK SYNCHRONOUS TO THE 160MHZ CCC CLOCK FROM THE SERIALIZER
            CLK60MHZ            :   IN  STD_LOGIC;                          -- CLOCK FROM THE USM MODULE DERIVED FROM A 12MHZ CRYSTAL ON-BOARD THE USB MODULE PLL
                                                                            -- THIS CLOCK IS NOT ACTIVE AT POWER ON.  REQUIRES USB HOST ACTION TO ENABLE THE OUTPUT.
            USB_RESET_B         :   OUT STD_LOGIC;                          -- ACTIVE LOW RESET DEDICATED FOR THE USB VHDL STATE MACHINE--SYCHRONOUS RELEASE RELATIVE TO THE 60 MHZ CLOCK

            MASTER_DCB_POR_B    :   OUT STD_LOGIC;                          -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR DCB CONFIGS
            MASTER_SALT_POR_B   :   OUT STD_LOGIC;                          -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR SALT CONFIGS
            MASTER_POR_B        :   OUT STD_LOGIC                           -- SYNCHRONOUS MASTER POR
        );
END COMPONENT;

----------------------------------------------------------------
-- GENERATES A 40 MHZ CLOCK BY DIVIDING THE 200 MHZ BY 5.  DUTY CYCLE IS 40/60.
COMPONENT REF_CLK_DIV_GEN is
    port (
            CLK_200MHZ          :   IN  STD_LOGIC;                  -- 200 MHZ OSCILLATOR SOURCE
            POR_N               :   IN  STD_LOGIC;                  -- ACTIVE LOW POWER-ON RESET
            CLK40M_10NS_REF     :   OUT STD_LOGIC                   -- 40 MHZ WITH 40/60 DUTY CYCLE (IE 0 NS PW) DERIVED FROM 200 MHZ
        );
END COMPONENT;
----------------------------------------------------------------
-- CCC THAT GENERATES FIXED 40 and 160 MHZ CLOCKS AS WELL AS BUFFERS THE 60 MHZ FROM THE USB MODULE.  THE 60 MHZ IS SOURCED BY THE USB MODULE AND IS FULLY ASYCHRONOUS TO THE OTHER CLOCKS
-- !!!!!!!! TIMING NOTES !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- 	THE REF CLOCK AND USB CLOCK SOURCES ARE EXT I/O CONNECTIONS.
--  THE USB 60 MHZ CLOCK ROUTED THRU THE CCC GLOBAL BUFFER NEEDS TO BE DELAYED BY 6.335 NS TO ESTABLISH A PROPER PIPELINE DELAY 
--  THE FIXED 40MHZ OUTPUT HAS 0 NS DELAY
--	THE FIXED 160MHZ OUTPUT HAS A 0.735 NS DELAY
--	THE DELAY OF THE TWO PLL OUTPUTS RELATIVE TO THE TUNABLE 160 MHZ CLOCKS IN CCC#2 ARE ADJUSTED VIA FEEDBACK DELAY SET TO 3.335NS.
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
COMPONENT CLK_FXD_40_160_A60M is

    port( POWERDOWN : in    std_logic;
          CLKA      : in    std_logic;
          LOCK      : out   std_logic;
          GLA       : out   std_logic;
          GLB       : out   std_logic;
          GLC       : out   std_logic;
          SDIN      : in    std_logic;
          SCLK      : in    std_logic;
          SSHIFT    : in    std_logic;
          SUPDATE   : in    std_logic;
          MODE      : in    std_logic;
          SDOUT     : out   std_logic;
          CLKC      : in    std_logic
        );
END COMPONENT;

----------------------------------------------------------------
-- MULTIPLEXOR FOR THE TX SERIAL DATA SOURCE
COMPONENT SYNC_DAT_SEL 
    port (
            CLK40M_GEN          :   IN  STD_LOGIC;                              -- 40 MHZ CLOCK WHERE RISE EDGE IS DELAYED 2.5 NS FROM THE FIXED 160 MHZ RISE EDGE
            RESET_B             :   IN  STD_LOGIC;                              -- ACTIVE LOW RESET    

            ALIGN_MODE_EN       :   IN  STD_LOGIC;                              -- '1' ENABLES THE AUTO BIT AND BYTE ALIGNMENT FUNCTION. PULSED INPUT MUST BE LOW BEFORE ALIGNMENT COMPLETE
            ALIGN_PATT          :   IN  STD_LOGIC_VECTOR(7 DOWNTO 0);           -- PATTERN USED TO DETERMINE ALIGNMENT (EG A5 HEX)

            SER_DAT_IN          :   IN  STD_LOGIC_VECTOR(7 DOWNTO 0);           -- SERIAL DATA BYTE

            P_SERDAT            :   OUT STD_LOGIC_VECTOR(7 DOWNTO 0)            -- SERIAL DATA BYTE FOR TX
    );
END COMPONENT;

----------------------------------------------------------------
-- BASIC 8-BIT PARALLEL-TO-SERIAL TX 
COMPONENT SER320M
    port (
            DDR_160M_CLK        :   IN  STD_LOGIC;                              -- FIXED 160 MHZ DDR CLOCK
            CLK40M_GEN          :   IN  STD_LOGIC;                              -- 40 MHZ CLOCK DERIVED FROM PLL CLOCK DELAYED BY ~2.5NS FROM THE RISING EDGE OF THE FIXED DDR_160M_CLK

            RESET_B             :   IN  STD_LOGIC;                              -- ACTIVE LOW RESET    
            NEXT_SER_CMD_WORD   :   IN  STD_LOGIC_VECTOR(7 DOWNTO 0);           -- 8 BIT COMMAND INPUT WORD    
            SERIAL_TX_EN        :   IN  STD_LOGIC;                              -- ENABLE FOR THE SERIAL TX

            SER_OUT_R           :   OUT STD_LOGIC;                              -- SERIALIZED COMMAND 160MHZ RISE CLOCK DATA-- 12 COPIES
            SER_OUT_F           :   OUT STD_LOGIC                               -- SERIALIZED COMMAND 160MHZ FALL CLOCK DATA-- 12 COPIES
         );
    END COMPONENT;

----------------------------------------------------------------
-- MASTER 8-BIT SERIAL-TO-PARALLEL RX.  
COMPONENT TOP_MASTER_DES320M is
    port    (
                CLK_40M_GL              :   IN  STD_LOGIC;                      -- ON-BOARD CCC1 40 MHZ CLOCK
				CCC_160M_FXD			:	IN	STD_LOGIC;						-- FIXED PHASE 160 MHZ DDR CLOCK

                CLK_40M_BUF_RECD        :   IN  STD_LOGIC;                      -- 40 MHZ REF CLOCK DISTRIBUTED BY THE 'MASTER FPGA' ON THE MASTER DCB CONFIGURED COMET
                MASTER_POR_B            :   IN  STD_LOGIC;                      -- MASTER POWER-ON-RESET: SYNCHRONOUS RESET WAITS FOR CCC1 TO BE LOCKED AND STABLE

                DCB_SALT_SEL            :   IN  STD_LOGIC;                      -- '1'=DCB, '0'=SALT
                ALIGN_MODE_EN           :   IN  STD_LOGIC;                      -- '1'= AUTO ALIGN ENABLED
                SIM_MODE                :   IN  STD_LOGIC;                      -- GPIO_1:  '1' = SIM MODE, '0' = REAL TIME OP MODE

                MAN_BIT_OS              :   IN  STD_LOGIC_VECTOR(3 DOWNTO 0);   -- MANUAL BIT OFFSET ADJUSTMENT (THESE 3 MANUAL MODE INPUTS CAN BE HARD-WIRED INACTIVE AT NEXT LEVEL)
                MAN_PHASE_ADJ           :   IN  STD_LOGIC_VECTOR(4 DOWNTO 0);   -- MANUAL PHASE ADJUSTMENT 
                MAN_AUTO_ALIGN          :   IN  STD_LOGIC;                      -- '1'=MANUAL , '0'= AUTO PHASE ADJ MODE

                ELINK0_DDR_R            :   IN  STD_LOGIC;                      -- ELINK0 DDR RISE SERIAL DATA
                ELINK0_DDR_F            :   IN  STD_LOGIC;                      -- ELINK0 DDR FALL SERIAL DATA
                TFC_DDR_R               :   IN  STD_LOGIC;                      -- TFC DDR RISE SERIAL DATA
                TFC_DDR_F               :   IN  STD_LOGIC;                      -- TFC DDR FALL SERIAL DATA

                CH0_RAM_BPORT           :   OUT STD_LOGIC_VECTOR(7 DOWNTO 0);   -- SERIAL DATA GETS ROUTED TO THE RAM CH0 STORAGE ALLOCATED FOR TFC WHEN FPGA CONSIGD AS SALT
                CH1_RAM_BPORT           :   OUT STD_LOGIC_VECTOR(7 DOWNTO 0);   -- SERIAL DATA GETS ROUTED TO THE RAM CH1 STORAGE ALLOCATED FOR ELINK0
                P_BIT_OS_SEL            :   OUT STD_LOGIC_VECTOR(2 DOWNTO 0);   -- BIT ALIGNMENT OFFSET VALUE DETERMINED BY MASTER DES320M AND USE DY ALL SLAVES
                P_ALIGN_ACTIVE          :   OUT STD_LOGIC;                      -- '1' INDICATES THE AUTO ALIGN FUNCTION IS ACTIVE

                P_CCC_RX_CLK_LOCK       :   OUT STD_LOGIC;                      -- CCC2 LOCK STATUS
                P_CCC_160M_ADJ          :   OUT STD_LOGIC;                      -- CCC2 PHASE ADJUSTABLE 160 MHZ CLOCK--BASELINE PHASE
                P_CCC_160M_1ADJ         :   OUT STD_LOGIC;                      -- CCC2 PHASE ADJUSTABLE 160 MHZ CLOCK--ADD'L PHASE OFFSET 1 
                P_CCC_160M_2ADJ         :   OUT STD_LOGIC                       -- CCC2 PHASE ADJUSTABLE 160 MHZ CLOCK--ADD'L PHASE OFFSET 2
            );
END COMPONENT;

----------------------------------------------------------------
-- GENERAL PURPOSE PATTERN GENERATOR
COMPONENT GP_PATT_GEN
    port (  
            CLK_40MHZ_GEN       :   IN  STD_LOGIC;                              -- CLOCK SYNCHRONOUS BUT DELAYED BY !2.5NS FROM THE FIXED 160MHZ CCC CLOCK FROM THE SERIALIZER
            RESET_B             :   IN  STD_LOGIC;                              -- ACTIVE LOW RESET    
            USB_MASTER_EN       :   IN  STD_LOGIC;                              -- '1' SIGNIFIES THAT THE USB MODULE IS NOW ACTIVE

            STRT_ADDR           :   IN  STD_LOGIC_VECTOR(7 DOWNTO 0);           -- START ADDRESS FOR A PATTERN GENERATOR
            STOP_ADDR           :   IN  STD_LOGIC_VECTOR(7 DOWNTO 0);           -- STOP ADDRESS FOR A PATTERN GENERATOR
            ACT_BLK_SEL         :   IN  STD_LOGIC;                              -- ACTIVE RAM BLOCK SELECT (IE ADDR BIT 8 FOR 512 BYTE RAM CONTROLLED IN THE USB MODULE)
            DIR_MODE            :   IN  STD_LOGIC;                              -- '1'= TX MODE, '0'= RX MODE

            ALIGN_PATT          :   IN  STD_LOGIC_VECTOR(7 DOWNTO 0);           -- ALIGNMENT PATTERN
            RX_SER_WORD         :   IN  STD_LOGIC_VECTOR(7 DOWNTO 0);           -- RECEIVED SERIAL BYTE STREAM

            GP_PATT_GEN_EN      :   IN  STD_LOGIC;                              -- PATERN GENERATOR ENABLE
            REPEAT_EN           :   IN  STD_LOGIC;                              -- '1' CAUSES PATTERN GENERATOR TO AUTO REPEAT CONTINUOUSLY WHEN THE PATTERN GENERATOR IS ENABLED
            ALIGN_ACTIVE        :   IN  STD_LOGIC;                              -- '1' INDICATES THAT THE ALIGN MODE IS ACTIVE

            RAM_ADDR            :   OUT STD_LOGIC_VECTOR(8 DOWNTO 0);           -- START ADDRESS FOR A PATTERN GENERATOR (USES B PORT SIDE OF DUAL PORT RAM BLOCKS)
            RAM_BLKB            :   OUT STD_LOGIC;                              -- PORT B RAM BLOCK ENABLE
            RAM_RWB             :   OUT STD_LOGIC                               -- PORT B RAM READ/WRITE CONTROL
        );
END COMPONENT;

----------------------------------------------------------------
-- SLAVE ELINK MODULE
COMPONENT ELINK_SLAVE
 port (
			CLK_40M_GL        		:   IN 	STD_LOGIC;                          	-- CCC#1 FIXED 40MHZ CLOCK OUT
			CCC_160M_FXD      		:   IN	STD_LOGIC;                          	-- CCC#1 FIXED 160MHZ CLOCK
			CCC_160M_ADJ      		:   IN	STD_LOGIC;                          	-- CCC#2 ADJ 160MHZ CLOCK

			DEV_RST_B           	:   IN  STD_LOGIC;                          	-- ACTIVE LOW ASYNC RESET --DEDICATED COMET BOARD RC TIME CONSTANT
			MASTER_POR_B      		:   IN	STD_LOGIC;                          	-- MASTER_POR_B
			MASTER_DCB_POR_B        :   IN	STD_LOGIC;                              -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR DCB CONFIGS
			MASTER_SALT_POR_B     	:   IN	STD_LOGIC;                              -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR SALT CONFIGS

			DCB_SALT_SEL        	:   IN  STD_LOGIC;                          	-- '1'= DCB MODE (IE TFC MASTER TX ENABLED) // '0'=SALT HYBRID MODE (IE TFC MASTER RX W/ SYNC MODE ENABLED)
		
			OP_MODE1_SPE      		:   IN	STD_LOGIC;                          	-- OP_MODE BIT 1 = SYNC PATT EN
			F_ALIGN_PATT            :   IN	STD_LOGIC_VECTOR(7 DOWNTO 0); 			-- FIXED SYNC / ALIGNMENT PATTERN BYTE
			PATT_ELK_DAT			:	IN	STD_LOGIC_VECTOR(7 DOWNTO 0); 			-- ELINK PATTERN TX DATA

			BIT_OS_SEL            	:   IN	STD_LOGIC_VECTOR(2 DOWNTO 0);   		-- BIT ALIGNMENT OFFSET VALUE DETERMINED BY MASTER DES320M AND USE DY ALL SLAVES
		
			ELK_DAT_P         		:   INOUT STD_LOGIC;                        	-- SERIAL LVDS ELINK0 DATA BIDIR PORT
			ELK_DAT_N         		:   INOUT STD_LOGIC;							--	""

			ELK_RX_SER_WORD         :   OUT	STD_LOGIC_VECTOR(7 DOWNTO 0)            -- OUTPUT WORD OF THE ELINK DE-SERIALIZER

	 );
	END COMPONENT;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- SLAVE ELINK MODULE+++++++INVERTED SERIAL DATA PATH PER NOTE AT BEGINNING OF THIS FILE+++++++
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
COMPONENT ELINK_SLAVE_INV
 port (
			CLK_40M_GL        		:   IN 	STD_LOGIC;                          	-- CCC#1 FIXED 40MHZ CLOCK OUT
			CCC_160M_FXD      		:   IN	STD_LOGIC;                          	-- CCC#1 FIXED 160MHZ CLOCK
			CCC_160M_ADJ      		:   IN	STD_LOGIC;                          	-- CCC#2 ADJ 160MHZ CLOCK

			DEV_RST_B           	:   IN  STD_LOGIC;                          	-- ACTIVE LOW ASYNC RESET --DEDICATED COMET BOARD RC TIME CONSTANT
			MASTER_POR_B      		:   IN	STD_LOGIC;                          	-- MASTER_POR_B
			MASTER_DCB_POR_B        :   IN	STD_LOGIC;                              -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR DCB CONFIGS
			MASTER_SALT_POR_B     	:   IN	STD_LOGIC;                              -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR SALT CONFIGS

			DCB_SALT_SEL        	:   IN  STD_LOGIC;                          	-- '1'= DCB MODE (IE TFC MASTER TX ENABLED) // '0'=SALT HYBRID MODE (IE TFC MASTER RX W/ SYNC MODE ENABLED)
		
			OP_MODE1_SPE      		:   IN	STD_LOGIC;                          	-- OP_MODE BIT 1 = SYNC PATT EN
			F_ALIGN_PATT            :   IN	STD_LOGIC_VECTOR(7 DOWNTO 0); 			-- FIXED SYNC / ALIGNMENT PATTERN BYTE
			PATT_ELK_DAT			:	IN	STD_LOGIC_VECTOR(7 DOWNTO 0); 			-- ELINK PATTERN TX DATA

			BIT_OS_SEL            	:   IN	STD_LOGIC_VECTOR(2 DOWNTO 0);   		-- BIT ALIGNMENT OFFSET VALUE DETERMINED BY MASTER DES320M AND USE DY ALL SLAVES
		
			ELK_DAT_P         		:   INOUT STD_LOGIC;                        	-- SERIAL LVDS ELINK0 DATA BIDIR PORT
			ELK_DAT_N         		:   INOUT STD_LOGIC;							--	""

			ELK_RX_SER_WORD         :   OUT	STD_LOGIC_VECTOR(7 DOWNTO 0)            -- OUTPUT WORD OF THE ELINK DE-SERIALIZER

	 );
	END COMPONENT;
----------------------------------------------------------------
-- USB INTERFACE
-- CONTAINS USB INTERFACE LOGIC, CONTROL REGISTERS, STATUS REGISTERS, ONE TFC PATTERN REGISTER BANK, AND UP TO 20 ELINK PATTERN REGISTER BANKS
COMPONENT USB_INTERFACE 
    port(
            CLK60MHZ            :   IN      STD_LOGIC;                      -- CLOCK FROM THE USM MODULE DERIVED FROM A 12MHZ CRYSTAL ON-BOARD THE USB MODULE PLL
            RESETB              :   IN      STD_LOGIC;                      -- ACTIVE LOW RESET
            MASTER_POR_B        :   IN      STD_LOGIC;                      -- RESET SYNCHRONOUS TO THE 160 MHZ AND 40 MHZ CLOCKS
            CLK_40MHZ_GEN       :   IN      STD_LOGIC;                      -- CLOCK SYNCHRONOUS TO THE 160MHZ CCC CLOCK FROM THE SERIALIZER            

            -- USB INTERFACE SIGNALS (SYNCHRONOUS TO CLK60MHZ)
            BIDIR_USB_ADBUS     :   INOUT   STD_LOGIC_VECTOR(7 DOWNTO 0);   -- USB:  BI-DIRECTIONAL ADDRESS AND DATA BUS
            USB_OE_B            :   OUT     STD_LOGIC;                      -- USB:  ACTIVE LOW TURNS ON THE USB DATA BUS OUTPUT MODE

            P_USB_RXF_B         :   IN      STD_LOGIC;                      -- USB:  ACTIVE LOW SIGNIFIES THAT THE ON-BOARD USB FIFO HAS DATA TO BE READ (IE READ TRANSFER REQUEST)
            USB_RD_B            :   OUT     STD_LOGIC;                      -- USB:  ACTIVE LOW STATE FETCHES NEXT BYTE FROM THE FIFO ON THE NEXT CLK60MHZ CLOCK EDGE

            P_USB_TXE_B         :   IN      STD_LOGIC;                      -- USB:  ACTIVE LOW SIGNIFIES THAT THE ON-BOARD USB FIFO CAN NOW ACCEPT DATA (IE WRITE TRANSFER ENABLED)
            USB_WR_B            :   OUT     STD_LOGIC;                      -- USB:  ACTIVE LOW STATE ENABLE DATA TO BE WRITTEN TO THE FIFO ON THE NEXT CLK60MHZ CLOCK EDGE

            USB_SIWU_B          :   OUT     STD_LOGIC;                      -- USB:  ACTIVE LOW--Send Immediate / WakeUp signal (CAN BE USED TO OPTIMIZE DATA TRANSFER RATES)
                                                                            -- TIE HIGH IF NOT USED
            -- EXTERNAL PATTERN GEN INTERFACES (SYNCHRONOUS TO CLK_40MHZ_GEN)
            P_TFC_STRT_ADDR     :   OUT     STD_LOGIC_VECTOR(7 DOWNTO 0);   -- START ADDRESS FOR THE TFC PATTERN GENERATOR
            P_TFC_STOP_ADDR     :   OUT     STD_LOGIC_VECTOR(7 DOWNTO 0);   -- STOP ADDRESS FOR THE TFC PATTERN GENERATOR
            TFC_ADDRB           :   IN      STD_LOGIC_VECTOR(8 downto 0);   -- TFC RAM BLOCK PORT B ADDRESS
            TFC_RAM_BLKB_EN     :   IN      STD_LOGIC;                      -- TFC RAM BLOCK PORT B ACTIVE LOW RAM BLOCK ENABLE
            P_TFC_ADDR8B        :   OUT     STD_LOGIC;                      -- 8TH ADDR BIT FOR THE TFC PATT B PORT INDICATES WHICH 1/2 THE PATT GEN IS USING
            TFC_DAT_OUT         :   OUT     STD_LOGIC_VECTOR(7 DOWNTO 0);   -- TFC RAM BLOCK PORT B DATA OUT
            TFC_DAT_IN          :   IN      STD_LOGIC_VECTOR(7 DOWNTO 0);   -- TFC RAM BLOCK PORT B DATA IN
            TFC_RWB             :   IN      STD_LOGIC;                      -- TFC RAM BLOCK PORT B READ WRITE CONTROL

            P_ELINKS_STRT_ADDR  :   OUT     STD_LOGIC_VECTOR(7 DOWNTO 0);   -- START ADDRESS FOR THE ELINKS PATTERN GENERATOR
            P_ELINKS_STOP_ADDR  :   OUT     STD_LOGIC_VECTOR(7 DOWNTO 0);   -- STOP ADDRESS FOR THE ELINKS PATTERN GENERATOR
            ELINK_ADDRB        	:   IN      STD_LOGIC_VECTOR(8 downto 0);   -- COMMON ELINKS RAM BLOCK PORT B ADDRESS
            ELINK_PATT_GEN_EN  	:   IN      STD_LOGIC;                      -- COMMON ELINKS RAM BLOCK PORT B ACTIVE LOW RAM BLOCK ENABLE
            P_ELINK_ADDR8B     	:   OUT     STD_LOGIC;                      -- 8TH ADDR BIT FOR THE ELINK 0 PORT B INDICATES WHICH 1/2 THE PATT GEN IS USING
            ELINK_RWB          	:   IN      STD_LOGIC;                      -- COMMON ELINKS RAM BLOCK PORT B READ WRITE CONTROL

            ELINK0_DAT_OUT      :   OUT     STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK0 RAM BLOCK PORT B DATA OUT
            ELINK0_DAT_IN       :   IN      STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK0 RAM BLOCK PORT B DATA IN

			ELINK1_DAT_OUT      :   OUT     STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK1 RAM BLOCK PORT B DATA OUT
            ELINK1_DAT_IN       :   IN      STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK1 RAM BLOCK PORT B DATA IN

			ELINK2_DAT_OUT      :   OUT     STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK2 RAM BLOCK PORT B DATA OUT
            ELINK2_DAT_IN       :   IN      STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK2 RAM BLOCK PORT B DATA IN

			ELINK3_DAT_OUT      :   OUT     STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK3 RAM BLOCK PORT B DATA OUT
            ELINK3_DAT_IN       :   IN      STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK3 RAM BLOCK PORT B DATA IN

			ELINK4_DAT_OUT      :   OUT     STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK4 RAM BLOCK PORT B DATA OUT
            ELINK4_DAT_IN       :   IN      STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK4 RAM BLOCK PORT B DATA IN

			ELINK5_DAT_OUT      :   OUT     STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK5 RAM BLOCK PORT B DATA OUT
            ELINK5_DAT_IN       :   IN      STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK5 RAM BLOCK PORT B DATA IN

			ELINK6_DAT_OUT      :   OUT     STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK6 RAM BLOCK PORT B DATA OUT
            ELINK6_DAT_IN       :   IN      STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK6 RAM BLOCK PORT B DATA IN

			ELINK7_DAT_OUT      :   OUT     STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK7 RAM BLOCK PORT B DATA OUT
            ELINK7_DAT_IN       :   IN      STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK7 RAM BLOCK PORT B DATA IN

			ELINK8_DAT_OUT      :   OUT     STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK8 RAM BLOCK PORT B DATA OUT
            ELINK8_DAT_IN       :   IN      STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK8 RAM BLOCK PORT B DATA IN

			ELINK9_DAT_OUT      :   OUT     STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK9 RAM BLOCK PORT B DATA OUT
            ELINK9_DAT_IN       :   IN      STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK9 RAM BLOCK PORT B DATA IN

			ELINK10_DAT_OUT     :   OUT     STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK10 RAM BLOCK PORT B DATA OUT
            ELINK10_DAT_IN      :   IN      STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK10 RAM BLOCK PORT B DATA IN

			ELINK11_DAT_OUT     :   OUT     STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK11 RAM BLOCK PORT B DATA OUT
            ELINK11_DAT_IN      :   IN      STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK11 RAM BLOCK PORT B DATA IN

			ELINK12_DAT_OUT     :   OUT     STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK12 RAM BLOCK PORT B DATA OUT
            ELINK12_DAT_IN      :   IN      STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK12 RAM BLOCK PORT B DATA IN

			ELINK13_DAT_OUT     :   OUT     STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK13 RAM BLOCK PORT B DATA OUT
            ELINK13_DAT_IN      :   IN      STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK13 RAM BLOCK PORT B DATA IN

			ELINK14_DAT_OUT     :   OUT     STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK14 RAM BLOCK PORT B DATA OUT
            ELINK14_DAT_IN      :   IN      STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK14 RAM BLOCK PORT B DATA IN

			ELINK15_DAT_OUT     :   OUT     STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK15 RAM BLOCK PORT B DATA OUT
            ELINK15_DAT_IN      :   IN      STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK15 RAM BLOCK PORT B DATA IN

			ELINK16_DAT_OUT     :   OUT     STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK16 RAM BLOCK PORT B DATA OUT
            ELINK16_DAT_IN      :   IN      STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK16 RAM BLOCK PORT B DATA IN

			ELINK17_DAT_OUT     :   OUT     STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK17 RAM BLOCK PORT B DATA OUT
            ELINK17_DAT_IN      :   IN      STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK17 RAM BLOCK PORT B DATA IN

			ELINK18_DAT_OUT     :   OUT     STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK18 RAM BLOCK PORT B DATA OUT
            ELINK18_DAT_IN      :   IN      STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK18 RAM BLOCK PORT B DATA IN

			ELINK19_DAT_OUT     :   OUT     STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK19 RAM BLOCK PORT B DATA OUT
            ELINK19_DAT_IN      :   IN      STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK19 RAM BLOCK PORT B DATA IN

            P_OP_MODE           :   OUT     STD_LOGIC_VECTOR(7 DOWNTO 0)   	-- PATTERN GENERATOR OPERATING MODE

        );
    END COMPONENT;


--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- DEFINE INTERNAL SIGNALS
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

SIGNAL  RAW_CLK_200M                    :   STD_LOGIC;                                  -- DIRECT FROM LVDS RECV BUFF: OSC REF CLOCK

-- SIGNALS ASSOCIATED WITH THE MAIN CCC
SIGNAL  CLK_40M_BUF_RECD                :   STD_LOGIC;                                  -- BIDIR_LVDS_BUF_RX SIGNAL 'Y': DIV-BY-5 OF 200 MHZ OSC REF CLOCK
SIGNAL  CCC_160M_FXD                    :   STD_LOGIC;                                  -- CCC1 GENERATED FIXED 160 MHZ
SIGNAL  CCC_MAIN_LOCK                   :   STD_LOGIC;                                  -- LOCK FOR THE MAIN CCC THAT GENERATES THE 160 MHZ AND 40 MHZ CLOCKS
SIGNAL  CLK40M_10NS_REF                 :   STD_LOGIC;                                  -- REF 40 MHZ DERIVED BY DIV-BY-5 OF 200 MHZ (USED AS CCC1 REF CLOCK SOURCE)
SIGNAL  CLK_40M_GL                      :   STD_LOGIC;                                  -- 40 MHZ CLOCK---GLOBAL USED AS REF TO CCC#2
SIGNAL  CLK60MHZ                        :   STD_LOGIC;                                  -- CCC 60 MHZ DERIVED FROM THE USB 60 MHZ, BUT WITH A FIXED 'LEADING PHASE'.

ATTRIBUTE syn_keep OF CLK_40M_GL 		: SIGNAL IS TRUE;
ATTRIBUTE alspreserve OF CLK_40M_GL 	: SIGNAL IS TRUE;

ATTRIBUTE syn_keep OF CCC_160M_FXD 		: SIGNAL IS TRUE;
ATTRIBUTE alspreserve OF CCC_160M_FXD 	: SIGNAL IS TRUE;

ATTRIBUTE syn_keep OF CLK60MHZ 			: SIGNAL IS TRUE;
ATTRIBUTE alspreserve OF CLK60MHZ 		: SIGNAL IS TRUE;


-- SIGNALS ASSOCIATED WITH THE AUX CCC 
SIGNAL  CCC_160M_ADJ                    :   STD_LOGIC;                                  -- PHASE ADJ 160 MHZ CLOCK FOR THE SERDES.
SIGNAL  CCC_RX_CLK_LOCK                 :   STD_LOGIC;                                  -- CCC#2 LOCK STATUS


-- ELINK BLOCK RAMS WITH 'A' AND 'B' PORTS
TYPE   ELINK_BUS_SIGS 		IS ARRAY (19 DOWNTO 0) OF STD_LOGIC_VECTOR (8 DOWNTO 0);
TYPE   ELINK_SIGNALS		IS ARRAY (19 DOWNTO 0) OF STD_LOGIC;
TYPE   ELINK_BYTES			IS ARRAY (19 DOWNTO 0) OF STD_LOGIC_VECTOR (7 DOWNTO 0);

-- DATA FLOW SIGNALS
SIGNAL  TFC_OUT_R                       :   STD_LOGIC;               					-- TFC LVDS OUTPUT --RISE EDGE
SIGNAL  TFC_OUT_F                       :   STD_LOGIC;               					-- TFC LVDS OUTPUT --FALL EDGE
SIGNAL  TFC_IN_DDR_R, TFC_IN_R          :   STD_LOGIC;                                  -- TFC INPUT BIT -- RISE EDGE (DDR VERSION IS STRAIGHT FROM DDR REG, OTHER IS DELAYED BY 1 FF )
SIGNAL  TFC_IN_DDR_F, TFC_IN_F          :   STD_LOGIC;                                  -- TFC INPUT BIT -- FALL EDGE (DDR VERSION IS STRAIGHT FROM DDR REG, OTHER IS DELAYED BY 1 FF )

SIGNAL  ELK0_OUT_R                     	:   STD_LOGIC;              					-- ELINK0 LVDS OUTPUTS --RISE EDGE
SIGNAL  ELK0_OUT_F                      :   STD_LOGIC;              					-- ELINK0 LVDS OUTPUTS --FALL EDGE
SIGNAL  ELK0_IN_DDR_R, ELK0_IN_R        :   STD_LOGIC;                              	-- ELINK0 INPUT BITS -- RISE EDGE (DDR VERSION IS STRAIGHT FROM DDR REG, OTHER IS DELAYED BY 1 FF )
SIGNAL  ELK0_IN_DDR_F, ELK0_IN_F        :   STD_LOGIC;                              	-- ELINK0 INPUT BITS -- FALL EDGE (DDR VERSION IS STRAIGHT FROM DDR REG, OTHER IS DELAYED BY 1 FF )

SIGNAL  USB_RD_BI                       :   STD_LOGIC;                                  -- INTERNAL VERSION OF USB_RD_B
SIGNAL  USB_WR_BI                       :   STD_LOGIC;                                  -- INTERNAL VERSION OF USB_WR_B
SIGNAL  USB_OE_BI                       :   STD_LOGIC;                                  -- INTERNAL VERSION OF USB_OE_B
SIGNAL  USB_SIWU_BI                     :   STD_LOGIC;                                  -- INTERNAL VERSION OF USB_SIWU_B

SIGNAL  USB_MASTER_EN                   :   STD_LOGIC;                                  -- USED TO ENABLE THE VHDL MODULE AFTER THE PHY USB MODULE IS GENERATING A STABLE 60 MHZ CLOCK

-- PATTERN GENERATOR RELATED SIGNALS
SIGNAL  ALIGN_ACTIVE                    :   STD_LOGIC;                                  -- '1' INDICATES THAT THE ALIGN MODE IS ACTIVE

SIGNAL  TFC_STRT_ADDR                   :   STD_LOGIC_VECTOR(7 DOWNTO 0);               -- START ADDRESS FOR THE TFC PATTERN GENERATOR
SIGNAL  TFC_STOP_ADDR                   :   STD_LOGIC_VECTOR(7 DOWNTO 0);               -- STOP ADDRESS FOR THE TFC PATTERN GENERATOR
SIGNAL  TFC_ADDRB                       :   STD_LOGIC_VECTOR(8 DOWNTO 0);               -- TFC RAM BANK, B PORT ADDRESS FROM THE PATTERN GEN
SIGNAL  PATT_TFC_DAT                    :   STD_LOGIC_VECTOR(7 DOWNTO 0);               -- TFC RAM BLOCK PORT B DATA OUT
SIGNAL  TFC_RX_SER_WORD                 :   STD_LOGIC_VECTOR(7 DOWNTO 0);               -- OUTPUT WORD OF THE TFC DE-SERIALIZER
SIGNAL  TFC_TX_DAT                      :   STD_LOGIC_VECTOR(7 DOWNTO 0);               -- CONNECTION BETWEEN TFC SOURCE DATA MUX AND THE TFS TX SERIALIZER
SIGNAL  TFC_ACT_BLK_SEL                 :   STD_LOGIC;                                  -- ACTIVE RAM BLOCK SELECT
SIGNAL  TFC_RAM_BLKB_EN                 :   STD_LOGIC;                                  -- TFC RAM BLOCK B PORT ENABLE
SIGNAL  TFC_RWB                         :   STD_LOGIC;                                  -- TFC RAM BLOCK B PORT R/W CONTROL
SIGNAL  OP_MODE                         :   STD_LOGIC_VECTOR(7 DOWNTO 0);               -- DEFINES THE OPERATING MODE FOR ALL PATTERN GENERATORS

SIGNAL  ELKS_STRT_ADDR                  :   STD_LOGIC_VECTOR(7 DOWNTO 0);               -- COMMON START ADDRESS FOR THE ELINKS PATTERN GENERATOR
SIGNAL  ELKS_STOP_ADDR                  :   STD_LOGIC_VECTOR(7 DOWNTO 0);               -- COMMON STOP ADDRESS FOR THE ELINKS PATTERN GENERATOR
SIGNAL  ELKS_ADDRB                      :   STD_LOGIC_VECTOR(8 DOWNTO 0);               -- ELINKS RAM BANK, B PORT ADDRESS FROM THE PATTERN GEN
SIGNAL  ELKS_ACT_BLK_SEL                :   STD_LOGIC;                                  -- ACTIVE RAM BLOCK SELECT
SIGNAL  ELKS_RAM_BLKB_EN                :   STD_LOGIC;                                  -- ELINKS RAM BLOCK B PORT ENABLE
SIGNAL  ELKS_RWB                        :   STD_LOGIC;                                  -- ELINK 0 RAM BLOCK B PORT R/W CONTROL

--+++++++
SIGNAL  PATT_ELK_DAT                   	:   ELINK_BYTES;               					-- ELINK PATTERN TX DATA (X20 BYTES)

SIGNAL  ELK_RX_SER_WORD                	:   ELINK_BYTES;               					-- OUTPUT WORDS OF THE ELINK DE-SERIALIZERS (X20 BYTES)
SIGNAL  ELK0_TX_DAT                    	:   STD_LOGIC_VECTOR(7 DOWNTO 0);            	-- CONNECTION BETWEEN ELINK0 SOURCE DATA MUX AND THE ELINKS TX SERIALIZER
--+++++++

SIGNAL  BIT_OS_SEL                      :   STD_LOGIC_VECTOR(2 DOWNTO 0);               -- BIT ALIGNMENT OFFSET VALUE DETERMINED BY MASTER DES320M AND USE DY ALL SLAVES
SIGNAL  DDR_Q0_RISE                     :   STD_LOGIC;                                  -- TEST PORT VALUE OF THE REC'D DDR BIT STREAM (RISE)
SIGNAL  DDR_Q1_FALL                     :   STD_LOGIC;                                  -- TEST PORT VALUE OF THE REC'D DDR BIT STREAM (FALL)

-- THESE SIGNALS ARE USED FOR INITIAL CONFIG AND POWER ON RESET
SIGNAL  MASTER_POR_B                    :   STD_LOGIC;                                  -- MASTER POR (INTERNAL COPY)
SIGNAL  MASTER_DCB_POR_B                :   STD_LOGIC;                                  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR DCB CONFIGS
SIGNAL  MASTER_SALT_POR_B               :   STD_LOGIC;                                  -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR SALT CONFIGS

-- SYNC DETECTION STATUS SIGNALS:  ='1' WHEN DATA CONNECTED TO RAM BLOCK INPUT IS 8E HEX
SIGNAL  ELK0_SYNC_DET                   :   STD_LOGIC;
SIGNAL  TFC_SYNC_DET                    :   STD_LOGIC;

CONSTANT    F_ALIGN_PATT                :   STD_LOGIC_VECTOR(7 DOWNTO 0) := "10001110"; -- 8E HEX FIXED SYNC / ALIGNMENT PATTERN BYTE
CONSTANT    TFC_1_CMD                   :   STD_LOGIC_VECTOR(7 DOWNTO 0) := "01010001"; -- FOR TEST USAGE
CONSTANT    TFC_2_CMD                   :   STD_LOGIC_VECTOR(7 DOWNTO 0) := "01010010"; -- FOR TEST USAGE
CONSTANT    TFC_3_CMD                   :   STD_LOGIC_VECTOR(7 DOWNTO 0) := "01010011"; -- FOR TEST USAGE
CONSTANT    TFC_4_CMD                   :   STD_LOGIC_VECTOR(7 DOWNTO 0) := "01010100"; -- FOR TEST USAGE
CONSTANT    TFC_5_CMD                   :   STD_LOGIC_VECTOR(7 DOWNTO 0) := "01010101"; -- FOR TEST USAGE
CONSTANT    TFC_6_CMD                   :   STD_LOGIC_VECTOR(7 DOWNTO 0) := "01010110"; -- FOR TEST USAGE
CONSTANT    TFC_7_CMD                   :   STD_LOGIC_VECTOR(7 DOWNTO 0) := "01010111"; -- FOR TEST USAGE
CONSTANT    TFC_8_CMD                   :   STD_LOGIC_VECTOR(7 DOWNTO 0) := "01011000"; -- FOR TEST USAGE
CONSTANT    TFC_9_CMD                   :   STD_LOGIC_VECTOR(7 DOWNTO 0) := "01011001"; -- FOR TEST USAGE
CONSTANT    TFC_10_CMD                  :   STD_LOGIC_VECTOR(7 DOWNTO 0) := "01011010"; -- FOR TEST USAGE
CONSTANT    TFC_11_CMD                  :   STD_LOGIC_VECTOR(7 DOWNTO 0) := "01011011"; -- FOR TEST USAGE
CONSTANT    TFC_12_CMD                  :   STD_LOGIC_VECTOR(7 DOWNTO 0) := "01011100"; -- FOR TEST USAGE
CONSTANT    TFC_13_CMD                  :   STD_LOGIC_VECTOR(7 DOWNTO 0) := "01011101"; -- FOR TEST USAGE
CONSTANT    TFC_14_CMD                  :   STD_LOGIC_VECTOR(7 DOWNTO 0) := "01011110"; -- FOR TEST USAGE

CONSTANT    SIM_MODE                    :   STD_LOGIC :=  '0';                          -- '1' = SIM MODE, '0' = REAL TIME OP MODE

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
BEGIN
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- CREATE A FEW PIPELINE DELAY REGISTERS FOR THE DDR RECEIVE SIGNALS ASSOCIATED WITH TFC AND ELINKS (GIVES P&R MORE LATITUDE TO CLOSE TIMING)
-- THESE PIPELINE REGISTERS ARE FOR THE MASTER DESERILIZER 
-- SIMILAR PIPELINE REGISTERS ARE LOCATED INSIDE THE SLAVE DESERILIZER MODULES
REG:PROCESS(DEV_RST_B, CCC_160M_ADJ)
    BEGIN
        IF DEV_RST_B = '0' THEN
            TFC_IN_R  	<=  '0';
            TFC_IN_F    <=  '0';

            ELK0_IN_R   <=  '0';
            ELK0_IN_F   <=  '0';

        ELSIF (CCC_160M_ADJ'EVENT AND CCC_160M_ADJ='1') THEN
            TFC_IN_R    <=  TFC_IN_DDR_R;
            TFC_IN_F    <=  TFC_IN_DDR_F;

            ELK0_IN_R   <=  NOT(ELK0_IN_DDR_R);						-- ++++INVERTED PER NOTE A BEGINNING OF THIS FILE++++
            ELK0_IN_F   <=  NOT(ELK0_IN_DDR_F);						-- ++++INVERTED PER NOTE A BEGINNING OF THIS FILE++++


        END IF;

    END PROCESS REG;
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
-- 	EACH COMET FPGA DRIVES 2 CAT5 CONNS ON THE ASSOCIATED PASSIVE DAUGHTER BOARD,  1 CONN HAS THE BIDIR PORT WHILE THE OTHER HAS THE TX-ONLY PORT
--	THIS ALLOWS THE MASTER TX ONLY TO CONNECT TO THE DOWNSTREAM SLAVE BIDIR PORT.  THE REST OF THE SLAVES ARE THEN CONNECTED IN A SIMILAR DAISY CHAIN FASHION.
--  ONLY ONE FPGA SHOULD BE CONFIGURED AS MASTER TO ENSURE COMMON DETERMINISTIC REF CLOCK PHASES THRUOUT THE SYSTEM.
--  THEREFORE, THE BIDIR PORT OF THE MASTER FPGA SHOULD BE CONNECTED TO THE BIDIR 'SLAVE' CONFIGURED ADJACENT FPGA LOCATED ON THE SAME BOARD AS THE MASTER FPGA.
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- THIS IS THE LVDS INPUT FOR THE COMET 200 MHZ OSC 
U0_200M_BUF:LVDS_CLK_IN                                  
    PORT MAP    (
                    PADP    =>  CLK200_P,
                    PADN    =>  CLK200_N,
                    Y       =>  RAW_CLK_200M
                );

-- LVDS CLOCK BI-DIR BUFFER OF THE COMET 40 MHZ CLOCK DERIVED FROM THE 200 MHZ OSC CLOCK TO BE USED AS A MAIN CCC REF CLOCK
-- EXT_INT_REF_SEL = '1' => DCB RX OF CLOCK (IE USE EXT REF CLK).  DCB_SALT_SEL = '0' => DCB TX REF CLOCKS (IE DRIVER OUT ENABLED).  
U0A_40M_REFCLK:BIDIR_LVDS_IO
    PORT MAP    (   Data    =>  CLK40M_10NS_REF,                -- DATA INPUT FOR THE BUFFER THAT DRIVES THE PADS
                    Y       =>  CLK_40M_BUF_RECD,               -- TRANSPARENT BUFFER CONNECTED TO THE PADS DRIVING INTO THE FPGA (IE SEES EITHER TX OR RX VERSION OF CLOCK)
                    Trien   =>  EXT_INT_REF_SEL,                -- TRI-STATE CONTROL ('0' = DRIVER ENABLED)
                    PADP    =>  BIDIR_CLK40M_P,                 -- PHYSICAL I/O PAD
                    PADN    =>  BIDIR_CLK40M_N                  -- PHYSCIAL I/O PAD
                );

-- LVDS DRIVER USED FOR DISTRIBUTION COPY OF CLK_40M_BUF_RECD (IE 10NS HIGH / 15NS LOW)
U0B_TX40M_REFCLK:LVDS_BUFOUT
    PORT MAP	( 
					Data 	=>	CLK_40M_BUF_RECD,
					PADP 	=>	TX_CLK40M_P,
					PADN 	=>	TX_CLK40M_N
				);
				
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- THIS IS THE EXECUTIVE CCC CONFIG-AT-POWER-ON AND MASTER RESET MODULE
U_EXEC_MASTER:EXEC_MODE_CNTL
    PORT MAP    (
                    CCC_160M_FXD        =>  CCC_160M_FXD,               -- FIXED 160 MHZ COMET CLOCK
                    DEV_RST_B           =>  DEV_RST_B,                  -- COMET BOARD POWER ON RESET
                    DCB_SALT_SEL        =>  DCB_SALT_SEL,               -- DETERMINES INITIAL POWER ON CONDITIONS
                    CCC_1_LOCK_STAT     =>  CCC_MAIN_LOCK,

                    CLK_40MHZ_GEN       =>  CLK_40M_GL,                 -- 40MHZ CLOCK SYNCHRONOUS TO THE 160MHZ CCC CLOCKS FROM THE SERDES CCC2
                    CLK60MHZ            =>  CLK60MHZ,                   -- CLOCK FROM THE USM MODULE DERIVED FROM A 12MHZ CRYSTAL ON-BOARD THE USB MODULE PLL
                                                                        -- THIS CLOCK IS NOT ACTIVE AT POWER ON.  REQUIRES USB HOST ACTION TO ENABLE THE OUTPUT.
                    USB_RESET_B         =>  USB_MASTER_EN,              -- ACTIVE LOW RESET DEDICATED FOR THE USB VHDL STATE MACHINE--SYCHRONOUS RELEASE RELATIVE TO THE 60 MHZ CLOCK

                    MASTER_DCB_POR_B    =>  MASTER_DCB_POR_B,           -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR DCB CONFIGS
                    MASTER_SALT_POR_B   =>  MASTER_SALT_POR_B,          -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR SALT CONFIGS
                    MASTER_POR_B        =>  MASTER_POR_B 
                );

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- GENERATES A 40 MHZ CLOCK BY DIVIDING THE 200 MHZ BY 5.  DUTY CYCLE IS 40/60.
U_GEN_REF_CLK:REF_CLK_DIV_GEN 
    PORT MAP (
                    CLK_200MHZ          =>  RAW_CLK_200M,               -- 200 MHZ OSCILLATOR SOURCE
                    POR_N               =>  DEV_RST_B,                  -- ACTIVE LOW POWER-ON RESET
                    CLK40M_10NS_REF     =>  CLK40M_10NS_REF             -- 40 MHZ WITH 40/60 DUTY CYCLE (IE 0 NS PW) DERIVED FROM 200 MHZ
            );
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- THIS IS THE CCC USED TO GENERATE THE FIXED 40 AND 160 MHZ CLOCK SOURCES AS WELL AS THE ASYNCHRONOUS USB 60 MHZ GLOBAL CLOCK BUFFER WITH FIXED DELAY OFFSET.  
-- CCC #1
U_MAINCLKGEN:CLK_FXD_40_160_A60M 
    PORT MAP	( 
					POWERDOWN 	=>  '1',                            -- '1' POWERS THE PLL
					CLKA      	=>  CLK_40M_BUF_RECD,               -- 40 MHZ REFERENCE WITH A 40/60 DUTY CYCLE (IE 10NS PULSE) DERIVED FROMTHE 200 MHZ OSCILLATOR
					LOCK      	=>  CCC_MAIN_LOCK,
					GLA       	=>  CLK_40M_GL,                     -- GLOBAL 40 MHZ CLOCK USED FOR ALL TIMING REFERENCES--RISE EDGE 1/2 CYCLE DELAYED REALTIVE TO 160M FIXED RISE EDGE
					GLB       	=>	CCC_160M_FXD,					-- FIXED GLOBAL 160 MHZ CLOCK
					GLC       	=>  CLK60MHZ,                       -- GLOBAL 60 MHZ CLOCK FROM THE USB MODULE (ASYNC TO OTHER CLOCKS!)
					SDIN      	=>  '0',                            --
					SCLK      	=>  '0',                            --
					SSHIFT    	=>  '0',                            --
					SUPDATE   	=>  '0',                            --
					MODE      	=>  '0',                            --
					SDOUT     	=>  open,
					CLKC      	=>  USBCLK60MHZ						-- SOURCE CLOCK FROM THE USB MODULE
				);
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- CHANNEL 0 TFC DCB TX MODULES (AND RX DDR OUTPUTS):
-- THE SERIAL TFC TX CONSISTS OF SERIAL DATA SELECT MUX, SERIALZER, BI-DIRECTIONAL DDR REGISTER FOR TFC, AND BIDIRECTIONAL BUFFER FOR THE REFCLOCK.
-- THE DATA SELECT MUX DETERMINES WHETHER TO SEND NORMAL DATA FROM THE RAM OR FIXED ALIGNMENT PATTERN DATA.

U_TFC_SERDAT_SOURCE:SYNC_DAT_SEL 
    PORT MAP    (
                    CLK40M_GEN          =>  CLK_40M_GL,             -- FIXED CCC MAIN (#1) 40 MHZ TX WORD RATE CLOCK
                    RESET_B             =>  MASTER_DCB_POR_B,       -- ONLY COME OUT OF RESET AND ENABLE IF CONFIGURED AS A DCB

                    ALIGN_MODE_EN       =>  OP_MODE(1),             -- '1' ENABLES THE SYNC PATTERN
                    ALIGN_PATT          =>  F_ALIGN_PATT,

                    SER_DAT_IN          =>  PATT_TFC_DAT,

                    P_SERDAT            =>  TFC_TX_DAT
            );


U_TFC_CMD_TX:SER320M
    PORT MAP    (
                    DDR_160M_CLK        =>  CCC_160M_FXD,
                    CLK40M_GEN          =>  CLK_40M_GL,             -- FROM PLL SYNCHRONOUS TO THE 160 MHZ SERDES CLOCKS

                    RESET_B             =>  MASTER_DCB_POR_B,       -- ONLY COME OUT OF RESET AND ENABLE IF CONFIGURED AS A DCB
                    NEXT_SER_CMD_WORD   =>  TFC_TX_DAT,
                    SERIAL_TX_EN        =>   '1',                   -- ENABLE FOR THE SERIAL TX

                    SER_OUT_R           =>  TFC_OUT_R,
                    SER_OUT_F           =>  TFC_OUT_F
                 );

-- ######################################################################################################################################
-- ######################################################################################################################################

U_DDR_TFC:DDR_BIDIR_LVDS_DUAL_CLK
    PORT MAP    (  
                    DDR_CLR             =>  MASTER_POR_B,           -- ACTIVE LOW CLEAR
                    DDR_DIR             =>  DCB_SALT_SEL,           -- ENABLE OUTPUT(IE '1'= OUTPUT)==> TX ON FOR DCB MODE // RX ON FOR SALT MODE)
                    DDR_TX_CLK          =>  CCC_160M_FXD,           -- FIXED TX CLOCK
                    DDR_TX_R            =>  TFC_OUT_R,      		-- DATA TO BE TRANSMITTED
                    DDR_TX_F            =>  TFC_OUT_F,      		--   "
                    DDR_RX_CLK          =>  CCC_160M_ADJ,           -- PHASE DELAY TUNABLE RX CLOCK
                    DDR_RX_R            =>  TFC_IN_DDR_R,           -- DATA BEING RECEIVED 
                    DDR_RX_F            =>  TFC_IN_DDR_F,           --  "                   
                    PADP                =>  TFC_DAT_0P,             -- 
                    PADN                =>  TFC_DAT_0N              -- 
                );


U_REFCLKBUF:BIDIR_LVDS_IO
    PORT MAP    (   Data                =>  CLK_40M_GL,        		-- 
                    Y                   =>  EXTCLK_40MHZ,           -- RX COPY OF DISTRIBUTED 40 MHX FIXED CLOCK FROM THE DCB CONFIGURED COMET
                    TRIEN               =>  NOT(DCB_SALT_SEL),      -- ACTIVE LOW ENABLE (IE '1'=TRI-STATED)==> TX ON FOR DCB MODE // RX ON FOR SALT MODE)
                    PADP                =>  REF_CLK_0P,             -- 
                    PADN                =>  REF_CLK_0N              -- 
                );
-- ######################################################################################################################################
-- ######################################################################################################################################


--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- RAM BLOCK CH 1 MASTER ELINK0 TX DATA SOURCE MODULES (AND RX DDR OUTPUTS)FOR A SALT CONFIGURED COMET
-- THE MASTER SERIAL ELINK0 TX CONSISTS OF SERIAL DATA SELECT MUX, SERIALZER, AND BI-DIRECTIONAL DDR REGISTER FOR ELINK0
-- THE DATA SELECT MUX DETERMINES WHETHER TO SEND NORMAL DATA FROM THE RAM OR FIXED ALIGNMENT PATTERN DATA.

U_ELK0_SERDAT_SOURCE:SYNC_DAT_SEL 
    PORT MAP    (
                    CLK40M_GEN          =>  CLK_40M_GL,             -- FIXED CCC MAIN (#1) 40 MHZ TX WORD RATE CLOCK
                    RESET_B             =>  MASTER_SALT_POR_B,     	-- ONLY COME OUT OF RESET AND ENABLE IF CONFIGURED AS A SALT

                    ALIGN_MODE_EN       =>  OP_MODE(1),             -- '1' ENABLES THE SYNC PATTERN
                    ALIGN_PATT          =>  F_ALIGN_PATT,

                    SER_DAT_IN          =>  PATT_ELK_DAT(0),

                    P_SERDAT            =>  ELK0_TX_DAT
            );


U_ELK0_CMD_TX:SER320M
    PORT MAP    (
                    DDR_160M_CLK        =>  CCC_160M_FXD,
                    CLK40M_GEN          =>  CLK_40M_GL,            -- FROM PLL SYNCHRONOUS TO 160MHZ SERDES CLOCKS

                    RESET_B             =>  MASTER_SALT_POR_B,     -- ONLY COME OUT OF RESET AND ENABLE IF CONFIGURED AS A SALT
                    NEXT_SER_CMD_WORD   =>  ELK0_TX_DAT,
                    SERIAL_TX_EN        =>   '1',                  -- ENABLE FOR THE SERIAL TX

                    SER_OUT_R           =>  ELK0_OUT_R,
                    SER_OUT_F           =>  ELK0_OUT_F
                 );

U_DDR_ELK0:DDR_BIDIR_LVDS_DUAL_CLK
    PORT MAP    (  
                    DDR_CLR             =>  MASTER_POR_B,           -- ACTIVE LOW CLEAR
                    DDR_DIR             =>  NOT(DCB_SALT_SEL),      -- ENABLE OUTPUT(IE '1'= OUTPUT)==> ELK TX ON FOR SALT MODE // ELK RX ON FOR DCB MODE)
                    DDR_TX_CLK          =>  CCC_160M_FXD,         	-- FIXED TX CLOCK
                    DDR_TX_R            =>  NOT(ELK0_OUT_R),        -- DATA TO BE TRANSMITTED ++++INVERTED PER NOTE A BEGINNING OF THIS FILE++++
                    DDR_TX_F            =>  NOT(ELK0_OUT_F),        --  "					  ++++INVERTED PER NOTE A BEGINNING OF THIS FILE++++
                    DDR_RX_CLK          =>  CCC_160M_ADJ,           -- PHASE DELAY TUNABLE RX CLOCK
                    DDR_RX_R            =>  ELK0_IN_DDR_R,        	-- DATA BEING RECEIVED
                    DDR_RX_F            =>  ELK0_IN_DDR_F,        	--  "
                    PADP                =>  ELK0_DAT_P,
                    PADN                =>  ELK0_DAT_N
                );

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- RAM BLOCKS CH0 AND CH1 MASTER DESERIALIZER WITH BUILT-IN INPUT AND OUTPUT DATA MUX LOGIC.  
-- DCB_SALT_SEL= '0' / '1' DETERMINE WHETHER DATA INTERFACES ARE TFC OR ELINK0
-- CONTAINS DYNAMICALLY ADJUSTED CCC2 WHICH GENERATES THE PHASE ADJUSTABLE 160 MHZ DESERIALIZER CLOCK.
-- INPUT REF CLOCK ASSUMED TO BE 160.0317 MHZ DERIVED FROM THE MASTER FPGA OF THE MASTER DCB-CONFIG'D COMET.

U_MASTER_DES:TOP_MASTER_DES320M 
        PORT MAP (
                    CLK_40M_GL          =>  CLK_40M_GL,                     -- ON-BOARD CCC1 40 MHZ CLOCK
					CCC_160M_FXD		=>	CCC_160M_FXD,					-- FIXED PHASE 160 MHZ DDR CLOCK

                    CLK_40M_BUF_RECD    =>  CLK_40M_BUF_RECD,               -- RECEIVED 40 MHZ REF CLOCK DISTRIBUTED BY THE 'MASTER FPGA' ON THE MASTER DCB CONFIGURED COMET
                    MASTER_POR_B        =>  MASTER_POR_B,                   -- MASTER POWER-ON-RESET: SYNCHRONOUS RESET WAITS FOR CCC1 TO BE LOCKED AND STABLE

                    DCB_SALT_SEL        =>  DCB_SALT_SEL,                   -- '1'=DCB, '0'=SALT
                    ALIGN_MODE_EN       =>  OP_MODE(5),                     -- '1'= AUTO ALIGN ENABLED
                    SIM_MODE            =>  SIM_MODE,                       -- GPIO_1:  '1' = SIM MODE, '0' = REAL TIME OP MODE

                    MAN_BIT_OS          =>  "0000",                         -- MANUAL BIT OFFSET ADJUSTMENT (THESE 3 MANUAL MODE INPUTS CAN BE HARD-WIRED INACTIVE AT NEXT LEVEL)
                    MAN_PHASE_ADJ       =>  "00000",                        -- MANUAL PHASE ADJUSTMENT 
                    MAN_AUTO_ALIGN      =>  '0',                            -- '1'=MANUAL , '0'= AUTO PHASE ADJ MODE

                    ELINK0_DDR_R        =>  ELK0_IN_R,                    	-- ELINK0 DDR RISE SERIAL DATA
                    ELINK0_DDR_F        =>  ELK0_IN_F,                    	-- ELINK0 DDR FALL SERIAL DATA
                    TFC_DDR_R           =>  TFC_IN_R,                    	-- TFC DDR RISE SERIAL DATA
                    TFC_DDR_F           =>  TFC_IN_F,                    	-- TFC DDR FALL SERIAL DATA

                    CH0_RAM_BPORT       =>  TFC_RX_SER_WORD,                -- SERIAL DATA GETS ROUTED TO THE RAM CH0 STORAGE ALLOCATED FOR TFC WHEN FPGA CONSIGD AS SALT
                    CH1_RAM_BPORT       =>  ELK_RX_SER_WORD(0),             -- SERIAL DATA GETS ROUTED TO THE RAM CH1 STORAGE ALLOCATED FOR ELINK0
                    P_BIT_OS_SEL        =>  BIT_OS_SEL,                     -- BIT ALIGNMENT OFFSET VALUE DETERMINED BY MASTER DES320M AND USE DY ALL SLAVES
                    P_ALIGN_ACTIVE      =>  ALIGN_ACTIVE,                   -- '1' INDICATES THE AUTO ALIGN FUNCTION IS ACTIVE

                    P_CCC_RX_CLK_LOCK   =>  CCC_RX_CLK_LOCK,                -- CCC2 LOCK STATUS
                    P_CCC_160M_ADJ      =>  CCC_160M_ADJ,                   -- CCC2 PHASE ADJUSTABLE 160 MHZ CLOCK--BASELINE PHASE
                    P_CCC_160M_1ADJ     =>  OPEN,                           -- CCC2 PHASE ADJUSTABLE 160 MHZ CLOCK--ADD'L PHASE OFFSET 1 
                    P_CCC_160M_2ADJ     =>  OPEN                          	-- CCC2 PHASE ADJUSTABLE 160 MHZ CLOCK--ADD'L PHASE OFFSET 2
                );

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ELINK 1 -----OPERATES AS A SLAVE DESERIALIER 
--       +++++++INVERTED SERIAL DATA PATH PER NOTE AT BEGINNING OF THIS FILE+++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
U_ELK1_CH:ELINK_SLAVE_INV
		 PORT MAP (
					CLK_40M_GL        	=>	CLK_40M_GL,                     -- CCC#1 FIXED 40MHZ CLOCK OUT
					CCC_160M_FXD      	=>	CCC_160M_FXD,					-- CCC#1 FIXED 160MHZ CLOCK
					CCC_160M_ADJ      	=>	CCC_160M_ADJ,                   -- CCC#2 ADJ 160MHZ CLOCK

					DEV_RST_B           =>	DEV_RST_B,                      -- ACTIVE LOW ASYNC RESET --DEDICATED COMET BOARD RC TIME CONSTANT
					MASTER_POR_B      	=>	MASTER_POR_B,                   -- MASTER_POR_B
					MASTER_DCB_POR_B    =>	MASTER_DCB_POR_B,               -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR DCB CONFIGS
					MASTER_SALT_POR_B   =>	MASTER_SALT_POR_B,              -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR SALT CONFIGS

					DCB_SALT_SEL        =>	DCB_SALT_SEL,                 	-- '1'= DCB MODE (IE TFC MASTER TX ENABLED) // '0'=SALT HYBRID MODE (IE TFC MASTER RX W/ SYNC MODE ENABLED)
				
					OP_MODE1_SPE      	=>	OP_MODE(1),                     -- OP_MODE BIT 1 = SYNC PATT EN
					F_ALIGN_PATT        =>	F_ALIGN_PATT, 					-- FIXED SYNC / ALIGNMENT PATTERN BYTE
					PATT_ELK_DAT		=>	PATT_ELK_DAT(1), 				-- ELINK PATTERN TX DATA

					BIT_OS_SEL          =>	BIT_OS_SEL,   					-- BIT ALIGNMENT OFFSET VALUE DETERMINED BY MASTER DES320M AND USE DY ALL SLAVES
				
					ELK_DAT_P         	=>	ELK1_DAT_P,                     -- SERIAL LVDS ELINK1 DATA BIDIR PORT
					ELK_DAT_N         	=>	ELK1_DAT_N,						--	""

					ELK_RX_SER_WORD     =>	ELK_RX_SER_WORD(1)            	-- OUTPUT WORD OF THE ELINK DE-SERIALIZER
				);
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ELINK 2 -----OPERATES AS A SLAVE DESERIALIER
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
U_ELK2_CH:ELINK_SLAVE
		 PORT MAP (
					CLK_40M_GL        	=>	CLK_40M_GL,                     -- CCC#1 FIXED 40MHZ CLOCK OUT
					CCC_160M_FXD      	=>	CCC_160M_FXD,					-- CCC#1 FIXED 160MHZ CLOCK
					CCC_160M_ADJ      	=>	CCC_160M_ADJ,                   -- CCC#2 ADJ 160MHZ CLOCK

					DEV_RST_B           =>	DEV_RST_B,                      -- ACTIVE LOW ASYNC RESET --DEDICATED COMET BOARD RC TIME CONSTANT
					MASTER_POR_B      	=>	MASTER_POR_B,                   -- MASTER_POR_B
					MASTER_DCB_POR_B    =>	MASTER_DCB_POR_B,               -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR DCB CONFIGS
					MASTER_SALT_POR_B   =>	MASTER_SALT_POR_B,              -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR SALT CONFIGS

					DCB_SALT_SEL        =>	DCB_SALT_SEL,                 	-- '1'= DCB MODE (IE TFC MASTER TX ENABLED) // '0'=SALT HYBRID MODE (IE TFC MASTER RX W/ SYNC MODE ENABLED)
				
					OP_MODE1_SPE      	=>	OP_MODE(1),                     -- OP_MODE BIT 1 = SYNC PATT EN
					F_ALIGN_PATT        =>	F_ALIGN_PATT, 					-- FIXED SYNC / ALIGNMENT PATTERN BYTE
					PATT_ELK_DAT		=>	PATT_ELK_DAT(2), 				-- ELINK PATTERN TX DATA

					BIT_OS_SEL          =>	BIT_OS_SEL,   					-- BIT ALIGNMENT OFFSET VALUE DETERMINED BY MASTER DES320M AND USE DY ALL SLAVES
				
					ELK_DAT_P         	=>	ELK2_DAT_P,                     -- SERIAL LVDS ELINK2 DATA BIDIR PORT
					ELK_DAT_N         	=>	ELK2_DAT_N,						--	""

					ELK_RX_SER_WORD     =>	ELK_RX_SER_WORD(2)            	-- OUTPUT WORD OF THE ELINK DE-SERIALIZER
				);

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ELINK 3 -----OPERATES AS A SLAVE DESERIALIER
--       +++++++INVERTED SERIAL DATA PATH PER NOTE AT BEGINNING OF THIS FILE+++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
U_ELK3_CH:ELINK_SLAVE_INV
		 PORT MAP (
					CLK_40M_GL        	=>	CLK_40M_GL,                     -- CCC#1 FIXED 40MHZ CLOCK OUT
					CCC_160M_FXD      	=>	CCC_160M_FXD,					-- CCC#1 FIXED 160MHZ CLOCK
					CCC_160M_ADJ      	=>	CCC_160M_ADJ,                   -- CCC#2 ADJ 160MHZ CLOCK

					DEV_RST_B           =>	DEV_RST_B,                      -- ACTIVE LOW ASYNC RESET --DEDICATED COMET BOARD RC TIME CONSTANT
					MASTER_POR_B      	=>	MASTER_POR_B,                   -- MASTER_POR_B
					MASTER_DCB_POR_B    =>	MASTER_DCB_POR_B,               -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR DCB CONFIGS
					MASTER_SALT_POR_B   =>	MASTER_SALT_POR_B,              -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR SALT CONFIGS

					DCB_SALT_SEL        =>	DCB_SALT_SEL,                 	-- '1'= DCB MODE (IE TFC MASTER TX ENABLED) // '0'=SALT HYBRID MODE (IE TFC MASTER RX W/ SYNC MODE ENABLED)
				
					OP_MODE1_SPE      	=>	OP_MODE(1),                     -- OP_MODE BIT 1 = SYNC PATT EN
					F_ALIGN_PATT        =>	F_ALIGN_PATT, 					-- FIXED SYNC / ALIGNMENT PATTERN BYTE
					PATT_ELK_DAT		=>	PATT_ELK_DAT(3), 				-- ELINK PATTERN TX DATA

					BIT_OS_SEL          =>	BIT_OS_SEL,   					-- BIT ALIGNMENT OFFSET VALUE DETERMINED BY MASTER DES320M AND USE DY ALL SLAVES
				
					ELK_DAT_P         	=>	ELK3_DAT_P,                     -- SERIAL LVDS ELINK0 DATA BIDIR PORT
					ELK_DAT_N         	=>	ELK3_DAT_N,						--	""

					ELK_RX_SER_WORD     =>	ELK_RX_SER_WORD(3)            	-- OUTPUT WORD OF THE ELINK DE-SERIALIZER
				);

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ELINK 4 -----OPERATES AS A SLAVE DESERIALIER
--       +++++++INVERTED SERIAL DATA PATH PER NOTE AT BEGINNING OF THIS FILE+++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
U_ELK4_CH:ELINK_SLAVE_INV
		 PORT MAP (
					CLK_40M_GL        	=>	CLK_40M_GL,                     -- CCC#1 FIXED 40MHZ CLOCK OUT
					CCC_160M_FXD      	=>	CCC_160M_FXD,					-- CCC#1 FIXED 160MHZ CLOCK
					CCC_160M_ADJ      	=>	CCC_160M_ADJ,                   -- CCC#2 ADJ 160MHZ CLOCK

					DEV_RST_B           =>	DEV_RST_B,                      -- ACTIVE LOW ASYNC RESET --DEDICATED COMET BOARD RC TIME CONSTANT
					MASTER_POR_B      	=>	MASTER_POR_B,                   -- MASTER_POR_B
					MASTER_DCB_POR_B    =>	MASTER_DCB_POR_B,               -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR DCB CONFIGS
					MASTER_SALT_POR_B   =>	MASTER_SALT_POR_B,              -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR SALT CONFIGS

					DCB_SALT_SEL        =>	DCB_SALT_SEL,                 	-- '1'= DCB MODE (IE TFC MASTER TX ENABLED) // '0'=SALT HYBRID MODE (IE TFC MASTER RX W/ SYNC MODE ENABLED)
				
					OP_MODE1_SPE      	=>	OP_MODE(1),                     -- OP_MODE BIT 1 = SYNC PATT EN
					F_ALIGN_PATT        =>	F_ALIGN_PATT, 					-- FIXED SYNC / ALIGNMENT PATTERN BYTE
					PATT_ELK_DAT		=>	PATT_ELK_DAT(4), 				-- ELINK PATTERN TX DATA

					BIT_OS_SEL          =>	BIT_OS_SEL,   					-- BIT ALIGNMENT OFFSET VALUE DETERMINED BY MASTER DES320M AND USE DY ALL SLAVES
				
					ELK_DAT_P         	=>	ELK4_DAT_P,                     -- SERIAL LVDS ELINK0 DATA BIDIR PORT
					ELK_DAT_N         	=>	ELK4_DAT_N,						--	""

					ELK_RX_SER_WORD     =>	ELK_RX_SER_WORD(4)            	-- OUTPUT WORD OF THE ELINK DE-SERIALIZER
				);

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ELINK 5 -----OPERATES AS A SLAVE DESERIALIER
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
U_ELK5_CH:ELINK_SLAVE
		 PORT MAP (
					CLK_40M_GL        	=>	CLK_40M_GL,                     -- CCC#1 FIXED 40MHZ CLOCK OUT
					CCC_160M_FXD      	=>	CCC_160M_FXD,					-- CCC#1 FIXED 160MHZ CLOCK
					CCC_160M_ADJ      	=>	CCC_160M_ADJ,                   -- CCC#2 ADJ 160MHZ CLOCK

					DEV_RST_B           =>	DEV_RST_B,                      -- ACTIVE LOW ASYNC RESET --DEDICATED COMET BOARD RC TIME CONSTANT
					MASTER_POR_B      	=>	MASTER_POR_B,                   -- MASTER_POR_B
					MASTER_DCB_POR_B    =>	MASTER_DCB_POR_B,               -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR DCB CONFIGS
					MASTER_SALT_POR_B   =>	MASTER_SALT_POR_B,              -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR SALT CONFIGS

					DCB_SALT_SEL        =>	DCB_SALT_SEL,                 	-- '1'= DCB MODE (IE TFC MASTER TX ENABLED) // '0'=SALT HYBRID MODE (IE TFC MASTER RX W/ SYNC MODE ENABLED)
				
					OP_MODE1_SPE      	=>	OP_MODE(1),                     -- OP_MODE BIT 1 = SYNC PATT EN
					F_ALIGN_PATT        =>	F_ALIGN_PATT, 					-- FIXED SYNC / ALIGNMENT PATTERN BYTE
					PATT_ELK_DAT		=>	PATT_ELK_DAT(5), 				-- ELINK PATTERN TX DATA

					BIT_OS_SEL          =>	BIT_OS_SEL,   					-- BIT ALIGNMENT OFFSET VALUE DETERMINED BY MASTER DES320M AND USE DY ALL SLAVES
				
					ELK_DAT_P         	=>	ELK5_DAT_P,                     -- SERIAL LVDS ELINK0 DATA BIDIR PORT
					ELK_DAT_N         	=>	ELK5_DAT_N,						--	""

					ELK_RX_SER_WORD     =>	ELK_RX_SER_WORD(5)            	-- OUTPUT WORD OF THE ELINK DE-SERIALIZER
				);

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ELINK 6 -----OPERATES AS A SLAVE DESERIALIER
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
U_ELK6_CH:ELINK_SLAVE
		 PORT MAP (
					CLK_40M_GL        	=>	CLK_40M_GL,                     -- CCC#1 FIXED 40MHZ CLOCK OUT
					CCC_160M_FXD      	=>	CCC_160M_FXD,					-- CCC#1 FIXED 160MHZ CLOCK
					CCC_160M_ADJ      	=>	CCC_160M_ADJ,                   -- CCC#2 ADJ 160MHZ CLOCK

					DEV_RST_B           =>	DEV_RST_B,                      -- ACTIVE LOW ASYNC RESET --DEDICATED COMET BOARD RC TIME CONSTANT
					MASTER_POR_B      	=>	MASTER_POR_B,                   -- MASTER_POR_B
					MASTER_DCB_POR_B    =>	MASTER_DCB_POR_B,               -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR DCB CONFIGS
					MASTER_SALT_POR_B   =>	MASTER_SALT_POR_B,              -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR SALT CONFIGS

					DCB_SALT_SEL        =>	DCB_SALT_SEL,                 	-- '1'= DCB MODE (IE TFC MASTER TX ENABLED) // '0'=SALT HYBRID MODE (IE TFC MASTER RX W/ SYNC MODE ENABLED)
				
					OP_MODE1_SPE      	=>	OP_MODE(1),                     -- OP_MODE BIT 1 = SYNC PATT EN
					F_ALIGN_PATT        =>	F_ALIGN_PATT, 					-- FIXED SYNC / ALIGNMENT PATTERN BYTE
					PATT_ELK_DAT		=>	PATT_ELK_DAT(6), 				-- ELINK PATTERN TX DATA

					BIT_OS_SEL          =>	BIT_OS_SEL,   					-- BIT ALIGNMENT OFFSET VALUE DETERMINED BY MASTER DES320M AND USE DY ALL SLAVES
				
					ELK_DAT_P         	=>	ELK6_DAT_P,                     -- SERIAL LVDS ELINK0 DATA BIDIR PORT
					ELK_DAT_N         	=>	ELK6_DAT_N,						--	""

					ELK_RX_SER_WORD     =>	ELK_RX_SER_WORD(6)            	-- OUTPUT WORD OF THE ELINK DE-SERIALIZER
				);

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ELINK 7 -----OPERATES AS A SLAVE DESERIALIER
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
U_ELK7_CH:ELINK_SLAVE
		 PORT MAP (
					CLK_40M_GL        	=>	CLK_40M_GL,                     -- CCC#1 FIXED 40MHZ CLOCK OUT
					CCC_160M_FXD      	=>	CCC_160M_FXD,					-- CCC#1 FIXED 160MHZ CLOCK
					CCC_160M_ADJ      	=>	CCC_160M_ADJ,                   -- CCC#2 ADJ 160MHZ CLOCK

					DEV_RST_B           =>	DEV_RST_B,                      -- ACTIVE LOW ASYNC RESET --DEDICATED COMET BOARD RC TIME CONSTANT
					MASTER_POR_B      	=>	MASTER_POR_B,                   -- MASTER_POR_B
					MASTER_DCB_POR_B    =>	MASTER_DCB_POR_B,               -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR DCB CONFIGS
					MASTER_SALT_POR_B   =>	MASTER_SALT_POR_B,              -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR SALT CONFIGS

					DCB_SALT_SEL        =>	DCB_SALT_SEL,                 	-- '1'= DCB MODE (IE TFC MASTER TX ENABLED) // '0'=SALT HYBRID MODE (IE TFC MASTER RX W/ SYNC MODE ENABLED)
				
					OP_MODE1_SPE      	=>	OP_MODE(1),                     -- OP_MODE BIT 1 = SYNC PATT EN
					F_ALIGN_PATT        =>	F_ALIGN_PATT, 					-- FIXED SYNC / ALIGNMENT PATTERN BYTE
					PATT_ELK_DAT		=>	PATT_ELK_DAT(7), 				-- ELINK PATTERN TX DATA

					BIT_OS_SEL          =>	BIT_OS_SEL,   					-- BIT ALIGNMENT OFFSET VALUE DETERMINED BY MASTER DES320M AND USE DY ALL SLAVES
				
					ELK_DAT_P         	=>	ELK7_DAT_P,                     -- SERIAL LVDS ELINK0 DATA BIDIR PORT
					ELK_DAT_N         	=>	ELK7_DAT_N,						--	""

					ELK_RX_SER_WORD     =>	ELK_RX_SER_WORD(7)            	-- OUTPUT WORD OF THE ELINK DE-SERIALIZER
				);

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ELINK 8 -----OPERATES AS A SLAVE DESERIALIER
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
U_ELK8_CH:ELINK_SLAVE
		 PORT MAP (
					CLK_40M_GL        	=>	CLK_40M_GL,                     -- CCC#1 FIXED 40MHZ CLOCK OUT
					CCC_160M_FXD      	=>	CCC_160M_FXD,					-- CCC#1 FIXED 160MHZ CLOCK
					CCC_160M_ADJ      	=>	CCC_160M_ADJ,                   -- CCC#2 ADJ 160MHZ CLOCK

					DEV_RST_B           =>	DEV_RST_B,                      -- ACTIVE LOW ASYNC RESET --DEDICATED COMET BOARD RC TIME CONSTANT
					MASTER_POR_B      	=>	MASTER_POR_B,                   -- MASTER_POR_B
					MASTER_DCB_POR_B    =>	MASTER_DCB_POR_B,               -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR DCB CONFIGS
					MASTER_SALT_POR_B   =>	MASTER_SALT_POR_B,              -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR SALT CONFIGS

					DCB_SALT_SEL        =>	DCB_SALT_SEL,                 	-- '1'= DCB MODE (IE TFC MASTER TX ENABLED) // '0'=SALT HYBRID MODE (IE TFC MASTER RX W/ SYNC MODE ENABLED)
				
					OP_MODE1_SPE      	=>	OP_MODE(1),                     -- OP_MODE BIT 1 = SYNC PATT EN
					F_ALIGN_PATT        =>	F_ALIGN_PATT, 					-- FIXED SYNC / ALIGNMENT PATTERN BYTE
					PATT_ELK_DAT		=>	PATT_ELK_DAT(8), 				-- ELINK PATTERN TX DATA

					BIT_OS_SEL          =>	BIT_OS_SEL,   					-- BIT ALIGNMENT OFFSET VALUE DETERMINED BY MASTER DES320M AND USE DY ALL SLAVES
				
					ELK_DAT_P         	=>	ELK8_DAT_P,                     -- SERIAL LVDS ELINK0 DATA BIDIR PORT
					ELK_DAT_N         	=>	ELK8_DAT_N,						--	""

					ELK_RX_SER_WORD     =>	ELK_RX_SER_WORD(8)            	-- OUTPUT WORD OF THE ELINK DE-SERIALIZER
				);

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ELINK 9 -----OPERATES AS A SLAVE DESERIALIER
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
U_ELK9_CH:ELINK_SLAVE
		 PORT MAP (
					CLK_40M_GL        	=>	CLK_40M_GL,                     -- CCC#1 FIXED 40MHZ CLOCK OUT
					CCC_160M_FXD      	=>	CCC_160M_FXD,					-- CCC#1 FIXED 160MHZ CLOCK
					CCC_160M_ADJ      	=>	CCC_160M_ADJ,                   -- CCC#2 ADJ 160MHZ CLOCK

					DEV_RST_B           =>	DEV_RST_B,                      -- ACTIVE LOW ASYNC RESET --DEDICATED COMET BOARD RC TIME CONSTANT
					MASTER_POR_B      	=>	MASTER_POR_B,                   -- MASTER_POR_B
					MASTER_DCB_POR_B    =>	MASTER_DCB_POR_B,               -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR DCB CONFIGS
					MASTER_SALT_POR_B   =>	MASTER_SALT_POR_B,              -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR SALT CONFIGS

					DCB_SALT_SEL        =>	DCB_SALT_SEL,                 	-- '1'= DCB MODE (IE TFC MASTER TX ENABLED) // '0'=SALT HYBRID MODE (IE TFC MASTER RX W/ SYNC MODE ENABLED)
				
					OP_MODE1_SPE      	=>	OP_MODE(1),                     -- OP_MODE BIT 1 = SYNC PATT EN
					F_ALIGN_PATT        =>	F_ALIGN_PATT, 					-- FIXED SYNC / ALIGNMENT PATTERN BYTE
					PATT_ELK_DAT		=>	PATT_ELK_DAT(9), 				-- ELINK PATTERN TX DATA

					BIT_OS_SEL          =>	BIT_OS_SEL,   					-- BIT ALIGNMENT OFFSET VALUE DETERMINED BY MASTER DES320M AND USE DY ALL SLAVES
				
					ELK_DAT_P         	=>	ELK9_DAT_P,                     -- SERIAL LVDS ELINK0 DATA BIDIR PORT
					ELK_DAT_N         	=>	ELK9_DAT_N,						--	""

					ELK_RX_SER_WORD     =>	ELK_RX_SER_WORD(9)            	-- OUTPUT WORD OF THE ELINK DE-SERIALIZER
				);

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ELINK 10 -----OPERATES AS A SLAVE DESERIALIER
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
U_ELK10_CH:ELINK_SLAVE
		 PORT MAP (
					CLK_40M_GL        	=>	CLK_40M_GL,                     -- CCC#1 FIXED 40MHZ CLOCK OUT
					CCC_160M_FXD      	=>	CCC_160M_FXD,					-- CCC#1 FIXED 160MHZ CLOCK
					CCC_160M_ADJ      	=>	CCC_160M_ADJ,                   -- CCC#2 ADJ 160MHZ CLOCK

					DEV_RST_B           =>	DEV_RST_B,                      -- ACTIVE LOW ASYNC RESET --DEDICATED COMET BOARD RC TIME CONSTANT
					MASTER_POR_B      	=>	MASTER_POR_B,                   -- MASTER_POR_B
					MASTER_DCB_POR_B    =>	MASTER_DCB_POR_B,               -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR DCB CONFIGS
					MASTER_SALT_POR_B   =>	MASTER_SALT_POR_B,              -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR SALT CONFIGS

					DCB_SALT_SEL        =>	DCB_SALT_SEL,                 	-- '1'= DCB MODE (IE TFC MASTER TX ENABLED) // '0'=SALT HYBRID MODE (IE TFC MASTER RX W/ SYNC MODE ENABLED)
				
					OP_MODE1_SPE      	=>	OP_MODE(1),                     -- OP_MODE BIT 1 = SYNC PATT EN
					F_ALIGN_PATT        =>	F_ALIGN_PATT, 					-- FIXED SYNC / ALIGNMENT PATTERN BYTE
					PATT_ELK_DAT		=>	PATT_ELK_DAT(10), 				-- ELINK PATTERN TX DATA

					BIT_OS_SEL          =>	BIT_OS_SEL,   					-- BIT ALIGNMENT OFFSET VALUE DETERMINED BY MASTER DES320M AND USE DY ALL SLAVES
				
					ELK_DAT_P         	=>	ELK10_DAT_P,                    -- SERIAL LVDS ELINK0 DATA BIDIR PORT
					ELK_DAT_N         	=>	ELK10_DAT_N,					--	""

					ELK_RX_SER_WORD     =>	ELK_RX_SER_WORD(10)            	-- OUTPUT WORD OF THE ELINK DE-SERIALIZER
				);

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ELINK 11 -----OPERATES AS A SLAVE DESERIALIER
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
U_ELK11_CH:ELINK_SLAVE
		 PORT MAP (
					CLK_40M_GL        	=>	CLK_40M_GL,                     -- CCC#1 FIXED 40MHZ CLOCK OUT
					CCC_160M_FXD      	=>	CCC_160M_FXD,					-- CCC#1 FIXED 160MHZ CLOCK
					CCC_160M_ADJ      	=>	CCC_160M_ADJ,                   -- CCC#2 ADJ 160MHZ CLOCK

					DEV_RST_B           =>	DEV_RST_B,                      -- ACTIVE LOW ASYNC RESET --DEDICATED COMET BOARD RC TIME CONSTANT
					MASTER_POR_B      	=>	MASTER_POR_B,                   -- MASTER_POR_B
					MASTER_DCB_POR_B    =>	MASTER_DCB_POR_B,               -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR DCB CONFIGS
					MASTER_SALT_POR_B   =>	MASTER_SALT_POR_B,              -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR SALT CONFIGS

					DCB_SALT_SEL        =>	DCB_SALT_SEL,                 	-- '1'= DCB MODE (IE TFC MASTER TX ENABLED) // '0'=SALT HYBRID MODE (IE TFC MASTER RX W/ SYNC MODE ENABLED)
				
					OP_MODE1_SPE      	=>	OP_MODE(1),                     -- OP_MODE BIT 1 = SYNC PATT EN
					F_ALIGN_PATT        =>	F_ALIGN_PATT, 					-- FIXED SYNC / ALIGNMENT PATTERN BYTE
					PATT_ELK_DAT		=>	PATT_ELK_DAT(11), 				-- ELINK PATTERN TX DATA

					BIT_OS_SEL          =>	BIT_OS_SEL,   					-- BIT ALIGNMENT OFFSET VALUE DETERMINED BY MASTER DES320M AND USE DY ALL SLAVES
				
					ELK_DAT_P         	=>	ELK11_DAT_P,                    -- SERIAL LVDS ELINK0 DATA BIDIR PORT
					ELK_DAT_N         	=>	ELK11_DAT_N,					--	""

					ELK_RX_SER_WORD     =>	ELK_RX_SER_WORD(11)            	-- OUTPUT WORD OF THE ELINK DE-SERIALIZER
				);

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ELINK 12 -----OPERATES AS A SLAVE DESERIALIER
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
U_ELK12_CH:ELINK_SLAVE
		 PORT MAP (
					CLK_40M_GL        	=>	CLK_40M_GL,                     -- CCC#1 FIXED 40MHZ CLOCK OUT
					CCC_160M_FXD      	=>	CCC_160M_FXD,					-- CCC#1 FIXED 160MHZ CLOCK
					CCC_160M_ADJ      	=>	CCC_160M_ADJ,                   -- CCC#2 ADJ 160MHZ CLOCK

					DEV_RST_B           =>	DEV_RST_B,                      -- ACTIVE LOW ASYNC RESET --DEDICATED COMET BOARD RC TIME CONSTANT
					MASTER_POR_B      	=>	MASTER_POR_B,                   -- MASTER_POR_B
					MASTER_DCB_POR_B    =>	MASTER_DCB_POR_B,               -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR DCB CONFIGS
					MASTER_SALT_POR_B   =>	MASTER_SALT_POR_B,              -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR SALT CONFIGS

					DCB_SALT_SEL        =>	DCB_SALT_SEL,                 	-- '1'= DCB MODE (IE TFC MASTER TX ENABLED) // '0'=SALT HYBRID MODE (IE TFC MASTER RX W/ SYNC MODE ENABLED)
				
					OP_MODE1_SPE      	=>	OP_MODE(1),                     -- OP_MODE BIT 1 = SYNC PATT EN
					F_ALIGN_PATT        =>	F_ALIGN_PATT, 					-- FIXED SYNC / ALIGNMENT PATTERN BYTE
					PATT_ELK_DAT		=>	PATT_ELK_DAT(12), 				-- ELINK PATTERN TX DATA

					BIT_OS_SEL          =>	BIT_OS_SEL,   					-- BIT ALIGNMENT OFFSET VALUE DETERMINED BY MASTER DES320M AND USE DY ALL SLAVES
				
					ELK_DAT_P         	=>	ELK12_DAT_P,                    -- SERIAL LVDS ELINK0 DATA BIDIR PORT
					ELK_DAT_N         	=>	ELK12_DAT_N,					--	""

					ELK_RX_SER_WORD     =>	ELK_RX_SER_WORD(12)            	-- OUTPUT WORD OF THE ELINK DE-SERIALIZER
				);

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ELINK 13 -----OPERATES AS A SLAVE DESERIALIER
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
U_ELK13_CH:ELINK_SLAVE
		 PORT MAP (
					CLK_40M_GL        	=>	CLK_40M_GL,                     -- CCC#1 FIXED 40MHZ CLOCK OUT
					CCC_160M_FXD      	=>	CCC_160M_FXD,					-- CCC#1 FIXED 160MHZ CLOCK
					CCC_160M_ADJ      	=>	CCC_160M_ADJ,                   -- CCC#2 ADJ 160MHZ CLOCK

					DEV_RST_B           =>	DEV_RST_B,                      -- ACTIVE LOW ASYNC RESET --DEDICATED COMET BOARD RC TIME CONSTANT
					MASTER_POR_B      	=>	MASTER_POR_B,                   -- MASTER_POR_B
					MASTER_DCB_POR_B    =>	MASTER_DCB_POR_B,               -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR DCB CONFIGS
					MASTER_SALT_POR_B   =>	MASTER_SALT_POR_B,              -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR SALT CONFIGS

					DCB_SALT_SEL        =>	DCB_SALT_SEL,                 	-- '1'= DCB MODE (IE TFC MASTER TX ENABLED) // '0'=SALT HYBRID MODE (IE TFC MASTER RX W/ SYNC MODE ENABLED)
				
					OP_MODE1_SPE      	=>	OP_MODE(1),                     -- OP_MODE BIT 1 = SYNC PATT EN
					F_ALIGN_PATT        =>	F_ALIGN_PATT, 					-- FIXED SYNC / ALIGNMENT PATTERN BYTE
					PATT_ELK_DAT		=>	PATT_ELK_DAT(13), 				-- ELINK PATTERN TX DATA

					BIT_OS_SEL          =>	BIT_OS_SEL,   					-- BIT ALIGNMENT OFFSET VALUE DETERMINED BY MASTER DES320M AND USE DY ALL SLAVES
				
					ELK_DAT_P         	=>	ELK13_DAT_P,                    -- SERIAL LVDS ELINK0 DATA BIDIR PORT
					ELK_DAT_N         	=>	ELK13_DAT_N,					--	""

					ELK_RX_SER_WORD     =>	ELK_RX_SER_WORD(13)            	-- OUTPUT WORD OF THE ELINK DE-SERIALIZER
				);

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ELINK 14 -----OPERATES AS A SLAVE DESERIALIER
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
U_ELK14_CH:ELINK_SLAVE
		 PORT MAP (
					CLK_40M_GL        	=>	CLK_40M_GL,                     -- CCC#1 FIXED 40MHZ CLOCK OUT
					CCC_160M_FXD      	=>	CCC_160M_FXD,					-- CCC#1 FIXED 160MHZ CLOCK
					CCC_160M_ADJ      	=>	CCC_160M_ADJ,                   -- CCC#2 ADJ 160MHZ CLOCK

					DEV_RST_B           =>	DEV_RST_B,                      -- ACTIVE LOW ASYNC RESET --DEDICATED COMET BOARD RC TIME CONSTANT
					MASTER_POR_B      	=>	MASTER_POR_B,                   -- MASTER_POR_B
					MASTER_DCB_POR_B    =>	MASTER_DCB_POR_B,               -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR DCB CONFIGS
					MASTER_SALT_POR_B   =>	MASTER_SALT_POR_B,              -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR SALT CONFIGS

					DCB_SALT_SEL        =>	DCB_SALT_SEL,                 	-- '1'= DCB MODE (IE TFC MASTER TX ENABLED) // '0'=SALT HYBRID MODE (IE TFC MASTER RX W/ SYNC MODE ENABLED)
				
					OP_MODE1_SPE      	=>	OP_MODE(1),                     -- OP_MODE BIT 1 = SYNC PATT EN
					F_ALIGN_PATT        =>	F_ALIGN_PATT, 					-- FIXED SYNC / ALIGNMENT PATTERN BYTE
					PATT_ELK_DAT		=>	PATT_ELK_DAT(14), 				-- ELINK PATTERN TX DATA

					BIT_OS_SEL          =>	BIT_OS_SEL,   					-- BIT ALIGNMENT OFFSET VALUE DETERMINED BY MASTER DES320M AND USE DY ALL SLAVES
				
					ELK_DAT_P         	=>	ELK14_DAT_P,                    -- SERIAL LVDS ELINK0 DATA BIDIR PORT
					ELK_DAT_N         	=>	ELK14_DAT_N,					--	""

					ELK_RX_SER_WORD     =>	ELK_RX_SER_WORD(14)            	-- OUTPUT WORD OF THE ELINK DE-SERIALIZER
				);

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ELINK 15 -----OPERATES AS A SLAVE DESERIALIER
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
U_ELK15_CH:ELINK_SLAVE
		 PORT MAP (
					CLK_40M_GL        	=>	CLK_40M_GL,                     -- CCC#1 FIXED 40MHZ CLOCK OUT
					CCC_160M_FXD      	=>	CCC_160M_FXD,					-- CCC#1 FIXED 160MHZ CLOCK
					CCC_160M_ADJ      	=>	CCC_160M_ADJ,                   -- CCC#2 ADJ 160MHZ CLOCK

					DEV_RST_B           =>	DEV_RST_B,                      -- ACTIVE LOW ASYNC RESET --DEDICATED COMET BOARD RC TIME CONSTANT
					MASTER_POR_B      	=>	MASTER_POR_B,                   -- MASTER_POR_B
					MASTER_DCB_POR_B    =>	MASTER_DCB_POR_B,               -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR DCB CONFIGS
					MASTER_SALT_POR_B   =>	MASTER_SALT_POR_B,              -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR SALT CONFIGS

					DCB_SALT_SEL        =>	DCB_SALT_SEL,                 	-- '1'= DCB MODE (IE TFC MASTER TX ENABLED) // '0'=SALT HYBRID MODE (IE TFC MASTER RX W/ SYNC MODE ENABLED)
				
					OP_MODE1_SPE      	=>	OP_MODE(1),                     -- OP_MODE BIT 1 = SYNC PATT EN
					F_ALIGN_PATT        =>	F_ALIGN_PATT, 					-- FIXED SYNC / ALIGNMENT PATTERN BYTE
					PATT_ELK_DAT		=>	PATT_ELK_DAT(15), 				-- ELINK PATTERN TX DATA

					BIT_OS_SEL          =>	BIT_OS_SEL,   					-- BIT ALIGNMENT OFFSET VALUE DETERMINED BY MASTER DES320M AND USE DY ALL SLAVES
				
					ELK_DAT_P         	=>	ELK15_DAT_P,                    -- SERIAL LVDS ELINK0 DATA BIDIR PORT
					ELK_DAT_N         	=>	ELK15_DAT_N,					--	""

					ELK_RX_SER_WORD     =>	ELK_RX_SER_WORD(15)            	-- OUTPUT WORD OF THE ELINK DE-SERIALIZER
				);

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ELINK 16 -----OPERATES AS A SLAVE DESERIALIER
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
U_ELK16_CH:ELINK_SLAVE
		 PORT MAP (
					CLK_40M_GL        	=>	CLK_40M_GL,                     -- CCC#1 FIXED 40MHZ CLOCK OUT
					CCC_160M_FXD      	=>	CCC_160M_FXD,					-- CCC#1 FIXED 160MHZ CLOCK
					CCC_160M_ADJ      	=>	CCC_160M_ADJ,                   -- CCC#2 ADJ 160MHZ CLOCK

					DEV_RST_B           =>	DEV_RST_B,                      -- ACTIVE LOW ASYNC RESET --DEDICATED COMET BOARD RC TIME CONSTANT
					MASTER_POR_B      	=>	MASTER_POR_B,                   -- MASTER_POR_B
					MASTER_DCB_POR_B    =>	MASTER_DCB_POR_B,               -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR DCB CONFIGS
					MASTER_SALT_POR_B   =>	MASTER_SALT_POR_B,              -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR SALT CONFIGS

					DCB_SALT_SEL        =>	DCB_SALT_SEL,                 	-- '1'= DCB MODE (IE TFC MASTER TX ENABLED) // '0'=SALT HYBRID MODE (IE TFC MASTER RX W/ SYNC MODE ENABLED)
				
					OP_MODE1_SPE      	=>	OP_MODE(1),                     -- OP_MODE BIT 1 = SYNC PATT EN
					F_ALIGN_PATT        =>	F_ALIGN_PATT, 					-- FIXED SYNC / ALIGNMENT PATTERN BYTE
					PATT_ELK_DAT		=>	PATT_ELK_DAT(16), 				-- ELINK PATTERN TX DATA

					BIT_OS_SEL          =>	BIT_OS_SEL,   					-- BIT ALIGNMENT OFFSET VALUE DETERMINED BY MASTER DES320M AND USE DY ALL SLAVES
				
					ELK_DAT_P         	=>	ELK16_DAT_P,                    -- SERIAL LVDS ELINK0 DATA BIDIR PORT
					ELK_DAT_N         	=>	ELK16_DAT_N,					--	""

					ELK_RX_SER_WORD     =>	ELK_RX_SER_WORD(16)            	-- OUTPUT WORD OF THE ELINK DE-SERIALIZER
				);

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ELINK 17 -----OPERATES AS A SLAVE DESERIALIER
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
U_ELK17_CH:ELINK_SLAVE
		 PORT MAP (
					CLK_40M_GL        	=>	CLK_40M_GL,                     -- CCC#1 FIXED 40MHZ CLOCK OUT
					CCC_160M_FXD      	=>	CCC_160M_FXD,					-- CCC#1 FIXED 160MHZ CLOCK
					CCC_160M_ADJ      	=>	CCC_160M_ADJ,                   -- CCC#2 ADJ 160MHZ CLOCK

					DEV_RST_B           =>	DEV_RST_B,                      -- ACTIVE LOW ASYNC RESET --DEDICATED COMET BOARD RC TIME CONSTANT
					MASTER_POR_B      	=>	MASTER_POR_B,                   -- MASTER_POR_B
					MASTER_DCB_POR_B    =>	MASTER_DCB_POR_B,               -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR DCB CONFIGS
					MASTER_SALT_POR_B   =>	MASTER_SALT_POR_B,              -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR SALT CONFIGS

					DCB_SALT_SEL        =>	DCB_SALT_SEL,                 	-- '1'= DCB MODE (IE TFC MASTER TX ENABLED) // '0'=SALT HYBRID MODE (IE TFC MASTER RX W/ SYNC MODE ENABLED)
				
					OP_MODE1_SPE      	=>	OP_MODE(1),                     -- OP_MODE BIT 1 = SYNC PATT EN
					F_ALIGN_PATT        =>	F_ALIGN_PATT, 					-- FIXED SYNC / ALIGNMENT PATTERN BYTE
					PATT_ELK_DAT		=>	PATT_ELK_DAT(17), 				-- ELINK PATTERN TX DATA

					BIT_OS_SEL          =>	BIT_OS_SEL,   					-- BIT ALIGNMENT OFFSET VALUE DETERMINED BY MASTER DES320M AND USE DY ALL SLAVES
				
					ELK_DAT_P         	=>	ELK17_DAT_P,                    -- SERIAL LVDS ELINK0 DATA BIDIR PORT
					ELK_DAT_N         	=>	ELK17_DAT_N,					--	""

					ELK_RX_SER_WORD     =>	ELK_RX_SER_WORD(17)            	-- OUTPUT WORD OF THE ELINK DE-SERIALIZER
				);

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ELINK 18 -----OPERATES AS A SLAVE DESERIALIER
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
U_ELK18_CH:ELINK_SLAVE
		 PORT MAP (
					CLK_40M_GL        	=>	CLK_40M_GL,                     -- CCC#1 FIXED 40MHZ CLOCK OUT
					CCC_160M_FXD      	=>	CCC_160M_FXD,					-- CCC#1 FIXED 160MHZ CLOCK
					CCC_160M_ADJ      	=>	CCC_160M_ADJ,                   -- CCC#2 ADJ 160MHZ CLOCK

					DEV_RST_B           =>	DEV_RST_B,                      -- ACTIVE LOW ASYNC RESET --DEDICATED COMET BOARD RC TIME CONSTANT
					MASTER_POR_B      	=>	MASTER_POR_B,                   -- MASTER_POR_B
					MASTER_DCB_POR_B    =>	MASTER_DCB_POR_B,               -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR DCB CONFIGS
					MASTER_SALT_POR_B   =>	MASTER_SALT_POR_B,              -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR SALT CONFIGS

					DCB_SALT_SEL        =>	DCB_SALT_SEL,                 	-- '1'= DCB MODE (IE TFC MASTER TX ENABLED) // '0'=SALT HYBRID MODE (IE TFC MASTER RX W/ SYNC MODE ENABLED)
				
					OP_MODE1_SPE      	=>	OP_MODE(1),                     -- OP_MODE BIT 1 = SYNC PATT EN
					F_ALIGN_PATT        =>	F_ALIGN_PATT, 					-- FIXED SYNC / ALIGNMENT PATTERN BYTE
					PATT_ELK_DAT		=>	PATT_ELK_DAT(18), 				-- ELINK PATTERN TX DATA

					BIT_OS_SEL          =>	BIT_OS_SEL,   					-- BIT ALIGNMENT OFFSET VALUE DETERMINED BY MASTER DES320M AND USE DY ALL SLAVES
				
					ELK_DAT_P         	=>	ELK18_DAT_P,                    -- SERIAL LVDS ELINK0 DATA BIDIR PORT
					ELK_DAT_N         	=>	ELK18_DAT_N,					--	""

					ELK_RX_SER_WORD     =>	ELK_RX_SER_WORD(18)            	-- OUTPUT WORD OF THE ELINK DE-SERIALIZER
				);

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ELINK 19 -----OPERATES AS A SLAVE DESERIALIER
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
U_ELK19_CH:ELINK_SLAVE
		 PORT MAP (
					CLK_40M_GL        	=>	CLK_40M_GL,                     -- CCC#1 FIXED 40MHZ CLOCK OUT
					CCC_160M_FXD      	=>	CCC_160M_FXD,					-- CCC#1 FIXED 160MHZ CLOCK
					CCC_160M_ADJ      	=>	CCC_160M_ADJ,                   -- CCC#2 ADJ 160MHZ CLOCK

					DEV_RST_B           =>	DEV_RST_B,                      -- ACTIVE LOW ASYNC RESET --DEDICATED COMET BOARD RC TIME CONSTANT
					MASTER_POR_B      	=>	MASTER_POR_B,                   -- MASTER_POR_B
					MASTER_DCB_POR_B    =>	MASTER_DCB_POR_B,               -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR DCB CONFIGS
					MASTER_SALT_POR_B   =>	MASTER_SALT_POR_B,              -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR SALT CONFIGS

					DCB_SALT_SEL        =>	DCB_SALT_SEL,                 	-- '1'= DCB MODE (IE TFC MASTER TX ENABLED) // '0'=SALT HYBRID MODE (IE TFC MASTER RX W/ SYNC MODE ENABLED)
				
					OP_MODE1_SPE      	=>	OP_MODE(1),                     -- OP_MODE BIT 1 = SYNC PATT EN
					F_ALIGN_PATT        =>	F_ALIGN_PATT, 					-- FIXED SYNC / ALIGNMENT PATTERN BYTE
					PATT_ELK_DAT		=>	PATT_ELK_DAT(19), 				-- ELINK PATTERN TX DATA

					BIT_OS_SEL          =>	BIT_OS_SEL,   					-- BIT ALIGNMENT OFFSET VALUE DETERMINED BY MASTER DES320M AND USE DY ALL SLAVES
				
					ELK_DAT_P         	=>	ELK19_DAT_P,                    -- SERIAL LVDS ELINK0 DATA BIDIR PORT
					ELK_DAT_N         	=>	ELK19_DAT_N,					--	""

					ELK_RX_SER_WORD     =>	ELK_RX_SER_WORD(19)            	-- OUTPUT WORD OF THE ELINK DE-SERIALIZER
				);


--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- INSTANTIATE THE MODULE CONTAINING THE USB HOST AND STORAGE INTERFACES
U50_PATTERNS:USB_INTERFACE 
    PORT MAP    (
                    CLK60MHZ            =>  CLK60MHZ,                               -- 
                    RESETB              =>  USB_MASTER_EN,                          -- ENABLE THE VHDL MODULE AFTER THE PHY USB MODULE IS GENERATING A STABLE 60 MHZ CLOCK
                    MASTER_POR_B        =>  MASTER_POR_B,                           -- RESET SYNCHRONOUS TO THE 160 MHZ AND 40 MHZ CLOCKS
                    CLK_40MHZ_GEN       =>  CLK_40M_GL,                             -- 

                    -- USB INTERFACE SIGNALS (SYNCHRONOUS TO CLK60MHZ)
                    BIDIR_USB_ADBUS     =>  BIDIR_USB_ADBUS,                        -- 
                    USB_OE_B            =>  USB_OE_BI,                              -- 

                    P_USB_RXF_B         =>  P_USB_RXF_B,                            -- 
                    USB_RD_B            =>  USB_RD_BI,                              -- 

                    P_USB_TXE_B         =>  P_USB_TXE_B,                            -- 
                    USB_WR_B            =>  USB_WR_BI,                              -- 

                    USB_SIWU_B          =>  USB_SIWU_BI,                            -- 
                                                                                    -- 
                    -- EXTERNAL PATTERN GEN INTERFACES (SYNCHRONOUS TO CLK_40MHZ_GEN)
                    P_TFC_STRT_ADDR     =>  TFC_STRT_ADDR,                          -- 
                    P_TFC_STOP_ADDR     =>  TFC_STOP_ADDR,                          -- 
                    TFC_ADDRB           =>  TFC_ADDRB,                              -- TFC ADDR INPUTS FOR THE B PORT PATT GEN SIDE
                    TFC_RAM_BLKB_EN     =>  TFC_RAM_BLKB_EN,                        -- 
                    P_TFC_ADDR8B        =>  TFC_ACT_BLK_SEL,                        -- TFC ACTIVE BLOCK SELECT FOR THE TFC RAM BANK
                    TFC_DAT_OUT         =>  PATT_TFC_DAT,                           -- TFC RAM BLOCK PORT B DATA OUT
                    TFC_DAT_IN          =>  TFC_RX_SER_WORD,                        -- TFC RAM BLOCK PORT B DATA IN
                    TFC_RWB             =>  TFC_RWB,                                -- TFC R/W FOR THE RAM B-PORT

					-- SIGNALS COMMON TO ALL ELINKS
					P_ELINKS_STRT_ADDR  =>  ELKS_STRT_ADDR,                         -- 
                    P_ELINKS_STOP_ADDR  =>  ELKS_STOP_ADDR,                         -- 
                    ELINK_ADDRB        	=>  ELKS_ADDRB,                             -- ADDR INPUTS FOR THE B PORT PATT GEN SIDE
                    ELINK_PATT_GEN_EN  	=>  ELKS_RAM_BLKB_EN,                       -- TFC ACTIVE BLOCK SELECT FOR THE TFC RAM BANK(ACTIVE LOW SIGNAL)
                    P_ELINK_ADDR8B     	=>  ELKS_ACT_BLK_SEL,                       -- ELINKS ACTIVE BLOCK SELECT FOR THE ELINKS RAM BANK
                    ELINK_RWB          	=>  ELKS_RWB,                               -- COMMON ELINK R/W FOR THE RAM B-PORTS

                    ELINK0_DAT_OUT      =>  PATT_ELK_DAT(0),                        -- 
                    ELINK0_DAT_IN       =>  ELK_RX_SER_WORD(0),                     -- ELINK0 RAM BLOCK PORT B DATA IN

                    ELINK1_DAT_OUT      =>  PATT_ELK_DAT(1),                        -- 
                    ELINK1_DAT_IN       =>  ELK_RX_SER_WORD(1),                     -- ELINK1 RAM BLOCK PORT B DATA IN

                    ELINK2_DAT_OUT      =>  PATT_ELK_DAT(2),                        -- 
                    ELINK2_DAT_IN       =>  ELK_RX_SER_WORD(2),                     -- ELINK2 RAM BLOCK PORT B DATA IN

                    ELINK3_DAT_OUT      =>  PATT_ELK_DAT(3),                        -- 
                    ELINK3_DAT_IN       =>  ELK_RX_SER_WORD(3),                     -- ELINK3 RAM BLOCK PORT B DATA IN

                    ELINK4_DAT_OUT      =>  PATT_ELK_DAT(4),                        -- 
                    ELINK4_DAT_IN       =>  ELK_RX_SER_WORD(4),                     -- ELINK4 RAM BLOCK PORT B DATA IN

                    ELINK5_DAT_OUT      =>  PATT_ELK_DAT(5),                        -- 
                    ELINK5_DAT_IN       =>  ELK_RX_SER_WORD(5),                     -- ELINK5 RAM BLOCK PORT B DATA IN

                    ELINK6_DAT_OUT      =>  PATT_ELK_DAT(6),                        -- 
                    ELINK6_DAT_IN       =>  ELK_RX_SER_WORD(6),                     -- ELINK6 RAM BLOCK PORT B DATA IN

                    ELINK7_DAT_OUT      =>  PATT_ELK_DAT(7),                        -- 
                    ELINK7_DAT_IN       =>  ELK_RX_SER_WORD(7),                     -- ELINK7 RAM BLOCK PORT B DATA IN

                    ELINK8_DAT_OUT      =>  PATT_ELK_DAT(8),                        -- 
                    ELINK8_DAT_IN       =>  ELK_RX_SER_WORD(8),                     -- ELINK8 RAM BLOCK PORT B DATA IN

                    ELINK9_DAT_OUT      =>  PATT_ELK_DAT(9),                        -- 
                    ELINK9_DAT_IN       =>  ELK_RX_SER_WORD(9),                     -- ELINK9 RAM BLOCK PORT B DATA IN

                    ELINK10_DAT_OUT      =>  PATT_ELK_DAT(10),                      -- 
                    ELINK10_DAT_IN       =>  ELK_RX_SER_WORD(10),                   -- ELINK10 RAM BLOCK PORT B DATA IN

                    ELINK11_DAT_OUT      =>  PATT_ELK_DAT(11),                      -- 
                    ELINK11_DAT_IN       =>  ELK_RX_SER_WORD(11),                   -- ELINK11 RAM BLOCK PORT B DATA IN

                    ELINK12_DAT_OUT      =>  PATT_ELK_DAT(12),                      -- 
                    ELINK12_DAT_IN       =>  ELK_RX_SER_WORD(12),                   -- ELINK12 RAM BLOCK PORT B DATA IN

                    ELINK13_DAT_OUT      =>  PATT_ELK_DAT(13),                      -- 
                    ELINK13_DAT_IN       =>  ELK_RX_SER_WORD(13),                   -- ELINK13 RAM BLOCK PORT B DATA IN

                    ELINK14_DAT_OUT      =>  PATT_ELK_DAT(14),                      -- 
                    ELINK14_DAT_IN       =>  ELK_RX_SER_WORD(14),                   -- ELINK14 RAM BLOCK PORT B DATA IN

                    ELINK15_DAT_OUT      =>  PATT_ELK_DAT(15),                      -- 
                    ELINK15_DAT_IN       =>  ELK_RX_SER_WORD(15),                   -- ELINK15 RAM BLOCK PORT B DATA IN

                    ELINK16_DAT_OUT      =>  PATT_ELK_DAT(16),                      -- 
                    ELINK16_DAT_IN       =>  ELK_RX_SER_WORD(16),                   -- ELINK16 RAM BLOCK PORT B DATA IN

                    ELINK17_DAT_OUT      =>  PATT_ELK_DAT(17),                      -- 
                    ELINK17_DAT_IN       =>  ELK_RX_SER_WORD(17),                   -- ELINK17 RAM BLOCK PORT B DATA IN

                    ELINK18_DAT_OUT      =>  PATT_ELK_DAT(18),                      -- 
                    ELINK18_DAT_IN       =>  ELK_RX_SER_WORD(18),                   -- ELINK18 RAM BLOCK PORT B DATA IN

                    ELINK19_DAT_OUT      =>  PATT_ELK_DAT(19),                      -- 
                    ELINK19_DAT_IN       =>  ELK_RX_SER_WORD(19),                   -- ELINK19 RAM BLOCK PORT B DATA IN
					
                    P_OP_MODE           =>  OP_MODE                                 -- 
        );

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- INSTANTIATE TRI-STATE BUFFERS FOR ALL USB CONTROL LINES THAT ARE HELD IN TRI-STATE UNTIL THE USB MODULE IS ENABLED
U60_TS_RD_BUF:tristate_buf
    PORT MAP    (   
                    Data                =>  USB_RD_BI,
                    Trien               =>  USB_MASTER_EN,
                    PAD                 =>  USB_RD_B
                );

U61_TS_WR_BUF:tristate_buf
    PORT MAP    (   
                    Data                =>  USB_WR_BI,
                    Trien               =>  USB_MASTER_EN,
                    PAD                 =>  USB_WR_B
                );

U62_TS_OE_BUF:tristate_buf
    PORT MAP    (   
                    Data                =>  USB_OE_BI,
                    Trien               =>  USB_MASTER_EN,
                    PAD                 =>  USB_OE_B
                );

U63_TS_SIWU_BUF:tristate_buf
    PORT MAP    (   
                    Data                =>  USB_SIWU_BI,
                    Trien               =>  USB_MASTER_EN,
                    PAD                 =>  USB_SIWU_B
                );

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--PATTERN GENERATOR FOR THE TFC SEQUENCE
-- CONTROLS BOTH THE TX AND RX OPERATIONS!
U200A_TFC:GP_PATT_GEN
    PORT MAP    (  
                    CLK_40MHZ_GEN       =>  CLK_40M_GL,
                    RESET_B             =>  MASTER_POR_B,                           -- POR SYNCHRONIZED TO LOCAL CLOCKS
                    USB_MASTER_EN       =>  USB_MASTER_EN,                          -- '1' SIGNIFIES THAT THE USB MODULE IS NOW ACTIVE

                    STRT_ADDR           =>  TFC_STRT_ADDR,
                    STOP_ADDR           =>  TFC_STOP_ADDR,
                    ACT_BLK_SEL         =>  TFC_ACT_BLK_SEL,                        -- SELECTS THE UPPER OR LOWER BLOCK OF THE RAM BANK
                    DIR_MODE            =>  DCB_SALT_SEL,                           -- DEDICATED TFC PATTERN TX OR RX SELECT BIT ('1'= TX MODE, '0'= RX MODE)

                    ALIGN_PATT          =>  F_ALIGN_PATT,                           -- FIXED ALIGNMENT PATTERN
                    RX_SER_WORD         =>  TFC_RX_SER_WORD,                        -- RECEIVED TFC SERIAL BYTE STREAM--USED TO SYNCHRONIZE DATA FLOW.

                    GP_PATT_GEN_EN      =>  OP_MODE(2),                             -- OP_MODE(2)--> '1'= TFC TX/RX FUNCTION ENABLE
                    REPEAT_EN           =>  OP_MODE(0),                             -- DEDICATED TFC PATTERN REPEAT/SINGLE-SHOT SELECT
                    ALIGN_ACTIVE        =>  ALIGN_ACTIVE,                           -- USED AN A QUALIFYING ENABLE OF THE PATTERN GENERATION FUNCTION

                    RAM_ADDR            =>  TFC_ADDRB,
                    RAM_BLKB            =>  TFC_RAM_BLKB_EN,
                    RAM_RWB             =>  TFC_RWB
                );
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--PATTERN GENERATOR FOR THE ELINKS SEQUENCE
-- CONTROLS BOTH THE TX AND RX OPERATIONS!
-- ONLY USES ELINK0 TO SYNC THE DATA FLOW
U200B_ELINKS:GP_PATT_GEN
    PORT MAP    (  
                    CLK_40MHZ_GEN       =>  CLK_40M_GL,
                    RESET_B             =>  MASTER_POR_B,                           -- POR SYNCHRONIZED TO LOCAL CLOCKS
                    USB_MASTER_EN       =>  USB_MASTER_EN,                          -- '1' SIGNIFIES THAT THE USB MODULE IS NOW ACTIVE

                    STRT_ADDR           =>  ELKS_STRT_ADDR,                         -- COMMON START ADDRESS FOR ALL ELINKS
                    STOP_ADDR           =>  ELKS_STOP_ADDR,                         -- COMMON STOP ADDRESS FOR ALL ELINKS
                    ACT_BLK_SEL         =>  ELKS_ACT_BLK_SEL,                       -- SELECTS THE UPPER OR LOWER BLOCK OF THE RAM BANK
                    DIR_MODE            =>  NOT(DCB_SALT_SEL),                      -- DEDICATED ELINKS PATTERN TX OR RX SELECT BIT ('1'= TX MODE, '0'= RX MODE)

                    ALIGN_PATT          =>  F_ALIGN_PATT,                           -- FIXED ALIGNMENT PATTERN
                    RX_SER_WORD         =>  ELK_RX_SER_WORD(0),                     -- RECEIVED MASTER ELINK0 SERIAL BYTE STREAM--USED TO SYNCHRONIZE DATA FLOW.

                    GP_PATT_GEN_EN      =>  OP_MODE(6),                             -- OP_MODE(6)--> '1'= ELINKS TX/RX FUNCTION ENABLE
                    REPEAT_EN           =>  OP_MODE(4),                             -- DEDICATED ELINK PATTERN REPEAT/SINGLE-SHOT SELECT
                    ALIGN_ACTIVE        =>  ALIGN_ACTIVE,                           -- USED AN A QUALIFYING ENABLE OF THE PATTERN GENERATION FUNCTION

                    RAM_ADDR            =>  ELKS_ADDRB,
                    RAM_BLKB            =>  ELKS_RAM_BLKB_EN,
                    RAM_RWB             =>  ELKS_RWB
                );

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- SYNC STATUS PROCESS:  FLAGS='1' WHEN RECEIVE WORDS ARE 8E HEX
SYNC_STAT_DET:PROCESS(CLK_40M_GL, MASTER_POR_B)
    BEGIN
        IF MASTER_POR_B = '0'   THEN
            ELK0_SYNC_DET       <=  '0';
            TFC_SYNC_DET        <=  '0';
        ELSIF (CLK_40M_GL'EVENT AND CLK_40M_GL = '1') THEN
            ELK0_SYNC_DET       <=  ELK_RX_SER_WORD(0)(7) AND NOT(ELK_RX_SER_WORD(0)(6)) AND NOT(ELK_RX_SER_WORD(0)(5)) AND NOT(ELK_RX_SER_WORD(0)(4)) AND 
                                    ELK_RX_SER_WORD(0)(3) AND     ELK_RX_SER_WORD(0)(2)  AND     ELK_RX_SER_WORD(0)(1)  AND NOT(ELK_RX_SER_WORD(0)(0));

            TFC_SYNC_DET        <=  TFC_RX_SER_WORD(7) AND NOT(TFC_RX_SER_WORD(6)) AND NOT(TFC_RX_SER_WORD(5)) AND NOT(TFC_RX_SER_WORD(4)) AND 
                                    TFC_RX_SER_WORD(3) AND     TFC_RX_SER_WORD(2)  AND     TFC_RX_SER_WORD(1)  AND NOT(TFC_RX_SER_WORD(0));

        END IF;
    END PROCESS SYNC_STAT_DET;

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- CONNECT INTERNAL SIGNALS TO EXTERNAL PORTS
ALL_PLL_LOCK        <=  CCC_RX_CLK_LOCK AND CCC_MAIN_LOCK;  -- BOTH ARE ACTIVE HIGH FOR LOCK CONDITION TRUE
P_MASTER_POR_B      <=  MASTER_POR_B;                  -- THIS IS THE NON-GLOBAL BUFFER VERSION
P_USB_MASTER_EN     <=  USB_MASTER_EN;
P_CLK_40M_GL        <=  CLK_40M_GL;
P_CCC_160M_FXD      <=  CCC_160M_FXD;
P_CCC_160M_ADJ      <=  CCC_160M_ADJ;

P_ELK0_SYNC_DET     <=  ELK0_SYNC_DET;
P_TFC_SYNC_DET      <=  TFC_SYNC_DET;

P_OP_MODE1_SPE      <=  OP_MODE(1);                     -- I2C_SCLK_1---SYNC PATT EN
P_OP_MODE2_TE       <=  OP_MODE(2);                     -- I2C_SDAT_1---TFC EN
P_OP_MODE5_AAE      <=  OP_MODE(5);                     -- I2C_SCLK_2---AUTO ALIGN EN
P_OP_MODE6_EE       <=  OP_MODE(6);                     -- I2C_SDAT_2---ELINKS EN


end RTL;
