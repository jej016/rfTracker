// Libraries
#include "xparameters.h"
#include "xgpio.h"
#include "xscugic.h"
#include "xil_exception.h"
#include "xil_printf.h"

// Paramater Definitions
#define INTC_DEVICE_ID 		XPAR_PS7_SCUGIC_0_DEVICE_ID
#define SWITCH_DEVICE_ID	XPAR_AXI_GPIO_0_DEVICE_ID
#define SPEED_DEVICE_ID		XPAR_AXI_GPIO_1_DEVICE_ID
#define STEERING_DEVICE_ID	XPAR_AXI_GPIO_2_DEVICE_ID
#define MUX_DEVICE_ID		XPAR_AXI_GPIO_3_DEVICE_ID
#define STEERINGDUTY_DEVICE_ID	XPAR_AXI_GPIO_4_DEVICE_ID
#define SPEEDDUTY_DEVICE_ID		XPAR_AXI_GPIO_5_DEVICE_ID

#define INTC_GPIO_INTERRUPT_ID XPAR_FABRIC_AXI_GPIO_1_IP2INTC_IRPT_INTR
#define SWITCH_INT			XGPIO_IR_CH1_MASK

XGpio SwitchInst, SpeedInst, SteeringInst, SpeeddutyInst, SteeringdutyInst, MuxInst;
XScuGic INTCInst;

//----------------------------------------------------
// PROTOTYPE FUNCTIONS
//----------------------------------------------------
static void Switch_INTr_Handler(void *baseaddr_p);
static int InterruptSystemSetup(XScuGic *XScuGicInstancePtr);
static int IntcInitFunction(u16 DeviceId, XGpio *GpioInstancePtr);

void Switch_INTr_Handler(void *InstancePtr)
{// Disable GPIO interrupts
	XGpio_InterruptDisable(&SwitchInst, SWITCH_INT);
	// Ignore additional button presses
	if ((XGpio_InterruptGetStatus(&SwitchInst) & SWITCH_INT) != SWITCH_INT) {
			return;
		}

	//DO SOMETHING HERE FOR THE INTERRUPT

    (void)XGpio_InterruptClear(&SwitchInst, SWITCH_INT);
    // Enable GPIO interrupts
    XGpio_InterruptEnable(&SwitchInst, SWITCH_INT);
}

int main(void){
	// Initialize SpeedInst, SteeringInst, SpeeddutyInst, SteeringdutyInst, MuxInst;
	int status;
	  status = XGpio_Initialize(&SpeedInst, SPEED_DEVICE_ID);
	  if(status != XST_SUCCESS) return XST_FAILURE;
	  
	  status = XGpio_Initialize(&SteeringInst, STEERING_DEVICE_ID);
	  if(status != XST_SUCCESS) return XST_FAILURE;
	  
	  status = XGpio_Initialize(&SpeeddutyInst, SPEEDDUTY_DEVICE_ID);
	  if(status != XST_SUCCESS) return XST_FAILURE;
	  
	  status = XGpio_Initialize(&SteeringdutyInst, STEERINGDUTY_DEVICE_ID);
	  if(status != XST_SUCCESS) return XST_FAILURE;
	  
	  status = XGpio_Initialize(&MuxInst, MUX_DEVICE_ID);
	  if(status != XST_SUCCESS) return XST_FAILURE;

	  // Set GPIO data directions
	  XGpio_SetDataDirection(&SpeedInst, 1, 0xFF);
	  
	  XGpio_SetDataDirection(&SteeringInst, 1, 0xFF);
	  
	  XGpio_SetDataDirection(&SpeeddutyInst, 1, 0x00);
	  
	  XGpio_SetDataDirection(&SteeringdutyInst, 1, 0x00);
	  
	  XGpio_SetDataDirection(&MuxInst, 1, 0x00);		
		
	  // Initialize interrupt controller
	  status = IntcInitFunction(INTC_DEVICE_ID, &SwitchInst);
	  if(status != XST_SUCCESS) return XST_FAILURE;

	// Code to control the car to drive from the remote and sample speed/steering duty cycles
	while (1){
		 XGpio_DiscreteWrite(&MuxInst, 1, 0);
	}

	return 0;
}

int InterruptSystemSetup(XScuGic *XScuGicInstancePtr)
{
	// Enable interrupt
	XGpio_InterruptEnable(&SwitchInst, SWITCH_INT);
	XGpio_InterruptGlobalEnable(&SwitchInst);

	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
			 	 	 	 	 	 (Xil_ExceptionHandler)XScuGic_InterruptHandler,
			 	 	 	 	 	 XScuGicInstancePtr);
	Xil_ExceptionEnable();


	return XST_SUCCESS;

}

int IntcInitFunction(u16 DeviceId, XGpio *GpioInstancePtr)
{
	XScuGic_Config *IntcConfig;
	int status;

	// Interrupt controller initialisation
	IntcConfig = XScuGic_LookupConfig(DeviceId);
	status = XScuGic_CfgInitialize(&INTCInst, IntcConfig, IntcConfig->CpuBaseAddress);
	if(status != XST_SUCCESS) return XST_FAILURE;

	// Call to interrupt setup
	status = InterruptSystemSetup(&INTCInst);
	if(status != XST_SUCCESS) return XST_FAILURE;

	// Connect GPIO interrupt to handler
	status = XScuGic_Connect(&INTCInst,
					  	  	 INTC_GPIO_INTERRUPT_ID,
					  	  	 (Xil_ExceptionHandler)RF_INTr_Handler,
					  	  	 (void *)GpioInstancePtr);
	if(status != XST_SUCCESS) return XST_FAILURE;

	// Enable GPIO interrupts interrupt
	XGpio_InterruptEnable(GpioInstancePtr, 1);
	XGpio_InterruptGlobalEnable(GpioInstancePtr);

	// Enable GPIO and timer interrupts in the controller
	XScuGic_Enable(&INTCInst, INTC_GPIO_INTERRUPT_ID);

	return XST_SUCCESS;
}