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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top is
  Port (
  speed, steering, switchIn : in std_logic;
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
  FIXED_IO_ps_srstb : inout STD_LOGIC;
  muxselect_tri_o : out STD_LOGIC_VECTOR ( 0 to 0 );
  speeddutyint_tri_o : out STD_LOGIC_VECTOR ( 7 downto 0 );
  speedread_tri_i : in STD_LOGIC_VECTOR ( 7 downto 0 );
  steeringdutyint_tri_o : out STD_LOGIC_VECTOR ( 7 downto 0 );
  steeringread_tri_i : in STD_LOGIC_VECTOR ( 7 downto 0 );
  switch_tri_i : in STD_LOGIC_VECTOR ( 0 to 0 )
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

component mux is
    Port ( a : in STD_LOGIC;
           b : in STD_LOGIC;
           sel : in STD_LOGIC;
           output : out STD_LOGIC);
end component;

signal fastClk, slowClk : std_logic;
signal speedDuty,steeringDuty : std_logic_vector(7 downto 0) := "00000000";
signal muxSelect : std_logic_vector(0 downto 0);
signal speedTemp, steeringTemp : integer;
signal speedPWMout, steeringPWMout : std_logic;

begin

theClkDivider : entity xil_defaultlib.myClkDivider generic map (100000000,100000) port map (clk => fastClk, clkOut=> slowClk);
theRemote : entity xil_defaultlib.rfChangeDetect port map (clk => slowClk, speedIn => speed, steeringIn => steering, speedOut => speedTemp, steeringOut => steeringTemp);
theSpeed : entity xil_defaultlib.speedPWM port map (clk => slowClk, dutyCycle => to_integer(unsigned(speedDuty)), pwmOut => speedPWMout);
theSteering : entity xil_defaultlib.steeringPWM port map (clk => slowClk, dutyCycle => to_integer(unsigned(steeringDuty)), pwmOut => steeringPWMout);
thePS : entity xil_defaultlib.myPS_wrapper port map (FCLK_CLK0 => fastClk, muxselect_tri_o => muxSelect, speedread_tri_i => std_logic_vector(to_unsigned(speedTemp,8)),steeringread_tri_i => std_logic_vector(to_unsigned(steeringTemp,8)),switch_tri_i(0) => switchIn, steeringdutyint_tri_o => steeringDuty, speeddutyint_tri_o => speedDuty);
speedMux : entity xil_defaultlib.mux port map (a => speed, b=> speedPWMout, sel => muxSelect(0), output => speedOut);
steeringMux : entity xil_defaultlib.mux port map (a => steering, b=> steeringPWMout, sel => muxSelect(0), output => steeringOut);

end Behavioral;

