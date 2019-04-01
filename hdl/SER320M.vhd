--------------------------------------------------------------------------------
-- Company: University of Maryland
--
-- File: SER320M.vhd
-- File history:
--      Rev B,  CHANGED TO A DDR CONFIGURATION
--      Rev C,  UPDATED THE DDR CONFIGURATION SO THAT ONLY THE RISE EDGE OF THE CLOCK IS USED---THE DDR OUTPUT MODULE TAKES CARE OF MULTIPLEXING RISE AND FALL EDGES.

-- Description: Basic SERIALIZER operation.  Command word IS SENT IN AT RATE = SER_CLK / 8.
--              THERE IS ESSENTIALLY A ONE BYTE BUFFER

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


entity SER320M is
port (
        DDR_160M_CLK        :   IN  STD_LOGIC;                              -- 160 MHZ DDR CLOCK-ONLY USING THE RISE EDGE AS A TIMING REFERENCE HERE!
        CLK40M_GEN          :   IN  STD_LOGIC;                              -- 40 MHZ CLOCK WHERE RISE EDGE IS ALIGNED WITH 160 MHZ FALL EDGE
                                                                            -- THIS CLOCK IS USED TO RESYNC THE 160 MHZ DDR TO THE REST OF THE 40 MHZ CLOCK OPERATIONS!
        RESET_B             :   IN  STD_LOGIC;                              -- ACTIVE LOW RESET    
        NEXT_SER_CMD_WORD   :   IN  STD_LOGIC_VECTOR(7 DOWNTO 0);           -- 8 BIT COMMAND INPUT WORD
        SERIAL_TX_EN        :   IN  STD_LOGIC;                              -- ENABLE FOR THE SERIAL TX

        SER_OUT_R           :   OUT STD_LOGIC;                              -- SERIALIZED COMMAND 160MHZ RISE CLOCK DATA
        SER_OUT_F           :   OUT STD_LOGIC                               -- SERIALIZED COMMAND 160MHZ FALL CLOCK DATA
     );
end SER320M;

--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
architecture RTL_LOGIC of SER320M is

-- NEED TO PRESERVE THE INDIVIDUAL REGISTERS DEFINED IN EACH INSTANTIATION TO PREVENT SHARING OF RESOURCES (IMPROVES TIMING IN PLACE/ROUTE)
ATTRIBUTE SYN_PRESERVE : BOOLEAN;
ATTRIBUTE SYN_PRESERVE OF RTL_LOGIC:  ARCHITECTURE IS TRUE;   

    SIGNAL  CLK40M_GEN_DEL0                     :   STD_LOGIC;                          -- 1 CLK CYCLE DELAYED VERSION SYNCED TO THE 160 MHZ CLOCK RISE EDGE
    SIGNAL  CLK40M_GEN_DD                       :   STD_LOGIC;                          -- SIM "DELTA DELAY" VERSION OF CLK40M_GEN_TO PERMIT PROPER EVAL FROM EVENT-DRIVEN SIM

    SIGNAL  SER_OUT_RI, N_SER_OUT_RI            :   STD_LOGIC;                          -- INTERNAL SER_OUT_R RISE EDGE DATA
    SIGNAL  SER_OUT_RDEL, N_SER_OUT_RDEL        :   STD_LOGIC;                          -- DELAYED INTERNAL SER_OUT_R RISE EDGE DATA

    SIGNAL  SER_OUT_FI, N_SER_OUT_FI            :   STD_LOGIC;                          -- INTERNAL SER_OUT_F FALL EDGE DATA
    SIGNAL  SER_OUT_FDEL, N_SER_OUT_FDEL        :   STD_LOGIC;                          -- DELAYED INTERNAL SER_OUT_R FALL EDGE DATA

    SIGNAL  START_RISE, N_START_RISE            :   STD_LOGIC;                          -- PULSE THAT SYNCHRONOUSLY STARTS THE RISING EDGE SHIFT REG RELATIVE TO THE RISE EDGE OF 40 MHZ

    SIGNAL  SER_CMD_WORD_R, N_SER_CMD_WORD_R    :   STD_LOGIC_VECTOR(3 DOWNTO 0);       -- THIS IS THE CURRENT ACTIVE COMMAND WORD VALUE FOR RISE EDGE DATA PATH
    SIGNAL  SER_CMD_WORD_F, N_SER_CMD_WORD_F    :   STD_LOGIC_VECTOR(3 DOWNTO 0);       -- THIS IS THE CURRENT ACTIVE COMMAND WORD VALUE FOR FALL EDGE DATA PATH
    
begin

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
-- DEFINE ALL REGISTERS HERE
------------------------------------------------------------------------------------------------------------------------

CLK40M_GEN_DD   <=  CLK40M_GEN;                                     -- SIM "DELTA DELAY" VERSION TO PERMIT PROPER EVAL FROM EVENT-DRIVEN SIM

