library verilog;
use verilog.vl_types.all;
entity riscv_dstage is
    generic(
        width           : integer := 64
    );
    port(
        i_riscv_dstage_clk_n: in     vl_logic;
        i_riscv_dstage_rst: in     vl_logic;
        i_riscv_dstage_regw: in     vl_logic;
        i_riscv_dstage_immsrc: in     vl_logic_vector(2 downto 0);
        i_riscv_dstage_inst: in     vl_logic_vector(31 downto 0);
        i_riscv_dstage_rdaddr: in     vl_logic_vector(4 downto 0);
        i_riscv_dstage_rddata: in     vl_logic_vector;
        o_riscv_dstage_rs1data: out    vl_logic_vector;
        o_riscv_dstage_rs2data: out    vl_logic_vector;
        o_riscv_dstage_rs1addr: out    vl_logic_vector(4 downto 0);
        o_riscv_dstage_rs2addr: out    vl_logic_vector(4 downto 0);
        o_riscv_dstage_rdaddr: out    vl_logic_vector(4 downto 0);
        o_riscv_dstage_simm: out    vl_logic_vector;
        o_riscv_dstage_opcode: out    vl_logic_vector(6 downto 0);
        o_riscv_dstage_funct3: out    vl_logic_vector(2 downto 0);
        o_riscv_dstage_func7_0: out    vl_logic;
        o_riscv_dstage_func7_5: out    vl_logic;
        o_riscv_dstage_immzeroextend: out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of width : constant is 1;
end riscv_dstage;
