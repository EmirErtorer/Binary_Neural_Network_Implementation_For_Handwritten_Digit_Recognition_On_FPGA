@echo off
REM ****************************************************************************
REM Vivado (TM) v2024.1 (64-bit)
REM
REM Filename    : simulate.bat
REM Simulator   : AMD Vivado Simulator
REM Description : Script for simulating the design by launching the simulator
REM
REM Generated by Vivado on Wed May 28 22:25:57 +0300 2025
REM SW Build 5076996 on Wed May 22 18:37:14 MDT 2024
REM
REM Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
REM Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
REM
REM usage: simulate.bat
REM
REM ****************************************************************************
REM simulate design
echo "xsim bnn_top_tb_time_impl -key {Post-Implementation:sim_1:Timing:bnn_top_tb} -tclbatch bnn_top_tb.tcl -view C:/Mac/Home/Documents/Projects/FPGA-BNN-Project/bnn_inference_on_fpga/bnn_top_tb_behav.wcfg -log simulate.log"
call xsim  bnn_top_tb_time_impl -key {Post-Implementation:sim_1:Timing:bnn_top_tb} -tclbatch bnn_top_tb.tcl -view C:/Mac/Home/Documents/Projects/FPGA-BNN-Project/bnn_inference_on_fpga/bnn_top_tb_behav.wcfg -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
