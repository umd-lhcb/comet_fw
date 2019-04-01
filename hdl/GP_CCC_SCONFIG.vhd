--------------------------------------------------------------------------------
-- Company: UNIVERSITY OF MARYLAND
--
-- File: GP_CCC_SCONFIG.vhd
-- File history:
--      REV - // OCT 12, 2015 // INITIAL VERSION
--      REV A // OCT 19, 2015 // CHANGED CCC INPUT REFERENCE TO OPERATE FROM 40.078MHZ (IE SAME AS TX/RX 'REF_CLK')
--      
-- Targeted device: <Family::ProASIC3E> <Die::A3PE1500> <Package::208 PQFP>
-- Author: TOM O'BANNON
-- 
-- Description: SERIAL CONFIGURATOR FOR THE CCC
--      FUNCTIONS:
--          ALLOWS THE CLOCK OUTPUT RELATIVE DELAY TO BE DYNAMICALLY ADJUSTED.
--          CCC REFERENCE CLOCK SOURCE IS ASSUMED TO BE 40.078 MHZ RECEIVED FROM THE COMET TRANSMITTING THE TFC COMMANDS
--          THIS LOGIC CHECKS THE PRESENT DLYGLA_L BIT AGAINST THE LAST ONE USED TO DETERMINE IF A SHIFT UPDATE IS NEEDED.
--          (IT APPEARS THE SEQUENTIAL UPDATES WITH THE SAME VALUE CAUSES A BRIEF LOSS OF LOCK EACH TIME!)
--          * THE PRIMARY CLOCK PRODUCED IS THE 160.315 MHZ THAT IS PHASE DELAY ADJUSTABLE.
--          * THIS MODULE ALSO PRODUCES A 40.078 MHZ GLOBAL OUTPUT.  THE RISE EDGE IS ALIGNED WITH THE FALL EDGE OF THE 160.315 MHZ CLOCK AND 
--            AND IS PROVIDED WITHT E SAME DELAY COMMAND SO THAT ITS TRACKS THE PRIMARY CLOCK.
-- 
--      USE THE LIBERO SW TO GENERATE THE DYNAMIC STREAM BITS THAT GET PROGRAMMED VIA THE DYNAMIC CCC SERIAL PORT.
--      TABLE BELOW IS FOUND IN THE CCC_ADJ_160M.LOG REPORT
--            ######################################
--                # Dynamic Stream Data                 
--            ######################################
--            --------------------------------------
--             NAME      SDIN      VALUE    TYPE     
--            --------------------------------------
--             FINDIV    [6:0]     0000111  EDIT      
--             FBDIV     [13:7]    0011111  EDIT      
--             OADIV     [18:14]   00000    EDIT      
--             OBDIV     [23:19]   00011    EDIT      
--             OCDIV     [28:24]   11010    EDIT      
--             OAMUX     [31:29]   100      EDIT      
--             OBMUX     [34:32]   110      EDIT        
--             OCMUX     [37:35]   000      EDIT      
--             FBSEL     [39:38]   01       EDIT      
--             FBDLY     [44:40]   00000    EDIT      
--             XDLYSEL   [45]      0        EDIT      
--             DLYGLA    [50:46]   00101    EDIT      
--             DLYGLB    [55:51]   00101    EDIT      
--             DLYGLC    [60:56]   00000    EDIT      
--             DLYYB     [65:61]   00000    EDIT      
--             DLYYC     [70:66]   00000    EDIT      
--             STATASEL  [71]      X        MASKED*   
--             STATBSEL  [72]      X        MASKED*   
--             STATCSEL  [73]      X        MASKED*   
--             VCOSEL    [76:74]   100      EDIT      
--             DYNASEL   [77]      X        MASKED*   
--             DYNBSEL   [78]      X        MASKED*   
--             DYNCSEL   [79]      X        MASKED*   
--             RESETEN   [80]      1        READONLY  
--            ----------------------------------------

