simSetSimulator "-vcssv" -exec "./simv" -args
debImport "-dbdir" "./simv.daidir"
debLoadSimResult /home/pedu17/temp/workspace/260604_sram/wave_ram.fsdb
wvCreateWindow
verdiSetActWin -win $_nWave2
verdiWindowResize -win $_Verdi_1 "830" "370" "900" "700"
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcHBDrag -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
wvSetPosition -win $_nWave2 {("dut" 0)}
wvRenameGroup -win $_nWave2 {G1} {dut}
wvAddSignal -win $_nWave2 "/tb_RAM/dut/clk" "/tb_RAM/dut/we" \
           "/tb_RAM/dut/addr\[7:0\]" "/tb_RAM/dut/wdata\[7:0\]" \
           "/tb_RAM/dut/rdata\[7:0\]"
wvSetPosition -win $_nWave2 {("dut" 0)}
wvSetPosition -win $_nWave2 {("dut" 5)}
wvSetPosition -win $_nWave2 {("dut" 5)}
srcTBInvokeSim
verdiSetActWin -dock widgetDock_<Member>
verdiDockWidgetSetCurTab -dock windowDock_nWave_2
verdiSetActWin -win $_nWave2
srcTBRunSim
wvZoomAll -win $_nWave2
