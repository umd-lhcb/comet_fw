--------------------------------------------------------------------------------
-- Company: University of Maryland
--
-- File: MASTER_DES320M.vhd
-- File history:
--      Rev A
--      Rev B-- UPDATED THE DDR FUNCTIONALITY TO EXPLOIT THE INPUT DDR CAPABILITY WHICH PLACES B OTH THE RISE AND FALL CLOCKED IN DATA ONTO THE OUTPUTS SYNCHRONOUS TO ONLY THE RISE EDGE

-- Description: Basic DE-SERIALIZER operation.  THIS MODULE ACCEPTS THE DDR INPUT REGISTER RISE AND FALL LATCHED DATA RESULTS.  THERE ARE TWO MODES:
--              (1) AUTO ALIGN:  THE RECD PATTERNS ARE CORRELATED RELATIVE TO THE PREDEFINED ALIGNMENT BYTE TO DETERMINE BOTH THE BIT ALIGNMENT RELATIVE TO THE ADJUSTABLE CLOCK 
--                               PHASE AS WELL AS THE BYTE ALIGNMENT.  
--                               THE AUTO ALIGN IS EDGE TRIGGERED BASED UPON OP_MODE(1) INITIAL TRANSITION TO '1'.
--                               THE FINAL OUTPUT DETERMINES THE BIT OFFSET NEEDED IN A STREAM OF 14 BITS RECEIVED SEQUENTIALLY.
--                               NOTE:  THE AUTO ALIGNMENT ONLY NEEDS TO USE 8 OF THE SEQUENTIALLY RECEIVED BITS SINCE THE SYNC PATTERN IS REPEATED EVERY BYTE
--              (2) NORMAL RECEIVE:  THE SERIAL CONTINUES TO RUN WITH THE LATCHED BIT CLOCK PHASE AND BYTE ALIGNMENT OFFSET DETERMINED BY THE LAST AUTO ALIGN FUNCTION.

-- CLOCK DOMAIN INFO:   THIS APPROACH USES MUTLIPLE CLOCK DOMAINS, OF BOTH DYNAMIC AND STATIC CONFIGURATIONS, TO ACCOMPLISH THE TASKS.
--                      THERE ARE 2 CCC MODULES USED.  
--                      THE FIRST IS STATICALLY CONFIGURED TO GENERATED THE FIXED AND PHASE-RELATED 160 MHZ AND 40 MHZ CLOCKS. 
--                          THE RISE EDGE OF THE 40 MHZ CLOCK IS ALIGNED WITH THE RISE EDGE OF THE 160 MHZ CLOCK VIA THE PLL.
--                          IT ALSO GENERATES A FIXED DELAYED COPY OF THE USB MODULE 60 MHZ CLOCK.
--                          THE REFERENCE IS SELECTED BASED UPON THE DCB OR SALT CONFIG JUMPER.
--                      THE SECOND CCC IS DYNAMICALLY CONFIGURED AND CONTROLLED BY THIS MODULE TO GENERATE THE SAME 160 AND 40 MHZ PHASE RELATED CLOCKS, BY TUNED WITH
--                      200 PS DELAY STEPS.  THESE LATTER CLOCKS ARE USED TO SAMPLE THE INCOMONG DDR SERIAL DATA.  THE PHASE OF THIS 160 MHZ SAMPLE CLOCK IS TUNED DURING THE 
--                      SYNC MODE TO ACHIEVE THE PROPER ALIGNMENT TO RECEIVE THE SERIAL DATA.  THIS STREAM IS THEN SYNCHRONIXED TO THE DYNMAIC 40 MHZ CLOCK AND THEN FINALLY SYNCHRONIZE
--                      TO THE FIXED 40 MHZ CLOCK.  THE TOTAL DELAY TUNE RANGE OF THE DYNAMIC 160 MHZ SAMPLE CLOCK IS APPROXIMATELY 1 CLOCK CYCLE.
--                      CONSEQUENTLY, THE NET TUNE RANGE FOR THE DYNAMIC 40 MHZ CLOCK RELATIVE TO THE FIXED ONE IS MUCH LESS THAN THE FULL CLOCK CYCLE.

-- Targeted device: <Family::PROASIC3E> <Die::1500 GATE> <Package::208 QFP>
-- Author: Tom O'Bannon
--
--------------------------------------------------------------------------------

library IEEE;

use IEEE.std_logic_1164.all;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.STD_LOGIC_MISC.ALL;

library proasic3e;
use proasic3e.all;


