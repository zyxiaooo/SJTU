
#include "inc/hw_types.h"	
#include "inc/hw_memmap.h"	
#include "inc/hw_sysctl.h"
#include "inc/hw_gpio.h"
#include "inc/hw_timer.h"
#include "inc/hw_ints.h"
#include "inc/hw_uart.h"
#include "inc/hw_pwm.h"
#include "driverlib/sysctl.h"
#include "driverlib/rom.h"
#include "grlib/grlib.h"
#include "drivers/kitronix320x240x16_ssd2119_8bit.h"
#include "drivers/set_pinout.h"
#include "driverlib/rom_map.h"
#include "driverlib/debug.h"
#include "driverlib/gpio.h"
#include "driverlib/pin_map.h"
#include "driverlib/systick.h"
#include "driverlib/timer.h"
#include "driverlib/interrupt.h"
#include "drivers/sound.h"
#include "drivers/touch.h"
#include "grlib/widget.h"
#include "grlib/canvas.h"
#include "grlib/slider.h"
#include "grlib/pushbutton.h"
#include "third_party/fatfs/src/ff.h"
#include "third_party/fatfs/src/diskio.h"
#include "driverlib/uart.h"
#include "grlib/listbox.h"
#include "utils/ustdlib.h"
#include "driverlib/pwm.h"
#include "driverlib/udma.h"
#include<string.h>
#include <stdio.h>
//*****************************DMA part*******************************************************************
//********************************************************************************************************
#ifdef ewarm
#pragma data_alignment=1024
tDMAControlTable sDMAControlTable[64];//定义DMA表
#elif defined(ccs)
#pragma DATA_ALIGN(sDMAControlTable, 1024) //设置对齐
tDMAControlTable sDMAControlTable[64];
#else
tDMAControlTable sDMAControlTable[64] __attribute__ ((aligned(1024)));	//设置对齐
#endif
//********************************************************************************************************

//********************************************************************************************************
//全局变量区
//********************************************************************************************************
#define UART0RX_PIN		GPIO_PIN_0				
#define UART0TX_PIN		GPIO_PIN_1				  
#define UART0_PIN_BASE	GPIO_PORTA_BASE	  //uart
#define START_SOUND_PERIOD	TheSysClock/1000		//蜂鸣器
#define AUDIO_BUFFER_SIZE       3100
#define BUFFER_BOTTOM_EMPTY     0x00000001
#define BUFFER_TOP_EMPTY        0x00000002
#define BUFFER_PLAYING          0x00000004
//***************************************************
unsigned long TheSysClock = 16000000UL;//系统时钟
//************程序逻辑控制**************************
unsigned char flag=true;
unsigned char flagstart=false;
int flaglevel=0;
unsigned char flagok=false;
unsigned char flagchooseok=false;
unsigned char flagreturn=false;
long testflag=0;
unsigned char flagpos[4];
unsigned char flagholded[4];
short selected;
int j=0;
int k=0;
//***************************************************

const char *g_ppcDirListStrings[8];	 //listbox的字符串
//**********************从sd卡读取文件****************
static FIL pFile;
static FATFS g_sFatFs;
static DIR g_sDirObject;
static FILINFO g_sFileInfo;
FRESULT fresult;
unsigned short usCount;
char filename[8][13];
char filenameopen[16]="";
char wavenameopen[16]="";
char filenamedisplay[10][10];
char databuffer[10000];
//*****************************************************
//***************************文件处理后将铺面信息保存**
int timestamp[1000];
int position[1000];
int type[1000];
int totaltime=0;
int notenumber=0;
int notehasgone;
int timepoint;
//****************************************************************
//****************************图形区域**************
tRectangle sRect[1000];
tRectangle tRect1;
tRectangle tRect2;
tContext sContext;
tContext sContext1;
tRectangle tRect;
//***************************************************************
//********分数计算**********************************************
int missnum;
int greatnum;
int perfectnum;
int combo;
int maxcombo;
int totalpoint;
char greats[30];
char perfects[30];
char misss[30];
char maxcombos[30];
char totalpoints[30];
//**************************************************************
//*****************控件声明************************************
extern const tDisplay g_sKitronix320x240x16_SSD2119;
extern tPushButtonWidget pushbuttonstart;
extern tPushButtonWidget pushbuttoneasy;
extern tPushButtonWidget pushbuttonnormal;
extern tPushButtonWidget pushbuttonhard;
extern tPushButtonWidget pushbuttonchoosestart;
extern tPushButtonWidget pushbuttonreturn;
extern tPushButtonWidget pushbutton1;
extern tPushButtonWidget pushbutton2;
extern tPushButtonWidget pushbutton3;
extern tPushButtonWidget pushbutton4;
extern tPushButtonWidget pushbuttonok;
extern tListBoxWidget songlist;
extern tSliderWidget volumebar;

//*****************************************************************************
// 驱动库错误提示
//*****************************************************************************
#ifdef DEBUG
void
__error__(char *pcFilename, unsigned long ulLine)
{
}
#endif

//*******************************************************************************
//初始化函数及中断函数声明区域
//*******************************************************************************
void TimerInitial(void)
{
	SysCtlPeripheralEnable(SYSCTL_PERIPH_TIMER0);		// 初始化timer，4ms时间片
	TimerConfigure(TIMER0_BASE,TIMER_CFG_32_BIT_PER); 	
	TimerLoadSet(TIMER0_BASE,TIMER_A,(TheSysClock/250));	
	TimerIntEnable(TIMER0_BASE,TIMER_TIMA_TIMEOUT);	
	IntEnable(INT_TIMER0A);
}
void Timer0A_ISR(void)
{unsigned long ulStatus;
	ulStatus=TimerIntStatus(TIMER0_BASE,true);
if(ulStatus & TIMER_TIMA_TIMEOUT) 	
	{ 
		flag=false;
	}
	TimerIntClear(TIMER0_BASE,ulStatus);
}

SysTickHandler(void)
{
    disk_timerproc();
}
void UART0Initial(void)
{	
	
	SysCtlPeripheralEnable(SYSCTL_PERIPH_UART0);
	GPIOPinConfigure(GPIO_PA0_U0RX);
	GPIOPinConfigure(GPIO_PA1_U0TX);
	GPIOPinTypeUART(UART0_PIN_BASE, UART0RX_PIN | UART0TX_PIN);
	UARTConfigSet(UART0_BASE,						
    			  115200,       					
    			  UART_CONFIG_WLEN_8 |				 
    			  UART_CONFIG_STOP_ONE |			
    			  UART_CONFIG_PAR_NONE);   			 
	UARTEnable(UART0_BASE);						  
}
void PWMInitial(void)
{	
	SysCtlPeripheralEnable(SYSCTL_PERIPH_PWM);
	GPIOPinConfigure(GPIO_PF3_PWM5);
	GPIOPinTypePWM(GPIO_PORTF_BASE, GPIO_PIN_3);				
	SysCtlPWMClockSet(SYSCTL_PWMDIV_1);			
	PWMGenConfigure(PWM_BASE,
					PWM_GEN_2,
					PWM_GEN_MODE_DOWN |
					PWM_GEN_MODE_NO_SYNC);
	PWMGenPeriodSet(PWM_BASE,PWM_GEN_2,START_SOUND_PERIOD);	
	PWMPulseWidthSet(PWM_BASE,PWM_OUT_5,START_SOUND_PERIOD/2);
	PWMOutputState(PWM_BASE,PWM_OUT_5_BIT,true);
	
	PWMGenEnable(PWM_BASE,PWM_GEN_2);
	SysCtlDelay(TheSysClock/15);
	PWMGenDisable(PWM_BASE,PWM_GEN_2);
}
void BuzzerBeep(void)
{
	PWMGenEnable(PWM_BASE,PWM_GEN_2);
	SysCtlDelay(TheSysClock/15);
	PWMGenDisable(PWM_BASE,PWM_GEN_2);
}
//*****************************************************************************
//按钮控件函数声明区域
//*****************************************************************************
void onpress1(tWidget *pWidget);
void onpress2(tWidget *pWidget);
void onpress3(tWidget *pWidget);
void onpress4(tWidget *pWidget);
void onpressstart(tWidget *pWidget);
void onpresseasy(tWidget *pWidget);
void onpressnormal(tWidget *pWidget);
void onpresshard(tWidget *pWidget);
void onpressok(tWidget *pWidget);
void onpresschooseok(tWidget *pWidget);
void onpressreturn(tWidget *pWidget);
void setvolume(tWidget *pWidget,long lvalue);

