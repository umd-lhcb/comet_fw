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
-- File: TB_TOP_COMET_DCB_CONFIG.vhd
-- File history:
--
-- Description:     THIS TESTBENCH ACTUALLY INSTANTIATES 2 TOP_COMET MODULES SO THE RELATIVE SERDES PERFORMENCE CAN BE EVALUATED.
--                  *TOP_COMET_0 IS THE MASTER DCB TFC VERSION (TX)
--                  *TOP_COMET_1 IS THE SALT TFC VERSION (RX)

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

entity TB_TOP_COMET_DCB_CONFIG is
end TB_TOP_COMET_DCB_CONFIG;

architecture behavioral of TB_TOP_COMET_DCB_CONFIG is

    SIGNAL SYSCLK200MHZ_P   :   STD_LOGIC   :=  '0';        -- OSC
    SIGNAL SYSCLK200MHZ_N   :   STD_LOGIC   :=  '1';
    SIGNAL E_SYSCLK200MHZ_P :   STD_LOGIC   :=  '0';        -- EXTERNAL
    SIGNAL E_SYSCLK200MHZ_N :   STD_LOGIC   :=  '1';

    SIGNAL SYSCLK160MHZ_P   :   STD_LOGIC   :=  '0';
    SIGNAL SYSCLK160MHZ_N   :   STD_LOGIC   :=  '1';

    SIGNAL TFC_P, TFC_DEL_P : STD_LOGIC     :=  '0';
    SIGNAL TFC_N, TFC_DEL_N : STD_LOGIC     :=  '1';

    SIGNAL CLK160M_TX_PX    : STD_LOGIC;  
    SIGNAL CLK160M_TX_NX    : STD_LOGIC;
-------------------------------------------------------------------------------------------------
-- THESE ARE FOR TOP_COMET_1 IS THE SLAVE SALT TFC VERSION (TX)CONTROL
    constant SYSCLK_PERIOD_60MHZ_1 : time := 16.6 ns;        -- SLIGHTLY FASTER THAN 60MHZ
    constant SYSCLK_PERIOD_200MHZ  : time := 5 ns;         
    constant E_SYSCLK_PERIOD_200MHZ: time := 5.2 ns;           -- CHANGE TO SEE DIFF IN SIM
    constant SYSCLK_PERIOD_160MHZ  : time := 6.23762376 ns;

    signal SYSCLK60MHZ_1  : std_logic  := '1';

    SIGNAL SYSCLK60M_EN_1            : STD_LOGIC := '0';
    signal SYSCLK60M_DEL_1           : STD_LOGIC := '0';

    signal NSYSRESET_1 : std_logic := '0';

    SIGNAL BIDIR_USB_ADBUS_1      : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL P_USB_RXF_B_1          : STD_LOGIC := '1';
    SIGNAL USB_RD_B_1             : STD_LOGIC;
    SIGNAL USB_OE_B_1             : STD_LOGIC;
    SIGNAL P_USB_TXE_B_1          : STD_LOGIC := '0';
    SIGNAL USB_WR_B_1             : STD_LOGIC;    
    SIGNAL USB_SIWU_B_1           : STD_LOGIC;
    SIGNAL RAM_BYTE_1             : STD_LOGIC_VECTOR (7 DOWNTO 0) := "00000000";
    SIGNAL DCB_SALT_SEL_1         : STD_LOGIC := '0'; 


    SIGNAL  SIM_MODE                :  STD_LOGIC := '1';
    SIGNAL  EXT_INT_REF_SEL         :  STD_LOGIC := '0';

    CONSTANT DAT_PH_DEL             : TIME := 5.4 NS;          -- TRANSPORT DELAY VALUE