REG_RISE:PROCESS(DDR_160M_CLK, RESET_B)                             -- RISE EDGE CLOCKED REGISTERS
BEGIN
    IF ( RESET_B  = '0' )                               THEN

        SER_OUT_RI          <=  '0';                                -- RISE EDGE SIGNALS
        SER_OUT_RDEL        <=  '0';
        SER_CMD_WORD_R      <=  (OTHERS => '0');
        CLK40M_GEN_DEL0     <=  '0';
        START_RISE          <=  '0';

        SER_OUT_FI          <=  '0';                                -- FALL EDGE SIGNALS
        SER_OUT_FDEL        <=  '0';
        SER_CMD_WORD_F      <=  (OTHERS => '0');
                                                                    
    ELSIF (DDR_160M_CLK'EVENT AND DDR_160M_CLK = '1')   THEN      
        
        SER_OUT_RI          <=  N_SER_OUT_RI;                       -- RISE EDGE SIGNALS
        SER_OUT_RDEL        <=  N_SER_OUT_RDEL; 
        SER_CMD_WORD_R      <=  N_SER_CMD_WORD_R;
        CLK40M_GEN_DEL0     <=  CLK40M_GEN_DD;                      -- WAS: CLK40M_GEN; 
        START_RISE          <=  N_START_RISE;

        SER_OUT_FI          <=  N_SER_OUT_FI;                       -- FALL EDGE SIGNALS
        SER_OUT_FDEL        <=  N_SER_OUT_FDEL;
        SER_CMD_WORD_F      <=  N_SER_CMD_WORD_F;
        
    END IF;

END PROCESS REG_RISE;

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
-- SERIALIZE THE SER COMMAND SEQUENCES AS A DDR STREAM (IE RISE AND FALL EDGE DATA STREAMS, BUT BOTH OPERATING FROM THE RISE EDGE FO THE CLOCK)
-- NOTE:  THE SIGNAL, SERIAL_TX_EN, IS GATED WITH THE SERIAL INPUT DATA WORD TO ALLOW SYNCHRONOUS TX START/STOP (IE SEND OUT 0'S WHEN DISABLED)
------------------------------------------------------------------------------------------------------------------------
SERSER:PROCESS( SER_CMD_WORD_R, SER_OUT_RI,
                SER_CMD_WORD_F, SER_OUT_FI,
                NEXT_SER_CMD_WORD, SERIAL_TX_EN,
                CLK40M_GEN, CLK40M_GEN_DEL0, START_RISE )

BEGIN

    N_START_RISE        <=  CLK40M_GEN AND CLK40M_GEN_DEL0;                     -- 40 MHZ CLOCK DELAYED BY 2.5NS RELATIVE TO 160 MHZ RISE EDGE


    IF START_RISE = '1' THEN                                                    -- RISE EDGE OF 40MHZ SIGNIFIES MSB TO BE TRANSMITTED FIRST (SAME AS GBTx)
        N_SER_CMD_WORD_F(0) <=  NEXT_SER_CMD_WORD(0) AND SERIAL_TX_EN;          -- UPDATE THE SER TX WORD TO THE NEXT ONE IN THE QUEUE.
        N_SER_CMD_WORD_R(0) <=  NEXT_SER_CMD_WORD(1) AND SERIAL_TX_EN;          -- UPDATE THE SER TX WORD TO THE NEXT ONE IN THE QUEUE.
        N_SER_CMD_WORD_F(1) <=  NEXT_SER_CMD_WORD(2) AND SERIAL_TX_EN;          -- UPDATE THE SER TX WORD TO THE NEXT ONE IN THE QUEUE.
        N_SER_CMD_WORD_R(1) <=  NEXT_SER_CMD_WORD(3) AND SERIAL_TX_EN;          -- UPDATE THE SER TX WORD TO THE NEXT ONE IN THE QUEUE.
        N_SER_CMD_WORD_F(2) <=  NEXT_SER_CMD_WORD(4) AND SERIAL_TX_EN;          -- UPDATE THE SER TX WORD TO THE NEXT ONE IN THE QUEUE.
        N_SER_CMD_WORD_R(2) <=  NEXT_SER_CMD_WORD(5) AND SERIAL_TX_EN;          -- UPDATE THE SER TX WORD TO THE NEXT ONE IN THE QUEUE.
        N_SER_CMD_WORD_F(3) <=  NEXT_SER_CMD_WORD(6) AND SERIAL_TX_EN;          -- UPDATE THE SER TX WORD TO THE NEXT ONE IN THE QUEUE.
        N_SER_CMD_WORD_R(3) <=  NEXT_SER_CMD_WORD(7) AND SERIAL_TX_EN;          -- UPDATE THE SER TX WORD TO THE NEXT ONE IN THE QUEUE.
    ELSE
        N_SER_CMD_WORD_R(3) <=  SER_CMD_WORD_R(2);
        N_SER_CMD_WORD_F(3) <=  SER_CMD_WORD_F(2);
        N_SER_CMD_WORD_R(2) <=  SER_CMD_WORD_R(1);
        N_SER_CMD_WORD_F(2) <=  SER_CMD_WORD_F(1);
        N_SER_CMD_WORD_R(1) <=  SER_CMD_WORD_R(0);
        N_SER_CMD_WORD_F(1) <=  SER_CMD_WORD_F(0);
        N_SER_CMD_WORD_R(0) <=  '0';
        N_SER_CMD_WORD_F(0) <=  '0';
    END IF;

    N_SER_OUT_RI        <=  SER_CMD_WORD_R(3);                                  -- ASSIGN THE SHIFT REG OUTPUT TO A PIPELINE DELAY REGISTER
    N_SER_OUT_RDEL      <=  SER_OUT_RI;                                         -- ADD A SECOND PIPELINE DELAY REGISTER

    N_SER_OUT_FI        <=  SER_CMD_WORD_F(3);                                  -- ASSIGN THE SHIFT REG OUTPUT TO A PIPELINE DELAY REGISTER
    N_SER_OUT_FDEL      <=  SER_OUT_FI;                                         -- ADD A SECOND PIPELINE DELAY REGISTER

END PROCESS SERSER;

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
-- ASSIGN INTERNAL SIGNALS TO EXTERNAL PORTS
SER_OUT_R       <=  SER_OUT_RDEL;
SER_OUT_F       <=  SER_OUT_FDEL;

end RTL_LOGIC;
