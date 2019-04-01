--------------------------------------------------------------------------------
-- Company: UNIVERSITY OF MARYLAND
--
-- File: TOP_MASTER_DES320M.vhd
-- File history:
--      REV INITIAL,  DEC 11, 2015
--
-- Description: THIS TOP-LEVL MODULE CONTAINS THE SUBMODULES NEEDED FOR THE MASTER DESERIALIZER FUNCTION.  
--              THESE INCLUDE:
--                  MASTER_DES320M
--                  GP_CCC_SCONFIG
--                  CCC_160M_ADJ
--
--              THE MASTER DESERIALIZER USES THE TFC DATA STREAM FOR THE SALT CONFIG AND THE ELINK DATA STREAM FOR THE DCB CONFIG SELECTED VIA AN COMBINATORIAL MUX PROCESS.
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

library synplify;
use synplify.attributes.all;

entity TOP_MASTER_DES320M is
    port    (
                CLK_40M_GL              :   IN  STD_LOGIC;                      -- ON-BOARD CCC1 40 MHZ CLOCK
				CCC_160M_FXD			:	IN	STD_LOGIC;						-- FIXED PHASE 160 MHZ DDR CLOCK

                CLK_40M_BUF_RECD        :   IN  STD_LOGIC;                      -- 40 MHZ REF CLOCK DISTRIBUTED BY THE 'MASTER FPGA' ON THE MASTER DCB CONFIGURED COMET---IS FOR CCC2 REF
                MASTER_POR_B            :   IN  STD_LOGIC;                      -- MASTER POWER-ON-RESET: SYNCHRONOUS RESET WAITS FOR CCC1 TO BE LOCKED AND STABLE

                DCB_SALT_SEL            :   IN  STD_LOGIC;                      -- '1'=DCB, '0'=SALT
                ALIGN_MODE_EN           :   IN  STD_LOGIC;                      -- '1'= AUTO ALIGN ENABLED
                SIM_MODE                :   IN  STD_LOGIC;                      -- GPIO_1:  '1' = SIM MODE, '0' = REAL TIME OP MODE

                MAN_BIT_OS              :   IN  STD_LOGIC_VECTOR(3 DOWNTO 0);   -- MANUAL BIT OFFSET ADJUSTMENT (THESE 3 MANUAL MODE INPUTS CAN BE HARD-WIRED INACTIVE AT NEXT LEVEL)
                MAN_PHASE_ADJ           :   IN  STD_LOGIC_VECTOR(4 DOWNTO 0);   -- MANUAL PHASE ADJUSTMENT 
                MAN_AUTO_ALIGN          :   IN  STD_LOGIC;                      -- '1'=MANUAL , '0'= AUTO PHASE ADJ MODE

                ELINK0_DDR_R            :   IN  STD_LOGIC;                      -- ELINK0 DDR RISE SERIAL DATA
                ELINK0_DDR_F            :   IN  STD_LOGIC;                      -- ELINK0 DDR FALL SERIAL DATA
                TFC_DDR_R               :   IN  STD_LOGIC;                      -- TFC DDR RISE SERIAL DATA
                TFC_DDR_F               :   IN  STD_LOGIC;                      -- TFC DDR FALL SERIAL DATA

                CH0_RAM_BPORT           :   OUT STD_LOGIC_VECTOR(7 DOWNTO 0);   -- SERIAL DATA GETS ROUTED TO THE RAM CH0 STORAGE ALLOCATED FOR TFC WHEN FPGA CONSIGD AS SALT
                CH1_RAM_BPORT           :   OUT STD_LOGIC_VECTOR(7 DOWNTO 0);   -- SERIAL DATA GETS ROUTED TO THE RAM CH1 STORAGE ALLOCATED FOR ELINK0
                P_BIT_OS_SEL            :   OUT STD_LOGIC_VECTOR(2 DOWNTO 0);   -- BIT ALIGNMENT OFFSET VALUE DETERMINED BY MASTER DES320M AND USE DY ALL SLAVES
                P_ALIGN_ACTIVE          :   OUT STD_LOGIC;                      -- '1' INDICATES THE AUTO ALIGN FUNCTION IS ACTIVE

                P_CCC_RX_CLK_LOCK       :   OUT STD_LOGIC;                      -- CCC2 LOCK STATUS
                P_CCC_160M_ADJ          :   OUT STD_LOGIC;                      -- CCC2 PHASE ADJUSTABLE 160 MHZ CLOCK--BASELINE PHASE
                P_CCC_160M_1ADJ         :   OUT STD_LOGIC;                      -- CCC2 PHASE ADJUSTABLE 160 MHZ CLOCK--ADD'L PHASE OFFSET 1 
                P_CCC_160M_2ADJ         :   OUT STD_LOGIC                       -- CCC2 PHASE ADJUSTABLE 160 MHZ CLOCK--ADD'L PHASE OFFSET 2
            );
