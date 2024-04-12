library verilog;
use verilog.vl_types.all;
entity data_array is
    generic(
        \INDEX\         : integer := 12;
        DWIDTH          : integer := 128;
        CACHE_DEPTH     : integer := 4096;
        \BYTE_OFFSET\   : integer := 4
    );
    port(
        clk             : in     vl_logic;
        wren            : in     vl_logic;
        rden            : in     vl_logic;
        index           : in     vl_logic_vector;
        byte_offset     : in     vl_logic_vector(3 downto 0);
        storesrc        : in     vl_logic_vector(1 downto 0);
        mem_in          : in     vl_logic;
        data_in         : in     vl_logic_vector;
        data_out        : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of \INDEX\ : constant is 1;
    attribute mti_svvh_generic_type of DWIDTH : constant is 1;
    attribute mti_svvh_generic_type of CACHE_DEPTH : constant is 1;
    attribute mti_svvh_generic_type of \BYTE_OFFSET\ : constant is 1;
end data_array;
