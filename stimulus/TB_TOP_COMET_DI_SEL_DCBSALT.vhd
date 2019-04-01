----------------------------------------------------------------------
-- Created by Microsemi SmartDesign Wed Sep 16 18:31:49 2015
-- Testbench Template
-- This is a basic testbench that instantiates your design with basic 
-- clock and reset pins connected.  If your design has special
-- clock/reset or testbench driver requirements then you should 
-- copy this file and modify it. 
----------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Company: UNIVERSITY OF MARYLAND
--
-- File: TB_TOP_COMET_DUAL_IMPL.vhd
-- File history:
--				June 2nd, 2016 ADDED 2ND ELINK CHANNEL
-- Description:     THIS TESTBENCH INSTANTIATES THE DCB VARIENT OF COMET SO THE RELATIVE SERDES PERFORMENCE CAN BE EVALUATED.
--                  *TOP_COMET_DUAL_IMPL_0 IS THE MASTER DCB TFC VERSION (TX)
--                  *THE TFC OUTPUT (TX) IS ROUTED TO THE ELINK CHANNEL (RX)

-- WAIT ARGUMENTS
--  WAIT UNTIL 'CONDITION'
--  WAIT FOR 'TIME'
--  WAIT ON 'SIGNAL LIST' (IE SUSPENDS PROCESS SAME AS PROCESS SESNITIVITY LIST)
--
-- Targeted device: <Family::ProASIC3E> <Die::A3PE1500> <Package::208 PQFP>
-- Author: TOM O'BANNON
--
--------------------------------------------------------------------------------
-- NOTE:  THE INTERNAL USB 60 MHZ CLOCK HAS A SLIGHT TIMING LEAD RELATIVE TO THE EXTERNAL INPUT PIN.  THEREFORE, AN ADDITIONAL DELAY COMPENATION OF 3 NS IS USED BELOW
-- TO ACCOMMODATE THIS FEATURE.  THE PHASE LEAD COMPENSATES FOR THE MIN PROP DELAYS OF THE FPGA AS WELL AS THE SIGNAL PROP DELAY FROM THE FPGA TO THE USB MODULE (LINE LENGTHS + RC TIME CONSTANTS)

library ieee;
use ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.STD_LOGIC_MISC.ALL;

library proasic3e;
use proasic3e.all;

entity TB_TOP_COMET_DUAL_IMPL is
end TB_TOP_COMET_DUAL_IMPL;

architecture behavioral of TB_TOP_COMET_DUAL_IMPL is

	CONSTANT	DCB_SALT_SEL		:	STD_LOGIC_ARITH	:= '1';

    signal SYSCLK200MHZ     		:   std_logic   := '0';
    SIGNAL SYSCLK200MHZ_P   		:   STD_LOGIC   :=  '0';
    SIGNAL SYSCLK200MHZ_N   		:   STD_LOGIC   :=  '1';

    SIGNAL SIG_CLK40M_P    			:   STD_LOGIC ;
    SIGNAL SIG_CLK40M_N    			:   STD_LOGIC ;

    SIGNAL SIG_CLK160M_P    		: STD_LOGIC     :=  'Z';
    SIGNAL SIG_CLK160M_N    		: STD_LOGIC     :=  'Z';

--    SIGNAL PLL_RESET_EN     :   STD_LOGIC_VECTOR(0 DOWNTO 0)   :=  "1";
-------------------------------------------------------------------------------------------------
-- THESE ARE FOR TOP_COMET_0 IS THE MASTER DCB TFC VERSION (TX)CONTROL
    constant SYSCLK_PERIOD_60MHZ_0 	: time := 16.6 ns;       -- 59.988MHZ
    constant SYSCLK_PERIOD_200MHZ_0 : time := 5 ns;           -- 200MHZ

    signal SYSCLK60MHZ_0  			: std_logic  := '1';

    SIGNAL SYSCLK60M_EN_0           : STD_LOGIC := '0';
    signal SYSCLK60M_DEL_0          : STD_LOGIC := '0';

    signal NSYSRESET_0 : std_logic := '0';

    SIGNAL BIDIR_USB_ADBUS_0      	: STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL P_USB_RXF_B_0          	: STD_LOGIC := '1';
    SIGNAL USB_RD_B_0             	: STD_LOGIC;
    SIGNAL USB_OE_B_0             	: STD_LOGIC;
    SIGNAL P_USB_TXE_B_0          	: STD_LOGIC := '0';
    SIGNAL USB_WR_B_0             	: STD_LOGIC;    
    SIGNAL USB_SIWU_B_0           	: STD_LOGIC;
    SIGNAL RAM_BYTE_0             	: STD_LOGIC_VECTOR (7 DOWNTO 0) := "00000000";

    SIGNAL TFC_P                  	: STD_LOGIC;
    SIGNAL TFC_N                  	: STD_LOGIC;
    SIGNAL TFC_DEL_P              	: STD_LOGIC;
    SIGNAL TFC_DEL_N              	: STD_LOGIC;

    SIGNAL ELK0_P                 	: STD_LOGIC;
    SIGNAL ELK0_N                 	: STD_LOGIC;

    SIGNAL ELK1_P                 	: STD_LOGIC;
    SIGNAL ELK1_N                 	: STD_LOGIC;

    SIGNAL REFCLK_P               	: STD_LOGIC;
    SIGNAL REFCLK_N               	: STD_LOGIC;
    SIGNAL REFCLK_DEL_P           	: STD_LOGIC;
    SIGNAL REFCLK_DEL_N           	: STD_LOGIC;