//*****************************************************************************
//初始化控件树
//*****************************************************************************
RectangularButton(pushbuttonstart, WIDGET_ROOT,&pushbuttoneasy, 0,						  //开始按钮
                  &g_sKitronix320x240x16_SSD2119, 80, 150, 160, 40,
                  (PB_STYLE_OUTLINE | PB_STYLE_TEXT_OPAQUE | PB_STYLE_TEXT |
                   PB_STYLE_FILL ),
                   ClrBlue, ClrDarkBlue, ClrRed, ClrWhite,
                   g_pFontCmss22b, "Start", 0, 0, 0, 0, onpressstart,0);
RectangularButton(pushbuttoneasy, WIDGET_ROOT,&pushbuttonnormal, 0,					  //难度easy按钮
                  &g_sKitronix320x240x16_SSD2119, 80, 40, 160, 40,
                  (PB_STYLE_OUTLINE | PB_STYLE_TEXT_OPAQUE | PB_STYLE_TEXT |
                   PB_STYLE_FILL ),
                   ClrBlue, ClrYellow, ClrRed, ClrWhite,
                   g_pFontCmss22b, "easy", 0, 0, 0, 0, onpresseasy,0);
RectangularButton(pushbuttonnormal, WIDGET_ROOT,&pushbuttonhard, 0,					 //难度normal按钮
                  &g_sKitronix320x240x16_SSD2119, 80, 100, 160, 40,
                  (PB_STYLE_OUTLINE | PB_STYLE_TEXT_OPAQUE | PB_STYLE_TEXT |
                   PB_STYLE_FILL ),
                   ClrBlue, ClrYellow, ClrRed, ClrWhite,
                   g_pFontCmss22b, "normal", 0, 0, 0, 0, onpressnormal,0);
RectangularButton(pushbuttonhard, WIDGET_ROOT,&pushbuttonchoosestart, 0,				//难度hard按钮
                  &g_sKitronix320x240x16_SSD2119, 80, 160, 160, 40,
                  (PB_STYLE_OUTLINE | PB_STYLE_TEXT_OPAQUE | PB_STYLE_TEXT |
                   PB_STYLE_FILL ),
                   ClrBlue, ClrYellow, ClrRed, ClrWhite,
                   g_pFontCmss22b, "hard", 0, 0, 0, 0, onpresshard,0);						  //go按钮
RectangularButton(pushbuttonchoosestart, WIDGET_ROOT,&pushbuttonreturn, 0,					
                  &g_sKitronix320x240x16_SSD2119, 220, 60, 80, 40,
                  (PB_STYLE_OUTLINE | PB_STYLE_TEXT_OPAQUE | PB_STYLE_TEXT |
                   PB_STYLE_FILL ),
                   ClrBlue, ClrDarkBlue, ClrRed, ClrWhite,									  
                   g_pFontCmss22b, "GO!", 0, 0, 0, 0, onpresschooseok,0);
RectangularButton(pushbuttonreturn, WIDGET_ROOT,&volumebar, 0,						 		   //return按钮
                  &g_sKitronix320x240x16_SSD2119, 220, 130, 80, 40,
                  (PB_STYLE_OUTLINE | PB_STYLE_TEXT_OPAQUE | PB_STYLE_TEXT |
                   PB_STYLE_FILL ),
                   ClrBlue, ClrDarkBlue, ClrRed, ClrWhite,
                   g_pFontCmss22b, "Return", 0, 0, 0, 0, onpressreturn,0);
Slider(volumebar, WIDGET_ROOT, &songlist, 0,											   //
       &g_sKitronix320x240x16_SSD2119, 180, 200, 120, 30, 40, 90,
       60, (SL_STYLE_FILL | SL_STYLE_BACKG_FILL |
       SL_STYLE_OUTLINE), ClrGreen, ClrBlack, ClrWhite,
       ClrWhite, ClrWhite, 0, 0, 0, 0, setvolume);
ListBox(songlist, WIDGET_ROOT, &pushbutton1, 0,
        &g_sKitronix320x240x16_SSD2119,												   //选择歌曲列表框
        0, 30, 125, 180, LISTBOX_STYLE_OUTLINE, ClrBlack, ClrDarkBlue,
        ClrSilver, ClrWhite, ClrWhite, g_pFontCmss20, g_ppcDirListStrings,
        8, 0, 0);
RectangularButton(pushbutton1, WIDGET_ROOT,&pushbutton2, 0,								//底部打击按钮左一
                  &g_sKitronix320x240x16_SSD2119, 1, 160, 78, 80,
                  (PB_STYLE_OUTLINE | PB_STYLE_TEXT_OPAQUE | PB_STYLE_TEXT |
                   PB_STYLE_FILL ),
                   ClrBlack, ClrYellow, ClrBlack, ClrWhite,
                   g_pFontCmss22b, "", 0, 0, 0, 0, onpress1,50);
RectangularButton(pushbutton2, WIDGET_ROOT, &pushbutton3, 0,								 //底部打击按钮左二
                  &g_sKitronix320x240x16_SSD2119, 81, 160, 78, 80,
                  (PB_STYLE_OUTLINE | PB_STYLE_TEXT_OPAQUE | PB_STYLE_TEXT |
                   PB_STYLE_FILL ),
                   ClrBlack, ClrYellow, ClrBlack, ClrWhite,
                   g_pFontCmss22b, "", 0, 0, 0, 0, onpress2,50);
RectangularButton(pushbutton3, WIDGET_ROOT, &pushbutton4, 0,							  //底部打击按钮右二
                  &g_sKitronix320x240x16_SSD2119, 161, 160, 78, 80,
                  (PB_STYLE_OUTLINE | PB_STYLE_TEXT_OPAQUE | PB_STYLE_TEXT |
                   PB_STYLE_FILL ),
                   ClrBlack, ClrYellow, ClrBlack, ClrWhite,
                   g_pFontCmss22b, "", 0, 0, 0, 0, onpress3,50);
RectangularButton(pushbutton4, WIDGET_ROOT, &pushbuttonok, 0,									//底部打击按钮右三
                  &g_sKitronix320x240x16_SSD2119, 241, 160, 78, 80    ,
                  (PB_STYLE_OUTLINE | PB_STYLE_TEXT_OPAQUE | PB_STYLE_TEXT |
                   PB_STYLE_FILL ),
                   ClrBlack, ClrYellow, ClrBlack, ClrWhite,
                   g_pFontCmss22b, "", 0, 0, 0, 0, onpress4,50);	