--            *: These bits are computed after layout has been run
--               and are available in the post-layout CCC_Configuration Global Report

--* SDIN:   The configuration bits are serially loaded into a shift register through this port. The LSB of
--          the configuration data bits should be loaded first.
--* SDOUT:  The shift register contents can be shifted out (LSB first) through this port using the shift
--          operation. DATA BIT(80:0) WHERE 0 IS THE LSB
--* SCLK:   This port should be driven by the shift clock.
--* SSHIFT: The active-high shift enable signal should drive this port. The configuration data will be
--          shifted into the shift register if this signal is HIGH. Once SSHIFT goes LOW, the data shifting will
--          be halted.
--*SUPDATE: The SUPDATE signal is used to configure the CCC with the new configuration bits
--          when shifting is complete.

--* MODE:   The selection between the flash configuration bits and the bits from the configuration register is made
--          using the MODE signal. If the MODE signal is logic HIGH, the dynamic shift register configuration bits are selected. 
--          There are 81 control bits to configure the different functions of the CCC.

-- SDIN:    -----XMSB.....LSBX-----
-- SSHIFT   000/111111111111111\000000                                  -- SSHIFT MUST BE HIGH WHILE SHIFTING IN DATA
-- SUPDATE  000000000000000000000/1\00                                  -- UPDATING THE CCC REQUIRES SUPDATE TO BE PULSED HIGH FOR 1 SCLK CYCLE JUST AFTER SSHIFT IS BROUGHT LOW 
-- MODE     = LOGIC '1' ALWAYS FOR LOGIC-CONTROLLED DYNAMIC OPERATIONS  -- LOGIC '0' REVERTS OPERATION BACK TO THE STORED FLASH CONFIG BITS
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ++++ NOTE +++++THE CCC TEMPORARILY LOSSES LOCK AND BRIEFLY INTERRUPTS THE CLOCK OUTPUT WHEN UPDATED.
-- DISTURBANCE IS DENOTED BY THE LOCK STATUS BIT AND HAS A TYPICAL DURATION OF SEVERAL 100 NS 
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

--
--------------------------------------------------------------------------------

library IEEE;

use IEEE.std_logic_1164.all;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.STD_LOGIC_MISC.ALL;

library proasic3e;
use proasic3e.all;

