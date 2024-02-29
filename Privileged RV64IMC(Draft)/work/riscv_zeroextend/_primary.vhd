library verilog;
use verilog.vl_types.all;
entity riscv_zeroextend is
    generic(
        width           : integer := 64
    );
    port(
        i_riscv_zeroextend_imm: in     vl_logic_vector(4 downto 0);
        o_riscv_zeroextend_immextend: out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of width : constant is 1;
end riscv_zeroextend;
