--------------------------------------------------------------------------------
-- Company: UNIVERSITY OF MARYLAND
--
-- File: REF_CLK_DIV_GEN.vhd
-- File history:
--      
--
-- Description: 
--  THIS MODULE DIVIDES THE 200 MHZ INPUT TO PRODUCE A 40 MHZ REFERENCE CLOCK WITH A 40/60 DUTY CYCLE (IE 10 NS HIGH/15 NS LOW) TO BE
--  USED AS THE REFERENCE INPUT TO THE CCC1 MODULE WHICH PRODUCES A CLEAN 50/50 DUTY CYCLE VERSION.
-- 
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


entity REF_CLK_DIV_GEN is
port (
        CLK_200MHZ          :   IN  STD_LOGIC;                  -- 200 MHZ OSCILLATOR SOURCE
        POR_N               :   IN  STD_LOGIC;                  -- ACTIVE LOW POWER-ON RESET
        CLK40M_10NS_REF     :   OUT STD_LOGIC                   -- 40 MHZ WITH 40/60 DUTY CYCLE (IE 0 NS PW) DERIVED FROM 200 MHZ
    );
end REF_CLK_DIV_GEN;

architecture RTL of REF_CLK_DIV_GEN is

    SIGNAL  GEN_40M_REFCNT, N_GEN_40M_REFCNT        :   INTEGER RANGE 0 TO 4;
    SIGNAL  GEN_40M_REF, N_GEN_40M_REF              :   STD_LOGIC;


begin

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- THESE TWO PROCESSES GENERATE A DIVIDE-BY-5 OF THE 200 MHZ SOURCE CLOCK, BUT WITH A DUTY CYCLE OF 40/60
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
REG:PROCESS(CLK_200MHZ, POR_N)
        BEGIN

            IF POR_N = '0' THEN
                GEN_40M_REFCNT      <=   0;
                GEN_40M_REF         <=  '0';

            ELSIF (CLK_200MHZ = '1' AND CLK_200MHZ 'EVENT)   THEN
                GEN_40M_REFCNT      <=  N_GEN_40M_REFCNT;
                GEN_40M_REF         <=  N_GEN_40M_REF;

            END IF;
        END PROCESS REG;

CNT_LOGIC:PROCESS(GEN_40M_REFCNT)
        BEGIN
            
            IF GEN_40M_REFCNT = 4 THEN
                N_GEN_40M_REFCNT    <=  0;
            ELSE
                N_GEN_40M_REFCNT    <=  GEN_40M_REFCNT + 1;
            END IF;

            IF GEN_40M_REFCNT = 0 OR GEN_40M_REFCNT = 1 THEN
                N_GEN_40M_REF       <=  '1';
            ELSE
                N_GEN_40M_REF       <=  '0';
            END IF;

        END PROCESS CNT_LOGIC;
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CLK40M_10NS_REF     <=  GEN_40M_REF;

end RTL;
