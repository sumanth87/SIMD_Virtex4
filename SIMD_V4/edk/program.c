/*
// Simple program to load SIMD with values and compute.
// Author      : Sumanth Kumar Bandi
// Copyright   : Copyright 2014, Sumanth kumar Bandi, All rights reserved.
*/
 /*
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

#include <stdio.h>
#include "platform.h"
#include "xparameters.h"
#include <xil_io.h>
#include "xuartlite.h"
#include "xuartlite_l.h"

void print(char *str);
void reg_print(void);
u32 input_hex(void);

int main()
{
    init_platform();
    int i;
    u32 temp;
    u32 input,output;
    u32 check = 0x00000000;
    u8 buffer=0x00;
    u32 *start_n_regread = XPAR_SIMD2_0_BASEADDR;
    u32 *reg1 = XPAR_SIMD2_0_BASEADDR + (1*4);
    u32 *reg2 = XPAR_SIMD2_0_BASEADDR + (2*4);
    u32 *reg3 = XPAR_SIMD2_0_BASEADDR + (3*4);
    u32 *reg4 = XPAR_SIMD2_0_BASEADDR + (4*4);

    u32 *wr_addr = XPAR_SIMD2_0_BASEADDR + (5*4);
    u32 *wr_data = XPAR_SIMD2_0_BASEADDR + (6*4);
    u32 *rd_addr = XPAR_SIMD2_0_BASEADDR + (7*4);
    u32 *rd_data = XPAR_SIMD2_0_BASEADDR + (8*4);
    u32 *finish = XPAR_SIMD2_0_BASEADDR + (9*4);

    xil_printf("\nstart: %X\n",start_n_regread);
    printf("\n");
    xil_printf("\nreg1: %X\n",reg1);
    printf("\n");
    xil_printf("\nreg2: %X\n",reg2);
    printf("\n\n");


    /*
     * ----------------------------------------------------------------------------------
     *
     *						lOADING VALUES OF M,B, X[5 VALUES]
     *
     *Note: In this design writing the address will trigger the memory write operation
     *		 so give the data prior to giving the address.
     * ----------------------------------------------------------------------------------
     */
           xil_printf("-------*** Program to compute Y = m X + b ");
           printf("\n");
           xil_printf("--- Enter the value of m:");
           input=input_hex();
           Xil_Out32(wr_data,input);
           //scanf("%x",*wr_data);
           printf("\n");
           Xil_Out32(wr_addr,0x00000000);
           //*wr_addr = 0x00000000;

           xil_printf("--- Enter the value of b:");
              input=input_hex();
              Xil_Out32(wr_data,input);
              //scanf("%x",*wr_data);
              printf("\n");
              Xil_Out32(wr_addr,0x01010101);
              //*wr_addr = 0x01010101;

           temp = 0x02020202;
           for (i=0;i<5;i++)
           {
           	xil_printf("**--- Enter the value of x[%d]: ",i);
           	input=input_hex();
           	Xil_Out32(wr_data,input);
           	//scanf("%x",*wr_data);
           	Xil_Out32(wr_addr,temp);
           	//*wr_addr = temp;
           	temp += 0x01010101;
           	printf("\n");
           }

           /*
            * ----------------------------------------------------------------------------------
            *
            *						pRINTING iNITIAL REGISTER VALUES & Memory Values
            *
            * ----------------------------------------------------------------------------------
            */

           Xil_Out32(start_n_regread,0x30000000);
           //*start_n_regread = 0x30000000;
           xil_printf("Initial reg status----");
           printf("\n");
           reg_print();

           temp = 0x00000000;
                      for (i=0;i<5;i++)
                      {
                    	Xil_Out32(rd_addr,temp);
                      	xil_printf("Value at memory %x :",temp);
                      	output=Xil_In32(rd_data);
                      	xil_printf("%X :",output);
                      	//*wr_addr = temp;
                      	temp += 0x01010101;
                      	printf("\n");
                      }




           /*
            * ----------------------------------------------------------------------------------
            *
            *			sTARTING THE PROCESSOR AND WAIT UNTIL PROGRAM COMPLETES
            *
            * ----------------------------------------------------------------------------------
            */

           Xil_Out32(start_n_regread,0xF000000F);
           //*start_n_regread = 0x80000000;
           for(i=0;i<4;i++)
           {
        	   output=Xil_In32(start_n_regread);
        	   xil_printf("***--- start: %X",output);
        	   printf("\n");
           	output=Xil_In32(finish);
           	xil_printf("***--- finish: %X",output);
           	printf("\n");
           }

           xil_printf("Press any key to check register status");
           printf("\n");

           while(check==0x00000000)
           {
        	  //buffer=0x00;
        	  //buffer=XUartLite_RecvByte(XPAR_RS232_UART_1_BASEADDR);
        	  if(XUartLite_IsReceiveEmpty(XPAR_RS232_UART_1_BASEADDR) != TRUE)
        	  {
        		  xil_printf("----Register Contents:");
        		  printf("\n");
        		reg_print();
        	  }
        	  xil_printf("*");
        	  check=Xil_In32(finish);
           }
           printf("\n");
           xil_printf("--------------Computation Finished-------------------");
           printf("\n\n");
           /*
            * ----------------------------------------------------------------------------------
            *
            *			sTOPPING THE PROCESSOR & PRINTING FINAL REGISTER VALUES & OUTPUT
            *
            * ----------------------------------------------------------------------------------
            */

           Xil_Out32(start_n_regread,0x00000000);
           //*start_n_regread = 0x00000000;
           xil_printf("Final reg status----");
           printf("\n");
           reg_print();

           //--Printing Output values
           temp = 0x08080808;
               for (i=0;i<5;i++)
               {
               	Xil_Out32(rd_addr,temp);
               	printf("\r");
               	output=Xil_In32(rd_data);
               	xil_printf("***--- Output Y[%d]: %X",i,output);
               	printf("\n");
               	temp += 0x01010101;
               }



           print("Hello World\n\r");

           return 0;
    }