end TOP_MASTER_DES320M;

architecture RTL of TOP_MASTER_DES320M is

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- DEFINE COMPONENTS
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- SIMPLE LVDS OUTPUT BUFFER
COMPONENT LVDS_BUF
    port (  Data            : in    std_logic;
            PADP            : out   std_logic;
            PADN            : out   std_logic
         );
END COMPONENT;

----------------------------------------------------------------
-- MASTER 8-BIT SERIAL-TO-PARALLEL RX 
COMPONENT MASTER_DES320M is
    port (
            CCC_160M_ADJ       	:   IN  STD_LOGIC;                              -- PHASE ADJUSTABLE 160 MHZ DDR CLOCK
			CCC_160M_FXD		:	IN	STD_LOGIC;								-- FIXED PHASE 160 MHZ DDR CLOCK
			
            CCC2_CLK_LOCK       :   IN  STD_LOGIC;                              -- PLL LOCK STATUS FOR THE DDR CLOCK
            CLK_40M_FXD         :   IN  STD_LOGIC;                              -- 40 MHZ CLOCK 

            RESET_B             :   IN  STD_LOGIC;                              -- ACTIVE LOW RESET    

            ALIGN_MODE_EN       :   IN  STD_LOGIC;                              -- '1' ENABLES THE AUTO BIT AND BYTE ALIGNMENT FUNCTION. PULSED INPUT MUST BE LOW BEFORE ALIGNMENT COMPLETE
            ALIGN_PATT          :   IN  STD_LOGIC_VECTOR(7 DOWNTO 0);           -- PATTERN USED TO DETERMINE ALIGNMENT (EG 8E HEX)

            MAN_AUTO_ALIGN      :   IN  STD_LOGIC;                              -- '1'= MANUAL BIT OFFSET AND PHASE ALIGNMENT, '0'=AUTO
            MAN_BIT_OS          :   IN  STD_LOGIC_VECTOR(3 DOWNTO 0);           -- MANUAL SELECTION OF THE BIT OFFSET 
            MAN_PHASE_ADJ       :   IN  STD_LOGIC_VECTOR(4 DOWNTO 0);           -- MANUAL PHASE ADJ VALUE OF 160 ADJ CCC#2

            SER_IN_R            :   IN  STD_LOGIC;                              -- SERIAL DATA IN-->RISE EDGE
            SER_IN_F            :   IN  STD_LOGIC;                              -- SERIAL DATA IN-->FALL EDGE

            PLL_SS_TIME         :   IN  STD_LOGIC_VECTOR(13 DOWNTO 0);          -- STEADY STATE TIME COUNT ALLOCATED FOR THE ADJUSTABLE PLL

            DDR_Q0_RISE         :   OUT STD_LOGIC;                              -- TEST PORT VALUE OF THE REC'D DDR BIT STREAM (RISE)
            DDR_Q1_FALL         :   OUT STD_LOGIC;                              -- TEST PORT VALUE OF THE REC'D DDR BIT STREAM (FALL)

            PHASE_ADJ_160_L     :   OUT STD_LOGIC_VECTOR(4 DOWNTO 0);           -- PHASE ADJ CONTROL BITS (NOMINAL 160 PS STEP SIZE) FOR THE 160MHZ DDR ADJ CLOCK
            P_CONFIG_ONCE_TRIG  :   OUT STD_LOGIC;                              -- PULSE TRIGGER TO FORCE A CCC#2 UPDATE
            P_CCC_RESET_EN      :   OUT STD_LOGIC_VECTOR(0 DOWNTO 0);           -- '1' FORCES A CCC RESET PULSE IMMEDIATELY AFTER CONFIG UPDATES, '0' DISABLES THIS FEATURE

            P_RECD_SER_WORD     :   OUT STD_LOGIC_VECTOR(7 DOWNTO 0);           -- 8 BIT SERIAL OUTPUT WORD
            P_BIT_OS_SEL        :   OUT STD_LOGIC_VECTOR(2 DOWNTO 0);           -- FINAL SELECTED BIT OFFSET ALIGNMENT VALUE
            P_ALIGN_ACTIVE      :   OUT STD_LOGIC                               -- '1' INDICATES THAT THE ALIGN MODE IS ACTIVE
        );
