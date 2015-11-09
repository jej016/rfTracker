----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/04/2015 04:33:38 PM
-- Design Name: 
-- Module Name: top - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library xil_defaultlib;
use xil_defaultlib.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top is
  Port (
  speed, steering : in std_logic;
  speedOut, steeringOut : out std_logic
  );
end top;

architecture Behavioral of top is

component myPS_wrapper is
  port (
  DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
  DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
  DDR_cas_n : inout STD_LOGIC;
  DDR_ck_n : inout STD_LOGIC;
  DDR_ck_p : inout STD_LOGIC;
  DDR_cke : inout STD_LOGIC;
  DDR_cs_n : inout STD_LOGIC;
  DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
  DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
  DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
  DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
  DDR_odt : inout STD_LOGIC;
  DDR_ras_n : inout STD_LOGIC;
  DDR_reset_n : inout STD_LOGIC;
  DDR_we_n : inout STD_LOGIC;
  FCLK_CLK0 : out STD_LOGIC;
  FIXED_IO_ddr_vrn : inout STD_LOGIC;
  FIXED_IO_ddr_vrp : inout STD_LOGIC;
  FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
  FIXED_IO_ps_clk : inout STD_LOGIC;
  FIXED_IO_ps_porb : inout STD_LOGIC;
  FIXED_IO_ps_srstb : inout STD_LOGIC
);
end component;

component myClkDivider is
    generic(inputFreqency : integer := 100000000; outputFreqency : integer := 666 ); --Hz
    Port ( clk : in STD_LOGIC;
           clkOut : out STD_LOGIC
           );
end component;

component rfChangeDetect is
    generic (DETECT_RANGE : integer := 3);
    Port ( clk : in STD_LOGIC;
           speedIn, steeringIn : in STD_LOGIC;
           speedOut, steeringOut : out integer);
end component;

component speedPwm is
    Port ( clk : in STD_LOGIC;
            dutyCycle : in integer;
           pwmOut : out STD_LOGIC);
end component;

component steeringPWM is
    Port ( clk : in STD_LOGIC;
           dutyCycle : in integer;
           pwmOut : out STD_LOGIC);
end component;

signal fastClk, slowClk : std_logic;
signal speedDuty,steeringDuty : integer;

begin

theClkDivider : entity xil_defaultlib.myClkDivider generic map (100000000,100000) port map (clk => fastClk, clkOut=> slowClk);
theRemote : entity xil_defaultlib.rfChangeDetect port map (clk => slowClk, speedIn => speed, steeringIn => steering, speedOut => speedDuty, steeringOut => steeringDuty);
theSpeed : entity xil_defaultlib.speedPWM port map (clk => slowClk, dutyCycle => speedDuty, pwmOut => speedOut);
theSteering : entity xil_defaultlib.steeringPWM port map (clk => slowClk, dutyCycle => steeringDuty, pwmOut => steeringOut);
thePS : entity xil_defaultlib.myPS_wrapper port map (FCLK_CLK0 => fastClk);

end Behavioral;

