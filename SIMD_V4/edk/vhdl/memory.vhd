----------------------------------------------------------------------------------
-- Company: UNCC
-- Engineer: Sumanth kumar Bandi
-- 
-- Create Date:    12:19:35 06/18/2014 
-- Design Name: 
-- Module Name:    memory - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
--use IEEE.math_real.all;
use IEEE.NUMERIC_STD.ALL;


entity memory is
	generic(
			word_size: integer;		-- # of bits per word
			ram_size : integer;	-- size of the RAM with total # of words.
			req_addr : integer
			);
			
	port (
		clk 		: in std_logic;
		rst		: in std_logic;
		ce			: in std_logic;
		wr			: in std_logic;
		addr 		: in std_logic_vector(0 to (req_addr-1));
		data_in 	: in std_logic_vector(0 to word_size-1);

		data_out : out std_logic_vector(0 to word_size-1);
		ack		: out std_logic		);
		
  attribute MAX_FANOUT : string;
  attribute SIGIS : string;

  attribute SIGIS of clk      : signal is "CLK";
  attribute SIGIS of rst      : signal is "RST";
end memory;

architecture Behavioral of memory is
	type ram_array is array (0 to ram_size-1) of std_logic_vector(0 to word_size-1);
	signal RAM: ram_array; 

----------------------------------BEGIN ARCHITECTURE----------------------------------------------------

BEGIN
process(clk,rst, wr, ce)
begin

	if clk'event and clk ='1' then			--comment this line for asynchronous memory access
		--Reset condition

		if (rst ='1') then
			ack<='0';
				for i in 0 to ram_size-1 loop
					RAM(i)<= (others=>'0');
				end loop;
		
		--Normal condition	
		elsif (rst ='0' and ce ='1') then
				--read_condition:
			if wr = '0' then
				data_out <= RAM(to_integer(unsigned(addr)));
				ack <='1';
				
				--write condition:
			elsif wr ='1' then
				RAM(to_integer(unsigned(addr)))<=data_in;
				ack <='1';
			end if;
		
		--Disabled condition: --ce = 0 n rst=0
		elsif ce='0' then
			ack<='0';
				
		end if ;
		
	end if ;

end process;		
			

END Behavioral;

