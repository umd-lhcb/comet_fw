--------------------------------------------------------------------------------
-- Company: University of Maryland
--
-- File: CLK_BNDRY_X.vhd
-- File history:
--      Rev INIT
--      Rev A:  Fixed the assignment for when ARB_WRD_A case is correct sampled result of the clock crossing. (Feb 2, 2016)
--      REV B:  CHANGED VOTE METHOD.  NOW SAMPLE THE ADJ40MHZ BY THE FIXED AND LOOK FOR THE FIRST LOW SAMPLE OF THE ADJ40MHZ TO MOVE DATA ACROSS THE CLOCK BOUNDARY.

-- Description: PERFORMS A CLOCK BOUNDRY CROSSING FROM THE DYNAMIC CLK40MHZ_ADJ TO THE FIXED CLK40M_GEN.  IT ESSENTIALLY TAKES 4 SEQUENTIAL DATA SAMPLES WITHIN THE
--              CLK40M_GEN CLOCK CYCLE AND OUTPUTS THE FIRST 2 SEQUENTIAL SAMPLES THAT AGREE IN VALUE
-- 
--
-- Targeted device: <Family::ProASIC3E> <Die::A3PE1500> <Package::208 PQFP>
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

entity CLK_BNDRY_X is
port (
        CLK40M_GEN          :   IN  STD_LOGIC;                              -- 40 MHZ CLOCK WHERE RISE EDGE IS DELAYED ~2.5NS FROM THE 160 MHZ RISE EDGE
        RESET_B             :   IN  STD_LOGIC;                              -- ACTIVE LOW RESET    
        CLK_PH1_160MHZ      :   IN  STD_LOGIC;                              -- 160 MHZ FIXED PHASE CLOCK
        DDR_40M_CLK         :   IN  STD_LOGIC;                              -- ADJ 40 MHZ CLOCK USED TO CORSS THE BYTE CLOCK BOUNDARY
        ARB_WORD_40M_ADJ    :   IN  STD_LOGIC_VECTOR(14 DOWNTO 0);          -- ARBITRARY RX SERIAL WORD ASSIGNMENT SYNCHRONOUS TO THE CLK_40M_ADJ DYNAMIC PHASE CLOCK 
        P_ARB_WRD_40M_FIXED :   OUT STD_LOGIC_VECTOR(14 DOWNTO 0)           -- ARBITRARY RX SERIAL WORD ASSIGNMENT NOW SYNCHRONOUS TO THE CLK40M_GEN FIXED PHASE CLOCK 
     );

end CLK_BNDRY_X;

