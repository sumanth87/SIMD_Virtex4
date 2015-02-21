----------------------------------------------------------------------------------
-- Company: 	UNCC
-- Engineer:	Sumanth Kumar Bandi 
-- 	
-- Create Date:    18:34:19 06/23/2014 
-- Design Name: 
-- Module Name:    simd_v2 - Behavioral 
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
use simd2_v2_00_a.sm_v2;
use simd2_v2_00_a.pe; 
use simd2_v2_00_a.bram_code; 



entity simdv2_actual is
	generic (N : Integer := 4);
	port(
  		clk,rst 	:in std_logic;
  		start		: in std_logic;
  		T_reg, T_mem_w, T_mem_r:in std_logic;
  		--For register read
  		slvreg_1,slvreg_2,slvreg_3,slvreg_4:out std_logic_vector(0 to 31);
  		--For memory operation(read and write)
  		slvreg_5,slvreg_6,slvreg_7: in std_logic_vector(0 to 31);
  		slvreg_8	: buffer std_logic_vector(0 to 31);
  		stop		: buffer std_logic				 
		);

  attribute MAX_FANOUT : string;
  attribute SIGIS : string;

  attribute SIGIS of clk : signal is "CLK";
  attribute SIGIS of rst : signal is "RST";
end simdv2_actual;

architecture Behavioral of simdv2_actual is
	
	--Signal declarations
	signal mem_ce, ready_mem, done, sm_select, sm_ce : std_logic;
	signal data		: std_logic_vector(0 to (mneumonic_size)-1);
	signal addr		: std_logic_vector(0 to (code_req_addr)-1);
	signal opcode	: std_logic_vector(0 to mneumonic_opcode-1);
	signal op_1	: std_logic_vector(0 to mneumonic_op1-1);
	signal op_23	: std_logic_vector(0 to mneumonic_op23-1);
	signal pcr		: std_logic_vector(0 to 3);
	--for chipscope
	signal control		: std_logic_vector(35 downto 0);



	--Component declaration
	component chipscope_ila IS
  		port (
    		CONTROL: inout std_logic_vector(35 downto 0);
    		CLK: in std_logic;
    		TRIG0: in std_logic_vector(2 downto 0);
    		TRIG1: in std_logic_vector(31 downto 0);
    		TRIG2: in std_logic_vector(31 downto 0);
    		TRIG3: in std_logic_vector(31 downto 0);
    		TRIG4: in std_logic_vector(31 downto 0);
    		TRIG5: in std_logic_vector(1 downto 0);
    		TRIG6: in std_logic_vector(4 downto 0);
    		TRIG7: in std_logic_vector(9 downto 0);
    		TRIG8: in std_logic_vector(9 downto 0):="0000000000";
    		TRIG9: in std_logic_vector(3 downto 0);
    		TRIG10: in std_logic_vector(0 to 0):="0";
    		TRIG11: in std_logic_vector(0 to 0):="0";
    		TRIG12: in std_logic_vector(0 to 0):="0";
    		TRIG13: in std_logic_vector(0 to 0):="0";
    		TRIG14: in std_logic_vector(0 to 0):="0");
	end component chipscope_ila;
	
	component chipscope_icon IS
  		port (
    		CONTROL0: inout std_logic_vector(35 downto 0));
	end component chipscope_icon;

	--function to vectorize data
 	function vectorize(s: std_logic) return std_logic_vector is
 		variable v: std_logic_vector(0 downto 0);
 	begin
   		v(0):= s;
        	return v;
 	end;

BEGIN
	--Instantiating components
	uut: entity simd2_v2_00_a.sm_v2 PORT MAP (
          clk 	=> clk,
          rst 	=> rst,
          ce 	=> sm_ce,
          ready_mem => ready_mem,
          data 	=> data,
          addr 	=> addr,
          mem_ce 	=> mem_ce,
          pcr 		=> pcr,
          opcode 	=> opcode,
          op_1 	=> op_1,
          op_23 	=> op_23,
          done 	=> done
        );
	uut1:entity simd2_v2_00_a.bram_code 
		port map(
			clk =>clk,	
			ce	=>mem_ce, 	
			ready => ready_mem,
         data => data,
         addr => addr		
			);
	uut_pe: for I in 0 to N-1 generate proc_ele:
		entity simd2_v2_00_a.pe PORT MAP(
			clk	=> clk,
			rst	=> rst,
			slv_1	=> slvreg_1(I*word_size to (I*word_size)+word_size-1 ),
			slv_2 => slvreg_2(I*word_size to (I*word_size)+word_size-1 ),
			slv_3 => slvreg_3(I*word_size to (I*word_size)+word_size-1 ),
			slv_4 => slvreg_4(I*word_size to (I*word_size)+word_size-1 ),
			mem5_wr_addr	=> slvreg_5( (I*word_size)+word_size-ram_req_addr to (I*word_size)+word_size-1 ), --slv_regs5-8
			mem6_wr_data	=> slvreg_6( I*word_size to (I*word_size)+word_size-1 ),
			mem7_rd_addr	=> slvreg_7( (I*word_size)+word_size-ram_req_addr to (I*word_size)+word_size-1 ),
			mem8_rd_data	=> slvreg_8( I*word_size to (I*word_size)+word_size-1 ),
			T_reg 	=> T_reg,
			T_mem_w	=> T_mem_w,
			T_mem_r	=> T_mem_r,
			pcr	=> pcr,
			opcode=> opcode,
			op1	=> op_1,
			op2_3	=> op_23
			);
		end generate uut_pe;

	

----External operation control
	process(T_reg,T_mem_w,T_mem_r, sm_select)
	begin
		if(T_reg = '1' or T_mem_w='1' or T_mem_r='1') then
			sm_ce<='0';
		else
			sm_ce<=sm_select;
		end if;
	end process;

----
	----Start & Stop process
	process(start,done,rst)
	begin
		if(rst='1') then
			sm_select	<='0';
			stop		<='0';
		elsif(rst= '0') then
			if(start='1' and done /= '1') then
				stop		<='0';				
				sm_select	<='1';
			elsif(start='1' and done='1') then
				stop		<='1';
				sm_select	<='0';
			else
				sm_select	<='0';
			end if;
		else
			sm_select	<='0';
		end if;
	end process;


--CHIPSCOPE INSTATNTIATION:
	uut_ila:chipscope_ila
  		port map(
    		CONTROL	=> control,
    		CLK	=> clk,
    		TRIG0(0)	=> (start),
		TRIG0(1)	=>  (done),
		TRIG0(2)	=>  (stop),
    		TRIG1	=> slvreg_5,
    		TRIG2	=> slvreg_6,
    		TRIG3	=> slvreg_7,
    		TRIG4	=> slvreg_8,
    		TRIG5(0)	=>  (sm_select),
		TRIG5(1)	=> (sm_ce),
    		TRIG6	=> addr,
    		TRIG7	=> data,
    		TRIG8(3 downto 0)	=> opcode,
			TRIG8(5 downto 4)	=> op_1,
			TRIG8(9 downto 6)	=> op_23,
    		TRIG9	=> pcr,
    		TRIG10	=> vectorize( (mem_ce)),
    		TRIG11	=> vectorize( (ready_mem)),
    		TRIG12	=> vectorize( (T_reg)),
    		TRIG13	=> vectorize( (T_mem_r)),
    		TRIG14	=> vectorize( (T_mem_w))
		);
	uut_icon:chipscope_icon
  		port map(
    		CONTROL0	=> control
		);


END Behavioral;