RectangularButton(pushbuttonok, WIDGET_ROOT, 0, 0,											  //ok按钮
                  &g_sKitronix320x240x16_SSD2119, 80, 160, 160,40 ,
                  (PB_STYLE_OUTLINE | PB_STYLE_TEXT_OPAQUE | PB_STYLE_TEXT |
                   PB_STYLE_FILL ),
                   ClrBlue, ClrYellow, ClrRed, ClrWhite,
                   g_pFontCmss22b, "Ok", 0, 0, 0, 0, onpressok,0);

//****************************************************************************
//*******由于播放声音模块较为独立，故单独放出*********************************
static unsigned char g_pucBuffer[AUDIO_BUFFER_SIZE]; //声音缓存区
static volatile unsigned long g_ulFlags;
static unsigned long g_ulBytesPlayed;
static unsigned long g_ulBytesRemaining;
unsigned long g_ulMaxBufferSize;
typedef struct	//声音头结构体
{
    unsigned long ulSampleRate;	 //采样频率
    unsigned long ulAvgByteRate;   //平均速率
    unsigned long ulDataSize;	   //大小
    unsigned short usBitsPerSample;	 //每个采样需要的bit数
    unsigned short usFormat;		 //记录编码方式
    unsigned short usNumChannels;	  //声道（单声道或立体声）
}
tWaveHeader;

