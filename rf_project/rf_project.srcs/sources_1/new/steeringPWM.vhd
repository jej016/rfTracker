----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/04/2015 04:44:55 PM
-- Design Name: 
-- Module Name: steeringPWM - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity steeringPWM is
    Port ( clk : in STD_LOGIC;
           dutyCycle : in integer;
           pwmOut : out STD_LOGIC);
end steeringPWM;

architecture Behavioral of steeringPWM is

signal counter : integer range 0 to 1000 := 0;
signal internalDutyCycle : integer := 160;
constant  minDutyCycle : integer := 110;
constant maxDutyCycle : integer := 210;

begin
    process(clk)
    begin
        if rising_edge(clk) then
            if counter < 1000 then
                counter <= counter + 1;
            else
                counter <= 0;
                if dutyCycle > maxDutyCycle then
                    internalDutyCycle <= maxDutyCycle;
                elsif dutyCycle < minDutyCycle then
                    internalDutyCycle <= minDutyCycle;
                else
                    internalDutyCycle <= dutyCycle;
                end if;
            end if;
            
            if counter < internalDutyCycle then
                pwmOut <= '1';
            else
                pwmOut <= '0';
            end if;                        
        end if;
    end process;

end Behavioral;