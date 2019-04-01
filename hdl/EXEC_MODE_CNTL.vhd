--------------------------------------------------------------------------------
-- Company: UNIVERSITY OF MARYLAND
--
-- File: EXEC_MODE_CNTL.vhd
-- File history:
--      REV - // oct 23, 2015 // INITIAL VERSION
--
-- Description:     THIS MODULE SERVES AS THE EXECUTIVE POWER-ON MODULE TO ENABLE EITHER THE DCB OR THE SALT MODE CONFIG VIA CONTROL OF ALL RESET SIGNALS.  
--                  THE POR_MASTER TIMOUT DURATION IS FIXED. THE TIMEOUT START OCCURS WHEN THE MAIN CCC PLL IS LOCKED.
--
-- Targeted device: <Family::ProASIC3E> <Die::A3PE1500> <Package::208 PQFP>
-- Author: TOM O'BANNON
--
-------------------------------------------------------------------  -------------

library IEEE;

use IEEE.std_logic_1164.all;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.STD_LOGIC_MISC.ALL;

library proasic3e;
use proasic3e.all;

entity EXEC_MODE_CNTL is
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

end EXEC_MODE_CNTL;

architecture RTL of EXEC_MODE_CNTL is

-- DEFINE COMPONENTS

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- DETECTS THE PRESENCE OF A STABLE USB 60 MHZ CLOCK AND THEN GENERATES A SYNCHRONOUS ENABLE FOR THE USB MODULE 
COMPONENT USB_EXEC
port (
        RESETB              :   IN      STD_LOGIC;                      -- ACTIVE LOW RESET
        CLK_40MHZ_GEN       :   IN      STD_LOGIC;                      -- CLOCK SYNCHRONOUS TO THE 160MHZ CCC CLOCK FROM THE SERIALIZER

        CLK60MHZ            :   IN      STD_LOGIC;                      -- CLOCK FROM THE USM MODULE DERIVED FROM A 12MHZ CRYSTAL ON-BOARD THE USB MODULE PLL
                                                                        -- THIS CLOCK IS NOT ACTIVE AT POWER ON.  REQUIRES USB HOST ACTION TO ENABLE THE OUTPUT.
        USB_RESET_B         :   OUT     STD_LOGIC                       -- ACTIVE LOW RESET DEDICATED FOR THE USB VHDL STATE MACHINE--SYCHRONOUS RELEASE RELATIVE TO THE 60 MHZ CLOCK
    );
END COMPONENT;

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

SIGNAL  N_PRESCALE, PRESCALE            :   INTEGER RANGE 0 TO 15;      -- PRESCALER FOR THE DEL_CNT
SIGNAL  N_DEL_CNT, DEL_CNT              :   INTEGER RANGE 0 TO 255;     -- MASTER POR DELAY COUNT
SIGNAL  N_MPOR_B, MPOR_B                :   STD_LOGIC;                  -- MASTER POR SIGNAL
SIGNAL  N_MPOR_DCB_B, MPOR_DCB_B        :   STD_LOGIC;                  -- MASTER POR SIGNAL-- SPECIFIC FOR DCB CONFIGS
SIGNAL  N_MPOR_SALT_B, MPOR_SALT_B      :   STD_LOGIC;                  -- MASTER POR SIGNAL-- SPECIFIC FOR SALT CONFIGS

SIGNAL  CCC_1_LOCK_STAT_0D              :   STD_LOGIC;                  -- DELAYED SIGNAL OF CCC_1_LOCK_STAT-STAT FOR SYNC TO SCFG_CLK
SIGNAL  CCC_1_LOCK_STAT_1D              :   STD_LOGIC;                  -- DELAYED SIGNAL OF CCC_1_LOCK_STAT-STAT FOR SYNC TO SCFG_CLK

SIGNAL  DEV_RST_0B                      :   STD_LOGIC;                  -- USED TO SYNC SLOW EXT BOARD RESET TO 160 MHZ CLOCK REF
SIGNAL  DEV_RST_1B                      :   STD_LOGIC;                  -- USED TO SYNC SLOW EXT BOARD RESET TO 160 MHZ CLOCK REF
SIGNAL  SYNC_BRD_RST_BI                 :   STD_LOGIC;                  -- SYNCD VERSION OF SLOW EXT BOARD RESET TO 160 MHZ CLOCK REF

----------------------------------------------------------------

begin

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- GENERATE THE MASTER RESET (AND ENABLE) FOR THE USB INTERFACE
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