static tWaveHeader g_sWaveHeader;
void
BufferCallback(void *pvBuffer, unsigned long ulEvent)//播放完缓冲区的回调函数
{
    if(ulEvent & BUFFER_EVENT_FREE)						// 改变缓存区状态，底部空还是顶部空
    {
        if(pvBuffer == g_pucBuffer)
        {
            g_ulFlags |= BUFFER_BOTTOM_EMPTY;
        }
        else
        {
            g_ulFlags |= BUFFER_TOP_EMPTY;
        }
        g_ulBytesPlayed += AUDIO_BUFFER_SIZE >> 1;
    }
}
FRESULT
WaveOpen(FIL *psFileObject, const char *pcFileName, tWaveHeader *pWaveHeader)  //打开wav文件并检测
{
    unsigned long *pulBuffer;
    unsigned short *pusBuffer;
    unsigned long ulChunkSize;
    unsigned short usCount;
    unsigned long ulBytesPerSample;
    FRESULT Result;
	
    pulBuffer = (unsigned long *)g_pucBuffer;	//8位8位取	  
    pusBuffer = (unsigned short *)g_pucBuffer;	 //4位4位取

    Result = f_open(psFileObject, pcFileName, FA_READ);	  //先打开文件（用到third party的fatfs文件读取库）
    if(Result != FR_OK)
    {	GrContextForegroundSet(&sContext, ClrGreen);
    GrContextFontSet(&sContext, g_pFontCm20);
    GrStringDrawCentered(&sContext, "Open Failed", -1,
    GrContextDpyWidthGet(&sContext) / 2, 10, 0);
	GrFlush(&sContext);
        return(Result);
    }
    Result = f_read(psFileObject, g_pucBuffer, 12, &usCount);//读第一个RIFF wave chunk(ID,size,type各4字节)
    if(Result != FR_OK)
    {	GrContextForegroundSet(&sContext, ClrRed); 
    GrContextFontSet(&sContext, g_pFontCm20);
    GrStringDrawCentered(&sContext, "Read Failed", -1,
    GrContextDpyWidthGet(&sContext) / 2, 10, 0);
	GrFlush(&sContext);
        f_close(psFileObject);
        return(Result);
    }
    if((pulBuffer[0] != 0x46464952) || (pulBuffer[2] != 0x45564157))	 //非wav文件(由于pulBuffer为long,所以pulBuffer[0]对应前4字节，pulBuffer[2]对应后4字节)
    {																	//此处把“FFIR”，“EVAW”转成了16进制，以下同
        f_close(psFileObject);
        return(FR_INVALID_NAME);
    }
    Result = f_read(psFileObject, g_pucBuffer, 8, &usCount);  //读format chunk的前8字节(ID,Size各4字节)
    if(Result != FR_OK)
    {	GrContextForegroundSet(&sContext, ClrRed);
    GrContextFontSet(&sContext, g_pFontCm20);
    GrStringDrawCentered(&sContext, "Read Failed", -1,
    GrContextDpyWidthGet(&sContext) / 2, 10, 0);
	GrFlush(&sContext);
        f_close(psFileObject);
        return(Result);
    }
    if(pulBuffer[0] != 0x20746d66)		  //非wav文件
    {
        f_close(psFileObject);
        return(FR_INVALID_NAME);
    }
    ulChunkSize = pulBuffer[1];

    if(ulChunkSize > 16)	  //非标准wav文件，这会过滤某些软件（如au）生成的含有附加信息的wav文件（chunksize是18bit）
    {
        f_close(psFileObject);
        return(FR_INVALID_NAME);
    }
    Result = f_read(psFileObject, g_pucBuffer, ulChunkSize, &usCount);	//读取format chunk, 收集信息
    if(Result != FR_OK)
    {	 GrContextForegroundSet(&sContext, ClrRed);
    GrContextFontSet(&sContext, g_pFontCm20);
    GrStringDrawCentered(&sContext, "Read Failed", -1,
    GrContextDpyWidthGet(&sContext) / 2, 10, 0);
	GrFlush(&sContext);
        f_close(psFileObject);
        return(Result);
    }
	//**********format chunk 之后的格式*****************
	/*| FormatTag     |  2 Bytes  | 编码方式，一般为0x0001               |
    --------------------------------------------------------------------     
    | Channels      |  2 Bytes  | 声道数目，1--单声道；2--双声道       |     
    --------------------------------------------------------------------     
    | SamplesPerSec |  4 Bytes  | 采样频率                             |     
    --------------------------------------------------------------------     
    | AvgBytesPerSec|  4 Bytes  | 每秒所需字节数                       |     
    --------------------------------------------------------------------     
    | BlockAlign    |  2 Bytes  | 数据块对齐单位(每个采样需要的字节数) |     
    --------------------------------------------------------------------     
    | BitsPerSample |  2 Bytes  | 每个采样需要的bit数
	*/
	//**************************************************	
    pWaveHeader->usFormat = pusBuffer[0];
    pWaveHeader->usNumChannels =  pusBuffer[1];
    pWaveHeader->ulSampleRate = pulBuffer[1];
    pWaveHeader->ulAvgByteRate = pulBuffer[2];
    pWaveHeader->usBitsPerSample = pusBuffer[7];
    g_ulBytesPlayed = 0;
    ulBytesPerSample = (pWaveHeader->usBitsPerSample *
                        pWaveHeader->usNumChannels) >> 3;
    if(((AUDIO_BUFFER_SIZE >> 1) / ulBytesPerSample) > 1024)			//设置最大读取量，不超过1024个sample，或者一半缓存区大小
    {
        g_ulMaxBufferSize = 1024 * ulBytesPerSample;
    }
    else
    {
        g_ulMaxBufferSize = AUDIO_BUFFER_SIZE >> 1;
    }
    if(pWaveHeader->usNumChannels > 2) //只能播放单声道或立体声
    {
        f_close(psFileObject);
        return(FR_INVALID_NAME);
    }
    Result = f_read(psFileObject, g_pucBuffer, 8, &usCount);	//读取data chunk（某些软件的wav可能使此处为fact chunk 而不是data chunk）
    if(Result != FR_OK)
    {
        f_close(psFileObject);
        return(Result);
    }

    if(pulBuffer[0] !=0x61746164)	 //非标准wav文件，退出
    {
        f_close(psFileObject);
        return(Result);
    }
		
    pWaveHeader->ulDataSize = pulBuffer[1];		 //文件大小
    g_ulBytesRemaining = pWaveHeader->ulDataSize;
    if((pWaveHeader->usNumChannels == 1) && (pWaveHeader->usBitsPerSample == 8))
    {
        pWaveHeader->ulAvgByteRate <<=1;
    }
    SoundSetFormat(pWaveHeader->ulSampleRate, pWaveHeader->usBitsPerSample,	 //设置声音格式
                   pWaveHeader->usNumChannels);

    return(FR_OK);
}
void
WaveClose(FIL *psFileObject)	  //关闭声音文件
{
    f_close(psFileObject);
}
void
Convert8Bit(unsigned char *pucBuffer, unsigned long ulSize)	  //将无符号转成有符号，以便传输到I2S
{
    unsigned long ulIdx;

    for(ulIdx = 0; ulIdx < ulSize; ulIdx++)
    {
        *pucBuffer = ((short)(*pucBuffer)) - 128;
        pucBuffer++;
    }
}
unsigned short
WaveRead(FIL *psFileObject, tWaveHeader *pWaveHeader, unsigned char *pucBuffer)	//读取声音文件
{
    unsigned long ulBytesToRead;
    unsigned short usCount;
    if(g_ulBytesRemaining < g_ulMaxBufferSize)				  //按最大读取量与剩余的最小值读取
    {
        ulBytesToRead = g_ulBytesRemaining;
    }
    else
    {
        ulBytesToRead = g_ulMaxBufferSize;
    }
    if(f_read(&pFile, pucBuffer, ulBytesToRead, &usCount) != FR_OK)	 //读取失败
    {
        return(0);
    }
    g_ulBytesRemaining -= usCount;			   //减去剩余
    if(pWaveHeader->usBitsPerSample == 8)
    {
        Convert8Bit(pucBuffer, usCount);		 //转成有符号
    }

    return(usCount);
}
//****************************************************************************
//*****************************************************************************
//普通的操作函数声明区域，定义放在主函数后
//*****************************************************************************
void moverec(tContext *sContext,tRectangle *sRect);	//向下移动一个矩形（note）1单位
void moverec1(tContext *sContext,tRectangle *sRect,int i); //向下移动一个长按键（矩形加长条）1单位
void destroyrec(tContext *sContext,tRectangle *sRect);//抹掉一个矩形
void destroyrec1(tContext *sContext,tRectangle *sRect,int i);//抹掉一个长按键
void getdata(void);	//将txt文件的数据转换成按键信息
void initialarray(void); //游戏开始前的初始化
void uartstringput(unsigned long ulBase,char *cMessage);//向电脑发送一个字符串
void clr(void);//清屏
int populate(char s);//根据所选难度初始化listbox
int max(int a,int b); //取两数最大值
void missorperfect(int j);	//根据按键情况判定是miss还是great还是perfect
void printlevel(void);	 //游戏结束后评判等级
//*****************************************************************************
//按钮控件的函数定义
//*****************************************************************************
void onpress1(tWidget *pWidget)				   //onpress1 到onpress 4 是游戏当中的按键函数，由于更改过grlib，现在摁下与松开按键将分别触发一次该函数
{	if(flagpos[0]==false)flagpos[0]=true;	   //区分是按下还是松开
	else flagpos[0]=false;
    if(flagpos[0]==true)								 //按下
  {	GrContextForegroundSet(&sContext1, ClrYellow);				//点亮中部的按键效果圈
    GrCircleDraw(&sContext1, 160, 120, 9);
	k=timepoint;
    totaltime+=1+(k-notehasgone)/5;	//时间微小补偿		
	for(j=notehasgone;j<k;++j)	 //搜索固定道的按键
	{
		if(position[j]==0 && type[j]==0){destroyrec(&sContext,&sRect[j]);position[j]=-1;missorperfect(j);break;	} //找到点键，抹掉并判定
		if(position[j]==0 && type[j]>0){   //找到长按键, 判定，若为miss则抹掉，否则不做处理，等长按键全部跑完或中途松开按键再判定
		if(sRect[j].sYMax<200){
		++missnum;combo=0;maxcombo=max(combo, maxcombo);destroyrec1(&sContext,&sRect[j],j);position[j]=-1;
		GrContextForegroundSet(&sContext1, ClrRed);GrCircleFill(&sContext1, 160, 120, 8);break;}
		else{	tRect2.sXMin=10;
				tRect2.sXMax=70;
				GrContextForegroundSet(&sContext1, ClrBlack);
				GrRectFill(&sContext1, &tRect2);
				}
		flagholded[0]=true;break; }	//更改这一键道的状态，记录已被按过
	}
  }
  else
  {
  	GrContextForegroundSet(&sContext1, ClrBlack);	   //松开，熄灭中部按键效果圈
    GrCircleDraw(&sContext1, 160, 120, 9);
  }
}
void onpress2(tWidget *pWidget)					
{	
	if(flagpos[1]==false)flagpos[1]=true;
	else flagpos[1]=false;
    if(flagpos[1]==true)
  {	GrContextForegroundSet(&sContext1, ClrYellow);
    GrCircleDraw(&sContext1, 160, 120, 9);
	k=timepoint;
	totaltime+=1+(k-notehasgone)/5;
	for(j=notehasgone;j<k;++j)
	{
		if(position[j]==1 && type[j]==0){destroyrec(&sContext,&sRect[j]);position[j]=-1;missorperfect(j);break;	}
		if(position[j]==1 && type[j]>0){
		if(sRect[j].sYMax<200){
		++missnum;combo=0;maxcombo=max(combo, maxcombo);destroyrec1(&sContext,&sRect[j],j);position[j]=-1;
		GrContextForegroundSet(&sContext1, ClrRed);GrCircleFill(&sContext1, 160, 120, 8);break;}
		else{	tRect2.sXMin=90;
				tRect2.sXMax=150;
				GrContextForegroundSet(&sContext1, ClrBlack);
				GrRectFill(&sContext1, &tRect2);
				}
		flagholded[1]=true;break;	}
		
	}
	}
	else
  {
  	GrContextForegroundSet(&sContext1, ClrBlack);
    GrCircleDraw(&sContext1, 160, 120, 9);
  }
}
void onpress3(tWidget *pWidget)
{	if(flagpos[2]==false)flagpos[2]=true;
	else flagpos[2]=false;
    if(flagpos[2]==true)
  {	GrContextForegroundSet(&sContext1, ClrYellow);
    GrCircleDraw(&sContext1, 160, 120, 9);
	k=timepoint;
	totaltime+=1+(k-notehasgone)/5;
	for(j=notehasgone;j<k;++j)
	{
		if(position[j]==2 && type[j]==0){destroyrec(&sContext,&sRect[j]);position[j]=-1;missorperfect(j);break;	}
		if(position[j]==2 && type[j]>0){if(sRect[j].sYMax<200){
		++missnum;combo=0;maxcombo=max(combo, maxcombo);destroyrec1(&sContext,&sRect[j],j);position[j]=-1;
		GrContextForegroundSet(&sContext1, ClrRed);GrCircleFill(&sContext1, 160, 120, 8);break;	}
			else{	tRect2.sXMin=170;
				tRect2.sXMax=230;
				GrContextForegroundSet(&sContext1, ClrBlack);
				GrRectFill(&sContext1, &tRect2);
				}
		flagholded[2]=true;break;}
	
	}
  }
  else
  {
  	GrContextForegroundSet(&sContext1, ClrBlack);
    GrCircleDraw(&sContext1, 160, 120, 9);
  }
}
void onpress4(tWidget *pWidget)
{	if(flagpos[3]==false)flagpos[3]=true;
	else flagpos[3]=false;
    if(flagpos[3]==true)
  {	GrContextForegroundSet(&sContext1, ClrYellow);
    GrCircleDraw(&sContext1, 160, 120, 9);
	k=timepoint;
	totaltime+=1+(k-notehasgone)/5;
	for(j=notehasgone;j<k;++j)
	{
		if(position[j]==3 && type[j]==0){destroyrec(&sContext,&sRect[j]);position[j]=-1;missorperfect(j);break;	}
		if(position[j]==3 && type[j]>0){
		if(sRect[j].sYMax<200){++missnum;combo=0;maxcombo=max(combo, maxcombo);destroyrec1(&sContext,&sRect[j],j);position[j]=-1;
		GrContextForegroundSet(&sContext1, ClrRed);GrCircleFill(&sContext1, 160, 120, 8);break;}
		else{	tRect2.sXMin=250;
				tRect2.sXMax=310;
				GrContextForegroundSet(&sContext1, ClrBlack);
				GrRectFill(&sContext1, &tRect2);
				}
		flagholded[3]=true;break;	}
	}
	}
	else
  {
  	GrContextForegroundSet(&sContext1, ClrBlack);
    GrCircleDraw(&sContext1, 160, 120, 9);
  }
}
void onpressstart(tWidget *pWidget)		//最开始的开始按钮
{
	flagstart=true;
	BuzzerBeep();
}
void onpresseasy(tWidget *pWidget)				 //难度选择按钮
{
	flaglevel=1;
	BuzzerBeep();
}
void onpressnormal(tWidget *pWidget)
{
	flaglevel=2;
	BuzzerBeep();
}
void onpresshard(tWidget *pWidget)
{
	flaglevel=3;
	BuzzerBeep();
}
void onpressok(tWidget *pWidget)			   //最后的ok按钮
{
	flagok=true;
	BuzzerBeep();
}
void onpresschooseok(tWidget *pWidget)				//选择歌曲后的确定按钮
{	selected=ListBoxSelectionGet(&songlist);
	if(selected>=0)flagchooseok=true;
}
void onpressreturn(tWidget *pWidget)		 //选择歌曲界面的return按钮
{	flagreturn=true;
	BuzzerBeep();
}
void setvolume(tWidget *pWidget,long lvalue)
{
	SoundVolumeSet(lvalue);	
	testflag=lvalue; 
							
}
//*****************************************************************************
//*****************************int main()**************************************
//*****************************************************************************
int
main(void)				
{	
	int i;	  //循环变量
   
	
    ROM_SysCtlClockSet(SYSCTL_SYSDIV_4 | SYSCTL_USE_PLL | SYSCTL_XTAL_16MHZ |
                       SYSCTL_OSC_MAIN);//设置50MHz时钟
	SysCtlDelay(100);				   
	TheSysClock =ROM_SysCtlClockGet();
	ROM_SysTickPeriodSet(SysCtlClockGet() / 100);
	ROM_SysTickEnable();
    ROM_SysTickIntEnable();
	ROM_IntMasterEnable();				
	
	
    PinoutSet();
	ROM_SysCtlPeripheralEnable(SYSCTL_PERIPH_UDMA);	    
	ROM_uDMAControlBaseSet(&sDMAControlTable[0]);
    ROM_uDMAEnable();
    Kitronix320x240x16_SSD2119Init();
	TouchScreenInit();
	TouchScreenCallbackSet(WidgetPointerMessage);
	UART0Initial();
	PWMInitial();
	TimerInitial();
	SoundInit(0);
	SoundVolumeSet(60);
    GrContextInit(&sContext, &g_sKitronix320x240x16_SSD2119);
	GrContextInit(&sContext1, &g_sKitronix320x240x16_SSD2119);
	GrContextForegroundSet(&sContext, ClrYellow);
    GrContextFontSet(&sContext, g_pFontCm20);

	//***********************************************************准备阶段;
	WidgetAdd(WIDGET_ROOT, (tWidget *)&pushbuttonstart);  //更新屏幕按钮
	WidgetRemove((tWidget *)&pushbutton1);
	WidgetRemove((tWidget *)&pushbutton2);
	WidgetRemove((tWidget *)&pushbutton3);
	WidgetRemove((tWidget *)&pushbutton4);
	WidgetRemove((tWidget *)&pushbuttoneasy);
	WidgetRemove((tWidget *)&volumebar);
	WidgetRemove((tWidget *)&pushbuttonnormal);
	WidgetRemove((tWidget *)&pushbuttonhard);
	WidgetRemove((tWidget *)&pushbuttonok);
	WidgetRemove((tWidget *)&pushbuttonchoosestart);
	WidgetRemove((tWidget *)&pushbuttonreturn);
	WidgetRemove((tWidget *)&songlist);
	flagstart=false;
	WidgetPaint(WIDGET_ROOT);
	WidgetMessageQueueProcess();
	GrStringDrawCentered(&sContext, "Music Rhythm Game", -1,
    GrContextDpyWidthGet(&sContext) / 2, 50, 0);
	while(1)							   //等待按键
	{
		WidgetMessageQueueProcess();
		if(flagstart==true)break;
	}

	while(1){
	ROM_SysTickEnable();
    ROM_SysTickIntEnable();
	//********************************************选择等级***************************
	clr();
	flaglevel=0; //记录所选等级
	WidgetRemove((tWidget *)&pushbuttonstart);		 //更新屏幕按钮
	WidgetAdd(WIDGET_ROOT, (tWidget *)&pushbuttoneasy);
	WidgetAdd(WIDGET_ROOT, (tWidget *)&pushbuttonnormal);
	WidgetAdd(WIDGET_ROOT, (tWidget *)&pushbuttonhard);
	WidgetRemove((tWidget *)&pushbutton1);
	WidgetRemove((tWidget *)&pushbutton2);
	WidgetRemove((tWidget *)&pushbutton3);
	WidgetRemove((tWidget *)&pushbutton4);
	WidgetRemove((tWidget *)&pushbuttonok);
	WidgetRemove((tWidget *)&pushbuttonchoosestart);
	WidgetRemove((tWidget *)&pushbuttonreturn);
	WidgetRemove((tWidget *)&songlist);
	WidgetRemove((tWidget *)&volumebar);
	WidgetPaint(WIDGET_ROOT);
	WidgetMessageQueueProcess();
	WaveClose(&pFile);
	fresult = f_mount(0, &g_sFatFs);
		
	while(1)			  //等待确定
	{
		if(flaglevel>0)break;
		WidgetMessageQueueProcess();
	}
	//*****************************************************选择歌曲*****************************************
	clr();
	flagchooseok=false;
	flagreturn=false;
	selected=-1;
	fresult = f_mount(0, &g_sFatFs);
	if(flaglevel==1)populate('E');			   //根据选择等级在listbox显示相应文件（根据文件名首字母筛选）
	else if(flaglevel==2)populate('N');
	else if(flaglevel==3)populate('H');
	WidgetRemove((tWidget *)&pushbuttonstart);
	WidgetRemove((tWidget *)&pushbuttoneasy);
	WidgetRemove((tWidget *)&pushbuttonnormal);
	WidgetRemove((tWidget *)&pushbuttonhard);
	WidgetAdd(WIDGET_ROOT, (tWidget *)&pushbuttonchoosestart);
	WidgetAdd(WIDGET_ROOT, (tWidget *)&pushbuttonreturn);
	WidgetRemove((tWidget *)&pushbutton1);
	WidgetRemove((tWidget *)&pushbutton2);
	WidgetRemove((tWidget *)&pushbutton3);
	WidgetRemove((tWidget *)&pushbutton4);
	WidgetRemove((tWidget *)&pushbuttonok);
	WidgetAdd(WIDGET_ROOT, (tWidget *)&songlist);
	WidgetAdd(WIDGET_ROOT, (tWidget *)&volumebar);
	WidgetPaint(WIDGET_ROOT);
	WidgetMessageQueueProcess();
	while(1)										   //等待按键
	{
		if(testflag>0)		
	{
	WaveOpen(&pFile, "sound.wav",&g_sWaveHeader);							
	g_ulFlags = BUFFER_BOTTOM_EMPTY | BUFFER_TOP_EMPTY;
	g_ulFlags |= BUFFER_PLAYING;
	IntDisable(INT_I2S0);
	while(1)
	{
        if(g_ulFlags & BUFFER_BOTTOM_EMPTY)
        {
            usCount = WaveRead(&pFile, &g_sWaveHeader, g_pucBuffer); //读取声音
            SoundBufferPlay(g_pucBuffer, usCount, BufferCallback);		  //播放声音
            g_ulFlags &= ~BUFFER_BOTTOM_EMPTY;
        }
        if(g_ulFlags & BUFFER_TOP_EMPTY)				   //检测高一半与低一半缓存区状态
        {
            usCount = WaveRead(&pFile, &g_sWaveHeader,
                               &g_pucBuffer[AUDIO_BUFFER_SIZE >> 1]);
            SoundBufferPlay(&g_pucBuffer[AUDIO_BUFFER_SIZE >> 1],
                            usCount, BufferCallback);
            g_ulFlags &= ~BUFFER_TOP_EMPTY;

        }
        if((usCount < g_ulMaxBufferSize) || (g_ulBytesRemaining == 0))
        {
            g_ulFlags &= ~BUFFER_PLAYING;
            while(g_ulFlags != (BUFFER_TOP_EMPTY | BUFFER_BOTTOM_EMPTY))
            {}
		testflag=0;	
		break;
        }
		WidgetMessageQueueProcess();
	}
		IntEnable(INT_I2S0);
		WaveClose(&pFile);
	}
		if(flagchooseok==true || flagreturn==true)break;
		WidgetMessageQueueProcess();
	}
	if(flagreturn==true)continue;						 //返回
	strncpy(filenameopen, filename[selected], 16);		  
	for(i=0;i<10000;++i)databuffer[i]=0;


	fresult = f_mount(0, &g_sFatFs);				   //打开对应txt文件，读进databuffer
    if(fresult != FR_OK)
    {	GrContextForegroundSet(&sContext, ClrRed);
    GrContextFontSet(&sContext, g_pFontCm20);
    GrStringDrawCentered(&sContext, "Driving Failed", -1,
    GrContextDpyWidthGet(&sContext) / 2, 10, 0);
	fresult = f_mount(0, &g_sFatFs);
	GrFlush(&sContext);
        return(1);
    }
	fresult = f_open(&pFile, filenameopen, FA_READ);
    if(fresult != FR_OK)
    {	
	 if(fresult==FR_NOT_READY){	GrContextForegroundSet(&sContext, ClrRed);
    GrContextFontSet(&sContext, g_pFontCm20);
    GrStringDrawCentered(&sContext, "Not Ready", -1,
    GrContextDpyWidthGet(&sContext) / 2, 10, 0);
	fresult = f_mount(0, &g_sFatFs);
	GrFlush(&sContext);}
	GrContextForegroundSet(&sContext, ClrRed);
    GrContextFontSet(&sContext, g_pFontCm20);
    GrStringDrawCentered(&sContext, "Open Failed", -1,
    GrContextDpyWidthGet(&sContext) / 2, 10, 0);
	fresult = f_mount(0, &g_sFatFs);
	GrFlush(&sContext);
        return(fresult);
    }
    fresult = f_read(&pFile, databuffer, sizeof(databuffer), &usCount);
    if(fresult != FR_OK)
    {	GrContextForegroundSet(&sContext, ClrRed);
    GrContextFontSet(&sContext, g_pFontCm20);
    GrStringDrawCentered(&sContext, "Read Failed", -1,
    GrContextDpyWidthGet(&sContext) / 2, 10, 0);
	fresult = f_mount(0, &g_sFatFs);
	GrFlush(&sContext);
        f_close(&pFile);
        return(fresult);
    }


	for(i=0;i<16;++i)wavenameopen[i]=0;							//打开对应wav文件
	for(i=1;i<16;++i)if(filenameopen[i]!='.')wavenameopen[i-1]=filenameopen[i];
	strcat(wavenameopen,".wav");
   WaveOpen(&pFile, wavenameopen,&g_sWaveHeader);
	GrContextForegroundSet(&sContext, ClrRed);
    GrContextFontSet(&sContext, g_pFontCm20);
    GrStringDrawCentered(&sContext, wavenameopen, -1,
    GrContextDpyWidthGet(&sContext) / 2, 10, 0);
//*****************************************************游戏中*****************************************
//***************************************************************************************************
	clr();
	for(i=0;i<1000;++i)
	{
    sRect[i].sXMin = 0;
    sRect[i].sYMin = -20;
    sRect[i].sXMax = 40;
    sRect[i].sYMax = 0;
	}
	tRect1.sYMin=210;
	tRect1.sYMax=215;
	tRect2.sYMin=235;
	tRect2.sYMax=240;
	
		
	initialarray();	//初始化数组							
	GrContextForegroundSet(&sContext1, ClrRed);
	GrLineDraw(&sContext1 , 0, 209, 320, 209);
	GrContextForegroundSet(&sContext1, ClrBlue);
	GrLineDraw(&sContext1 , 0, 0, 0, 240);
	GrLineDraw(&sContext1 , 80, 0, 80, 240);
	GrLineDraw(&sContext1 , 160, 0, 160, 240);
	GrLineDraw(&sContext1 , 240, 0, 240, 240);
	GrLineDraw(&sContext1 , 319, 0, 319, 240);
	GrContextForegroundSet(&sContext1, ClrWhite);
	GrCircleFill (&sContext1, 160, 120, 8);
	GrContextFontSet(&sContext1, g_pFontCm20);
	GrFlush(&sContext1);
    GrFlush(&sContext);
	WidgetRemove((tWidget *)&pushbuttonnormal);
	WidgetRemove((tWidget *)&pushbuttoneasy);
	WidgetRemove((tWidget *)&pushbuttonhard);
	WidgetAdd(WIDGET_ROOT, (tWidget *)&pushbutton1);
	WidgetAdd(WIDGET_ROOT, (tWidget *)&pushbutton2);
	WidgetAdd(WIDGET_ROOT, (tWidget *)&pushbutton3);
	WidgetAdd(WIDGET_ROOT, (tWidget *)&pushbutton4);
	WidgetRemove((tWidget *)&pushbuttonok);
	WidgetRemove((tWidget *)&songlist);
	WidgetRemove((tWidget *)&pushbuttonchoosestart);
	WidgetRemove((tWidget *)&pushbuttonreturn);
	WidgetRemove((tWidget *)&volumebar);
	WidgetPaint(WIDGET_ROOT);
    WidgetMessageQueueProcess();	
	getdata();
	for(i=0;i<notenumber;++i)
	{
	sRect[i].sXMin=80*position[i]+10;
	  sRect[i].sXMax=80*position[i]+70;
	  }
	 g_ulFlags = BUFFER_BOTTOM_EMPTY | BUFFER_TOP_EMPTY;
   	g_ulFlags |= BUFFER_PLAYING;
	timepoint=0;
	totaltime=0;
	notehasgone=0;
	uartstringput(UART0_BASE,filenameopen);
	TimerEnable(TIMER0_BASE,TIMER_A);

//**********************主循环*********************************************************
   while(1)
    {
	
	while(flag==true){};	  //由timer控制循环的时间片
	 flag=true;
		

           //*************************************************播放声音*********************************************{
	       IntDisable(INT_I2S0);
        if(g_ulFlags & BUFFER_BOTTOM_EMPTY)
        {
            usCount = WaveRead(&pFile, &g_sWaveHeader, g_pucBuffer); //读取声音
            SoundBufferPlay(g_pucBuffer, usCount, BufferCallback);		  //播放声音
            g_ulFlags &= ~BUFFER_BOTTOM_EMPTY;
        }
        if(g_ulFlags & BUFFER_TOP_EMPTY)				   //检测高一半与低一半缓存区状态
        {
            usCount = WaveRead(&pFile, &g_sWaveHeader,
                               &g_pucBuffer[AUDIO_BUFFER_SIZE >> 1]);
            SoundBufferPlay(&g_pucBuffer[AUDIO_BUFFER_SIZE >> 1],
                            usCount, BufferCallback);
            g_ulFlags &= ~BUFFER_TOP_EMPTY;

        }
        if((usCount < g_ulMaxBufferSize) || (g_ulBytesRemaining == 0))
        {
            g_ulFlags &= ~BUFFER_PLAYING;
            while(g_ulFlags != (BUFFER_TOP_EMPTY | BUFFER_BOTTOM_EMPTY))
            {}
        }
        		  
        //**********************************************************播放声音结束************************************************

	 totaltime+=4;										   //总时间加4
	 if(timestamp[timepoint]<=totaltime)				   //检测该时间点是否有note产生
	 { 
	 ++timepoint;}										   //检测点加一
	 while(position[notehasgone]==-1)++notehasgone;		   //跳过已消失的note
	 for(i=notehasgone;i<timepoint;++i)						//检测所有屏幕上的键
	 {
	 if(position[i]>=0){
	 if(type[i]==0){   //点键
	 if(position[i]>=0)moverec(&sContext,&sRect[i]);//下移
	 if(sRect[i].sYMin>240){position[i]=-1;++missnum;maxcombo=max(combo, maxcombo);combo=0;GrContextForegroundSet(&sContext1, ClrRed);GrCircleFill (&sContext1, 160, 120, 8);}
	 }//掉落到屏幕最下方也没有被击中，miss加1
	 if(type[i]>0){	 //长按键
	 if(position[i]>=0){moverec1(&sContext,&sRect[i],i); //下移
	 if(sRect[i].sYMin>240 && flagpos[position[i]]==false && flagholded[position[i]]==false){destroyrec1(&sContext,&sRect[i],i);++notehasgone;position[i]=-1;++missnum;maxcombo=max(combo, maxcombo);combo=0;GrContextForegroundSet(&sContext1, ClrRed);GrCircleFill(&sContext1, 160, 120, 8);}
	 ////掉落到屏幕最下方也没有被按下，miss加1
	 else if(sRect[i].sYMin-type[i]/4+20<209 && flagpos[position[i]]==false && flagholded[position[i]]==true){flagholded[position[i]]=false;destroyrec1(&sContext,&sRect[i],i);position[i]=-1;++missnum;maxcombo=max(combo, maxcombo);combo=0;GrContextForegroundSet(&sContext1, ClrRed);GrCircleFill(&sContext1, 160, 120, 8);}
	  //还未结束就松开，miss加1
	 else if(sRect[i].sYMin-type[i]/4+20>209 ){tRect1.sXMin=80*position[i]+10+28;tRect1.sXMax=80*position[i]+10+32;flagholded[position[i]]=false;position[i]=-1;++perfectnum;++combo;GrContextForegroundSet(&sContext1, ClrGreen);GrCircleFill(&sContext1, 160, 120, 8);GrContextForegroundSet(&sContext1, ClrBlack);GrRectFill(&sContext1, &tRect1);}
	  //按下直到长按键全部结束, perfect加1
	  }	 }			  }
	 
	 }
	WidgetMessageQueueProcess(); //处理按键事件
    GrFlush(&sContext);
	IntEnable(INT_I2S0);
 	if(totaltime>timestamp[notenumber-1]+type[notenumber-1]+5000 )break;  //全部按键结束，等待5s退出
    }
	//*************************************************游戏结束*********************************************
	clr();
	flagok=false;
	WaveClose(&pFile);						  //清屏，关闭音乐文件，计算得分与等级并打印
	TimerDisable(TIMER0_BASE,TIMER_A);
	if(maxcombo<combo)maxcombo=combo;
	totalpoint=perfectnum*5+greatnum*3+maxcombo;
	WidgetAdd(WIDGET_ROOT, (tWidget *)&pushbuttonok);
	WidgetRemove((tWidget *)&pushbutton1);
	WidgetRemove((tWidget *)&pushbutton2);
	WidgetRemove((tWidget *)&pushbutton3);
	WidgetRemove((tWidget *)&pushbutton4);
	WidgetPaint(WIDGET_ROOT);
    WidgetMessageQueueProcess();
	sprintf(perfects,"perfect: %d", perfectnum);
	sprintf(greats,"great: %d", greatnum);
	sprintf(misss,"miss: %d", missnum);
	sprintf(maxcombos,"maxcombo: %d", maxcombo);
	sprintf(totalpoints,"point: %d", totalpoint);
	GrContextForegroundSet(&sContext, ClrWhite);
    GrContextFontSet(&sContext, g_pFontCmss22b);
    GrStringDrawCentered(&sContext, perfects, -1,
    GrContextDpyWidthGet(&sContext) / 2-50, 40, 0);
	 GrStringDrawCentered(&sContext, greats, -1,
    GrContextDpyWidthGet(&sContext) / 2-50, 65, 0);
	 GrStringDrawCentered(&sContext, misss, -1,
    GrContextDpyWidthGet(&sContext) / 2-50, 90, 0);
	 GrStringDrawCentered(&sContext, maxcombos, -1,
    GrContextDpyWidthGet(&sContext) / 2-50, 115, 0);
	 GrStringDrawCentered(&sContext, totalpoints, -1,
    GrContextDpyWidthGet(&sContext) / 2-50, 140, 0);
	printlevel();
	WaveClose(&pFile);
	fresult = f_mount(0, &g_sFatFs);
	while(1)						   //等待按键
	{
		WidgetMessageQueueProcess();
		if(flagok==true)break;
	}
	}
}



 //*********************************************一般函数定义*****************************************

