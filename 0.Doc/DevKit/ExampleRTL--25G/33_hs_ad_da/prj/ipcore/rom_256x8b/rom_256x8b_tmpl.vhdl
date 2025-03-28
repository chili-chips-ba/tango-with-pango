-- Created by IP Generator (Version 2022.2-SP4.2 build 132111)
-- Instantiation Template
--
-- Insert the following codes into your VHDL file.
--   * Change the_instance_name to your own instance name.
--   * Change the net names in the port map.


COMPONENT rom_256x8b
  PORT (
    addr : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;
    rd_data : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END COMPONENT;


the_instance_name : rom_256x8b
  PORT MAP (
    addr => addr,
    clk => clk,
    rst => rst,
    rd_data => rd_data
  );
