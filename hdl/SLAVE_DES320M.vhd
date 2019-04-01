--------------------------------------------------------------------------------
-- Company: University of Maryland
--
-- File: SLAVE_DES320M.vhd
-- File history:
--      DEC 8, 2015, Rev A
--
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


entity SLAVE_DES320M is
port (
        DDR_160M_CLK        :   IN  STD_LOGIC;                              -- PHASE ADJUSTABLE 160 MHZ DDR CLOCK
        CLK40M_GEN          :   IN  STD_LOGIC;                              -- 40 MHZ CLOCK WHERE RISE EDGE IS ALIGNED WITH 160 MHZ RISE EDGE
        RESET_B             :   IN  STD_LOGIC;                              -- ACTIVE LOW RESET    

        BIT_OFFSET          :   IN  STD_LOGIC_VECTOR(7 DOWNTO 0);           -- BIT OFFSET DETERMINED BY THE MASTER_SER320m MODULE

        SER_IN_R            :   IN  STD_LOGIC;                              -- SERIAL DATA IN-->RISE EDGE
        SER_IN_F            :   IN  STD_LOGIC;                              -- SERIAL DATA IN-->FALL EDGE

        DDR_Q0_RISE         :   OUT STD_LOGIC;                              -- TEST PORT VALUE OF THE REC'D DDR BIT STREAM (RISE)
        DDR_Q1_FALL         :   OUT STD_LOGIC;                              -- TEST PORT VALUE OF THE REC'D DDR BIT STREAM (FALL)

        P_RECD_SER_WORD     :   OUT STD_LOGIC_VECTOR(7 DOWNTO 0)            -- 8 BIT SERIAL OUTPUT WORD
    );
end SLAVE_DES320M;

architecture RTL of SLAVE_DES320M is

-- DEFINE SIGNALS THAT OPERATE FROM THE 40 MHZ CLOCK
    SIGNAL ARB_BYTE_40M_0DEL                    :   STD_LOGIC_VECTOR(14 DOWNTO 0);          -- REC'D BITS SYNC'D TO CCC1 CLK40MHZ (1ST SAMPLE)
    SIGNAL ARB_BYTE_40M_1DEL                    :   STD_LOGIC_VECTOR(14 DOWNTO 0);          -- REC'D BITS SYNC'D TO CCC1 CLK40MHZ (2ND SAMPLE)
    SIGNAL ARB_BYTE_40M_2DEL                    :   STD_LOGIC_VECTOR(14 DOWNTO 0);          -- REC'D BITS SYNC'D TO CCC1 CLK40MHZ (3RD SAMPLE)
    SIGNAL ARB_BYTE                             :   STD_LOGIC_VECTOR(14 DOWNTO 0);          -- REC'D BITS SYNC'D TO CLK40MHZ
    SIGNAL N_RECD_SER_WORD, RECD_SER_WORD       :   STD_LOGIC_VECTOR(7 DOWNTO 0);           -- THIS IS THE SERIAL WORD WITH ALIGNMENT FOR BIT AND CLOCK PHASE APPLIED

-- DEFINE SIGNALS THAT OPERATE FROM THE 160 MHZ CLOCK.  SUFFIX 'R' OR 'F' DEFINES WHICH EDGE
    SIGNAL  SER_IN_R_0DEL                       :   STD_LOGIC;                              -- SAMPLE OF THE DDR RISE BIT (1ST SAMPLE)
    SIGNAL  SER_IN_F_0DEL                       :   STD_LOGIC;                              -- SAMPLE OF THE DDR FALL BIT (1ST SAMPLE)

    SIGNAL  SER_IN_R_1DEL                       :   STD_LOGIC;                              -- SAMPLE OF THE DDR RISE BIT (2ND SAMPLE)
    SIGNAL  SER_IN_F_1DEL                       :   STD_LOGIC;                              -- SAMPLE OF THE DDR FALL BIT (2ND SAMPLE)

    SIGNAL Q                                    :   STD_LOGIC_VECTOR(15 DOWNTO 0);          -- SHIFT REGISTER USED TO SHIFT IN THE DDR BITS 

