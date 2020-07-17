-------------------------------------------------------
-- Auto-generated module template: DE10_LITE_Default
--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
 
entity DE10_LITE_Default is
	port (
	-- CLOCK
		ADC_CLK_10 			: in std_logic;
		MAX10_CLK1_50 		: in std_logic;
		MAX10_CLK2_50 		: in std_logic;
	-- SDRAM
		DRAM_ADDR 			: out std_logic_vector(12 downto 0);
		DRAM_BA 				: out std_logic_vector(1 downto 0);
		DRAM_CAS_N 			: out std_logic;
		DRAM_CKE 			: out std_logic;
		DRAM_CLK 			: out std_logic;
		DRAM_CS_N 			: out std_logic;
		DRAM_DQ 				: inout std_logic_vector(15 downto 0);
		DRAM_LDQM 			: out std_logic;
		DRAM_RAS_N 			: out std_logic;
		DRAM_UDQM 			: out std_logic;
		DRAM_WE_N 			: out std_logic;
	-- SEG7
		HEX0 					: out std_logic_vector(7 downto 0);
		HEX1 					: out std_logic_vector(7 downto 0);
		HEX2 					: out std_logic_vector(7 downto 0);
		HEX3					: out std_logic_vector(7 downto 0);
		HEX4					: out std_logic_vector(7 downto 0);
		HEX5 					: out std_logic_vector(7 downto 0);
	-- KEY
		KEY 					: in std_logic_vector(1 downto 0);
	-- LED
		LEDR 					: out std_logic_vector(9 downto 0);
	-- SW
		SW 					: in std_logic_vector(9 downto 0);
	-- VGA
		VGA_B 				: out std_logic_vector(3 downto 0);
		VGA_G 				: out std_logic_vector(3 downto 0);
		VGA_HS 				: out std_logic;
		VGA_R 				: out std_logic_vector(3 downto 0);
		VGA_VS 				: out std_logic;
	-- Accelerometer
		GSENSOR_INT 		: in std_logic_vector(2 downto 1);
		GSENSOR_CS_N 		: out std_logic;	
		GSENSOR_SCLK 		: out std_logic;
		GSENSOR_SDI 		: inout std_logic;
		GSENSOR_SDO 		: inout std_logic;
	-- Arduino
		ARDUINO_IO 			: inout std_logic_vector(15 downto 0);
		ARDUINO_RESET_N 	: inout std_logic;
	-- GPIO, GPIO connect to GPIO Default
		GPIO 					: inout std_logic_vector(35 downto 0)
    );
end DE10_LITE_Default;
 
architecture RTL of DE10_LITE_Default is

component Reset_Delay is
	port (
		iCLK : in std_logic;
		oRESET : out std_logic
	);
end component;
component ClkGen is
   generic (N : integer);
   port (
	   CLK, RESET : in std_logic;
		CLKout : out std_logic
	);
end component;
component UpDownCounter is
   port (
      CLK, RESET : in std_logic;
      EN, UD, SET	: in std_logic;
      Cin : in std_logic_vector(3 downto 0);
      Cout : out std_logic_vector(3 downto 0);
      CB : out std_logic
   );
end component;
component SegmentDecoder is
   port (
      Din : in std_logic_vector(3 downto 0);
      Dout : out std_logic_vector(7 downto 0)
   );
end component;	
component MIPSnp is
    port(
        CLK, RESET : in std_logic;
		  EN : in std_logic; --Enavle
		  RegN : in std_logic_vector(2 downto 0); --Reg number
        PCout : out std_logic_vector(7 downto 0);
		  regD : out std_logic_vector(15 downto 0) -- Reg Data
    );
end component;

component Chattering is
    port (
        clk		: in std_logic;
		  reset  : in std_logic;
		  sw_in	: in std_logic;
        sw_out	: out std_logic
    );
end component;

component TogleFF is
    port (
        reset	: in std_logic;
		  Tin		: in std_logic;
        Tout	: out std_logic
    );
end component;

