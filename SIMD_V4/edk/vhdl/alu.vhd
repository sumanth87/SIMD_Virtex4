----------------------------------------------------------------------------------
-- Company: UNCC
-- Engineer: Sumanth kumar Bandi
-- 
-- Create Date:    13:43:47 06/19/2014 
-- Design Name: 
-- Module Name:    alu - Behavioral 
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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity alu is
	generic(
		constant mode_size: integer;
		constant word_size:integer	
		);

	port(	
		clk:in std_logic;
  		rst:in std_logic; 

		mode 	: in std_logic_vector(0 to 2);					
		ce		: in std_logic;
		ip1	: in std_logic_vector(0 to word_size-1);		
		ip2	: in std_logic_vector(0 to word_size-1);
		
		ack	: out std_logic;
		op	: out std_logic_vector(0 to word_size-1)
		);

  attribute MAX_FANOUT : string;
  attribute SIGIS : string;

  attribute SIGIS of clk      : signal is "CLK";
  attribute SIGIS of rst      : signal is "RST";
end alu;



architecture Behavioral of alu is

	signal temp : std_logic_vector(0 to 15);

----------------------------------BEGIN ARCHITECTURE----------------------------------------------------	

BEGIN
process(clk, rst, ce, temp, mode, ip1, ip2)
begin
			
	--if (clk'event and clk = '1' ) then
		if ( rst = '1') then
			ack <='0';	
			
		elsif ce ='1' then 
			case mode is
				when "000" => 
								op <= 	"00000000";		--clear
								ack <= '1';			--new value available								
				when "001" => 
								op <=   ip1 + ip2;		--add
								ack <= '1';
				when "010" =>
								op <=   ip1 - ip2;		--subtract
								ack <= '1';									
				when "011"=>
								temp <= (unsigned(ip1)) * (unsigned(ip2));--Multiply
								op  <= temp(8 to 15);									
								ack <= '1';	
				when "100"=> 
								op <= 	ip1 OR ip2;		--or
								ack <= '1';	
				when "101"=> 
								op <= 	ip1 AND ip2 ;		--and
								ack <= '1';
				when "110"=> 
								op <= 	NOT ip1 ;		--not 1st operand
								ack <= '1';
				when "111"=> 
								op <= 	NOT ip2;		--not 2nd operand
								ack <= '1';
				 when others => null;
        end case;	
			
		else
			ack<='0';
			
		end if;
		
	--end if;
			
end process;

end Behavioral;