USB_MASTER_EN:USB_EXEC
    PORT MAP (
                RESETB              =>  MPOR_B,
                CLK_40MHZ_GEN       =>  CLK_40MHZ_GEN,
                CLK60MHZ            =>  CLK60MHZ,
                USB_RESET_B         =>  USB_RESET_B
            );
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- SYNC THE EXTERNAL POR TO THE 160 MHZ CLOCK SO IT IS ALSO SYNCHRONOUS TO THE SCFG_CLK
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
RST_SYNC:PROCESS(CCC_160M_FXD, DEV_RST_B)
    BEGIN
        IF DEV_RST_B = '0' THEN
            DEV_RST_0B      <=  '0';
            DEV_RST_1B      <=  '0';
            SYNC_BRD_RST_BI <=  '0';
            
        ELSIF ( CCC_160M_FXD'EVENT AND CCC_160M_FXD = '1' ) THEN
            DEV_RST_0B      <=  DEV_RST_B;
            DEV_RST_1B      <=  DEV_RST_0B;
            SYNC_BRD_RST_BI <=  DEV_RST_1B;
        END IF;

    END PROCESS RST_SYNC;



--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- DEFINE ALL REGISTERS
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
REG:PROCESS(CLK_40MHZ_GEN, SYNC_BRD_RST_BI)
    BEGIN
        IF ( SYNC_BRD_RST_BI = '0' ) THEN
            PRESCALE            <=   0;
            DEL_CNT             <=   0;
            MPOR_B              <=  '0';
            MPOR_DCB_B          <=  '0';
            MPOR_SALT_B         <=  '0';
            CCC_1_LOCK_STAT_0D  <=  '0';     
            CCC_1_LOCK_STAT_1D  <=  '0';     

        ELSIF ( CLK_40MHZ_GEN'EVENT AND CLK_40MHZ_GEN = '1' ) THEN
            PRESCALE            <=  N_PRESCALE;
            DEL_CNT             <=  N_DEL_CNT;
            MPOR_B              <=  N_MPOR_B;
            MPOR_DCB_B          <=  N_MPOR_DCB_B;
            MPOR_SALT_B         <=  N_MPOR_SALT_B;
            CCC_1_LOCK_STAT_0D  <=  CCC_1_LOCK_STAT;            -- ASSUMING CCC_1_LOCK_STAT IS ASYNC
            CCC_1_LOCK_STAT_1D  <=  CCC_1_LOCK_STAT_0D;     

        END IF;

    END PROCESS REG;

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- GENERATE A MASTER POR FOR ALL OTHER LOGIC DESIGN.  ONLY THIS MODULE AND THE SERIAL CONFIG RELATED LOGIC FUNCTIONS USES THE ON-BOARD POR.
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
LOGIC_POR:PROCESS(PRESCALE, DEL_CNT, CCC_1_LOCK_STAT_1D, DCB_SALT_SEL)
    BEGIN


        IF CCC_1_LOCK_STAT_1D = '1' THEN                        -- START COUNT ONCE LOCK STAT INDICATES PLL IS LOCKED

            IF PRESCALE < 14 THEN
                N_PRESCALE  <=   PRESCALE + 1;
            ELSE
                N_PRESCALE  <=  0;
            END IF;

            IF (DEL_CNT < 254) THEN
                IF PRESCALE = 0 THEN
                    N_DEL_CNT   <=  DEL_CNT + 1;                -- COUNT TO THE MAX VALUE .....
                ELSE
                    N_DEL_CNT   <=  DEL_CNT;
                END IF;
                N_MPOR_B        <=  '0';                        -- STAY IN RESET
                N_MPOR_DCB_B    <=  '0';
                N_MPOR_SALT_B   <=  '0';
            ELSE
                N_DEL_CNT       <=  DEL_CNT;                    -- ...AND THEN HOLD IT INDEFINITELY
                N_MPOR_B        <=  '1';                        -- RESET COMPLETE!
                N_MPOR_DCB_B    <=  DCB_SALT_SEL;               -- SIGNAL USED FOR DCB CONFIGS THAT COME OF RESET 
                N_MPOR_SALT_B   <=  NOT(DCB_SALT_SEL);          -- SIGNAL USED FOR SALT CONFIGS THAT COME OUT OF RESET
                N_PRESCALE      <=   PRESCALE;                  -- OVER-WRITES ABOVE ASSIGNMENTS
            END IF;

        ELSE                                                    -- STAY (OR RE-START) HERE UNTIL LOCK STAT INDICATES PLL IS LOCKED
            N_DEL_CNT       <=   0 ;
            N_MPOR_B        <=  '0';                                -- STAY IN RESET
            N_MPOR_DCB_B    <=  '0';
            N_MPOR_SALT_B   <=  '0';
            N_PRESCALE      <=   0;

        END IF;

    END PROCESS LOGIC_POR;

-- ASSIGN INTERNAL SIGNALS TO EXTERNAL PORTS
MASTER_POR_B        <=  MPOR_B;
MASTER_DCB_POR_B    <=  MPOR_DCB_B;
MASTER_SALT_POR_B   <=  MPOR_SALT_B;

end RTL;