END COMPONENT;

----------------------------------------------------------------
-- CCC WITH DYNAMIC SERIAL CONFIGURATION INTERFACE TO ALLOW EITHER FIXED OR PHASE ADJUSTABLE OUTPUTS TO BE GENERATED
COMPONENT GP_CCC_SCONFIG is
    port (
            SCFG_CLK            :   IN  STD_LOGIC;                                          -- CLOCK USED TO CLOCK THE PGASE ADJ SERIAL SHFT REGISTER
            DEV_RST_B           :   IN  STD_LOGIC;                                          -- ACTIVE LOW RESET
            CONFIG_ONCE_TRIG    :   IN  STD_LOGIC;                                          -- '1' MEANS RUN ONCE AND THEN STOP FOREVERMORE

            FINDIV_A            :   IN  STD_LOGIC_VECTOR(6 DOWNTO 0);                       -- FINDIV:   LSB BIT 0
            FBDIV_B             :   IN  STD_LOGIC_VECTOR(13 DOWNTO 7);                      -- FBDIV
            OADIV_C             :   IN  STD_LOGIC_VECTOR(18 DOWNTO 14);                     -- OADIV
            OBDIV_D             :   IN  STD_LOGIC_VECTOR(23 DOWNTO 19);                     -- OBDIV
            OCDIV_E             :   IN  STD_LOGIC_VECTOR(28 DOWNTO 24);                     -- OCDIV
            OAMUX_F             :   IN  STD_LOGIC_VECTOR(31 DOWNTO 29);                     -- OAMUX    
            OBMUX_G             :   IN  STD_LOGIC_VECTOR(34 DOWNTO 32);                     -- OBMUX
            OCMUX_H             :   IN  STD_LOGIC_VECTOR(37 DOWNTO 35);                     -- OCMUX
            FBSEL_I             :   IN  STD_LOGIC_VECTOR(39 DOWNTO 38);                     -- FBSEL
            FBDLY_J             :   IN  STD_LOGIC_VECTOR(44 DOWNTO 40);                     -- FBDLY
            XDLYSEL_K           :   IN  STD_LOGIC_VECTOR(45 DOWNTO 45);                     -- BIT 54 XDLYSEL
            DLYGLA_L            :   IN  STD_LOGIC_VECTOR(50 DOWNTO 46);                     -- DLYGLA-->  GLOBAL A PHASE ADJUST INPUT 
            DLYGLB_M            :   IN  STD_LOGIC_VECTOR(55 DOWNTO 51);                     -- DLYGLB-->  GLOBAL B PHASE ADJUST INPUT 
            DLYGLC_N            :   IN  STD_LOGIC_VECTOR(60 DOWNTO 56);                     -- DLYGLC-->  GLOBAL C PHASE ADJUST INPUT 
            DLYYB_O             :   IN  STD_LOGIC_VECTOR(65 DOWNTO 61);                     -- DLYYB
            DLYYC_P             :   IN  STD_LOGIC_VECTOR(70 DOWNTO 66);                     -- DLYYC
            STATASEL_Q          :   IN  STD_LOGIC_VECTOR(71 DOWNTO 71);                     --  BIT 71 MASKED*   THESE BITS ARE DETERMINED AFTER P & R
            STATBSEL_R          :   IN  STD_LOGIC_VECTOR(72 DOWNTO 72);                     --  BIT 72 MASKED*   THEREFORE, BRING THEM IN VIA THE GPIO PORTS FOR NOW
            STATCSEL_S          :   IN  STD_LOGIC_VECTOR(73 DOWNTO 73);                     --  BIT_73 MASKED*   (CAN ALSO BRING IN VIA USB REGISTER EVENTUALLY?)
            VCOSEL_T            :   IN  STD_LOGIC_VECTOR(76 DOWNTO 74);                     --  VCOSEL
            DYNASEL_U           :   IN  STD_LOGIC_VECTOR(77 DOWNTO 77);                     --  BIT 77 MASKED*   (BUT MAY WANT TO HAVE STD FLASG AS DEFAULT CONFIG)
            DYNBSEL_V           :   IN  STD_LOGIC_VECTOR(78 DOWNTO 78);                     --  BIT 78 MASKED*   
            DYNCSEL_W           :   IN  STD_LOGIC_VECTOR(79 DOWNTO 79);                     --  BIT 79 MASKED*   
            RESETEN_X           :   IN  STD_LOGIC_VECTOR(80 DOWNTO 80);                     --  RESETEN, READONLY: MSB BIT 80
            P_CCC1_MODE         :   OUT STD_LOGIC;                                          -- CONTROL THE CONFIG MODE FOR CCC #1
            P_SDIN              :   OUT STD_LOGIC;                                          -- SERIAL DATA STREAM FOR THE SERIAL CONFIG OF THE CCC
            P_SSHIFT            :   OUT STD_LOGIC;                                          -- SERIAL SHIFT ENABLE
            P_SUPDATE           :   OUT STD_LOGIC                                           -- SERIAL UPDATE

    );
