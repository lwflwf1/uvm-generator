///////////////////////////////////////////////
// file name  : my_top.v
// creat time : 2020-04-11
// author     : Gong Yingfan
// version    : v1.0
// descript   : my_top.sv
// log        : no
///////////////////////////////////////////////

// `include "uvm_macros.svh"
// import uvm_pkg::*;

//  Module: my_top
//
module my_top(); 
    // timeunit 1ns;
    // timeprecision 1ps;

    // parameters

    // variables


    // interface
    my_interface m_if();

    // Clock model instantiation
    my_clock_model clk_mdl (
        .clk(m_if.clk),
        .rst_n(m_if.rst_n)
    );

    // DUT instantiation and interface connection  

    // start simulation
    initial begin
        $timeformat(-9, 1, "ns", 5);
        run_test();
    end



    // dump fsdb
    `ifdef DUMP
    initial begin//do_not_remove 
        $fsdbAutoSwitchDumpfile(1000, "./fsdb/test_fsdb.fsdb", 10);//do_not_remove 
        $fsdbDumpvars(0, my_top);//do_not_remove 
        // $fsdbDumpMDA(1000, my_top);//do_not_remove 
        // $fsdbDumpflush();//do_not_remove 
        //$fsdbDumpvars("+all");//do_not_remove 
    end//do_not_remove 
    `endif

    // initial begin
    //     forever begin
    //         repeat(1000) @(posedge m_if.clk);
    //         $fsdbDumpflush()
    //     end
    // end






endmodule: my_top
