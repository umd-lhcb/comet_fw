--------------------------------------------------------------------------------
-- Company: UNIVERSITY OF MARYLAND
--
-- File: USB_INTERFACE.vhd
-- File history: REV -
--               REV A: COMMENTED OUT THE FPGA FIFO THAT WAS NOT BEING USED FOR THE USB DATA INTERFACE
--				 REV B: ADDING ADDITIONAL ELINKS FOR A TOTAL OF 5
--				 REV C: ADDING ADDITIONAL ELINKS FOR A TOTAL OF 20
--
-- Description: THIS MODULE PROVIDES THE INTERFACE BETWEEN THE USB FT232 USB MODULE AND FPGA REGISTER BANKS.
--  THE USB MODULE READ AND WRITE OPERATIONS EACH HAVE DEDICATED 1K BYTE BUFFERS.  
-- 
--  THERE ARE 2 TYPES OF PATTERN GENERATOR BLOCKS: (1) TFC SEQUENCES (SINGLE RAM BLOCK) AND (2) ELINK SEQUENCES (UP TO 20 RAM BLOCKS--8BITS@40MHZ MAPPED TO SINGLE 320Mbps STREAMS).
--  THE STORED SEQUENCE CAN EITHER BE TRANSMITTED OR USED AS A REFERENCE FOR COMPARISON.
--  THERE ARE TWO TYPES OF INTERFACE PORTS PRESENT FOR THIS MODULE.  THE RAM BLOCKS SERVE AS ASYNCHRONOUS INTERFACES BETWEEN THE TWO CLOCKS ASYNCHRONOUS TO EACH OTHER.
--  (1) THE USB MODULE INTERFACE WHICH OPERATES SOLELY VIA THE USB MODULE 60 MHZ CLOCK SOURCE
--  (2) THE 'B' SIDE OF THE PATTERN RAM BLOCKS WHICH OPERATE VIA THE SYSTEM 40 MHZ CLOCK
--  THE RAM BLOCKS HAVE TWO 1/2'S CONTROLLED BY THE MSB ADDRESS BIT THAT IS AUTOMATICALLY TOGGLED TO ACTIVE AN UPDATED RAM BLOCK.
--  EACH OF THE SEQUENCES MUST GENERATE A PULSE FROM THE 40 MHZ CLOCK DOMAIN THAT INDICATES THE SEQUENCE HAS JUST COMPLETED.  THE SEQUENCE WILL EITHER STOP FOR SINGLE SEQUENCE MODE OR WILL 
--  RESTART AT THE BEGINNING IF CONTINUOUS MODE IS SELECTED.  THE USB INTERFACE UPDATES IMMEDIATELY FOR SINGLE MODE, BUT WAITS FOR A PULSE FROM THE 40 MHZ CLOCK DOMAIN 
--  THAT INDICATES THE SEQUENCE HAS REACHED THE END BEFORE TOGGLING THE MSB ADDRESS BIT.  EACH PATTERN GENERATOR HAS A DEDICATED MSB ADDRESS BIT SINCE THE BANKS ARE UPDATED ONE AT A TIME.
--  WARNING:  THE OP_MODE SHOULD BE USED TO DISABLE A SEQUENCE BEFORE UPDATING THE START AND STOP ADDRESSES TO ENSURE PREDICTABLE OPERATION!
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

entity USB_INTERFACE is
port    (
            CLK60MHZ            :   IN      STD_LOGIC;                      -- CLOCK FROM THE USM MODULE DERIVED FROM A 12MHZ CRYSTAL ON-BOARD THE USB MODULE PLL
            RESETB              :   IN      STD_LOGIC;                      -- ACTIVE LOW RESET--SYNCHRONOUS TO THE 60 MHZ CLOCK!
            MASTER_POR_B        :   IN      STD_LOGIC;                      -- RESET SYNCHRONOUS TO THE 160 MHZ AND 40 MHZ CLOCKS
            CLK_40MHZ_GEN       :   IN      STD_LOGIC;                      -- CLOCK SYNCHRONOUS TO THE 160MHZ CCC CLOCK FROM THE SERIALIZER

            -- USB INTERFACE SIGNALS (SYNCHRONOUS TO CLK60MHZ)
            BIDIR_USB_ADBUS     :   INOUT   STD_LOGIC_VECTOR(7 DOWNTO 0);   -- USB:  BI-DIRECTIONAL ADDRESS AND DATA BUS
            USB_OE_B            :   OUT     STD_LOGIC;                      -- USB:  ACTIVE LOW TURNS ON THE USB DATA BUS OUTPUT MODE

            P_USB_RXF_B         :   IN      STD_LOGIC;                      -- USB:  ACTIVE LOW SIGNIFIES THAT THE ON-BOARD USB FIFO HAS DATA TO BE READ (IE READ TRANSFER REQUEST)
            USB_RD_B            :   OUT     STD_LOGIC;                      -- USB:  ACTIVE LOW STATE FETCHES NEXT BYTE FROM THE FIFO ON THE NEXT CLK60MHZ CLOCK EDGE

            P_USB_TXE_B         :   IN      STD_LOGIC;                      -- USB:  ACTIVE LOW SIGNIFIES THAT THE ON-BOARD USB FIFO CAN NOW ACCEPT DATA (IE WRITE TRANSFER ENABLED)
            USB_WR_B            :   OUT     STD_LOGIC;                      -- USB:  ACTIVE LOW STATE ENABLE DATA TO BE WRITTEN TO THE FIFO ON THE NEXT CLK60MHZ CLOCK EDGE

            USB_SIWU_B          :   OUT     STD_LOGIC;                      -- USB:  ACTIVE LOW--Send Immediate / WakeUp signal (CAN BE USED TO OPTIMIZE DATA TRANSFER RATES)
                                                                            -- TIE HIGH IF NOT USED.  PULSE LOW FOR 250 NS (15 CLOCK CYCLES) TO FORCE THE FIFO TO FLUSH CONTENTS TO THE HOST

            -- EXTERNAL PATTERN GEN INTERFACES (ALL I/O HERE IS SYNCHRONOUS TO CLK_40MHZ_GEN, HOWEVER INTERNAL USB "REGISTERS" INHERENTLY OPERATE SYNCHRONOUS TO 60 MHZ!)
            -- NOTE: 'B' SUFFIXES HERE DENOTE RAM 'B' PORT I/O'S RATHER THAN ACTIVE LOW AS OFTEN USED ELSEWHERE!
            P_TFC_STRT_ADDR     :   OUT     STD_LOGIC_VECTOR(7 DOWNTO 0);   -- 40 MHZ: START ADDRESS FOR THE TFC PATTERN GENERATOR
            P_TFC_STOP_ADDR     :   OUT     STD_LOGIC_VECTOR(7 DOWNTO 0);   -- 40 MHZ: STOP ADDRESS FOR THE TFC PATTERN GENERATOR
            TFC_ADDRB           :   IN      STD_LOGIC_VECTOR(8 downto 0);   -- TFC RAM BLOCK PORT B ADDRESS
            TFC_RAM_BLKB_EN     :   IN      STD_LOGIC;                      -- TFC RAM BLOCK PORT B ACTIVE LOW RAM BLOCK ENABLE
            P_TFC_ADDR8B        :   OUT     STD_LOGIC;                      -- 8TH ADDR BIT FOR THE TFC PATT B PORT INDICATES WHICH 1/2 THE PATT GEN IS USING
            TFC_DAT_OUT         :   OUT     STD_LOGIC_VECTOR(7 DOWNTO 0);   -- TFC RAM BLOCK PORT B DATA OUT
            TFC_DAT_IN          :   IN      STD_LOGIC_VECTOR(7 DOWNTO 0);   -- TFC RAM BLOCK PORT B DATA IN
            TFC_RWB             :   IN      STD_LOGIC;                      -- TFC RAM BLOCK PORT B READ WRITE CONTROL

			-- SIGNALS COMMON TO ALL ELINKS
            P_ELINKS_STRT_ADDR  :   OUT     STD_LOGIC_VECTOR(7 DOWNTO 0);   -- START ADDRESS FOR THE ELINKS PATTERN GENERATOR
            P_ELINKS_STOP_ADDR  :   OUT     STD_LOGIC_VECTOR(7 DOWNTO 0);   -- STOP ADDRESS FOR THE ELINKS PATTERN GENERATOR
            ELINK_ADDRB      	:   IN      STD_LOGIC_VECTOR(8 downto 0);   -- ELINK_N RAM BLOCK PORT B ADDRESS
            ELINK_PATT_GEN_EN  	:   IN      STD_LOGIC;                      -- ELINK_N RAM BLOCK PORT B ACTIVE LOW RAM BLOCK ENABLE
            P_ELINK_ADDR8B     	:   OUT     STD_LOGIC;                      -- 8TH ADDR BIT FOR THE ELINK 0 PORT B INDICATES WHICH 1/2 THE PATT GEN IS USING
            ELINK_RWB          	:   IN      STD_LOGIC;                      -- ELINK_N RAM BLOCK PORT B READ WRITE CONTROL

            ELINK0_DAT_OUT      :   OUT     STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK0 RAM BLOCK PORT B DATA OUT
            ELINK0_DAT_IN       :   IN      STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK0 RAM BLOCK PORT B DATA IN

			ELINK1_DAT_OUT      :   OUT     STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK1 RAM BLOCK PORT B DATA OUT
            ELINK1_DAT_IN       :   IN      STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK1 RAM BLOCK PORT B DATA IN

			ELINK2_DAT_OUT      :   OUT     STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK2 RAM BLOCK PORT B DATA OUT
            ELINK2_DAT_IN       :   IN      STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK2 RAM BLOCK PORT B DATA IN

			ELINK3_DAT_OUT      :   OUT     STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK3 RAM BLOCK PORT B DATA OUT
            ELINK3_DAT_IN       :   IN      STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK3 RAM BLOCK PORT B DATA IN

			ELINK4_DAT_OUT      :   OUT     STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK4 RAM BLOCK PORT B DATA OUT
            ELINK4_DAT_IN       :   IN      STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK4 RAM BLOCK PORT B DATA IN

			ELINK5_DAT_OUT      :   OUT     STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK5 RAM BLOCK PORT B DATA OUT
            ELINK5_DAT_IN       :   IN      STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK5 RAM BLOCK PORT B DATA IN

			ELINK6_DAT_OUT      :   OUT     STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK6 RAM BLOCK PORT B DATA OUT
            ELINK6_DAT_IN       :   IN      STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK6 RAM BLOCK PORT B DATA IN

			ELINK7_DAT_OUT      :   OUT     STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK7 RAM BLOCK PORT B DATA OUT
            ELINK7_DAT_IN       :   IN      STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK7 RAM BLOCK PORT B DATA IN

			ELINK8_DAT_OUT      :   OUT     STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK8 RAM BLOCK PORT B DATA OUT
            ELINK8_DAT_IN       :   IN      STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK8 RAM BLOCK PORT B DATA IN

			ELINK9_DAT_OUT      :   OUT     STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK9 RAM BLOCK PORT B DATA OUT
            ELINK9_DAT_IN       :   IN      STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK9 RAM BLOCK PORT B DATA IN

			ELINK10_DAT_OUT     :   OUT     STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK10 RAM BLOCK PORT B DATA OUT
            ELINK10_DAT_IN      :   IN      STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK10 RAM BLOCK PORT B DATA IN

			ELINK11_DAT_OUT     :   OUT     STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK11 RAM BLOCK PORT B DATA OUT
            ELINK11_DAT_IN      :   IN      STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK11 RAM BLOCK PORT B DATA IN

			ELINK12_DAT_OUT     :   OUT     STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK12 RAM BLOCK PORT B DATA OUT
            ELINK12_DAT_IN      :   IN      STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK12 RAM BLOCK PORT B DATA IN

			ELINK13_DAT_OUT     :   OUT     STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK13 RAM BLOCK PORT B DATA OUT
            ELINK13_DAT_IN      :   IN      STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK13 RAM BLOCK PORT B DATA IN

			ELINK14_DAT_OUT     :   OUT     STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK14 RAM BLOCK PORT B DATA OUT
            ELINK14_DAT_IN      :   IN      STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK14 RAM BLOCK PORT B DATA IN

			ELINK15_DAT_OUT     :   OUT     STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK15 RAM BLOCK PORT B DATA OUT
            ELINK15_DAT_IN      :   IN      STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK15 RAM BLOCK PORT B DATA IN

			ELINK16_DAT_OUT     :   OUT     STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK16 RAM BLOCK PORT B DATA OUT
            ELINK16_DAT_IN      :   IN      STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK16 RAM BLOCK PORT B DATA IN

			ELINK17_DAT_OUT     :   OUT     STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK17 RAM BLOCK PORT B DATA OUT
            ELINK17_DAT_IN      :   IN      STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK17 RAM BLOCK PORT B DATA IN

			ELINK18_DAT_OUT     :   OUT     STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK18 RAM BLOCK PORT B DATA OUT
            ELINK18_DAT_IN      :   IN      STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK18 RAM BLOCK PORT B DATA IN

			ELINK19_DAT_OUT     :   OUT     STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK19 RAM BLOCK PORT B DATA OUT
            ELINK19_DAT_IN      :   IN      STD_LOGIC_VECTOR(7 DOWNTO 0);   -- ELINK19 RAM BLOCK PORT B DATA IN

            P_OP_MODE           :   OUT     STD_LOGIC_VECTOR(7 DOWNTO 0)    -- PATTERN GENERATOR OPERATING MODE

        );
end USB_INTERFACE;
architecture RTL of USB_INTERFACE is

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- DEFINE ALL CONSTANTS AND SIGNALS

    -- THESE ARE THE START AND STOP HEADER BYTES
    CONSTANT    START_BYTE          :   STD_LOGIC_VECTOR(7 DOWNTO 0):=  "10101010";     -- START PATTERN FOR THE COMMAND BLOCK INTO COMET
    CONSTANT    STOP_BYTE           :   STD_LOGIC_VECTOR(7 DOWNTO 0):=  "01010101";     -- STOP PATTERN FOR THE COMMAND BLOCK INTO COMET

    -- TRANSFER TYPES - READ = USB-->FPGA
    CONSTANT    TT_RD_NOP           :   STD_LOGIC_VECTOR(7 DOWNTO 0):=  "00000000";     -- READ:  NOP 
    CONSTANT    TT_RD_ACR           :   STD_LOGIC_VECTOR(7 DOWNTO 0):=  "00000001";     -- READ:  ALL CONTROL REGISTERS 
    CONSTANT    TT_RD_TFC_RB        :   STD_LOGIC_VECTOR(7 DOWNTO 0):=  "00000010";     -- READ:  TFC REGISTER BANK
    CONSTANT    TT_RD_ELK_RB0       :   STD_LOGIC_VECTOR(7 DOWNTO 0):=  "00100000";     -- READ:  ELINK REGISTER BANK 0 
    CONSTANT    TT_RD_ELK_RB1       :   STD_LOGIC_VECTOR(7 DOWNTO 0):=  "00100001";     -- READ:  ELINK REGISTER BANK 1 
    CONSTANT    TT_RD_ELK_RB2       :   STD_LOGIC_VECTOR(7 DOWNTO 0):=  "00100010";     -- READ:  ELINK REGISTER BANK 2 
    CONSTANT    TT_RD_ELK_RB3       :   STD_LOGIC_VECTOR(7 DOWNTO 0):=  "00100011";     -- READ:  ELINK REGISTER BANK 3 
    CONSTANT    TT_RD_ELK_RB4       :   STD_LOGIC_VECTOR(7 DOWNTO 0):=  "00100100";     -- READ:  ELINK REGISTER BANK 4 
    CONSTANT    TT_RD_ELK_RB5       :   STD_LOGIC_VECTOR(7 DOWNTO 0):=  "00100101";     -- READ:  ELINK REGISTER BANK 5 
    CONSTANT    TT_RD_ELK_RB6       :   STD_LOGIC_VECTOR(7 DOWNTO 0):=  "00100110";     -- READ:  ELINK REGISTER BANK 6 
    CONSTANT    TT_RD_ELK_RB7       :   STD_LOGIC_VECTOR(7 DOWNTO 0):=  "00100111";     -- READ:  ELINK REGISTER BANK 7 
    CONSTANT    TT_RD_ELK_RB8       :   STD_LOGIC_VECTOR(7 DOWNTO 0):=  "00101000";     -- READ:  ELINK REGISTER BANK 8 
    CONSTANT    TT_RD_ELK_RB9       :   STD_LOGIC_VECTOR(7 DOWNTO 0):=  "00101001";     -- READ:  ELINK REGISTER BANK 9 
    CONSTANT    TT_RD_ELK_RB10      :   STD_LOGIC_VECTOR(7 DOWNTO 0):=  "00101010";     -- READ:  ELINK REGISTER BANK 10 
    CONSTANT    TT_RD_ELK_RB11      :   STD_LOGIC_VECTOR(7 DOWNTO 0):=  "00101011";     -- READ:  ELINK REGISTER BANK 11 
    CONSTANT    TT_RD_ELK_RB12      :   STD_LOGIC_VECTOR(7 DOWNTO 0):=  "00101100";     -- READ:  ELINK REGISTER BANK 12 
    CONSTANT    TT_RD_ELK_RB13      :   STD_LOGIC_VECTOR(7 DOWNTO 0):=  "00101101";     -- READ:  ELINK REGISTER BANK 13 
    CONSTANT    TT_RD_ELK_RB14      :   STD_LOGIC_VECTOR(7 DOWNTO 0):=  "00101110";     -- READ:  ELINK REGISTER BANK 14 
    CONSTANT    TT_RD_ELK_RB15      :   STD_LOGIC_VECTOR(7 DOWNTO 0):=  "00101111";     -- READ:  ELINK REGISTER BANK 15 
    CONSTANT    TT_RD_ELK_RB16      :   STD_LOGIC_VECTOR(7 DOWNTO 0):=  "00110000";     -- READ:  ELINK REGISTER BANK 16 
    CONSTANT    TT_RD_ELK_RB17      :   STD_LOGIC_VECTOR(7 DOWNTO 0):=  "00110001";     -- READ:  ELINK REGISTER BANK 17 
    CONSTANT    TT_RD_ELK_RB18      :   STD_LOGIC_VECTOR(7 DOWNTO 0):=  "00110010";     -- READ:  ELINK REGISTER BANK 18 
    CONSTANT    TT_RD_ELK_RB19      :   STD_LOGIC_VECTOR(7 DOWNTO 0):=  "00110011";     -- READ:  ELINK REGISTER BANK 19 

    -- TRANSFER TYPES - WRITE = FPGA-->USB
    CONSTANT    TT_WR_ASR           :   STD_LOGIC_VECTOR(7 DOWNTO 0):=  "10000000";     -- WRITE:  ALL STATUS REGISTERS 
    CONSTANT    TT_WR_ACR           :   STD_LOGIC_VECTOR(7 DOWNTO 0):=  "10000001";     -- WRITE:  ALL CONTROL REGISTERS 
    CONSTANT    TT_WR_TFC_RB        :   STD_LOGIC_VECTOR(7 DOWNTO 0):=  "10000010";     -- WRITE:  TFC REGISTER BANK
    CONSTANT    TT_WR_ELK_RB0       :   STD_LOGIC_VECTOR(7 DOWNTO 0):=  "10100000";     -- WRITE:  ELINK REGISTER BANK 0 
    CONSTANT    TT_WR_ELK_RB1       :   STD_LOGIC_VECTOR(7 DOWNTO 0):=  "10100001";     -- WRITE:  ELINK REGISTER BANK 1 
    CONSTANT    TT_WR_ELK_RB2       :   STD_LOGIC_VECTOR(7 DOWNTO 0):=  "10100010";     -- WRITE:  ELINK REGISTER BANK 2 
    CONSTANT    TT_WR_ELK_RB3       :   STD_LOGIC_VECTOR(7 DOWNTO 0):=  "10100011";     -- WRITE:  ELINK REGISTER BANK 3 
    CONSTANT    TT_WR_ELK_RB4       :   STD_LOGIC_VECTOR(7 DOWNTO 0):=  "10100100";     -- WRITE:  ELINK REGISTER BANK 4 
    CONSTANT    TT_WR_ELK_RB5       :   STD_LOGIC_VECTOR(7 DOWNTO 0):=  "10100101";     -- WRITE:  ELINK REGISTER BANK 5 
    CONSTANT    TT_WR_ELK_RB6       :   STD_LOGIC_VECTOR(7 DOWNTO 0):=  "10100110";     -- WRITE:  ELINK REGISTER BANK 6 
    CONSTANT    TT_WR_ELK_RB7       :   STD_LOGIC_VECTOR(7 DOWNTO 0):=  "10100111";     -- WRITE:  ELINK REGISTER BANK 7 
    CONSTANT    TT_WR_ELK_RB8       :   STD_LOGIC_VECTOR(7 DOWNTO 0):=  "10101000";     -- WRITE:  ELINK REGISTER BANK 8 
    CONSTANT    TT_WR_ELK_RB9       :   STD_LOGIC_VECTOR(7 DOWNTO 0):=  "10101001";     -- WRITE:  ELINK REGISTER BANK 9 
    CONSTANT    TT_WR_ELK_RB10      :   STD_LOGIC_VECTOR(7 DOWNTO 0):=  "10101010";     -- WRITE:  ELINK REGISTER BANK 10 
    CONSTANT    TT_WR_ELK_RB11      :   STD_LOGIC_VECTOR(7 DOWNTO 0):=  "10101011";     -- WRITE:  ELINK REGISTER BANK 11 
    CONSTANT    TT_WR_ELK_RB12      :   STD_LOGIC_VECTOR(7 DOWNTO 0):=  "10101100";     -- WRITE:  ELINK REGISTER BANK 12 
    CONSTANT    TT_WR_ELK_RB13      :   STD_LOGIC_VECTOR(7 DOWNTO 0):=  "10101101";     -- WRITE:  ELINK REGISTER BANK 13 
    CONSTANT    TT_WR_ELK_RB14      :   STD_LOGIC_VECTOR(7 DOWNTO 0):=  "10101110";     -- WRITE:  ELINK REGISTER BANK 14 
    CONSTANT    TT_WR_ELK_RB15      :   STD_LOGIC_VECTOR(7 DOWNTO 0):=  "10101111";     -- WRITE:  ELINK REGISTER BANK 15 
    CONSTANT    TT_WR_ELK_RB16      :   STD_LOGIC_VECTOR(7 DOWNTO 0):=  "10110000";     -- WRITE:  ELINK REGISTER BANK 16 
    CONSTANT    TT_WR_ELK_RB17      :   STD_LOGIC_VECTOR(7 DOWNTO 0):=  "10110001";     -- WRITE:  ELINK REGISTER BANK 17 
    CONSTANT    TT_WR_ELK_RB18      :   STD_LOGIC_VECTOR(7 DOWNTO 0):=  "10110010";     -- WRITE:  ELINK REGISTER BANK 18 
    CONSTANT    TT_WR_ELK_RB19      :   STD_LOGIC_VECTOR(7 DOWNTO 0):=  "10110011";     -- WRITE:  ELINK REGISTER BANK 19 

