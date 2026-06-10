simSetSimulator "-vcssv" -exec "./simv" -args
debImport "-dbdir" "./simv.daidir"
debLoadSimResult /home/pedu17/temp/workspace/260604_adder/wave.fsdb
wvCreateWindow
verdiSetActWin -win $_nWave2
verdiWindowResize -win $_Verdi_1 "830" "370" "900" "700"
verdiWindowResize -win $_Verdi_1 "830" "370" "900" "700"
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
verdiSetActWin -win $_nWave2
wvAddAllSignals -win $_nWave2
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvZoomAll -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G1" 1 )} 
wvSelectSignal -win $_nWave2 {( "G1" 1 )} 
wvSetRadix -win $_nWave2 -format Hex
wvSelectSignal -win $_nWave2 {( "G1" 1 )} 
wvSetRadix -win $_nWave2 -format UDec
wvSelectSignal -win $_nWave2 {( "G1" 2 )} 
wvSelectSignal -win $_nWave2 {( "G1" 2 )} 
wvSetRadix -win $_nWave2 -format UDec
wvSelectSignal -win $_nWave2 {( "G1" 3 )} 
wvSelectSignal -win $_nWave2 {( "G1" 3 )} 
wvSetRadix -win $_nWave2 -format UDec
wvSelectSignal -win $_nWave2 {( "G1" 4 )} 
wvSelectSignal -win $_nWave2 {( "G1" 4 )} 
wvSetRadix -win $_nWave2 -format UDec
wvSelectSignal -win $_nWave2 {( "G1" 5 )} 
wvSelectSignal -win $_nWave2 {( "G1" 5 )} 
wvSetRadix -win $_nWave2 -format UDec
wvSelectSignal -win $_nWave2 {( "G1" 6 )} 
wvSelectSignal -win $_nWave2 {( "G1" 6 )} 
wvSetRadix -win $_nWave2 -format UDec
wvSetCursor -win $_nWave2 70532.365145 -snap {("G2" 0)}
wvZoomOut -win $_nWave2
wvZoomAll -win $_nWave2
wvZoomAll -win $_nWave2
srcHBSelect "tb_adder.dut" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
wvSelectSignal -win $_nWave2 {( "G1" 3 )} 
verdiSetActWin -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G1" 2 )} 
wvSelectSignal -win $_nWave2 {( "G1" 1 )} 
verdiDockWidgetSetCurTab -dock windowDock_OneSearch
verdiSetActWin -win $_OneSearch
verdiDockWidgetSetCurTab -dock windowDock_nWave_2
verdiSetActWin -win $_nWave2
srcHBDrag -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("dut" 0)}
wvRenameGroup -win $_nWave2 {G2} {dut}
wvAddSignal -win $_nWave2 "/tb_adder/dut/a\[7:0\]" "/tb_adder/dut/b\[7:0\]" \
           "/tb_adder/dut/y\[8:0\]"
wvSetPosition -win $_nWave2 {("dut" 0)}
wvSetPosition -win $_nWave2 {("dut" 3)}
wvSetPosition -win $_nWave2 {("dut" 3)}
srcSelect -win $_nTrace1 -range {19 19 1 6 1 1}
srcTBAddBrkPnt -win $_nTrace1 -line 19 -file \
           /home/pedu17/temp/workspace/260604_adder/tb_adder.sv
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcSelect -win $_nTrace1 -range {18 18 1 6 1 1}
srcTBAddBrkPnt -win $_nTrace1 -line 18 -file \
           /home/pedu17/temp/workspace/260604_adder/tb_adder.sv
srcSelect -win $_nTrace1 -range {19 19 1 6 1 1}
srcTBSetBrkPnt -win $_nTrace1 -disable -index 0
srcSelect -win $_nTrace1 -range {19 19 1 6 1 1}
srcTBSetBrkPnt -win $_nTrace1 -delete -index 0
srcSelect -win $_nTrace1 -range {18 18 1 6 1 1}
srcTBSetBrkPnt -win $_nTrace1 -disable -index 1
srcSelect -win $_nTrace1 -range {18 18 1 6 1 1}
srcTBSetBrkPnt -win $_nTrace1 -delete -index 1
srcSelect -win $_nTrace1 -range {18 18 1 6 1 1}
srcTBAddBrkPnt -win $_nTrace1 -line 18 -file \
           /home/pedu17/temp/workspace/260604_adder/tb_adder.sv
verdiDockWidgetMaximize -dock widgetDock_<Inst._Tree>
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHierTreeSort -win $_nTrace1 -hierAscending
srcHierTreeSort -win $_nTrace1 -moduleDescending
srcHierTreeSort -win $_nTrace1 -moduleAscending
verdiDockWidgetHide -dock widgetDock_<Inst._Tree>
verdiSetActWin -win $_nWave2
verdiDockWidgetUndock -dock widgetDock_MTB_SOURCE_TAB_1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
verdiDockWidgetDock -dock widgetDock_MTB_SOURCE_TAB_1
verdiDockWidgetRestore -dock windowDock_nWave_2
verdiSetActWin -win $_nWave2
verdiWindowResize -win $_Verdi_1 "8" "31" "900" "700"
verdiWindowResize -win $_Verdi_1 "1136" "343" "1059" "700"
wvZoomAll -win $_nWave2
srcTBInvokeSim
verdiSetActWin -dock widgetDock_<Member>
verdiDockWidgetSetCurTab -dock windowDock_nWave_2
verdiSetActWin -win $_nWave2
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcTBRunSim
srcTBRunSim
srcTBSimReset
srcTBRunSim
srcTBRunSim
verdiWindowResize -win $_Verdi_1 "1136" "343" "1059" "700"
wvZoomAll -win $_nWave2
verdiSetActWin -win $_nWave2
srcSelect -win $_nTrace1 -range {24 24 1 6 1 1}
srcTBAddBrkPnt -line 24 -file \
           /home/pedu17/temp/workspace/260604_adder/tb_adder.sv
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcSelect -win $_nTrace1 -range {30 30 1 6 1 1}
srcTBAddBrkPnt -line 30 -file \
           /home/pedu17/temp/workspace/260604_adder/tb_adder.sv
srcSelect -win $_nTrace1 -range {36 36 1 6 1 1}
srcTBAddBrkPnt -line 36 -file \
           /home/pedu17/temp/workspace/260604_adder/tb_adder.sv
srcSelect -win $_nTrace1 -range {44 44 1 6 1 1}
srcTBAddBrkPnt -line 44 -file \
           /home/pedu17/temp/workspace/260604_adder/tb_adder.sv
srcTBSimReset
srcTBRunSim
srcTBRunSim
wvZoomAll -win $_nWave2
verdiSetActWin -win $_nWave2
srcTBRunSim
srcTBRunSim
srcTBRunSim
srcTBRunSim
wvZoomAll -win $_nWave2
verdiWindowResize -win $_Verdi_1 "1136" "343" "1059" "700"