signal DLY_RST : std_logic;
signal clk, clk1, reset : std_logic;
signal PC : std_logic_vector(7 downto 0);
signal EN, EN0, EN1, EN2, EN3, EN4, EN5 : std_logic;  -- Enable
signal UD, SET : std_logic;  -- Up/Down, Set
signal Cin : std_logic_vector(3 downto 0);  -- Counter In
signal Cout0, Cout1, Cout2, Cout3, Cout4, Cout5, Count : std_logic_vector(3 downto 0);  -- regD In
signal Count0, Count1, Count2, Count3, Count4, Count5 : std_logic_vector(3 downto 0);  -- Counter Out
signal CB0, CB1, CB2, CB3, CB4, CB5 : std_logic;  -- Carry/Borrow
signal key1out, Ststout, clkin : std_logic;
signal Breakaddr : std_logic_vector(5 downto 0);
signal RegD, RegDout : std_logic_vector(15 downto 0);
signal RegNin : std_logic_vector(2 downto 0);

begin

-- START/STOP:KEY1
Chattering1: Chattering port map(MAX10_CLK1_50, reset, key(1), key1out);
KEY1SW: TogleFF port map(reset, key1out, Ststout);


-- Reset Delay
RD0: Reset_Delay port map (MAX10_CLK1_50, DLY_RST); 

-- Reset
	reset <= KEY(0) and DLY_RST;

-- Clock Generater at 1s(25000000)
CG0: ClkGen generic map (25000000) port map (MAX10_CLK1_50, reset, clk1);
   process(clk1, Breakaddr)
	
	begin
		if(SW(6) = '1') then
			if(PC(5 downto 0) = Breakaddr and Breakaddr /= "000000") then
				clk <= '1';
			else
				clk <= clk1;
			end if;
		else
			clk <= clk1;
		end if;
	end process;

	
-- signal of mipsnp
	RegNin <= SW(9 downto 7);
	EN <= Ststout;
	Breakaddr <= SW(5 downto 0);
	
-- MIPS Non Pipeline	(Assignments>Settings>Files Add Components)
MIPSnp0: MIPSnp port map (clk, reset, EN, RegNin, PC, regD);

	LEDR(5 downto 0) <= PC(7 downto 2);
	LEDR(8) <= EN;	
	
-- Signal of Up/Down Counter	--EN0 <= Ststout;  -- Enable=1(Up/Down)
--	EN1 <= CB0;  -- 9
--	EN2 <= CB1 and EN1;  -- 99
--	EN3 <= CB2 and EN2;  -- 999
--	EN4 <= CB3 and EN3;  -- 9999
--	EN5 <= CB4 and EN4;  -- 99999
--	UD <= SW(9);  -- Up/Down=0/1
	SET <= '0' ;  -- Set Initial Value=1
	Cin <= "0000";  -- Countet In
	LEDR(9) <= CB0;  -- LED Display Carry/Borrow
	UD <= '0';

-- Up/Down Counter 0 to 999999
LEDR(7) <= Count(0);
UDC1: UpDownCounter port map (clk, reset, EN, UD, SET, Cin, Count1, CB1);
EN2 <= CB1 and EN;
UDC2: UpDownCounter port map (clk, reset, EN2, UD, SET, Cin, Count2, CB2);
EN3 <= CB2 and EN2;
UDC3: UpDownCounter port map (clk, reset, EN3, UD, SET, Cin, Count3, CB3);
EN4 <= CB3 and EN3;
UDC4: UpDownCounter port map (clk, reset, EN4, UD, SET, Cin, Count4, CB4);
-- UDC5: UpDownCounter port map (clk, reset, EN5, UD, SET, Cin, Cout5, CB5);
ReO : process(RegNin, Count, RegD)
	 begin
		case (RegNin) is
			when "000" => RegDout <= Count4 & Count3 & Count2 & Count1;
			when others => RegDout <= regD;
		end case;
	end process;




Cout0 <= regDout(3 downto 0);
Cout1 <= regDout(7 downto 4);
Cout2 <= regDout(11 downto 8);
Cout3 <= regDout(15 downto 12);
Cout4 <= PC(3 downto 0);
Cout5 <= PC(7 downto 4); 
-- HEX Segment Display
HSD0: SegmentDecoder port map (Cout0, HEX0);
HSD1: SegmentDecoder port map (Cout1, HEX1);
HSD2: SegmentDecoder port map (Cout2, HEX2);
HSD3: SegmentDecoder port map (Cout3, HEX3);
HSD4: SegmentDecoder port map (Cout4, HEX4);
HSD5: SegmentDecoder port map (Cout5, HEX5);

