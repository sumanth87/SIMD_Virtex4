----------------------------------------------------------------------------------
-- Company: UNCC
-- Engineer: Sumanth kumar Bandi
-- 
-- Create Date:    11:41:56 06/18/2014 
-- Design Name: 
-- Module Name:    bram_code - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

library simd2_v2_00_a;
use simd2_v2_00_a.generic_values_pe.all;


entity bram_code is
	port (
			clk 	: in std_logic;
			ce		: in std_logic;
			addr 	: in std_logic_vector(0 to (code_req_addr)-1);
			data 	: out std_logic_vector(0 to (mneumonic_size)-1);
			ready : out std_logic		
			);
		
  attribute MAX_FANOUT : string;
  attribute SIGIS : string;

  attribute SIGIS of clk      : signal is "CLK";
end bram_code;



architecture Behavioral of bram_code is

	type rom_type is array (0 to (code_memory)-1) of std_logic_vector (0 to (mneumonic_size)-1);
	signal ROM : rom_type:= (
			"1000000000",		--LD r0,0h	-m
			"1000100001",		--LD r2,1h	-b
			
			"1000010010",		--LD r1,2h		-x0
			"0011110100",		--mul r3=r1*r0
			"0001011110",		--add r1=r3+r2
			"1100011000",		--ST r1,8h		-Y0
								
			"1000010011",		--LD r1,3h		-x1
			"0011110100",		--mul r3=r1*r0
			"0001011110",		--add r1=r3+r2
			"1100011001",		--ST r1,9h		-Y1
								
			"1000010100",		--LD r1,4h		-x2
			"0011110100",		--mul r3=r1*r0
			"0001011110",		--add r1=r3+r2
			"1100011010",		--ST r1,Ah		-Y2
						
			"1000010101",		--LD r1,5h		-x3
			"0011110100",		--mul r3=r1*r0
			"0001011110",		--add r1=r3+r2
			"1100011011",		--ST r1,Bh		-Y3
								
			"1000010110",		--LD r1,6h		-x4
			"0011110100",		--mul r3=r1*r0
			"0001011110",		--add r1=r3+r2
			"1100011100",			--ST r1,Ch		-Y4
			others=>(others=>'0')
								
			) ;

----------------------------------BEGIN ARCHITECTURE----------------------------------------------------	

BEGIN
process (ce)
	begin
	
	--if (clk'event and clk = '1') then
		
		if (ce = '1') then
			data <= ROM(to_integer(unsigned(addr)));
			ready <= '1';
		else
			ready <= '0';
			--data <= (others=>'0');
		end if;

	--end if;
end process;


end Behavioral;

