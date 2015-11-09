library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--use IEEE.NUMERIC_STD.ALL;

entity rfChangeDetect is
    generic (DETECT_RANGE : integer := 3);
    Port ( clk : in STD_LOGIC;
           speedIn, steeringIn : in STD_LOGIC;
           speedOut, steeringOut : out integer);
end rfChangeDetect;

architecture Behavioral of rfChangeDetect is

signal temp_speed : STD_LOGIC;

begin
	--- Speed signal ---
	MONITORING_SPEED: process(clk)
		variable speed_count : integer range 0 to 250;
		variable speed_flag : boolean;	
	begin	
		if rising_edge(clk) then
			if speedIn = '1' then
				speed_count := speed_count + 1;
				speed_flag := true;				
			else
				if speed_flag = true then
				    speedOut <= speed_count;
				    speed_count := 0;
					speed_flag := false;	
				end if;					
			end if;
		end if;
	end process MONITORING_SPEED;
	
    --- Steering signal ---
    MONITORING_STEERING: process(clk)
        variable steering_count : integer range 0 to 250;
        variable steering_flag : boolean;    
    begin    
        if rising_edge(clk) then
            if steeringIn = '1' then
                steering_count := steering_count + 1;
                steering_flag := true;                
            else
                if steering_flag = true then
                    steeringOut <= steering_count;
                    steering_count := 0;
                    steering_flag := false;    
                end if;                    
            end if;
        end if;
    end process MONITORING_STEERING;
end Behavioral;