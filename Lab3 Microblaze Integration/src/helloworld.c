/******************************************************************************
* Copyright (C) 2023 Advanced Micro Devices, Inc. All Rights Reserved.
* SPDX-License-Identifier: MIT
******************************************************************************/
/*
 * Brandon Sweitzer, Bruno Graziano, ECE 383 Lab 3
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include "xparameters.h"
#include "stdio.h"
#include "xstatus.h"

#include "platform.h"
#include "xil_printf.h"						// xil_printf
#include <xuartlite_l.h>					// XUartLite_RecvByte
#include <xil_io.h>							// Xil in/out functions
#include <xil_exception.h>

/************************** Constant Definitions ****************************/
#define LAB3_BASEADDR XPAR_LAB2_IP_0_S00_AXI_BASEADDR
#define EX_WR_ADDR    (LAB3_BASEADDR + 0)
#define EXWEN_REG     (LAB3_BASEADDR + 4)
#define LBUS_OUT_REG  (LAB3_BASEADDR + 8)
#define RBUS_OUT_REG  (LAB3_BASEADDR + 12)
#define EX_LBUS       (LAB3_BASEADDR + 16)
#define EX_RBUS       (LAB3_BASEADDR + 20)
#define FLAGQ_REG     (LAB3_BASEADDR + 24)
#define FLAGCLR_REG   (LAB3_BASEADDR + 28)
#define TRIG_VOLT_REG (LAB3_BASEADDR + 32)
#define TRIG_TIME_REG (LAB3_BASEADDR + 36)
#define CONTROL_REG   (LAB3_BASEADDR + 40)
#define CH_ENABLE_REG (LAB3_BASEADDR + 44)
#define LBUS_IN_REG   (LAB3_BASEADDR + 48)
#define RBUS_IN_REG   (LAB3_BASEADDR + 52)

/************************** Control Bit Definitions ****************************/
#define EXWEN_MASK 0x01
#define EXSEL_MASK 0x02

/************************** Global Variable Definitions ****************************/
u16 array_L[1024];
u16 array_R[1024];
int ARRAY_FULL = 0;
int sample_index = 0;
u16 triggerVolt = 220;
u16 triggerTime = 310;

/************************** Helper Functins ****************************/
void write_bram(u16 addr, u16 left, u16 right){
  Xil_Out16(EX_WR_ADDR, addr);
  Xil_Out16(EX_LBUS, left);
  Xil_Out16(EX_RBUS, right);
  Xil_Out32(CONTROL_REG, EXWEN_MASK | EXSEL_MASK);
  Xil_Out32(CONTROL_REG, EXSEL_MASK);
}

void clear_flag(){
  Xil_Out32(FLAGCLR_REG, 1);
  Xil_Out32(FLAGCLR_REG, 0);
}

u16 get_flag(){
  return (Xil_In32(FLAGQ_REG) & 0x1);
}

/************************** Trigger Search Function ****************************/
int find_trigger(u16 trigVolt){
  int i;
  u16 prev;
  u16 curr;
  for(i = 1; i < 1024; i++){
    prev = (array_L[i-1] >> 6);
    curr = (array_L[i] >> 6);

    if((prev < trigVolt) && (curr >= trigVolt)){
      return i;
    }
  }
  return 0;
}

/************************** UART Command Cases ****************************/
void process_uart(char c){
	int i;
	int trigLoc;
	switch(c){

	/* CASE 'd' Draw test patterns directly into BRAM */
	case 'd':

	  printf("Drawing test patterns...\r\n");
	  for(i = 0; i < 1024; i++){
		write_bram(i, (185 << 6), (i << 6));
	  }
	break;

	/******** CASE 'm' Poll samples from codec into arrays ********/

	case 'm':

	  printf("Polling samples...\r\n");
	  microblaze_disable_interrupts();
	  for(i = 0; i < 1024; i++){
		  while(get_flag() == 0);
		  array_L[i] = Xil_In16(LBUS_IN_REG);
		  array_R[i] = Xil_In16(RBUS_IN_REG);
		  clear_flag();
	  }
	  microblaze_enable_interrupts();
	  printf("Done sampling.\r\n");
	break;

	/**********CASE 'p' * Print waveform samples *****************/

	case 'p':

	  for(i = 0; i < 1024; i++){
		printf("%d : %u\r\n", i, array_L[i]);
	  }
	break;

	/*************CASE 'w' Write arrays to BRAM *******************/

	case 'w':

	  printf("Writing waveform to BRAM...\r\n");
	  for(i = 0; i < 1024; i++){
		write_bram(i,array_L[i],array_R[i]);
	  }
	break;

	/******* CASE 't' Find trigger location **********************/

	case 't':

		trigLoc = find_trigger(triggerVolt);
	  	printf("Trigger found here: %d\r\n", trigLoc);
	break;

	/********CASE 'z' Write triggered waveform *******************/

	case 'z':
	  trigLoc = find_trigger(triggerVolt);
	  printf("Displaying triggered waveform.\r\n");
	  for(i = 0; i < 620; i++){
		  int src;
		  src = trigLoc - triggerTime + i;
		  if(src < 0)
			  src += 1024;
		  if(src >= 1024)
			  src -= 1024;
		  write_bram(i, array_L[src], array_R[src]);
	  }
	break;

	/****** CASE 'g' Continuous polling mode *******************/

	case 'g':

	  printf("Continuous polling mode.\r\n");

	  while(1){
		for(i = 0; i < 1024; i++){
		  while(get_flag() == 0);
		  array_L[i] = Xil_In16(LBUS_IN_REG);
		  array_R[i] = Xil_In16(RBUS_IN_REG);
		  clear_flag();
		}

		trigLoc = find_trigger(triggerVolt);
		for(i = 0; i < 620; i++){
		  int src;
		  src = trigLoc - triggerTime + i;
		  if(src < 0)
			  src += 1024;
		  if(src >= 1024)
			  src -= 1024;
		  write_bram(i, array_L[src], array_R[src]);
		}

		if(!XUartLite_IsReceiveEmpty(STDIN_BASEADDRESS)){
		  break;
		}
	  }
	break;

	/******** CASE 'i' Enable interrupt acquisition *********/

	case 'i':

	   printf("Interrupt mode enabled.\r\n");
	  ARRAY_FULL = 0;
	  sample_index = 0;
	  microblaze_enable_interrupts();
	break;

	/****** CASE 'c' Continuous interrupt display mode ********/

	case 'c':

	  printf("Continuous interrupt display.\r\n");
	  while(1)

	  {
		if(ARRAY_FULL){
		  trigLoc = find_trigger(triggerVolt);
		  for(i = 0; i < 620; i++){

			int src;
			src = trigLoc - triggerTime + i;
			if(src < 0)
			  src += 1024;
			if(src >= 1024)
			  src -= 1024;
			write_bram(i, array_L[src], array_R[src]);
		  }
		  ARRAY_FULL = 0;
		}

		if(!XUartLite_IsReceiveEmpty(STDIN_BASEADDRESS)){
		  break;
		}
	  }
	break;

	// trigger controls are on hardware.
}

/************************** Interrupt Service Routine ****************************/

void sample_ISR(){
  clear_flag();
  if(ARRAY_FULL == 0)
  {
    array_L[sample_index] = Xil_In16(LBUS_IN_REG);
    array_R[sample_index] = Xil_In16(RBUS_IN_REG);
    sample_index++;

    if(sample_index >= 1024){
      sample_index = 0;
      ARRAY_FULL = 1;
    }
  }
}