architecture RTL of CLK_BNDRY_X is

        SIGNAL  CLK40M_GEN_PH_A     :   STD_LOGIC;                          -- PHASE 'A' OF CLK40M_GEN CREATED USING CLK_PH1_160MHZ
        SIGNAL  CLK40M_GEN_PH_B     :   STD_LOGIC;                          -- PHASE 'B' OF CLK40M_GEN CREATED USING CLK_PH1_160MHZ
        SIGNAL  CLK40M_GEN_PH_C     :   STD_LOGIC;                          -- PHASE 'C' OF CLK40M_GEN CREATED USING CLK_PH1_160MHZ
        SIGNAL  CLK40M_GEN_PH_D     :   STD_LOGIC;                          -- PHASE 'D' OF CLK40M_GEN CREATED USING CLK_PH1_160MHZ

        SIGNAL  DDR_40M_CLK_A       :   STD_LOGIC;                          -- SAMPLE OUTPUT OF DDR_40M_CLK USING CLK40M_GEN_PH_A
        SIGNAL  DDR_40M_CLK_B       :   STD_LOGIC;                          -- SAMPLE OUTPUT OF DDR_40M_CLK USING CLK40M_GEN_PH_B
        SIGNAL  DDR_40M_CLK_C       :   STD_LOGIC;                          -- SAMPLE OUTPUT OF DDR_40M_CLK USING CLK40M_GEN_PH_C
        SIGNAL  DDR_40M_CLK_D       :   STD_LOGIC;                          -- SAMPLE OUTPUT OF DDR_40M_CLK USING CLK40M_GEN_PH_D

        SIGNAL  ARB_WRD_A           :   STD_LOGIC_VECTOR(14 DOWNTO 0);     -- SAMPLED VERSION OF ARB_WORD_40M_ADJ USING CLK40M_GEN_PH_A
        SIGNAL  ARB_WRD_B           :   STD_LOGIC_VECTOR(14 DOWNTO 0);     -- SAMPLED VERSION OF ARB_WORD_40M_ADJ USING CLK40M_GEN_PH_B
        SIGNAL  ARB_WRD_C           :   STD_LOGIC_VECTOR(14 DOWNTO 0);     -- SAMPLED VERSION OF ARB_WORD_40M_ADJ USING CLK40M_GEN_PH_C
        SIGNAL  ARB_WRD_D           :   STD_LOGIC_VECTOR(14 DOWNTO 0);     -- SAMPLED VERSION OF ARB_WORD_40M_ADJ USING CLK40M_GEN_PH_D

        SIGNAL  ARB_WRD_40M_FIXED   :   STD_LOGIC_VECTOR(14 DOWNTO 0);     -- ARBITRARY RX SERIAL WORD ASSIGNMENT NOW SYNCHRONOUS TO THE CLK40M_GEN FIXED PHASE CLOCK 
        SIGNAL  N_ARB_WRD_40M_FIXED :   STD_LOGIC_VECTOR(14 DOWNTO 0);     -- ARBITRARY RX SERIAL WORD ASSIGNMENT NOW SYNCHRONOUS TO THE CLK40M_GEN FIXED PHASE CLOCK 