-- DEFINE STATES FOR THE STATE MACHINE THAT CONTROL TRANSFER OF DATA BETWEEN THE USB INTERFACE AND COMET FPGA
    TYPE REG_SM_STATES IS  ( 
                            INIT, FILL_RD_PIPELN, CHK_FOR_HEADER, ASSERT_RD, DEC_XFER_TYPE, TT_WAIT,
                            STORE_ALL_REG, REQ_TFC_STRT_ADDR, REQ_TFC_STOP_ADDR, REQ_ELINKS_STRT_ADDR, REQ_ELINKS_STOP_ADDR,
                            REQ_CHKSUM, REQ_STP_HDR, 
                            SWAP_REG_VALS, SWAP_TFC_VALS, SWAP_0_ELINK_VALS, STORE_RAM, STORE_RAM1, STORE_RAM2, FPGA_RD_HOLD,
                            TX_TO_HOST, TX_TO_HOST1, SEND_ACR, SEND_ACR1, SEND_ACR2, SEND_ACR3, SEND_ACR4, SEND_ACR5, SEND_ACR6, SEND_ACR7, SEND_ACR8, SEND_ACR9, SEND_ACR10,
                            SEND_ACR11, SEND_ACR_HOLD,
                            SEND_RB, SEND_RB1, SEND_RB2, SEND_RB3,
                            TX_TO_HOST_FIN, TX_TO_HOST_FIN1, TX_TO_HOST_FIN2, TX_TO_HOST_FIN3, TX_EMPTY_PIPE, TX_EMPTY_PIPE1, TX_RAM_HOLD
                        );
    SIGNAL N_REG_STATE, REG_STATE       :   REG_SM_STATES;

-- INTERNAL USB INTERFACE SIGNALS
    SIGNAL USB_RXF_B                    :   STD_LOGIC;                                  -- INTERNAL RE-CLOCKED VERSION
    SIGNAL USB_TXE_B                    :   STD_LOGIC;                                  -- INTERNAL RE-CLOCKED VERSION

    SIGNAL N_USB_RD_BI, USB_RD_BI       :   STD_LOGIC;                                  -- INTERNAL VERSIONS
    SIGNAL N_USB_WR_BI, USB_WR_BI       :   STD_LOGIC;
    SIGNAL N_USB_TRIEN_B, USB_TRIEN_B   :   STD_LOGIC;                                  -- TRI-STATE ENABLE FOR THE FPGA USB DATA BUS DRIVER (FPGA 3STATE DRIVE ENABLE TURN ON IS SLOW)
    SIGNAL N_USB_OE_BI, USB_OE_BI       :   STD_LOGIC;

    SIGNAL  N_SI_CNT, SI_CNT            :   STD_LOGIC_VECTOR(3 DOWNTO 0);               -- COUNTER USED TO PULSE THE USB_SIWU_B SIGNAL
    SIGNAL  N_USB_SIWU_BI, USB_SIWU_BI  :   STD_LOGIC;                                  -- ACTIVE LOW USB SEND-IMMEDIATE FUNCTION (FORCES USB MODULE FIFO TO EMPTY DATA TO HOST)

    SIGNAL N_RD_USB_ADBUS, RD_USB_ADBUS :   STD_LOGIC_VECTOR(7 DOWNTO 0);               -- INTERNAL READ BUS DERIVED FROM THE BIDIR BUFFER
    SIGNAL N_WR_USB_ADBUS, WR_USB_ADBUS :   STD_LOGIC_VECTOR(7 DOWNTO 0);               -- INTERNAL WRITE BUS DERIVED FROM THE BIDIR BUFFER

    SIGNAL N_REG_ADDR, REG_ADDR         :   STD_LOGIC_VECTOR(8 DOWNTO 0);               -- ADDRESS POINTER FOR REGISTERS

    SIGNAL N_WR_XFER_TYPE, WR_XFER_TYPE :   STD_LOGIC_VECTOR(7 DOWNTO 0);               -- SPECIFIES THE DATA TO BE SENT BACK VIA USB WRITE OPS (AKA TRANSFER TYPE)

