----------------------------------------------------------------------------------
-- Company: UNCC
-- Engineer: Sumanth kumar Bandi
-- 
-- Create Date:    11:41:08 06/18/2014 
-- Design Name: 
-- Module Name:    PE - Behavioral 
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

library simd2_v2_00_a;
use simd2_v2_00_a.generic_values_pe.all;
use simd2_v2_00_a.alu;
use simd2_v2_00_a.memory; 
use simd2_v2_00_a.register_bank; 

entity pe is
	port(
		clk	: in std_logic;
		rst	: in std_logic;
		slv_1	: out	std_logic_vector(0 to word_size-1);
		slv_2 : out std_logic_vector(0 to word_size-1);
		slv_3 : out std_logic_vector(0 to word_size-1);
		slv_4 : out std_logic_vector(0 to word_size-1);
		
		mem5_wr_addr: in std_logic_vector(0 to ram_req_addr-1); --slv_regs5-8
		mem6_wr_data: in std_logic_vector(0 to word_size-1);
		mem7_rd_addr: in std_logic_vector(0 to ram_req_addr-1);
		mem8_rd_data: out std_logic_vector(0 to word_size-1);
		
		T_reg 	: in std_logic;
		T_mem_w	: in std_logic;
		T_mem_r	: in std_logic;
		
		pcr	: in std_logic_vector(0 to 3);
		opcode: in std_logic_vector(0 to mneumonic_opcode-1);
		op1	: in std_logic_vector(0 to mneumonic_op1-1);
		op2_3	: in std_logic_vector(0 to mneumonic_op23-1)
	);

  attribute MAX_FANOUT : string;
  attribute SIGIS : string;

  attribute SIGIS of clk      : signal is "CLK";
  attribute SIGIS of rst      : signal is "RST";
end PE;


architecture Behavioral of PE is
   
	 
	----Signal declaration---------------
	signal mem_ce,reg_ce, mem_wr, reg_ack, alu_ack, mem_ack:std_logic;
	signal op2_no,op3_no: std_logic_vector(0 to mneumonic_op1-1);
	signal reg_op1,reg_op2,reg_op3,reg_ip: std_logic_vector(0 to word_size-1);
	signal mode: std_logic_vector(0 to mode_size-1);
	signal alu_op, mem_op: std_logic_vector(0 to word_size-1);

	signal data_in,data_out: std_logic_vector(0 to word_size-1);
	signal mem_addr : std_logic_vector(0 to ram_req_addr-1);

	signal ext_mem: std_logic;
	signal ext_mux: std_logic_vector(0 to 1);

----------------------------------BEGIN ARCHITECTURE----------------------------------------------------	 

BEGIN
	--Instantiation of the Blocks
	uut_a: entity simd2_v2_00_a.register_bank
		generic map(
			word_size	=> word_size,	
			total_regs	=> total_regs,
			req_addr 	=> reg_req_addr
			)
		
		PORT MAP (
         	 clk => clk,
          	rst => rst,
          	ce => reg_ce,
          	wr => pcr(3),
          	op1_no => op1,
         	op2_no => op2_no,
         	op3_no => op3_no,

          	reg_op1 => reg_op1,	-- O/p for alu or memory(store) 
          	reg_op2 => reg_op2,	-- i/p for alu
		reg_op3 => reg_op3,	-- i/p from alu 
		reg_ip	=> reg_ip,	--memory(load)
			 
		slv_reg(0 to 7)  => slv_1,
		slv_reg(8 to 15) => slv_2,
		slv_reg(16 to 23)=> slv_3,
		slv_reg(24 to 31)=> slv_4,
		reg_update	 => T_reg,
			 
          	ack => reg_ack--
        	);
		  
	uut_b: entity simd2_v2_00_a.alu 
			generic map(
				word_size => word_size,
				mode_size => mode_size
				)
			PORT MAP (
          			clk => clk,
          			rst => rst,
         			mode => mode,
          			ce => pcr(1),
          			ip1 => reg_op2,
          			ip2 => reg_op3,
          			ack => alu_ack,
          			op => alu_op
        			);
		  
	uut_c: entity simd2_v2_00_a.memory 
			generic map(
			word_size	=> word_size,
			ram_size		=> ram_size,
			req_addr		=> ram_req_addr
			)
			PORT MAP (
          		clk => clk,
          		rst => rst,
          		ce => mem_ce, 		--mutilexed o/p of pcr(2) and 1 by T_w or T_r
          		wr => mem_wr, 		--mutilexed o/p of pcr(3) and (T_w or (notT_r)) by T_worT_r
          		addr => mem_addr,	--mutilexed o/p of rd_addr,wr_addr,op_23 by T_w,T_r
          		data_in => data_in,	--mutilexed o/p of reg_op1,wr_data by T_w
          		data_out => data_out,	--demuxed o/p to rd_data,mem_op by T_r
          		ack => mem_ack--
        		);

synthesize:
process (clk, pcr, opcode, ext_mem, ext_mux, T_mem_w, T_mem_r, mem_ack, alu_ack, data_out,reg_op1,mem_op,alu_op,op2_3,mem7_rd_addr,mem5_wr_addr,mem6_wr_data)
	begin
	--External Access to Memory
		operation:
		if (ext_mem='1') then
				case ext_mux is	
					-- when READ enabled	
					when "01" =>			
						mem_wr  <= '0';
						mem_addr<= mem7_rd_addr;
					-- when WRITE enabled
					when "10" =>			
						mem_wr  <= '1';
						mem_addr<= mem5_wr_addr;
						data_in <= mem6_wr_data;
					when others=> null;
				end case;
			mem_ce <= '1';
	
	
	--Normal Operation
		else
			mem_wr 	<= pcr(3);
			data_in	<= reg_op1;	--for memory write(store)
			mem_addr	<= op2_3;	
			mem_ce	<= pcr(2);
			
			--Reg file write operation
			if (pcr(0)='1' and pcr(3)='1') then	
				case opcode(0) is
					--incase of Load op.
					when '1' => 
						reg_ip <= mem_op;
					--incase of ALU op.
					when '0' => 
						reg_ip <= alu_op;
					when others => NULL;
				end case;
				reg_ce <= pcr(0);
			else
				reg_ce <= pcr(0);
			end if;
			
		end if operation;
	end process synthesize;
		
		
mem_demuxed:
	process(clk, mem_ce,ext_mem,pcr,data_out)
		begin
			--reset:
			if(rst='1') then
				mem8_rd_data<=(others=>'0');
			elsif(mem_ce='1' and rst='0') then
				if(ext_mem='1')then
					mem8_rd_data <= data_out;
				else
					mem_op <= data_out;
				end if;
			end if;
			
		end process mem_demuxed;


----Internal signal connections
ext_mem 	<= T_mem_w OR T_mem_r;
ext_mux 	<= T_mem_w & T_mem_r;
op2_no	<= op2_3(0 to reg_req_addr-1);
op3_no	<= op2_3(reg_req_addr to (2*reg_req_addr)-1);
mode		<= opcode(1 to mneumonic_opcode-1);


END Behavioral;

