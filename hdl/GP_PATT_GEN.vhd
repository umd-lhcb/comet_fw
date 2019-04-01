--------------------------------------------------------------------------------
-- Company: UNIVERSITY OF MARYLAND
--
-- File: GP_PATT_GEN.vhd
-- File history:  REV -
--
-- Description: 
--      GENERAL PURPOSE PATTERN RAM ACCESS GENERATOR.  CONTAINS COUNTERS THAT OPERATE WITH EXTERNALLY SPECIFIED START AND STOP ADDRESS INPUTS TO CONTROL ACCESS 
--      TO THE RAM BLOCK B PORTS THAT CONTAIN THE CUSTOM PATTERNS.  THE DIR_MODE INPUT DETERMINES WHETHER DATA IS BEING GENERATED OR RECEIVED.
--      GENERAL PURPOSE OPERATING MODE INCLUDE (1) REPEAT/SINGLE SHOT, (2) ENABLE ON/OFF, (3) TX OR RX, AND (4) COMPARE ON/OFF
--          -->THE COMPARE MODE WILL BE ADDED LATER.  IT WILL NOT STORE THE FDATA FOR RX MODE, BUT RATHER WILL COMPARE IN-COMING AGAINST THE 'PRE-STORED' DATA PATTERN.
--      ALL RAM DATA IS ROUTED THRU THIS MODULE FOR 2 PURPOSES. 
--          (1) PROVIDE AN ADDITIONAL CLOCK RESYNC LAYER AT 40 MHZ.  NOTE, 40 MHZ IS SYNCHRONOUS TO THE 160 MHZ VIA THE CCC CONFIG.
--          (2) ALLOW FUTURE DATA CAPTURE AND COMPARE FUNCTIONALITY.  THESE FUNCTIONS ASSUME THE ENTIRE 256 BYTE SRAM RECORD LENGTH IS ALWAYS USED
--              (A) CAPTURE TO BE SENT BACK VIA USB WITHOUT ANY COMPARISIONS PERFORMED
--              (B) COMPARE ASSUMES THE REF DATA IS ALREADY STORED IN THE SRAM BANK (IE NO NEW DATA IS CAPTURED)
--
--          NOTE:   (1) THE START AND STOP ADDRESSES AS WELL AS THE ACTIVE RAM BLOCK SELECT ARE LATCHED AT THE INITIALLY WHEN THE PATTERN IS ENABLED SO THAT UPDATES TO THE 
--                      PATTERNS IN-PROGRESS ARE NOT AFFECTED BY THE ALL_REGISTERS UPDATE.  
--                      THE PATTERN MUST FIRST BE DISABLED TO ALLOW THE OPERATIONAL START AND STOP ADDRESSES TO BE USED.
--                  (2) A SEPARATE COPY OF THIS PATTERN GENERATOR WILL BE INSTANTIATED FOR EACH RAM BANK TO BETTER FACILITATE TIMING CLOSURE DURING PLACE & ROUTE
-- 
-- Targeted device: <Family::ProASIC3E> <Die::A3PE1500> <Package::208 PQFP>
-- Author: TOM O'BANNON
--
--------------------------------------------------------------------------------

library IEEE;

use IEEE.std_logic_1164.all;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.STD_LOGIC_MISC.ALL;

library proasic3e;
use proasic3e.all;

