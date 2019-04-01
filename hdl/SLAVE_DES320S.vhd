--------------------------------------------------------------------------------
-- Company: University of Maryland
--
-- File: SLAVE_DES320S.vhd
-- File history:
--      MAY 31, 2016 Rev A

-- Description: SLAVE DE-SERIALIZER operation.  THIS MODULE ACCEPTS THE DDR INPUT REGISTER RISE AND FALL LATCHED DATA RESULTS AS WELL AS THE BIT OFFSET COMMAND.  IT PRODUCES 
--                                              THE PARALLEL WORD BASED UPON THE COMMANDED BIT OFFSET POSITION.  THE BIT SAMPLE TIMIGN IS CONTROLLED BY THE MASTER_DES320M MODULE.  
--                                              LIKEWISE, THE BIT OFFSET COMMAND IS DERIVED BY MASTER_DES320M.

-- CLOCK DOMAIN INFO:   THIS APPROACH USES MUTLIPLE CLOCK DOMAINS, OF BOTH DYNAMIC AND STATIC CONFIGURATIONS, TO ACCOMPLISH THE TASKS.
--                      THERE ARE 2 CCC MODULES USED.  
--                      THE FIRST IS STATICALLY CONFIGURED TO GENERATE THE FIXED AND PHASE-RELATED 160 MHZ AND 40 MHZ CLOCKS. 
--                          THE RISE EDGE OF THE 40 MHZ CLOCK IS ALIGNED WITH A SLIGHT DELAY RELATICVE TO THE RISE EDGE OF THE 160 MHZ CLOCK VIA THE PLL.
--                          IT ALSO GENERATES A FIXED DELAYED COPY OF THE USB MODULE 60 MHZ CLOCK.
--                          THE REFERENCE IS SELECTED BASED UPON THE DCB OR SALT CONFIG JUMPER.
--                      THE SECOND CCC IS DYNAMICALLY CONFIGURED AND CONTROLLED BY THE MASTER_DES320M MODULE TO GENERATE THE 160 MHZ PHASE OFFSET CLOCKS, BUT TUNED WITH
--                      200 PS DELAY STEPS.  THESE LATTER CLOCKS ARE USED TO SAMPLE THE INCOMING DDR SERIAL DATA.  THE PHASE OF THIS 160 MHZ SAMPLE CLOCK IS TUNED DURING THE 
--                      SYNC MODE TO ACHIEVE THE PROPER ALIGNMENT TO RECEIVE THE SERIAL DATA.  THIS STREAM IS THEN SYNCHRONIXED THE FIXED 40 MHZ CLOCK.  
--                      THE TOTAL DELAY TUNE RANGE OF THE DYNAMIC 160 MHZ SAMPLE CLOCK IS APPROXIMATELY 1 CLOCK CYCLE.

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


entity SLAVE_DES320S is
port (
        CCC_160M_ADJ       	:   IN  STD_LOGIC;                              -- PHASE ADJUSTABLE 160 MHZ DDR CLOCK
		CCC_160M_FXD		:	IN	STD_LOGIC;								-- FIXED PHASE 160 MHZ DDR CLOCK

        BIT_OFFSET          :   IN  STD_LOGIC_VECTOR(2 DOWNTO 0);           -- BIT OFFSET DETERMINED BY THE MASTER_SER320m MODULE
		
        CLK_40M_FXD         :   IN  STD_LOGIC;                              -- FIXED PHASE 40 MHZ CLOCK 

        RESET_B             :   IN  STD_LOGIC;                              -- ACTIVE LOW RESET    

        SER_IN_R            :   IN  STD_LOGIC;                              -- SERIAL DATA IN-->RISE EDGE
        SER_IN_F            :   IN  STD_LOGIC;                             	-- SERIAL DATA IN-->FALL EDGE

		P_RECD_SER_WORD     :   OUT STD_LOGIC_VECTOR(7 DOWNTO 0)            -- 8 BIT SERIAL OUTPUT WORD
    );
end SLAVE_DES320S;

architecture RTL of SLAVE_DES320S is

-- DEFINE SIGNALS THAT OPERATE FROM THE 40 MHZ CLOCK

    SIGNAL ARB_WRD_40M_FIXED                    :   STD_LOGIC_VECTOR(14 DOWNTO 0);          -- REC'D BITS SYNC'D TO CCC1 PHASE STATIC CLK40MHZ
    SIGNAL ARB_BYTE                             :   STD_LOGIC_VECTOR(14 DOWNTO 0);          -- REC'D BITS SYNC'D TO CLK40MHZ_GEN

    SIGNAL N_RECD_SER_WORD, RECD_SER_WORD       :   STD_LOGIC_VECTOR(7 DOWNTO 0);           -- THIS IS THE SERIAL WORD WITH ALIGNMENT FOR BIT AND CLOCK PHASE APPLIED

-- DEFINE SIGNALS THAT OPERATE FROM CCC_160_ADJ CLOCK.  SUFFIX 'R' OR 'F' DEFINES WHICH EDGE
    SIGNAL  ADJ_SER_IN_R_0DEL                   :   STD_LOGIC;                              -- SAMPLE OF THE DDR RISE BIT (1ST SAMPLE)
    SIGNAL  ADJ_SER_IN_F_0DEL                   :   STD_LOGIC;                              -- SAMPLE OF THE DDR FALL BIT (1ST SAMPLE)

    SIGNAL  ADJ_SER_IN_R_1DEL                   :   STD_LOGIC;                              -- SAMPLE OF THE DDR RISE BIT (2ND SAMPLE)
    SIGNAL  ADJ_SER_IN_F_1DEL                   :   STD_LOGIC;                              -- SAMPLE OF THE DDR FALL BIT (2ND SAMPLE)

    SIGNAL 	ADJ_Q                               :   STD_LOGIC_VECTOR(15 DOWNTO 0);          -- SHIFT REGISTER USED TO SHIFT IN THE DDR BITS 