entity MASTER_DES320M is
port (
        CCC_160M_ADJ       	:   IN  STD_LOGIC;                              -- PHASE ADJUSTABLE 160 MHZ DDR CLOCK
		CCC_160M_FXD		:	IN	STD_LOGIC;								-- FIXED PHASE 160 MHZ DDR CLOCK
        CCC2_CLK_LOCK       :   IN  STD_LOGIC;                              -- PLL LOCK STATUS FOR CCC2 
		
        CLK_40M_FXD         :   IN  STD_LOGIC;                              -- FIXED PHASE 40 MHZ CLOCK 

        RESET_B             :   IN  STD_LOGIC;                              -- ACTIVE LOW RESET    

        ALIGN_MODE_EN       :   IN  STD_LOGIC;                              -- '1' ENABLES THE AUTO BIT AND BYTE ALIGNMENT FUNCTION. PULSED INPUT MUST BE LOW BEFORE ALIGNMENT COMPLETE
        ALIGN_PATT          :   IN  STD_LOGIC_VECTOR(7 DOWNTO 0);           -- PATTERN USED TO DETERMINE ALIGNMENT (EG A5 HEX)

        MAN_AUTO_ALIGN      :   IN  STD_LOGIC;                              -- '1'= MANUAL BIT OFFSET AND PHASE ALIGNMENT, '0'=AUTO
        MAN_BIT_OS          :   IN  STD_LOGIC_VECTOR(3 DOWNTO 0);           -- MANUAL SELECTION OF THE BIT OFFSET 
        MAN_PHASE_ADJ       :   IN  STD_LOGIC_VECTOR(4 DOWNTO 0);           -- MANUAL PHASE ADJ VALUE OF 160 ADJ CCC#2

        SER_IN_R            :   IN  STD_LOGIC;                              -- SERIAL DATA IN-->RISE EDGE
        SER_IN_F            :   IN  STD_LOGIC;                              -- SERIAL DATA IN-->FALL EDGE
        PLL_SS_TIME         :   IN  STD_LOGIC_VECTOR(13 DOWNTO 0);          -- STEADY STATE TIME COUNT ALLOCATED FOR THE ADJUSTABLE PLL

        DDR_Q0_RISE         :   OUT STD_LOGIC;                              -- TEST PORT VALUE OF THE REC'D DDR BIT STREAM (RISE)
        DDR_Q1_FALL         :   OUT STD_LOGIC;                              -- TEST PORT VALUE OF THE REC'D DDR BIT STREAM (FALL)

        PHASE_ADJ_160_L     :   OUT STD_LOGIC_VECTOR(4 DOWNTO 0);           -- 160 MHZ PHASE ADJ CONTROL BITS (NOMINAL 160 PS STEP SIZE) FOR THE 160MHZ DDR ADJ CLOCK
        P_CONFIG_ONCE_TRIG  :   OUT STD_LOGIC;                              -- PULSE TRIGGER TO FORCE A CCC#2 UPDATE
        P_CCC_RESET_EN      :   OUT STD_LOGIC_VECTOR(0 DOWNTO 0);           -- '1' FORCES A CCC RESET PULSE IMMEDIATELY AFTER CONFIG UPDATES, '0' DISABLES THIS FEATURE
        P_RECD_SER_WORD     :   OUT STD_LOGIC_VECTOR(7 DOWNTO 0);           -- 8 BIT SERIAL OUTPUT WORD
        P_BIT_OS_SEL        :   OUT STD_LOGIC_VECTOR(2 DOWNTO 0);           -- FINAL SELECTED BIT OFFSET ALIGNMENT VALUE
        P_ALIGN_ACTIVE      :   OUT STD_LOGIC                               -- '1' INDICATES THAT THE ALIGN MODE IS ACTIVE
    );
end MASTER_DES320M;

architecture RTL of MASTER_DES320M is