-------------------------------------------------------------------------------------------------

    component TOP_COMET
        -- ports
        port( 
            -- Inputs
        CLK200_P            :   in std_logic;
        CLK200_N            :   in std_logic;

        DEV_RST_B           :   in std_logic;
        DCB_SALT_SEL        :   IN  STD_LOGIC;                          -- GPIO_0:  '1'= DCB MODE (IE TFC MASTER TX ENABLED) // '0'=SALT HYBRID MODE (IE TFC MASTER RX W/ SYNC MODE ENABLED)

        USBCLK60MHZ         :   in std_logic;
        P_USB_RXF_B         :   in std_logic;
        P_USB_TXE_B         :   in std_logic;
        EXT_INT_REF_SEL     :   IN  STD_LOGIC;                          -- GPIO_9   '1' = CCC USE REC'D REF CLOCKS, '0' BOARD TRANSMITS REF CLOCK SIGNALS

            -- Outputs
        ALL_PLL_LOCK        :   OUT STD_LOGIC;                          -- GPIO_10: COMBINED LOCK STATUS OF CCC #1 AND #2
        P_MASTER_POR_B      :   OUT STD_LOGIC;                          -- GPIO_2:  MASTER_POR_B
        P_USB_MASTER_EN     :   OUT STD_LOGIC;                          -- GPIO_7:  USB_MASTER_EN
        P_CLK_40M_GL        :   OUT STD_LOGIC;                          -- GPIO_4:  40 MHZ MAIN CLOCK
--        P_CLK_PH1_160MHZ    :   OUT STD_LOGIC;                          -- GPIO_8:  CCC#1 FIXED CLOCK OUT
        P_CCC_160M_FXD       :   OUT STD_LOGIC;                          -- GPIO 6
        P_CCC_160M_ADJ      :   OUT STD_LOGIC;                          -- GPIO_5:  CCC#2 ADJ CLOCK

        BIDIR_CLK40M_P     :   INOUT   STD_LOGIC;                      -- 40 MHZ REF CLOCK FOR CCC#1: EITHER LOCAL OSC OR EXTERNAL REC'D DIFF CLOCK SOURCE
        BIDIR_CLK40M_N     :   INOUT   STD_LOGIC;                      -- 40 MHZ REF CLOCK FOR CCC#1: EITHER LOCAL OSC OR EXTERNAL REC'D DIFF CLOCK SOURCE

        USB_OE_B            :   out std_logic;
        USB_RD_B            :   out std_logic;
        USB_WR_B            :   out std_logic;
        USB_SIWU_B          :   out std_logic;

-- STAVE IO VIA DAUGHTER BOARDS AND ERM8 CONNS
-- PORT DIRECTIONS DETERMINED BY DCB_SALT_SEL CONSTANT
        TFC_DAT_0P          :   INOUT STD_LOGIC;                        -- SERIAL LVDS TFC COMMAND BIDIR PORT
        TFC_DAT_0N          :   INOUT STD_LOGIC; 
        REF_CLK_0P          :   INOUT STD_LOGIC;                        -- 40 MHZ REF CLK LVDS BIDIR PORT SYNCHRONOUS TO THE TCF OUTPUT BYTE RATE.  
        REF_CLK_0N          :   INOUT STD_LOGIC;                        -- DCB MODE TRANSMITS THE REFCLK, SALT MODE RECEIVES THE REFCLK

        ELK0_DAT_P         	:   INOUT STD_LOGIC;                        -- SERIAL LVDS ELINK0 DATA BIDIR PORT
        ELK0_DAT_N         	:   INOUT STD_LOGIC;

        ELK1_DAT_P         	:   INOUT STD_LOGIC;                        -- SERIAL LVDS ELINK1 DATA BIDIR PORT
        ELK1_DAT_N         	:   INOUT STD_LOGIC;

        BIDIR_USB_ADBUS     :   inout std_logic_vector(7 downto 0)
 
        );
    end component;