/*
 * -----------------------------------------------------------------------------------
 * 					Function Print REGISTER VALUES
 * -----------------------------------------------------------------------------------
 */
void reg_print(void)
{
	u32 output = 0x00000000;
    int *reg1 = XPAR_SIMD2_0_BASEADDR + (1*4);
    int *reg2 = XPAR_SIMD2_0_BASEADDR + (2*4);
    int *reg3 = XPAR_SIMD2_0_BASEADDR + (3*4);
    int *reg4 = XPAR_SIMD2_0_BASEADDR + (4*4);

    				output=Xil_In32(reg1);
					xil_printf("reg1= %x",output);
	               printf("\n");
	               output=Xil_In32(reg2);
	               xil_printf("reg2= %x",output);
	               printf("\n");
	               output=Xil_In32(reg3);
	               xil_printf("reg3= %x",output);
	               printf("\n");
	               output=Xil_In32(reg4);
	               xil_printf("reg4= %x",output);
	               printf("\n");
	     return;
}

/*-----------------------------------------------------------------------------
 *
 * 			Function to accept i/p from STDIN and convert to HEXADECIMAL
 *
 * ----------------------------------------------------------------------------
 */
    u32 input_hex(void)
    {
        u32 hex;
        u8 temp;
        int i;

       start:
        hex=0x0;
        for(i=0;i<8;i++)
            {
            	temp = XUartLite_RecvByte(XPAR_RS232_UART_1_BASEADDR);
            	xil_printf("%c",temp);
            	if(temp==0x15)
            	    {goto stop;}
            	else if(temp>=0x30 && temp<=0x39)	//for integers 0-9
            		{temp-=0x30;}
            	else if(temp>=0x41 && temp<=0x46)	//for A-F
            	      {temp-=0x37;}
            	else if(temp>=0x61 && temp<=0x66)	//for a-f
            	        {temp-=0x57;}
            	else
            		{xil_printf("Wrong entry, Re-enter the value:");print("\n");goto start;}
            	hex*=0x10;
            	hex+=temp;
            }
        stop:
        	return hex;
    }

