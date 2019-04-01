--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Company: UNIVERSITY OF MARYLAND
--
-- File: ELINK_SLAVE_INV.vhd
-- File history:
--      REV - // JUNE 6, 2016 // INITIAL VERSION
--      
--      
--
-- Description: IMPLEMENTS THE MODULE CONNECTIVITY FOR AN ELINK SLAVE.
--      ++++++ NOTE +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--		++ 	THIS VERSION INVERTS THE SERIAL INPUT AND OUTPUT SIGNALS TO COMPENSATE FOR THE 4 CHANNELS ON THE COMMET + PASSIVE PROBE BOARD 
--		++ 	WHERE THE _P AND _N LINES ARE INADVERTANTLY SWAPPED
--		+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Targeted device: <Family::ProASIC3E> <Die::A3PE1500> <Package::208 PQFP>
-- Author: TOM O'BANNON
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library IEEE;

use IEEE.std_logic_1164.all;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.STD_LOGIC_MISC.ALL;

library proasic3e;
use proasic3e.all;

library synplify;
use synplify.attributes.all;

entity ELINK_SLAVE_INV is
port (
		CLK_40M_GL        		:   IN 	STD_LOGIC;                          	-- CCC#1 FIXED 40MHZ CLOCK OUT
        CCC_160M_FXD      		:   IN	STD_LOGIC;                          	-- CCC#1 FIXED 160MHZ CLOCK
        CCC_160M_ADJ      		:   IN	STD_LOGIC;                          	-- CCC#2 ADJ 160MHZ CLOCK

        DEV_RST_B           	:   IN  STD_LOGIC;                          	-- ACTIVE LOW ASYNC RESET --DEDICATED COMET BOARD RC TIME CONSTANT
		MASTER_POR_B      		:   IN	STD_LOGIC;                          	-- MASTER_POR_B
		MASTER_DCB_POR_B        :   IN	STD_LOGIC;                              -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR DCB CONFIGS
		MASTER_SALT_POR_B     	:   IN	STD_LOGIC;                              -- SAME AS MASTER_POR_B, BUT ONLY COMES OUT OF ACTIVE RESET FOR SALT CONFIGS

        DCB_SALT_SEL        	:   IN  STD_LOGIC;                          	-- '1'= DCB MODE (IE TFC MASTER TX ENABLED) // '0'=SALT HYBRID MODE (IE TFC MASTER RX W/ SYNC MODE ENABLED)
		
		OP_MODE1_SPE      		:   IN	STD_LOGIC;                          	-- OP_MODE BIT 1 = SYNC PATT EN
		F_ALIGN_PATT            :   IN	STD_LOGIC_VECTOR(7 DOWNTO 0); 			-- FIXED SYNC / ALIGNMENT PATTERN BYTE
		PATT_ELK_DAT			:	IN	STD_LOGIC_VECTOR(7 DOWNTO 0); 			-- ELINK PATTERN TX DATA

        BIT_OS_SEL            	:   IN	STD_LOGIC_VECTOR(2 DOWNTO 0);   		-- BIT ALIGNMENT OFFSET VALUE DETERMINED BY MASTER DES320M AND USE DY ALL SLAVES
		
		ELK_DAT_P         		:   INOUT STD_LOGIC;                        	-- SERIAL LVDS ELINK0 DATA BIDIR PORT
        ELK_DAT_N         		:   INOUT STD_LOGIC;							--	""

		ELK_RX_SER_WORD         :   OUT	STD_LOGIC_VECTOR(7 DOWNTO 0)            -- OUTPUT WORD OF THE ELINK DE-SERIALIZER

	);
	
end ELINK_SLAVE_INV;

architecture RTL of ELINK_SLAVE_INV is

SIGNAL  ELK_TX_DAT              :   STD_LOGIC_VECTOR(7 DOWNTO 0);              	-- CONNECTION BETWEEN ELINK0 SOURCE DATA MUX AND THE ELINK0 TX SERIALIZER
SIGNAL  ELK_OUT_R               :   STD_LOGIC;              					-- ELINK LVDS OUTPUT --RISE EDGE
SIGNAL  ELK_OUT_F               :   STD_LOGIC;              					-- ELINK LVDS OUTPUT --FALL EDGE

