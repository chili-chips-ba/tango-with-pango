`timescale  1ns/1ns   // �������ʱ�䵥λ1ns�ͷ���ʱ�侫��Ϊ1ns

module  tb_mipi_dsi_colorbar();            

//����
reg  sys_clk;                      // ʱ���ź�
reg  sys_rst_n;                    // ��λ�ź�


//*****************************************************
//**                    main code
//*****************************************************

//�������źų�ʼֵ
initial begin
    sys_clk            = 1'b0;
    sys_rst_n          = 1'b0;     // ��λ
    #20  sys_rst_n  = 1'b1;     // �ڵ�21ns��ʱ��λ�ź��ź�����
end

//50Mhz��ʱ�ӣ�������Ϊ1/50Mhz=20ns,����ÿ10ns����ƽȡ��һ��
always #10 sys_clk = ~sys_clk;

reg  grs_n;
    GTP_GRS GRS_INST(
    .GRS_N (grs_n)
    );
    
    initial begin
        grs_n = 1'b0;
        #5000 grs_n = 1'b1;
    end

//����ģ��
mipi_dsi_colorbar  u_mipi_dsi_colorbar(
    .sys_clk            (sys_clk  ),
    .sys_rst_n          (sys_rst_n),

    .mipi_dsi_rst_n     (),
    .mipi_dsi_bl        (),
    .mipi_dsi_data_p    (),
    .mipi_dsi_data_n    (),
    .mipi_dsi_clk_p     (),
    .mipi_dsi_clk_n     ()
);

endmodule
