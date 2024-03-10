# How to test the connections:
1. Copy [Core Verification folder](https://github.com/AhmedAmrAbdellatif1/GP-RV64IMAC/tree/main/RV64IMC/DV%20verification/Core%20Verification) into your pc.
2. Update the design files in this folder to test it (If you've added a new design file that wasn't included follow these steps[^longnote])
3. Open QuestaSim (it gives an error in ModelSim --> You've do to create your own project, add design files then follow the steps)
4. Click on: File --> Open --> Filter the `Project Files (*.mpf)` and select `golden-reference-test.mpf`
<p align="left">
  <img src="https://github.com/AhmedAmrAbdellatif1/GP-RV64IMAC/assets/140100601/5e292c00-e1e1-421b-9d3f-769bd8053047" width=600 alt="Block Interface">
</p>
5. Open `Core Verification` folder in VSCode

![image](https://github.com/AhmedAmrAbdellatif1/GP-RV64IMAC/assets/140100601/28b01140-2f64-4a19-a862-8c51e4b6b07e)

6. Write in Questa's terminal the following command:
```
do sim.do
```
7. Wait for the test to finish
8. In VSCode open [mod_questa_log.py](https://github.com/AhmedAmrAbdellatif1/GP-RV64IMAC/blob/main/RV64IMC/DV%20verification/Core%20Verification/mod_questa_log.py) and press F5 to run
9. Open [compare-logs.py](https://github.com/AhmedAmrAbdellatif1/GP-RV64IMAC/blob/main/RV64IMC/DV%20verification/Core%20Verification/compare-logs.py) and press F5 to run
10. Check VSCode's terminal

![image](https://github.com/AhmedAmrAbdellatif1/GP-RV64IMAC/assets/140100601/c84f28f2-c3f2-4486-b911-36deed0d2142)

# Prerequists
1. QuestaSim/ModelSim
2. VSCode
3. Python extension for Visual Studio Code

[^longnote]: Run [import.tcl](https://github.com/AhmedAmrAbdellatif1/GP-RV64IMAC/blob/main/RV64IMC/DV%20verification/Core%20Verification/import.tcl) and copy the design file names from the VSCode's terminal then modify [sim.do](https://github.com/AhmedAmrAbdellatif1/GP-RV64IMAC/blob/main/RV64IMC/DV%20verification/Core%20Verification/sim.do) line 3 with the new design files