entity GP_CCC_SCONFIG is
port (
        SCFG_CLK            :   IN  STD_LOGIC;                                          -- CLOCK USED TO CLOCK THE PHASE ADJ SERIAL SHFT REGISTER
        DEV_RST_B           :   IN  STD_LOGIC;                                          -- ACTIVE LOW RESET
        CONFIG_ONCE_TRIG    :   IN  STD_LOGIC;                                          -- '1' MEANS RUNS ONCE AND STOP FOREVERMORE

        FINDIV_A            :   IN  STD_LOGIC_VECTOR(6 DOWNTO 0);                       -- FINDIV:   LSB BIT 0
        FBDIV_B             :   IN  STD_LOGIC_VECTOR(13 DOWNTO 7);                      -- FBDIV
        OADIV_C             :   IN  STD_LOGIC_VECTOR(18 DOWNTO 14);                     -- OADIV
        OBDIV_D             :   IN  STD_LOGIC_VECTOR(23 DOWNTO 19);                     -- OBDIV
        OCDIV_E             :   IN  STD_LOGIC_VECTOR(28 DOWNTO 24);                     -- OCDIV
        OAMUX_F             :   IN  STD_LOGIC_VECTOR(31 DOWNTO 29);                     -- OAMUX    
        OBMUX_G             :   IN  STD_LOGIC_VECTOR(34 DOWNTO 32);                     -- OBMUX
        OCMUX_H             :   IN  STD_LOGIC_VECTOR(37 DOWNTO 35);                     -- OCMUX
        FBSEL_I             :   IN  STD_LOGIC_VECTOR(39 DOWNTO 38);                     -- FBSEL
        FBDLY_J             :   IN  STD_LOGIC_VECTOR(44 DOWNTO 40);                     -- FBDLY
        XDLYSEL_K           :   IN  STD_LOGIC_VECTOR(45 DOWNTO 45);                     -- BIT 54 XDLYSEL
        DLYGLA_L            :   IN  STD_LOGIC_VECTOR(50 DOWNTO 46);                     -- DLYGLA-->  GLOBAL A PHASE ADJUST INPUT 
        DLYGLB_M            :   IN  STD_LOGIC_VECTOR(55 DOWNTO 51);                     -- DLYGLB-->  GLOBAL B PHASE ADJUST INPUT 
        DLYGLC_N            :   IN  STD_LOGIC_VECTOR(60 DOWNTO 56);                     -- DLYGLC-->  GLOBAL C PHASE ADJUST INPUT 
        DLYYB_O             :   IN  STD_LOGIC_VECTOR(65 DOWNTO 61);                     -- DLYYB
        DLYYC_P             :   IN  STD_LOGIC_VECTOR(70 DOWNTO 66);                     -- DLYYC
        STATASEL_Q          :   IN  STD_LOGIC_VECTOR(71 DOWNTO 71);                     --  BIT 71 MASKED*   THESE BITS ARE DETERMINED AFTER P & R
        STATBSEL_R          :   IN  STD_LOGIC_VECTOR(72 DOWNTO 72);                     --  BIT 72 MASKED*   THEREFORE, BRING THEM IN VIA THE GPIO PORTS FOR NOW
        STATCSEL_S          :   IN  STD_LOGIC_VECTOR(73 DOWNTO 73);                     --  BIT_73 MASKED*   (CAN ALSO BRING IN VIA USB REGISTER EVENTUALLY?)
        VCOSEL_T            :   IN  STD_LOGIC_VECTOR(76 DOWNTO 74);                     --  VCOSEL
        DYNASEL_U           :   IN  STD_LOGIC_VECTOR(77 DOWNTO 77);                     --  BIT 77 MASKED*   (BUT MAY WANT TO HAVE STD FLASG AS DEFAULT CONFIG)
        DYNBSEL_V           :   IN  STD_LOGIC_VECTOR(78 DOWNTO 78);                     --  BIT 78 MASKED*   
        DYNCSEL_W           :   IN  STD_LOGIC_VECTOR(79 DOWNTO 79);                     --  BIT 79 MASKED*   
        RESETEN_X           :   IN  STD_LOGIC_VECTOR(80 DOWNTO 80);                     --  RESETEN, READONLY: MSB BIT 80
        P_CCC1_MODE         :   OUT STD_LOGIC;                                          -- CONTROL THE CONFIG MODE FOR CCC #1
        P_SDIN              :   OUT STD_LOGIC;                                          -- SERIAL DATA STREAM FOR THE SERIAL CONFIG OF THE CCC
        P_SSHIFT            :   OUT STD_LOGIC;                                          -- SERIAL SHIFT ENABLE
        P_SUPDATE           :   OUT STD_LOGIC                                           -- SERIAL UPDATE
);
end GP_CCC_SCONFIG;
architecture RTL of GP_CCC_SCONFIG is

-- THESE ARE THE SIGNALS FOR THE CONFIGURATION SHIFT REGISTER
    SIGNAL  N_SDIN, SDIN                    :   STD_LOGIC;                              -- SERIAL CONFIG DATA INPUT
    SIGNAL  N_SSHIFT, SSHIFT                :   STD_LOGIC;                              -- SERIAL SHIFT ENABLE
    SIGNAL  N_SUPDATE, SUPDATE              :   STD_LOGIC;                              -- SERIAL UPDATE