SIGNAL	ELK_IN_DDR_R, ELK_IN_R  :   STD_LOGIC;                              	-- ELINK INPUT SERIAL BIT STREAM -- RISE EDGE (DDR VERSION IS STRAIGHT FROM DDR REG, OTHER IS DELAYED BY 1 FF )
SIGNAL	ELK_IN_DDR_F, ELK_IN_F  :   STD_LOGIC;                              	-- ELINK INPUT SERIAL BIT STREAM -- FALL EDGE (DDR VERSION IS STRAIGHT FROM DDR REG, OTHER IS DELAYED BY 1 FF )


----------------------------------------------------------------
-- MULTIPLEXOR FOR THE TX SERIAL DATA SOURCE
COMPONENT SYNC_DAT_SEL 
    port (
            CLK40M_GEN          :   IN  STD_LOGIC;                              -- 40 MHZ CLOCK WHERE RISE EDGE IS DELAYED 2.5 NS FROM THE FIXED 160 MHZ RISE EDGE
            RESET_B             :   IN  STD_LOGIC;                              -- ACTIVE LOW RESET    

            ALIGN_MODE_EN       :   IN  STD_LOGIC;                              -- '1' ENABLES THE AUTO BIT AND BYTE ALIGNMENT FUNCTION. PULSED INPUT MUST BE LOW BEFORE ALIGNMENT COMPLETE
            ALIGN_PATT          :   IN  STD_LOGIC_VECTOR(7 DOWNTO 0);           -- PATTERN USED TO DETERMINE ALIGNMENT (EG A5 HEX)

            SER_DAT_IN          :   IN  STD_LOGIC_VECTOR(7 DOWNTO 0);           -- SERIAL DATA BYTE

            P_SERDAT            :   OUT STD_LOGIC_VECTOR(7 DOWNTO 0)            -- SERIAL DATA BYTE FOR TX
    );
END COMPONENT;

----------------------------------------------------------------
-- BASIC 8-BIT PARALLEL-TO-SERIAL TX 
COMPONENT SER320M
    port (
            DDR_160M_CLK        :   IN  STD_LOGIC;                              -- FIXED 160 MHZ DDR CLOCK
            CLK40M_GEN          :   IN  STD_LOGIC;                              -- 40 MHZ CLOCK DERIVED FROM PLL CLOCK DELAYED BY ~2.5NS FROM THE RISING EDGE OF THE FIXED DDR_160M_CLK

            RESET_B             :   IN  STD_LOGIC;                              -- ACTIVE LOW RESET    
            NEXT_SER_CMD_WORD   :   IN  STD_LOGIC_VECTOR(7 DOWNTO 0);           -- 8 BIT COMMAND INPUT WORD    
            SERIAL_TX_EN        :   IN  STD_LOGIC;                              -- ENABLE FOR THE SERIAL TX

            SER_OUT_R           :   OUT STD_LOGIC;                              -- SERIALIZED COMMAND 160MHZ RISE CLOCK DATA-- 12 COPIES
            SER_OUT_F           :   OUT STD_LOGIC                               -- SERIALIZED COMMAND 160MHZ FALL CLOCK DATA-- 12 COPIES
         );
    END COMPONENT;
	
	
----------------------------------------------------------------

COMPONENT DDR_BIDIR_LVDS_DUAL_CLK is
    port(
            DDR_CLR     : in    std_logic;
            DDR_DIR     : in    std_logic;
            DDR_TX_CLK  : in    std_logic;
            DDR_TX_R    : in    std_logic;
            DDR_TX_F    : in    std_logic;
            DDR_RX_CLK  : in    std_logic;
            DDR_RX_R    : out   std_logic;
            DDR_RX_F    : out   std_logic;
            PADP        : inout std_logic;
            PADN        : inout std_logic
        );
END COMPONENT;

----------------------------------------------------------------
-- SLAVE 8-BIT SERIAL-TO-PARALLEL RX.  
COMPONENT  SLAVE_DES320S is
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
END COMPONENT;

