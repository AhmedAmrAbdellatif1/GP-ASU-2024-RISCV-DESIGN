library verilog;
use verilog.vl_types.all;
entity riscv_compressed_decoder is
    port(
        i_riscv_cdecoder_inst: in     vl_logic_vector(31 downto 0);
        o_riscv_cdecoder_inst: out    vl_logic_vector(31 downto 0);
        o_riscv_cdecoder_compressed: out    vl_logic;
        o_riscv_cdecoder_cillegal_inst: out    vl_logic
    );
end riscv_compressed_decoder;