entity GP_PATT_GEN is
port    (  
            CLK_40MHZ_GEN       :   IN  STD_LOGIC;                              -- CLOCK SYNCHRONOUS TO THE 160MHZ CCC CLOCK FROM THE SERIALIZER
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

end GP_PATT_GEN;

architecture RTL_LOGIC of GP_PATT_GEN is

    SIGNAL  N_ADDR_POINTER , ADDR_POINTER       : STD_LOGIC_VECTOR(7 DOWNTO 0); -- ADDRESS POINTER TO DRIVE THE RAM BLOCKS

    SIGNAL  N_LOC_STRT_ADDR, LOC_STRT_ADDR      : STD_LOGIC_VECTOR(7 DOWNTO 0); -- LOCAL LATCHED VALUE OF THE START ADDRESS
    SIGNAL  N_LOC_STOP_ADDR, LOC_STOP_ADDR      : STD_LOGIC_VECTOR(7 DOWNTO 0); -- LOCAL LATCHED VALUE OF THE STOP ADDRESS
    SIGNAL  N_LOC_ACT_BLK_SEL, LOC_ACT_BLK_SEL  : STD_LOGIC;                    -- LOCAL LATCHED VALUE OF THE ACTIVE BLOCK SELECT
    SIGNAL  N_LOC_DIR_MODE, LOC_DIR_MODE        : STD_LOGIC;                    -- LOCAL LATCHED VALUE OF THE ACTIVE DIR MODE

    SIGNAL  RX_SER_WORD_1DEL                    : STD_LOGIC_VECTOR(7 DOWNTO 0); -- DELAYED VERION OF THE RECEIVED SERIAL WORD
    SIGNAL  RX_SER_WORD_2DEL                    : STD_LOGIC_VECTOR(7 DOWNTO 0); -- DELAYED VERION OF THE RECEIVED SERIAL WORD
    SIGNAL  RX_SER_WORD_3DEL                    : STD_LOGIC_VECTOR(7 DOWNTO 0); -- DELAYED VERION OF THE RECEIVED SERIAL WORD
    
    SIGNAL  N_R_BLKB, R_BLKB                    : STD_LOGIC;                    -- GENERIC RAM BLOCK, PORT B, ACTIVE LOW ENABLE
    SIGNAL  N_R_RWB, R_RWB                      : STD_LOGIC;                    -- GENERIC RAM BLOCK, PORT B, READ/WRITE CONTROL (LOGIC 1/0)

    TYPE    GP_PG_SM_STATES IS  (                                               -- STATES FOR THE GENERAL PURPOSE PATTER GENERATOR STATE MACHINE
                                    INIT, COORD_START, TX_START, WAIT_FOR_DATA, RX_START, RX_START_1PIPE, RX_START_2PIPE, RX_START_3PIPE,
                                    TX_SINGLE_MODE, RX_SINGLE_MODE, TX_CONT_MODE, RX_CONT_MODE, 
                                    SINGLE_MODE_HOLD, SINGLE_MODE_HOLD1
                                );
    SIGNAL  N_GP_PG_SM, GP_PG_SM                : GP_PG_SM_STATES;              -- STATE MACHINE POINTER FOR THE GENERAL PURPOSE PATTER GENERATOR STATE MACHINE

begin

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- DEFINE ALL REGISTERS THAT USE THE 40 MHZ CLOCK
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    REG:PROCESS(CLK_40MHZ_GEN, RESET_B)
        BEGIN
            IF (RESET_B='0')    THEN
                GP_PG_SM            <=  INIT;

                ADDR_POINTER        <=  (OTHERS => '0');
                R_BLKB              <=  '1';                                -- ACTIVE LOW
                R_RWB               <=  '1';                                -- DEFAULT IS READ

                LOC_STOP_ADDR       <=  (OTHERS => '0');
                LOC_STRT_ADDR       <=  (OTHERS => '0');
                LOC_ACT_BLK_SEL     <=  '0';
                LOC_DIR_MODE        <=  '0';                                -- DEFAULT IS READ

                RX_SER_WORD_1DEL    <=  (OTHERS => '0');
                RX_SER_WORD_2DEL    <=  (OTHERS => '0');
                RX_SER_WORD_3DEL    <=  (OTHERS => '0');
                
            ELSIF (CLK_40MHZ_GEN'EVENT AND CLK_40MHZ_GEN='1')   THEN
                GP_PG_SM            <=  N_GP_PG_SM;

                ADDR_POINTER        <=  N_ADDR_POINTER;
                R_BLKB              <=  N_R_BLKB;
                R_RWB               <=  N_R_RWB;

                LOC_STOP_ADDR       <=  N_LOC_STOP_ADDR;
                LOC_STRT_ADDR       <=  N_LOC_STRT_ADDR;
                LOC_ACT_BLK_SEL     <=  N_LOC_ACT_BLK_SEL;
                LOC_DIR_MODE        <=  N_LOC_DIR_MODE;

                RX_SER_WORD_1DEL    <=  RX_SER_WORD;
                RX_SER_WORD_2DEL    <=  RX_SER_WORD_1DEL;
                RX_SER_WORD_3DEL    <=  RX_SER_WORD_2DEL;

            END IF;

    END PROCESS REG;


--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- GENERAL PURPOSE PATTERN GENERATOR LOGIC
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    GP_PG:PROCESS(  GP_PG_SM, STRT_ADDR, STOP_ADDR, ADDR_POINTER, RX_SER_WORD_2DEL, RX_SER_WORD_3DEL, ALIGN_PATT, 
                    ACT_BLK_SEL, R_BLKB, R_RWB,
                    DIR_MODE, GP_PATT_GEN_EN, USB_MASTER_EN, REPEAT_EN, ALIGN_ACTIVE,
                    LOC_STRT_ADDR, LOC_STOP_ADDR, LOC_ACT_BLK_SEL, LOC_DIR_MODE
                  )
        BEGIN

    -- DEFAULT ASSIGNMENTS
        N_LOC_STRT_ADDR     <=  LOC_STRT_ADDR;
        N_LOC_STOP_ADDR     <=  LOC_STOP_ADDR;
        N_LOC_ACT_BLK_SEL   <=  LOC_ACT_BLK_SEL;
        N_LOC_DIR_MODE      <=  LOC_DIR_MODE;

        N_ADDR_POINTER      <=  ADDR_POINTER;
        N_R_BLKB            <=  R_BLKB;
        N_R_RWB             <=  R_RWB;

-- GP_PATT_GEN_EN DRIVEN BY OP_MODE SIGNAL THAT DETERMINES THE TX OR RX FUNCTION IS ENABLED
-- USB_MASTER_EN MAKES SYRE THE USB INTERFACE IS ACTUALLY OPERATING (IE NOT STILL WAITING FOR THE CLOCK INIT)
-- ALIGN_ACTIVE IS FROM THE LOCAL DESERIALIZER
-- LOC_DIR_MODE IS LATCHED VERSION OF DCB_SALT_SEL JUMPER

        CASE GP_PG_SM IS

            WHEN INIT           =>                                                                  -- 2 CONFIGS = 2 DIFFERENT START CONDITIONS
                IF      (GP_PATT_GEN_EN AND USB_MASTER_EN AND NOT(ALIGN_ACTIVE)) = '1'  THEN        --> +++CONFIG RX PATT GEN START CONDITIONS+++
                            N_R_BLKB        <=  '0';                                                -- ACTIVE LOW: ENABLE THE B PORT RAM BLOCK
                            N_GP_PG_SM      <=  COORD_START;                                        -- NEED TO COORDINATE TX AND RX START OPERATIONS

                ELSIF   (GP_PATT_GEN_EN AND USB_MASTER_EN AND LOC_DIR_MODE) = '1'   THEN            --> +++CONFIG TX PATT GEN START CONDITIONS+++
                            N_R_BLKB        <=  '0';                                                -- ACTIVE LOW: ENABLE THE B PORT RAM BLOCK
                            N_GP_PG_SM      <=  COORD_START;                                        -- NEED TO COORDINATE TX AND RX START OPERATIONS

                ELSE                                                                                -- WAIT HERE UNTIL THE PATT GEN IS ENABLED
                            N_R_BLKB        <=  '1';                                                -- ACTIVE LOW: KEEP THE B PORT RAM BLOCK DISABLED
                            N_GP_PG_SM      <=  INIT;

                END IF;

                N_R_RWB             <=  LOC_DIR_MODE;               -- DEFAULT MODE CONFIG FOR PATT GEN TX MODE DETERMINED BY LOCAL SAVED COPY

                N_ADDR_POINTER      <=  STRT_ADDR;                  -- UPDATE THE RAM PORT B ADDRESS POINTER START ADDRESS

                N_LOC_STRT_ADDR     <=  STRT_ADDR;                  -- SAVE A LOCAL COPY TO PREVENT UPDATES DURING THE SEQUENCE
                N_LOC_STOP_ADDR     <=  STOP_ADDR;                  -- SAVE A LOCAL COPY TO PREVENT UPDATES DURING THE SEQUENCE
                N_LOC_ACT_BLK_SEL   <=  ACT_BLK_SEL;                -- SAVE A LOCAL COPY TO PREVENT UPDATES DURING THE SEQUENCE
                N_LOC_DIR_MODE      <=  DIR_MODE;                   -- SAVE A LOCAL COPY TO PREVENT UPDATES DURING THE SEQUENCE


            WHEN COORD_START    =>
                IF LOC_DIR_MODE = '1'   THEN                        -- IF TX MODE, THEN START TX SEQUENCE
                    N_GP_PG_SM      <=  TX_START;                   -- 
                ELSE
                    N_GP_PG_SM      <=  WAIT_FOR_DATA;              -- IF RX MODE, THEN WAIT FOR SYNC TRANSITION TO DATA
                END IF;


            WHEN TX_START       =>                                  -- OK TO START DATA TX OP
                IF REPEAT_EN = '1'          THEN
                    N_GP_PG_SM      <=  TX_CONT_MODE;
                ELSE
                    N_GP_PG_SM      <=  TX_SINGLE_MODE;
                END IF;


            WHEN WAIT_FOR_DATA  =>                                  -- LOOK FOR AT LEAST TWO SEQUENTIAL NON-SYNC CHARACTERS (NOTE-THIS INHERENTLY DELAYS THE DATA STORE START!)
                IF (RX_SER_WORD_2DEL /= ALIGN_PATT) AND (RX_SER_WORD_3DEL /= ALIGN_PATT)    THEN
                    N_GP_PG_SM      <=  RX_START;
                ELSE
                    N_GP_PG_SM      <=  WAIT_FOR_DATA;
                END IF;


            WHEN TX_SINGLE_MODE    =>                               -- SINGLE SHOT MODE
                IF ADDR_POINTER >= LOC_STOP_ADDR THEN
                    N_ADDR_POINTER      <=  STRT_ADDR;
                    N_GP_PG_SM          <=  SINGLE_MODE_HOLD;       
                ELSE
                    N_ADDR_POINTER      <=  ADDR_POINTER + "1";
                    N_GP_PG_SM          <=  TX_SINGLE_MODE;       
                END IF;


            WHEN TX_CONT_MODE      =>                               -- CONTINUOUS OPERATION MODE
                IF ADDR_POINTER >= LOC_STOP_ADDR THEN
                    N_ADDR_POINTER      <=  LOC_STRT_ADDR;

                    IF GP_PATT_GEN_EN = '0'     THEN                -- NEED TO RETURN TO THE DISABLED STATE TO UPDATE START/STOP ADDRESSES OR CONT/SINGLE SHOT MODES
                        N_GP_PG_SM      <=  SINGLE_MODE_HOLD;       -- BUT ONLY DO THAT AT THE END OF THE CURRENT SEQUENCE
                    ELSE
                        N_GP_PG_SM      <=  TX_CONT_MODE;
                    END IF;

                ELSE
                    N_ADDR_POINTER      <=  ADDR_POINTER + "1";
                    N_GP_PG_SM          <=  TX_CONT_MODE;           -- ONLY CHANGE STATES AT THE END OF EACH TIME THRU THE SEQUENCE

                END IF;


            --WHEN RX_START       =>                                  -- OK TO START DATA RX OP AFTER PIPELINE DELAY ACCOUNTED
                --N_GP_PG_SM      <=  RX_START_1PIPE;                 -- THIS PIPELINE DELAY ACCOUNTS FOR THE DELAY FROM TX TRANSITIONS FROM ALIGN TO DATA CHARACTER STREAM.
                                                                    ---- THERE ARE SOME EXTRA 00 HEX BYTES SENT AFTER LAST ALIGN BYTE AND FIRST DATA BYTE.
            --WHEN RX_START_1PIPE       =>                            -- OK TO START DATA RX OP AFTER PIPELINE DELAY ACCOUNTED
                --N_GP_PG_SM      <=  RX_START_2PIPE;
--
            --WHEN RX_START_2PIPE       =>                            -- OK TO START DATA RX OP AFTER PIPELINE DELAY ACCOUNTED
                --N_GP_PG_SM      <=  RX_START_3PIPE;

            WHEN RX_START       =>                                  -- OK TO START DATA RX OP
                IF REPEAT_EN = '1'          THEN
                    N_GP_PG_SM      <=  RX_CONT_MODE;
                ELSE
                    N_GP_PG_SM      <=  RX_SINGLE_MODE;
                END IF;


            WHEN RX_SINGLE_MODE    =>                               -- SINGLE SHOT MODE
                IF ADDR_POINTER >= LOC_STOP_ADDR THEN
                    N_ADDR_POINTER      <=  STRT_ADDR;
                    N_GP_PG_SM          <=  SINGLE_MODE_HOLD;       

                ELSE
                    N_ADDR_POINTER      <=  ADDR_POINTER + "1";
                    N_GP_PG_SM          <=  RX_SINGLE_MODE;       
                END IF;


            WHEN RX_CONT_MODE      =>                               -- CONTINUOUS OPERATION MODE
                IF ADDR_POINTER >= LOC_STOP_ADDR THEN
                    N_ADDR_POINTER      <=  LOC_STRT_ADDR;

                    IF GP_PATT_GEN_EN = '0'     THEN                -- NEED TO RETURN TO THE DISABLED STATE TO UPDATE START/STOP ADDRESSES OR CONT/SINGLE SHOT MODES
                        N_GP_PG_SM      <=  SINGLE_MODE_HOLD;       -- BUT ONLY DO THAT AT THE END OF THE CURRENT SEQUENCE
                    ELSE
                        N_GP_PG_SM      <=  RX_CONT_MODE;
                    END IF;

                ELSE
                    N_ADDR_POINTER      <=  ADDR_POINTER + "1";
                    N_GP_PG_SM          <=  RX_CONT_MODE;           -- ONLY CHANGE STATES AT THE END OF EACH TIME THRU THE SEQUENCE

                END IF;


            WHEN SINGLE_MODE_HOLD =>                                -- NEED 1 CLOCK CYCLE DELAY FOR THE LAST BYTE BEFORE DISABLING THE RAM BLOCK
                N_GP_PG_SM      <=  SINGLE_MODE_HOLD1;
                N_R_BLKB            <=  '1';                        -- ACTIVE LOW: TOGGLE THE B PORT RAM BLOCK TO BE DISABLED


            WHEN SINGLE_MODE_HOLD1 =>                               -- WAIT HERE UNTIL THE OUTPUT IS DISABLED
                IF GP_PATT_GEN_EN = '0'     THEN
                    N_GP_PG_SM      <=  INIT;
                ELSE
                    N_GP_PG_SM      <=  SINGLE_MODE_HOLD1;
                END IF;

            WHEN OTHERS         =>
                N_GP_PG_SM      <=  INIT;

        END CASE;

    END PROCESS GP_PG;
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
RAM_ADDR        <=  LOC_ACT_BLK_SEL & ADDR_POINTER;         -- NEED BOTH THE LATCHED RAM BLOCK BIT AND ADDR POINTER
RAM_BLKB        <=  R_BLKB;
RAM_RWB         <=  R_RWB;

end RTL_LOGIC;