begin

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- GENERATE 4 DELAY PHASE-RELATED COPIES OF THE FIXED CLK40M_GEN

    REG_160M:PROCESS(RESET_B, CLK_PH1_160MHZ)

        BEGIN

            IF RESET_B = '0' THEN  
                CLK40M_GEN_PH_A     <=  '0';
                CLK40M_GEN_PH_B     <=  '0';
                CLK40M_GEN_PH_C     <=  '0';
                CLK40M_GEN_PH_D     <=  '0';
 
            ELSIF ( CLK_PH1_160MHZ 'EVENT AND CLK_PH1_160MHZ = '1' ) THEN
                CLK40M_GEN_PH_A     <=  CLK40M_GEN;
                CLK40M_GEN_PH_B     <=  CLK40M_GEN_PH_A;
                CLK40M_GEN_PH_C     <=  CLK40M_GEN_PH_B;
                CLK40M_GEN_PH_D     <=  CLK40M_GEN_PH_C;

            END IF;

        END PROCESS REG_160M;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- SAMPLE THE ARB_WORD_40M_ADJ USING THE 'A' PHASE OF THE FIXED CLK40M_GEN
    REG_40M_PHA:PROCESS(RESET_B, CLK40M_GEN_PH_A)
        BEGIN
            IF RESET_B='0' THEN  
                ARB_WRD_A       <=  (OTHERS => '0');
                DDR_40M_CLK_A   <=  '1';
            ELSIF (CLK40M_GEN_PH_A 'EVENT AND CLK40M_GEN_PH_A = '1' ) THEN
                ARB_WRD_A       <=  ARB_WORD_40M_ADJ;
                DDR_40M_CLK_A   <=  DDR_40M_CLK;
            END IF;
        END PROCESS REG_40M_PHA;
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- SAMPLE THE ARB_WORD_40M_ADJ USING THE 'B' PHASE OF THE FIXED CLK40M_GEN
    REG_40M_PHB:PROCESS(RESET_B, CLK40M_GEN_PH_B)
        BEGIN
            IF RESET_B='0' THEN  
                ARB_WRD_B       <=  (OTHERS => '0');
                DDR_40M_CLK_B   <=  '1';
            ELSIF (CLK40M_GEN_PH_B 'EVENT AND CLK40M_GEN_PH_B = '1' ) THEN
                ARB_WRD_B       <=  ARB_WORD_40M_ADJ;
                DDR_40M_CLK_B   <=  DDR_40M_CLK;
            END IF;
        END PROCESS REG_40M_PHB;
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- SAMPLE THE ARB_WORD_40M_ADJ USING THE 'C' PHASE OF THE FIXED CLK40M_GEN
    REG_40M_PHC:PROCESS(RESET_B, CLK40M_GEN_PH_C)
        BEGIN
            IF RESET_B='0' THEN  
                ARB_WRD_C       <=  (OTHERS => '0');
                DDR_40M_CLK_C   <=  '1';
            ELSIF (CLK40M_GEN_PH_C 'EVENT AND CLK40M_GEN_PH_C = '1' ) THEN
                ARB_WRD_C       <=  ARB_WORD_40M_ADJ;
                DDR_40M_CLK_C   <=  DDR_40M_CLK;
            END IF;
        END PROCESS REG_40M_PHC;
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- SAMPLE THE ARB_WORD_40M_ADJ USING THE 'D' PHASE OF THE FIXED CLK40M_GEN
    REG_40M_PHD:PROCESS(RESET_B, CLK40M_GEN_PH_D)
        BEGIN
            IF RESET_B='0' THEN  
                ARB_WRD_D       <=  (OTHERS => '0');
                DDR_40M_CLK_D   <=  '1';
            ELSIF (CLK40M_GEN_PH_D 'EVENT AND CLK40M_GEN_PH_D = '1' ) THEN
                ARB_WRD_D       <=  ARB_WORD_40M_ADJ;
                DDR_40M_CLK_D   <=  DDR_40M_CLK;
            END IF;
        END PROCESS REG_40M_PHD;
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- DEFINE REGISTERS FOR THE PROCESS OPERATING FROM CLK40M_GEN
    REG_40M:PROCESS(RESET_B, CLK40M_GEN)
        BEGIN
            IF RESET_B='0' THEN
                ARB_WRD_40M_FIXED   <=  ( OTHERS => '0' );

            ELSIF (CLK40M_GEN 'EVENT AND CLK40M_GEN = '1') THEN
                ARB_WRD_40M_FIXED   <=  N_ARB_WRD_40M_FIXED;
            END IF;
        END PROCESS REG_40M;
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- SAMPLE THE ADJ DDR_40M_CLK AND LOOK FOR THE 1ST LOW VALUE TO DETERMINE WHICH CLOCK PHASE TO USE FOR CROSSING THE CLOCK BOUNDARY

    SEL_SAMPLE:PROCESS( DDR_40M_CLK_A, DDR_40M_CLK_B, DDR_40M_CLK_C, DDR_40M_CLK_D, ARB_WRD_A, ARB_WRD_B, ARB_WRD_C, ARB_WRD_D)
        BEGIN

            IF      DDR_40M_CLK_A = '1' AND DDR_40M_CLK_B = '0'    THEN
                        N_ARB_WRD_40M_FIXED     <=  ARB_WRD_B;

            ELSIF   DDR_40M_CLK_B = '1' AND DDR_40M_CLK_C = '0'    THEN
                        N_ARB_WRD_40M_FIXED     <=  ARB_WRD_C;

            ELSIF   DDR_40M_CLK_C = '1' AND DDR_40M_CLK_D = '0'    THEN
                        N_ARB_WRD_40M_FIXED     <=  ARB_WRD_D;

            ELSE                                                    -- MUST BE THE 'D' AND 'A' CASE
                        N_ARB_WRD_40M_FIXED     <=  ARB_WRD_A;

            END IF;
    END PROCESS SEL_SAMPLE;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ASSIGN INTERNAL SIGNALS TO EXTERNAL PORTS

P_ARB_WRD_40M_FIXED     <=  ARB_WRD_40M_FIXED;

end RTL;