begin

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ELINK 1 -----OPERATES AS A SLAVE DESERIALIER
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
U_ELK1_SERDAT_SOURCE:SYNC_DAT_SEL 
    PORT MAP    (
                    CLK40M_GEN          =>  CLK_40M_GL,             -- FIXED CCC MAIN (#1) 40 MHZ TX WORD RATE CLOCK
                    RESET_B             =>  MASTER_SALT_POR_B,     	-- ONLY COME OUT OF RESET AND ENABLE IF CONFIGURED AS A SALT

                    ALIGN_MODE_EN       =>  OP_MODE1_SPE,           -- '1' ENABLES THE SYNC PATTERN
                    ALIGN_PATT          =>  F_ALIGN_PATT,

                    SER_DAT_IN          =>  PATT_ELK_DAT,

                    P_SERDAT            =>  ELK_TX_DAT
            );

U_ELK1_CMD_TX:SER320M
    PORT MAP    (
                    DDR_160M_CLK        =>  CCC_160M_FXD,
                    CLK40M_GEN          =>  CLK_40M_GL,            -- FROM PLL SYNCHRONOUS TO 160MHZ SERDES CLOCKS

                    RESET_B             =>  MASTER_SALT_POR_B,     -- ONLY COME OUT OF RESET AND ENABLE IF CONFIGURED AS A SALT
                    NEXT_SER_CMD_WORD   =>  ELK_TX_DAT,
                    SERIAL_TX_EN        =>   '1',                  -- ENABLE FOR THE SERIAL TX

                    SER_OUT_R           =>  ELK_OUT_R,
                    SER_OUT_F           =>  ELK_OUT_F
                 );

U_DDR_ELK1:DDR_BIDIR_LVDS_DUAL_CLK
    PORT MAP    (  
                    DDR_CLR             =>  MASTER_POR_B,           -- ACTIVE LOW CLEAR
                    DDR_DIR             =>  NOT(DCB_SALT_SEL),      -- ENABLE OUTPUT(IE '1'= OUTPUT)==> ELK TX ON FOR SALT MODE // ELK RX ON FOR DCB MODE)
                    DDR_TX_CLK          =>  CCC_160M_FXD,         	-- FIXED TX CLOCK
                    DDR_TX_R            =>  NOT(ELK_OUT_R),         -- DATA TO BE TRANSMITTED   +++ INVERTED PER NOTE AT BEGINNING OF THIS FILE +++
                    DDR_TX_F            =>  NOT(ELK_OUT_F),         --  "					 	+++ INVERTED PER NOTE AT BEGINNING OF THIS FILE +++
                    DDR_RX_CLK          =>  CCC_160M_ADJ,           -- PHASE DELAY TUNABLE RX CLOCK
                    DDR_RX_R            =>  ELK_IN_DDR_R,        	-- DATA BEING RECEIVED
                    DDR_RX_F            =>  ELK_IN_DDR_F,        	--  "
                    PADP                =>  ELK_DAT_P,
                    PADN                =>  ELK_DAT_N
                );

-- ELINK 1 SLAVE DESERIALIZER
U_SLAVE_1ELK:SLAVE_DES320S
		PORT MAP (
					CCC_160M_ADJ       	=>	CCC_160M_ADJ,           -- PHASE ADJUSTABLE 160 MHZ DDR CLOCK
					CCC_160M_FXD		=>	CCC_160M_FXD,			-- FIXED PHASE 160 MHZ DDR CLOCK

					BIT_OFFSET          =>	BIT_OS_SEL,           	-- BIT OFFSET DETERMINED BY THE MASTER_SER320m MODULE
					
					CLK_40M_FXD         =>	CLK_40M_GL,             -- FIXED PHASE 40 MHZ CLOCK 

					RESET_B             =>	MASTER_DCB_POR_B,     	-- ONLY COME OUT OF RESET AND ENABLE IF CONFIGURED AS A DCB  

					SER_IN_R            =>	ELK_IN_R,               -- SERIAL DATA IN-->RISE EDGE
					SER_IN_F            =>	ELK_IN_F,               -- SERIAL DATA IN-->FALL EDGE

					P_RECD_SER_WORD     =>	ELK_RX_SER_WORD         -- 8 BIT SERIAL OUTPUT WORD
				);
				
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- CREATE A PIPELINE DELAY REGISTER FOR THE DDR RECEIVE SIGNALS ASSOCIATED WITH TFC AND ELINKS (GIVES P&R MORE LATITUDE TO CLOSE TIMING)

REG:PROCESS(DEV_RST_B, CCC_160M_ADJ)
    BEGIN
        IF DEV_RST_B = '0' THEN

			ELK_IN_R     	<=  '0';
            ELK_IN_F    	<=  '0';

        ELSIF (CCC_160M_ADJ'EVENT AND CCC_160M_ADJ='1') THEN

            ELK_IN_F     	<=  NOT(ELK_IN_DDR_F);					-- +++ INVERTED PER NOTE AT BEGINNING OF THIS FILE +++
            ELK_IN_R     	<=  NOT(ELK_IN_DDR_R);					-- +++ INVERTED PER NOTE AT BEGINNING OF THIS FILE +++

        END IF;

    END PROCESS REG;
				

end RTL;