END COMPONENT;

----------------------------------------------------------------
-- DEFINE THE CCC COMPONENT USED TO GENERATE 3 DYNAMICALLY AND INDEPENDENTLY ADJUSTED 160 MHZ CLOCKS
-- !!!!!!!! TIMING NOTES !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
--	THE FIXED 160MHZ OUTPUTS HAVE AN INITIAL 0.735 NS DELAY
--	THE DELAY OFFSETS OF THE THREE PLL OUTPUTS RELATIVE TO THE FIXED 40 AND 160 MHZ CLOCKS IN CCC#1 ARE ADJUSTED VIA FEEDBACK DELAYS SET TO  2.290 + 0.935 NS.
--  THE REF CLOCK IS A EXT I/O CONNECTION
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
COMPONENT CCC_DYN_TRIPLE_160M is
    port ( 
			POWERDOWN : in    std_logic;
			CLKA      : in    std_logic;
			LOCK      : out   std_logic;
			GLA       : out   std_logic;
			GLB       : out   std_logic;
			GLC       : out   std_logic;
			SDIN      : in    std_logic;
			SCLK      : in    std_logic;
			SSHIFT    : in    std_logic;
			SUPDATE   : in    std_logic;
			MODE      : in    std_logic;
			SDOUT     : out   std_logic
         );

END COMPONENT;


--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- DEFINE THE SIGNALS
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- SIGNALS ASSOCIATED WITH THE AUX CCC2 
SIGNAL  CCC_RX_CLK_LOCK                 :   STD_LOGIC;                                  -- LOCK STATUS INDICATOR FOR THE AUX CCC (THAT GENS THE ADJUSTABLE CLOCKS)
SIGNAL  PHASE_ADJ_160_L                 :   STD_LOGIC_VECTOR(4 DOWNTO 0);               -- PHASE ADJ COMMAND FOR THE ADJ 160 M CLOCK
SIGNAL  CCC2_CONFIG_TRIG                :   STD_LOGIC;                                  -- TRIGGER PULSE FOR CCC#2 UPDATE
SIGNAL  CCC_160M_ADJ                    :   STD_LOGIC;                                  -- PHASE ADJ 160 MHZ CLOCK FOR THE SERDES.
SIGNAL  CCC_160M_1ADJ                   :   STD_LOGIC;                                  -- PHASE ADJ 160 MHZ CLOCK FOR THE SERDES.
SIGNAL  CCC_160M_2ADJ                   :   STD_LOGIC;                                  -- PHASE ADJ 160 MHZ CLOCK FOR THE SERDES.

ATTRIBUTE syn_keep OF CCC_160M_ADJ 		: SIGNAL IS TRUE;
ATTRIBUTE alspreserve OF CCC_160M_ADJ 	: SIGNAL IS TRUE;

ATTRIBUTE syn_keep OF CCC_160M_1ADJ 	: SIGNAL IS TRUE;
ATTRIBUTE alspreserve OF CCC_160M_1ADJ 	: SIGNAL IS TRUE;

ATTRIBUTE syn_keep OF CCC_160M_2ADJ 	: SIGNAL IS TRUE;
ATTRIBUTE alspreserve OF CCC_160M_2ADJ 	: SIGNAL IS TRUE;