-- DEFINE THE STATE MACHINE STATES USED TO CONTROL THE CCC DELAY UPDATES
    TYPE SHIFT_SM_STATES IS (
                                INIT, DELAY_CFG_START, GET_81BITS, ASSERT_SSHIFT, SHIFT_THE_DAT, STOP_SHIFT, UPDATE_CCC
                            );
    SIGNAL  N_SHIFT_SM, SHIFT_SM            :   SHIFT_SM_STATES;

    SIGNAL  N_BITCNT, BITCNT                :   INTEGER RANGE 0 TO 255;             -- BIT COUNTER
    SIGNAL  N_ALL81BITS, ALL81BITS          :   STD_LOGIC_VECTOR(80 DOWNTO 0);      -- LOCAL COPY OF PHASE ADJ COMMAND SAVED AT THE START OF EACH SEQUENCE

    SIGNAL  N_LAST_PHA_ADJ_L, LAST_PHA_ADJ_L    :   STD_LOGIC_VECTOR(4 DOWNTO 0);   -- COPY OF THE LAST USED PHASE ADJ COMMAND

    SIGNAL  N_CCC1_MODE, CCC1_MODE          :   STD_LOGIC;                          -- '0' USE FUSE BITS, '1' USE SERIAL CONFIG BITS

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
begin

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- DEFINE ALL REGISTERS
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
REG:PROCESS(SCFG_CLK, DEV_RST_B)
    BEGIN
    
        IF DEV_RST_B = '0' THEN
            SHIFT_SM        <=  INIT;
            BITCNT          <=   0;
            ALL81BITS       <=  (OTHERS=>'0');
            SDIN            <=  '0';
            SSHIFT          <=  '0';
            SUPDATE         <=  '0';
            LAST_PHA_ADJ_L  <=  "11111";                    -- NON-ZERO VALUE FORCES AN UPDATE AT INITIAL POR START
            CCC1_MODE       <=  '0';                        -- START WITH FUSE BITS CONFIG

        ELSIF (SCFG_CLK'EVENT AND SCFG_CLK='1') THEN
            SHIFT_SM        <=  N_SHIFT_SM;
            BITCNT          <=  N_BITCNT;
            ALL81BITS       <=  N_ALL81BITS;
            SDIN            <=  N_SDIN;
            SSHIFT          <=  N_SSHIFT;
            SUPDATE         <=  N_SUPDATE;
            LAST_PHA_ADJ_L  <=  N_LAST_PHA_ADJ_L;
            CCC1_MODE       <=  N_CCC1_MODE;

        END IF;

    END PROCESS REG;
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- DEFINE THE CCC CONFIG STATE MACHINE
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CCC_CFG:PROCESS(    SHIFT_SM, ALL81BITS, BITCNT, SDIN, SSHIFT, SUPDATE,
                    RESETEN_X, DYNCSEL_W, DYNBSEL_V, DYNASEL_U, VCOSEL_T,
                    STATCSEL_S, STATBSEL_R, STATASEL_Q, 
                    DLYYC_P, DLYYB_O, DLYGLC_N, DLYGLB_M, 
                    DLYGLA_L, LAST_PHA_ADJ_L,
                    XDLYSEL_K, FBDLY_J, FBSEL_I, OCMUX_H,
                    OBMUX_G, OAMUX_F, OCDIV_E, OBDIV_D,
                    OADIV_C, FBDIV_B, FINDIV_A, CONFIG_ONCE_TRIG, CCC1_MODE
                )
    BEGIN

    -- DEFAULT ASSIGNMENTS
        N_ALL81BITS         <=  ALL81BITS;
        N_BITCNT            <=  BITCNT;
        N_SDIN              <=  SDIN;
        N_SSHIFT            <=  SSHIFT;
        N_SUPDATE           <=  SUPDATE;
        N_LAST_PHA_ADJ_L    <=  LAST_PHA_ADJ_L;
        N_CCC1_MODE         <=  CCC1_MODE;

        CASE SHIFT_SM IS

            WHEN INIT       =>
                N_BITCNT    <=  0;
                N_SUPDATE   <=  '0';    
                N_SSHIFT    <=  '0';    
                N_SDIN      <=  '0';

                IF CONFIG_ONCE_TRIG = '1'           THEN    -- INITIATE A ONE TIME CONFIG CYCLE AFTER A BRIEF DELAY
                    N_SHIFT_SM  <=  DELAY_CFG_START;
                    
                ELSE                                        -- OTHERWISE JUST WAIT HERE
                    N_SHIFT_SM  <=  INIT;

                END IF;

            WHEN DELAY_CFG_START   =>
                IF BITCNT   = 26 THEN
                    N_SHIFT_SM  <=  GET_81BITS;
                    N_BITCNT    <=  0;
                ELSE
                    N_SHIFT_SM  <=  DELAY_CFG_START;
                    N_BITCNT    <=  BITCNT + 1;
                END IF;

            WHEN GET_81BITS =>
                N_ALL81BITS <=  RESETEN_X & DYNCSEL_W & DYNBSEL_V & DYNASEL_U & VCOSEL_T             -- NOTE:  BOTH PLL OUTPUTS GET THE 
                                & STATCSEL_S & STATBSEL_R & STATASEL_Q                              -- SAME DELAY COMMAND SO THEY TRACK
                                & DLYYC_P & DLYYB_O & DLYGLC_N & DLYGLB_M
                                & DLYGLA_L 
                                & XDLYSEL_K & FBDLY_J & FBSEL_I & OCMUX_H
                                & OBMUX_G & OAMUX_F & OCDIV_E & OBDIV_D
                                & OADIV_C & FBDIV_B & FINDIV_A;

                N_SHIFT_SM          <=  ASSERT_SSHIFT;
                N_LAST_PHA_ADJ_L    <=  DLYGLA_L;

            WHEN ASSERT_SSHIFT  =>
                N_SHIFT_SM  <=  SHIFT_THE_DAT;

            WHEN SHIFT_THE_DAT  =>
                IF BITCNT >= 80  THEN                       -- MAX COUNT IS 80DEC
                    N_BITCNT    <=  0;
                    N_SSHIFT    <=  '0';
                    N_SHIFT_SM  <=  STOP_SHIFT;
                ELSE
                    N_BITCNT    <=  BITCNT + 1;
                    N_SHIFT_SM  <=  SHIFT_THE_DAT;
                END IF;

                N_SSHIFT    <=  '1';
                N_SUPDATE   <=  '0';
                N_SDIN      <=  ALL81BITS(BITCNT);

            WHEN STOP_SHIFT     =>
                N_SHIFT_SM  <=  UPDATE_CCC;
                N_SUPDATE   <=  '0';    
                N_SSHIFT    <=  '0';

            WHEN UPDATE_CCC     =>
                IF BITCNT > 10 THEN
                    N_BITCNT    <=  0;
                    N_SHIFT_SM  <=  INIT;
                    N_CCC1_MODE <=  '1';                    -- SWITCH FROM FUSE TO SERIAL CONFIG MODE

                ELSE
                    N_BITCNT    <=  BITCNT + 1;
                    N_SHIFT_SM  <=  UPDATE_CCC;
                END IF;

                IF BITCNT = 2 THEN
                    N_SUPDATE   <=  '1';    
                ELSE
                    N_SUPDATE   <=  '0';
                END IF;

                N_SSHIFT    <=  '0';

            WHEN OTHERS     =>
                N_SHIFT_SM  <=  INIT;

        END CASE;



    END PROCESS CCC_CFG;

-- MAP INTERNAL SIGNALS TO EXTERNAL PORTS
P_CCC1_MODE         <=  CCC1_MODE;
P_SDIN              <=  SDIN;                                           -- SERIAL DATA STREAM FOR THE SERIAL CONFIG OF THE CCC
P_SSHIFT            <=  SSHIFT;                                         -- SERIAL SHIFT ENABLE
P_SUPDATE           <=  SUPDATE;                                        -- SERIAL UPDATE

end RTL;