end RTL;

-- Component

--FF
--library IEEE;
--use IEEE.std_logic_1164.all;
--use IEEE.std_logic_unsigned.all;
--
--entity FF is
--  port (
--    D   : in  std_logic;
--    CLK : in  std_logic;
--    Q   : out std_logic );
--end FF;
--
--architecture FF is
--signal buff : std_logic;
--begin
--  process(CLK)
--  begin
--    if CLK'event and CLK = '1' then
--      buff <= D;
--    end if;
--  end process;
--  Q <= not buff;
--end FF;



-- Clock Generater
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity ClkGen is
   generic (N : integer := 25000000);  -- 1s
   port (
	   CLK, RESET : in std_logic;
		CLKout : out std_logic
	);
end ClkGen;

architecture RTL of ClkGen is
signal c : std_logic;
begin
	process(CLK, RESET)
	variable i : integer;
	begin
		if (RESET = '0') then
			i := 0;
			c <= '0';
		elsif (CLK'event and CLK = '1') then
			if (i < N) then
				i := i + 1;
			else
				i := 0;
				c <= not c;
			end if;
		end if;
	end process;
	CLKout <= c;
end RTL;

-- UpDownCounter

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity UpDownCounter is
   port (
      CLK, RESET : in std_logic;
      EN, UD, SET	: in std_logic;
      Cin : in std_logic_vector(3 downto 0);
      Cout : out std_logic_vector(3 downto 0);
      CB : out std_logic
   );
end UpDownCounter;

architecture RTL of UpDownCounter is
signal c : std_logic_vector(3 downto 0);
begin
--Up/Down Counter with Carry/Borrow and Enable
	process(CLK, RESET)
	begin
		if (RESET = '0') then
			c <= "0000";
		elsif (CLK'event and CLK = '1') then
			if (SET = '1') then
				c <= Cin;
			elsif (EN = '1') then
				if (UD = '0') then  -- Up
					if (c = "1001") then
						c <= "0000";
					else
						c <= c + 1;
					end if;
				else  -- Down
					if (c = "0000") then
						c <= "1001";
					else
						c <= c - 1;
					end if;
				end if;
			end if;
		end if;
	end process;
	Cout <= c;
	-- Carry/Borrow
	CB <= '1' when (UD = '0') and (c = "1001") else  -- Up Carry
        '1' when (UD = '1') and (c = "0000") else  -- Down Borrow
         '0';
end RTL;

-- Segment Decoder

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
 
entity SegmentDecoder is
	port (
		Din : in std_logic_vector(3 downto 0);
		Dout : out std_logic_vector(7 downto 0)
    );
end SegmentDecoder;
 
architecture RTL of SegmentDecoder is
begin	
	process(Din)
	begin
		case Din is
			when "0000" => Dout <= "11000000";  -- 0
			when "0001" => Dout <= "11111001";  -- 1
			when "0010" => Dout <= "10100100";  -- 2
			when "0011" => Dout <= "10110000";  -- 3
			when "0100" => Dout <= "10011001";  -- 4
			when "0101" => Dout <= "10010010";  -- 5
			when "0110" => Dout <= "10000010";  -- 6
			when "0111" => Dout <= "11111000";  -- 7
			when "1000" => Dout <= "10000000";  -- 8
			when "1001" => Dout <= "10010000";  -- 9
			when "1010" => Dout <= "00001000";  -- A.
			when "1011" => Dout <= "00000011";  -- b.
			when "1100" => Dout <= "01000110";  -- C.
			when "1101" => Dout <= "00100001";  -- d.
			when "1110" => Dout <= "00000110";  -- E.
			when "1111" => Dout <= "00001110";  -- F.
			when others => Dout <= "11111111";  -- No Disp
		end case;
	end process;
end RTL;