-- THESE ARE THE SIGNALS FOR THE CONFIGURATION SHIFT REGISTER FOR CCC_AUX (DYNAMIC 160 PHASE ADJ OUTPUTS)
SIGNAL  AUX_MODE                        :   STD_LOGIC;                                  -- '0' CONFIG CCC USING FUSE BITS, '1' CONFIG CCC DYNAMICALLY
SIGNAL  AUX_SDIN                        :   STD_LOGIC;                                  -- SERIAL CONFIG DATA INPUT
SIGNAL  AUX_SSHIFT                      :   STD_LOGIC;                                  -- SERIAL SHIFT ENABLE
SIGNAL  AUX_SUPDATE                     :   STD_LOGIC;                                  -- SERIAL UPDATE
SIGNAL  CCC2_RESET_EN                   :   STD_LOGIC_VECTOR(0 DOWNTO 0);               -- '1' FORCES A CCC RESET PULSE IMMEDIATELY AFTER CONFIG UPDATES, '0' DISABLES THIS FEATURE
SIGNAL  ALIGN_ACTIVE                    :   STD_LOGIC;                                  -- '1' INDICATES THAT THE ALIGN MODE IS ACTIVE

-- DATA FLOW SIGNALS
SIGNAL  SER_RX_IN_R                     :   STD_LOGIC;                                  -- SERIAL RX DDR RISE EDGE DATA
SIGNAL  SER_RX_IN_F                     :   STD_LOGIC;                                  -- SERIAL RX DDR FALL EDGE DATA
SIGNAL  RECD_SER_WORD                   :   STD_LOGIC_VECTOR(7 DOWNTO 0);               -- 40 MHZ BYTE STREAM OUT OF THE DE-SERIALIZER
SIGNAL  BIT_OS_SEL                      :   STD_LOGIC_VECTOR(2 DOWNTO 0);               -- BIT ALIGNMENT OFFSET VALUE DETERMINED BY MASTER DES320M AND USE DY ALL SLAVES

-- SMALLER VALUE FOR SIM MODE, LARGER VALUE FOR IMPLEMENTATION
SIGNAL      PLL_SS_TIME                 :   STD_LOGIC_VECTOR(13 DOWNTO 0);
CONSTANT    PLL_SS_TIME_IMPL            :   STD_LOGIC_VECTOR(13 DOWNTO 0) :=    "11111111111110";     
CONSTANT    PLL_SS_TIME_SIM             :   STD_LOGIC_VECTOR(13 DOWNTO 0) :=    "00000001111111";     

--HARD-WIRED ALIGNMENT PATTERN
CONSTANT    F_ALIGN_PATT                :   STD_LOGIC_VECTOR(7 DOWNTO 0) := "10001110";                 -- 8E HEX FIXED SYNC / ALIGNMENT PATTERN BYTE




--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- DEFINE THE ARCHITECTURE!
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

begin

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- CONFIGURE AND CONNECT THE COMPONENTS
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- THESE ARE THE THREE MODULES NEEDED FOR THE MASTER DE-SERIALIZER FUNCTION.  
-- IT USES BOTH A CLOCK WITH COMMANDED PHASE OFFSETS AND THE DESERIALIZER MODULE
-- INPUT REF CLOCK ASSUMED TO BE 160.0317 MHZ
U13A_ADJ_160M:GP_CCC_SCONFIG
    PORT MAP    (
                    SCFG_CLK            =>  CLK_40M_GL,             -- 
                    DEV_RST_B           =>  MASTER_POR_B,
                    CONFIG_ONCE_TRIG    =>  CCC2_CONFIG_TRIG,       -- CONFIG UPDATES TRIGGERED BY THE MASTER DESERIALIZER
                    FINDIV_A            =>  "0000111",
                    FBDIV_B             =>  "0011111",
                    OADIV_C             =>  "00000",
                    OBDIV_D             =>  "00000",
                    OCDIV_E             =>  "00000",
                    OAMUX_F             =>  "100",                  -- 
                    OBMUX_G             =>  "100",                  -- 
                    OCMUX_H             =>  "100",
                    FBSEL_I             =>  "10",
                    FBDLY_J             =>  "10111",                -- 
                    XDLYSEL_K           =>  "0",
                    DLYGLA_L            =>  PHASE_ADJ_160_L,        -- DELAY ONLY THE ADJ 160 MHZ
                    DLYGLB_M            =>  "00000",                -- AND KEEP THE FIXED 160 MHZ STEADY
                    DLYGLC_N            =>  "00000",
                    DLYYB_O             =>  "00000",
                    DLYYC_P             =>  "00000",
                    STATASEL_Q          =>  "1",                    -- 
                    STATBSEL_R          =>  "1",                    -- 
                    STATCSEL_S          =>  "1",                    -- 
                    VCOSEL_T            =>  "100",                  -- THE LSB IS THE LOCK CONTROL BIT!
                    DYNASEL_U           =>  "1",                    -- 
                    DYNBSEL_V           =>  "1",                    -- 
                    DYNCSEL_W           =>  "1",                    -- 
                    RESETEN_X           =>  "0",                    -- DO NOT WANT RESET EVER SINCE IT CAUSES A MOMENTARY DROPPED LOCK CONDITION! 
                    P_CCC1_MODE         =>  AUX_MODE,
                    P_SDIN              =>  AUX_SDIN,
                    P_SSHIFT            =>  AUX_SSHIFT,
                    P_SUPDATE           =>  AUX_SUPDATE
            );

