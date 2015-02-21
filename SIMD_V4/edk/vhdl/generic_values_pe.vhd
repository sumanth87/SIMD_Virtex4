LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
--use IEEE.math_real.all;

package generic_values_pe is
	constant word_size: integer :=8;		-- # of bits per word
	constant ram_size : integer :=16;		-- size of the RAM with total # of words.
	constant ram_req_addr : integer := 4;		--(integer(ceil(log2(real(ram_size)))));
	constant total_regs: integer :=4;
	constant reg_req_addr: integer := 2;		--(integer(ceil(log2(real(total_regs)))));
	constant mneumonic_op23: integer:=(2*reg_req_addr);--use max value among ram_req_addr and 2*reg_req_addr 
	constant mneumonic_op1: integer :=reg_req_addr;
	constant mneumonic_opcode: integer :=4;
	constant mode_size : integer := mneumonic_opcode-1;
	
	constant mneumonic_size: integer :=10;		--# of bits of mneumonic
	constant code_memory: integer :=32;		--Total array elements of code(i.e, no. of lines of code)
	constant	code_req_addr : integer := 5;	--(integer(ceil(log2(real(code_memory)))));

end generic_values_pe;