-- DEFINE SIGNALS THAT OPERATE FROM THE 40 MHZ CLOCK
-- DEFINE THE STATES FOR THE DE-SERIALIZER STATE MACHINE
    TYPE DES_STATES IS (  INIT, FIND_ALIGN, CHK_BIT_OS_CNTS, INCR_CLK_PH, ALIGN_DONE, WAIT_FOR_SS, WAIT_FOR_INIT_SS, CALC_FINAL_ALIGN, GEN_ALIGN_DONE_FG );
    SIGNAL N_DES_SM, DES_SM                     :   DES_STATES;         

    SIGNAL ARB_WRD_40M_FIXED                    :   STD_LOGIC_VECTOR(14 DOWNTO 0);          -- REC'D BITS SYNC'D TO CCC1 PHASE STATIC CLK40MHZ
    SIGNAL ARB_BYTE                             :   STD_LOGIC_VECTOR(14 DOWNTO 0);          -- REC'D BITS SYNC'D TO CLK40MHZ_GEN

    SIGNAL N_CLKPHASE, CLKPHASE                 :   STD_LOGIC_VECTOR(4 DOWNTO 0);           -- INTERNAL SIGNAL OF THE CLOCK PHASE ADJMENT COMMAND FOR THE CCC THAT GENERATES THE 160 MHZ
    SIGNAL N_BEST_CLKPHASE, BEST_CLKPHASE       :   STD_LOGIC_VECTOR(4 DOWNTO 0);           -- FINAL 'BEST' VALUE FOR THE CLOCK PHASE
    SIGNAL N_BEST_BIT_OS_VAL, BEST_BIT_OS_VAL   :   STD_LOGIC_VECTOR(3 DOWNTO 0);           -- THIS 'BEST' VALUE FOR BIT OFFSET VALUE (EXTRA BIT NEEDED TO ACCOUNT FOR NO OS VAL (1000)
    SIGNAL N_TUNE_CLKPHASE, TUNE_CLKPHASE       :   STD_LOGIC_VECTOR(4 DOWNTO 0);           -- THIS IS THE FINAL CLOCK PHASE SETPOINT TO USE ALONG WITH THE BEST_BIT_OS_VAL!

    TYPE BIT_OS_VALUES IS ARRAY (0 TO 31) OF STD_LOGIC_VECTOR(3 DOWNTO 0);                  -- DEFINE AN ARRAY TO HOLD THE OFFSET VALUE FOUND FOR EACH CLOCK PHASE SETPOINT
    SIGNAL N_BIT_OS_VAL, BIT_OS_VAL             :   BIT_OS_VALUES;                          -- '8'= NO VALID OFFSET FOUND, 0 - 7 = VALID BIT OFFSET VALUES

    TYPE BIT_OS_SEQ_CNTS IS ARRAY (0 TO 31) OF STD_LOGIC_VECTOR(4 DOWNTO 0);                -- DEFINE AN ARRAY TO HOLD THE OFFSET VALUE FOUND FOR EACH CLOCK PHASE SETPOINT
    SIGNAL N_SEQCNTS, SEQCNTS                   :   BIT_OS_SEQ_CNTS;                        -- CONTAINS THE COUNTS OF SUCCESSIVE BIT OS SOLUTIONS THAT ARE THE SAME

    SIGNAL N_BEST_SEQCNT, BEST_SEQCNT           :   STD_LOGIC_VECTOR(4 DOWNTO 0);           -- CONTAINS THE HIGHEST SEQUENCE COUNT OBTAINED THRU 32 PHASE ADJ VALUES

    SIGNAL N_PHACNT_OK, PHACNT_OK               :   STD_LOGIC_VECTOR(4 DOWNTO 0);           -- CONTAINS COUNT OF THE TOTAL NUMBER OF ACCEPTABLE PHASE COUNT SOLUTIONS
    SIGNAL N_INDEX_CNT, INDEX_CNT               :   INTEGER RANGE 0 TO 31;                  -- INDEX POINTER FOR THE BIT_OS_VAL ARRAY

    SIGNAL N_LOOP_CNT, LOOP_CNT                 :   INTEGER RANGE 0 TO 7;                   -- LOOP COUNTER USED TO IMPLEMENT SEQUENTIAL RATHER THAN COMBINATORIAL FOR-->LOOPS

    TYPE BIT_OS_SET IS ARRAY (0 TO 7) OF STD_LOGIC_VECTOR(8 DOWNTO 0);                      -- DEFINE AN ARRAY TO HOLD THE 8 COUNTER RESULTS FOR THE BIT OFFSET CHECKS
    SIGNAL N_BIT_OS_CNT, BIT_OS_CNT             :   BIT_OS_SET;                             -- 512 COUNT OF SUCCESSFUL ALIGNMENT CHKS WITH A 0 BIT OFFSTE

    SIGNAL N_MAX_CNT, MAX_CNT                   :   STD_LOGIC_VECTOR(8 DOWNTO 0);           -- COUNTER OF NUMBER OF STATISTICAL TRIALS FOR RUNNING THE BIT AND CLOCK PHASE ALIGNMENT TESTS
    SIGNAL N_WAITCNT, WAITCNT                   :   STD_LOGIC_VECTOR(13 DOWNTO 0);          -- WAIT DELAY TIMER

    SIGNAL N_ALIGN_ACTIVE, ALIGN_ACTIVE         :   STD_LOGIC;                              -- '1' SIGNIFIES ALIGNMENT CAL PROCESS IS ACTIVE

    SIGNAL N_RECD_SER_WORD, RECD_SER_WORD       :   STD_LOGIC_VECTOR(7 DOWNTO 0);           -- THIS IS THE SERIAL WORD WITH ALIGNMENT FOR BIT AND CLOCK PHASE APPLIED

    SIGNAL N_CONFIG_ONCE_TRIG, CONFIG_ONCE_TRIG :   STD_LOGIC;                              -- PULSE USED TO TRIGGER A PHASE ADJ UPDATE TO CCC#2

    SIGNAL N_BIT_OS_SEL, BIT_OS_SEL             :   STD_LOGIC_VECTOR(3 DOWNTO 0);           -- FINAL SELECTED BIT OFFSET ALIGNMENT VALUE
    SIGNAL N_PHASE_ADJ, PHASE_ADJ               :   STD_LOGIC_VECTOR(4 DOWNTO 0);           -- FINAL SELECTED PHASE ADJMENT VALUE FOR CCC#2 160 MHZ PHASE

    SIGNAL N_CCC_RESET_EN, CCC_RESET_EN         :   STD_LOGIC_VECTOR(0 DOWNTO 0);           -- '1' FORCES A CCC RESET PULSE IMMEDIATELY AFTER CONFIG UPDATES, '0' DISABLES THIS FEATURE

-- DEFINE SIGNALS THAT OPERATE FROM CCC_160_ADJ CLOCK.  SUFFIX 'R' OR 'F' DEFINES WHICH EDGE
    SIGNAL  ADJ_SER_IN_R_0DEL                   :   STD_LOGIC;                              -- SAMPLE OF THE DDR RISE BIT (1ST SAMPLE)
    SIGNAL  ADJ_SER_IN_F_0DEL                   :   STD_LOGIC;                              -- SAMPLE OF THE DDR FALL BIT (1ST SAMPLE)

    SIGNAL  ADJ_SER_IN_R_1DEL                   :   STD_LOGIC;                              -- SAMPLE OF THE DDR RISE BIT (2ND SAMPLE)
    SIGNAL  ADJ_SER_IN_F_1DEL                   :   STD_LOGIC;                              -- SAMPLE OF THE DDR FALL BIT (2ND SAMPLE)

    SIGNAL 	ADJ_Q                               :   STD_LOGIC_VECTOR(15 DOWNTO 0);          -- SHIFT REGISTER USED TO SHIFT IN THE DDR BITS 

-- DEFINE SIGNALS THAT OPERATE FROM CCC_160M_FXD CLOCK.  SUFFIX 'R' OR 'F' DEFINES WHICH EDGE
    SIGNAL Q                                    :   STD_LOGIC_VECTOR(15 DOWNTO 0);          -- SHIFT REGISTER USED TO SHIFT IN THE DDR BITS 

-- DEFINE SOME DEBUG SIGNALS
    TYPE ALIGN_SOLNS IS ARRAY (0 TO 7) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL N_DAT_ALIGN, DAT_ALIGN               : ALIGN_SOLNS;

    CONSTANT INIT_PLL_SS_TIME      :   STD_LOGIC_VECTOR(13 DOWNTO 0) := "11111111111111";   -- INITIAL DELAY NEEDED TO ACCOMMODATE THE CCC RESET ON 1ST DYNAMIC CONFIG
    CONSTANT CCC_UPDATE_WAIT       :   STD_LOGIC_VECTOR(13 DOWNTO 0) := "00000011111111";   -- DELAY TO ALLOW FINAL CCC UPDATE TO BE COMPLETED

begin

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- THE RAW EVEN AND ODD DDR SERIAL BITS ARE FIRST CLOCKED VIA THE PHASE ADJUSTABLE CCC_160M_ADJ, AND THEN THE FIXED CCC_160M_FXD.
-- THE INTENT TO TO PROVIDE ADDITIONAL TIMING MARGIN TO THE UNTIMATE CLK_40M_FXD.
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- DEFINE ALL THE REGISTERS THAT OPERATE AT PHASE ADJUSTABLE 160 MHZ !!!RISE!!! EDGE

    REG160M_ADJ_R:PROCESS(CCC_160M_ADJ, RESET_B)
        BEGIN

            IF RESET_B = '0' THEN
                ADJ_Q               <=  (OTHERS => '0');

                ADJ_SER_IN_R_0DEL   <=  '0';
                ADJ_SER_IN_F_0DEL   <=  '0';

                ADJ_SER_IN_R_1DEL   <=  '0';
                ADJ_SER_IN_F_1DEL   <=  '0';

            ELSIF (CCC_160M_ADJ'EVENT AND CCC_160M_ADJ='1') THEN              			-- DDR 'FALL' DATA IS ALWAYS 'OLDER' THAN THE 'RISE' DATA!

                ADJ_SER_IN_R_0DEL   <=  SER_IN_R;                                   	-- SHIFT IN THE ARBITRARILY ASSIGNED 'EVEN' BITS
                ADJ_SER_IN_F_0DEL   <=  SER_IN_F;                                   	-- SHIFT IN THE ARBITRARILY ASSIGNED 'ODD' BITS

                ADJ_SER_IN_R_1DEL   <=  ADJ_SER_IN_R_0DEL;                              -- 2ND SAMPLES TO ADDRESS CLOCK PHASE ADJ INDUCED SETUP/HOLD VIOLATIONS
                ADJ_SER_IN_F_1DEL   <=  ADJ_SER_IN_F_0DEL;                              -- "

                ADJ_Q(0)            <=  ADJ_SER_IN_R_1DEL;                              -- SHIFT IN THE ARBITRARILY ASSIGNED 'EVEN' BITS
                ADJ_Q(1)            <=  ADJ_SER_IN_F_1DEL;                              -- SHIFT IN THE ARBITRARILY ASSIGNED 'ODD' BITS
                ADJ_Q(2)            <=  ADJ_Q(0);
                ADJ_Q(3)            <=  ADJ_Q(1);

                ADJ_Q(4)            <=  ADJ_Q(2);
                ADJ_Q(5)            <=  ADJ_Q(3);
                ADJ_Q(6)            <=  ADJ_Q(4);
                ADJ_Q(7)            <=  ADJ_Q(5);

                ADJ_Q(8)            <=  ADJ_Q(6);
                ADJ_Q(9)            <=  ADJ_Q(7);
                ADJ_Q(10)           <=  ADJ_Q(8);
                ADJ_Q(11)           <=  ADJ_Q(9);

                ADJ_Q(12)           <=  ADJ_Q(10);
                ADJ_Q(13)           <=  ADJ_Q(11);
                ADJ_Q(14)           <=  ADJ_Q(12);
                ADJ_Q(15)           <=  ADJ_Q(13);

            END IF;

        END PROCESS REG160M_ADJ_R;

-- DEFINE ALL THE REGISTERS THAT OPERATE AT THE FIXED 160 MHZ !!!RISE!!! EDGE

    REG160M_FXD_R:PROCESS(CCC_160M_FXD, RESET_B)
        BEGIN

            IF RESET_B = '0' THEN
                Q               <=  (OTHERS => '0');

            ELSIF (CCC_160M_FXD'EVENT AND CCC_160M_FXD='1') THEN 
				Q				<=	ADJ_Q;
			
            END IF;

        END PROCESS REG160M_FXD_R;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- SAMPLE THE LAST SET OF 15 SEQUENTIAL BITS OF THE SERIAL DATA STREAM USING THE FIXED 40 MHZ CLOCK
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    AUX40M:PROCESS(CLK_40M_FXD, RESET_B)                                         -- FIXED 40 MHZ RISE EDGE IS ALIGNED, BUT SLIGHTLY PRECEEDS THE RISE EDGE OF 
        BEGIN                                                                    -- THE 160 MHZ SERDES CLOCK USED BY PROCESS REG160M_R ABOVE
                                                                                 -- (TUNABLE 160MHZ RANGE IS SLIGHTLY LESS THAN 1 CYCLE OF 160MHZ)
            IF RESET_B = '0' THEN
                ARB_WRD_40M_FIXED    <=  (OTHERS => '0');           
            
            ELSIF (CLK_40M_FXD'EVENT AND CLK_40M_FXD='1') THEN                                          -- SYNC THE BITS TO THE 40 MHZ 
                ARB_WRD_40M_FIXED   <=          Q(14) & Q(13) & Q(12) & Q(11) & Q(10) & Q(9) & Q(8) &
                                        Q(7)  & Q(6)  & Q(5)  & Q(4)  & Q(3)  & Q(2)  & Q(1) & Q(0); 

            END IF;

        END PROCESS AUX40M;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- DEFINE ALL THE REGISTERS THAT OPERATE AT THE GLOBAL FIXED 40 MHZ
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    REG40M:PROCESS(CLK_40M_FXD, RESET_B)                                         -- 
        BEGIN

            IF RESET_B = '0' THEN
                DES_SM              <=  INIT;

                ARB_BYTE            <=  (OTHERS => '0');           
                CLKPHASE            <=  (OTHERS => '0');
                BEST_CLKPHASE       <=  (OTHERS => '0');
                TUNE_CLKPHASE       <=  "00001";						-- AVOID THE 0 PHASE ADJ SETTING
                BIT_OS_CNT          <=  (OTHERS => "000000000");
                BEST_BIT_OS_VAL     <=  (OTHERS => '0');
                MAX_CNT             <=  (OTHERS => '0');
                WAITCNT             <=  (OTHERS => '0');

                BIT_OS_VAL          <=  (OTHERS => "0000");
                PHACNT_OK           <=  (OTHERS => '0');
                INDEX_CNT           <=   0;
                
                ALIGN_ACTIVE        <=  '0';
                RECD_SER_WORD       <=  (OTHERS => '0');

                DAT_ALIGN           <=  (OTHERS => "00000000");
                SEQCNTS             <=  (OTHERS => "00000");
                BEST_SEQCNT         <=  (OTHERS => '0');

                CONFIG_ONCE_TRIG    <=  '0';

                BIT_OS_SEL          <=  (OTHERS => '0');
                PHASE_ADJ           <=  (OTHERS => '0');

                CCC_RESET_EN        <=  "0";

                LOOP_CNT            <=   0;
            
            ELSIF (CLK_40M_FXD'EVENT AND CLK_40M_FXD='1') THEN
                DES_SM              <=  N_DES_SM;

                ARB_BYTE            <=  ARB_WRD_40M_FIXED;              
                CLKPHASE            <=  N_CLKPHASE;
                BEST_CLKPHASE       <=  N_BEST_CLKPHASE;
                TUNE_CLKPHASE       <=  N_TUNE_CLKPHASE;
                BIT_OS_CNT          <=  N_BIT_OS_CNT;
                BEST_BIT_OS_VAL     <=  N_BEST_BIT_OS_VAL;
                MAX_CNT             <=  N_MAX_CNT;
                WAITCNT             <=  N_WAITCNT;

                BIT_OS_VAL          <=  N_BIT_OS_VAL;
                PHACNT_OK           <=  N_PHACNT_OK;
                INDEX_CNT           <=  N_INDEX_CNT;

                ALIGN_ACTIVE        <=  N_ALIGN_ACTIVE;
                RECD_SER_WORD       <=  N_RECD_SER_WORD;

                DAT_ALIGN           <=  N_DAT_ALIGN;
                SEQCNTS             <=  N_SEQCNTS;
                BEST_SEQCNT         <=  N_BEST_SEQCNT;

                CONFIG_ONCE_TRIG    <=  N_CONFIG_ONCE_TRIG;

                BIT_OS_SEL          <=  N_BIT_OS_SEL;
                PHASE_ADJ           <=  N_PHASE_ADJ;

                CCC_RESET_EN        <=  N_CCC_RESET_EN;

                LOOP_CNT            <=  N_LOOP_CNT;

            END IF;

        END PROCESS REG40M;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- DEFINE THE STATE MACHINE THAT CONTROLS THE BIT CLOCK AND BYTE ALIGNMENT OPERATION
-- 
-- 
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    SYNC_SM:PROCESS(    DES_SM, 
                        CLKPHASE, BEST_CLKPHASE, TUNE_CLKPHASE, BEST_SEQCNT,
                        BEST_BIT_OS_VAL, MAX_CNT, 
                        BIT_OS_CNT, PLL_SS_TIME,
                        WAITCNT, ALIGN_ACTIVE,
                        ARB_BYTE, ALIGN_PATT, ALIGN_MODE_EN, CCC2_CLK_LOCK,
                        BIT_OS_VAL, PHACNT_OK, INDEX_CNT, LOOP_CNT,
                        MAN_AUTO_ALIGN, BIT_OS_SEL, MAN_PHASE_ADJ, MAN_BIT_OS,
                        CCC_RESET_EN
                    )
        BEGIN

            -- DEFAULT ASSIGNMENTS
            N_CLKPHASE          <=  CLKPHASE;
            N_BEST_CLKPHASE     <=  BEST_CLKPHASE;                              -- THESE ONLY GET INITIALIZED AT POR
            N_BEST_BIT_OS_VAL   <=  BEST_BIT_OS_VAL;                            -- OR ONCE THE ALIGNMENT PROCESS IS RE-ENABLED
            N_TUNE_CLKPHASE     <=  TUNE_CLKPHASE;                              -- ONLY GETS INITIALIZED AT POR
            N_MAX_CNT           <=  MAX_CNT;
            N_BIT_OS_CNT        <=  BIT_OS_CNT;
            N_WAITCNT           <=  WAITCNT;
            N_ALIGN_ACTIVE      <=  ALIGN_ACTIVE;

            N_BIT_OS_VAL        <=  BIT_OS_VAL;
            N_PHACNT_OK         <=  PHACNT_OK;
            N_INDEX_CNT         <=  INDEX_CNT;
            N_SEQCNTS           <=  SEQCNTS;
            N_BEST_SEQCNT       <=  BEST_SEQCNT;

            N_CCC_RESET_EN      <=  CCC_RESET_EN;

            N_CONFIG_ONCE_TRIG  <=  '0';                                        -- OVER-WRITTEN BELOW TO GENERATE A SIGNAL FOR A SINGLE CLOCK PULSE

            N_LOOP_CNT          <=  LOOP_CNT;
            
            -- CREATE THE REC'D SERIAL BYTE WITH BIT ALIGNMENT SHIFT APPLIED
            CASE BIT_OS_SEL IS
             WHEN "0000" =>   N_RECD_SER_WORD   <=  ARB_BYTE(7)  & ARB_BYTE(6)  & ARB_BYTE(5)  & ARB_BYTE(4)  & ARB_BYTE(3)  & ARB_BYTE(2) & ARB_BYTE(1) & ARB_BYTE(0);
             WHEN "0001" =>   N_RECD_SER_WORD   <=  ARB_BYTE(8)  & ARB_BYTE(7)  & ARB_BYTE(6)  & ARB_BYTE(5)  & ARB_BYTE(4)  & ARB_BYTE(3) & ARB_BYTE(2) & ARB_BYTE(1);
             WHEN "0010" =>   N_RECD_SER_WORD   <=  ARB_BYTE(9)  & ARB_BYTE(8)  & ARB_BYTE(7)  & ARB_BYTE(6)  & ARB_BYTE(5)  & ARB_BYTE(4) & ARB_BYTE(3) & ARB_BYTE(2);
             WHEN "0011" =>   N_RECD_SER_WORD   <=  ARB_BYTE(10) & ARB_BYTE(9)  & ARB_BYTE(8)  & ARB_BYTE(7)  & ARB_BYTE(6)  & ARB_BYTE(5) & ARB_BYTE(4) & ARB_BYTE(3);
             WHEN "0100" =>   N_RECD_SER_WORD   <=  ARB_BYTE(11) & ARB_BYTE(10) & ARB_BYTE(9)  & ARB_BYTE(8)  & ARB_BYTE(7)  & ARB_BYTE(6) & ARB_BYTE(5) & ARB_BYTE(4);
             WHEN "0101" =>   N_RECD_SER_WORD   <=  ARB_BYTE(12) & ARB_BYTE(11) & ARB_BYTE(10) & ARB_BYTE(9)  & ARB_BYTE(8)  & ARB_BYTE(7) & ARB_BYTE(6) & ARB_BYTE(5);
             WHEN "0110" =>   N_RECD_SER_WORD   <=  ARB_BYTE(13) & ARB_BYTE(12) & ARB_BYTE(11) & ARB_BYTE(10) & ARB_BYTE(9)  & ARB_BYTE(8) & ARB_BYTE(7) & ARB_BYTE(6);
             WHEN "0111" =>   N_RECD_SER_WORD   <=  ARB_BYTE(14) & ARB_BYTE(13) & ARB_BYTE(12) & ARB_BYTE(11) & ARB_BYTE(10) & ARB_BYTE(9) & ARB_BYTE(8) & ARB_BYTE(7);
             WHEN OTHERS =>   N_RECD_SER_WORD   <=  ARB_BYTE(7)  & ARB_BYTE(6)  & ARB_BYTE(5)  & ARB_BYTE(4)  & ARB_BYTE(3)  & ARB_BYTE(2) & ARB_BYTE(1) & ARB_BYTE(0);
            END CASE;


            -- ALIGNMENT MODE SELECTION MUX
            IF MAN_AUTO_ALIGN = '0' THEN                                        -- '0'= AUTO
                N_BIT_OS_SEL        <=  BEST_BIT_OS_VAL;
                N_PHASE_ADJ         <=  CLKPHASE;							
            ELSE
                N_BIT_OS_SEL        <=  MAN_BIT_OS;
                N_PHASE_ADJ         <=  MAN_PHASE_ADJ;
            END IF;


            -- STATE MACHINE LOGIC
            CASE DES_SM IS

                WHEN INIT           =>
                    N_CLKPHASE          <=  TUNE_CLKPHASE;                      -- ASSIGN THE LAST 'WORKING' VALUE UNTIL READY TO START NEW MEASUREMENTS

                    IF (ALIGN_MODE_EN = '1') THEN                               -- CHANGED FROM AN EDGE-TRIGGERED EVENT SO IT CAN RUN JUST ONCE WHEN ENABLED!
                        N_DES_SM            <=  WAIT_FOR_INIT_SS;               -- NEED TO COMMAND THE CCC#2 FOR INITIAL PHASE VAL
                        N_BEST_CLKPHASE     <=  (OTHERS => '0');                -- THESE ONLY GET INITIALZED AT POR
                        N_CLKPHASE          <=  "00001";                		-- OR ONCE THE ALIGNMENT PROCESS IS RE-ENABLED (AVOID THE 0 PHASE ADJ SETTING)
                        N_BEST_BIT_OS_VAL   <=  (OTHERS => '0');                -- "
                        N_ALIGN_ACTIVE      <=  '1';
                        N_CCC_RESET_EN      <=  "1";                            -- ONLLY ALLOW A CCC RESET THE TIME USED AT START OF ALIGNMENT
                        N_CONFIG_ONCE_TRIG  <=  '1';                            -- GENERATE A TRIGGER TO UPDATE THE PHASE ADJ CCC#2
                    ELSE
                        N_DES_SM        <=  INIT;
                        N_ALIGN_ACTIVE      <=  '0';
                    END IF;
                    
                    N_WAITCNT           <=  (OTHERS => '0');
                    N_INDEX_CNT         <=   0;
                    N_LOOP_CNT          <=   0;

                    N_BIT_OS_CNT        <=  (OTHERS => "000000000");            -- INITIALIZE THE OFFSET MEASUREMENT COUNTS 0 THRU 7 
                    N_MAX_CNT           <=  (OTHERS => '0');

                    N_SEQCNTS           <=  (OTHERS => "00000");
                    N_BEST_SEQCNT       <=  (OTHERS => '0');

                WHEN FIND_ALIGN     =>                                          -- FINDS THE BIT CLOCK PHASE AND BYTE ALIGNMENT SOLUTIONS    

                    N_CCC_RESET_EN  <=  "0";                                    -- ALL REMAINING CCC UPDATES DONE WITHOUT A RESET APPLIED!

                    FOR I IN 0 TO 7 LOOP                                        -- ONLY INCREMENT THE COUNT VALUE ASSOCIATED WITH THE # BIT ROTATE SPECIFIED BY 'I'    
                        CASE I IS
                         WHEN 0 =>   IF ARB_BYTE(7) & ARB_BYTE(6) & ARB_BYTE(5) & ARB_BYTE(4) & ARB_BYTE(3) & ARB_BYTE(2) & ARB_BYTE(1) & ARB_BYTE(0) = ALIGN_PATT THEN
                                        N_BIT_OS_CNT(I)     <=  BIT_OS_CNT(I) + '1';  
                                        N_DAT_ALIGN(I)      <=  ALIGN_PATT;
                                     ELSE
                                        N_DAT_ALIGN(I)      <=  (OTHERS => '0');
                                     END IF;
                         WHEN 1 =>   IF ARB_BYTE(0) & ARB_BYTE(7) & ARB_BYTE(6) & ARB_BYTE(5) & ARB_BYTE(4) & ARB_BYTE(3) & ARB_BYTE(2) & ARB_BYTE(1) = ALIGN_PATT THEN
                                        N_BIT_OS_CNT(I)     <=  BIT_OS_CNT(I) + '1';  
                                        N_DAT_ALIGN(I)      <=  ALIGN_PATT;
                                     ELSE
                                        N_DAT_ALIGN(I)      <=  (OTHERS => '0');
                                     END IF;
                         WHEN 2 =>   IF ARB_BYTE(1) & ARB_BYTE(0) & ARB_BYTE(7) & ARB_BYTE(6) & ARB_BYTE(5) & ARB_BYTE(4) & ARB_BYTE(3) & ARB_BYTE(2) = ALIGN_PATT THEN
                                        N_BIT_OS_CNT(I)     <=  BIT_OS_CNT(I) + '1';  
                                        N_DAT_ALIGN(I)      <=  ALIGN_PATT;
                                     ELSE
                                        N_DAT_ALIGN(I)      <=  (OTHERS => '0');
                                     END IF;
                         WHEN 3 =>   IF ARB_BYTE(2) & ARB_BYTE(1) & ARB_BYTE(0) & ARB_BYTE(7) & ARB_BYTE(6) & ARB_BYTE(5) & ARB_BYTE(4) & ARB_BYTE(3) = ALIGN_PATT THEN
                                        N_BIT_OS_CNT(I)     <=  BIT_OS_CNT(I) + '1';  
                                        N_DAT_ALIGN(I)      <=  ALIGN_PATT;
                                     ELSE
                                        N_DAT_ALIGN(I)      <=  (OTHERS => '0');
                                     END IF;
                         WHEN 4 =>   IF ARB_BYTE(3) & ARB_BYTE(2) & ARB_BYTE(1) & ARB_BYTE(0) & ARB_BYTE(7) & ARB_BYTE(6) & ARB_BYTE(5) & ARB_BYTE(4) = ALIGN_PATT THEN
                                        N_BIT_OS_CNT(I)     <=  BIT_OS_CNT(I) + '1';  
                                        N_DAT_ALIGN(I)      <=  ALIGN_PATT;
                                     ELSE
                                        N_DAT_ALIGN(I)      <=  (OTHERS => '0');
                                     END IF;
                         WHEN 5 =>   IF ARB_BYTE(4) & ARB_BYTE(3) & ARB_BYTE(2) & ARB_BYTE(1) & ARB_BYTE(0) & ARB_BYTE(7) & ARB_BYTE(6) & ARB_BYTE(5) = ALIGN_PATT THEN
                                        N_BIT_OS_CNT(I)     <=  BIT_OS_CNT(I) + '1';  
                                        N_DAT_ALIGN(I)      <=  ALIGN_PATT;
                                     ELSE
                                        N_DAT_ALIGN(I)      <=  (OTHERS => '0');
                                     END IF;
                         WHEN 6 =>   IF ARB_BYTE(5) & ARB_BYTE(4) & ARB_BYTE(3) & ARB_BYTE(2) & ARB_BYTE(1) & ARB_BYTE(0) & ARB_BYTE(7) & ARB_BYTE(6) = ALIGN_PATT THEN
                                        N_BIT_OS_CNT(I)     <=  BIT_OS_CNT(I) + '1';  
                                        N_DAT_ALIGN(I)      <=  ALIGN_PATT;
                                     ELSE
                                        N_DAT_ALIGN(I)      <=  (OTHERS => '0');
                                     END IF;
                         WHEN 7 =>   IF ARB_BYTE(6) & ARB_BYTE(5) & ARB_BYTE(4) & ARB_BYTE(3) & ARB_BYTE(2) & ARB_BYTE(1) & ARB_BYTE(0) & ARB_BYTE(7) = ALIGN_PATT THEN
                                        N_BIT_OS_CNT(I)     <=  BIT_OS_CNT(I) + '1';  
                                        N_DAT_ALIGN(I)      <=  ALIGN_PATT;
                                     ELSE
                                        N_DAT_ALIGN(I)      <=  (OTHERS => '0');
                                     END IF;
                        END CASE;
                    END LOOP;


--++++
-- changed max cnt limit from all 1's
--++++
                    IF MAX_CNT="000001111" THEN 
                        N_DES_SM        <=  CHK_BIT_OS_CNTS;
                        N_MAX_CNT       <=  (OTHERS=> '0');

                    ELSE
                        N_DES_SM        <=  FIND_ALIGN;
                        N_MAX_CNT       <=  MAX_CNT + 1;

                    END IF;


                WHEN CHK_BIT_OS_CNTS    =>                                              -- SEQUENTIALLY CHECK WHICH OF THE BIT OFFSET COUNT VALUES WAS HIGHEST 
                                                                                        -- BEFORE INCREMENTING THE CLOCK PHASE DELAY
                    N_BIT_OS_VAL(CONV_INTEGER(CLKPHASE))    <= "1000";                  -- THE DEFAULT IS 'NO VALID OFFSET VALUE FOUND FOR THIS CLOCK PHASE' UNLESS OVER-WRITTEN BELOW!
-- +++ alt sequential approach
-- IS

                        --IF BIT_OS_CNT(LOOP_CNT) > "000001101"   THEN                                                -- BOTH MAX COUNT AND MAX COUNT LESS 1 ARE CONSIDERED OK HERE
                            --N_BIT_OS_VAL(CONV_INTEGER(CLKPHASE))    <= CONV_STD_LOGIC_VECTOR(LOOP_CNT, 4);          -- SAVE THE BIT OFFSET VALUE OBTAINED FOR EACH CLKPHASE 
--
                            --IF CLKPHASE > "00000" THEN                                                              -- 
                                --IF BIT_OS_VAL(CONV_INTEGER(CLKPHASE)-1) = CONV_STD_LOGIC_VECTOR(LOOP_CNT, 4) THEN   -- INCREMENT THE SEQCNT FOR THIS CLKPHASE SETPOINT IF THE NEXT ...
                                    --N_SEQCNTS(CONV_INTEGER(CLKPHASE)) <=  SEQCNTS(CONV_INTEGER(CLKPHASE-1)) + '1';  -- ... VALUE IS THE SAME AS THIS PRESENT VALUE
                                --END IF;
                            --END IF;
--
                        --END IF;
--
                        --N_BIT_OS_CNT(LOOP_CNT)     <=  (OTHERS => '0');                 -- CAN RE-INITIALIZE NOW THAT IT HAS BEEN CHECKED AND SAVED
--
                    --IF LOOP_CNT = 7 THEN
                        --IF CLKPHASE="11111" THEN
                            --N_DES_SM        <=  ALIGN_DONE;                               
                        --ELSE
                            --N_DES_SM        <=  INCR_CLK_PH;
                        --END IF;
--
                        --N_LOOP_CNT      <=  0;
--
                    --ELSE
                        --N_DES_SM        <=  CHK_BIT_OS_CNTS;
                        --N_LOOP_CNT      <=  LOOP_CNT + 1;
--
                    --END IF;
--+++
-- WAS:
                    FOR I IN 0 TO 7 LOOP
                        IF BIT_OS_CNT(I) > "000001101"   THEN                                                       -- BOTH MAX COUNT AND MAX COUNT LESS 1 ARE CONSIDERED OK HERE
                            N_BIT_OS_VAL(CONV_INTEGER(CLKPHASE))    <= CONV_STD_LOGIC_VECTOR(I, 4);                 -- SAVE THE BIT OFFSET VALUE OBTAINED FOR EACH CLKPHASE 

                            IF CLKPHASE > "00000" THEN                                                              -- 
                                IF BIT_OS_VAL(CONV_INTEGER(CLKPHASE)-1) = CONV_STD_LOGIC_VECTOR(I, 4) THEN          -- INCREMENT THE SEQCNT FOR THIS CLKPHASE SETPOINT IF THE NEXT ...
                                    N_SEQCNTS(CONV_INTEGER(CLKPHASE)) <=  SEQCNTS(CONV_INTEGER(CLKPHASE-1)) + '1';  -- ... VALUE IS THE SAME AS THIS PRESENT VALUE
                                END IF;
                            END IF;

                        END IF;

                        N_BIT_OS_CNT(I)     <=  (OTHERS => '0');                        -- CAN RE-INITIALIZE NOW THAT IT HAS BEEN CHECKED AND SAVED

                    END LOOP;

                    IF CLKPHASE="11110" THEN
                        N_DES_SM        <=  ALIGN_DONE;                               
                    ELSE
                        N_DES_SM        <=  INCR_CLK_PH;
                    END IF;

                WHEN INCR_CLK_PH    =>                                          -- INCREMENT THE CLOCK PHASE COMMAND
                    N_CLKPHASE          <=  CLKPHASE + '1';
                    N_DES_SM            <=  WAIT_FOR_SS;
                    N_CONFIG_ONCE_TRIG  <=  '1';                                -- GENERATE A TRIGGER TO UPDATE THE PHASE ADJ CCC#2

--++++
-- changed wait count from 1024
--+++++
                WHEN WAIT_FOR_SS    =>                                          -- WAIT FOR THE PLL TO STABILIZE BACK TO STEADY STATE
                    IF (CCC2_CLK_LOCK = '1' AND WAITCNT = PLL_SS_TIME) THEN
                        N_DES_SM        <=  FIND_ALIGN;
                        N_WAITCNT       <=  (OTHERS => '0');
                    ELSIF (CCC2_CLK_LOCK = '0') THEN                            -- WANT TO COUNT THE ADDITIONAL ONLY AFTER THE PLL HAS LOCK 
                        N_DES_SM        <=  WAIT_FOR_SS;
                        N_WAITCNT       <=  (OTHERS => '0');
                    ELSE
                        N_DES_SM        <=  WAIT_FOR_SS;
                        N_WAITCNT       <=  WAITCNT + '1';
                    END IF;

                WHEN WAIT_FOR_INIT_SS    =>                                     -- INITIAL WAIT FOR THE PLL TO STABILIZE BACK TO STEADY STATE
                    IF (CCC2_CLK_LOCK = '1' AND WAITCNT = INIT_PLL_SS_TIME) THEN
                        N_DES_SM        <=  FIND_ALIGN;
                        N_WAITCNT       <=  (OTHERS => '0');
                    ELSIF (CCC2_CLK_LOCK = '0') THEN                            -- WANT TO COUNT THE ADDITIONAL ONLY AFTER THE PLL HAS LOCK 
                        N_DES_SM        <=  WAIT_FOR_INIT_SS;
                        N_WAITCNT       <=  (OTHERS => '0');
                    ELSE
                        N_DES_SM        <=  WAIT_FOR_INIT_SS;
                        N_WAITCNT       <=  WAITCNT + '1';
                    END IF;


                WHEN ALIGN_DONE     =>  

                    IF INDEX_CNT = 29  THEN                                         -- ADD'L +2 FOR BIT CHECK YIELDS 30 (INCLUDING '0')
                        N_DES_SM        <=  CALC_FINAL_ALIGN;       
                        N_INDEX_CNT     <=  0;

                    ELSE
                        N_DES_SM        <=  ALIGN_DONE;
                        N_INDEX_CNT     <=  INDEX_CNT + 1;

                        IF (SEQCNTS(INDEX_CNT+1) > BEST_SEQCNT) THEN                     -- 
                            N_BEST_CLKPHASE     <=  CONV_STD_LOGIC_VECTOR(INDEX_CNT+1, 5);
                            N_BEST_BIT_OS_VAL   <=  BIT_OS_VAL(INDEX_CNT+1);
                            N_BEST_SEQCNT       <=  SEQCNTS(INDEX_CNT+1);
                        ELSIF (BIT_OS_VAL(INDEX_CNT) = BIT_OS_VAL(INDEX_CNT + 1)) AND (BIT_OS_VAL(INDEX_CNT) = BIT_OS_VAL(INDEX_CNT + 2)) THEN
                            N_PHACNT_OK     <=  PHACNT_OK + '1';                     -- A 2 NEEDS TO BE ADDED TO THIS COUNT WHEN DONE SINCE TESTING THREE BITS AT A TIME!
                        END IF;
                    END IF;

                WHEN CALC_FINAL_ALIGN   =>
                    N_TUNE_CLKPHASE <=  BEST_CLKPHASE - BEST_SEQCNT(4 DOWNTO 1);    -- DIVIDE BY 2 (TRUNCATED)!
                    N_DES_SM        <=  GEN_ALIGN_DONE_FG;
                    N_CONFIG_ONCE_TRIG  <=  '1';                                    -- GENERATE A TRIGGER TO UPDATE THE PHASE ADJ CCC#2


                WHEN GEN_ALIGN_DONE_FG  =>                                          -- NEED TO WAIT FOR THE LAST CCC UPDATE TO COMPLETE 
                    N_CLKPHASE          <=  TUNE_CLKPHASE;                          -- ASSIGN THE LAST 'WORKING' VALUE UNTIL READY TO START NEW MEASUREMENTS

                    IF WAITCNT  = CCC_UPDATE_WAIT THEN                              -- BEFORE ALLOWING OTHER SUBSEQUENT OPS TO BEGIN
                        N_DES_SM        <=  INIT;                                   -- INIT STATE WILL CLEAR ALIGN_ACTIVE
                        N_WAITCNT       <=  (OTHERS => '0');
                    ELSE
                        N_DES_SM        <=  GEN_ALIGN_DONE_FG;
                        N_WAITCNT       <=  WAITCNT + '1';
                    END IF;
                        

                WHEN OTHERS         =>
                    N_DES_SM        <=  INIT;       

            END CASE;

    END PROCESS SYNC_SM;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ASSIGN INTERNAL SIGNALS TO EXTERNAL PORTS

PHASE_ADJ_160_L     <=  PHASE_ADJ;
P_RECD_SER_WORD     <=  RECD_SER_WORD;
P_ALIGN_ACTIVE      <=  ALIGN_ACTIVE;
P_CONFIG_ONCE_TRIG  <=  CONFIG_ONCE_TRIG;
P_CCC_RESET_EN      <=  CCC_RESET_EN;
DDR_Q0_RISE         <=  Q(0);
DDR_Q1_FALL         <=  Q(1);
P_BIT_OS_SEL        <=  BIT_OS_SEL(2 DOWNTO 0);

end RTL;