-- CCC2:  GENERATE 3 PHASE ADJUSTABLE 160 MHZ CLOCKS FOR SERDES
U13B_CCC:CCC_DYN_TRIPLE_160M
    PORT MAP 	( 
					POWERDOWN 	=>  '1',                            -- '0' DISABLES THE PLL
					CLKA      	=>  CLK_40M_BUF_RECD,               -- 40 MHZ REF CLOCK DISTRIBUTED BY THE 'MASTER FPGA' ON THE MASTER DCB CONFIGURED COMET
					LOCK      	=>  CCC_RX_CLK_LOCK,
					GLA       	=>  CCC_160M_ADJ,                   -- ADJUSTABLE PHASE 160 MHZ
					GLB       	=>  CCC_160M_1ADJ,                  -- ADJUSTABLE PHASE 160 MHZ
					GLC       	=>  CCC_160M_2ADJ,                  -- ADJUSTABLE PHASE 160 MHZ
					SDIN      	=>  AUX_SDIN,
					SCLK      	=>  NOT(CLK_40M_GL),  
					SSHIFT    	=>  AUX_SSHIFT,
					SUPDATE   	=>  AUX_SUPDATE,
					MODE      	=>  AUX_MODE,                       -- START WITH FUSE CONFIG, BUT EVENTUALLY TRANSITION FOR DYNAMIC CONFIG MODE!
					SDOUT     	=>  OPEN
				);
				
				
-- MASTER RX DESERIALIZER.
U13C_MASTER_DESER:MASTER_DES320M
    PORT MAP    (
                    CCC_160M_ADJ       	=>  CCC_160M_ADJ,           -- CCC2 DYNAMIC PHASE ADJUSTABLE CLOCK
					CCC_160M_FXD		=>	CCC_160M_FXD,			-- CCC1 FIXED PHASE CLOCK
					
                    CCC2_CLK_LOCK       =>  CCC_RX_CLK_LOCK,        -- CCC2 LOCK STATUS
                    CLK_40M_FXD         =>  CLK_40M_GL,             -- CCC1 CLOCK SOURCE
 
                    RESET_B             =>  MASTER_POR_B,           -- SYNCHRONOUS RESET WAITS FOR CCC1 TO BE LOCKED AND STABLE

                    ALIGN_MODE_EN       =>  ALIGN_MODE_EN,          -- '1' = AUTO ALIGN MODE
                    ALIGN_PATT          =>  F_ALIGN_PATT,           -- HARD-WIRED / FIXED ALIGNMENT PATTERN

                    MAN_AUTO_ALIGN      =>  MAN_AUTO_ALIGN,         -- '1'= MANUAL BIT OFFSET AND PHASE ALIGNMENT, '0'=AUTO
                    MAN_BIT_OS          =>  MAN_BIT_OS,             -- MANUAL SELECTION OF THE BIT OFFSET
                    MAN_PHASE_ADJ       =>  MAN_PHASE_ADJ,          -- MANUAL PHASE ADJ VALUE OF 160 ADJ CCC#2

                    SER_IN_R            =>  SER_RX_IN_R,            -- RX DDR RISE OUTPUT SIGNAL
                    SER_IN_F            =>  SER_RX_IN_F,            -- RX DDR FALL OUTPUT SIGNAL

                    PLL_SS_TIME         =>  PLL_SS_TIME,            -- STEADY STATE TIME COUNT ALLOCATED FOR THE ADJUSTABLE PLL

                    DDR_Q0_RISE         =>  OPEN,                   -- TEST PORT VALUE OF THE REC'D DDR BIT STREAM (RISE)
                    DDR_Q1_FALL         =>  OPEN,                   -- TEST PORT VALUE OF THE REC'D DDR BIT STREAM (FALL)

                    PHASE_ADJ_160_L     =>  PHASE_ADJ_160_L,
                    P_CONFIG_ONCE_TRIG  =>  CCC2_CONFIG_TRIG,       -- PULSE TRIGGER TO FORCE A CCC#2 UPDATE
                    P_CCC_RESET_EN      =>  CCC2_RESET_EN,          -- '1' FORCES A CCC RESET PULSE IMMEDIATELY AFTER CONFIG UPDATES, '0' DISABLES THIS FEATURE

                    P_RECD_SER_WORD     =>  RECD_SER_WORD,          -- BYTE STREAM OUT OF THE DE-SERIALIZER
                    P_BIT_OS_SEL        =>  BIT_OS_SEL,             -- FINAL SELECTED BIT ALIGNMENT OFFSET VALUE
                    P_ALIGN_ACTIVE      =>  ALIGN_ACTIVE
                );
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- DEFINE PROCESSES
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- COMBINATORIAL PROCESS THAT DETERMINES THE SERIALIZER INPUT AND OUTPUT PORT CONNECTIONS VIA MUXES BASED UPON DCB_SALT_SEL CONFIG JUMPER