void moverec(tContext  * sContext,tRectangle * sRect)
{	
    sRect->sYMax =sRect->sYMin;
	GrContextForegroundSet(sContext, ClrBlack);
    if(sRect->sYMin!=209)GrRectFill(sContext, sRect);
	sRect->sYMax =sRect->sYMin+20+1;
	sRect->sYMin =sRect->sYMax;
	GrContextForegroundSet(sContext, ClrDarkBlue);
    if(sRect->sYMin!=209)GrRectFill(sContext, sRect);
	sRect->sYMin =sRect->sYMax-20;
	
}
void moverec1(tContext  * sContext,tRectangle * sRect,int i)
{	
	GrContextForegroundSet(sContext, ClrBlack);
	if((sRect->sYMin<209) ||((sRect->sYMin>209)&&(sRect->sYMin<=215))||((sRect->sYMin>215)&&(flagpos[position[i]]==false)&&(sRect->sYMin<236))||((sRect->sYMin>=236)&&(sRect->sYMin<=240)&&(flagpos[position[i]]==false))){
    GrLineDraw(sContext , sRect->sXMin, sRect->sYMin, sRect->sXMin+27, sRect->sYMin);
	GrLineDraw(sContext , sRect->sXMin+33, sRect->sYMin, sRect->sXMin+60, sRect->sYMin);
	}
	if(sRect->sYMin-type[i]/4+20>=0 && sRect->sYMin-type[i]/4+20!=209)GrLineDraw(sContext , sRect->sXMin+28, sRect->sYMin-type[i]/4+20, sRect->sXMin+32, sRect->sYMin-type[i]/4+20);
	sRect->sYMax=sRect->sYMax+1;
	sRect->sYMin =sRect->sYMax;
	GrContextForegroundSet(sContext, ClrGreen);
    if((sRect->sYMin<209) ||((sRect->sYMin>209)&&(sRect->sYMin<=215))||((sRect->sYMin>215)&&(flagpos[position[i]]==false)&&(sRect->sYMin<236))||((sRect->sYMin>=236)&&(sRect->sYMin<=240)&&(flagpos[position[i]]==false)))GrRectFill(sContext, sRect);
	 sRect->sYMin =sRect->sYMax-20;
}
void destroyrec(tContext *sContext,tRectangle *sRect)	  
{
	 GrContextForegroundSet(sContext, ClrBlack);
	 GrRectFill(sContext, sRect);
	 GrContextForegroundSet(&sContext1, ClrRed);
     GrLineDraw(&sContext1 , sRect->sXMin, 209, sRect->sXMax, 209);
}
void destroyrec1(tContext *sContext,tRectangle *sRect,int i)
{	GrContextForegroundSet(sContext, ClrBlack);
	if(sRect->sYMin<=240)GrRectFill(sContext, sRect);
	sRect->sXMin = sRect->sXMin+28;
    sRect->sYMin = sRect->sYMin-type[i]/4+20;
    sRect->sXMax = sRect->sXMax-28;
	GrContextForegroundSet(sContext, ClrBlack);
	 GrRectFill(sContext, sRect);
	 GrContextForegroundSet(&sContext1, ClrRed);
     GrLineDraw(&sContext1 , sRect->sXMin-28, 209, sRect->sXMax+28, 209);
}

