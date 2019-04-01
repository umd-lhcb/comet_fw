--------------------------------------------------------------------------------
-- Company: UNIVERSITY OF MARYLAND
--
-- File: CLK60M_TO_40M.vhd
-- File history:
--      REV INITIAL
--
-- Description: 
--
-- THIS MODULE PERFORMS A CLOCK BOUNDARY CROSSING FROM THE 60 MHZ USB DOMAIN TO THE FIXED 40 MHZ USED BY THE PATTERN GENERATORS.
-- IT USES 2 SEQUENCIAL BYTE WIDE REGISTERS, SAMP_ONE AND SAMP_TWO, TO SAMPLE FROM THE 60 MHZ DOMAIN.
-- A DIFFERNCE BETWEEN THE PRESENT 40 MHZ DOMAIN REGISTER VALUE AND SAMP_TWO INITIATES A 4 CLOCK DELAY BEFORE THE REGISTER IS UPDATED.
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

entity CLK60M_TO_40M is
    port (  
            CLK40M_GEN          :   IN  STD_LOGIC;                              -- 40 MHZ CLOCK WHERE RISE EDGE IS DELAYED ~2.5NS FROM THE 160 MHZ RISE EDGE
            MASTER_POR_B        :   IN  STD_LOGIC;                              -- RESET SYNCHRONOUS TO THE 160 MHZ AND 40 MHZ CLOCKS

            BYTE60M_IN          :   IN  STD_LOGIC_VECTOR(7 DOWNTO 0);           -- INPUT BYTE ORIGINATING FROM THE 60 MHZ DOMAIN
            BYTE40M_OUT         :   OUT STD_LOGIC_VECTOR(7 DOWNTO 0)            -- OUTPUT REGISTER BYTE SYNCHRONIZED TO THE 40 MHZ DOMAIN
        );
end CLK60M_TO_40M;

architecture RTL of CLK60M_TO_40M is
    
    SIGNAL SAMP_ONE                         :   STD_LOGIC_VECTOR(7 DOWNTO 0);               -- 1ST SAMPLE OF THE INPUT BYTE USING THE 40 MHZ CLOCK
    SIGNAL SAMP_TWO                         :   STD_LOGIC_VECTOR(7 DOWNTO 0);               -- 2ND SAMPLE OF THE INPUT BYTE USING THE 40 MHZ CLOCK

    SIGNAL LOCAL_REG_VAL, N_LOCAL_REG_VAL   :   STD_LOGIC_VECTOR(7 DOWNTO 0);               -- LOCAL REGISTER STORED VALUE

    SIGNAL DELCNT, N_DELCNT                 :   STD_LOGIC_VECTOR(1 DOWNTO 0);               -- DELAY COUNTER
    
-- DEFINE STATE MACHINE VARIABLE AND STATES
    TYPE STATE_VALS IS (INIT, CHKDEL);
    SIGNAL  SYNC_SM, N_SYNC_SM              :   STATE_VALS;

begin


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- DEFINE ALL REGISTERS OPERATING WITH THE 40 MHZ DOMAIN
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    REG:PROCESS(CLK40M_GEN, MASTER_POR_B)
        BEGIN

            IF (MASTER_POR_B = '0') THEN
                SYNC_SM         <=  INIT;
                DELCNT          <=  (OTHERS => '0');
                LOCAL_REG_VAL   <=  (OTHERS => '0');

                SAMP_ONE        <=  (OTHERS => '0');
                SAMP_TWO        <=  (OTHERS => '0');

            ELSIF (CLK40M_GEN 'EVENT AND CLK40M_GEN='1') THEN
                SYNC_SM         <=  N_SYNC_SM;
                DELCNT          <=  N_DELCNT;
                LOCAL_REG_VAL   <=  N_LOCAL_REG_VAL;

                SAMP_ONE        <=  BYTE60M_IN;
                SAMP_TWO        <=  SAMP_ONE;

            END IF;

    END PROCESS REG;

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- REGISTER SYNCHRONIZATION PROCESS-- UPDATES TO THE NEW VALUE AFTER WAITING A DELAY OF 4 CLOCK PERIODS
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    REG_SYNC:PROCESS(SYNC_SM, SAMP_TWO, LOCAL_REG_VAL, DELCNT)
        BEGIN

        CASE SYNC_SM IS

            WHEN INIT       =>
                IF LOCAL_REG_VAL /=  SAMP_TWO    THEN               -- CHECK TO SEE IF AN UPDATE IS NEEDED
                    N_SYNC_SM       <=  CHKDEL;
                ELSE
                    N_SYNC_SM       <=  INIT;
                END IF;

                N_DELCNT        <=  "00";                           -- INIT THE DELAY COUNT TO 0
                N_LOCAL_REG_VAL <=  LOCAL_REG_VAL;                  -- REMEMBER CURRENT REGISTER VALUE

            WHEN CHKDEL     =>
                IF DELCNT = "11"    THEN
                    N_SYNC_SM       <=  INIT;
                    N_DELCNT        <=  "00";                       -- INIT THE DELAY COUNT TO 0
                    N_LOCAL_REG_VAL <=  SAMP_TWO;
                ELSE
                    N_SYNC_SM       <=  CHKDEL;
                    N_DELCNT        <=  DELCNT + '1';
                    N_LOCAL_REG_VAL <=  LOCAL_REG_VAL;
                END IF;

            END CASE;

        END PROCESS REG_SYNC;

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- ASSIGN LOCAL SIGNALS TO EXTERNAL PORTS
BYTE40M_OUT     <=  LOCAL_REG_VAL;

end architecture RTL;
