--------------------------------------------------------------------------------
-- Company: UNIVERSITY OF MARYLAND
--
-- File: DDR_BIDIR_LVDS_DUAL_CLK.vhd
-- File history:
--      REV - 
--
-- Description: THIS IS A SPECIAL VARIANT OF THE DDR BIDIRECTIONAL REGISTER.
--                  * OUTPUT STD IS LVDS
--                  * THERE ARE SEPARATE CLOCKS FOR THE RX AND TX FUNCTIONS
--                  * THE CLEAR FUNCTION IS COMMON (FABRIC RESTRICTION)
--
-- Targeted device: <Family::ProASIC3E> <Die::A3PE1500> <Package::208 PQFP>
-- Author: TOM O'BANNON
-- (VHDL source note:  auto-generated from previous 'testddrconfig' schema)
--------------------------------------------------------------------------------

library IEEE;

use IEEE.std_logic_1164.all;

entity DDR_BIDIR_LVDS_DUAL_CLK is
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
end DDR_BIDIR_LVDS_DUAL_CLK;
----------------------------------------------------------------------
-- DDR_BIDIR_LVDS_DUAL_CLK architecture body
----------------------------------------------------------------------
architecture RTL of DDR_BIDIR_LVDS_DUAL_CLK is

-- FORCE THE COMMON CLR CONNECTION
ATTRIBUTE SYN_PRESERVE : BOOLEAN;
ATTRIBUTE SYN_PRESERVE OF RTL :  ARCHITECTURE IS TRUE;   

--attribute syn_black_box : boolean; 
--attribute syn_black_box of rtl: architecture is true; 
----------------------------------------------------------------------
-- Component declarations
----------------------------------------------------------------------

-- BIBUF_LVDS:  BI-DIRECTIONAL LVDS
component BIBUF_LVDS
    -- Port list
    port(
        -- Inputs
        D    : in    std_logic;
        E    : in    std_logic;             -- E= '1' ENABLES THE OUTPUT

        -- Outputs
        Y    : out   std_logic;

        -- Inouts
        PADN : inout std_logic;
        PADP : inout std_logic
        );
end component;

-- DDR_OUT:  SEPARATE RISE AND FALL INPUTS TO A SINGLE DOUBLE RATE OUTPUT USING BOTH CLOCK EDGES
component DDR_OUT
    -- Port list
    port(
        -- Inputs
        CLK : in  std_logic;
        CLR : in  std_logic;
        DF  : in  std_logic;
        DR  : in  std_logic;

        -- Outputs
        Q   : out std_logic
        );
end component;

-- DDR_REG:  SINGLE 'D' INPUT SAMPLED ON BOTH RISE AND FALL CLOCK EDGES
component DDR_REG
    -- Port list
    port(
        -- Inputs
        CLK : in  std_logic;
        CLR : in  std_logic;
        D   : in  std_logic;

        -- Outputs
        QF  : out std_logic;
        QR  : out std_logic
        );
end component;
----------------------------------------------------------------------
-- Signal declarations
----------------------------------------------------------------------
signal BIBUF_LVDS_0_Y : std_logic;
signal DDR_OUT_0_Q    : std_logic;
signal DDR_RX_F_net_0 : std_logic;
signal DDR_RX_R_net_0 : std_logic;
signal DDR_RX_R_net_1 : std_logic;
signal DDR_RX_F_net_1 : std_logic;

SIGNAL DDR_COM_CLR  : STD_LOGIC;

begin
----------------------------------------------------------------------
-- Top level output port assignments
----------------------------------------------------------------------
 DDR_RX_R_net_1 <= DDR_RX_R_net_0;
 DDR_RX_R       <= DDR_RX_R_net_1;
 DDR_RX_F_net_1 <= DDR_RX_F_net_0;
 DDR_RX_F       <= DDR_RX_F_net_1;
 DDR_COM_CLR    <= DDR_CLR;
----------------------------------------------------------------------
-- Component instances
----------------------------------------------------------------------
-- BIBUF_LVDS_0
BIBUF_LVDS_0 : BIBUF_LVDS
    port map( 
        -- Inputs
        D    => DDR_OUT_0_Q,
        E    => DDR_DIR,
        -- Outputs
        Y    => BIBUF_LVDS_0_Y,
        -- Inouts
        PADP => PADP,
        PADN => PADN 
        );
-- DDR_OUT_0
DDR_OUT_0 : DDR_OUT
    port map( 
        -- Inputs
        DR  => DDR_TX_R,
        DF  => DDR_TX_F,
        CLK => DDR_TX_CLK,
        CLR => '0',
        -- Outputs
        Q   => DDR_OUT_0_Q 
        );
-- DDR_REG_0
DDR_REG_0 : DDR_REG
    port map( 
        -- Inputs
        D   => BIBUF_LVDS_0_Y,
        CLK => DDR_RX_CLK,
        CLR => '0',
        -- Outputs
        QR  => DDR_RX_R_net_0,
        QF  => DDR_RX_F_net_0 
        );

end RTL;