void getdata(void)	   //将读入的数据转入到数组中
{   int s=0;
    int r=0;
	notenumber=0;

	while(databuffer[s]>='0' && databuffer[s]<='9'){notenumber=notenumber*10+databuffer[s]-'0';++s;}	 //读入字符，转化成整型数
	++s;
	++s;
	while(1){
	while(databuffer[s]!=' '){timestamp[r]=timestamp[r]*10+databuffer[s]-'0';++s;}		 
	++s;
	position[r]=databuffer[s]-'0';
	++s;
	++s;
	while(databuffer[s]>='0' && databuffer[s]<='9'){type[r]=type[r]*10+databuffer[s]-'0';++s;}
	++r;
	if(r>=notenumber)break;
	++s;							   //注意一个换行符要用两个字符位置（不清楚为什么。。）
	++s;
	
	}
	for(s=0;s<notenumber;++s)timestamp[s]=timestamp[s]-920;
	timestamp[notenumber]=10000000;
		


}
void initialarray(void)							 //初始化变量
{
	int i=0;
	for(i=0;i<1000;++i)
	{
		timestamp[i]=0;
		position[i]=0;
		type[i]=0;
			
	}
	for(i=0;i<4;++i){flagpos[i]=false;flagholded[i]=false;}
	notenumber=0;
	timepoint=0;
	notehasgone=0;
	missnum=0;
	greatnum=0;
	perfectnum=0;
	combo=0;
	maxcombo=0;
	totalpoint=0;
}
void clr(void)										 //清屏，涂黑屏幕
{
	GrContextForegroundSet(&sContext, ClrBlack);
	tRect.sXMin = 0;
    tRect.sYMin = 0;
    tRect.sXMax = 320;
    tRect.sYMax = 240;
	GrRectFill(&sContext, &tRect);
}
int populate(char s)//显示框显示			//根据首字母来决定要显示的内容
{	int p;
    unsigned long ulItemCount;
    FRESULT fresult;
    ListBoxClear(&songlist);
    fresult = f_opendir(&g_sDirObject, "/");
    if(fresult != FR_OK)
    {
        return(fresult);
    }
    ulItemCount = 0;
    while(1)
    {  
        fresult = f_readdir(&g_sDirObject, &g_sFileInfo);
        if(fresult != FR_OK)
        {
            return(fresult);
        }

        if(!g_sFileInfo.fname[0])
        {
            break;
        }

        if(ulItemCount < 8 )
        {
            if((g_sFileInfo.fattrib & AM_DIR) == 0 && g_sFileInfo.fname[0]==s)
            {
                strncpy(filename[ulItemCount], g_sFileInfo.fname,
                         13);
				for(p=0;p<13;++p)filenamedisplay[ulItemCount][p]='\0';
				for(p=0;p<13;++p){if(g_sFileInfo.fname[p+1]=='.')break;filenamedisplay[ulItemCount][p]=g_sFileInfo.fname[p+1];}
                ListBoxTextAdd(&songlist, filenamedisplay[ulItemCount]);
            }
        }

        if((g_sFileInfo.fattrib & AM_DIR ) == 0  && g_sFileInfo.fname[0]==s)
        {
            ulItemCount++;
        }
    }
	}