begin
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- DEFINE ALL THE REGISTERS THAT OPERATE AT 160 MHZ !!!RISE!!! EDGE
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    REG160M_R:PROCESS(DDR_160M_CLK, RESET_B)
        BEGIN

            IF RESET_B = '0' THEN
                Q               <=  (OTHERS => '0');

                SER_IN_R_0DEL   <=  '0';
                SER_IN_F_0DEL   <=  '0';

                SER_IN_R_1DEL   <=  '0';
                SER_IN_F_1DEL   <=  '0';

            ELSIF (DDR_160M_CLK'EVENT AND DDR_160M_CLK='1') THEN                -- DDR 'FALL' DATA IS ALWAYS 'OLDER' THAN THE 'RISE' DATA!

                SER_IN_R_0DEL   <=  SER_IN_R;                                   -- SHIFT IN THE ARBITRARILY ASSIGNED 'EVEN' BITS
                SER_IN_F_0DEL   <=  SER_IN_F;                                   -- SHIFT IN THE ARBITRARILY ASSIGNED 'ODD' BITS

                SER_IN_R_1DEL   <=  SER_IN_R_0DEL;                              -- 2ND SAMPLES TO ADDRESS CLOCK PHASE ADJ INDUCED SETUP/HOLD VIOLATIONS
                SER_IN_F_1DEL   <=  SER_IN_F_0DEL;                              -- "

                Q(0)            <=  SER_IN_R_1DEL;                              -- SHIFT IN THE ARBITRARILY ASSIGNED 'EVEN' BITS
                Q(1)            <=  SER_IN_F_1DEL;                              -- SHIFT IN THE ARBITRARILY ASSIGNED 'ODD' BITS
                Q(2)            <=  Q(0);
                Q(3)            <=  Q(1);

                Q(4)            <=  Q(2);
                Q(5)            <=  Q(3);
                Q(6)            <=  Q(4);
                Q(7)            <=  Q(5);

                Q(8)            <=  Q(6);
                Q(9)            <=  Q(7);
                Q(10)           <=  Q(8);
                Q(11)           <=  Q(9);

                Q(12)           <=  Q(10);
                Q(13)           <=  Q(11);
                Q(14)           <=  Q(12);
                Q(15)           <=  Q(13);

            END IF;

        END PROCESS REG160M_R;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- DEFINE ALL THE SERIAL DATA REGISTERS THAT OPERATE AT THE 40 MHZ CLOCK RATE
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    AUX40M:PROCESS(CLK40M_GEN, RESET_B)
        BEGIN

            IF RESET_B = '0' THEN
                ARB_BYTE_40M_0DEL   <=  (OTHERS => '0');           
                ARB_BYTE_40M_1DEL   <=  (OTHERS => '0');           
                ARB_BYTE_40M_2DEL   <=  (OTHERS => '0');           
            
            ELSIF (CLK40M_GEN'EVENT AND CLK40M_GEN='1') THEN                                          -- SYNC THE BITS TO THE 40 MHZ 
                ARB_BYTE_40M_0DEL   <=          Q(14) & Q(13) & Q(12) & Q(11) & Q(10) & Q(9) & Q(8) &
                                        Q(7)  & Q(6)  & Q(5)  & Q(4)  & Q(3)  & Q(2)  & Q(1) & Q(0); 

                ARB_BYTE_40M_1DEL   <=  ARB_BYTE_40M_0DEL;
                ARB_BYTE_40M_2DEL   <=  ARB_BYTE_40M_1DEL;

            END IF;

        END PROCESS AUX40M;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- DEFINE ALL THE OTHER REGISTERS THAT OPERATE AT THE MAIN 40 MHZ
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    REG40M:PROCESS(CLK40M_GEN, RESET_B)                                         -- 40 MHZ RISE EDGE IS ALIGNED TO THE DDR CLK 160 MHZ FALL EDGE
        BEGIN

            IF RESET_B = '0' THEN
                ARB_BYTE            <=  (OTHERS => '0');           
                RECD_SER_WORD       <=  (OTHERS => '0');
            
            ELSIF (CLK40M_GEN'EVENT AND CLK40M_GEN='1') THEN
                ARB_BYTE            <=  ARB_BYTE_40M_2DEL;              
                RECD_SER_WORD       <=  N_RECD_SER_WORD;

            END IF;

        END PROCESS REG40M;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- DESERIALIZER
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    DESERIALIZE:PROCESS(BIT_OFFSET)
        BEGIN

            -- CREATE THE COMMANDED SERIAL BYTE WITH BIT ALIGNMENT SHIFT APPLIED
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
DDR_Q0_RISE         <=  Q(0);
DDR_Q1_FALL         <=  Q(1);

end RTL;