-- DEFINE SIGNALS THAT OPERATE FROM CCC_160M_FXD CLOCK.  SUFFIX 'R' OR 'F' DEFINES WHICH EDGE
    SIGNAL  SER_IN_R_0DEL                       :   STD_LOGIC;                              -- SAMPLE OF THE DDR RISE BIT (1ST SAMPLE)
    SIGNAL  SER_IN_F_0DEL                       :   STD_LOGIC;                              -- SAMPLE OF THE DDR FALL BIT (1ST SAMPLE)

    SIGNAL  SER_IN_R_1DEL                       :   STD_LOGIC;                              -- SAMPLE OF THE DDR RISE BIT (2ND SAMPLE)
    SIGNAL  SER_IN_F_1DEL                       :   STD_LOGIC;                              -- SAMPLE OF THE DDR FALL BIT (2ND SAMPLE)

    SIGNAL Q                                    :   STD_LOGIC_VECTOR(15 DOWNTO 0);          -- SHIFT REGISTER USED TO SHIFT IN THE DDR BITS 

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
                ARB_WRD_40M_FIXED   <=  (OTHERS => '0');

				ARB_BYTE            <=  (OTHERS => '0');           
                RECD_SER_WORD       <=  (OTHERS => '0');
            
            ELSIF (CLK_40M_FXD'EVENT AND CLK_40M_FXD='1') THEN                                          -- SYNC THE BITS TO THE 40 MHZ 
                ARB_WRD_40M_FIXED   <=          Q(14) & Q(13) & Q(12) & Q(11) & Q(10) & Q(9) & Q(8) &
                                        Q(7)  & Q(6)  & Q(5)  & Q(4)  & Q(3)  & Q(2)  & Q(1) & Q(0); 

				ARB_BYTE            <=  ARB_WRD_40M_FIXED;              										
                RECD_SER_WORD       <=  N_RECD_SER_WORD;

			END IF;

        END PROCESS AUX40M;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- DESERIALIZER
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    DESERIALIZE:PROCESS(BIT_OFFSET, ARB_BYTE)
        BEGIN
            
            -- CREATE THE REC'D SERIAL BYTE WITH BIT ALIGNMENT SHIFT APPLIED
            CASE BIT_OFFSET IS
             WHEN "000" =>   N_RECD_SER_WORD   <=  ARB_BYTE(7)  & ARB_BYTE(6)  & ARB_BYTE(5)  & ARB_BYTE(4)  & ARB_BYTE(3)  & ARB_BYTE(2) & ARB_BYTE(1) & ARB_BYTE(0);
             WHEN "001" =>   N_RECD_SER_WORD   <=  ARB_BYTE(8)  & ARB_BYTE(7)  & ARB_BYTE(6)  & ARB_BYTE(5)  & ARB_BYTE(4)  & ARB_BYTE(3) & ARB_BYTE(2) & ARB_BYTE(1);
             WHEN "010" =>   N_RECD_SER_WORD   <=  ARB_BYTE(9)  & ARB_BYTE(8)  & ARB_BYTE(7)  & ARB_BYTE(6)  & ARB_BYTE(5)  & ARB_BYTE(4) & ARB_BYTE(3) & ARB_BYTE(2);
             WHEN "011" =>   N_RECD_SER_WORD   <=  ARB_BYTE(10) & ARB_BYTE(9)  & ARB_BYTE(8)  & ARB_BYTE(7)  & ARB_BYTE(6)  & ARB_BYTE(5) & ARB_BYTE(4) & ARB_BYTE(3);
             WHEN "100" =>   N_RECD_SER_WORD   <=  ARB_BYTE(11) & ARB_BYTE(10) & ARB_BYTE(9)  & ARB_BYTE(8)  & ARB_BYTE(7)  & ARB_BYTE(6) & ARB_BYTE(5) & ARB_BYTE(4);
             WHEN "101" =>   N_RECD_SER_WORD   <=  ARB_BYTE(12) & ARB_BYTE(11) & ARB_BYTE(10) & ARB_BYTE(9)  & ARB_BYTE(8)  & ARB_BYTE(7) & ARB_BYTE(6) & ARB_BYTE(5);
             WHEN "110" =>   N_RECD_SER_WORD   <=  ARB_BYTE(13) & ARB_BYTE(12) & ARB_BYTE(11) & ARB_BYTE(10) & ARB_BYTE(9)  & ARB_BYTE(8) & ARB_BYTE(7) & ARB_BYTE(6);
             WHEN "111" =>   N_RECD_SER_WORD   <=  ARB_BYTE(14) & ARB_BYTE(13) & ARB_BYTE(12) & ARB_BYTE(11) & ARB_BYTE(10) & ARB_BYTE(9) & ARB_BYTE(8) & ARB_BYTE(7);
             WHEN OTHERS =>   N_RECD_SER_WORD   <=  ARB_BYTE(7)  & ARB_BYTE(6)  & ARB_BYTE(5)  & ARB_BYTE(4)  & ARB_BYTE(3)  & ARB_BYTE(2) & ARB_BYTE(1) & ARB_BYTE(0);
            END CASE;
    END PROCESS DESERIALIZE;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ASSIGN INTERNAL SIGNALS TO EXTERNAL PORTS

P_RECD_SER_WORD     <=  RECD_SER_WORD;

end RTL;