-- GENERIC RAM BANK INTERFACE SIGNALS TO CREATE A COMMON MUX AXCESS BETWEEN THE USB AND VARIOUS RAM BLOCKS (IE THE REG_STATE STATE MACHINE JUST ACCESSES THE GENRIC INTERFACE
-- RATHER THAN REPEAT THE SAME INTERFACE DESIGN FOR EACH RAM BLOCK.
    SIGNAL X_BLKA                       :   STD_LOGIC;                                  -- GENERIC RAM BLOCK, PORT A, ACTIVE LOW ENABLE
    SIGNAL X_RWA                        :   STD_LOGIC;                                  -- GENERIC RAM BLOCK, PORT A, ACTIVE LOW READ/WRITE CONTROL (LOGIC 1/0)
    SIGNAL X_DINA                       :   std_logic_vector(8 downto 0);               -- GENERIC RAM BLOCK, PORT A, DATA INPUT BUS
    SIGNAL X_ADDRA                      :   std_logic_vector(8 downto 0);               -- GENERIC RAM BLOCK, PORT A: ADDRESS BUS

	-- STATES FOR THE RAM BLOCK MUX OPERATING BETWEEN THE USB REG_STATES SM AND THE RAM BLOCKS
    TYPE MUX_STATES IS  ( INACTIVE, TFC, ELINK0, ELINK1, ELINK2, ELINK3, ELINK4, ELINK5, ELINK6, ELINK7, ELINK8, ELINK9, ELINK10, ELINK11, ELINK12, ELINK13, ELINK14, ELINK15, ELINK16, ELINK17, ELINK18, ELINK19 ); 
    SIGNAL N_SM_BANK_SEL, SM_BANK_SEL   :   MUX_STATES;                                 -- MUX_SM STATE MACHINE POINTER SET BY THE REG_SM STATE MACHINE

	SIGNAL N_ELK_N_ACTIVE, ELK_N_ACTIVE	:	STD_LOGIC;									-- IS SET TO '1' WHEN ONE OF THE 20 ELINK BLOCKS ARE BEING ACCESSED VIA USB TO THE 'A' PORTS 
	
-- TFC PATTERN BLOCK RAM WITH 'A' AND 'B' PORTS
    SIGNAL N_TFC_DINA, TFC_DINA         :   std_logic_vector(8 downto 0);               -- PORT A: DATA INPUT BUS
    SIGNAL TFC_DOUTA                    :   std_logic_vector(8 downto 0);               -- PORT A: DATA OUTPUT BUS
    SIGNAL TFC_DINB                     :   std_logic_vector(8 downto 0);               -- PORT B: DATA INPUT BUS
    SIGNAL TFC_DOUTB                    :   std_logic_vector(8 downto 0);               -- PORT B: DATA OUTPUT BUS
    SIGNAL N_TFC_ADDRA, TFC_ADDRA       :   std_logic_vector(8 downto 0);               -- PORT A: ADDRESS
    SIGNAL N_TFC_RWA,TFC_RWA            :   std_logic;                                  -- PORT A: READ/WRITE ENABLE
    SIGNAL N_TFC_BLKA,TFC_BLKA          :   std_logic;                                  -- PORT A: ACTIVE LOW RAM BLOCK ENABLE

-- ELINK BLOCK RAMS WITH 'A' AND 'B' PORTS
	TYPE   ELINK_BUS_SIGS 		IS ARRAY (19 DOWNTO 0) OF STD_LOGIC_VECTOR (8 DOWNTO 0);
	TYPE   ELINK_SIGNALS		IS ARRAY (19 DOWNTO 0) OF STD_LOGIC;

	SIGNAL N_ELINK_DINA, ELINK_DINA 	:	ELINK_BUS_SIGS;								-- PORT A: DATA INPUT BUS
    SIGNAL ELINK_DOUTA               	:   ELINK_BUS_SIGS;               				-- PORT A: DATA OUTPUT BUS
	
    SIGNAL N_ELINK_ADDRA, ELINK_ADDRA 	:   ELINK_BUS_SIGS;               				-- PORT A: ADDRESS
    SIGNAL N_ELINK_RWA, ELINK_RWA     	:   ELINK_SIGNALS;                              -- PORT A: READ/WRITE ENABLE
    SIGNAL N_ELINK_BLKA, ELINK_BLKA   	:   ELINK_SIGNALS;                              -- PORT A: ACTIVE LOW RAM BLOCK ENABLE

    SIGNAL ELINK_DINB                  	:   ELINK_BUS_SIGS;               				-- PORT B: DATA INPUT BUS
    SIGNAL ELINK_DOUTB                 	:   ELINK_BUS_SIGS;               				-- PORT B: DATA OUTPUT BUS

    SIGNAL N_USB_RD_DAT, USB_RD_DAT     :   STD_LOGIC_VECTOR(7 DOWNTO 0);               -- CONTAINS THE LAST READ VALUE FROM THE USB BUS (IE CREATE A PIPELINE DELAY OF 1 CLOCK CYCLE)

    SIGNAL N_RD_XFER_TYPE, RD_XFER_TYPE :   STD_LOGIC_VECTOR(7 DOWNTO 0);               -- STORED VERSION OF THE USB TRANSFER TYPE FOR FPGA MASTER READ OPs(NOP, ALL REGISTER, TFC BLOCK, ELINK BLOCKS)

-- THE TEMPORARY REGISTER COPY GETS TRANSFERRED TO THE FINAL REGISTER ONCE THE CHKSUM IS VERIFIED OK
    SIGNAL N_OP_MODE_T, OP_MODE_T       :   STD_LOGIC_VECTOR(7 DOWNTO 0);               -- CONTAINS THE OPERATING MODE BYTE (TEMP VERSION)
    SIGNAL N_OP_MODE, OP_MODE           :   STD_LOGIC_VECTOR(7 DOWNTO 0);               -- CONTAINS THE OPERATING MODE BYTE

-- POINTER FOR UPPER OR LOWER RAM BLOCK
    SIGNAL N_TFC_ADDR8B, TFC_ADDR8B     :   STD_LOGIC := '0';                       	-- 8TH ADDR BIT FOR THE TFC PATT B PORT INDICATES WHICH 1/2 THE PATT GEN IS USING
    SIGNAL N_ELINK_ADDR8B, ELINK_ADDR8B :   STD_LOGIC := '0';                       	-- 8TH ADDR BIT FOR THE ELINK 0 PORT B INDICATES WHICH 1/2 THE PATT GEN IS USING

-- EACH PATTERN HAS SEPARATE POINTERS FOR THE 'A' AND 'B' SIDES OF THE RAM BLOCK
-- THE TEMPORARY REGISTER COPIES GET TRANSFERRED TO THE FINAL REGISTERS ONCE THE CHKSUM IS VERIFIED OK
    SIGNAL N_TFC_STRT_ADDR_T, TFC_STRT_ADDR_T           :   STD_LOGIC_VECTOR(7 DOWNTO 0);   -- CONTAINS THE START ADDRESS FOR THE TFC BLOCK (TEMP VERSION)
    SIGNAL N_TFC_STOP_ADDR_T, TFC_STOP_ADDR_T           :   STD_LOGIC_VECTOR(7 DOWNTO 0);   -- CONTAINS THE STOP ADDRESS FOR THE TFC BLOCK (TEMP VERSION)
    SIGNAL N_ELINKS_STRT_ADDR_T, ELINKS_STRT_ADDR_T     :   STD_LOGIC_VECTOR(7 DOWNTO 0);   -- CONTAINS THE START ADDRESS FOR THE ELINK BLOCKS (TEMP VERSION)
    SIGNAL N_ELINKS_STOP_ADDR_T, ELINKS_STOP_ADDR_T     :   STD_LOGIC_VECTOR(7 DOWNTO 0);   -- CONTAINS THE STOP ADDRESS FOR THE ELINK BLOCKS (TEMP VERSION)
    
    SIGNAL N_TFC_STRT_ADDR, TFC_STRT_ADDR               :   STD_LOGIC_VECTOR(7 DOWNTO 0);   -- CONTAINS THE START ADDRESS FOR THE TFC BLOCK (REG VERSION)
    SIGNAL N_TFC_STOP_ADDR, TFC_STOP_ADDR               :   STD_LOGIC_VECTOR(7 DOWNTO 0);   -- CONTAINS THE STOP ADDRESS FOR THE TFC BLOCK (REG VERSION)
    SIGNAL N_ELINKS_STRT_ADDR, ELINKS_STRT_ADDR         :   STD_LOGIC_VECTOR(7 DOWNTO 0);   -- CONTAINS THE START ADDRESS FOR THE ELINK BLOCKS (REG VERSION)
    SIGNAL N_ELINKS_STOP_ADDR, ELINKS_STOP_ADDR         :   STD_LOGIC_VECTOR(7 DOWNTO 0);   -- CONTAINS THE STOP ADDRESS FOR THE ELINK BLOCKS (REG VERSION)

-- THESE FLAGS ARE USED BY THE WDT TO MAKE SURE THE INTERFACE DOES NOT GET HUNG INDEFINITELY!
    SIGNAL N_USB_RD_ACTIVE, USB_RD_ACTIVE               : STD_LOGIC;                        -- INDICATES THAT A READ OP FROM usb TO fpga IS IN-PROGRESS.
    SIGNAL N_USB_WR_ACTIVE, USB_WR_ACTIVE               : STD_LOGIC;                        -- INDICATES THAT A WRITE OP FROM FPGA TO USB IS IN-PROGRESS.

    SIGNAL N_CHKSUM, CHKSUM                             : STD_LOGIC_VECTOR(7 DOWNTO 0);     -- 8-BIT CHKSUM FOR USB COMM

-- THESE SIGNALS ARE USED FOR CLOCK DOMAIN CROSSING BETWEEN THE 60 MHZ AND 40 MHZ DOMAINS
    SIGNAL  TFC_STRT_ADDR_40MVAL                        : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL  TFC_STOP_ADDR_40MVAL                        : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL  ELINKS_STRT_ADDR_40MVAL                     : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL  ELINKS_STOP_ADDR_40MVAL                     : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL  OP_MODE_40MVAL                              : STD_LOGIC_VECTOR(7 DOWNTO 0);

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- DEFINE COMPONENTS
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- SRAM BLOCK DEFINITION
-- A Dual Port RAM has read and write access on both ports
-- while a Two Port RAM allows write access on one port and read access on the other port.
--      Block Enables (BLKA and BLKB)
--          Asserting BLKA when RWA is high reads the RAM at the address (ADDRA) onto the data port (DOUTA).
--          Asserting BLKA when RWA is low writes the data (DINA) into the RAM at the address (ADDRA).
--          Asserting BLKB when RWB is high reads the RAM at the address (ADDRB) onto the data port (DOUTB).
--          Asserting BLKB when RWB is low writes the data (DINB) into the RAM at the address (ADDRB).
--      Read/Write Mode Control (RWA and RWB)
--          Use this signal to switch between read or write mode for a given port. LOW = WRITE, HIGH = READ.
-- MSB IN RAM IS UNUSED PLACEHOLDER FOR NOW
-- RAM IS USED AS 256 WORD BLOCKS TO STORE TFC AND ELINK PATTERN DATA.
-- THERE ARE TWO ACTIVE COPIES OF THE RAM BLOCKS THAT ARE SELECTED BY THE MSB ADDRESS, ADDR8.
-- THE ADDR8 BIT ON THE PORT B SIDE IS TOGGLED AFTER A SUCCESSFUL PACKET UPDATE (EG HEADER AND CHECKSUMS ALL ACCEPTABLE)
-- THEREFORE, READING THE BLOCK VIA USB REQUIRES THAT THE ADDRB8 BIT BE READ TO GET TO THE COPY CURRENTLY IN USE
--   !!!USE ADDR8B TRUE TO TRANSFER FROM THE FPGA TO THE USB INTERFACE ALL THE DATA CURRENTLY IN USE BY THE PATTERN GENERATE FUNCTION
--   !!!USE ADDR8B INVERTED TO LOAD NEW DATA FROM THE USB INTERFACE INTO THE RAM BLOCK.  
--      THE PATTERN GENERATOR WILL TOGGLE ADDR8B AT THE START OF THE NEXT PATTERN CYCLE IF THE PACKET IS ACCEPTED.
--      THIS APPROACH ALLOWS SIMULTANEOUS COPIES OF RAM FOR (1) UPDATE AND VALIDATION BEFORE USE AND (2) PATTERN GENERATOR USE
-- 'A' PORT INTERFACE ASSIGNED TO USB.  
-- 'B' PORT INTERFACE ASSIGNED TO PATTERN GENERATOR.
-- NOTE---THERE ARE PIPELINE DELAYS FOR ALL DATA OUTPUT PORTS!!!!!
    COMPONENT DPRT_512X9_SRAM
        port( 
              DINA          : in    std_logic_vector(8 downto 0);           -- PORT A: DATA INPUT BUS
              DOUTA         : out   std_logic_vector(8 downto 0);           -- PORT A: DATA OUTPUT BUS
              DINB          : in    std_logic_vector(8 downto 0);           -- PORT B: DATA INPUT BUS
              DOUTB         : out   std_logic_vector(8 downto 0);           -- PORT B: DATA OUTPUT BUS
              ADDRA         : in    std_logic_vector(8 downto 0);           -- PORT A: ADDRESS
              ADDRB         : in    std_logic_vector(8 downto 0);           -- PORT B: ADDRESS
              RWA           : in    std_logic;                              -- PORT A: READ/WRITE ENABLE
              RWB           : in    std_logic;                              -- PORT B: READ/WRITE ENABLE
              BLKA          : in    std_logic;                              -- PORT A: ACTIVE LOW RAM BLOCK ENABLE
              BLKB          : in    std_logic;                              -- PORT B: ACTIVE LOW RAM BLOCK ENABLE
              CLKA          : in    std_logic;                              -- PORT A: CLOCK
              CLKB          : in    std_logic;                              -- PORT B: CLOCK
              RESET         : in    std_logic                               -- ACTIVE LOW
            );
    END COMPONENT;


-- 8 BIT WIDE BIDIR LVTTL BUFFER
    COMPONENT BIDIR_LVTTL is
        port( 
                Data    : in    std_logic_vector(7 downto 0);
                Y       : out   std_logic_vector(7 downto 0);
                Trien   : in    std_logic;
                PAD     : inout std_logic_vector(7 downto 0) := (others => 'Z')
            );
    END COMPONENT;

-- REGISTER BYTE CLOCK DOMAIN CROSS FROM 60 MHZ TO 40 MHZ
    COMPONENT CLK60M_TO_40M is
        port (  
                CLK40M_GEN          :   IN  STD_LOGIC;                              -- 40 MHZ CLOCK WHERE RISE EDGE IS DELAYED ~2.5NS FROM THE 160 MHZ RISE EDGE
                MASTER_POR_B        :   IN  STD_LOGIC;                              -- RESET SYNCHRONOUS TO THE 160 MHZ AND 40 MHZ CLOCKS

                BYTE60M_IN          :   IN  STD_LOGIC_VECTOR(7 DOWNTO 0);           -- INPUT BYTE ORIGINATING FROM THE 60 MHZ DOMAIN
                BYTE40M_OUT         :   OUT STD_LOGIC_VECTOR(7 DOWNTO 0)            -- OUTPUT REGISTER BYTE SYNCHRONIZED TO THE 40 MHZ DOMAIN
            );
    END COMPONENT;

BEGIN

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- INSTANTIATE THE DUAL PORT RAMS
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    TFC_DINB        	<=  "0" & TFC_DAT_IN;

    ELINK_DINB(0)     	<=  "0" & ELINK0_DAT_IN;
    ELINK_DINB(1)     	<=  "0" & ELINK1_DAT_IN;
    ELINK_DINB(2)     	<=  "0" & ELINK2_DAT_IN;
    ELINK_DINB(3)     	<=  "0" & ELINK3_DAT_IN;
    ELINK_DINB(4)     	<=  "0" & ELINK4_DAT_IN;
    ELINK_DINB(5)     	<=  "0" & ELINK5_DAT_IN;
    ELINK_DINB(6)     	<=  "0" & ELINK6_DAT_IN;
    ELINK_DINB(7)     	<=  "0" & ELINK7_DAT_IN;
    ELINK_DINB(8)     	<=  "0" & ELINK8_DAT_IN;
    ELINK_DINB(9)     	<=  "0" & ELINK9_DAT_IN;
    ELINK_DINB(10)     	<=  "0" & ELINK10_DAT_IN;
    ELINK_DINB(11)     	<=  "0" & ELINK11_DAT_IN;
    ELINK_DINB(12)     	<=  "0" & ELINK12_DAT_IN;
    ELINK_DINB(13)     	<=  "0" & ELINK13_DAT_IN;
    ELINK_DINB(14)     	<=  "0" & ELINK14_DAT_IN;
    ELINK_DINB(15)     	<=  "0" & ELINK15_DAT_IN;
    ELINK_DINB(16)     	<=  "0" & ELINK16_DAT_IN;
    ELINK_DINB(17)     	<=  "0" & ELINK17_DAT_IN;
    ELINK_DINB(18)     	<=  "0" & ELINK18_DAT_IN;
    ELINK_DINB(19)     	<=  "0" & ELINK19_DAT_IN;

-- PATTERN FOR TFC WITH PORTS 'A' AND 'B'
-- 
U0_PATT_TFC_BLK:DPRT_512X9_SRAM
    PORT MAP( 
              DINA          =>  TFC_DINA,
              DOUTA         =>  TFC_DOUTA,
              DINB          =>  TFC_DINB,
              DOUTB         =>  TFC_DOUTB,
              ADDRA         =>  TFC_ADDRA,
              ADDRB         =>  TFC_ADDRB,
              RWA           =>  TFC_RWA,
              RWB           =>  TFC_RWB,
              BLKA          =>  TFC_BLKA,
              BLKB          =>  TFC_RAM_BLKB_EN,                    -- PORT B ENABLE
              CLKA          =>  CLK60MHZ,                           -- A PORT IS FOR THE USB INTERFACE
              CLKB          =>  CLK_40MHZ_GEN,                      -- B PORT IS FOR THE PATTERN GENERATOR USE
              RESET         =>  RESETB
            );

-- U100 IS THE FIRST OF 20 MAX RAM BLOCKS FOR THE ELINK PATTERN GENERATOR
-- USING UNIQUE REGISTERS FOR EACH ELINK RAM BANK TO FACILITATE TIMING CLOSURE
-- 
U100_PATT_ELINK_BLK:DPRT_512X9_SRAM									-- ELINK0 RAM BLOCK
   PORT MAP ( 
              DINA          =>  ELINK_DINA(0),
              DOUTA         =>  ELINK_DOUTA(0),
              ADDRA         =>  ELINK_ADDRA(0),
              RWA           =>  ELINK_RWA(0),
              BLKA          =>  ELINK_BLKA(0),
              CLKA          =>  CLK60MHZ,                           -- A PORT IS FOR THE USB INTERFACE

              DINB          =>  ELINK_DINB(0),
              DOUTB         =>  ELINK_DOUTB(0),
              ADDRB         =>  ELINK_ADDRB,
              RWB           =>  ELINK_RWB,
              BLKB          =>  ELINK_PATT_GEN_EN,
              CLKB          =>  CLK_40MHZ_GEN,                      -- B PORT IS FOR THE PATTERN GENERATOR USE

              RESET         =>  RESETB								-- ACTIVE LOW RESET FOR THE RAM BLOCK (IE NOT JUST PORT B)
            );

U101_PATT_ELINK_BLK:DPRT_512X9_SRAM									-- ELINK1 RAM BLOCK
   PORT MAP ( 
              DINA          =>  ELINK_DINA(1),
              DOUTA         =>  ELINK_DOUTA(1),
              ADDRA         =>  ELINK_ADDRA(1),
              RWA           =>  ELINK_RWA(1),
              BLKA          =>  ELINK_BLKA(1),
              CLKA          =>  CLK60MHZ,                           -- A PORT IS FOR THE USB INTERFACE

              DINB          =>  ELINK_DINB(1),
              DOUTB         =>  ELINK_DOUTB(1),
              ADDRB         =>  ELINK_ADDRB,
              RWB           =>  ELINK_RWB,
              BLKB          =>  ELINK_PATT_GEN_EN,
              CLKB          =>  CLK_40MHZ_GEN,                      -- B PORT IS FOR THE PATTERN GENERATOR USE

              RESET         =>  RESETB								-- ACTIVE LOW RESET FOR THE RAM BLOCK (IE NOT JUST PORT B)
            );

U102_PATT_ELINK_BLK:DPRT_512X9_SRAM									-- ELINK1 RAM BLOCK
   PORT MAP ( 
              DINA          =>  ELINK_DINA(2),
              DOUTA         =>  ELINK_DOUTA(2),
              ADDRA         =>  ELINK_ADDRA(2),
              RWA           =>  ELINK_RWA(2),
              BLKA          =>  ELINK_BLKA(2),
              CLKA          =>  CLK60MHZ,                           -- A PORT IS FOR THE USB INTERFACE

              DINB          =>  ELINK_DINB(2),
              DOUTB         =>  ELINK_DOUTB(2),
              ADDRB         =>  ELINK_ADDRB,
              RWB           =>  ELINK_RWB,
              BLKB          =>  ELINK_PATT_GEN_EN,
              CLKB          =>  CLK_40MHZ_GEN,                      -- B PORT IS FOR THE PATTERN GENERATOR USE

              RESET         =>  RESETB								-- ACTIVE LOW RESET FOR THE RAM BLOCK (IE NOT JUST PORT B)
            );

U103_PATT_ELINK_BLK:DPRT_512X9_SRAM									-- ELINK1 RAM BLOCK
   PORT MAP ( 
              DINA          =>  ELINK_DINA(3),
              DOUTA         =>  ELINK_DOUTA(3),
              ADDRA         =>  ELINK_ADDRA(3),
              RWA           =>  ELINK_RWA(3),
              BLKA          =>  ELINK_BLKA(3),
              CLKA          =>  CLK60MHZ,                           -- A PORT IS FOR THE USB INTERFACE

              DINB          =>  ELINK_DINB(3),
              DOUTB         =>  ELINK_DOUTB(3),
              ADDRB         =>  ELINK_ADDRB,
              RWB           =>  ELINK_RWB,
              BLKB          =>  ELINK_PATT_GEN_EN,
              CLKB          =>  CLK_40MHZ_GEN,                      -- B PORT IS FOR THE PATTERN GENERATOR USE

              RESET         =>  RESETB								-- ACTIVE LOW RESET FOR THE RAM BLOCK (IE NOT JUST PORT B)
            );

U104_PATT_ELINK_BLK:DPRT_512X9_SRAM									-- ELINK1 RAM BLOCK
   PORT MAP ( 
              DINA          =>  ELINK_DINA(4),
              DOUTA         =>  ELINK_DOUTA(4),
              ADDRA         =>  ELINK_ADDRA(4),
              RWA           =>  ELINK_RWA(4),
              BLKA          =>  ELINK_BLKA(4),
              CLKA          =>  CLK60MHZ,                           -- A PORT IS FOR THE USB INTERFACE

              DINB          =>  ELINK_DINB(4),
              DOUTB         =>  ELINK_DOUTB(4),
              ADDRB         =>  ELINK_ADDRB,
              RWB           =>  ELINK_RWB,
              BLKB          =>  ELINK_PATT_GEN_EN,
              CLKB          =>  CLK_40MHZ_GEN,                      -- B PORT IS FOR THE PATTERN GENERATOR USE

              RESET         =>  RESETB								-- ACTIVE LOW RESET FOR THE RAM BLOCK (IE NOT JUST PORT B)
            );

U105_PATT_ELINK_BLK:DPRT_512X9_SRAM									-- ELINK1 RAM BLOCK
   PORT MAP ( 
              DINA          =>  ELINK_DINA(5),
              DOUTA         =>  ELINK_DOUTA(5),
              ADDRA         =>  ELINK_ADDRA(5),
              RWA           =>  ELINK_RWA(5),
              BLKA          =>  ELINK_BLKA(5),
              CLKA          =>  CLK60MHZ,                           -- A PORT IS FOR THE USB INTERFACE

              DINB          =>  ELINK_DINB(5),
              DOUTB         =>  ELINK_DOUTB(5),
              ADDRB         =>  ELINK_ADDRB,
              RWB           =>  ELINK_RWB,
              BLKB          =>  ELINK_PATT_GEN_EN,
              CLKB          =>  CLK_40MHZ_GEN,                      -- B PORT IS FOR THE PATTERN GENERATOR USE

              RESET         =>  RESETB								-- ACTIVE LOW RESET FOR THE RAM BLOCK (IE NOT JUST PORT B)
            );

U106_PATT_ELINK_BLK:DPRT_512X9_SRAM									-- ELINK1 RAM BLOCK
   PORT MAP ( 
              DINA          =>  ELINK_DINA(6),
              DOUTA         =>  ELINK_DOUTA(6),
              ADDRA         =>  ELINK_ADDRA(6),
              RWA           =>  ELINK_RWA(6),
              BLKA          =>  ELINK_BLKA(6),
              CLKA          =>  CLK60MHZ,                           -- A PORT IS FOR THE USB INTERFACE

              DINB          =>  ELINK_DINB(6),
              DOUTB         =>  ELINK_DOUTB(6),
              ADDRB         =>  ELINK_ADDRB,
              RWB           =>  ELINK_RWB,
              BLKB          =>  ELINK_PATT_GEN_EN,
              CLKB          =>  CLK_40MHZ_GEN,                      -- B PORT IS FOR THE PATTERN GENERATOR USE

              RESET         =>  RESETB								-- ACTIVE LOW RESET FOR THE RAM BLOCK (IE NOT JUST PORT B)
            );

U107_PATT_ELINK_BLK:DPRT_512X9_SRAM									-- ELINK1 RAM BLOCK
   PORT MAP ( 
              DINA          =>  ELINK_DINA(7),
              DOUTA         =>  ELINK_DOUTA(7),
              ADDRA         =>  ELINK_ADDRA(7),
              RWA           =>  ELINK_RWA(7),
              BLKA          =>  ELINK_BLKA(7),
              CLKA          =>  CLK60MHZ,                           -- A PORT IS FOR THE USB INTERFACE

              DINB          =>  ELINK_DINB(7),
              DOUTB         =>  ELINK_DOUTB(7),
              ADDRB         =>  ELINK_ADDRB,
              RWB           =>  ELINK_RWB,
              BLKB          =>  ELINK_PATT_GEN_EN,
              CLKB          =>  CLK_40MHZ_GEN,                      -- B PORT IS FOR THE PATTERN GENERATOR USE

              RESET         =>  RESETB								-- ACTIVE LOW RESET FOR THE RAM BLOCK (IE NOT JUST PORT B)
            );

U108_PATT_ELINK_BLK:DPRT_512X9_SRAM									-- ELINK1 RAM BLOCK
   PORT MAP ( 
              DINA          =>  ELINK_DINA(8),
              DOUTA         =>  ELINK_DOUTA(8),
              ADDRA         =>  ELINK_ADDRA(8),
              RWA           =>  ELINK_RWA(8),
              BLKA          =>  ELINK_BLKA(8),
              CLKA          =>  CLK60MHZ,                           -- A PORT IS FOR THE USB INTERFACE

              DINB          =>  ELINK_DINB(8),
              DOUTB         =>  ELINK_DOUTB(8),
              ADDRB         =>  ELINK_ADDRB,
              RWB           =>  ELINK_RWB,
              BLKB          =>  ELINK_PATT_GEN_EN,
              CLKB          =>  CLK_40MHZ_GEN,                      -- B PORT IS FOR THE PATTERN GENERATOR USE

              RESET         =>  RESETB								-- ACTIVE LOW RESET FOR THE RAM BLOCK (IE NOT JUST PORT B)
            );

U109_PATT_ELINK_BLK:DPRT_512X9_SRAM									-- ELINK1 RAM BLOCK
   PORT MAP ( 
              DINA          =>  ELINK_DINA(9),
              DOUTA         =>  ELINK_DOUTA(9),
              ADDRA         =>  ELINK_ADDRA(9),
              RWA           =>  ELINK_RWA(9),
              BLKA          =>  ELINK_BLKA(9),
              CLKA          =>  CLK60MHZ,                           -- A PORT IS FOR THE USB INTERFACE

              DINB          =>  ELINK_DINB(9),
              DOUTB         =>  ELINK_DOUTB(9),
              ADDRB         =>  ELINK_ADDRB,
              RWB           =>  ELINK_RWB,
              BLKB          =>  ELINK_PATT_GEN_EN,
              CLKB          =>  CLK_40MHZ_GEN,                      -- B PORT IS FOR THE PATTERN GENERATOR USE

              RESET         =>  RESETB								-- ACTIVE LOW RESET FOR THE RAM BLOCK (IE NOT JUST PORT B)
            );

U110_PATT_ELINK_BLK:DPRT_512X9_SRAM									-- ELINK1 RAM BLOCK
   PORT MAP ( 
              DINA          =>  ELINK_DINA(10),
              DOUTA         =>  ELINK_DOUTA(10),
              ADDRA         =>  ELINK_ADDRA(10),
              RWA           =>  ELINK_RWA(10),
              BLKA          =>  ELINK_BLKA(10),
              CLKA          =>  CLK60MHZ,                           -- A PORT IS FOR THE USB INTERFACE

              DINB          =>  ELINK_DINB(10),
              DOUTB         =>  ELINK_DOUTB(10),
              ADDRB         =>  ELINK_ADDRB,
              RWB           =>  ELINK_RWB,
              BLKB          =>  ELINK_PATT_GEN_EN,
              CLKB          =>  CLK_40MHZ_GEN,                      -- B PORT IS FOR THE PATTERN GENERATOR USE

              RESET         =>  RESETB								-- ACTIVE LOW RESET FOR THE RAM BLOCK (IE NOT JUST PORT B)
            );

U111_PATT_ELINK_BLK:DPRT_512X9_SRAM									-- ELINK1 RAM BLOCK
   PORT MAP ( 
              DINA          =>  ELINK_DINA(11),
              DOUTA         =>  ELINK_DOUTA(11),
              ADDRA         =>  ELINK_ADDRA(11),
              RWA           =>  ELINK_RWA(11),
              BLKA          =>  ELINK_BLKA(11),
              CLKA          =>  CLK60MHZ,                           -- A PORT IS FOR THE USB INTERFACE

              DINB          =>  ELINK_DINB(11),
              DOUTB         =>  ELINK_DOUTB(11),
              ADDRB         =>  ELINK_ADDRB,
              RWB           =>  ELINK_RWB,
              BLKB          =>  ELINK_PATT_GEN_EN,
              CLKB          =>  CLK_40MHZ_GEN,                      -- B PORT IS FOR THE PATTERN GENERATOR USE

              RESET         =>  RESETB								-- ACTIVE LOW RESET FOR THE RAM BLOCK (IE NOT JUST PORT B)
            );

U112_PATT_ELINK_BLK:DPRT_512X9_SRAM									-- ELINK1 RAM BLOCK
   PORT MAP ( 
              DINA          =>  ELINK_DINA(12),
              DOUTA         =>  ELINK_DOUTA(12),
              ADDRA         =>  ELINK_ADDRA(12),
              RWA           =>  ELINK_RWA(12),
              BLKA          =>  ELINK_BLKA(12),
              CLKA          =>  CLK60MHZ,                           -- A PORT IS FOR THE USB INTERFACE

              DINB          =>  ELINK_DINB(12),
              DOUTB         =>  ELINK_DOUTB(12),
              ADDRB         =>  ELINK_ADDRB,
              RWB           =>  ELINK_RWB,
              BLKB          =>  ELINK_PATT_GEN_EN,
              CLKB          =>  CLK_40MHZ_GEN,                      -- B PORT IS FOR THE PATTERN GENERATOR USE

              RESET         =>  RESETB								-- ACTIVE LOW RESET FOR THE RAM BLOCK (IE NOT JUST PORT B)
            );

U113_PATT_ELINK_BLK:DPRT_512X9_SRAM									-- ELINK1 RAM BLOCK
   PORT MAP ( 
              DINA          =>  ELINK_DINA(13),
              DOUTA         =>  ELINK_DOUTA(13),
              ADDRA         =>  ELINK_ADDRA(13),
              RWA           =>  ELINK_RWA(13),
              BLKA          =>  ELINK_BLKA(13),
              CLKA          =>  CLK60MHZ,                           -- A PORT IS FOR THE USB INTERFACE

              DINB          =>  ELINK_DINB(13),
              DOUTB         =>  ELINK_DOUTB(13),
              ADDRB         =>  ELINK_ADDRB,
              RWB           =>  ELINK_RWB,
              BLKB          =>  ELINK_PATT_GEN_EN,
              CLKB          =>  CLK_40MHZ_GEN,                      -- B PORT IS FOR THE PATTERN GENERATOR USE

              RESET         =>  RESETB								-- ACTIVE LOW RESET FOR THE RAM BLOCK (IE NOT JUST PORT B)
            );

U114_PATT_ELINK_BLK:DPRT_512X9_SRAM									-- ELINK1 RAM BLOCK
   PORT MAP ( 
              DINA          =>  ELINK_DINA(14),
              DOUTA         =>  ELINK_DOUTA(14),
              ADDRA         =>  ELINK_ADDRA(14),
              RWA           =>  ELINK_RWA(14),
              BLKA          =>  ELINK_BLKA(14),
              CLKA          =>  CLK60MHZ,                           -- A PORT IS FOR THE USB INTERFACE

              DINB          =>  ELINK_DINB(14),
              DOUTB         =>  ELINK_DOUTB(14),
              ADDRB         =>  ELINK_ADDRB,
              RWB           =>  ELINK_RWB,
              BLKB          =>  ELINK_PATT_GEN_EN,
              CLKB          =>  CLK_40MHZ_GEN,                      -- B PORT IS FOR THE PATTERN GENERATOR USE

              RESET         =>  RESETB								-- ACTIVE LOW RESET FOR THE RAM BLOCK (IE NOT JUST PORT B)
            );

U115_PATT_ELINK_BLK:DPRT_512X9_SRAM									-- ELINK1 RAM BLOCK
   PORT MAP ( 
              DINA          =>  ELINK_DINA(15),
              DOUTA         =>  ELINK_DOUTA(15),
              ADDRA         =>  ELINK_ADDRA(15),
              RWA           =>  ELINK_RWA(15),
              BLKA          =>  ELINK_BLKA(15),
              CLKA          =>  CLK60MHZ,                           -- A PORT IS FOR THE USB INTERFACE

              DINB          =>  ELINK_DINB(15),
              DOUTB         =>  ELINK_DOUTB(15),
              ADDRB         =>  ELINK_ADDRB,
              RWB           =>  ELINK_RWB,
              BLKB          =>  ELINK_PATT_GEN_EN,
              CLKB          =>  CLK_40MHZ_GEN,                      -- B PORT IS FOR THE PATTERN GENERATOR USE

              RESET         =>  RESETB								-- ACTIVE LOW RESET FOR THE RAM BLOCK (IE NOT JUST PORT B)
            );

U116_PATT_ELINK_BLK:DPRT_512X9_SRAM									-- ELINK1 RAM BLOCK
   PORT MAP ( 
              DINA          =>  ELINK_DINA(16),
              DOUTA         =>  ELINK_DOUTA(16),
              ADDRA         =>  ELINK_ADDRA(16),
              RWA           =>  ELINK_RWA(16),
              BLKA          =>  ELINK_BLKA(16),
              CLKA          =>  CLK60MHZ,                           -- A PORT IS FOR THE USB INTERFACE

              DINB          =>  ELINK_DINB(16),
              DOUTB         =>  ELINK_DOUTB(16),
              ADDRB         =>  ELINK_ADDRB,
              RWB           =>  ELINK_RWB,
              BLKB          =>  ELINK_PATT_GEN_EN,
              CLKB          =>  CLK_40MHZ_GEN,                      -- B PORT IS FOR THE PATTERN GENERATOR USE

              RESET         =>  RESETB								-- ACTIVE LOW RESET FOR THE RAM BLOCK (IE NOT JUST PORT B)
            );

U117_PATT_ELINK_BLK:DPRT_512X9_SRAM									-- ELINK1 RAM BLOCK
   PORT MAP ( 
              DINA          =>  ELINK_DINA(17),
              DOUTA         =>  ELINK_DOUTA(17),
              ADDRA         =>  ELINK_ADDRA(17),
              RWA           =>  ELINK_RWA(17),
              BLKA          =>  ELINK_BLKA(17),
              CLKA          =>  CLK60MHZ,                           -- A PORT IS FOR THE USB INTERFACE

              DINB          =>  ELINK_DINB(17),
              DOUTB         =>  ELINK_DOUTB(17),
              ADDRB         =>  ELINK_ADDRB,
              RWB           =>  ELINK_RWB,
              BLKB          =>  ELINK_PATT_GEN_EN,
              CLKB          =>  CLK_40MHZ_GEN,                      -- B PORT IS FOR THE PATTERN GENERATOR USE

              RESET         =>  RESETB								-- ACTIVE LOW RESET FOR THE RAM BLOCK (IE NOT JUST PORT B)
            );

U118_PATT_ELINK_BLK:DPRT_512X9_SRAM									-- ELINK1 RAM BLOCK
   PORT MAP ( 
              DINA          =>  ELINK_DINA(18),
              DOUTA         =>  ELINK_DOUTA(18),
              ADDRA         =>  ELINK_ADDRA(18),
              RWA           =>  ELINK_RWA(18),
              BLKA          =>  ELINK_BLKA(18),
              CLKA          =>  CLK60MHZ,                           -- A PORT IS FOR THE USB INTERFACE

              DINB          =>  ELINK_DINB(18),
              DOUTB         =>  ELINK_DOUTB(18),
              ADDRB         =>  ELINK_ADDRB,
              RWB           =>  ELINK_RWB,
              BLKB          =>  ELINK_PATT_GEN_EN,
              CLKB          =>  CLK_40MHZ_GEN,                      -- B PORT IS FOR THE PATTERN GENERATOR USE

              RESET         =>  RESETB								-- ACTIVE LOW RESET FOR THE RAM BLOCK (IE NOT JUST PORT B)
            );

U119_PATT_ELINK_BLK:DPRT_512X9_SRAM									-- ELINK1 RAM BLOCK
   PORT MAP ( 
              DINA          =>  ELINK_DINA(19),
              DOUTA         =>  ELINK_DOUTA(19),
              ADDRA         =>  ELINK_ADDRA(19),
              RWA           =>  ELINK_RWA(19),
              BLKA          =>  ELINK_BLKA(19),
              CLKA          =>  CLK60MHZ,                           -- A PORT IS FOR THE USB INTERFACE

              DINB          =>  ELINK_DINB(19),
              DOUTB         =>  ELINK_DOUTB(19),
              ADDRB         =>  ELINK_ADDRB,
              RWB           =>  ELINK_RWB,
              BLKB          =>  ELINK_PATT_GEN_EN,
              CLKB          =>  CLK_40MHZ_GEN,                      -- B PORT IS FOR THE PATTERN GENERATOR USE

              RESET         =>  RESETB								-- ACTIVE LOW RESET FOR THE RAM BLOCK (IE NOT JUST PORT B)
            );


-- BIDIRECTIONAL I/O FOR THE USB INTERFACE BUS 
U3_USB_DAT_BUS:BIDIR_LVTTL 
   PORT MAP( 
              Data    =>  WR_USB_ADBUS,     -- SEND SIGNAL TO 'DATA' TO DRIVE THE BUFFER OUTPUT TO THE FPGA PAD WHEN TRIEN IS ACTIVE
              Y       =>  N_RD_USB_ADBUS,   -- THIS IS THE INPUT TO THE FPGA VIA A HIDDEN BUFFER
              Trien   =>  USB_TRIEN_B,      -- ACTIVE LOW EN ('1'=TRI-STATE)
              PAD     =>  BIDIR_USB_ADBUS   -- TRI-STATE-ABLE PHYSICAL PAD 
            );

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- CLOCK DOMAIN CROSS: 
-- HAVE MULTIPLE 60MHZ REGISTERS: TFC_STRT_ADDR,        TFC_STOP_ADDR,        ELINKS_STRT_ADDR,        ELINKS_STOP_ADDR,        OP_MODE
-- TO   MULTIPLE 40MHZ REGISTERS: TFC_STRT_ADDR_40MVAL, TFC_STOP_ADDR_40MVAL, ELINKS_STRT_ADDR_40MVAL, ELINKS_STOP_ADDR_40MVAL, OP_MODE_40MVAL
U4A_REGCROSS:CLK60M_TO_40M
    PORT MAP (  
                CLK40M_GEN          =>  CLK_40MHZ_GEN,                      -- 40 MHZ CLOCK WHERE RISE EDGE IS DELAYED ~2.5NS FROM THE 160 MHZ RISE EDGE
                MASTER_POR_B        =>  MASTER_POR_B,                       -- RESET SYNCHRONOUS TO THE 160 MHZ AND 40 MHZ CLOCKS

                BYTE60M_IN          =>  TFC_STRT_ADDR,                      -- INPUT BYTE ORIGINATING FROM THE 60 MHZ DOMAIN
                BYTE40M_OUT         =>  TFC_STRT_ADDR_40MVAL                -- OUTPUT REGISTER BYTE SYNCHRONIZED TO THE 40 MHZ DOMAIN
            );

U4B_REGCROSS:CLK60M_TO_40M
    PORT MAP (  
                CLK40M_GEN          =>  CLK_40MHZ_GEN,                      -- 40 MHZ CLOCK WHERE RISE EDGE IS DELAYED ~2.5NS FROM THE 160 MHZ RISE EDGE
                MASTER_POR_B        =>  MASTER_POR_B,                       -- RESET SYNCHRONOUS TO THE 160 MHZ AND 40 MHZ CLOCKS

                BYTE60M_IN          =>  TFC_STOP_ADDR,                      -- INPUT BYTE ORIGINATING FROM THE 60 MHZ DOMAIN
                BYTE40M_OUT         =>  TFC_STOP_ADDR_40MVAL                -- OUTPUT REGISTER BYTE SYNCHRONIZED TO THE 40 MHZ DOMAIN
            );

U4C_REGCROSS:CLK60M_TO_40M
    PORT MAP (  
                CLK40M_GEN          =>  CLK_40MHZ_GEN,                      -- 40 MHZ CLOCK WHERE RISE EDGE IS DELAYED ~2.5NS FROM THE 160 MHZ RISE EDGE
                MASTER_POR_B        =>  MASTER_POR_B,                       -- RESET SYNCHRONOUS TO THE 160 MHZ AND 40 MHZ CLOCKS

                BYTE60M_IN          =>  ELINKS_STRT_ADDR,                   -- INPUT BYTE ORIGINATING FROM THE 60 MHZ DOMAIN
                BYTE40M_OUT         =>  ELINKS_STRT_ADDR_40MVAL             -- OUTPUT REGISTER BYTE SYNCHRONIZED TO THE 40 MHZ DOMAIN
            );

U4D_REGCROSS:CLK60M_TO_40M
    PORT MAP (  
                CLK40M_GEN          =>  CLK_40MHZ_GEN,                      -- 40 MHZ CLOCK WHERE RISE EDGE IS DELAYED ~2.5NS FROM THE 160 MHZ RISE EDGE
                MASTER_POR_B        =>  MASTER_POR_B,                       -- RESET SYNCHRONOUS TO THE 160 MHZ AND 40 MHZ CLOCKS

                BYTE60M_IN          =>  ELINKS_STOP_ADDR,                   -- INPUT BYTE ORIGINATING FROM THE 60 MHZ DOMAIN
                BYTE40M_OUT         =>  ELINKS_STOP_ADDR_40MVAL             -- OUTPUT REGISTER BYTE SYNCHRONIZED TO THE 40 MHZ DOMAIN
            );
U4E_REGCROSS:CLK60M_TO_40M
    PORT MAP (  
                CLK40M_GEN          =>  CLK_40MHZ_GEN,                      -- 40 MHZ CLOCK WHERE RISE EDGE IS DELAYED ~2.5NS FROM THE 160 MHZ RISE EDGE
                MASTER_POR_B        =>  MASTER_POR_B,                       -- RESET SYNCHRONOUS TO THE 160 MHZ AND 40 MHZ CLOCKS

                BYTE60M_IN          =>  OP_MODE,                            -- INPUT BYTE ORIGINATING FROM THE 60 MHZ DOMAIN
                BYTE40M_OUT         =>  OP_MODE_40MVAL                      -- OUTPUT REGISTER BYTE SYNCHRONIZED TO THE 40 MHZ DOMAIN
            );

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- DEFINE ALL REGISTERS THAT OPERATE WITHIN THE 60 MHZ CLOCK DOAMIN FOR THE USB MODULE

    REG60M:PROCESS(CLK60MHZ, RESETB)
        BEGIN

            IF (RESETB = '0') THEN
                REG_STATE               <=  INIT;
                SM_BANK_SEL             <=  INACTIVE;
				ELK_N_ACTIVE			<=	'0';

                USB_RXF_B               <=  '1';
                USB_TXE_B               <=  '1';

                USB_RD_BI               <=  '1';
                USB_WR_BI               <=  '1';
                USB_TRIEN_B             <=  '1';
                USB_OE_BI               <=  '1';

                SI_CNT                  <=  "0000";
                USB_SIWU_BI             <=  '1';                        -- ACTIVE LOW

                RD_USB_ADBUS            <=  (OTHERS => '0');
                WR_USB_ADBUS            <=  (OTHERS => '0');

                USB_RD_ACTIVE           <=  '0';
                USB_WR_ACTIVE           <=  '0';

                TFC_BLKA                <=  '1';                        -- BLK ENABLE'S ARE ACTIVE LOW
                ELINK_BLKA           	<=  (OTHERS => '1');

                TFC_DINA                <=  (OTHERS => '0');
                ELINK_DINA           	<=  (OTHERS => "000000000");
        
                TFC_ADDRA               <=  (OTHERS => '0');
                ELINK_ADDRA          	<=  (OTHERS => "000000000");

                TFC_RWA                 <=  '1';
                ELINK_RWA            	<=  (OTHERS => '1');
    
                REG_ADDR                <=  (OTHERS => '0');

                WR_XFER_TYPE            <=  (OTHERS => '0');

                USB_RD_DAT              <=  (OTHERS => '0');
                RD_XFER_TYPE            <=  (OTHERS => '0');

                OP_MODE_T               <=  (OTHERS => '0');
                OP_MODE                 <=  (OTHERS => '0');

                TFC_STRT_ADDR_T         <=  (OTHERS => '0');
                TFC_STRT_ADDR           <=  (OTHERS => '0');
                
                TFC_STOP_ADDR_T         <=  (OTHERS => '0');
                TFC_STOP_ADDR           <=  (OTHERS => '0');

                ELINKS_STRT_ADDR_T      <=  (OTHERS => '0');
                ELINKS_STRT_ADDR        <=  (OTHERS => '0');

                ELINKS_STOP_ADDR_T      <=  (OTHERS => '0');
                ELINKS_STOP_ADDR        <=  (OTHERS => '0');

                CHKSUM                  <=  (OTHERS => '0');

                TFC_ADDR8B              <=  '0';
                ELINK_ADDR8B           	<=  '0';

            ELSIF (CLK60MHZ 'EVENT AND CLK60MHZ = '1') THEN
                REG_STATE               <=  N_REG_STATE;
                SM_BANK_SEL             <=  N_SM_BANK_SEL;
				ELK_N_ACTIVE			<=	N_ELK_N_ACTIVE;

                USB_RXF_B               <=  P_USB_RXF_B;
                USB_TXE_B               <=  P_USB_TXE_B;

                USB_RD_BI               <=  N_USB_RD_BI;
                USB_WR_BI               <=  N_USB_WR_BI;
                USB_TRIEN_B             <=  N_USB_TRIEN_B;
                USB_OE_BI               <=  N_USB_OE_BI;

                SI_CNT                  <=  N_SI_CNT;
                USB_SIWU_BI             <=  N_USB_SIWU_BI;

                RD_USB_ADBUS            <=  N_RD_USB_ADBUS;
                WR_USB_ADBUS            <=  N_WR_USB_ADBUS;

                USB_RD_ACTIVE           <=  N_USB_RD_ACTIVE;
                USB_WR_ACTIVE           <=  N_USB_WR_ACTIVE;

                TFC_BLKA                <=  N_TFC_BLKA;
                ELINK_BLKA           	<=  N_ELINK_BLKA;

                TFC_DINA                <=  N_TFC_DINA;
                ELINK_DINA           	<=  N_ELINK_DINA;

                TFC_ADDRA               <=  N_TFC_ADDRA;
                ELINK_ADDRA          	<=  N_ELINK_ADDRA;

                TFC_RWA                 <=  N_TFC_RWA;
                ELINK_RWA            	<=  N_ELINK_RWA;

                REG_ADDR                <=  N_REG_ADDR;

                WR_XFER_TYPE            <=  N_WR_XFER_TYPE;

                USB_RD_DAT              <=  N_USB_RD_DAT;
                RD_XFER_TYPE            <=  N_RD_XFER_TYPE;

                OP_MODE_T               <=  N_OP_MODE_T;
                OP_MODE                 <=  N_OP_MODE;

                TFC_STRT_ADDR_T         <=  N_TFC_STRT_ADDR_T;
                TFC_STRT_ADDR           <=  N_TFC_STRT_ADDR;

                TFC_STOP_ADDR_T         <=  N_TFC_STOP_ADDR_T;
                TFC_STOP_ADDR           <=  N_TFC_STOP_ADDR;

                ELINKS_STRT_ADDR_T      <=  N_ELINKS_STRT_ADDR_T;
                ELINKS_STRT_ADDR        <=  N_ELINKS_STRT_ADDR;

                ELINKS_STOP_ADDR_T      <=  N_ELINKS_STOP_ADDR_T;
                ELINKS_STOP_ADDR        <=  N_ELINKS_STOP_ADDR;

                CHKSUM                  <=  N_CHKSUM;

                TFC_ADDR8B              <=  N_TFC_ADDR8B;
                ELINK_ADDR8B           	<=  N_ELINK_ADDR8B;

            END IF;
        END PROCESS REG60M;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- MUX PROCESS OPERATING BETWEEN THE USB REG_SM STATE MACHINE AND THE RAM BLOCKS
-- THIS PROCESS CONNECTS THE GENERIC INTERFACE RAM BLOCK INPUTS SIGNALS FROM THE USB REG_SM STATE MECHINE TO THE SPECIFIC RAM BLOCKS
-- THERE IS ONE TFC RAM BLOCK AND UP TO 20 ELINK RAM BLOCKS

    USB_TO_RAM_MUX:PROCESS( SM_BANK_SEL, 
                            TFC_BLKA, TFC_RWA, TFC_DINA, TFC_ADDRA,
                            ELINK_BLKA, ELINK_RWA, ELINK_DINA, ELINK_ADDRA,
                            X_BLKA, X_RWA, X_DINA, X_ADDRA
                            )
        BEGIN
    -- DEFAULT ASSIGNMENTS
        N_TFC_BLKA              <=  TFC_BLKA;
        N_TFC_RWA               <=  TFC_RWA;
        N_TFC_ADDRA             <=  TFC_ADDRA;
        N_TFC_DINA              <=  TFC_DINA;
    
        N_ELINK_BLKA         	<=  ELINK_BLKA;
        N_ELINK_RWA          	<=  ELINK_RWA;
        N_ELINK_ADDRA        	<=  ELINK_ADDRA;
        N_ELINK_DINA         	<=  ELINK_DINA;

-- PLACEHOLDERS.  HARD-CODED TO THE LOWER RAM BLOCKS FOR NOW.  UPPER/LOWER RAM BLOCK TO EVENTUALLY COME FROM USB INTERFACE.
        N_TFC_ADDR8B            <=  '0';     
        N_ELINK_ADDR8B         	<=  '0';

-- SELECTION MUX FOR THE USB R/W ACCESS VIA RAM PORT A'S REGISTERS
        CASE SM_BANK_SEL IS
            WHEN INACTIVE       =>                                  -- INACTIVE MODE
                -- TFC RAM BLOCK I/O
                N_TFC_BLKA          <=  '1';                        -- ACTIVE LOW TFC RAM BLOCK ENABLE
                N_TFC_RWA           <=  '1';                        -- LEAVE IN THE READ STATE
                N_TFC_ADDRA         <=  (OTHERS => '0');            -- TFC RAM BLOCK PORT A ADDR INPUT
                N_TFC_DINA          <=  (OTHERS => '0');            -- TFC RAM BLOCK PORT A DATA INPUT

                N_ELINK_BLKA     	<=  (OTHERS => '1');            -- ACTIVE LOW ELINK RAM BLOCK ENABLES
                N_ELINK_RWA      	<=  (OTHERS => '1');            -- LEAVE 'ALL' IN THE READ STATE

				FOR I IN 0 TO 19 LOOP
					N_ELINK_ADDRA(I)    <=  (OTHERS => '0');            -- ELINK RAM BLOCK PORT A ADDR INPUTS
					N_ELINK_DINA(I)     <=  (OTHERS => '0');            -- ELINK RAM BLOCK PORT A DATA INPUTS
				END LOOP;
					
            WHEN TFC            =>
                N_TFC_BLKA          <=  X_BLKA;                     -- ACTIVE LOW TRFC RAM BLOCK ENABLE
                N_TFC_RWA           <=  X_RWA;                      -- READ/WRITE CONTROL, PORT A
                N_TFC_ADDRA         <=  X_ADDRA;                    -- TFC RAM BLOCK PORT A ADDR INPUT
                N_TFC_DINA          <=  X_DINA;                     -- TFC RAM BLOCK PORT A DATA INPUT
                
            WHEN ELINK0         =>
                N_ELINK_BLKA(0)     <=  X_BLKA;                     -- ACTIVE LOW TRFC RAM BLOCK ENABLE
                N_ELINK_RWA(0)      <=  X_RWA;                      -- READ/WRITE CONTROL, PORT A
                N_ELINK_ADDRA(0)    <=  X_ADDRA;                    -- ELINK0 RAM BLOCK PORT A ADDR INPUT
                N_ELINK_DINA(0)     <=  X_DINA;                     -- ELINK0 RAM BLOCK PORT A DATA INPUT
                
            WHEN ELINK1         =>
                N_ELINK_BLKA(1)     <=  X_BLKA;                     -- ACTIVE LOW TRFC RAM BLOCK ENABLE
                N_ELINK_RWA(1)      <=  X_RWA;                      -- READ/WRITE CONTROL, PORT A
                N_ELINK_ADDRA(1)    <=  X_ADDRA;                    -- ELINK1 RAM BLOCK PORT A ADDR INPUT
                N_ELINK_DINA(1)     <=  X_DINA;                     -- ELINK1 RAM BLOCK PORT A DATA INPUT
                
            WHEN ELINK2         =>
                N_ELINK_BLKA(2)     <=  X_BLKA;                     -- ACTIVE LOW TRFC RAM BLOCK ENABLE
                N_ELINK_RWA(2)      <=  X_RWA;                      -- READ/WRITE CONTROL, PORT A
                N_ELINK_ADDRA(2)    <=  X_ADDRA;                    -- ELINK2 RAM BLOCK PORT A ADDR INPUT
                N_ELINK_DINA(2)     <=  X_DINA;                     -- ELINK2 RAM BLOCK PORT A DATA INPUT
                
            WHEN ELINK3         =>
                N_ELINK_BLKA(3)     <=  X_BLKA;                     -- ACTIVE LOW TRFC RAM BLOCK ENABLE
                N_ELINK_RWA(3)      <=  X_RWA;                      -- READ/WRITE CONTROL, PORT A
                N_ELINK_ADDRA(3)    <=  X_ADDRA;                    -- ELINK3 RAM BLOCK PORT A ADDR INPUT
                N_ELINK_DINA(3)     <=  X_DINA;                     -- ELINK3 RAM BLOCK PORT A DATA INPUT
                
            WHEN ELINK4         =>
                N_ELINK_BLKA(4)     <=  X_BLKA;                     -- ACTIVE LOW TRFC RAM BLOCK ENABLE
                N_ELINK_RWA(4)      <=  X_RWA;                      -- READ/WRITE CONTROL, PORT A
                N_ELINK_ADDRA(4)    <=  X_ADDRA;                    -- ELINK4 RAM BLOCK PORT A ADDR INPUT
                N_ELINK_DINA(4)     <=  X_DINA;                     -- ELINK4 RAM BLOCK PORT A DATA INPUT
                
            WHEN ELINK5         =>
                N_ELINK_BLKA(5)     <=  X_BLKA;                     -- ACTIVE LOW TRFC RAM BLOCK ENABLE
                N_ELINK_RWA(5)      <=  X_RWA;                      -- READ/WRITE CONTROL, PORT A
                N_ELINK_ADDRA(5)    <=  X_ADDRA;                    -- ELINK5 RAM BLOCK PORT A ADDR INPUT
                N_ELINK_DINA(5)     <=  X_DINA;                     -- ELINK5 RAM BLOCK PORT A DATA INPUT
                
            WHEN ELINK6         =>
                N_ELINK_BLKA(6)     <=  X_BLKA;                     -- ACTIVE LOW TRFC RAM BLOCK ENABLE
                N_ELINK_RWA(6)      <=  X_RWA;                      -- READ/WRITE CONTROL, PORT A
                N_ELINK_ADDRA(6)    <=  X_ADDRA;                    -- ELINK6 RAM BLOCK PORT A ADDR INPUT
                N_ELINK_DINA(6)     <=  X_DINA;                     -- ELINK6 RAM BLOCK PORT A DATA INPUT
                
            WHEN ELINK7         =>
                N_ELINK_BLKA(7)     <=  X_BLKA;                     -- ACTIVE LOW TRFC RAM BLOCK ENABLE
                N_ELINK_RWA(7)      <=  X_RWA;                      -- READ/WRITE CONTROL, PORT A
                N_ELINK_ADDRA(7)    <=  X_ADDRA;                    -- ELINK7 RAM BLOCK PORT A ADDR INPUT
                N_ELINK_DINA(7)     <=  X_DINA;                     -- ELINK7 RAM BLOCK PORT A DATA INPUT
                
            WHEN ELINK8         =>
                N_ELINK_BLKA(8)     <=  X_BLKA;                     -- ACTIVE LOW TRFC RAM BLOCK ENABLE
                N_ELINK_RWA(8)      <=  X_RWA;                      -- READ/WRITE CONTROL, PORT A
                N_ELINK_ADDRA(8)    <=  X_ADDRA;                    -- ELINK8 RAM BLOCK PORT A ADDR INPUT
                N_ELINK_DINA(8)     <=  X_DINA;                     -- ELINK8 RAM BLOCK PORT A DATA INPUT
                
            WHEN ELINK9         =>
                N_ELINK_BLKA(9)     <=  X_BLKA;                     -- ACTIVE LOW TRFC RAM BLOCK ENABLE
                N_ELINK_RWA(9)      <=  X_RWA;                      -- READ/WRITE CONTROL, PORT A
                N_ELINK_ADDRA(9)    <=  X_ADDRA;                    -- ELINK9 RAM BLOCK PORT A ADDR INPUT
                N_ELINK_DINA(9)     <=  X_DINA;                     -- ELINK9 RAM BLOCK PORT A DATA INPUT
                
            WHEN ELINK10         =>
                N_ELINK_BLKA(10)    <=  X_BLKA;                     -- ACTIVE LOW TRFC RAM BLOCK ENABLE
                N_ELINK_RWA(10)     <=  X_RWA;                      -- READ/WRITE CONTROL, PORT A
                N_ELINK_ADDRA(10)   <=  X_ADDRA;                    -- ELINK10 RAM BLOCK PORT A ADDR INPUT
                N_ELINK_DINA(10)    <=  X_DINA;                     -- ELINK10 RAM BLOCK PORT A DATA INPUT
                
            WHEN ELINK11         =>
                N_ELINK_BLKA(11)    <=  X_BLKA;                     -- ACTIVE LOW TRFC RAM BLOCK ENABLE
                N_ELINK_RWA(11)     <=  X_RWA;                      -- READ/WRITE CONTROL, PORT A
                N_ELINK_ADDRA(11)   <=  X_ADDRA;                    -- ELINK11 RAM BLOCK PORT A ADDR INPUT
                N_ELINK_DINA(11)    <=  X_DINA;                     -- ELINK11 RAM BLOCK PORT A DATA INPUT
                
            WHEN ELINK12         =>
                N_ELINK_BLKA(12)    <=  X_BLKA;                     -- ACTIVE LOW TRFC RAM BLOCK ENABLE
                N_ELINK_RWA(12)     <=  X_RWA;                      -- READ/WRITE CONTROL, PORT A
                N_ELINK_ADDRA(12)   <=  X_ADDRA;                    -- ELINK12 RAM BLOCK PORT A ADDR INPUT
                N_ELINK_DINA(12)    <=  X_DINA;                     -- ELINK12 RAM BLOCK PORT A DATA INPUT
                
            WHEN ELINK13         =>
                N_ELINK_BLKA(13)    <=  X_BLKA;                     -- ACTIVE LOW TRFC RAM BLOCK ENABLE
                N_ELINK_RWA(13)     <=  X_RWA;                      -- READ/WRITE CONTROL, PORT A
                N_ELINK_ADDRA(13)   <=  X_ADDRA;                    -- ELINK13 RAM BLOCK PORT A ADDR INPUT
                N_ELINK_DINA(13)    <=  X_DINA;                     -- ELINK13 RAM BLOCK PORT A DATA INPUT
                
            WHEN ELINK14         =>
                N_ELINK_BLKA(14)    <=  X_BLKA;                     -- ACTIVE LOW TRFC RAM BLOCK ENABLE
                N_ELINK_RWA(14)     <=  X_RWA;                      -- READ/WRITE CONTROL, PORT A
                N_ELINK_ADDRA(14)   <=  X_ADDRA;                    -- ELINK14 RAM BLOCK PORT A ADDR INPUT
                N_ELINK_DINA(14)    <=  X_DINA;                     -- ELINK14 RAM BLOCK PORT A DATA INPUT
                
            WHEN ELINK15         =>
                N_ELINK_BLKA(15)    <=  X_BLKA;                     -- ACTIVE LOW TRFC RAM BLOCK ENABLE
                N_ELINK_RWA(15)     <=  X_RWA;                      -- READ/WRITE CONTROL, PORT A
                N_ELINK_ADDRA(15)   <=  X_ADDRA;                    -- ELINK15 RAM BLOCK PORT A ADDR INPUT
                N_ELINK_DINA(15)    <=  X_DINA;                     -- ELINK15 RAM BLOCK PORT A DATA INPUT
                
            WHEN ELINK16         =>
                N_ELINK_BLKA(16)    <=  X_BLKA;                     -- ACTIVE LOW TRFC RAM BLOCK ENABLE
                N_ELINK_RWA(16)     <=  X_RWA;                      -- READ/WRITE CONTROL, PORT A
                N_ELINK_ADDRA(16)   <=  X_ADDRA;                    -- ELINK16 RAM BLOCK PORT A ADDR INPUT
                N_ELINK_DINA(16)    <=  X_DINA;                     -- ELINK16 RAM BLOCK PORT A DATA INPUT
                
            WHEN ELINK17         =>
                N_ELINK_BLKA(17)    <=  X_BLKA;                     -- ACTIVE LOW TRFC RAM BLOCK ENABLE
                N_ELINK_RWA(17)     <=  X_RWA;                      -- READ/WRITE CONTROL, PORT A
                N_ELINK_ADDRA(17)   <=  X_ADDRA;                    -- ELINK17 RAM BLOCK PORT A ADDR INPUT
                N_ELINK_DINA(17)    <=  X_DINA;                     -- ELINK17 RAM BLOCK PORT A DATA INPUT
                
            WHEN ELINK18         =>
                N_ELINK_BLKA(18)    <=  X_BLKA;                     -- ACTIVE LOW TRFC RAM BLOCK ENABLE
                N_ELINK_RWA(18)     <=  X_RWA;                      -- READ/WRITE CONTROL, PORT A
                N_ELINK_ADDRA(18)   <=  X_ADDRA;                    -- ELINK18 RAM BLOCK PORT A ADDR INPUT
                N_ELINK_DINA(18)    <=  X_DINA;                     -- ELINK18 RAM BLOCK PORT A DATA INPUT
                
            WHEN ELINK19         =>
                N_ELINK_BLKA(19)    <=  X_BLKA;                     -- ACTIVE LOW TRFC RAM BLOCK ENABLE
                N_ELINK_RWA(19)     <=  X_RWA;                      -- READ/WRITE CONTROL, PORT A
                N_ELINK_ADDRA(19)   <=  X_ADDRA;                    -- ELINK19 RAM BLOCK PORT A ADDR INPUT
                N_ELINK_DINA(19)    <=  X_DINA;                     -- ELINK19 RAM BLOCK PORT A DATA INPUT

            WHEN OTHERS         =>

        END CASE;

    END PROCESS USB_TO_RAM_MUX;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- USB INTERFACE STATE MACHINE.  USES CLK60MHZ.

    REG_SM:PROCESS( REG_STATE, SM_BANK_SEL, WR_XFER_TYPE, WR_USB_ADBUS, USB_SIWU_BI, SI_CNT,
                    USB_RD_BI, USB_WR_BI, USB_TRIEN_B, USB_OE_BI, USB_RD_DAT, RD_XFER_TYPE,
                    OP_MODE_T, OP_MODE, ELK_N_ACTIVE,
                    TFC_STRT_ADDR_T, TFC_STOP_ADDR_T, ELINKS_STRT_ADDR_T, ELINKS_STOP_ADDR_T,
                    TFC_ADDR8B, TFC_DOUTA,
                    USB_RD_ACTIVE, USB_WR_ACTIVE, CHKSUM, USB_TXE_B, REG_ADDR, USB_RXF_B, RD_USB_ADBUS,
                    ELINK_ADDR8B, ELINK_DOUTA,
                    TFC_STRT_ADDR, TFC_STOP_ADDR, ELINKS_STRT_ADDR, ELINKS_STOP_ADDR
                    )
        BEGIN

        -- DEFAULT ASSIGNMENTS:  THE STATE MACHINE ONLY MAKES ASSIGNMENTS WHEN A CHANGE IS DESIRED
            N_SM_BANK_SEL           <=  SM_BANK_SEL;
			N_ELK_N_ACTIVE			<=	ELK_N_ACTIVE;

            N_USB_RD_BI             <=  USB_RD_BI;
            N_USB_WR_BI             <=  USB_WR_BI;
            N_USB_TRIEN_B           <=  USB_TRIEN_B;
            N_USB_OE_BI             <=  USB_OE_BI;

            N_SI_CNT                <=  SI_CNT;
            N_USB_SIWU_BI           <=  USB_SIWU_BI;

            N_REG_ADDR              <=  REG_ADDR;

            N_USB_RD_DAT            <=  USB_RD_DAT;
            N_RD_XFER_TYPE          <=  RD_XFER_TYPE;

            N_USB_RD_ACTIVE         <=  USB_RD_ACTIVE;
            N_USB_WR_ACTIVE         <=  USB_WR_ACTIVE;

            N_OP_MODE_T             <=  OP_MODE_T;
            N_OP_MODE               <=  OP_MODE;

            N_TFC_STRT_ADDR_T       <=  TFC_STRT_ADDR_T;
            N_TFC_STOP_ADDR_T       <=  TFC_STOP_ADDR_T;
            N_ELINKS_STRT_ADDR_T    <=  ELINKS_STRT_ADDR_T;
            N_ELINKS_STOP_ADDR_T    <=  ELINKS_STOP_ADDR_T;
 
            N_TFC_STRT_ADDR         <=  TFC_STRT_ADDR;
            N_TFC_STOP_ADDR         <=  TFC_STOP_ADDR;
            N_ELINKS_STRT_ADDR      <=  ELINKS_STRT_ADDR;
            N_ELINKS_STOP_ADDR      <=  ELINKS_STOP_ADDR;
 
            N_CHKSUM                <=  CHKSUM;

            N_WR_USB_ADBUS          <=  WR_USB_ADBUS;
            N_WR_XFER_TYPE          <=  WR_XFER_TYPE;           -- ++++NOTE++++THIS NEVER GETS INITIALIZED IN THE INIT STATE BECAUSE IT MUST BE REMEMBERED 
                                                                -- BETWEEN SUCCESSIVE USB COMMAND SEQUENCES

            X_ADDRA                 <=  (OTHERS => '0');        -- MUX INPUT DEFAULT IS ADDRESS 0
            X_BLKA                  <=  '1';                    -- MUX INPUT DEFAULT IS DISABLED RAM BLOCK
            X_RWA                   <=  '1';                    -- MUX INPUT DEFAULT IS READ MODE
            X_DINA                  <=  (OTHERS => '0');        -- MUX INPUT DEFAULT IS DATA 0

--++++++++++
        CASE REG_STATE IS

        WHEN INIT           =>
            N_USB_RD_BI             <=  '1';                                    -- INITIALIZE USB MODULE CONTROL BITS
            N_USB_WR_BI             <=  '1';
            N_USB_TRIEN_B           <=  '1';
            N_USB_OE_BI             <=  '1';
            N_SI_CNT                <=  "0000";                                 -- INITIALIZE THE SEND-IMMEDIATE COUNTER USED TO GENERATE THE 250 NS ACTIVE LOW PULSE
            N_USB_SIWU_BI           <=  '1';                                    -- INITIATE THE SEND IMMEDIATE SIGNAL USED TO FLUSH THE USB MODULE FIFO
            N_REG_ADDR              <=  (OTHERS => '0');                        -- INITIALIZE THE REGISTER ADDRESS TO 0 WHICH CORRESPONDS TO HEADER ID'S
            N_USB_RD_ACTIVE         <=  '0';                                    -- THE READ OPERATION IS INACTIVE
            N_USB_WR_ACTIVE         <=  '0';                                    -- THE WRITE OPERATION IS INACTIVE            
            X_ADDRA                 <=  (OTHERS => '0');                        -- INITIALIZE THE GENERIC PATTERN RAM ADDRESS POINTER FOR PORT A TO 0'S
            X_BLKA                  <=  '1';                                    -- INITIALIZE THE GENERIC PATTERN RAM ACTIVE LOW BLOCK ENABLE TO BE DISABLED
            X_RWA                   <=  '1';                                    -- INITIALIZE THE GENERIC PATTERN RAM READ/WRITE PORT TO READ
            X_DINA                  <=  (OTHERS => '0');                        -- INITIALIZE THE GENERIC PATTERN RAM DATA FOR PORT A TO 0'S
            N_CHKSUM                <=  (OTHERS => '0');                        -- INITIALIZE THE PACKET CHKSUM VALUE
            N_RD_XFER_TYPE          <=  (OTHERS => '0');                        -- INITIALIZE THE TRANSFER TYPE TO NOP
			N_SM_BANK_SEL			<=	INACTIVE;								-- INITIALIZE THE MUXES
             
            IF USB_RXF_B = '0' THEN                                             -- CHK USB READ REQUEST: ACCEPT COMMANDS FROM THE HOST
                N_REG_STATE         <=  ASSERT_RD;
                N_USB_OE_BI         <=  '0';                                    -- ENABLE THE USB MODULE TO DRIVE THE 1ST BYTE ONTO THE BUS 
            ELSE
                N_REG_STATE         <=  INIT;
            END IF;

-- ++++++++++++++++++++++++++++++++++++
--
-- NEED TO INSERT A WATCHDOG TIMEOUT FUNCTION TO PREVENT HUNG STATE MACHINE!
-- USE USB_WRITE_ACTIVE AND USB_RD_ACTIVE.  HIGH STATES ENABLES THE WDT, BUT LOW STATE RESETS THE WDT.
--+++++++++++++++++++++++++++++++++++++

--+++++++++++++
-- USB READ SECTION: TRANSFER DATA FROM THE USB MODULE TO THE FPGA.  OE NEEDS TO BE ASSERTED 1 CLOCK CYCLE AHEAD OF RD. 
        WHEN ASSERT_RD     =>                                                   -- EXTRA STATE HERE TO ASSERT READ AFTER OE ASSERTED
            IF USB_RXF_B = '0' THEN                                             -- USB READ REQUEST STARTED: THIS CHECK IS FOR GLITCH RECOVERY
                N_REG_STATE     <=  FILL_RD_PIPELN;  
                N_USB_RD_BI     <=  '0';                                        -- ACKNOWLEDGE THE FIRST READ BYTE RD_USB_ADBUS SHOULD CONTAIN THE START HEADER ON THE FPGA PINS, 
            ELSE                                                                -- BUT NOT YET THRU DATA INPUT D-FF
                N_REG_STATE     <=  INIT;
                N_USB_OE_BI     <=  '1';                                        -- KEEP THE USB DATA BUS DE-ACTIVATED
            END IF;

        WHEN FILL_RD_PIPELN     =>                                              -- EXTRA STATE HERE AFTER RD ASSERTED TO FILL THE DATA INPUT PIPELINE 
            IF USB_RXF_B = '0' THEN                                             -- USB READ REQUEST STARTED: THIS CHECK IS FOR GLITCH RECOVERY
                N_REG_STATE     <=  CHK_FOR_HEADER;  
            ELSE
                N_REG_STATE     <=  INIT;
            END IF;

        WHEN CHK_FOR_HEADER          =>                                         -- USB DATA NOW THRU THE INPUT FF PIPELINE
            IF (USB_RXF_B = '0') AND  (RD_USB_ADBUS = START_BYTE) THEN          -- USB READ REQUEST STARTED: THIS CHECK IS FOR IMPROPER HEADER AND GLITCH RECOVERY
                N_REG_STATE     <=  DEC_XFER_TYPE;
                N_USB_OE_BI     <=  '0';                                        -- ENABLE THE USB MODULE TO DRIVE THE FIRST DATA BYTE ONTO THE BUS
                N_USB_RD_BI     <=  '0';                                        -- ACKNOWLEDGE THE FIRST READ BYTE 
            ELSE
                N_REG_STATE     <=  INIT;
                N_USB_OE_BI     <=  '1';                                        -- KEEP THE USB DATA BUS DE-ACTIVATED
                N_USB_RD_BI     <=  '1';                                        -- READ OPERATION STOPPED
            END IF;
 
        WHEN DEC_XFER_TYPE     =>                                               -- DECODE THE STORED TRANSFER TYPE BYTE
            N_RD_XFER_TYPE          <=  RD_USB_ADBUS;                           -- USB BUS NOW HAS THE TRANSFER TYPE--STORE FOR LATER USE
            N_USB_RD_ACTIVE         <=  '1';                                    -- THE READ OPERATION IS NOW ACTIVE

            IF USB_RXF_B = '0' THEN                                             -- VERIFY USB STILL OPEN FOR A READ (NOISE GLITCH RECOVERY)
                CASE RD_USB_ADBUS IS                                            -- JUMP TO EITHER STORE PATTERN OR REGISTER INFO
                    WHEN TT_RD_NOP      =>                                      -- NULL NOP COMMAND
                        N_REG_STATE     <=  INIT;
                        N_SM_BANK_SEL   <=  INACTIVE;                           -- CONTROLS SIGNAL ACCESS TO THE VARIOUS RAM BANKS
						N_ELK_N_ACTIVE	<=	'0';								-- ELINK RAM BLOCKS NOT ACTIVE FOR USB INTERAFCE ACCESS

                    WHEN TT_RD_ACR      =>                                      -- UPDATE ALL CONTROL REGISTERS
                        N_REG_STATE     <=  STORE_ALL_REG;
                        N_SM_BANK_SEL   <=  INACTIVE;                           -- CONTROLS SIGNAL ACCESS TO THE VARIOUS RAM BANKS
						N_ELK_N_ACTIVE	<=	'0';								-- ELINK RAM BLOCKS NOT ACTIVE FOR USB INTERAFCE ACCESS
 
                    WHEN TT_RD_TFC_RB   =>                                      -- UPDATE THE TFC REGISTER BANK
                        N_REG_STATE     <=  STORE_RAM;                          -- NEED TO START HERE WITH RAM BANK SIGNALS TO BE READY FOR REAL DATA INPUT
                        N_SM_BANK_SEL   <=  TFC;                                -- CONNECT GENERIC RAM BANK SIGNALS TO TFC RAM BANK
						N_ELK_N_ACTIVE	<=	'0';								-- ELINK RAM BLOCKS NOT ACTIVE FOR USB INTERAFCE ACCESS

                    WHEN TT_RD_ELK_RB0  =>                                      -- UPDATE THE ELINK REGISTER BANK 0
                        N_REG_STATE     <=  STORE_RAM;
                        N_SM_BANK_SEL   <=  ELINK0;                             -- CONNECT GENERIC RAM BANK SIGNALS TO ELINK0 RAM BANK
						N_ELK_N_ACTIVE	<=	'1';								-- SIGNIFIES THAT ONE OF THE 20 ELINK RAM BLOCKS ACTIVE FOR USB INTERAFCE ACCESS

                    WHEN TT_RD_ELK_RB1  =>                                      -- UPDATE THE ELINK REGISTER BANK 1
                        N_REG_STATE     <=  STORE_RAM;
                        N_SM_BANK_SEL   <=  ELINK1;                             -- CONNECT GENERIC RAM BANK SIGNALS TO ELINK1 RAM BANK
						N_ELK_N_ACTIVE	<=	'1';								-- SIGNIFIES THAT ONE OF THE 20 ELINK RAM BLOCKS ACTIVE FOR USB INTERAFCE ACCESS

                    WHEN TT_RD_ELK_RB2  =>                                      -- UPDATE THE ELINK REGISTER BANK 2
                        N_REG_STATE     <=  STORE_RAM;
                        N_SM_BANK_SEL   <=  ELINK2;                             -- CONNECT GENERIC RAM BANK SIGNALS TO ELINK2 RAM BANK
						N_ELK_N_ACTIVE	<=	'1';								-- SIGNIFIES THAT ONE OF THE 20 ELINK RAM BLOCKS ACTIVE FOR USB INTERAFCE ACCESS

                    WHEN TT_RD_ELK_RB3  =>                                      -- UPDATE THE ELINK REGISTER BANK 3
                        N_REG_STATE     <=  STORE_RAM;
                        N_SM_BANK_SEL   <=  ELINK3;                             -- CONNECT GENERIC RAM BANK SIGNALS TO ELINK3 RAM BANK
						N_ELK_N_ACTIVE	<=	'1';								-- SIGNIFIES THAT ONE OF THE 20 ELINK RAM BLOCKS ACTIVE FOR USB INTERAFCE ACCESS

                    WHEN TT_RD_ELK_RB4  =>                                      -- UPDATE THE ELINK REGISTER BANK 4
                        N_REG_STATE     <=  STORE_RAM;
                        N_SM_BANK_SEL   <=  ELINK4;                             -- CONNECT GENERIC RAM BANK SIGNALS TO ELINK4 RAM BANK
						N_ELK_N_ACTIVE	<=	'1';								-- SIGNIFIES THAT ONE OF THE 20 ELINK RAM BLOCKS ACTIVE FOR USB INTERAFCE ACCESS

                    WHEN TT_RD_ELK_RB5  =>                                      -- UPDATE THE ELINK REGISTER BANK 5
                        N_REG_STATE     <=  STORE_RAM;
                        N_SM_BANK_SEL   <=  ELINK5;                             -- CONNECT GENERIC RAM BANK SIGNALS TO ELINK5 RAM BANK
						N_ELK_N_ACTIVE	<=	'1';								-- SIGNIFIES THAT ONE OF THE 20 ELINK RAM BLOCKS ACTIVE FOR USB INTERAFCE ACCESS

                    WHEN TT_RD_ELK_RB6  =>                                      -- UPDATE THE ELINK REGISTER BANK 6
                        N_REG_STATE     <=  STORE_RAM;
                        N_SM_BANK_SEL   <=  ELINK6;                             -- CONNECT GENERIC RAM BANK SIGNALS TO ELINK6 RAM BANK
						N_ELK_N_ACTIVE	<=	'1';								-- SIGNIFIES THAT ONE OF THE 20 ELINK RAM BLOCKS ACTIVE FOR USB INTERAFCE ACCESS

                    WHEN TT_RD_ELK_RB7  =>                                      -- UPDATE THE ELINK REGISTER BANK 7
                        N_REG_STATE     <=  STORE_RAM;
                        N_SM_BANK_SEL   <=  ELINK7;                             -- CONNECT GENERIC RAM BANK SIGNALS TO ELINK7 RAM BANK
						N_ELK_N_ACTIVE	<=	'1';								-- SIGNIFIES THAT ONE OF THE 20 ELINK RAM BLOCKS ACTIVE FOR USB INTERAFCE ACCESS

                    WHEN TT_RD_ELK_RB8  =>                                      -- UPDATE THE ELINK REGISTER BANK 8
                        N_REG_STATE     <=  STORE_RAM;
                        N_SM_BANK_SEL   <=  ELINK8;                             -- CONNECT GENERIC RAM BANK SIGNALS TO ELINK8 RAM BANK
						N_ELK_N_ACTIVE	<=	'1';								-- SIGNIFIES THAT ONE OF THE 20 ELINK RAM BLOCKS ACTIVE FOR USB INTERAFCE ACCESS

                    WHEN TT_RD_ELK_RB9  =>                                      -- UPDATE THE ELINK REGISTER BANK 9
                        N_REG_STATE     <=  STORE_RAM;
                        N_SM_BANK_SEL   <=  ELINK9;                             -- CONNECT GENERIC RAM BANK SIGNALS TO ELINK9 RAM BANK
						N_ELK_N_ACTIVE	<=	'1';								-- SIGNIFIES THAT ONE OF THE 20 ELINK RAM BLOCKS ACTIVE FOR USB INTERAFCE ACCESS

                    WHEN TT_RD_ELK_RB10  =>                                     -- UPDATE THE ELINK REGISTER BANK 10
                        N_REG_STATE     <=  STORE_RAM;
                        N_SM_BANK_SEL   <=  ELINK10;                            -- CONNECT GENERIC RAM BANK SIGNALS TO ELINK10 RAM BANK
						N_ELK_N_ACTIVE	<=	'1';								-- SIGNIFIES THAT ONE OF THE 20 ELINK RAM BLOCKS ACTIVE FOR USB INTERAFCE ACCESS

                    WHEN TT_RD_ELK_RB11  =>                                     -- UPDATE THE ELINK REGISTER BANK 11
                        N_REG_STATE     <=  STORE_RAM;
                        N_SM_BANK_SEL   <=  ELINK11;                            -- CONNECT GENERIC RAM BANK SIGNALS TO ELINK11 RAM BANK
						N_ELK_N_ACTIVE	<=	'1';								-- SIGNIFIES THAT ONE OF THE 20 ELINK RAM BLOCKS ACTIVE FOR USB INTERAFCE ACCESS

                    WHEN TT_RD_ELK_RB12  =>                                     -- UPDATE THE ELINK REGISTER BANK 12
                        N_REG_STATE     <=  STORE_RAM;
                        N_SM_BANK_SEL   <=  ELINK12;                            -- CONNECT GENERIC RAM BANK SIGNALS TO ELINK12 RAM BANK
						N_ELK_N_ACTIVE	<=	'1';								-- SIGNIFIES THAT ONE OF THE 20 ELINK RAM BLOCKS ACTIVE FOR USB INTERAFCE ACCESS

                    WHEN TT_RD_ELK_RB13  =>                                     -- UPDATE THE ELINK REGISTER BANK 13
                        N_REG_STATE     <=  STORE_RAM;
                        N_SM_BANK_SEL   <=  ELINK13;                            -- CONNECT GENERIC RAM BANK SIGNALS TO ELINK13 RAM BANK
						N_ELK_N_ACTIVE	<=	'1';								-- SIGNIFIES THAT ONE OF THE 20 ELINK RAM BLOCKS ACTIVE FOR USB INTERAFCE ACCESS

                    WHEN TT_RD_ELK_RB14  =>                                     -- UPDATE THE ELINK REGISTER BANK 14
                        N_REG_STATE     <=  STORE_RAM;
                        N_SM_BANK_SEL   <=  ELINK14;                            -- CONNECT GENERIC RAM BANK SIGNALS TO ELINK14 RAM BANK
						N_ELK_N_ACTIVE	<=	'1';								-- SIGNIFIES THAT ONE OF THE 20 ELINK RAM BLOCKS ACTIVE FOR USB INTERAFCE ACCESS

                    WHEN TT_RD_ELK_RB15  =>                                     -- UPDATE THE ELINK REGISTER BANK 15
                        N_REG_STATE     <=  STORE_RAM;
                        N_SM_BANK_SEL   <=  ELINK15;                            -- CONNECT GENERIC RAM BANK SIGNALS TO ELINK15 RAM BANK
						N_ELK_N_ACTIVE	<=	'1';								-- SIGNIFIES THAT ONE OF THE 20 ELINK RAM BLOCKS ACTIVE FOR USB INTERAFCE ACCESS

                    WHEN TT_RD_ELK_RB16  =>                                     -- UPDATE THE ELINK REGISTER BANK 16
                        N_REG_STATE     <=  STORE_RAM;
                        N_SM_BANK_SEL   <=  ELINK16;                            -- CONNECT GENERIC RAM BANK SIGNALS TO ELINK16 RAM BANK
						N_ELK_N_ACTIVE	<=	'1';								-- SIGNIFIES THAT ONE OF THE 20 ELINK RAM BLOCKS ACTIVE FOR USB INTERAFCE ACCESS

                    WHEN TT_RD_ELK_RB17  =>                                     -- UPDATE THE ELINK REGISTER BANK 17
                        N_REG_STATE     <=  STORE_RAM;
                        N_SM_BANK_SEL   <=  ELINK17;                            -- CONNECT GENERIC RAM BANK SIGNALS TO ELINK17 RAM BANK
						N_ELK_N_ACTIVE	<=	'1';								-- SIGNIFIES THAT ONE OF THE 20 ELINK RAM BLOCKS ACTIVE FOR USB INTERAFCE ACCESS

                    WHEN TT_RD_ELK_RB18  =>                                     -- UPDATE THE ELINK REGISTER BANK 18
                        N_REG_STATE     <=  STORE_RAM;
                        N_SM_BANK_SEL   <=  ELINK18;                            -- CONNECT GENERIC RAM BANK SIGNALS TO ELINK18 RAM BANK
						N_ELK_N_ACTIVE	<=	'1';								-- SIGNIFIES THAT ONE OF THE 20 ELINK RAM BLOCKS ACTIVE FOR USB INTERAFCE ACCESS

                    WHEN TT_RD_ELK_RB19  =>                                     -- UPDATE THE ELINK REGISTER BANK 19
                        N_REG_STATE     <=  STORE_RAM;
                        N_SM_BANK_SEL   <=  ELINK19;                            -- CONNECT GENERIC RAM BANK SIGNALS TO ELINK19 RAM BANK
						N_ELK_N_ACTIVE	<=	'1';								-- SIGNIFIES THAT ONE OF THE 20 ELINK RAM BLOCKS ACTIVE FOR USB INTERAFCE ACCESS
--+++
                    WHEN TT_WR_ASR      =>                                      -- CONFIG USB WRITE:  SEND BACK ALL STATUS REGISTERS
                        N_WR_XFER_TYPE      <=  RD_USB_ADBUS;                   -- STORE THE USB WRITE MODE/TRANSFER TYPE FOR FUTURE WRITE OPS
                        N_REG_STATE         <=  TT_WAIT;                        -- HOST SENT REQUEST FOR TRANSFER--SO NOW GO SEND BACK DATA
                        N_SM_BANK_SEL       <=  INACTIVE;                       -- CONTROLS SIGNAL ACCESS TO THE VARIOUS RAM BANKS
						N_ELK_N_ACTIVE		<=	'0';							-- ELINK RAM BLOCKS NOT ACTIVE FOR USB INTERAFCE ACCESS

                    WHEN TT_WR_ACR      =>                                      -- CONFIG USB WRITE:  SEND BACK ALL CONTROL REGISTERS
                        N_WR_XFER_TYPE      <=  RD_USB_ADBUS;                   -- STORE THE USB WRITE MODE/TRANSFER TYPE FOR FUTURE WRITE OPS
                        N_REG_STATE         <=  TT_WAIT;                        -- HOST SENT REQUEST FOR TRANSFER--SO NOW GO SEND BACK DATA
                        N_SM_BANK_SEL       <=  INACTIVE;                       -- CONTROLS SIGNAL ACCESS TO THE VARIOUS RAM BANKS
						N_ELK_N_ACTIVE		<=	'0';							-- ELINK RAM BLOCKS NOT ACTIVE FOR USB INTERAFCE ACCESS

                    WHEN TT_WR_TFC_RB   =>                                      -- CONFIG USB WRITE:  SEND BACK THE TFC RAM BLOCK
                        N_WR_XFER_TYPE      <=  RD_USB_ADBUS;                   -- STORE THE USB WRITE MODE/TRANSFER TYPE FOR FUTURE WRITE OPS
                        N_REG_STATE         <=  TT_WAIT;                        -- HOST SENT REQUEST FOR TRANSFER--SO NOW GO SEND BACK DATA
                        N_SM_BANK_SEL       <=  TFC;                            -- CONNECT GENERIC RAM BANK SIGNALS TO TFC RAM BANK
						N_ELK_N_ACTIVE		<=	'0';							-- ELINK RAM BLOCKS NOT ACTIVE FOR USB INTERAFCE ACCESS

                    WHEN TT_WR_ELK_RB0  =>                                      -- CONFIG USB WRITE:  SEND BACK THE ELINK BLOCK 0 RAM BLOCK
                        N_WR_XFER_TYPE      <=  RD_USB_ADBUS;                   -- STORE THE USB WRITE MODE/TRANSFER TYPE FOR FUTURE WRITE OPS
                        N_REG_STATE         <=  TT_WAIT;                        -- HOST SENT REQUEST FOR TRANSFER--SO NOW GO SEND BACK DATA
                        N_SM_BANK_SEL       <=  ELINK0;                         -- CONNECT GENERIC RAM BANK SIGNALS TO ELINK0 RAM BANK
						N_ELK_N_ACTIVE		<=	'1';							-- SIGNIFIES THAT ONE OF THE 20 ELINK RAM BLOCKS ACTIVE FOR USB INTERAFCE ACCESS

                    WHEN TT_WR_ELK_RB1  =>                                      -- CONFIG USB WRITE:  SEND BACK THE ELINK BLOCK 0 RAM BLOCK
                        N_WR_XFER_TYPE      <=  RD_USB_ADBUS;                   -- STORE THE USB WRITE MODE/TRANSFER TYPE FOR FUTURE WRITE OPS
                        N_REG_STATE         <=  TT_WAIT;                        -- HOST SENT REQUEST FOR TRANSFER--SO NOW GO SEND BACK DATA
                        N_SM_BANK_SEL       <=  ELINK1;                         -- CONNECT GENERIC RAM BANK SIGNALS TO ELINK1 RAM BANK
						N_ELK_N_ACTIVE		<=	'1';							-- SIGNIFIES THAT ONE OF THE 20 ELINK RAM BLOCKS ACTIVE FOR USB INTERAFCE ACCESS

                    WHEN TT_WR_ELK_RB2  =>                                      -- CONFIG USB WRITE:  SEND BACK THE ELINK BLOCK 0 RAM BLOCK
                        N_WR_XFER_TYPE      <=  RD_USB_ADBUS;                   -- STORE THE USB WRITE MODE/TRANSFER TYPE FOR FUTURE WRITE OPS
                        N_REG_STATE         <=  TT_WAIT;                        -- HOST SENT REQUEST FOR TRANSFER--SO NOW GO SEND BACK DATA
                        N_SM_BANK_SEL       <=  ELINK2;                         -- CONNECT GENERIC RAM BANK SIGNALS TO ELINK2 RAM BANK
						N_ELK_N_ACTIVE		<=	'1';							-- SIGNIFIES THAT ONE OF THE 20 ELINK RAM BLOCKS ACTIVE FOR USB INTERAFCE ACCESS

                    WHEN TT_WR_ELK_RB3  =>                                      -- CONFIG USB WRITE:  SEND BACK THE ELINK BLOCK 0 RAM BLOCK
                        N_WR_XFER_TYPE      <=  RD_USB_ADBUS;                   -- STORE THE USB WRITE MODE/TRANSFER TYPE FOR FUTURE WRITE OPS
                        N_REG_STATE         <=  TT_WAIT;                        -- HOST SENT REQUEST FOR TRANSFER--SO NOW GO SEND BACK DATA
                        N_SM_BANK_SEL       <=  ELINK3;                         -- CONNECT GENERIC RAM BANK SIGNALS TO ELINK3 RAM BANK
						N_ELK_N_ACTIVE		<=	'1';							-- SIGNIFIES THAT ONE OF THE 20 ELINK RAM BLOCKS ACTIVE FOR USB INTERAFCE ACCESS

                    WHEN TT_WR_ELK_RB4  =>                                      -- CONFIG USB WRITE:  SEND BACK THE ELINK BLOCK 0 RAM BLOCK
                        N_WR_XFER_TYPE      <=  RD_USB_ADBUS;                   -- STORE THE USB WRITE MODE/TRANSFER TYPE FOR FUTURE WRITE OPS
                        N_REG_STATE         <=  TT_WAIT;                        -- HOST SENT REQUEST FOR TRANSFER--SO NOW GO SEND BACK DATA
                        N_SM_BANK_SEL       <=  ELINK4;                         -- CONNECT GENERIC RAM BANK SIGNALS TO ELINK4 RAM BANK
						N_ELK_N_ACTIVE		<=	'1';							-- SIGNIFIES THAT ONE OF THE 20 ELINK RAM BLOCKS ACTIVE FOR USB INTERAFCE ACCESS

                    WHEN TT_WR_ELK_RB5  =>                                      -- CONFIG USB WRITE:  SEND BACK THE ELINK BLOCK 0 RAM BLOCK
                        N_WR_XFER_TYPE      <=  RD_USB_ADBUS;                   -- STORE THE USB WRITE MODE/TRANSFER TYPE FOR FUTURE WRITE OPS
                        N_REG_STATE         <=  TT_WAIT;                        -- HOST SENT REQUEST FOR TRANSFER--SO NOW GO SEND BACK DATA
                        N_SM_BANK_SEL       <=  ELINK5;                         -- CONNECT GENERIC RAM BANK SIGNALS TO ELINK5 RAM BANK
						N_ELK_N_ACTIVE		<=	'1';							-- SIGNIFIES THAT ONE OF THE 20 ELINK RAM BLOCKS ACTIVE FOR USB INTERAFCE ACCESS

                    WHEN TT_WR_ELK_RB6  =>                                      -- CONFIG USB WRITE:  SEND BACK THE ELINK BLOCK 0 RAM BLOCK
                        N_WR_XFER_TYPE      <=  RD_USB_ADBUS;                   -- STORE THE USB WRITE MODE/TRANSFER TYPE FOR FUTURE WRITE OPS
                        N_REG_STATE         <=  TT_WAIT;                        -- HOST SENT REQUEST FOR TRANSFER--SO NOW GO SEND BACK DATA
                        N_SM_BANK_SEL       <=  ELINK6;                         -- CONNECT GENERIC RAM BANK SIGNALS TO ELINK6 RAM BANK
						N_ELK_N_ACTIVE		<=	'1';							-- SIGNIFIES THAT ONE OF THE 20 ELINK RAM BLOCKS ACTIVE FOR USB INTERAFCE ACCESS

                    WHEN TT_WR_ELK_RB7  =>                                      -- CONFIG USB WRITE:  SEND BACK THE ELINK BLOCK 0 RAM BLOCK
                        N_WR_XFER_TYPE      <=  RD_USB_ADBUS;                   -- STORE THE USB WRITE MODE/TRANSFER TYPE FOR FUTURE WRITE OPS
                        N_REG_STATE         <=  TT_WAIT;                        -- HOST SENT REQUEST FOR TRANSFER--SO NOW GO SEND BACK DATA
                        N_SM_BANK_SEL       <=  ELINK7;                         -- CONNECT GENERIC RAM BANK SIGNALS TO ELINK7 RAM BANK
						N_ELK_N_ACTIVE		<=	'1';							-- SIGNIFIES THAT ONE OF THE 20 ELINK RAM BLOCKS ACTIVE FOR USB INTERAFCE ACCESS

                    WHEN TT_WR_ELK_RB8  =>                                      -- CONFIG USB WRITE:  SEND BACK THE ELINK BLOCK 0 RAM BLOCK
                        N_WR_XFER_TYPE      <=  RD_USB_ADBUS;                   -- STORE THE USB WRITE MODE/TRANSFER TYPE FOR FUTURE WRITE OPS
                        N_REG_STATE         <=  TT_WAIT;                        -- HOST SENT REQUEST FOR TRANSFER--SO NOW GO SEND BACK DATA
                        N_SM_BANK_SEL       <=  ELINK8;                         -- CONNECT GENERIC RAM BANK SIGNALS TO ELINK8 RAM BANK
						N_ELK_N_ACTIVE		<=	'1';							-- SIGNIFIES THAT ONE OF THE 20 ELINK RAM BLOCKS ACTIVE FOR USB INTERAFCE ACCESS

                    WHEN TT_WR_ELK_RB9  =>                                      -- CONFIG USB WRITE:  SEND BACK THE ELINK BLOCK 0 RAM BLOCK
                        N_WR_XFER_TYPE      <=  RD_USB_ADBUS;                   -- STORE THE USB WRITE MODE/TRANSFER TYPE FOR FUTURE WRITE OPS
                        N_REG_STATE         <=  TT_WAIT;                        -- HOST SENT REQUEST FOR TRANSFER--SO NOW GO SEND BACK DATA
                        N_SM_BANK_SEL       <=  ELINK9;                         -- CONNECT GENERIC RAM BANK SIGNALS TO ELINK9 RAM BANK
						N_ELK_N_ACTIVE		<=	'1';							-- SIGNIFIES THAT ONE OF THE 20 ELINK RAM BLOCKS ACTIVE FOR USB INTERAFCE ACCESS

                    WHEN TT_WR_ELK_RB10  =>                                     -- CONFIG USB WRITE:  SEND BACK THE ELINK BLOCK 0 RAM BLOCK
                        N_WR_XFER_TYPE      <=  RD_USB_ADBUS;                   -- STORE THE USB WRITE MODE/TRANSFER TYPE FOR FUTURE WRITE OPS
                        N_REG_STATE         <=  TT_WAIT;                        -- HOST SENT REQUEST FOR TRANSFER--SO NOW GO SEND BACK DATA
                        N_SM_BANK_SEL       <=  ELINK10;                        -- CONNECT GENERIC RAM BANK SIGNALS TO ELINK10 RAM BANK
						N_ELK_N_ACTIVE		<=	'1';							-- SIGNIFIES THAT ONE OF THE 20 ELINK RAM BLOCKS ACTIVE FOR USB INTERAFCE ACCESS

                    WHEN TT_WR_ELK_RB11  =>                                     -- CONFIG USB WRITE:  SEND BACK THE ELINK BLOCK 0 RAM BLOCK
                        N_WR_XFER_TYPE      <=  RD_USB_ADBUS;                   -- STORE THE USB WRITE MODE/TRANSFER TYPE FOR FUTURE WRITE OPS
                        N_REG_STATE         <=  TT_WAIT;                        -- HOST SENT REQUEST FOR TRANSFER--SO NOW GO SEND BACK DATA
                        N_SM_BANK_SEL       <=  ELINK11;                        -- CONNECT GENERIC RAM BANK SIGNALS TO ELINK11 RAM BANK
						N_ELK_N_ACTIVE		<=	'1';							-- SIGNIFIES THAT ONE OF THE 20 ELINK RAM BLOCKS ACTIVE FOR USB INTERAFCE ACCESS

                    WHEN TT_WR_ELK_RB12  =>                                     -- CONFIG USB WRITE:  SEND BACK THE ELINK BLOCK 0 RAM BLOCK
                        N_WR_XFER_TYPE      <=  RD_USB_ADBUS;                   -- STORE THE USB WRITE MODE/TRANSFER TYPE FOR FUTURE WRITE OPS
                        N_REG_STATE         <=  TT_WAIT;                        -- HOST SENT REQUEST FOR TRANSFER--SO NOW GO SEND BACK DATA
                        N_SM_BANK_SEL       <=  ELINK12;                        -- CONNECT GENERIC RAM BANK SIGNALS TO ELINK12 RAM BANK
						N_ELK_N_ACTIVE		<=	'1';							-- SIGNIFIES THAT ONE OF THE 20 ELINK RAM BLOCKS ACTIVE FOR USB INTERAFCE ACCESS

                    WHEN TT_WR_ELK_RB13  =>                                     -- CONFIG USB WRITE:  SEND BACK THE ELINK BLOCK 0 RAM BLOCK
                        N_WR_XFER_TYPE      <=  RD_USB_ADBUS;                   -- STORE THE USB WRITE MODE/TRANSFER TYPE FOR FUTURE WRITE OPS
                        N_REG_STATE         <=  TT_WAIT;                        -- HOST SENT REQUEST FOR TRANSFER--SO NOW GO SEND BACK DATA
                        N_SM_BANK_SEL       <=  ELINK13;                        -- CONNECT GENERIC RAM BANK SIGNALS TO ELINK13 RAM BANK
						N_ELK_N_ACTIVE		<=	'1';							-- SIGNIFIES THAT ONE OF THE 20 ELINK RAM BLOCKS ACTIVE FOR USB INTERAFCE ACCESS

                    WHEN TT_WR_ELK_RB14  =>                                     -- CONFIG USB WRITE:  SEND BACK THE ELINK BLOCK 0 RAM BLOCK
                        N_WR_XFER_TYPE      <=  RD_USB_ADBUS;                   -- STORE THE USB WRITE MODE/TRANSFER TYPE FOR FUTURE WRITE OPS
                        N_REG_STATE         <=  TT_WAIT;                        -- HOST SENT REQUEST FOR TRANSFER--SO NOW GO SEND BACK DATA
                        N_SM_BANK_SEL       <=  ELINK14;                        -- CONNECT GENERIC RAM BANK SIGNALS TO ELINK14 RAM BANK
						N_ELK_N_ACTIVE		<=	'1';							-- SIGNIFIES THAT ONE OF THE 20 ELINK RAM BLOCKS ACTIVE FOR USB INTERAFCE ACCESS

                    WHEN TT_WR_ELK_RB15  =>                                     -- CONFIG USB WRITE:  SEND BACK THE ELINK BLOCK 0 RAM BLOCK
                        N_WR_XFER_TYPE      <=  RD_USB_ADBUS;                   -- STORE THE USB WRITE MODE/TRANSFER TYPE FOR FUTURE WRITE OPS
                        N_REG_STATE         <=  TT_WAIT;                        -- HOST SENT REQUEST FOR TRANSFER--SO NOW GO SEND BACK DATA
                        N_SM_BANK_SEL       <=  ELINK15;                        -- CONNECT GENERIC RAM BANK SIGNALS TO ELINK15 RAM BANK
						N_ELK_N_ACTIVE		<=	'1';							-- SIGNIFIES THAT ONE OF THE 20 ELINK RAM BLOCKS ACTIVE FOR USB INTERAFCE ACCESS

                    WHEN TT_WR_ELK_RB16  =>                                     -- CONFIG USB WRITE:  SEND BACK THE ELINK BLOCK 0 RAM BLOCK
                        N_WR_XFER_TYPE      <=  RD_USB_ADBUS;                   -- STORE THE USB WRITE MODE/TRANSFER TYPE FOR FUTURE WRITE OPS
                        N_REG_STATE         <=  TT_WAIT;                        -- HOST SENT REQUEST FOR TRANSFER--SO NOW GO SEND BACK DATA
                        N_SM_BANK_SEL       <=  ELINK16;                        -- CONNECT GENERIC RAM BANK SIGNALS TO ELINK16 RAM BANK
						N_ELK_N_ACTIVE		<=	'1';							-- SIGNIFIES THAT ONE OF THE 20 ELINK RAM BLOCKS ACTIVE FOR USB INTERAFCE ACCESS

                    WHEN TT_WR_ELK_RB17  =>                                     -- CONFIG USB WRITE:  SEND BACK THE ELINK BLOCK 0 RAM BLOCK
                        N_WR_XFER_TYPE      <=  RD_USB_ADBUS;                   -- STORE THE USB WRITE MODE/TRANSFER TYPE FOR FUTURE WRITE OPS
                        N_REG_STATE         <=  TT_WAIT;                        -- HOST SENT REQUEST FOR TRANSFER--SO NOW GO SEND BACK DATA
                        N_SM_BANK_SEL       <=  ELINK17;                        -- CONNECT GENERIC RAM BANK SIGNALS TO ELINK17 RAM BANK
						N_ELK_N_ACTIVE		<=	'1';							-- SIGNIFIES THAT ONE OF THE 20 ELINK RAM BLOCKS ACTIVE FOR USB INTERAFCE ACCESS

                    WHEN TT_WR_ELK_RB18  =>                                     -- CONFIG USB WRITE:  SEND BACK THE ELINK BLOCK 0 RAM BLOCK
                        N_WR_XFER_TYPE      <=  RD_USB_ADBUS;                   -- STORE THE USB WRITE MODE/TRANSFER TYPE FOR FUTURE WRITE OPS
                        N_REG_STATE         <=  TT_WAIT;                        -- HOST SENT REQUEST FOR TRANSFER--SO NOW GO SEND BACK DATA
                        N_SM_BANK_SEL       <=  ELINK18;                        -- CONNECT GENERIC RAM BANK SIGNALS TO ELINK18 RAM BANK
						N_ELK_N_ACTIVE		<=	'1';							-- SIGNIFIES THAT ONE OF THE 20 ELINK RAM BLOCKS ACTIVE FOR USB INTERAFCE ACCESS

                    WHEN TT_WR_ELK_RB19  =>                                     -- CONFIG USB WRITE:  SEND BACK THE ELINK BLOCK 0 RAM BLOCK
                        N_WR_XFER_TYPE      <=  RD_USB_ADBUS;                   -- STORE THE USB WRITE MODE/TRANSFER TYPE FOR FUTURE WRITE OPS
                        N_REG_STATE         <=  TT_WAIT;                        -- HOST SENT REQUEST FOR TRANSFER--SO NOW GO SEND BACK DATA
                        N_SM_BANK_SEL       <=  ELINK19;                        -- CONNECT GENERIC RAM BANK SIGNALS TO ELINK19 RAM BANK
						N_ELK_N_ACTIVE		<=	'1';							-- SIGNIFIES THAT ONE OF THE 20 ELINK RAM BLOCKS ACTIVE FOR USB INTERAFCE ACCESS

--+++
    -- ADD ADDITIONAL ELINK REGISTER BANKS HERE!!!!!

                    WHEN OTHERS     =>
                        N_REG_STATE     <=  INIT;
                        N_USB_OE_BI     <=  '1';                                -- DE-ACTIVATE THE USB DATA BUS
                        N_USB_RD_BI     <=  '1';                                -- READ OPERATION STOPPED
                        N_SM_BANK_SEL   <=  INACTIVE;                           -- CONTROLS SIGNAL ACCESS TO THE VARIOUS RAM BANKS
						N_ELK_N_ACTIVE	<=	'0';								-- ELINK RAM BLOCKS NOT ACTIVE FOR USB INTERAFCE ACCESS
                END CASE;
            ELSE                                                                -- GLITCH RECOVERY/TRUNCATED TRANSFER!
                N_REG_STATE     <=  INIT;
                N_USB_OE_BI     <=  '1';                                        -- DE-ACTIVATE THE USB DATA BUS
                N_USB_RD_BI     <=  '1';                                        -- READ OPERATION STOPPED
            END IF;

--+++
        WHEN TT_WAIT        =>                                      -- WAIT FOR THE FPGA READ PORTION OF THE TT REQUEST TO COMPLETE BEFORE WRITING DATA BACK TO THE HOST
            IF USB_RXF_B = '1'  THEN
                N_REG_STATE         <=  TX_TO_HOST;                
                N_USB_OE_BI         <=  '1';                        -- DE-ACTIVATE THE USB DATA BUS
                N_USB_RD_BI         <=  '1';                        -- DISABLE READ OP
            ELSE
                N_REG_STATE         <=  TT_WAIT;   
            END IF;

-- +++++++++++++
-- SEQUENTIALLY STORE ALL THE REGISTERS
        WHEN STORE_ALL_REG          =>                                          -- STORE THE OPERATING MODE BYTE NOW PRESENT ON THE USB MODULE BUS
            IF USB_RXF_B = '0' THEN                                             
                N_OP_MODE_T             <=  RD_USB_ADBUS;                       -- STORE THE OP MODE
                N_REG_STATE             <=  REQ_TFC_STRT_ADDR;
            ELSE                                                                -- READ OP TERMINATED BY HOST
                N_REG_STATE             <=  INIT;                               -- READ TRANSFER TERMINATED
                N_USB_OE_BI             <=  '1';                                -- DE-ACTIVATE THE USB DATA BUS
                N_USB_RD_BI             <=  '1';                                -- DISABLE READ OP
            END IF;

        WHEN REQ_TFC_STRT_ADDR    =>                                            -- STORE THE TFC START ADDR BYTE NOW PRESENT ON THE USB MODULE BUS
            IF USB_RXF_B = '0' THEN                                             
                N_TFC_STRT_ADDR_T       <=  RD_USB_ADBUS;                       -- USE THE TEMPORARY REGISTER
                N_REG_STATE             <=  REQ_TFC_STOP_ADDR;
            ELSE                                                                -- READ OP TERMINATED BY HOST
                N_REG_STATE             <=  INIT;                               -- READ TRANSFER TERMINATED
                N_USB_OE_BI             <=  '1';                                -- DE-ACTIVATE THE USB DATA BUS
                N_USB_RD_BI             <=  '1';                                -- DISABLE READ OP
            END IF;

        WHEN REQ_TFC_STOP_ADDR    =>                                            -- STORE THE TFC STOP ADDR BYTE NOW PRESENT ON THE USB MODULE BUS  
            IF USB_RXF_B = '0' THEN                                             
                N_TFC_STOP_ADDR_T       <=  RD_USB_ADBUS;                       -- USE THE TEMPORARY REGISTER
                N_REG_STATE             <=  REQ_ELINKS_STRT_ADDR;
            ELSE                                                                -- READ OP TERMINATED BY HOST
                N_REG_STATE             <=  INIT;                               -- READ TRANSFER TERMINATED
                N_USB_OE_BI             <=  '1';                                -- DE-ACTIVATE THE USB DATA BUS
                N_USB_RD_BI             <=  '1';                                -- DISABLE READ OP
            END IF;

        WHEN REQ_ELINKS_STRT_ADDR =>                                            -- STORE THE ELINKS START ADDR BYTE NOW PRESENT ON THE USB MODULE BUS  
            IF USB_RXF_B = '0' THEN                                             
                N_ELINKS_STRT_ADDR_T    <=  RD_USB_ADBUS;                       -- USE THE TEMPORARY REGISTER
                N_REG_STATE             <=  REQ_ELINKS_STOP_ADDR;
            ELSE                                                                -- READ OP TERMINATED BY HOST
                N_REG_STATE             <=  INIT;                               -- READ TRANSFER TERMINATED
                N_USB_OE_BI             <=  '1';                                -- DE-ACTIVATE THE USB DATA BUS
                N_USB_RD_BI             <=  '1';                                -- DISABLE READ OP
            END IF;

        WHEN REQ_ELINKS_STOP_ADDR =>                                            -- STORE THE ELINKS STOP ADDR BYTE NOW PRESENT ON THE USB MODULE BUS  
            IF USB_RXF_B = '0' THEN                                             
                N_ELINKS_STOP_ADDR_T    <=  RD_USB_ADBUS;                       -- USE THE TEMPORARY REGISTER
                N_REG_STATE             <=  REQ_CHKSUM;
            ELSE                                                                -- READ OP TERMINATED BY HOST
                N_REG_STATE             <=  INIT;                               -- READ TRANSFER TERMINATED
                N_USB_OE_BI             <=  '1';                                -- DE-ACTIVATE THE USB DATA BUS
                N_USB_RD_BI             <=  '1';                                -- DISABLE READ OP
            END IF;

-- +++++++++++++
-- STORE TO A RAM BLOCK--ASSUMES BLOCK SIZE OF 256 BYTES ALWAYS
        WHEN STORE_RAM  =>                                                      -- NEED TO STORE THE TFC REGISTER BLOCK --BUT NEED THIS EXTRA STEP TO FILL THE PIPELINE!
            IF USB_RXF_B = '0' THEN                                             
                X_BLKA              <=  '0';                                    -- ENABLE THE RAM PORT
                X_RWA               <=  '0';                                    -- FOR A WRITE OPERATION
                X_DINA              <=  '0' & RD_USB_ADBUS;                     -- MUX THE USB BUS TO THE RAM INPUT PORT SIGNAL
                N_REG_ADDR          <=  REG_ADDR + "1";                         -- AUTO INCREMENT THE ADDR POINTER

				-- THIS IS A MUX FOR THE RAM ADDRESS BUS: EITHER TFC RAM BLOCK, ONE OF 20 ELINK RAM BLOCKS, OR NADA.
				-- THE MUX OUTPUT FEEDS FF'S IN THE CASE STATEMENT JUST AHEAD OF THE STATE MACHINE
                CASE SM_BANK_SEL IS												
                    WHEN TFC    =>
                        X_ADDRA     <=  TFC_ADDR8B & REG_ADDR(7 DOWNTO 0);      	-- GENERATE THE FULL 512 BYTE RAM ADDRESS
                    WHEN OTHERS =>
						IF ELK_N_ACTIVE = '1' THEN
							X_ADDRA     <=  ELINK_ADDR8B & REG_ADDR(7 DOWNTO 0);   	-- GENERATE THE FULL 512 BYTE RAM ADDRESS
						ELSE
							X_ADDRA     <=  (OTHERS => '0');
						END IF;	
                END CASE;
				
                N_REG_STATE         <=  STORE_RAM1;
 
            ELSE                                                                -- READ OP TERMINATED BY HOST
                N_REG_STATE             <=  INIT;                               -- READ TRANSFER TERMINATED
                N_USB_OE_BI             <=  '1';                                -- DE-ACTIVATE THE USB DATA BUS
                N_USB_RD_BI             <=  '1';                                -- DISABLE READ OP

            END IF;
 
        WHEN STORE_RAM1  =>                                                     -- NEED TO STORE THE RAM BLOCK 
            IF USB_RXF_B = '0' THEN                                             
                X_BLKA              <=  '0';                                    -- ENABLE THE RAM PORT
                X_RWA               <=  '0';                                    -- FOR A WRITE OPERATION
                X_DINA              <=  '0' & RD_USB_ADBUS;                     -- MUX THE USB BUS TO THE RAM INPUT PORT SIGNAL
                N_REG_ADDR          <=  REG_ADDR + "1";                         -- AUTO INCREMENT THE ADDR POINTER

				-- THIS IS A MUX FOR THE RAM ADDRESS BUS: EITHER TFC RAM BLOCK, ONE OF 20 ELINK RAM BLOCKS, OR NADA.
				-- THE MUX OUTPUT FEEDS FF'S IN THE CASE STATEMENT JUST AHEAD OF THE STATE MACHINE
                CASE SM_BANK_SEL IS												
                    WHEN TFC    =>
                        X_ADDRA     <=  TFC_ADDR8B & REG_ADDR(7 DOWNTO 0);          -- GENERATE THE FULL 512 BYTE RAM ADDRESS
                    WHEN OTHERS =>
						IF ELK_N_ACTIVE = '1' THEN
							X_ADDRA     <=  ELINK_ADDR8B & REG_ADDR(7 DOWNTO 0);   	-- GENERATE THE FULL 512 BYTE RAM ADDRESS
						ELSE
							X_ADDRA     <=  (OTHERS => '0');
						END IF;	
                END CASE;

				
                IF REG_ADDR = "011111111" THEN                                  -- COMPLETE AFTER 256 BYTES
                    N_REG_STATE             <=  REQ_CHKSUM;
                ELSE
                    N_REG_STATE             <=  STORE_RAM1;
                END IF;
            ELSE                                                                -- READ OP TERMINATED BY HOST
                N_REG_STATE             <=  INIT;                               -- READ TRANSFER TERMINATED
                N_USB_OE_BI             <=  '1';                                -- DE-ACTIVATE THE USB DATA BUS
                N_USB_RD_BI             <=  '1';                                -- DISABLE READ OP
            END IF;


--+++++++++++++++
--END OF PACKET: READ THE PACKET CHKSUM & STOP_HEADER
    -- ADD A CHKSUM VERIFICATION HERE
        WHEN REQ_CHKSUM         =>                                              -- PACKET CHKSUM BYTE NOW PRESENT ON THE USB MODULE BUS
            IF USB_RXF_B = '0' THEN                                             
                N_CHKSUM                <=  RD_USB_ADBUS;                       -- USE THE TEMPORARY REGISTER
                N_REG_STATE             <=  REQ_STP_HDR;
                X_BLKA                  <=  '1';                                -- ACTIVE LOW--DISABLE THIS RAM BLOCK INTERFACE WHEN DONE
            ELSE                                                                -- READ OP TERMINATED BY HOST
                N_REG_STATE             <=  INIT;                               -- READ TRANSFER TERMINATED
            END IF;

        WHEN REQ_STP_HDR        =>                                              -- STOP HEADER BYTE NOW PRESENT ON THE USB BUS
            IF (RD_USB_ADBUS = STOP_BYTE ) THEN

				CASE RD_XFER_TYPE IS
					WHEN TT_RD_ACR 		=>										-- THIS IS AN UPDATE OF THE CONTROL REGISTERS 
						N_REG_STATE     <=  SWAP_REG_VALS;
					
					WHEN TT_RD_TFC_RB 	=>		                        		-- THIS IS AN UPDATE OF THE TFC PATTERN
						N_REG_STATE     <=  SWAP_TFC_VALS;

					WHEN OTHERS    		=>          
						IF ELK_N_ACTIVE = '1' THEN         						-- THIS IS AN UPDATE OF THE 0 ELINK PATTERN
								N_REG_STATE     <=  SWAP_0_ELINK_VALS;
						ELSE
								N_REG_STATE     <=  INIT;
						END IF;	
				END CASE;

			ELSE
				N_REG_STATE     <=  INIT;
			END IF;

			
        WHEN SWAP_REG_VALS      =>                                              -- MOVE THE TEMPORARY VALUES TO THE WORKING VALUES SIMULTANEOUSLY
            N_OP_MODE               <=  OP_MODE_T;                              -- NOTE:  THE PATT GEN'S LATCH A LOCAL COPY WHNE INITIALLY ENABLED

            N_TFC_STRT_ADDR         <=  TFC_STRT_ADDR_T;
            N_TFC_STOP_ADDR         <=  TFC_STOP_ADDR_T;
            N_ELINKS_STRT_ADDR      <=  ELINKS_STRT_ADDR_T;
            N_ELINKS_STOP_ADDR      <=  ELINKS_STOP_ADDR_T;
 
            N_REG_STATE             <=  FPGA_RD_HOLD;

        WHEN SWAP_TFC_VALS      =>                                              -- PLACEHOLDER STATE 
            N_REG_STATE         <=  FPGA_RD_HOLD;                

        WHEN SWAP_0_ELINK_VALS  =>                                              -- PLACEHOLDER STATE 
            N_REG_STATE         <=  FPGA_RD_HOLD;                

        WHEN FPGA_RD_HOLD       =>                                              -- WAIT HERE UNTIL THE USB MODULE DE-ASSERTS USB_RXF_B
            IF USB_RXF_B = '1'  THEN
                N_REG_STATE         <=  INIT;                
                N_USB_OE_BI         <=  '1';                                    -- DE-ACTIVATE THE USB DATA BUS
                N_USB_RD_BI         <=  '1';                                    -- DISABLE READ OP
            ELSE
                N_REG_STATE         <=  FPGA_RD_HOLD;   
            END IF;

--+++++++++++
-- TRANSFER FROM FPGA TO USB VIA USB WRITE OP
-- THE DATA TYPE TO BE TRANSFERED IS STORED IN WR_XFER_TYPE (UPDATED AS PART OF A PREVIOUS USB READ OP)
-- FOUR DATA TRANSFER TYPES:  TT_WR_ASR, TT_WR_ACR, TT_WR_TFC_RB, TT_WR_ELK_RB_N (IE N = 20 ELINKS)

        WHEN TX_TO_HOST    =>                                                   -- FIRST DETERMINE THE TRANSFER TYPE 
            N_USB_WR_ACTIVE     <=  '1';                                        -- FLAG INDICATES WRITE OP IS NOW ACTIVE

            IF USB_TXE_B = '0' THEN                                             
                N_USB_TRIEN_B   <=  '0';                                        -- ENABLE THE USB BUS DRIVER NOW SO IT IS READY FOR DATA TX MODE
                --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                -- DETERMINE THE REQUESTED DATA TO SEND BACK
                CASE WR_XFER_TYPE IS

					WHEN TT_WR_ASR      =>                                      -- SEND ALL OF THE STATUS REGISTERS
                        N_REG_STATE     <=  INIT;                               -- PLACEHOLDER FOR NOW

                    WHEN TT_WR_ACR      =>                                      -- SEND ALL OF THE CONTROL REGISTERS
                        N_REG_STATE     <=  SEND_ACR;                           -- SEND ALL CONTROL REGISTERS

                    WHEN TT_WR_TFC_RB   =>                                      -- SEND THE TFC REGISTER BANK
                        N_REG_STATE     <=  SEND_RB;                            -- SEND VIA COMMON RAM BANK STATES
                        N_SM_BANK_SEL   <=  TFC;                                -- CONNECT GENERIC RAM BANK SIGNALS TO TFC RAM BANK

                    WHEN OTHERS     =>											-- EITHER ONE OF THE 20 ELINKS OR NADA
						IF ELK_N_ACTIVE = '1' THEN
							N_REG_STATE     <=  SEND_RB;                        -- SEND VIA COMMON RAM BANK STATES
						ELSE
							N_REG_STATE     <=  INIT;
						END IF;
 
                END CASE;
                --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            ELSE                                                                -- WRITE OP TERMINATED BY HOST
                N_REG_STATE             <=  INIT;                               -- WRITE OP TERMINATED
            END IF;

--++++++++
-- SEND ALL CONTROL REGISTERS IN THE FOLLOWING SEQUENCE:
--   (OVERHEAD ITEMS FIRST: START HEADER, TRANSFER TYPE), OP_MODE, TFC_STRT_ADDR, TFC_STOP_ADDR, ELINKS_STRT_ADDR, ELINKS_STOP_ADDR
        WHEN SEND_ACR       =>                                                  -- START HEADER BYTE
            IF USB_TXE_B = '0' THEN                                             
                N_USB_WR_BI         <=  '0';                                    -- ASSERT THE USB_WRITE EN
                N_WR_USB_ADBUS      <=  START_BYTE;                             -- MOVE THE DESIRED REGISTER OUTPUT TO THE USB DATA BUS OUTPUT.
                N_REG_STATE         <=  SEND_ACR1;
            ELSE                                                                -- WRITE OP TERMINATED BY HOST
                N_REG_STATE         <=  INIT;                                   -- WRITE OP TERMINATED
                N_USB_WR_BI         <=  '1';                                    -- DISABLE WRITE OP
            END IF;

        WHEN SEND_ACR1       =>                                                 -- USB WRITE MODE BYTE
            IF USB_TXE_B = '0' THEN                                             
                N_USB_WR_BI         <=  '0';                                    -- ASSERT THE USB_WRITE EN
                N_WR_USB_ADBUS      <=  WR_XFER_TYPE;                           -- MOVE THE DESIRED REGISTER OUTPUT TO THE USB DATA BUS OUTPUT.
                N_REG_STATE         <=  SEND_ACR2;
            ELSE                                                                -- WRITE OP TERMINATED BY HOST
                N_REG_STATE         <=  INIT;                                   -- WRITE OP TERMINATED
                N_USB_WR_BI         <=  '1';                                    -- DISABLE WRITE OP
            END IF;

        WHEN SEND_ACR2       =>                                                 -- OP MODE BYTE
            IF USB_TXE_B = '0' THEN                                             
                N_USB_WR_BI         <=  '0';                                    -- ASSERT THE USB_WRITE EN
                N_WR_USB_ADBUS      <=  OP_MODE;                                -- MOVE THE DESIRED REGISTER OUTPUT TO THE USB DATA BUS OUTPUT.
                N_REG_STATE         <=  SEND_ACR3;
            ELSE                                                                -- WRITE OP TERMINATED BY HOST
                N_REG_STATE         <=  INIT;                                   -- WRITE OP TERMINATED
                N_USB_WR_BI         <=  '1';                                    -- DISABLE WRITE OP
            END IF;

        WHEN SEND_ACR3      =>                                                  -- TFC_START_ADDR BYTE
            IF USB_TXE_B = '0' THEN                                                 
                N_USB_WR_BI         <=  '0';                                    -- ASSERT THE USB_WRITE EN
                N_WR_USB_ADBUS      <=  TFC_STRT_ADDR;                          -- MOVE THE DESIRED REGISTER OUTPUT TO THE USB DATA BUS OUTPUT.
                N_REG_STATE         <=  SEND_ACR4;
            ELSE                                                                -- WRITE OP TERMINATED BY HOST
                N_REG_STATE         <=  INIT;                                   -- WRITE OP TERMINATED
                N_USB_WR_BI         <=  '1';                                    -- DISABLE WRITE OP
            END IF;

        WHEN SEND_ACR4      =>                                                  -- TFC_STOP_ADDR BYTE
            IF USB_TXE_B = '0' THEN                                             
                N_USB_WR_BI         <=  '0';                                    -- ASSERT THE USB_WRITE EN
                N_WR_USB_ADBUS      <=  TFC_STOP_ADDR;                          -- MOVE THE DESIRED REGISTER OUTPUT TO THE USB DATA BUS OUTPUT.
                N_REG_STATE         <=  SEND_ACR5;
            ELSE                                                                -- WRITE OP TERMINATED BY HOST
               N_REG_STATE         <=  INIT;                                   -- WRITE OP TERMINATED
                N_USB_WR_BI         <=  '1';                                    -- DISABLE WRITE OP
            END IF;

        WHEN SEND_ACR5      =>                                                  -- ELINKS_START_ADDR BYTE
            IF USB_TXE_B = '0' THEN                                             
                N_USB_WR_BI         <=  '0';                                    -- ASSERT THE USB_WRITE EN
                N_WR_USB_ADBUS      <=  ELINKS_STRT_ADDR;                       -- MOVE THE DESIRED REGISTER OUTPUT TO THE USB DATA BUS OUTPUT.
                N_REG_STATE         <=  SEND_ACR6;
            ELSE                                                                -- WRITE OP TERMINATED BY HOST
                N_REG_STATE         <=  INIT;                                   -- WRITE OP TERMINATED
                N_USB_WR_BI         <=  '1';                                    -- DISABLE WRITE OP
            END IF;

        WHEN SEND_ACR6      =>                                                  -- ELINKS_STOP_ADDR BYTE
            IF USB_TXE_B = '0' THEN                                             
                N_USB_WR_BI         <=  '0';                                    -- ASSERT THE USB_WRITE EN
                N_WR_USB_ADBUS      <=  ELINKS_STOP_ADDR;                       -- MOVE THE DESIRED REGISTER OUTPUT TO THE USB DATA BUS OUTPUT.
                N_REG_STATE         <=  SEND_ACR7;
            ELSE                                                                -- WRITE OP TERMINATED BY HOST
                N_REG_STATE         <=  INIT;                                   -- WRITE OP TERMINATED
                N_USB_WR_BI         <=  '1';                                    -- DISABLE WRITE OP
            END IF;        

        WHEN SEND_ACR7      =>                                                  -- SEND THE PACKET CHECKSUM
            IF USB_TXE_B = '0' THEN                                             
                N_USB_WR_BI         <=  '0';                                    -- ASSERT THE USB_WRITE EN
                N_WR_USB_ADBUS      <=  CHKSUM;                                 -- MUX THE CHKSUM TO THE USB DATA BUS PORT REGISTER
                N_REG_STATE         <=  SEND_ACR8;
            ELSE                                                                -- WRITE OP TERMINATED BY HOST
                N_REG_STATE         <=  INIT;                                   -- WRITE OP TERMINATED
                N_USB_WR_BI         <=  '1';                                    -- DISABLE WRITE OP
            END IF;        

        WHEN SEND_ACR8      =>                                                  -- SEND THE PACKET HEADER STOP BYTE
            IF USB_TXE_B = '0' THEN                                             
                N_USB_WR_BI         <=  '0';                                    -- ASSERT THE USB_WRITE EN
                N_WR_USB_ADBUS      <=  STOP_BYTE;                              -- MUX THE STOP HEADER BYTE TO THE USB DATA BUS PORT REGISTER
                N_REG_STATE         <=  SEND_ACR9;
            ELSE                                                                -- WRITE OP TERMINATED BY HOST
                N_REG_STATE         <=  INIT;                                   -- WRITE OP TERMINATED
                N_USB_WR_BI         <=  '1';                                    -- DISABLE WRITE OP
            END IF;        

        WHEN SEND_ACR9      =>                                                  -- EMPTY THE PIPELINE
                N_USB_WR_BI         <=  '1';                                    -- ASSERT THE USB_WRITE EN
                N_REG_STATE         <=  SEND_ACR10;

        WHEN SEND_ACR10      =>                                                 -- EMPTY THE PIPELINE
                N_USB_WR_BI         <=  '1';                                    -- ASSERT THE USB_WRITE EN
                N_REG_STATE         <=  SEND_ACR11;

        WHEN SEND_ACR11      =>                                                 -- SIWU_B='0' FOR 15 CLOCK CYCLES: FORCE THE FIFO IN THE USB MODULE TO FLUSH CONTENTS TO THE HOST

            IF SI_CNT < "1111"  THEN
                N_USB_SIWU_BI   <=  '0';
                N_SI_CNT        <=  SI_CNT + '1';
                N_REG_STATE     <=  SEND_ACR11;
            ELSE
                N_USB_SIWU_BI   <=  '1';
                N_SI_CNT        <=  "0000";
                N_REG_STATE     <=  INIT;
            END IF;

        --WHEN SEND_ACR_HOLD  =>                                                  -- WAIT HERE UNTIL THE HOST DE-ASSERTS THE USB_TXE_B
            --IF USB_TXE_B = '1' THEN
                --N_REG_STATE     <=  INIT;
            --ELSE
                --N_REG_STATE     <=  SEND_ACR_HOLD;
            --END IF;

--++++++++
-- SEND THE ENTIRE 256 BYTE REGISTER BANK -HANDLES BOTH THE SINGLE TFC AND UPTO 20 ELINKx REGISTER BANKS
        WHEN SEND_RB    =>                                                      -- START TO FILL THE PIPELINE-- REG_ADDR REGISTER
                N_REG_STATE         <=  SEND_RB1;
                X_BLKA              <=  '0';                                    -- ENABLE THE RAM PORT (NEED TO START FILLING THE PIPELINE)
                X_RWA               <=  '1';                                    -- FOR A READ OPERATION
                N_REG_ADDR          <=  REG_ADDR + "1";                         -- INCREMENT THE ADDR POINTER

				-- THIS IS A MUX FOR THE RAM ADDRESS BUS: EITHER TFC RAM BLOCK, ONE OF 20 ELINK RAM BLOCKS, OR NADA.
				-- THE MUX OUTPUT FEEDS FF'S IN THE CASE STATEMENT JUST AHEAD OF THE STATE MACHINE
                CASE SM_BANK_SEL IS												
                    WHEN TFC    =>
                        X_ADDRA     <=  TFC_ADDR8B & REG_ADDR(7 DOWNTO 0);          -- GENERATE THE FULL 512 BYTE RAM ADDRESS
                    WHEN OTHERS =>
						IF ELK_N_ACTIVE = '1' THEN
							X_ADDRA     <=  ELINK_ADDR8B & REG_ADDR(7 DOWNTO 0);   	-- GENERATE THE FULL 512 BYTE RAM ADDRESS
						ELSE
							X_ADDRA     <=  (OTHERS => '0');
						END IF;	
                END CASE;


        WHEN SEND_RB1    =>                                                     -- SEND THE START BYTE WHILE THE TFC RAM BANK PIPELINE IS GETTING FILLED
            IF USB_TXE_B = '0' THEN                                             
                N_REG_STATE         <=  SEND_RB2;
                N_WR_USB_ADBUS      <=  START_BYTE;                             -- MUX THE RAM A PORT OUTPUT TO THE USB DATA BUS PORT REGISTER
                N_USB_WR_BI         <=  '0';                                    -- ASSERT THE USB_WRITE EN
                X_BLKA              <=  '0';                                    -- ENABLE THE RAM PORT
                X_RWA               <=  '1';                                    -- FOR A READ OPERATION
                N_REG_ADDR          <=  REG_ADDR + "1";                         -- INCREMENT THE ADDR POINTER

				-- THIS IS A MUX FOR THE RAM ADDRESS BUS: EITHER TFC RAM BLOCK, ONE OF 20 ELINK RAM BLOCKS, OR NADA.
				-- THE MUX OUTPUT FEEDS FF'S IN THE CASE STATEMENT JUST AHEAD OF THE STATE MACHINE
                CASE SM_BANK_SEL IS												
                    WHEN TFC    =>
                        X_ADDRA     <=  TFC_ADDR8B & REG_ADDR(7 DOWNTO 0);          -- GENERATE THE FULL 512 BYTE RAM ADDRESS
                    WHEN OTHERS =>
						IF ELK_N_ACTIVE = '1' THEN
							X_ADDRA     <=  ELINK_ADDR8B & REG_ADDR(7 DOWNTO 0);   	-- GENERATE THE FULL 512 BYTE RAM ADDRESS
						ELSE
							X_ADDRA     <=  (OTHERS => '0');
						END IF;	
                END CASE;

            ELSE                                                                -- WRITE OP TERMINATED BY HOST
                N_REG_STATE         <=  INIT;                                   -- WRITE OP TERMINATED
                N_USB_WR_BI         <=  '1';                                    -- DISABLE WRITE OP
            END IF;

        WHEN SEND_RB2    =>                                                     -- SEND THE TRANSFER TYPE BYTE WHILE THE TFC RAM BANK PIPELINE IS FILLING
            IF USB_TXE_B = '0' THEN                                             
                N_REG_STATE         <=  SEND_RB3;
                N_WR_USB_ADBUS      <=  WR_XFER_TYPE;                           -- MUX THE TRANSFER TYPE BYTE TO THE USB BUS
                N_USB_WR_BI         <=  '0';                                    -- ASSERT THE USB_WRITE EN
                X_BLKA              <=  '0';                                    -- ENABLE THE RAM PORT
                X_RWA               <=  '1';                                    -- FOR A READ OPERATION
                N_REG_ADDR          <=  REG_ADDR + "1";                         -- INCREMENT THE ADDR POINTER

				-- THIS IS A MUX FOR THE RAM ADDRESS BUS: EITHER TFC RAM BLOCK, ONE OF 20 ELINK RAM BLOCKS, OR NADA.
				-- THE MUX OUTPUT FEEDS FF'S IN THE CASE STATEMENT JUST AHEAD OF THE STATE MACHINE
                CASE SM_BANK_SEL IS												
                    WHEN TFC    =>
                        X_ADDRA     <=  TFC_ADDR8B & REG_ADDR(7 DOWNTO 0);          -- GENERATE THE FULL 512 BYTE RAM ADDRESS
                    WHEN OTHERS =>
						IF ELK_N_ACTIVE = '1' THEN
							X_ADDRA     <=  ELINK_ADDR8B & REG_ADDR(7 DOWNTO 0);   	-- GENERATE THE FULL 512 BYTE RAM ADDRESS
						ELSE
							X_ADDRA     <=  (OTHERS => '0');
						END IF;	
                END CASE;

            ELSE                                                                -- WRITE OP TERMINATED BY HOST
                N_REG_STATE         <=  INIT;                                   -- WRITE OP TERMINATED
                N_USB_WR_BI         <=  '1';                                    -- DISABLE WRITE OP
            END IF;

        WHEN SEND_RB3    =>                                                     -- SEND 256 BYTES
            IF USB_TXE_B = '0' THEN                                             
                N_USB_WR_BI         <=  '0';                                    -- ASSERT THE USB_WRITE EN
                X_BLKA              <=  '0';                                    -- ENABLE THE RAM PORT
                X_RWA               <=  '1';                                    -- FOR A READ OPERATION
                N_REG_ADDR          <=  REG_ADDR + "1";                         -- INCREMENT THE ADDR POINTER

                CASE SM_BANK_SEL IS
                    WHEN TFC    =>
                        X_ADDRA         <=  (TFC_ADDR8B) & REG_ADDR(7 DOWNTO 0);    -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  TFC_DOUTA(7 DOWNTO 0);                  -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK0 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(0)(7 DOWNTO 0);             -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK1 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(1)(7 DOWNTO 0);             -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK2 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(2)(7 DOWNTO 0);             -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK3 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(3)(7 DOWNTO 0);             -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK4 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(4)(7 DOWNTO 0);             -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK5 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(5)(7 DOWNTO 0);             -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK6 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(6)(7 DOWNTO 0);             -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK7 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(7)(7 DOWNTO 0);             -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK8 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(8)(7 DOWNTO 0);             -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK9 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(9)(7 DOWNTO 0);             -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK10 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(10)(7 DOWNTO 0);            -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK11 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(11)(7 DOWNTO 0);            -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK12 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(12)(7 DOWNTO 0);            -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK13 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(13)(7 DOWNTO 0);            -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK14 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(14)(7 DOWNTO 0);            -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK15 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(15)(7 DOWNTO 0);            -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK16 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(16)(7 DOWNTO 0);            -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK17 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(17)(7 DOWNTO 0);            -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK18 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(18)(7 DOWNTO 0);            -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK19 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(19)(7 DOWNTO 0);            -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN OTHERS =>
                        X_ADDRA         <=  (OTHERS => '0');
                        N_WR_USB_ADBUS  <=  (OTHERS => '0');
                END CASE;


                IF REG_ADDR = "100000000" THEN                                  -- 
                    N_REG_STATE             <=  TX_TO_HOST_FIN;
                ELSE
                    N_REG_STATE             <=  SEND_RB3;
                END IF;
            ELSE                                                                -- WRITE OP TERMINATED BY HOST
                N_REG_STATE         <=  INIT;                                   -- WRITE OP TERMINATED
                N_USB_WR_BI         <=  '1';                                    -- DISABLE WRITE OP
            END IF;

        -- COMPLETE THE TX TFC TO HOST WRITE OP.  FIRST EMPTY THE DATA IN THE PIPELINE AND THEN BY SENDING THE CHECKSUM AND STOP HEADER BYTE
        WHEN TX_TO_HOST_FIN =>                                                  -- FLUSH THE PIPELINE
            IF USB_TXE_B = '0' THEN                                             
                N_USB_WR_BI         <=  '0';                                    -- ASSERT THE USB_WRITE EN
                X_BLKA              <=  '0';                                    -- ENABLE THE RAM PORT
                X_RWA               <=  '1';                                    -- FOR A READ OPERATION

                CASE SM_BANK_SEL IS
                    WHEN TFC    =>
                        X_ADDRA         <=  (TFC_ADDR8B) & REG_ADDR(7 DOWNTO 0);    -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  TFC_DOUTA(7 DOWNTO 0);                  -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK0 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(0)(7 DOWNTO 0);             -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK1 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(1)(7 DOWNTO 0);             -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK2 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(2)(7 DOWNTO 0);             -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK3 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(3)(7 DOWNTO 0);             -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK4 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(4)(7 DOWNTO 0);             -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK5 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(5)(7 DOWNTO 0);             -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK6 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(6)(7 DOWNTO 0);             -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK7 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(7)(7 DOWNTO 0);             -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK8 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(8)(7 DOWNTO 0);             -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK9 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(9)(7 DOWNTO 0);             -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK10 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(10)(7 DOWNTO 0);            -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK11 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(11)(7 DOWNTO 0);            -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK12 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(12)(7 DOWNTO 0);            -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK13 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(13)(7 DOWNTO 0);            -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK14 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(14)(7 DOWNTO 0);            -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK15 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(15)(7 DOWNTO 0);            -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK16 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(16)(7 DOWNTO 0);            -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK17 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(17)(7 DOWNTO 0);            -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK18 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(18)(7 DOWNTO 0);            -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK19 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(19)(7 DOWNTO 0);            -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN OTHERS =>
                        X_ADDRA         <=  (OTHERS => '0');
                        N_WR_USB_ADBUS  <=  (OTHERS => '0');
                END CASE;

                N_REG_STATE         <=  TX_TO_HOST_FIN1;
            ELSE                                                                -- WRITE OP TERMINATED BY HOST
                N_REG_STATE         <=  INIT;                                   -- WRITE OP TERMINATED
                N_USB_WR_BI         <=  '1';                                    -- DISABLE WRITE OP
            END IF;        

        WHEN TX_TO_HOST_FIN1 =>                                                 -- FLUSH THE PIPELINE
            IF USB_TXE_B = '0' THEN                                             
                N_USB_WR_BI         <=  '0';                                    -- ASSERT THE USB_WRITE EN
                X_BLKA              <=  '0';                                    -- ENABLE THE RAM PORT
                X_RWA               <=  '1';                                    -- FOR A READ OPERATION

                CASE SM_BANK_SEL IS
                    WHEN TFC    =>
                        X_ADDRA         <=  (TFC_ADDR8B) & REG_ADDR(7 DOWNTO 0);    -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  TFC_DOUTA(7 DOWNTO 0);                  -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK0 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(0)(7 DOWNTO 0);             -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK1 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(1)(7 DOWNTO 0);             -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK2 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(2)(7 DOWNTO 0);             -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK3 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(3)(7 DOWNTO 0);             -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK4 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(4)(7 DOWNTO 0);             -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK5 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(5)(7 DOWNTO 0);             -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK6 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(6)(7 DOWNTO 0);             -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK7 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(7)(7 DOWNTO 0);             -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK8 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(8)(7 DOWNTO 0);             -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK9 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(9)(7 DOWNTO 0);             -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK10 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(10)(7 DOWNTO 0);            -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK11 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(11)(7 DOWNTO 0);            -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK12 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(12)(7 DOWNTO 0);            -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK13 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(13)(7 DOWNTO 0);            -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK14 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(14)(7 DOWNTO 0);            -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK15 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(15)(7 DOWNTO 0);            -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK16 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(16)(7 DOWNTO 0);            -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK17 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(17)(7 DOWNTO 0);            -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK18 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(18)(7 DOWNTO 0);            -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN ELINK19 =>  
                        X_ADDRA         <=  (ELINK_ADDR8B) & REG_ADDR(7 DOWNTO 0);  -- UPDATE THE BANK 1/2 BEING USED BY THE PATTERN GEN
                        N_WR_USB_ADBUS  <=  ELINK_DOUTA(19)(7 DOWNTO 0);            -- MUX THE RAM A PORT OUTPUT DIRECTLY TO THE USB DATA BUS PORT REGISTER
                    WHEN OTHERS =>
                        X_ADDRA         <=  (OTHERS => '0');
                        N_WR_USB_ADBUS  <=  (OTHERS => '0');
                END CASE;

                N_REG_STATE         <=  TX_TO_HOST_FIN2;
            ELSE                                                                -- WRITE OP TERMINATED BY HOST
                N_REG_STATE         <=  INIT;                                   -- WRITE OP TERMINATED
                N_USB_WR_BI         <=  '1';                                    -- DISABLE WRITE OP
            END IF;        

        WHEN TX_TO_HOST_FIN2 =>                                                  -- SEND THE PACKET CHECKSUM
            IF USB_TXE_B = '0' THEN                                             
                N_USB_WR_BI         <=  '0';                                    -- ASSERT THE USB_WRITE EN
                N_WR_USB_ADBUS      <=  CHKSUM;                                 -- MUX THE CHKSUM TO THE USB DATA BUS PORT REGISTER
                N_REG_STATE         <=  TX_TO_HOST_FIN3;
            ELSE                                                                -- WRITE OP TERMINATED BY HOST
                N_REG_STATE         <=  INIT;                                   -- WRITE OP TERMINATED
                N_USB_WR_BI         <=  '1';                                    -- DISABLE WRITE OP
            END IF;        

        WHEN TX_TO_HOST_FIN3 =>                                                  -- SEND THE PACKET CHECKSUM
            IF USB_TXE_B = '0' THEN                                             
                N_USB_WR_BI         <=  '0';                                    -- ASSERT THE USB_WRITE EN
                N_WR_USB_ADBUS      <=  STOP_BYTE;                              -- MUX THE STOP HEADER BYTE TO THE USB DATA BUS PORT REGISTER
                N_REG_STATE         <=  TX_EMPTY_PIPE;
            ELSE                                                                -- WRITE OP TERMINATED BY HOST
                N_REG_STATE         <=  INIT;                                   -- WRITE OP TERMINATED
                N_USB_WR_BI         <=  '1';                                    -- DISABLE WRITE OP
            END IF;        

        WHEN TX_EMPTY_PIPE =>                                                   -- ADD ONE ADD'L CLOCK CYCLE TO EMPTY THE PIPELINE OF DATA FLOW
                N_REG_STATE         <=  TX_EMPTY_PIPE1;
                N_USB_WR_BI         <=  '1';                                    -- DISABLE WRITE OP

        WHEN TX_EMPTY_PIPE1 =>                                                  -- ADD ONE ADD'L CLOCK CYCLE TO EMPTY THE PIPELINE OF DATA FLOW
            IF SI_CNT < "1111"  THEN
                N_USB_SIWU_BI   <=  '0';
                N_SI_CNT        <=  SI_CNT + '1';
                N_REG_STATE     <=  TX_EMPTY_PIPE1;
            ELSE
                N_USB_SIWU_BI   <=  '1';
                N_SI_CNT        <=  "0000";
                N_REG_STATE     <=  INIT;
            END IF;

        --WHEN TX_RAM_HOLD =>                                                  -- ADD ONE ADD'L CLOCK CYCLE TO EMPTY THE PIPELINE OF DATA FLOW
            --IF USB_TXE_B = '1' THEN
                --N_REG_STATE     <=  INIT;
            --ELSE
                --N_REG_STATE     <=  TX_RAM_HOLD;
            --END IF;

--++++++++++++

        WHEN OTHERS     =>
            N_REG_STATE     <=  INIT;


        END CASE;


    END PROCESS REG_SM;
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ROUTE INTERNAL SIGNALS TO EXTERNAL PORTS

P_OP_MODE               <=  OP_MODE_40MVAL;

P_TFC_STRT_ADDR         <=  TFC_STRT_ADDR_40MVAL;
P_TFC_STOP_ADDR         <=  TFC_STOP_ADDR_40MVAL;
P_TFC_ADDR8B            <=  TFC_ADDR8B;
TFC_DAT_OUT             <=  TFC_DOUTB(7 DOWNTO 0);

P_ELINKS_STRT_ADDR      <=  ELINKS_STRT_ADDR_40MVAL;
P_ELINKS_STOP_ADDR      <=  ELINKS_STOP_ADDR_40MVAL;
P_ELINK_ADDR8B         	<=  ELINK_ADDR8B;
ELINK0_DAT_OUT          <=  ELINK_DOUTB(0)(7 DOWNTO 0);
ELINK1_DAT_OUT          <=  ELINK_DOUTB(1)(7 DOWNTO 0);
ELINK2_DAT_OUT          <=  ELINK_DOUTB(2)(7 DOWNTO 0);
ELINK3_DAT_OUT          <=  ELINK_DOUTB(3)(7 DOWNTO 0);
ELINK4_DAT_OUT          <=  ELINK_DOUTB(4)(7 DOWNTO 0);
ELINK5_DAT_OUT          <=  ELINK_DOUTB(5)(7 DOWNTO 0);
ELINK6_DAT_OUT          <=  ELINK_DOUTB(6)(7 DOWNTO 0);
ELINK7_DAT_OUT          <=  ELINK_DOUTB(7)(7 DOWNTO 0);
ELINK8_DAT_OUT          <=  ELINK_DOUTB(8)(7 DOWNTO 0);
ELINK9_DAT_OUT          <=  ELINK_DOUTB(9)(7 DOWNTO 0);
ELINK10_DAT_OUT         <=  ELINK_DOUTB(10)(7 DOWNTO 0);
ELINK11_DAT_OUT         <=  ELINK_DOUTB(11)(7 DOWNTO 0);
ELINK12_DAT_OUT         <=  ELINK_DOUTB(12)(7 DOWNTO 0);
ELINK13_DAT_OUT         <=  ELINK_DOUTB(13)(7 DOWNTO 0);
ELINK14_DAT_OUT         <=  ELINK_DOUTB(14)(7 DOWNTO 0);
ELINK15_DAT_OUT         <=  ELINK_DOUTB(15)(7 DOWNTO 0);
ELINK16_DAT_OUT         <=  ELINK_DOUTB(16)(7 DOWNTO 0);
ELINK17_DAT_OUT         <=  ELINK_DOUTB(17)(7 DOWNTO 0);
ELINK18_DAT_OUT         <=  ELINK_DOUTB(18)(7 DOWNTO 0);
ELINK19_DAT_OUT         <=  ELINK_DOUTB(19)(7 DOWNTO 0);

USB_SIWU_B              <=  USB_SIWU_BI;
USB_WR_B                <=  USB_WR_BI;
USB_RD_B                <=  USB_RD_BI;
USB_OE_B                <=  USB_OE_BI;

end RTL;
