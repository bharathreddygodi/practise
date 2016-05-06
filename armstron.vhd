------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------
--   Filename:     armstrong.vhd
--   Created by:   Bharath Reddy Godi, Surendra Maddula, Nikhil Marda
--   Date:         Apr 19, 2016
--   ECE 590: Digital systems design using hardware description language (VHDL).
--   Assignment 1
--   This is an FSMD based Armstrong number generator, which takes inputs clk, reset, load, data_in
--   and gives output done when operation is finished and gives ouput whther given number is armstrong
--   number or not by asserting outputs armstrong or not_armstrong.
------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity arm_str is port(
	clk, reset: in std_logic; 
	load: in std_logic;
	data_in: in std_logic_vector(9 downto 0);
	done: out std_logic;
	armstrong: out std_logic;
	not_armstrong: out std_logic;
	error: out std_logic);
end arm_str;

architecture behavioral of arm_str is

	constant three: unsigned(2 downto 0) := "011";
	constant one: unsigned(2 downto 0) := "001";
	constant two: unsigned(2 downto 0) := "010";
	constant zero: unsigned(2 downto 0) := "000";
	constant range_value: integer:= 1000;
	constant ten: integer:= 10;
	constant hundred: integer:= 100;
	constant thousand: integer:= 1000;
	type state_type is (idle, error_state, modulo, multiply, add, comp, done_state, reset_state);
	signal state_reg, state_next: state_type;
	--signal a_is_0, b_is_0, count_0: std_logic;
	signal a_reg, a_next: unsigned(9 downto 0); 
	signal b_reg, b_next: unsigned(9 downto 0); 
	signal c_reg, c_next: unsigned(9 downto 0); 
	signal c_addition: unsigned(9 downto 0);
	signal a_mul, b_mul, c_mul: unsigned(19 downto 0);
	signal count_reg, count_next, counter, counter_value: unsigned(2 downto 0); 
	signal comp_count, arm_compare, counter_sub: std_logic;
	signal range_comp: std_logic;
	signal mod_ten, mod_hundred, mod_thousand,int_hundred: unsigned(9 downto 0);
	--signal adder_out: unsigned(2*WIDTH-1 downto 0); 
	--signal sub_out: unsigned(WIDTH-1 downto 0);

begin

	-- control path: state register
	process(clk, reset)
	begin
		if (reset = '1') then
			state_reg <= reset_state;
		elsif (clk'event and clk = '1') then
			state_reg <= state_next;
		end if; 
	end process;

	-- control path: next-state/output logic
	process(state_reg, load, range_comp, comp_count, counter_sub)
	begin
		case state_reg is 
			when idle =>
				if (load = '1') then
					if (range_comp = '1') then	-- Compares whether the given input is above working range (>999)
						state_next <= error_state;
					else 
						state_next <= modulo;
					end if;
					
				else
					state_next <= idle;
				end if; 
			
			when error_state =>
				state_next <= idle;

			when modulo =>
				if (comp_count = '1') then
					state_next <= comp;
				else
					state_next <= multiply;
				end if;

			when multiply =>
				if (counter_sub) = '1' then
					state_next <= add;
					report "add";					
				else
					state_next <= multiply;
					report "multiply";
				end if;

			when add =>
				state_next <= comp;

			when comp =>
				state_next <= done_state;

			when done_state =>
				state_next <= idle;
			when reset_state =>
				state_next <= idle;

		end case;
	end process;

-- control path: output logic
done <= '1'  when state_reg=done_state else '0';
armstrong <= arm_compare when state_reg=comp else '0';
not_armstrong <= not(arm_compare) when state_reg=comp else '0';
error <= '1' when state_reg=error_state else '0';


-- data path: data register
process(clk, reset)
begin
	if	(reset = '1') then 
		a_reg <= (others=>'0'); 
		b_reg <= (others=>'0'); 
		c_reg <= (others=>'0');
		count_reg <= (others=>'0');
	elsif (clk'event and clk= '1') then
		a_reg <= a_next; 
		b_reg <= b_next; 
		c_reg <= c_next;
		count_reg <= count_next;
	end if; 
end process;

-- data path: routing multiplexer
	
	process(state_reg, mod_ten, mod_hundred, mod_thousand, counter_value, a_mul, b_mul, c_mul, counter, c_addition)
	begin
		case state_reg is 
			when idle =>
				a_next <= (others=>'0');
				b_next <= (others=>'0');
				c_next <= (others=>'0');
				count_next <= (others=>'0');
				
			when error_state =>
				a_next <= (others=>'0');
				b_next <= (others=>'0');
				c_next <= (others=>'0');
				count_next <= (others=>'0');

			when modulo =>
				a_next <= mod_thousand;
				b_next <= mod_hundred;
				c_next <= mod_ten;
				count_next <= counter_value;

			when multiply =>
				a_next <= a_mul(9 downto 0);
				b_next <= b_mul(9 downto 0);
				c_next <= c_mul(9 downto 0);
				count_next <= counter;

			when add =>
				a_next <= a_reg;
				b_next <= b_reg;
				c_next <= c_addition(9 downto 0);
				count_next <= count_reg;

			when comp =>
				a_next <= a_reg;
				b_next <= b_reg;
				c_next <= c_reg;
				count_next <= count_reg;

			when done_state =>
				a_next <= (others=>'0');
				b_next <= (others=>'0');
				c_next <= (others=>'0');
				count_next <= (others=>'0');
			
			when reset_state =>
				a_next <= (others=>'0');
				b_next <= (others=>'0');
				c_next <= (others=>'0');
				count_next <= (others=>'0');

		end case;
	end process;

range_comp <= '1' when unsigned(data_in) > "1111100111" else '0';

--modulo
mod_ten <= unsigned(data_in) mod ten;
int_hundred <= (unsigned(data_in) mod hundred);
mod_hundred <= ((int_hundred - mod_ten)/ten);
mod_thousand <= ((unsigned(data_in) mod thousand) - int_hundred)/hundred;
counter_value <= one when unsigned(data_in) < ten else
		 two when unsigned(data_in) < hundred else three;
--
comp_count <= '1' when unsigned(data_in) < ten  else '0';
counter_sub <= '1' when counter = "001" else '0';
counter <= count_reg - "001";
a_mul <= a_reg * mod_thousand;
b_mul <= b_reg * mod_hundred;
c_mul <= c_reg * mod_ten;
c_addition <= a_reg + b_reg + c_reg;
arm_compare <= '1' when unsigned(data_in) = c_reg else '0';


end behavioral;