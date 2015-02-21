----------------------------------------------------------------------------------
-- Company: UNCC
-- Engineer: Sumanth kumar Bandi
-- 
-- Create Date:    14:42:57 06/19/2014 
-- Design Name: 
-- Module Name:    register_bank - Behavioral 
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

entity register_bank is
	generic(
			word_size	: integer ;		-- # of bits per word
			total_regs	: integer;		-- # no.of regs
			req_addr 	: integer 
			);
			
	port (
		clk 		: in std_logic;
		rst		: in std_logic;
		ce			: in std_logic;
		wr			: in std_logic;
		reg_update: in std_logic;
		
		op1_no	: in std_logic_vector(0 to (req_addr-1));
		op2_no	: in std_logic_vector(0 to (req_addr-1));
		op3_no	: in std_logic_vector(0 to (req_addr-1));
		
		reg_ip	: in std_logic_vector(0 to word_size-1);
		reg_op1 	: out std_logic_vector(0 to word_size-1);
		reg_op2 	: out std_logic_vector(0 to word_size-1);
		reg_op3	: out std_logic_vector(0 to word_size-1);
		
		slv_reg	: out std_logic_vector(0 to ((word_size * total_regs)-1));
		ack		: out std_logic		
		);
		
  attribute MAX_FANOUT : string;
  attribute SIGIS : string;

  attribute SIGIS of clk      : signal is "CLK";
  attribute SIGIS of rst      : signal is "RST";
end register_bank;



architecture Behavioral of register_bank is

	type reg_file is array (0 to total_regs-1) of std_logic_vector(0 to word_size-1);
	signal REG:reg_file; 

----------------------------------BEGIN ARCHITECTURE----------------------------------------------------
	
BEGIN
process(clk, rst, wr, ce, reg_update)
begin

	--if clk'event and clk ='1' then			--comment this line for asynchronous access
		--Reset condition

		if (rst ='1') then
			for i in 0 to total_regs-1 loop
				REG(i)<= (others=>'0');
			end loop;
			slv_reg <=(others=>'0');
			
		--Register read state		
		elsif (rst='0' and reg_update='1') then
			ack<='0';
			for i in 0 to total_regs-1 loop
				slv_reg(8*i to (8*i)+7)<=REG(i);
			end loop;
		
		--Normal condition	
		elsif (rst ='0' and ce ='1' and reg_update /='1') then
				--read_condition:
			if wr = '0' then
				reg_op1 <= REG(to_integer(unsigned(op1_no)));
				reg_op2 <= REG(to_integer(unsigned(op2_no)));
				reg_op3 <= REG(to_integer(unsigned(op3_no)));
				ack <='1';
				
				--write condition:
			elsif wr ='1' then
				REG(to_integer(unsigned(op1_no)))<=reg_ip;
				ack <='1';
			end if;
		
		--Disabled condition: --ce = 0 and rst=0
		else
			ack<='0';
				
		end if ;
		
	--end if ;

end process;		

END Behavioral;