CH_SEL_MUX:PROCESS(DCB_SALT_SEL, ELINK0_DDR_R, ELINK0_DDR_F, TFC_DDR_R, TFC_DDR_F, RECD_SER_WORD)
        BEGIN
            IF DCB_SALT_SEL='1' THEN                                -- DCB CONFIG SELECTION (IE RECEIVES FROM DATA ELINKS)
                SER_RX_IN_R         <=  ELINK0_DDR_R;               -- SELECT THE ELINK DDR MASTER CHANNEL
                SER_RX_IN_F         <=  ELINK0_DDR_F;

                CH0_RAM_BPORT       <=  (OTHERS => '0');            -- NOT USED (IE CH0 RAM IS ONLY FOR TFC TX DATA)
                CH1_RAM_BPORT       <=  RECD_SER_WORD;              -- SERIAL DATA GETS ROUTED TO THE RAM CH1 STORAGE ALLOCATED FOR ELINK0

            ELSE                                                    -- SALT CONFIG SELECTION (IE RECEIVES THE TFC)
                SER_RX_IN_R         <=  TFC_DDR_R;                  -- SELECT THE ELINK DDR MASTER CHANNEL
                SER_RX_IN_F         <=  TFC_DDR_F;

                CH0_RAM_BPORT       <=  RECD_SER_WORD;              -- SERIAL DATA GETS ROUTED TO THE RAM CH0 STORAGE ALLOCATED FOR TFC
                CH1_RAM_BPORT       <=  (OTHERS => '0');            -- NOT USED (IE CH1 RAM IS ONLY FOR ELINK TX DATA)

            END IF;
        END PROCESS;

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- COMBINATORIAL PROCESS THAT DETERMINES THE TIME ALLOWED FOR THE CCC2 PLL TO STABILIZE AFTER A TUNE UPDATE ---DETERMINED BY COMET BOARD JUMPER.

SIM:PROCESS(SIM_MODE)
    BEGIN
        IF SIM_MODE = '1' THEN
            PLL_SS_TIME     <=  PLL_SS_TIME_SIM;
        ELSE
            PLL_SS_TIME     <=  PLL_SS_TIME_IMPL;
        END IF;
    END PROCESS;

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ASSIGN INTERNAL SIGNALS TO EXTERNAL PORTS
P_CCC_160M_ADJ          <=  CCC_160M_ADJ;
P_CCC_160M_1ADJ         <=  CCC_160M_1ADJ;
P_CCC_160M_2ADJ         <=  CCC_160M_2ADJ;

P_CCC_RX_CLK_LOCK       <=  CCC_RX_CLK_LOCK;
P_BIT_OS_SEL            <=  BIT_OS_SEL;
P_ALIGN_ACTIVE          <=  ALIGN_ACTIVE;

end RTL;