-------------------------------------------------------------------------------------------------

    component TOP_COMET
        -- ports
        port( 
            -- Inputs
            CLK200_P            : in std_logic;
            CLK200_N            : in std_logic;
            DEV_RST_B           : in std_logic;
            USBCLK60MHZ         : in std_logic;
            P_USB_RXF_B         : in std_logic;
            P_USB_TXE_B         : in std_logic;
            DCB_SALT_SEL        : IN STD_LOGIC;
            SIM_MODE            : IN STD_LOGIC;
            EXT_INT_REF_SEL     : IN  STD_LOGIC;                        -- GPIO_9   '1' = CCC USE REC'D REF CLOCKS, '0' BOARD TRANSMITS REF CLOCK SIGNALS

            -- Outputs
        P_MASTER_POR_B      :   OUT STD_LOGIC;                          -- GPIO_2:  MASTER_POR_B
        P_USB_MASTER_EN     :   OUT STD_LOGIC;                          -- GPIO_7:  USB_MASTER_EN
        P_CCC_MAIN_LOCK     :   OUT STD_LOGIC;                          -- GPIO_3:  LOCK STATUS OF THE CCC #1
        P_CLK_PH1_160MHZ    :   OUT STD_LOGIC;                          -- GPIO_8:  CCC#1 FIXED CLOCK OUT
        P_RX_CLK160M        :   OUT STD_LOGIC;                          -- GPIO_6:  RX_CLK160M (MUX CLOCK SOURCE FROM EITHER ON-BOARD CCC#1 OR EXT RX 160M)
        P_CCC_160M_ADJ      :   OUT STD_LOGIC;                          -- GPIO_5:  CCC#2 ADJ CLOCK

        BIDIR_CLK200M_P     :   INOUT   STD_LOGIC;                      -- 200 MHZ REF CLOCK FOR CCC#1: EITHER LOCAL OSC OR EXTERNAL REC'D DIFF CLOCK SOURCE
        BIDIR_CLK200M_N     :   INOUT   STD_LOGIC;                      -- 200 MHZ REF CLOCK FOR CCC#1: EITHER LOCAL OSC OR EXTERNAL REC'D DIFF CLOCK SOURCE

        TX_200M_P           :   OUT STD_LOGIC;                          -- LVDS CLOCK TX BUFFER OF THE 200 MHZ REF CLOCK FOR CCC#1: EITHER LOCAL OSC OR EXTERNAL REC'D DIFF CLOCK SOURCE
        TX_200M_N           :   OUT STD_LOGIC;                          -- LVDS CLOCK TX BUFFER OF THE 200 MHZ REF CLOCK FOR CCC#1: EITHER LOCAL OSC OR EXTERNAL REC'D DIFF CLOCK SOURCE

        BIDIR_160M_P        :   INOUT   STD_LOGIC;                      -- 160 MHZ REF CLOCK FOR CCC#2: EITHER LOCAL CCC#1 OR EXTERNAL REC'D DIFF CLOCK SOURCE
        BIDIR_160M_N        :   INOUT   STD_LOGIC;                      -- 160 MHZ REF CLOCK FOR CCC#2: EITHER LOCAL CCC#1 OR EXTERNAL REC'D DIFF CLOCK SOURCE

        TX_160M_P           :   OUT STD_LOGIC;                          -- LVDS CLOCK TX BUFFER OF THE DCB-CONFIG'D COMET 200 MHZ CLOCK TO BE USED AS A MAIN CCC REF CLOCK OF A SALT-CONFIGURED COMET    
        TX_160M_N           :   OUT STD_LOGIC;                          -- LVDS CLOCK TX BUFFER OF THE DCB-CONFIG'D COMET 200 MHZ CLOCK TO BE USED AS A MAIN CCC REF CLOCK OF A SALT-CONFIGURED COMET    

            USB_OE_B   : out std_logic;
            USB_RD_B   : out std_logic;
            USB_WR_B   : out std_logic;
            USB_SIWU_B : out std_logic;
            --REF_CLK_0P : inout std_logic;
            --REF_CLK_0N : inout std_logic;
            --REF_CLK_10P : out std_logic;
            --REF_CLK_10N : out std_logic;
            --REF_CLK_11P : out std_logic;
            --REF_CLK_11N : out std_logic;

            -- Inouts
            BIDIR_USB_ADBUS : inout std_logic_vector(7 downto 0);
            TFC_DAT_0P : inout std_logic;
            TFC_DAT_0N : inout std_logic
            --TFC_OUT_1P : inout std_logic;
            --TFC_OUT_1N : inout std_logic;
            --TFC_OUT_2P : inout std_logic;
            --TFC_OUT_2N : inout std_logic;
            --TFC_OUT_3P : inout std_logic;
            --TFC_OUT_3N : inout std_logic;
            --TFC_OUT_4P : inout std_logic;
            --TFC_OUT_4N : inout std_logic;
            --TFC_OUT_5P : inout std_logic;
            --TFC_OUT_5N : inout std_logic;
            --TFC_OUT_6P : inout std_logic;
            --TFC_OUT_6N : inout std_logic;
            --TFC_OUT_7P : inout std_logic;
            --TFC_OUT_7N : inout std_logic;
            --TFC_OUT_8P : inout std_logic;
            --TFC_OUT_8N : inout std_logic;
            --TFC_OUT_9P : inout std_logic;
            --TFC_OUT_9N : inout std_logic;
            --TFC_OUT_10P : inout std_logic;
            --TFC_OUT_10N : inout std_logic;
            --TFC_OUT_11P : inout std_logic;
            --TFC_OUT_11N : inout std_logic

        );
    end component;

begin
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- GENERATE POR
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- THESE IS FOR TOP_COMET_1 IS THE SLAVE SALT TFC VERSION (TX)CONTROL 
 process
        variable vhdl_initial : BOOLEAN := TRUE;

    begin
        if ( vhdl_initial ) then
            -- Assert Reset
            NSYSRESET_1 <= '0';
            wait for ( SYSCLK_PERIOD_60MHZ_1 * 50 );
            
            NSYSRESET_1 <= '1';
            wait;
        end if;
    end process;



--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- GENERATE CLOCKS
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    -- Clock DriverS

    -- OSCILLATOR SOURCE
    PROCESS
        BEGIN
            SYSCLK200MHZ_P      <=  '0';
            SYSCLK200MHZ_N      <=  '1';
            WAIT FOR SYSCLK_PERIOD_200MHZ / 2.0;

            SYSCLK200MHZ_P      <=  '1';
            SYSCLK200MHZ_N      <=  '0';
            WAIT FOR SYSCLK_PERIOD_200MHZ / 2.0;
        END PROCESS;

    -- EXTERNAL LVDS CLOCK SOURCE
    PROCESS
        BEGIN
            E_SYSCLK200MHZ_P      <=  '0';
            E_SYSCLK200MHZ_N      <=  '1';
            WAIT FOR E_SYSCLK_PERIOD_200MHZ / 2.0;

            E_SYSCLK200MHZ_P      <=  '1';
            E_SYSCLK200MHZ_N      <=  '0';
            WAIT FOR E_SYSCLK_PERIOD_200MHZ / 2.0;
        END PROCESS;


    PROCESS
        BEGIN
            SYSCLK160MHZ_P      <=  '0';
            SYSCLK160MHZ_N      <=  '1';
            WAIT FOR SYSCLK_PERIOD_160MHZ / 2.0;

            SYSCLK160MHZ_P      <=  '1';
            SYSCLK160MHZ_N      <=  '0';
            WAIT FOR SYSCLK_PERIOD_160MHZ / 2.0;
        END PROCESS;




    SYSCLK60MHZ_1     <= not SYSCLK60MHZ_1 after (SYSCLK_PERIOD_60MHZ_1 / 2.0 );

   -- process for THE delayed 60 Mhz clock enable
----------------------
    process
        begin
            wait for ( SYSCLK_PERIOD_60MHZ_1 * 100 );
            WAIT FOR 2 NS;
            SYSCLK60M_EN_1    <=  '1';
            wait;
    end process;

    SYSCLK60M_DEL_1   <=  SYSCLK60M_EN_1 AND SYSCLK60MHZ_1;

    DCB_SALT_SEL_1    <=    '0';
    
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- generate a continuous 8E sync pattern at 320 MBbps
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    PROCESS                                     -- TRANSMIT 8E WITH MSB FIRST
        BEGIN

            WAIT UNTIL (CLK160M_TX_PX'EVENT);
            TFC_P       <=  '1';
            TFC_N       <=  '0';
            TFC_DEL_P   <=  TRANSPORT TFC_P AFTER DAT_PH_DEL;
            TFC_DEL_N   <=  TRANSPORT TFC_N AFTER DAT_PH_DEL;

            WAIT UNTIL (CLK160M_TX_PX'EVENT);
            TFC_P       <=  '0';
            TFC_N       <=  '1';
            TFC_DEL_P   <=  TRANSPORT TFC_P AFTER DAT_PH_DEL;
            TFC_DEL_N   <=  TRANSPORT TFC_N AFTER DAT_PH_DEL;

            WAIT UNTIL (CLK160M_TX_PX'EVENT);
            TFC_P       <=  '0';
            TFC_N       <=  '1';
            TFC_DEL_P   <=  TRANSPORT TFC_P AFTER DAT_PH_DEL;
            TFC_DEL_N   <=  TRANSPORT TFC_N AFTER DAT_PH_DEL;

            WAIT UNTIL (CLK160M_TX_PX'EVENT);
            TFC_P       <=  '0';
            TFC_N       <=  '1';
            TFC_DEL_P   <=  TRANSPORT TFC_P AFTER DAT_PH_DEL;
            TFC_DEL_N   <=  TRANSPORT TFC_N AFTER DAT_PH_DEL;

            WAIT UNTIL (CLK160M_TX_PX'EVENT);
            TFC_P       <=  '1';
            TFC_N       <=  '0';
            TFC_DEL_P   <=  TRANSPORT TFC_P AFTER DAT_PH_DEL;
            TFC_DEL_N   <=  TRANSPORT TFC_N AFTER DAT_PH_DEL;

            WAIT UNTIL (CLK160M_TX_PX'EVENT);
            TFC_P       <=  '1';
            TFC_N       <=  '0';
            TFC_DEL_P   <=  TRANSPORT TFC_P AFTER DAT_PH_DEL;
            TFC_DEL_N   <=  TRANSPORT TFC_N AFTER DAT_PH_DEL;

            WAIT UNTIL (CLK160M_TX_PX'EVENT);
            TFC_P       <=  '1';
            TFC_N       <=  '0';
            TFC_DEL_P   <=  TRANSPORT TFC_P AFTER DAT_PH_DEL;
            TFC_DEL_N   <=  TRANSPORT TFC_N AFTER DAT_PH_DEL;

            WAIT UNTIL (CLK160M_TX_PX'EVENT);
            TFC_P       <=  '0';
            TFC_N       <=  '1';
            TFC_DEL_P   <=  TRANSPORT TFC_P AFTER DAT_PH_DEL;
            TFC_DEL_N   <=  TRANSPORT TFC_N AFTER DAT_PH_DEL;

        END PROCESS;



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
-- FOR THE MASTER TFC COMET_1
    PROCESS 
        BEGIN
-- INITIALIZE CONDITION OF BUS
            BIDIR_USB_ADBUS_1   <=  "ZZZZZZZZ";                       -- HI-Z 

-- ++++++++
-- (1) COMET_1: WRITE ALL REGISTERS VIA A SET OF CONTINUOUS USB READ TRANSFERS (IE ASSUME HOST CAN KEEP UP)
-- ++++++++
            WAIT FOR SYSCLK_PERIOD_60MHZ_1*6000;                       -- LONG WAIT TO MAKE SURE THE USB CLOCK HAS BEEN DETECTED AND THE USB_INTERFACE.VHD IS ENABLED
            WAIT UNTIL (SYSCLK60M_DEL_1'EVENT AND SYSCLK60M_DEL_1='1');
            WAIT FOR 9 NS;                                          -- USB MODULE DELAY
            P_USB_RXF_B_1       <=  '0';                              -- INITIATE A USB READ TRANSACTION

            WAIT UNTIL USB_OE_B_1='0';                                -- HALT THE PROCESS UNTIL USB_OE_B_1 IS LOW
            WAIT FOR 9 NS;                                          -- USB MODULE DELAY
            BIDIR_USB_ADBUS_1   <=  "10101010";                       -- THIS IS THE START HEADER WORD

            WAIT UNTIL USB_RD_B_1 = '0';
            WAIT FOR 3 NS;                                          -- COMPENSATION FOR THE INTERNAL CLOCK PHASE LEAD 
            WAIT UNTIL (SYSCLK60M_DEL_1'EVENT AND SYSCLK60M_DEL_1='1');
            WAIT FOR 9 NS;                                          -- USB MODULE DELAY
            BIDIR_USB_ADBUS_1   <=  "00000001";                       -- TRANSFER TYPE = "ALL REGISTER" 

            WAIT UNTIL (SYSCLK60M_DEL_1'EVENT AND SYSCLK60M_DEL_1='1');
            WAIT FOR 9 NS;                                          -- USB MODULE DELAY
            BIDIR_USB_ADBUS_1   <=  "00000011";                       -- OP_MODE= TFC RX MODE, SYNC MODE ON, REPEAT MODE

            WAIT UNTIL (SYSCLK60M_DEL_1'EVENT AND SYSCLK60M_DEL_1='1');
            WAIT FOR 9 NS;                                          -- USB MODULE DELAY
            BIDIR_USB_ADBUS_1   <=  "00010000";                       -- TFC_START_ADDR

            WAIT UNTIL (SYSCLK60M_DEL_1'EVENT AND SYSCLK60M_DEL_1='1');
            WAIT FOR 9 NS;                                          -- USB MODULE DELAY
            BIDIR_USB_ADBUS_1   <=  "00100000";                       -- TFC_STOP_ADDR

            WAIT UNTIL (SYSCLK60M_DEL_1'EVENT AND SYSCLK60M_DEL_1='1');
            WAIT FOR 9 NS;                                          -- USB MODULE DELAY
            BIDIR_USB_ADBUS_1   <=  "00110000";                       -- ELINKS_START_ADDR

            WAIT UNTIL (SYSCLK60M_DEL_1'EVENT AND SYSCLK60M_DEL_1='1');
            WAIT FOR 9 NS;                                          -- USB MODULE DELAY
            BIDIR_USB_ADBUS_1   <=  "01000000";                       -- ELINKS_STOP_ADDR

            WAIT UNTIL (SYSCLK60M_DEL_1'EVENT AND SYSCLK60M_DEL_1='1');
            WAIT FOR 9 NS;                                          -- USB MODULE DELAY
            BIDIR_USB_ADBUS_1   <=  "11111111";                       -- CHKSUM

            WAIT UNTIL (SYSCLK60M_DEL_1'EVENT AND SYSCLK60M_DEL_1='1');
            WAIT FOR 9 NS;                                          -- USB MODULE DELAY
            BIDIR_USB_ADBUS_1   <=  "01010101";                       -- STOP HEADER

            WAIT FOR 900 NS;                                          -- PC DELAY WHILE IT CONTINUES TO READ THE FIFO....
            WAIT UNTIL (SYSCLK60M_DEL_1'EVENT AND SYSCLK60M_DEL_1='1');
            P_USB_RXF_B_1       <=  '1';                                -- TERMINATE THE USB READ TRANSACTION--USING CONCURRENT ASSIGNMENT HERE!

            WAIT UNTIL USB_OE_B_1='1';                                -- HALT THE PROCESS UNTIL USB_OE_B_1 IS BACK HIGH
            WAIT FOR 9 NS;                                          -- USB MODULE DELAY
            BIDIR_USB_ADBUS_1   <=  "ZZZZZZZZ";                       -- HI-Z 

-- ++++++++
-- PLACE A GAP OF TIME BETWEEN THESE TWO TYPES OF SIM CONDITONS
            WAIT FOR 10*SYSCLK_PERIOD_60MHZ_1;
            WAIT UNTIL (SYSCLK60M_DEL_1'EVENT AND SYSCLK60M_DEL_1='1');

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- (2)  COMET_1: PROGRAM THE TRANSFER TYPE NEEDED FOR THE NEXT WRITE DATA RETRIEVAL OP AND THEN FPGA WILL IMMEDIATELY WRITE THE DATA TO THE USB FIFO
--      TRANSFER TYPE = ALL CONTROL REGISTERS

            WAIT FOR SYSCLK_PERIOD_60MHZ_1*20;
            WAIT UNTIL (SYSCLK60M_DEL_1'EVENT AND SYSCLK60M_DEL_1='1');
            WAIT FOR 9 NS;                                          -- USB MODULE DELAY
            P_USB_RXF_B_1       <=  '0';                              -- INITIATE A USB READ TRANSACTION

            WAIT UNTIL USB_OE_B_1='0';                                -- HALT THE PROCESS UNTIL USB_OE_B_1 IS LOW

            WAIT FOR 9 NS;                                          -- USB MODULE DELAY
            BIDIR_USB_ADBUS_1   <=  "10101010";                       -- THIS IS THE START HEADER WORD

            WAIT UNTIL USB_RD_B_1 = '0';
            WAIT FOR 3 NS;                                          -- COMPENSATION FOR THE INTERNAL CLOCK PHASE LEAD 
            WAIT UNTIL (SYSCLK60M_DEL_1'EVENT AND SYSCLK60M_DEL_1='1');
            WAIT FOR 9 NS;                                          -- USB MODULE DELAY
            BIDIR_USB_ADBUS_1   <=  "10000001";                       -- TRANSFER TYPE = "ALL REGISTER" 

            WAIT FOR 900 NS;                                          -- PC DELAY WHILE IT CONTINUES TO READ THE FIFO....
            WAIT UNTIL (SYSCLK60M_DEL_1'EVENT AND SYSCLK60M_DEL_1='1');
            P_USB_RXF_B_1       <=  '1';                                -- TERMINATE THE USB READ TRANSACTION--USING CONCURRENT ASSIGNMENT HERE!

            WAIT UNTIL USB_OE_B_1='1';                                -- HALT THE PROCESS UNTIL USB_OE_B_1 IS BACK HIGH
            WAIT FOR 9 NS;                                          -- USB MODULE DELAY
            BIDIR_USB_ADBUS_1   <=  "ZZZZZZZZ";                       -- HI-Z 

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- (3)  COMET_1: STORE A TFC BLOCK --256 WORDS + OVERHEAD BYTES
            WAIT FOR SYSCLK_PERIOD_60MHZ_1*20;
            WAIT UNTIL (SYSCLK60M_DEL_1'EVENT AND SYSCLK60M_DEL_1='1');
            WAIT FOR 9 NS;                                          -- USB MODULE DELAY
            P_USB_RXF_B_1       <=  '0';                              -- INITIATE A USB READ TRANSACTION

            WAIT UNTIL USB_OE_B_1='0';                                -- HALT THE PROCESS UNTIL USB_OE_B_1 IS LOW

            WAIT FOR 9 NS;                                          -- USB MODULE DELAY
            BIDIR_USB_ADBUS_1   <=  "10101010";                       -- THIS IS THE START HEADER WORD

            WAIT UNTIL USB_RD_B_1 = '0';
            WAIT FOR 3 NS;                                          -- COMPENSATION FOR THE INTERNAL CLOCK PHASE LEAD 
            WAIT UNTIL (SYSCLK60M_DEL_1'EVENT AND SYSCLK60M_DEL_1='1');
            WAIT FOR 9 NS;                                          -- USB MODULE DELAY
            BIDIR_USB_ADBUS_1   <=  "00000010";                       -- TRANSFER TYPE = "TFC BLOCK" 

            RAM_BYTE_1    <=  "00000000";
        FOR I IN 0 TO 255 LOOP
            WAIT UNTIL (SYSCLK60M_DEL_1'EVENT AND SYSCLK60M_DEL_1='1');
            WAIT FOR 9 NS;                                          -- USB MODULE DELAY
            BIDIR_USB_ADBUS_1   <=  RAM_BYTE_1;                         -- TFC_DATA
            RAM_BYTE_1        <=  RAM_BYTE_1 + "1";
        END LOOP;


            WAIT UNTIL (SYSCLK60M_DEL_1'EVENT AND SYSCLK60M_DEL_1='1');
            WAIT FOR 9 NS;                                          -- USB MODULE DELAY
            BIDIR_USB_ADBUS_1   <=  "11100111";                       -- CHKSUM

            WAIT UNTIL (SYSCLK60M_DEL_1'EVENT AND SYSCLK60M_DEL_1='1');
            WAIT FOR 9 NS;                                          -- USB MODULE DELAY
            BIDIR_USB_ADBUS_1   <=  "01010101";                       -- STOP HEADER

            WAIT FOR 900 NS;                                          -- PC DELAY WHILE IT CONTINUES TO READ THE FIFO....
            WAIT UNTIL (SYSCLK60M_DEL_1'EVENT AND SYSCLK60M_DEL_1='1');
            P_USB_RXF_B_1       <=  '1';                                -- TERMINATE THE USB READ TRANSACTION--USING CONCURRENT ASSIGNMENT HERE!

            WAIT UNTIL USB_OE_B_1='1';                                -- HALT THE PROCESS UNTIL USB_OE_B_1 IS BACK HIGH
            WAIT FOR 9 NS;                                          -- USB MODULE DELAY
            BIDIR_USB_ADBUS_1   <=  "ZZZZZZZZ";                       -- HI-Z 


--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- (4) COMET_1: PROGRAM THE TRANSFER TYPE NEEDED FOR THE NEXT WRITE DATA RETRIEVAL OP AND THEN THE FPGA WILL IMMEDIATELY SEND IT TO THE USB FIFO
-- TRANSFER TYPE = TFC REGISTERS

            WAIT FOR SYSCLK_PERIOD_60MHZ_1*20;
            WAIT UNTIL (SYSCLK60M_DEL_1'EVENT AND SYSCLK60M_DEL_1='1');
            WAIT FOR 9 NS;                                          -- USB MODULE DELAY
            P_USB_RXF_B_1       <=  '0';                              -- INITIATE A USB READ TRANSACTION

            WAIT UNTIL USB_OE_B_1='0';                                -- HALT THE PROCESS UNTIL USB_OE_B_1 IS LOW

            WAIT FOR 9 NS;                                          -- USB MODULE DELAY
            BIDIR_USB_ADBUS_1   <=  "10101010";                       -- THIS IS THE START HEADER WORD

            WAIT UNTIL USB_RD_B_1 = '0';
            WAIT FOR 3 NS;                                          -- COMPENSATION FOR THE INTERNAL CLOCK PHASE LEAD 
            WAIT UNTIL (SYSCLK60M_DEL_1'EVENT AND SYSCLK60M_DEL_1='1');
            WAIT FOR 9 NS;                                          -- USB MODULE DELAY
            BIDIR_USB_ADBUS_1   <=  "10000010";                       -- TRANSFER TYPE = "TFC REGISTERS" 

            WAIT FOR 900 NS;                                          -- PC DELAY WHILE IT CONTINUES TO READ THE FIFO....
            WAIT UNTIL (SYSCLK60M_DEL_1'EVENT AND SYSCLK60M_DEL_1='1');
            P_USB_RXF_B_1       <=  '1';                                -- TERMINATE THE USB READ TRANSACTION--USING CONCURRENT ASSIGNMENT HERE!

            WAIT UNTIL USB_OE_B_1='1';                                -- HALT THE PROCESS UNTIL USB_OE_B_1 IS BACK HIGH
            WAIT FOR 9 NS;                                          -- USB MODULE DELAY
            BIDIR_USB_ADBUS_1   <=  "ZZZZZZZZ";                       -- HI-Z 

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- (5) COMET_1: STORE THE ELINK0 BLOCK --256 WORDS + OVERHEAD BYTES
            WAIT FOR SYSCLK_PERIOD_60MHZ_1*20;
            WAIT UNTIL (SYSCLK60M_DEL_1'EVENT AND SYSCLK60M_DEL_1='1');
            WAIT FOR 9 NS;                                          -- USB MODULE DELAY
            P_USB_RXF_B_1       <=  '0';                              -- INITIATE A USB READ TRANSACTION

            WAIT UNTIL USB_OE_B_1='0';                                -- HALT THE PROCESS UNTIL USB_OE_B_1 IS LOW

            WAIT FOR 9 NS;                                          -- USB MODULE DELAY
            BIDIR_USB_ADBUS_1   <=  "10101010";                       -- THIS IS THE START HEADER WORD

            WAIT UNTIL USB_RD_B_1 = '0';
            WAIT FOR 3 NS;                                          -- COMPENSATION FOR THE INTERNAL CLOCK PHASE LEAD 
            WAIT UNTIL (SYSCLK60M_DEL_1'EVENT AND SYSCLK60M_DEL_1='1');
            WAIT FOR 9 NS;                                          -- USB MODULE DELAY
            BIDIR_USB_ADBUS_1   <=  "00100000";                       -- TRANSFER TYPE = "ELINK0 BLOCK" 

            RAM_BYTE_1    <=  "00000000";
        FOR I IN 0 TO 255 LOOP
            WAIT UNTIL (SYSCLK60M_DEL_1'EVENT AND SYSCLK60M_DEL_1='1');
            WAIT FOR 9 NS;                                          -- USB MODULE DELAY
            BIDIR_USB_ADBUS_1   <=  RAM_BYTE_1;                         -- ELINK0_DATA
            RAM_BYTE_1        <=  RAM_BYTE_1 + "1";
        END LOOP;


            WAIT UNTIL (SYSCLK60M_DEL_1'EVENT AND SYSCLK60M_DEL_1='1');
            WAIT FOR 9 NS;                                          -- USB MODULE DELAY
            BIDIR_USB_ADBUS_1   <=  "11100111";                       -- CHKSUM

            WAIT UNTIL (SYSCLK60M_DEL_1'EVENT AND SYSCLK60M_DEL_1='1');
            WAIT FOR 9 NS;                                          -- USB MODULE DELAY
            BIDIR_USB_ADBUS_1   <=  "01010101";                       -- STOP HEADER

            WAIT FOR 900 NS;                                          -- PC DELAY WHILE IT CONTINUES TO READ THE FIFO....
            WAIT UNTIL (SYSCLK60M_DEL_1'EVENT AND SYSCLK60M_DEL_1='1');
            P_USB_RXF_B_1       <=  '1';                                -- TERMINATE THE USB READ TRANSACTION--USING CONCURRENT ASSIGNMENT HERE!

            WAIT UNTIL USB_OE_B_1='1';                                -- HALT THE PROCESS UNTIL USB_OE_B_1 IS BACK HIGH
            WAIT FOR 9 NS;                                          -- USB MODULE DELAY
            BIDIR_USB_ADBUS_1   <=  "ZZZZZZZZ";                       -- HI-Z 

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- (6) COMET_1: PROGRAM THE TRANSFER TYPE NEEDED FOR THE NEXT WRITE DATA RETRIEVAL OP AND THEN THE FPGA WILL IMMEDIATELY SEND THE DATA TO THE USB FIFO
-- TRANSFER TYPE = ELINK0 REGISTERS

            WAIT FOR SYSCLK_PERIOD_60MHZ_1*20;
            WAIT UNTIL (SYSCLK60M_DEL_1'EVENT AND SYSCLK60M_DEL_1='1');
            WAIT FOR 9 NS;                                          -- USB MODULE DELAY
            P_USB_RXF_B_1       <=  '0';                              -- INITIATE A USB READ TRANSACTION

            WAIT UNTIL USB_OE_B_1='0';                                -- HALT THE PROCESS UNTIL USB_OE_B_1 IS LOW

            WAIT FOR 9 NS;                                          -- USB MODULE DELAY
            BIDIR_USB_ADBUS_1   <=  "10101010";                       -- THIS IS THE START HEADER WORD

            WAIT UNTIL USB_RD_B_1 = '0';
            WAIT FOR 3 NS;                                          -- COMPENSATION FOR THE INTERNAL CLOCK PHASE LEAD 
            WAIT UNTIL (SYSCLK60M_DEL_1'EVENT AND SYSCLK60M_DEL_1='1');
            WAIT FOR 9 NS;                                          -- USB MODULE DELAY
            BIDIR_USB_ADBUS_1   <=  "10100000";                       -- TRANSFER TYPE = "ELINK0 REGISTERS" 

            WAIT FOR 900 NS;                                          -- PC DELAY WHILE IT CONTINUES TO READ THE FIFO....
            WAIT UNTIL (SYSCLK60M_DEL_1'EVENT AND SYSCLK60M_DEL_1='1');
            P_USB_RXF_B_1       <=  '1';                                -- TERMINATE THE USB READ TRANSACTION--USING CONCURRENT ASSIGNMENT HERE!

            WAIT UNTIL USB_OE_B_1='1';                                -- HALT THE PROCESS UNTIL USB_OE_B_1 IS BACK HIGH
            WAIT FOR 9 NS;                                          -- USB MODULE DELAY
            BIDIR_USB_ADBUS_1   <=  "ZZZZZZZZ";                       -- HI-Z 

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- (7) COMET_1: WAIT FOR 200 USEC FOR THE ALIGNMENT ALG TO COMPLETE, THEN SEND COMMANDS TO TX/RX TFC DATA
--      (THE RX DELAY IS BEING SET TO 575 US SO THE DE-SERIALIZER STARTS RECEIVING STD DATA AS SYNC BYTES FOLLOWED BY REAL DATA)
            WAIT FOR 575000 NS;
-- ++++++++
--      WRITE ALL CONTROL REGISTERS VIA A SET OF CONTINUOUS USB READ TRANSFERS (IE ASSUME HOST CAN KEEP UP)
-- ++++++++
            WAIT FOR SYSCLK_PERIOD_60MHZ_1*800;                       -- LONG WAIT 
            WAIT UNTIL (SYSCLK60M_DEL_1'EVENT AND SYSCLK60M_DEL_1='1');
            WAIT FOR 9 NS;                                          -- USB MODULE DELAY
            P_USB_RXF_B_1       <=  '0';                              -- INITIATE A USB READ TRANSACTION

            WAIT UNTIL USB_OE_B_1='0';                                -- HALT THE PROCESS UNTIL USB_OE_B_1 IS LOW
            WAIT FOR 9 NS;                                          -- USB MODULE DELAY
            BIDIR_USB_ADBUS_1   <=  "10101010";                       -- THIS IS THE START HEADER WORD

            WAIT UNTIL USB_RD_B_1 = '0';
            WAIT FOR 3 NS;                                          -- COMPENSATION FOR THE INTERNAL CLOCK PHASE LEAD 
            WAIT UNTIL (SYSCLK60M_DEL_1'EVENT AND SYSCLK60M_DEL_1='1');
            WAIT FOR 9 NS;                                          -- USB MODULE DELAY
            BIDIR_USB_ADBUS_1   <=  "00000001";                       -- TRANSFER TYPE = "ALL REGISTER" 

            WAIT UNTIL (SYSCLK60M_DEL_1'EVENT AND SYSCLK60M_DEL_1='1');
            WAIT FOR 9 NS;                                          -- USB MODULE DELAY
            BIDIR_USB_ADBUS_1   <=  "00000001";                       -- OP_MODE= TFC RX MODE, SYNC MODE OFF, REPEAT MODE

            WAIT UNTIL (SYSCLK60M_DEL_1'EVENT AND SYSCLK60M_DEL_1='1');
            WAIT FOR 9 NS;                                          -- USB MODULE DELAY
            BIDIR_USB_ADBUS_1   <=  "00000000";                       -- TFC_START_ADDR

            WAIT UNTIL (SYSCLK60M_DEL_1'EVENT AND SYSCLK60M_DEL_1='1');
            WAIT FOR 9 NS;                                          -- USB MODULE DELAY
            BIDIR_USB_ADBUS_1   <=  "11111111";                       -- TFC_STOP_ADDR

            WAIT UNTIL (SYSCLK60M_DEL_1'EVENT AND SYSCLK60M_DEL_1='1');
            WAIT FOR 9 NS;                                          -- USB MODULE DELAY
            BIDIR_USB_ADBUS_1   <=  "00110000";                       -- ELINKS_START_ADDR

            WAIT UNTIL (SYSCLK60M_DEL_1'EVENT AND SYSCLK60M_DEL_1='1');
            WAIT FOR 9 NS;                                          -- USB MODULE DELAY
            BIDIR_USB_ADBUS_1   <=  "01000000";                       -- ELINKS_STOP_ADDR

            WAIT UNTIL (SYSCLK60M_DEL_1'EVENT AND SYSCLK60M_DEL_1='1');
            WAIT FOR 9 NS;                                          -- USB MODULE DELAY
            BIDIR_USB_ADBUS_1   <=  "11111111";                       -- CHKSUM

            WAIT UNTIL (SYSCLK60M_DEL_1'EVENT AND SYSCLK60M_DEL_1='1');
            WAIT FOR 9 NS;                                          -- USB MODULE DELAY
            BIDIR_USB_ADBUS_1   <=  "01010101";                       -- STOP HEADER

            WAIT FOR 900 NS;                                          -- PC DELAY WHILE IT CONTINUES TO READ THE FIFO....
            WAIT UNTIL (SYSCLK60M_DEL_1'EVENT AND SYSCLK60M_DEL_1='1');
            P_USB_RXF_B_1       <=  '1';                                -- TERMINATE THE USB READ TRANSACTION--USING CONCURRENT ASSIGNMENT HERE!

            WAIT UNTIL USB_OE_B_1='1';                                -- HALT THE PROCESS UNTIL USB_OE_B_1 IS BACK HIGH
            WAIT FOR 9 NS;                                          -- USB MODULE DELAY
            BIDIR_USB_ADBUS_1   <=  "ZZZZZZZZ";                       -- HI-Z 
            

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            WAIT;
        END PROCESS;

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- PROCESS USED TO SIMULATE EFFECTS OF THE RESET_EN SIGNAL FOR THE CCC#2 IN COMET 1 (salt)
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --PROCESS
        --BEGIN
            --PLL_RESET_EN    <=  "1";
            --WAIT FOR 120000 NS;
            --PLL_RESET_EN    <=  "0";
            --WAIT;
        --END PROCESS;
            
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    -- Instantiate Unit Under Test:  TOP_COMET IN SALT CONFIG MODE
    TOP_COMET_0 : TOP_COMET
        -- port map
        port map( 
            -- Inputs
            CLK200_P        => SYSCLK200MHZ_P,
            CLK200_N        => SYSCLK200MHZ_N,
            DEV_RST_B       => NSYSRESET_1,
--            RESET_EN        => PLL_RESET_EN,                             -- '1'=RESET ENABLED, '0'= RESET MODE DISABLED
            USBCLK60MHZ     => SYSCLK60M_DEL_1,
            P_USB_RXF_B     => P_USB_RXF_B_1,
            P_USB_TXE_B     => P_USB_TXE_B_1,
            DCB_SALT_SEL    => DCB_SALT_SEL_1,
            SIM_MODE        => SIM_MODE,
            EXT_INT_REF_SEL => EXT_INT_REF_SEL,

            -- Outputs
        P_MASTER_POR_B      => OPEN,                                    -- GPIO_2:  MASTER_POR_B
        P_USB_MASTER_EN     => OPEN,                                    -- GPIO_7:  USB_MASTER_EN
        P_CCC_MAIN_LOCK     => OPEN,                                    -- GPIO_3:  LOCK STATUS OF THE CCC #1
        P_CLK_PH1_160MHZ    => OPEN,                                    -- GPIO_8:  CCC#1 FIXED CLOCK OUT
        P_RX_CLK160M        => OPEN,                                    -- GPIO_6:  RX_CLK160M (MUX CLOCK SOURCE FROM EITHER ON-BOARD CCC#1 OR EXT RX 160M)
        P_CCC_160M_ADJ      => OPEN,                                    -- GPIO_5:  CCC#2 ADJ CLOCK

        BIDIR_CLK200M_P     => OPEN,                    -- 200 MHZ REF CLOCK FOR CCC#1: EITHER LOCAL OSC OR EXTERNAL REC'D DIFF CLOCK SOURCE
        BIDIR_CLK200M_N     => OPEN,                    -- 200 MHZ REF CLOCK FOR CCC#1: EITHER LOCAL OSC OR EXTERNAL REC'D DIFF CLOCK SOURCE

        TX_200M_P           => OPEN,                                -- LVDS CLOCK TX BUFFER OF THE 200 MHZ REF CLOCK FOR CCC#1: EITHER LOCAL OSC OR EXTERNAL REC'D DIFF CLOCK SOURCE
        TX_200M_N           => OPEN,                                -- LVDS CLOCK TX BUFFER OF THE 200 MHZ REF CLOCK FOR CCC#1: EITHER LOCAL OSC OR EXTERNAL REC'D DIFF CLOCK SOURCE

        BIDIR_160M_P        => OPEN,                      -- 160 MHZ REF CLOCK FOR CCC#2: EITHER LOCAL CCC#1 OR EXTERNAL REC'D DIFF CLOCK SOURCE
        BIDIR_160M_N        => OPEN,                      -- 160 MHZ REF CLOCK FOR CCC#2: EITHER LOCAL CCC#1 OR EXTERNAL REC'D DIFF CLOCK SOURCE


        TX_160M_P           =>  CLK160M_TX_PX,                          -- LVDS CLOCK TX BUFFER OF THE DCB-CONFIG'D COMET 200 MHZ CLOCK TO BE USED AS A MAIN CCC REF CLOCK OF A SALT-CONFIGURED COMET    
        TX_160M_N           =>  CLK160M_TX_NX,                          -- LVDS CLOCK TX BUFFER OF THE DCB-CONFIG'D COMET 200 MHZ CLOCK TO BE USED AS A MAIN CCC REF CLOCK OF A SALT-CONFIGURED COMET    
            USB_OE_B        =>  USB_OE_B_1,
            USB_RD_B        =>  USB_RD_B_1,
            USB_WR_B        =>  USB_WR_B_1,
            USB_SIWU_B      =>  USB_SIWU_B_1,
            --REF_CLK_10P =>  open,
            --REF_CLK_10N =>  open,
            --REF_CLK_11P =>  open,
            --REF_CLK_11N =>  open,

            -- Inouts
            BIDIR_USB_ADBUS => BIDIR_USB_ADBUS_1,
            TFC_DAT_0P =>  TFC_P,                           -- THESE ARE TO BE CONFIGURED AS RECEIVERS
            TFC_DAT_0N =>  TFC_N                           -- SINCE SPECIFIED TO BE IN SALT MODE
            --TFC_OUT_1P =>  open,
            --TFC_OUT_1N =>  open,
            --TFC_OUT_2P =>  open,
            --TFC_OUT_2N =>  open,
            --TFC_OUT_3P =>  open,
            --TFC_OUT_3N =>  open,
            --TFC_OUT_4P =>  open,
            --TFC_OUT_4N =>  open,
            --TFC_OUT_5P =>  open,
            --TFC_OUT_5N =>  open,
            --TFC_OUT_6P =>  open,
            --TFC_OUT_6N =>  open,
            --TFC_OUT_7P =>  open,
            --TFC_OUT_7N =>  open,
            --TFC_OUT_8P =>  open,
            --TFC_OUT_8N =>  open,
            --TFC_OUT_9P =>  open,
            --TFC_OUT_9N =>  open,
            --TFC_OUT_10P =>  open,
            --TFC_OUT_10N =>  open,
            --TFC_OUT_11P =>  open,
            --TFC_OUT_11N =>  open

        );


end behavioral;