void uartstringput(unsigned long ulBase,char *cMessage)		   //另一方案要用电脑播放音乐，这是传输字符串函数
{
	while(*cMessage!='\0')
	{
		UARTCharPut(ulBase,*(cMessage++));
	}
	UARTCharPut(ulBase,'\r')  ;
}
int max(int a,int b)				//取较大数
{
	if(a>b)return a;
	else return b;
}
void missorperfect(int j)		// 判定玩家按键
{
	if(sRect[j].sYMax>200 && sRect[j].sYMax<248){++perfectnum;++combo;GrContextForegroundSet(&sContext1, ClrGreen);}
	else if((sRect[j].sYMax>180 && sRect[j].sYMax<=200)||(sRect[j].sYMax>=248) ){++greatnum;++combo;GrContextForegroundSet(&sContext1, ClrBlue);}
	else if(sRect[j].sYMax<=180){++missnum;combo=0;maxcombo=max(combo, maxcombo);GrContextForegroundSet(&sContext1, ClrRed);}
	GrCircleFill (&sContext1, 160, 120, 8);
}
void printlevel(void)				//结束后的打印分数界面
{	GrContextFontSet(&sContext, g_pFontCmss48b);
	if(missnum<=notenumber/100 && perfectnum>=notenumber*94/100 && maxcombo>=notenumber*60/100)
	{	 
		GrContextForegroundSet(&sContext, ClrYellow);
		GrStringDrawCentered(&sContext, "S", -1,
    		GrContextDpyWidthGet(&sContext) / 2+70, 80, 0);	
	}
	else if(missnum<notenumber*3/100 && perfectnum>notenumber*90/100 && maxcombo> notenumber*30/100)
	{
		GrContextForegroundSet(&sContext, ClrGreen);
		GrStringDrawCentered(&sContext, "A", -1,
    		GrContextDpyWidthGet(&sContext) / 2+70, 80, 0);	
	}
	else if(missnum<notenumber*5/100 && perfectnum>notenumber*80/100)
	{
		GrContextForegroundSet(&sContext, ClrBlue);
		GrStringDrawCentered(&sContext, "B", -1,
    		GrContextDpyWidthGet(&sContext) / 2+70, 80, 0);	
	}
	else
	{
		 GrContextForegroundSet(&sContext, ClrRed);
		GrStringDrawCentered(&sContext, "C", -1,
    		GrContextDpyWidthGet(&sContext) / 2+70, 80, 0);
	}
}