begin
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- GENERATE THE POR
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-------------------------------------------------------------------------------------------------
-- THIS IS FOR TB_TOP_COMET_0 WHICH IS CONFIG'D AS THE MASTER DCB TFC VERSION (TX) CONTROL
    process
        variable vhdl_initial : BOOLEAN := TRUE;

    begin
        if ( vhdl_initial ) then
            -- Assert Reset
            NSYSRESET_0 <= '0';
            wait for ( SYSCLK_PERIOD_60MHZ_0 * 50 );
            
            NSYSRESET_0 <= '1';
            wait;
        end if;
    end process;

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- GENERATE CLOCKS
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    -- Clock DriverS

    SYSCLK60MHZ_0     <= not SYSCLK60MHZ_0 after (SYSCLK_PERIOD_60MHZ_0 / 2.0 );
 
    PROCESS
        BEGIN
            SYSCLK200MHZ_P      <=  '0';
            SYSCLK200MHZ_N      <=  '1';
            WAIT FOR SYSCLK_PERIOD_200MHZ_0 / 2.0;

            SYSCLK200MHZ_P      <=  '1';
            SYSCLK200MHZ_N      <=  '0';
            WAIT FOR SYSCLK_PERIOD_200MHZ_0 / 2.0;

        END PROCESS;


   -- process for THE delayed 60 Mhz clock enableS
    process
        begin
            wait for ( SYSCLK_PERIOD_60MHZ_0 * 100 );
            WAIT FOR 2 NS;
            SYSCLK60M_EN_0    <=  '1';
            wait;
    end process;

    SYSCLK60M_DEL_0   <=  SYSCLK60M_EN_0 AND SYSCLK60MHZ_0;
    
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- STORE ALL REGISTER SEQUENTIAL ORDER
--  1) OP_MODE
--  2) TFC_START_ADDR
--  3) TFC_STOP_ADDR
--  4) ELINKS_START_ADDR
--  5) ELINKS STOP_ADDR
--  6) CHKSUM
--  7) STOP HEADER
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- FOR THE MASTER TFC COMET_0
    PROCESS
        BEGIN
-- INITIALIZE CONDITION OF BUS
            BIDIR_USB_ADBUS_0   <=  "ZZZZZZZZ";                       -- HI-Z 

