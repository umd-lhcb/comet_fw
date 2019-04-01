--------------------------------------------------------------------------------
-- Company: UNIVERSITY OF MARYLAND
--
-- File: SYNC_DAT_SEL.vhd
-- File history:
--     REV - // OCT 20, 2015 // INITIAL VERSION
--
-- Description: THIS MODULE IS A SIMPLE CLOCKED MULTIPLEXER FOR THE SERIAL TX SYNC DATA SOURCE
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

entity SYNC_DAT_SEL is
port (
        CLK40M_GEN          :   IN  STD_LOGIC;                              -- 40 MHZ CLOCK WHERE RISE EDGE IS ALIGNED WITH 160 MHZ FALL EDGE
        RESET_B             :   IN  STD_LOGIC;                              -- ACTIVE LOW RESET    

        ALIGN_MODE_EN       :   IN  STD_LOGIC;                              -- '1' ENABLES THE AUTO BIT AND BYTE ALIGNMENT FUNCTION. PULSED INPUT MUST BE LOW BEFORE ALIGNMENT COMPLETE
        ALIGN_PATT          :   IN  STD_LOGIC_VECTOR(7 DOWNTO 0);           -- PATTERN USED TO DETERMINE ALIGNMENT (EG A5 HEX)

        SER_DAT_IN          :   IN  STD_LOGIC_VECTOR(7 DOWNTO 0);           -- SERIAL DATA BYTE

        P_SERDAT            :   OUT STD_LOGIC_VECTOR(7 DOWNTO 0)            -- SERIAL DATA BYTE FOR TX
);
end SYNC_DAT_SEL;
architecture RTL of SYNC_DAT_SEL is

    SIGNAL N_SERDAT, SERDAT :   STD_LOGIC_VECTOR(7 DOWNTO 0);               -- INTERNAL SERIAL DATA RAGISTER FOR MUX OP

begin

-- DEFINE THE REGISTERS
    REG:PROCESS(RESET_B, CLK40M_GEN)
        BEGIN
            IF RESET_B = '0' THEN
                SERDAT     <=  "00000000";
            ELSIF (CLK40M_GEN'EVENT AND CLK40M_GEN='1') THEN
                SERDAT     <=  N_SERDAT;
            END IF;

        END PROCESS REG;

-- DEFINE THE MUX OPERATION
    MUXDAT:PROCESS(ALIGN_MODE_EN, ALIGN_PATT, SER_DAT_IN)
        BEGIN

            IF ALIGN_MODE_EN = '1' THEN
                N_SERDAT       <=  ALIGN_PATT;
            ELSE
                N_SERDAT       <=  SER_DAT_IN;
            END IF;
        END PROCESS MUXDAT;

-- MAP INTERNAL SIGNALS TO EXTERNAL PORTS
P_SERDAT    <=  SERDAT;

end RTL;
