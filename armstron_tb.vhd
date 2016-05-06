LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;

ENTITY test_tb is
END test_tb;

ARCHITECTURE behavior OF test_tb IS

component arm_str port(
	clk, reset: in std_logic; 
	load: in std_logic;
	data_in: in std_logic_vector(9 downto 0);
	done: out std_logic;
	armstrong: out std_logic;
	not_armstrong: out std_logic;
	error: out std_logic);
end component;

signal clk : std_logic;
signal reset: std_logic;
signal load: std_logic;
signal data_in : std_logic_vector(9 downto 0);
signal done, armstrong, not_armstrong, error: std_logic;
constant CLOCK_PERIOD : time := 2 ns;

BEGIN

uut: arm_str port map(
	clk => clk,
	reset => reset,
	load => load,
	data_in => data_in,
	done => done,
	armstrong => armstrong,
	not_armstrong => not_armstrong,
	error => error
);

clocked_process: process
begin
    clk <= '0';
    wait for CLOCK_PERIOD/2 ;
    clk <= '1';
    wait for CLOCK_PERIOD/2;
end process;

--stimulus Process
Stimuli: process
begin
	reset <= '1';
    wait for 5 ns;
	reset <= '0';
	load <=  '1';
	data_in <= "0000000010";
    wait for 10 ns;
	load <=  '0';

    wait for 20 ns;
	reset <= '0';
	load <=  '1';
	data_in <= "0100010000";
    wait for 10 ns;
	load <=  '0';

    wait for 20 ns;
	reset <= '0';
	load <=  '1';
	data_in <= "0010011001";
    wait for 20 ns;
	reset <= '0';
	load <=  '1';
	data_in <= "1111111100";
    wait for 10 ns;
	load <=  '0';
    wait for 100 ns;

end process;
end behavior;