-- ++++++++
-- (1) COMET_0: WRITE ALL REGISTERS VIA A SET OF CONTINUOUS USB READ TRANSFERS (IE ASSUME HOST CAN KEEP UP)
-- ++++++++
            WAIT FOR SYSCLK_PERIOD_60MHZ_0*6000;                        -- LONG WAIT TO MAKE SURE THE USB CLOCK HAS BEEN DETECTED AND THE USB_INTERFACE.VHD IS ENABLED
            WAIT UNTIL (SYSCLK60M_DEL_0'EVENT AND SYSCLK60M_DEL_0='1');
            WAIT FOR 9 NS;                                              -- USB MODULE DELAY
            P_USB_RXF_B_0       <=  '0';                                -- INITIATE A USB READ TRANSACTION

            WAIT UNTIL USB_OE_B_0='0';                                  -- HALT THE PROCESS UNTIL USB_OE_B_0 IS LOW
            WAIT FOR 9 NS;                                              -- USB MODULE DELAY
            BIDIR_USB_ADBUS_0   <=  "10101010";                         -- THIS IS THE START HEADER WORD

            WAIT UNTIL USB_RD_B_0 = '0';
            WAIT FOR 3 NS;                                              -- COMPENSATION FOR THE INTERNAL CLOCK PHASE LEAD 
            WAIT UNTIL (SYSCLK60M_DEL_0'EVENT AND SYSCLK60M_DEL_0='1');
            WAIT FOR 9 NS;                                              -- USB MODULE DELAY
            BIDIR_USB_ADBUS_0   <=  "00000001";                         -- TRANSFER TYPE = "ALL REGISTER" 

            WAIT UNTIL (SYSCLK60M_DEL_0'EVENT AND SYSCLK60M_DEL_0='1');
            WAIT FOR 9 NS;                                              -- USB MODULE DELAY
            BIDIR_USB_ADBUS_0   <=  "00100011";                         -- OP_MODE=  AUTO ALIGN ON, SYNC PATT GEN ON, REPEAT MODE

            WAIT UNTIL (SYSCLK60M_DEL_0'EVENT AND SYSCLK60M_DEL_0='1');
            WAIT FOR 9 NS;                                              -- USB MODULE DELAY
            BIDIR_USB_ADBUS_0   <=  "00010000";                         -- TFC_START_ADDR

            WAIT UNTIL (SYSCLK60M_DEL_0'EVENT AND SYSCLK60M_DEL_0='1');
            WAIT FOR 9 NS;                                              -- USB MODULE DELAY
            BIDIR_USB_ADBUS_0   <=  "00100000";                         -- TFC_STOP_ADDR

            WAIT UNTIL (SYSCLK60M_DEL_0'EVENT AND SYSCLK60M_DEL_0='1');
            WAIT FOR 9 NS;                                              -- USB MODULE DELAY
            BIDIR_USB_ADBUS_0   <=  "00110000";                         -- ELINKS_START_ADDR

            WAIT UNTIL (SYSCLK60M_DEL_0'EVENT AND SYSCLK60M_DEL_0='1');
            WAIT FOR 9 NS;                                              -- USB MODULE DELAY
            BIDIR_USB_ADBUS_0   <=  "01000000";                         -- ELINKS_STOP_ADDR

            WAIT UNTIL (SYSCLK60M_DEL_0'EVENT AND SYSCLK60M_DEL_0='1');
            WAIT FOR 9 NS;                                              -- USB MODULE DELAY
            BIDIR_USB_ADBUS_0   <=  "11111111";                         -- CHKSUM

            WAIT UNTIL (SYSCLK60M_DEL_0'EVENT AND SYSCLK60M_DEL_0='1');
            WAIT FOR 9 NS;                                              -- USB MODULE DELAY
            BIDIR_USB_ADBUS_0   <=  "01010101";                         -- STOP HEADER

            WAIT FOR 900 NS;                                            -- PC DELAY WHILE IT CONTINUES TO READ THE FIFO....
            WAIT UNTIL (SYSCLK60M_DEL_0'EVENT AND SYSCLK60M_DEL_0='1');
            P_USB_RXF_B_0       <=  '1';                                -- TERMINATE THE USB READ TRANSACTION--USING CONCURRENT ASSIGNMENT HERE!

            WAIT UNTIL USB_OE_B_0='1';                                  -- HALT THE PROCESS UNTIL USB_OE_B_0 IS BACK HIGH
            WAIT FOR 9 NS;                                              -- USB MODULE DELAY
            BIDIR_USB_ADBUS_0   <=  "ZZZZZZZZ";                         -- HI-Z 

-- ++++++++
-- PLACE A GAP OF TIME BETWEEN THESE TWO TYPES OF SIM CONDITONS
            WAIT FOR 10*SYSCLK_PERIOD_60MHZ_0;
            WAIT UNTIL (SYSCLK60M_DEL_0'EVENT AND SYSCLK60M_DEL_0='1');

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- (2) COMET_0: PROGRAM THE TRANSFER TYPE NEEDED FOR THE WRITE DATA RETRIEVAL OP AND THEN FPGA WILL IMMEDIATELY WRITE THE DATA TO THE USB FIFO
--      TRANSFER TYPE = ALL CONTROL REGISTERS

            WAIT FOR SYSCLK_PERIOD_60MHZ_0*20;
            WAIT UNTIL (SYSCLK60M_DEL_0'EVENT AND SYSCLK60M_DEL_0='1');
            WAIT FOR 9 NS;                                              -- USB MODULE DELAY
            P_USB_RXF_B_0       <=  '0';                                -- INITIATE A USB READ TRANSACTION

            WAIT UNTIL USB_OE_B_0='0';                                  -- HALT THE PROCESS UNTIL USB_OE_B_0 IS LOW

            WAIT FOR 9 NS;                                              -- USB MODULE DELAY
            BIDIR_USB_ADBUS_0   <=  "10101010";                         -- THIS IS THE START HEADER WORD

            WAIT UNTIL USB_RD_B_0 = '0';
            WAIT FOR 3 NS;                                              -- COMPENSATION FOR THE INTERNAL CLOCK PHASE LEAD 
            WAIT UNTIL (SYSCLK60M_DEL_0'EVENT AND SYSCLK60M_DEL_0='1');
            WAIT FOR 9 NS;                                              -- USB MODULE DELAY
            BIDIR_USB_ADBUS_0   <=  "10000001";                         -- TRANSFER TYPE = "ALL REGISTER" 

            WAIT FOR 900 NS;                                            -- PC DELAY WHILE IT CONTINUES TO READ THE FIFO....
            WAIT UNTIL (SYSCLK60M_DEL_0'EVENT AND SYSCLK60M_DEL_0='1');
            P_USB_RXF_B_0       <=  '1';                                -- TERMINATE THE USB READ TRANSACTION--USING CONCURRENT ASSIGNMENT HERE!

            WAIT UNTIL USB_OE_B_0='1';                                  -- HALT THE PROCESS UNTIL USB_OE_B_0 IS BACK HIGH
            WAIT FOR 9 NS;                                              -- USB MODULE DELAY
            BIDIR_USB_ADBUS_0   <=  "ZZZZZZZZ";                         -- HI-Z 

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- (3)  COMET_0: STORE A TFC BLOCK --256 WORDS + OVERHEAD BYTES
            WAIT FOR SYSCLK_PERIOD_60MHZ_0*20;
            WAIT UNTIL (SYSCLK60M_DEL_0'EVENT AND SYSCLK60M_DEL_0='1');
            WAIT FOR 9 NS;                                              -- USB MODULE DELAY
            P_USB_RXF_B_0       <=  '0';                                -- INITIATE A USB READ TRANSACTION

            WAIT UNTIL USB_OE_B_0='0';                                  -- HALT THE PROCESS UNTIL USB_OE_B_0 IS LOW

            WAIT FOR 9 NS;                                              -- USB MODULE DELAY
            BIDIR_USB_ADBUS_0   <=  "10101010";                         -- THIS IS THE START HEADER WORD

            WAIT UNTIL USB_RD_B_0 = '0';
            WAIT FOR 3 NS;                                              -- COMPENSATION FOR THE INTERNAL CLOCK PHASE LEAD 
            WAIT UNTIL (SYSCLK60M_DEL_0'EVENT AND SYSCLK60M_DEL_0='1');
            WAIT FOR 9 NS;                                              -- USB MODULE DELAY
            BIDIR_USB_ADBUS_0   <=  "00000010";                         -- TRANSFER TYPE = "TFC BLOCK" 

            RAM_BYTE_0    <=  "00000000";
        FOR I IN 0 TO 255 LOOP
            WAIT UNTIL (SYSCLK60M_DEL_0'EVENT AND SYSCLK60M_DEL_0='1');
            WAIT FOR 9 NS;                                              -- USB MODULE DELAY
            BIDIR_USB_ADBUS_0   <=  RAM_BYTE_0;                         -- TFC_DATA
            RAM_BYTE_0        <=  RAM_BYTE_0 + "1";
        END LOOP;


            WAIT UNTIL (SYSCLK60M_DEL_0'EVENT AND SYSCLK60M_DEL_0='1');
            WAIT FOR 9 NS;                                              -- USB MODULE DELAY
            BIDIR_USB_ADBUS_0   <=  "11100111";                         -- CHKSUM

            WAIT UNTIL (SYSCLK60M_DEL_0'EVENT AND SYSCLK60M_DEL_0='1');
            WAIT FOR 9 NS;                                              -- USB MODULE DELAY
            BIDIR_USB_ADBUS_0   <=  "01010101";                         -- STOP HEADER

            WAIT FOR 900 NS;                                            -- PC DELAY WHILE IT CONTINUES TO READ THE FIFO....
            WAIT UNTIL (SYSCLK60M_DEL_0'EVENT AND SYSCLK60M_DEL_0='1');
            P_USB_RXF_B_0       <=  '1';                                -- TERMINATE THE USB READ TRANSACTION--USING CONCURRENT ASSIGNMENT HERE!

            WAIT UNTIL USB_OE_B_0='1';                                  -- HALT THE PROCESS UNTIL USB_OE_B_0 IS BACK HIGH
            WAIT FOR 9 NS;                                              -- USB MODULE DELAY
            BIDIR_USB_ADBUS_0   <=  "ZZZZZZZZ";                         -- HI-Z 


--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            WAIT FOR 610000 NS;
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- (7) COMET_0: COMMAND THE ALIGNMENT ALG TO COMPLETE, BEFORE SENDING COMMANDS TO TX/RX TFC DATA
-- ++++++++
--      WRITE ALL CONTROL REGISTERS VIA A SET OF CONTINUOUS USB READ TRANSFERS (IE ASSUME HOST CAN KEEP UP)
-- ++++++++
            WAIT FOR SYSCLK_PERIOD_60MHZ_0*800;                         -- LONG WAIT TO MAKE SURE THE SALT VERSION HAS FINISHED THE SYNC AND IS READY FOR DATA
            WAIT UNTIL (SYSCLK60M_DEL_0'EVENT AND SYSCLK60M_DEL_0='1');
            WAIT FOR 9 NS;                                              -- USB MODULE DELAY
            P_USB_RXF_B_0       <=  '0';                                -- INITIATE A USB READ TRANSACTION

            WAIT UNTIL USB_OE_B_0='0';                                  -- HALT THE PROCESS UNTIL USB_OE_B_0 IS LOW
            WAIT FOR 9 NS;                                              -- USB MODULE DELAY
            BIDIR_USB_ADBUS_0   <=  "10101010";                         -- THIS IS THE START HEADER WORD

            WAIT UNTIL USB_RD_B_0 = '0';
            WAIT FOR 3 NS;                                              -- COMPENSATION FOR THE INTERNAL CLOCK PHASE LEAD 
            WAIT UNTIL (SYSCLK60M_DEL_0'EVENT AND SYSCLK60M_DEL_0='1');
            WAIT FOR 9 NS;                                              -- USB MODULE DELAY
            BIDIR_USB_ADBUS_0   <=  "00000001";                         -- TRANSFER TYPE = "ALL REGISTER" 

            WAIT UNTIL (SYSCLK60M_DEL_0'EVENT AND SYSCLK60M_DEL_0='1');
            WAIT FOR 9 NS;                                              -- USB MODULE DELAY
            BIDIR_USB_ADBUS_0   <=  "00000010";                         -- OP_MODE= ELINKS/TFC DIS-ABLED, AUTO ALIGN MODE OFF, SYNC PATT GEN ON, REPEAT MODE OFF!!!!

            WAIT UNTIL (SYSCLK60M_DEL_0'EVENT AND SYSCLK60M_DEL_0='1');
            WAIT FOR 9 NS;                                              -- USB MODULE DELAY
            BIDIR_USB_ADBUS_0   <=  "00000000";                         -- TFC_START_ADDR

            WAIT UNTIL (SYSCLK60M_DEL_0'EVENT AND SYSCLK60M_DEL_0='1');
            WAIT FOR 9 NS;                                              -- USB MODULE DELAY
            BIDIR_USB_ADBUS_0   <=  "11111111";                         -- TFC_STOP_ADDR

            WAIT UNTIL (SYSCLK60M_DEL_0'EVENT AND SYSCLK60M_DEL_0='1');
            WAIT FOR 9 NS;                                              -- USB MODULE DELAY
            BIDIR_USB_ADBUS_0   <=  "00000000";                         -- ELINKS_START_ADDR

            WAIT UNTIL (SYSCLK60M_DEL_0'EVENT AND SYSCLK60M_DEL_0='1');
            WAIT FOR 9 NS;                                              -- USB MODULE DELAY
            BIDIR_USB_ADBUS_0   <=  "11111111";                         -- ELINKS_STOP_ADDR

            WAIT UNTIL (SYSCLK60M_DEL_0'EVENT AND SYSCLK60M_DEL_0='1');
            WAIT FOR 9 NS;                                              -- USB MODULE DELAY
            BIDIR_USB_ADBUS_0   <=  "11111111";                         -- CHKSUM

            WAIT UNTIL (SYSCLK60M_DEL_0'EVENT AND SYSCLK60M_DEL_0='1');
            WAIT FOR 9 NS;                                              -- USB MODULE DELAY
            BIDIR_USB_ADBUS_0   <=  "01010101";                         -- STOP HEADER

            WAIT FOR 900 NS;                                            -- PC DELAY WHILE IT CONTINUES TO READ THE FIFO....
            WAIT UNTIL (SYSCLK60M_DEL_0'EVENT AND SYSCLK60M_DEL_0='1');
            P_USB_RXF_B_0       <=  '1';                                -- TERMINATE THE USB READ TRANSACTION--USING CONCURRENT ASSIGNMENT HERE!

            WAIT UNTIL USB_OE_B_0='1';                                  -- HALT THE PROCESS UNTIL USB_OE_B_0 IS BACK HIGH
            WAIT FOR 9 NS;                                              -- USB MODULE DELAY
            BIDIR_USB_ADBUS_0   <=  "ZZZZZZZZ";                         -- HI-Z            


--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- (8) COMET_0: WAIT FOR 610 USEC FOR THE ALIGNMENT ALG TO COMPLETE, THEN SEND COMMANDS TO TX/RX TFC DATA
--      (THE RX DELAY IS BEING SET TO 610 US SO THE DE-SERIALIZER STARTS RECEIVING STD DATA AS SYNC PATTERN FOLLOWED BY REAL DATA AFTER 210 US)
            WAIT FOR 610000 NS;
-- DO NOTHING ON THE DCB SIDE HERE--EXCEPT KEEP THE TEST BENCH IN TIME SYNC WITH THE SALT SIDE
            WAIT FOR SYSCLK_PERIOD_60MHZ_0*800;                         -- LONG WAIT TO MAKE SURE THE SALT VERSION HAS FINISHED THE SYNC AND IS READY FOR DATA

-- (9)  COMET_0: ENABLE THE DCB FOR TFC DATA TX AND ELINK DATA RX
-- ++++++++
--      WRITE ALL CONTROL REGISTERS VIA A SET OF CONTINUOUS USB READ TRANSFERS (IE ASSUME HOST CAN KEEP UP)
-- ++++++++
            WAIT FOR SYSCLK_PERIOD_60MHZ_0*800;                         -- LONG WAIT TO MAKE SURE THE SALT VERSION HAS FINISHED THE SYNC AND IS READY FOR DATA
            WAIT UNTIL (SYSCLK60M_DEL_0'EVENT AND SYSCLK60M_DEL_0='1');
            WAIT FOR 9 NS;                                              -- USB MODULE DELAY
            P_USB_RXF_B_0       <=  '0';                                -- INITIATE A USB READ TRANSACTION

            WAIT UNTIL USB_OE_B_0='0';                                  -- HALT THE PROCESS UNTIL USB_OE_B_0 IS LOW
            WAIT FOR 9 NS;                                              -- USB MODULE DELAY
            BIDIR_USB_ADBUS_0   <=  "10101010";                         -- THIS IS THE START HEADER WORD

            WAIT UNTIL USB_RD_B_0 = '0';
            WAIT FOR 3 NS;                                              -- COMPENSATION FOR THE INTERNAL CLOCK PHASE LEAD 
            WAIT UNTIL (SYSCLK60M_DEL_0'EVENT AND SYSCLK60M_DEL_0='1');
            WAIT FOR 9 NS;                                              -- USB MODULE DELAY
            BIDIR_USB_ADBUS_0   <=  "00000001";                         -- TRANSFER TYPE = "ALL REGISTER" 

            WAIT UNTIL (SYSCLK60M_DEL_0'EVENT AND SYSCLK60M_DEL_0='1');
            WAIT FOR 9 NS;                                              -- USB MODULE DELAY
            BIDIR_USB_ADBUS_0   <=  "01000100";                         -- OP_MODE= ELINKS/TFC ENABLED, AUTO ALIGN MODE OFF, SYNC PATT GEN OFF, REPEAT MODE OFF!!!!

            WAIT UNTIL (SYSCLK60M_DEL_0'EVENT AND SYSCLK60M_DEL_0='1');
            WAIT FOR 9 NS;                                              -- USB MODULE DELAY
            BIDIR_USB_ADBUS_0   <=  "00000000";                         -- TFC_START_ADDR

            WAIT UNTIL (SYSCLK60M_DEL_0'EVENT AND SYSCLK60M_DEL_0='1');
            WAIT FOR 9 NS;                                              -- USB MODULE DELAY
            BIDIR_USB_ADBUS_0   <=  "11111111";                         -- TFC_STOP_ADDR

            WAIT UNTIL (SYSCLK60M_DEL_0'EVENT AND SYSCLK60M_DEL_0='1');
            WAIT FOR 9 NS;                                              -- USB MODULE DELAY
            BIDIR_USB_ADBUS_0   <=  "00000000";                         -- ELINKS_START_ADDR

            WAIT UNTIL (SYSCLK60M_DEL_0'EVENT AND SYSCLK60M_DEL_0='1');
            WAIT FOR 9 NS;                                              -- USB MODULE DELAY
            BIDIR_USB_ADBUS_0   <=  "11111111";                         -- ELINKS_STOP_ADDR

            WAIT UNTIL (SYSCLK60M_DEL_0'EVENT AND SYSCLK60M_DEL_0='1');
            WAIT FOR 9 NS;                                              -- USB MODULE DELAY
            BIDIR_USB_ADBUS_0   <=  "11111111";                         -- CHKSUM

            WAIT UNTIL (SYSCLK60M_DEL_0'EVENT AND SYSCLK60M_DEL_0='1');
            WAIT FOR 9 NS;                                              -- USB MODULE DELAY
            BIDIR_USB_ADBUS_0   <=  "01010101";                         -- STOP HEADER

            WAIT FOR 900 NS;                                            -- PC DELAY WHILE IT CONTINUES TO READ THE FIFO....
            WAIT UNTIL (SYSCLK60M_DEL_0'EVENT AND SYSCLK60M_DEL_0='1');
            P_USB_RXF_B_0       <=  '1';                                -- TERMINATE THE USB READ TRANSACTION--USING CONCURRENT ASSIGNMENT HERE!

            WAIT UNTIL USB_OE_B_0='1';                                  -- HALT THE PROCESS UNTIL USB_OE_B_0 IS BACK HIGH
            WAIT FOR 9 NS;                                              -- USB MODULE DELAY
            BIDIR_USB_ADBUS_0   <=  "ZZZZZZZZ";                         -- HI-Z            

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- (4-REPEAT) COMET_0--READ ELINK 0 RAM: PROGRAM THE TRANSFER TYPE NEEDED FOR THE WRITE DATA RETRIEVAL OP AND THEN FPGA WILL IMMEDIATELY WRITE THE DATA TO THE USB FIFO
--      TRANSFER TYPE = ELINK0 DATA
            WAIT FOR 300000 NS;         -- wait until the serial data has been transmitted by the DCB and received by the salt

            WAIT FOR SYSCLK_PERIOD_60MHZ_0*20;
            WAIT UNTIL (SYSCLK60M_DEL_0'EVENT AND SYSCLK60M_DEL_0='1');
            WAIT FOR 9 NS;                                              -- USB MODULE DELAY
            P_USB_RXF_B_0       <=  '0';                                -- INITIATE A USB READ TRANSACTION

            WAIT UNTIL USB_OE_B_0='0';                                  -- HALT THE PROCESS UNTIL USB_OE_B_0 IS LOW

            WAIT FOR 9 NS;                                              -- USB MODULE DELAY
            BIDIR_USB_ADBUS_0   <=  "10101010";                         -- THIS IS THE START HEADER WORD

            WAIT UNTIL USB_RD_B_0 = '0';
            WAIT FOR 3 NS;                                              -- COMPENSATION FOR THE INTERNAL CLOCK PHASE LEAD 
            WAIT UNTIL (SYSCLK60M_DEL_0'EVENT AND SYSCLK60M_DEL_0='1');
            WAIT FOR 9 NS;                                              -- USB MODULE DELAY
            BIDIR_USB_ADBUS_0   <=  "10100000";                         -- TRANSFER TYPE = "ELINK0 DATA" 

            WAIT FOR 900 NS;                                            -- PC DELAY WHILE IT CONTINUES TO READ THE FIFO....
            WAIT UNTIL (SYSCLK60M_DEL_0'EVENT AND SYSCLK60M_DEL_0='1');
            P_USB_RXF_B_0       <=  '1';                                -- TERMINATE THE USB READ TRANSACTION--USING CONCURRENT ASSIGNMENT HERE!

            WAIT UNTIL USB_OE_B_0='1';                                  -- HALT THE PROCESS UNTIL USB_OE_B_0 IS BACK HIGH
            WAIT FOR 9 NS;                                              -- USB MODULE DELAY
            BIDIR_USB_ADBUS_0   <=  "ZZZZZZZZ";                         -- HI-Z 

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- (4-REPEAT) COMET_0--READ ELINK 1 RAM: PROGRAM THE TRANSFER TYPE NEEDED FOR THE WRITE DATA RETRIEVAL OP AND THEN FPGA WILL IMMEDIATELY WRITE THE DATA TO THE USB FIFO
--      TRANSFER TYPE = ELINK0 DATA
            WAIT FOR 10000 NS;         -- wait BETWEEN ELINK0 AND ELINK 1 RAM BANK READ

            WAIT FOR SYSCLK_PERIOD_60MHZ_0*20;
            WAIT UNTIL (SYSCLK60M_DEL_0'EVENT AND SYSCLK60M_DEL_0='1');
            WAIT FOR 9 NS;                                              -- USB MODULE DELAY
            P_USB_RXF_B_0       <=  '0';                                -- INITIATE A USB READ TRANSACTION

            WAIT UNTIL USB_OE_B_0='0';                                  -- HALT THE PROCESS UNTIL USB_OE_B_0 IS LOW

            WAIT FOR 9 NS;                                              -- USB MODULE DELAY
            BIDIR_USB_ADBUS_0   <=  "10101010";                         -- THIS IS THE START HEADER WORD

            WAIT UNTIL USB_RD_B_0 = '0';
            WAIT FOR 3 NS;                                              -- COMPENSATION FOR THE INTERNAL CLOCK PHASE LEAD 
            WAIT UNTIL (SYSCLK60M_DEL_0'EVENT AND SYSCLK60M_DEL_0='1');
            WAIT FOR 9 NS;                                              -- USB MODULE DELAY
            BIDIR_USB_ADBUS_0   <=  "10100001";                         -- TRANSFER TYPE = "ELINK1 DATA" 

            WAIT FOR 900 NS;                                            -- PC DELAY WHILE IT CONTINUES TO READ THE FIFO....
            WAIT UNTIL (SYSCLK60M_DEL_0'EVENT AND SYSCLK60M_DEL_0='1');
            P_USB_RXF_B_0       <=  '1';                                -- TERMINATE THE USB READ TRANSACTION--USING CONCURRENT ASSIGNMENT HERE!

            WAIT UNTIL USB_OE_B_0='1';                                  -- HALT THE PROCESS UNTIL USB_OE_B_0 IS BACK HIGH
            WAIT FOR 9 NS;                                              -- USB MODULE DELAY
            BIDIR_USB_ADBUS_0   <=  "ZZZZZZZZ";                         -- HI-Z 

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

            WAIT;
        END PROCESS;

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- DELAY THE ASSIGNMENT FO THE COMET 0 REFCLK OUTPUT TO THE COMET 1 INPUT

            REFCLK_DEL_P    <=  TRANSPORT REFCLK_P AFTER 18 NS;
            REFCLK_DEL_N    <=  TRANSPORT REFCLK_N AFTER 18 NS;

-- DELAY AND CONNECT THE TFC OUTPUT TO THE ELK0 INPUT
            ELK0_P       	<=  TRANSPORT TFC_N AFTER 4 NS;	--BUT RECALL THE TFC IS INVERTED IN GW TO ACCOUNT FOR A PIN SWAP ISSUE ON THE PASSIVE DAUGHTER BOARD
            ELK0_N       	<=  TRANSPORT TFC_P AFTER 4 NS;	--BUT RECALL THE TFC IS INVERTED IN GW TO ACCOUNT FOR A PIN SWAP ISSUE ON THE PASSIVE DAUGHTER BOARD

			ELK1_P       	<=  TRANSPORT TFC_P AFTER 4 NS;	--THIS IS A SLAVE DESERIALIZER, SO OK TO RECEIVE AS INVERTED!
            ELK1_N       	<=  TRANSPORT TFC_N AFTER 4 NS;	--THIS IS A SLAVE DESERIALIZER, SO OK TO RECEIVE AS INVERTED!

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    -- Instantiate Unit Under Test:  TOP_COMET IN DCB CONFIG MODE
    TOP_COMET_0 : TOP_COMET
        -- port map
        port map( 
            -- Inputs
        CLK200_P            => SYSCLK200MHZ_P,
        CLK200_N            => SYSCLK200MHZ_N,
        DEV_RST_B           => NSYSRESET_0,
		
		DCB_SALT_SEL		=> DCB_SALT_SEL,						--DCB / SALT FUNCTIONAL TEST

        USBCLK60MHZ         => SYSCLK60M_DEL_0,
        P_USB_RXF_B         => P_USB_RXF_B_0,
        P_USB_TXE_B         => P_USB_TXE_B_0,
        EXT_INT_REF_SEL     => '0',                                 -- USE LOCAL REF CLOCK

            -- Outputs
        ALL_PLL_LOCK        =>  OPEN,
        P_MASTER_POR_B      =>  OPEN,
        P_USB_MASTER_EN     =>  OPEN,
        P_CLK_40M_GL        =>  OPEN,
--        P_CLK_PH1_160MHZ    =>  OPEN,
        P_CCC_160M_FXD      =>  OPEN,
        P_CCC_160M_ADJ      =>  OPEN,

        BIDIR_CLK40M_P     	=>  SIG_CLK40M_P,                      -- 40 MHZ REF CLOCK FOR CCC#1: EITHER LOCAL OSC OR EXTERNAL REC'D DIFF CLOCK SOURCE
        BIDIR_CLK40M_N    	=>  SIG_CLK40M_N,                      -- 40 MHZ REF CLOCK FOR CCC#1: EITHER LOCAL OSC OR EXTERNAL REC'D DIFF CLOCK SOURCE

            USB_OE_B        =>  USB_OE_B_0,
            USB_RD_B        =>  USB_RD_B_0,
            USB_WR_B        =>  USB_WR_B_0,
            USB_SIWU_B      =>  USB_SIWU_B_0,


            -- Inouts
        TFC_DAT_0P          =>  TFC_P,                              -- SERIAL LVDS TFC COMMAND BIDIR PORT
        TFC_DAT_0N          =>  TFC_N, 
        REF_CLK_0P          =>  REFCLK_P,                           -- 40 MHZ REF CLK LVDS BIDIR PORT SYNCHRONOUS TO THE TCF OUTPUT BYTE RATE.  
        REF_CLK_0N          =>  REFCLK_N,                           -- DCB MODE TRANSMITS THE REFCLK, SALT MODE RECEIVES THE REFCLK

        ELK0_DAT_P         	=>  ELK0_P,                             -- SERIAL LVDS ELINK0 DATA BIDIR PORT
        ELK0_DAT_N         	=>  ELK0_N,

		ELK1_DAT_P         	=>  ELK1_P,                             -- SERIAL LVDS ELINK1 DATA BIDIR PORT
        ELK1_DAT_N         	=>  ELK1_N,

       BIDIR_USB_ADBUS      => BIDIR_USB_ADBUS_0

        );



end behavioral;

