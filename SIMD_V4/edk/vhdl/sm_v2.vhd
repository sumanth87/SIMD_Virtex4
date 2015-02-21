----------------------------------------------------------------------------------
-- Company: UNCC
-- Engineer: Sumanth kumar Bandi
-- 
-- Create Date:    13:49:24 06/23/2014 
-- Design Name: 
-- Module Name:    sm_v2 - Behavioral 
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
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library simd2_v2_00_a;
use simd2_v2_00_a.generic_values_pe.all;


entity sm_v2 is
port (
		clk,rst:		in std_logic;
		ce:			in std_logic;
		
		--for code memory read
		ready_mem:	in std_logic;
		data		:	in std_logic_vector(0 to ( mneumonic_size)-1);
		addr		:	buffer std_logic_vector(0 to (code_req_addr)-1);
		mem_ce	: 	out std_logic;
		
		--for PE
		pcr	: out std_logic_vector(0 to 3);
		opcode: out std_logic_vector(0 to (mneumonic_opcode)-1);
		op_1	: out std_logic_vector(0 to (mneumonic_op1)-1);
		op_23	: out std_logic_vector(0 to (mneumonic_op23)-1);
		
		done:		out std_logic	--to signal completion(end of memory)
		);
		
	attribute MAX_FANOUT : string;
	attribute SIGIS : string;

	attribute SIGIS of clk      : signal is "CLK";
	attribute SIGIS of rst      : signal is "RST";
end sm_v2;



architecture Behavioral of sm_v2 is

	type state is (INITIAL, FETCH, DECODE, EXECUTE, MEM_ACCESS, WR_BACK, HOLD);
	signal pr_state, nx_state : state;
	signal temp: std_logic_vector(0 to (code_req_addr)-1);

----------------------------------BEGIN ARCHITECTURE----------------------------------------------------	

BEGIN
	------------------STATE update-------------------
	fsm: process(rst,clk,ce)
	begin
		if (clk'event and clk ='1') then
			--Reset condition: keeps state machine in Initial stage and initial address to "000"
			if (rst = '1') then
				pr_state<= INITIAL;
				temp <= (others=>'0');
			--Normal condition: 
				--when chip enabled - updates the present state to next state and increments memory address
				--when chip disabled- keeps the state machine in HOLD state while storing the next state to execute
			elsif (rst ='0') then
				if(ce='1') then
					pr_state <= nx_state;
						if(pr_state = MEM_ACCESS) then
							temp <= temp+1;
						end if;
				else	
					pr_state <= HOLD;
				end if;
			end if;
		end if;	
	end process fsm;
	
	------------------State ACTION-------------------
	process (data, addr, ce, pr_state, ready_mem, temp)
	begin

		case pr_state is
			--INITIAL: Disable all PE's and bram. keep done to low and next state to FETCH  
		when INITIAL =>
			done		<='0';
			pcr		<=(others=>'0');
			mem_ce	<='0';
			nx_state	<= FETCH;
			
			--FETCH: enable bram, update address. If bram completes job update next state to DECODE else stay at FETCH
		when FETCH	=>
			pcr		<=(others=>'0');
			addr		<= temp;
			mem_ce	<='1';
				if(ready_mem = '1') then					
					nx_state	<= DECODE;
				else
					nx_state	<= FETCH;
				end if;
				
					if(addr = "10110") then
							done	<= '1';
						else
							done	<= '0';
						end if;
				
			--DECODE: Disable bram, obtain opcode,i/p and o/p register number from obtained data and enable the alu.	
		when DECODE	=>	
				mem_ce	<='0';
				opcode	<=data(0 to mneumonic_opcode-1);
				op_1		<=data(mneumonic_opcode to mneumonic_opcode+mneumonic_op1-1);
				op_23		<=data(mneumonic_opcode+mneumonic_op1 to mneumonic_opcode+mneumonic_op1+mneumonic_op23-1);
					if((data(0)='1' and data(1)='1') or (data(0)='0')) then	--STORE op.
						pcr <= "1000";		--register file read
					else
						pcr<=(others=>'0');
					end if;
				nx_state<= EXECUTE;	
				
			--EXECUTE: When all ALU's finish the job disable them and update next state to UPDATE else stay at EXECUTE 				
		when EXECUTE	=>
					if(data(0)='0' ) then
						pcr <= "0100";	--PE enable
					else
						pcr<=(others=>'0');
					end if;	
					nx_state<= MEM_ACCESS;
					
			--MEM_ACCESS: 
		when MEM_ACCESS	=>
					if(data(0)='1' and data(1)='1') then	--STORE op.--final step
						pcr <= "0011";		--Memory Write 
					elsif(data(0)='1' and data(1)='0') then --LOAD op.
						pcr <= "0010";		--Memory Read
					else
						pcr<=(others=>'0');
					end if;
				nx_state<= WR_BACK;
				
			--WR_BACK: Check for end of memory and send status signal to simd_actual.			
		when WR_BACK		=>	
					if((data(0)='1' and data(1)='0') or (data(0)='0')) then --LOAD op.
						pcr <= "1001";		--Register file Write
					else
						pcr<=(others=>'0');
					end if;
						
				nx_state	<=FETCH;
				
			--HOLD: Only occurs when state machine is disabled. Disables ALU & bram while storing the next state, useful in case of abrupt disable.
		when HOLD		=>
				pcr<=(others=>'0');
				--no next stage until ce='1'
				
		end case;

	end process;


END Behavioral;



