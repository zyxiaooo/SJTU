
#include <iostream>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv.hpp>
#include<stdio.h>
#include<cstring>
#include<cstdlib>
#include<map>
#include<cmath>

using namespace cv;
using namespace std;

template<class T> class Image { //simple template for image processing, surport image[i][j].
private:
	IplImage* imgp;
public:
	Image(IplImage* img = 0) { imgp = img; }
	~Image() { imgp = 0; }
	inline T* operator[](const int rowIndx) {
		return ((T *)(imgp->imageData + rowIndx*imgp->widthStep));
	}
};
typedef struct {
	unsigned char b, g, r;
} RgbPixel;
typedef Image<RgbPixel> RgbImage;
typedef Image<unsigned char> BwImage;

CvPoint2D32f ori[4];//trasformation
CvPoint2D32f ori2[4];//trasformation
CvMat* transmat = cvCreateMat(3, 3, CV_32FC1);//trasformation
CvMat* transmat2 = cvCreateMat(3, 3, CV_32FC1);//trasformation
CvMat* mergeTransmat = cvCreateMat(3, 3, CV_32FC1);
CvPoint2D32f newp[4];//trasformation
CvPoint2D32f newp2[4];//trasformation

int memmat[1000][1000];//member mat for players
int ballmat[1000][1000];//weighted matrix for ball
IplImage* pFrame = NULL;
IplImage* pFrImg = NULL;
IplImage* pBkImg = NULL;
IplImage* cpFrame = NULL;
IplImage* cpFrame2 = NULL;
IplImage *g_pGrayImage = NULL;
IplImage *g_pBinaryImage = NULL;
IplImage* diffImg = NULL;
IplImage* pFramenew = NULL;
CvMat* pFrameMat = NULL;
CvMat* pFrMat = NULL;
CvMat* pBkMat = NULL;
CvCapture* pCapture = NULL;
//for action prediction
int maxballx = 0;//location of current frame for ball
int maxbally = 0;
int maxballx1 = 0;//location of last frame
int maxbally1 = 0;
int maxballval = 0;
int counter = 0;//counter
int lostcounter = 0;//reset counter
//视频2的相关变量*************************************************************************
int memmat2[1000][1000];//几乎和视频一一样的变量
int ballmat2[1000][1000];
IplImage* pFrame2 = NULL;
IplImage* pFrImg2 = NULL;
IplImage* pBkImg2 = NULL;
IplImage* cpFrame21 = NULL;
IplImage* cpFrame22 = NULL;
IplImage *g_pGrayImage2 = NULL;
IplImage *g_pBinaryImage2 = NULL;
IplImage* diffImg2 = NULL;
IplImage* pFramenew2 = NULL;
CvMat* pFrameMat2 = NULL;
CvMat* pFrMat2 = NULL;
CvMat* pBkMat2 = NULL;
CvCapture* pCapture2 = NULL;
int maxballx2 = 0;
int maxbally2 = 0;
int maxballx12 = 0;
int maxbally12 = 0;
int maxballval2 = 0;
int counter2 = 0;
int lostcounter2 = 0;

int redRecord1[100][2];
int greenRecord1[100][2];
int redRecordLength1 = 0, greenRecordLength1 = 0;
int redRecord2[100][2];
int greenRecord2[100][2];
int redRecordLength2 = 0, greenRecordLength2 = 0;

IplImage* pFramenew3 = NULL;

bool isgreen(int i, int j, RgbImage matr)
{
	if (matr[i][j].r>155 && matr[i][j].r<230 && matr[i][j].g>190 && matr[i][j].g<255 && matr[i][j].b>100 && matr[i][j].b<195)return true;
	//if (matr[i][j].g - matr[i][j].r > 30 && matr[i][j].g - matr[i][j].b > 30)return true;
	else return false;
};
bool isred(int i, int j, RgbImage matr)
{
	if (matr[i][j].r>175 && matr[i][j].r<255 && matr[i][j].g>70 && matr[i][j].g<155 && matr[i][j].b>50 && matr[i][j].b<115)return true;
	else return false;
};
bool isball(int i, int j, RgbImage matr)
{
	if (matr[i][j].r>150 && matr[i][j].r<200 && matr[i][j].g>150 && matr[i][j].g<200 && matr[i][j].b>140 && matr[i][j].b<180)return true;
	else return false;
};
bool isblack(int i, int j, RgbImage matr)
{
	if (matr[i][j].r<9 && matr[i][j].g<9 && matr[i][j].b<9)return true;
	else return false;
};

bool isLightBlack(int i, int j, RgbImage matr)
{
	if (matr[i][j].r<70 && matr[i][j].g<70 && matr[i][j].b<70)return true;
	else return false;
};

bool blackBelowPeople(int i, int j, RgbImage matr)//i是列 j是行
{
	for (int x = max(j -3,0);x <= min(j+3,721);x++)//处理行
	{
		for (int y = min(i+2,576);y <= min(577,i+20);y++)//处理列
		{
			if (isLightBlack(y,x, matr)) return true;
		}
	}
	return false;
};

bool ispuregreen(int x, int y, RgbImage matr)
{
	if (matr[x][y].r == 0 && matr[x][y].g == 255 && matr[x][y].b == 0) return true;
	else return false;
};
bool ispurered(int x, int y, RgbImage matr)
{
	if (matr[x][y].r == 255 && matr[x][y].g == 0 && matr[x][y].b == 0) return true;
	else return false;
};
bool ispureblue(int x, int y, RgbImage matr)
{
	if (matr[x][y].r == 0 && matr[x][y].g == 0 && matr[x][y].b == 255) return true;
	else return false;
};
bool ispink(int x, int y, RgbImage matr)
{
	if (matr[x][y].r == 255 && matr[x][y].g == 0 && matr[x][y].b == 255) return true;
	else return false;
};
bool isindigo(int x, int y, RgbImage matr)
{
	if (matr[x][y].r == 0 && matr[x][y].g == 255 && matr[x][y].b == 255) return true;
	else return false;
};
bool isorange(int x, int y, RgbImage matr)
{
	if (matr[x][y].r == 255 && matr[x][y].g == 255 && matr[x][y].b == 0) return true;
	else return false;
};
void printsimbolblue(int i, int j, IplImage *origin)//画标识的函数
{
	RgbImage matr(origin);
	for (int x = i - 2;x <= i + 2 && x >= 0 && x<origin->height&& j >= 0 && j<origin->width;++x) { matr[x][j].r = 0; matr[x][j].g = 0; matr[x][j].b = 255; }
	for (int y = j - 2;y <= j + 2 && y >= 0 && y< origin->width&& i >= 0 && i<origin->height;++y) { matr[i][y].r = 0; matr[i][y].g = 0; matr[i][y].b = 255; }
};
void printsimbolpink(int i, int j, IplImage *origin)
{
	RgbImage matr(origin);
	for (int x = i - 2;x <= i + 2 && x >= 0 && x<origin->height&& j >= 0 && j<origin->width;++x) { matr[x][j].r = 255; matr[x][j].g = 0; matr[x][j].b = 255; }
	for (int y = j - 2;y <= j + 2 && y >= 0 && y< origin->width&& i >= 0 && i<origin->height;++y) { matr[i][y].r = 255; matr[i][y].g = 0; matr[i][y].b = 255; }
};
void printsimbolgreen(int i, int j, IplImage *origin)
{
	RgbImage matr(origin);
	for (int x = i - 2;x <= i + 2 && x >= 0 && x<origin->height && j >= 0 && j<origin->width;++x) { matr[x][j].r = 0; matr[x][j].g = 255; matr[x][j].b = 0; }
	for (int y = j - 2;y <= j + 2 && y >= 0 && y< origin->width && i >= 0 && i<origin->height;++y) { matr[i][y].r = 0; matr[i][y].g = 255; matr[i][y].b = 0; }
};
void printsimbolred(int i, int j, IplImage *origin)
{
	RgbImage matr(origin);
	for (int x = i - 2;x <= i + 2 && x >= 0 && x<origin->height&& j >= 0 && j<origin->width;++x) { matr[x][j].r = 255; matr[x][j].g = 0; matr[x][j].b = 0; }
	for (int y = j - 2;y <= j + 2 && y >= 0 && y< origin->width&& i >= 0 && i<origin->height;++y) { matr[i][y].r = 255; matr[i][y].g = 0; matr[i][y].b = 0; }
};
void resetpic(IplImage *origin)
{
	RgbImage matr(origin);
	for (int i = 0;i<origin->height;++i)
		for (int j = 0;j<origin->width;++j) { matr[i][j].r = 0;matr[i][j].g = 0;matr[i][j].b = 0; }
};
//=====================================================================================================================
//程序2代码
bool isLightBlack2(int i, int j,RgbImage matr)//几乎完和视频一全一样
{
	if (matr[i][j].r<80 && matr[i][j].g<80 && matr[i][j].b<80)return true;
	else return false;
}

bool isgreen2(int i, int j, RgbImage matr)
{
	if (matr[i][j].r>160 && matr[i][j].r<230 && matr[i][j].g>180 && matr[i][j].g<255 && matr[i][j].b>120 && matr[i][j].b<190)return true;
	else return false;
};
bool isred2(int i, int j, RgbImage matr)
{
	if (matr[i][j].r>140 && matr[i][j].r<210 && matr[i][j].g>70 && matr[i][j].g<135 && matr[i][j].b>80 && matr[i][j].b<140)return true;
	else return false;
};
bool isball2(int i, int j, RgbImage matr)
{
	if (matr[i][j].r>130 && matr[i][j].r<180 && matr[i][j].g>130 && matr[i][j].g<180 && matr[i][j].b>110 && matr[i][j].b<160)return true;
	else return false;
};
bool isblack2(int i, int j, RgbImage matr)
{
	if (matr[i][j].r<9 && matr[i][j].g<9 && matr[i][j].b<9)return true;
	else return false;
};
bool ispuregreen2(int x, int y, RgbImage matr)
{
	if (matr[x][y].r == 0 && matr[x][y].g == 255 && matr[x][y].b == 0) return true;
	else return false;
};
bool ispurered2(int x, int y, RgbImage matr)
{
	if (matr[x][y].r == 255 && matr[x][y].g == 0 && matr[x][y].b == 0) return true;
	else return false;
};
bool ispureblue2(int x, int y, RgbImage matr)
{
	if (matr[x][y].r == 0 && matr[x][y].g == 0 && matr[x][y].b == 255) return true;
	else return false;
};
bool ispink2(int x, int y, RgbImage matr)
{
	if (matr[x][y].r == 255 && matr[x][y].g == 0 && matr[x][y].b == 255) return true;
	else return false;
};
bool isindigo2(int x, int y, RgbImage matr)
{
	if (matr[x][y].r == 0 && matr[x][y].g == 255 && matr[x][y].b == 255) return true;
	else return false;
};
bool isorange2(int x, int y, RgbImage matr)
{
	if (matr[x][y].r == 255 && matr[x][y].g == 255 && matr[x][y].b == 0) return true;
	else return false;
};
void printsimbolblue2(int i, int j, IplImage *origin)
{
	RgbImage matr(origin);
	for (int x = i - 2;x <= i + 2 && x >= 0 && x<origin->height&& j >= 0 && j<origin->width;++x) { matr[x][j].r = 0; matr[x][j].g = 0; matr[x][j].b = 255; }
	for (int y = j - 2;y <= j + 2 && y >= 0 && y< origin->width&& i >= 0 && i<origin->height;++y) { matr[i][y].r = 0; matr[i][y].g = 0; matr[i][y].b = 255; }
};
void printsimbolpink2(int i, int j, IplImage *origin)
{
	RgbImage matr(origin);
	for (int x = i - 2;x <= i + 2 && x >= 0 && x<origin->height&& j >= 0 && j<origin->width;++x) { matr[x][j].r = 255; matr[x][j].g = 0; matr[x][j].b = 255; }
	for (int y = j - 2;y <= j + 2 && y >= 0 && y< origin->width&& i >= 0 && i<origin->height;++y) { matr[i][y].r = 255; matr[i][y].g = 0; matr[i][y].b = 255; }
};
void printsimbolgreen2(int i, int j, IplImage *origin)
{
	RgbImage matr(origin);
	for (int x = i - 2;x <= i + 2 && x >= 0 && x<origin->height && j >= 0 && j<origin->width;++x) { matr[x][j].r = 0; matr[x][j].g = 255; matr[x][j].b = 0; }
	for (int y = j - 2;y <= j + 2 && y >= 0 && y< origin->width && i >= 0 && i<origin->height;++y) { matr[i][y].r = 0; matr[i][y].g = 255; matr[i][y].b = 0; }
};
void printsimbolred2(int i, int j, IplImage *origin)
{
	RgbImage matr(origin);
	for (int x = i - 2;x <= i + 2 && x >= 0 && x<origin->height&& j >= 0 && j<origin->width;++x) { matr[x][j].r = 255; matr[x][j].g = 0; matr[x][j].b = 0; }
	for (int y = j - 2;y <= j + 2 && y >= 0 && y< origin->width&& i >= 0 && i<origin->height;++y) { matr[i][y].r = 255; matr[i][y].g = 0; matr[i][y].b = 0; }
};
void resetpic2(IplImage *origin)
{
	RgbImage matr(origin);
	for (int i = 0;i<origin->height;++i)
		for (int j = 0;j<origin->width;++j) { matr[i][j].r = 0;matr[i][j].g = 0;matr[i][j].b = 0; }
};
//=================================================================================================================
void drawfield(IplImage *origin)//draw field line
{
	RgbImage matr(origin);
	for (int i = 0;i<origin->height;++i) {
		matr[i][0].r = 255;matr[i][0].g = 255;matr[i][0].b = 255;
		matr[i][1].r = 255;matr[i][1].g = 255;matr[i][1].b = 255;
		matr[i][2].r = 255;matr[i][2].g = 255;matr[i][2].b = 255;
		matr[i][339].r = 255;matr[i][339].g = 255;matr[i][339].b = 255;
		matr[i][340].r = 255;matr[i][340].g = 255;matr[i][340].b = 255;
		matr[i][341].r = 255;matr[i][341].g = 255;matr[i][341].b = 255;
		matr[i][677].r = 255;matr[i][677].g = 255;matr[i][677].b = 255;
		matr[i][678].r = 255;matr[i][678].g = 255;matr[i][678].b = 255;
		matr[i][679].r = 255;matr[i][679].g = 255;matr[i][679].b = 255;
		if (i>149 && i<351)
		{
			matr[i][99].r = 255;matr[i][99].g = 255;matr[i][99].b = 255;
			matr[i][100].r = 255;matr[i][100].g = 255;matr[i][100].b = 255;
			matr[i][101].r = 255;matr[i][101].g = 255;matr[i][101].b = 255;
			matr[i][578].r = 255;matr[i][578].g = 255;matr[i][578].b = 255;
			matr[i][579].r = 255;matr[i][579].g = 255;matr[i][579].b = 255;
			matr[i][580].r = 255;matr[i][580].g = 255;matr[i][580].b = 255;
		}
		if (i>179 && i<321)
		{
			matr[i][59].r = 255;matr[i][59].g = 255;matr[i][59].b = 255;
			matr[i][60].r = 255;matr[i][60].g = 255;matr[i][60].b = 255;
			matr[i][61].r = 255;matr[i][61].g = 255;matr[i][61].b = 255;
			matr[i][618].r = 255;matr[i][618].g = 255;matr[i][618].b = 255;
			matr[i][619].r = 255;matr[i][619].g = 255;matr[i][619].b = 255;
			matr[i][620].r = 255;matr[i][620].g = 255;matr[i][620].b = 255;
		}
	}
	for (int j = 0;j<origin->width;++j) {
		matr[0][j].r = 255;matr[0][j].g = 255;matr[0][j].b = 255;
		matr[1][j].r = 255;matr[0][j].g = 255;matr[0][j].b = 255;
		matr[2][j].r = 255;matr[0][j].g = 255;matr[0][j].b = 255;
		matr[497][j].r = 255;matr[497][j].g = 255;matr[497][j].b = 255;
		matr[498][j].r = 255;matr[498][j].g = 255;matr[498][j].b = 255;
		matr[499][j].r = 255;matr[499][j].g = 255;matr[499][j].b = 255;
		if (j<100 || j>579)
		{
			matr[149][j].r = 255;matr[149][j].g = 255;matr[149][j].b = 255;
			matr[150][j].r = 255;matr[150][j].g = 255;matr[150][j].b = 255;
			matr[151][j].r = 255;matr[151][j].g = 255;matr[151][j].b = 255;
			matr[349][j].r = 255;matr[349][j].g = 255;matr[349][j].b = 255;
			matr[350][j].r = 255;matr[350][j].g = 255;matr[350][j].b = 255;
			matr[351][j].r = 255;matr[351][j].g = 255;matr[351][j].b = 255;
		}
		if (j<60 || j>619)
		{
			matr[179][j].r = 255;matr[179][j].g = 255;matr[179][j].b = 255;
			matr[180][j].r = 255;matr[180][j].g = 255;matr[180][j].b = 255;
			matr[181][j].r = 255;matr[181][j].g = 255;matr[181][j].b = 255;
			matr[319][j].r = 255;matr[319][j].g = 255;matr[319][j].b = 255;
			matr[320][j].r = 255;matr[320][j].g = 255;matr[320][j].b = 255;
			matr[321][j].r = 255;matr[321][j].g = 255;matr[321][j].b = 255;
		}
	}
};

void transpoint(CvMat *transmat, float x, float y, int &resx, int &resy)//transformation
{
	float point1[] = { x,y,1 };
	CvMat mat1 = cvMat(3, 1, CV_32FC1, point1);
	CvMat *mat1ptr = &mat1;
	CvMat *resmat = cvCreateMat(3, 1, CV_32FC1);
	cvMatMul(transmat, mat1ptr, resmat);
	resx = cvmGet(resmat, 0, 0) / cvmGet(resmat, 2, 0);
	resy = cvmGet(resmat, 1, 0) / cvmGet(resmat, 2, 0);
	cvReleaseMat(&mat1ptr);
	cvReleaseMat(&resmat);
};

void transpic(CvMat *transmat, IplImage *origin, IplImage *aftertrans)//transform a whole pic
{
	resetpic(aftertrans);
	drawfield(aftertrans);

	redRecordLength1 = 0;
	greenRecordLength1 = 0;

	for (int i = 0;i<origin->height;++i)
		for (int j = 0;j<origin->width;++j)
		{
			//forward窗口画点
			//画绿色的点
			if (ispuregreen(i, j, origin)) {
				int tmpx, tmpy;
				if (i + 14<origin->height) {
					transpoint(transmat, j, i + 14, tmpx, tmpy);
					greenRecord1[greenRecordLength1][0] = tmpx;
					greenRecord1[greenRecordLength1][1] = tmpy;
					greenRecordLength1++;
					Point center = Point(tmpx, tmpy);
					int r = 8;
					//printsimbolgreen(tmpy, tmpx, aftertrans);

					cvCircle(aftertrans, center, r, Scalar(0, 255, 0),6);
				}
			}
			//画红色的点
			else if (ispurered(i, j, origin)) {
				int tmpx, tmpy;
				if (i + 14<origin->height) {
					transpoint(transmat, j, i + 14, tmpx, tmpy);
					redRecord1[redRecordLength1][0] = tmpx;
					redRecord1[redRecordLength1][1] = tmpy;
					redRecordLength1++;
					Point center = Point(tmpx, tmpy);
					int r = 8;
					cvCircle(aftertrans, center, r, Scalar(0, 0, 255), 6);
				}
			}
		}

};
//============================================================================================================
//程序2代码2

void drawfield2(IplImage *origin)//和视频一完全一样
{
	RgbImage matr(origin);
	for (int i = 0;i<origin->height;++i) {
		matr[i][0].r = 255;matr[i][0].g = 255;matr[i][0].b = 255;
		matr[i][1].r = 255;matr[i][1].g = 255;matr[i][1].b = 255;
		matr[i][2].r = 255;matr[i][2].g = 255;matr[i][2].b = 255;
		matr[i][339].r = 255;matr[i][339].g = 255;matr[i][339].b = 255;
		matr[i][340].r = 255;matr[i][340].g = 255;matr[i][340].b = 255;
		matr[i][341].r = 255;matr[i][341].g = 255;matr[i][341].b = 255;
		matr[i][677].r = 255;matr[i][677].g = 255;matr[i][677].b = 255;
		matr[i][678].r = 255;matr[i][678].g = 255;matr[i][678].b = 255;
		matr[i][679].r = 255;matr[i][679].g = 255;matr[i][679].b = 255;
		if (i>149 && i<351)
		{
			matr[i][99].r = 255;matr[i][99].g = 255;matr[i][99].b = 255;
			matr[i][100].r = 255;matr[i][100].g = 255;matr[i][100].b = 255;
			matr[i][101].r = 255;matr[i][101].g = 255;matr[i][101].b = 255;
			matr[i][578].r = 255;matr[i][578].g = 255;matr[i][578].b = 255;
			matr[i][579].r = 255;matr[i][579].g = 255;matr[i][579].b = 255;
			matr[i][580].r = 255;matr[i][580].g = 255;matr[i][580].b = 255;
		}
		if (i>179 && i<321)
		{
			matr[i][59].r = 255;matr[i][59].g = 255;matr[i][59].b = 255;
			matr[i][60].r = 255;matr[i][60].g = 255;matr[i][60].b = 255;
			matr[i][61].r = 255;matr[i][61].g = 255;matr[i][61].b = 255;
			matr[i][618].r = 255;matr[i][618].g = 255;matr[i][618].b = 255;
			matr[i][619].r = 255;matr[i][619].g = 255;matr[i][619].b = 255;
			matr[i][620].r = 255;matr[i][620].g = 255;matr[i][620].b = 255;
		}
	}
	for (int j = 0;j<origin->width;++j) {
		matr[0][j].r = 255;matr[0][j].g = 255;matr[0][j].b = 255;
		matr[1][j].r = 255;matr[0][j].g = 255;matr[0][j].b = 255;
		matr[2][j].r = 255;matr[0][j].g = 255;matr[0][j].b = 255;
		matr[497][j].r = 255;matr[497][j].g = 255;matr[497][j].b = 255;
		matr[498][j].r = 255;matr[498][j].g = 255;matr[498][j].b = 255;
		matr[499][j].r = 255;matr[499][j].g = 255;matr[499][j].b = 255;
		if (j<100 || j>579)
		{
			matr[149][j].r = 255;matr[149][j].g = 255;matr[149][j].b = 255;
			matr[150][j].r = 255;matr[150][j].g = 255;matr[150][j].b = 255;
			matr[151][j].r = 255;matr[151][j].g = 255;matr[151][j].b = 255;
			matr[349][j].r = 255;matr[349][j].g = 255;matr[349][j].b = 255;
			matr[350][j].r = 255;matr[350][j].g = 255;matr[350][j].b = 255;
			matr[351][j].r = 255;matr[351][j].g = 255;matr[351][j].b = 255;
		}
		if (j<60 || j>619)
		{
			matr[179][j].r = 255;matr[179][j].g = 255;matr[179][j].b = 255;
			matr[180][j].r = 255;matr[180][j].g = 255;matr[180][j].b = 255;
			matr[181][j].r = 255;matr[181][j].g = 255;matr[181][j].b = 255;
			matr[319][j].r = 255;matr[319][j].g = 255;matr[319][j].b = 255;
			matr[320][j].r = 255;matr[320][j].g = 255;matr[320][j].b = 255;
			matr[321][j].r = 255;matr[321][j].g = 255;matr[321][j].b = 255;
		}
	}
};

void transpoint2(CvMat *transmat, float x, float y, int &resx, int &resy)
{
	float point1[] = { x,y,1 };
	CvMat mat1 = cvMat(3, 1, CV_32FC1, point1);
	CvMat *mat1ptr = &mat1;
	CvMat *resmat = cvCreateMat(3, 1, CV_32FC1);
	cvMatMul(transmat, mat1ptr, resmat);
	resx = cvmGet(resmat, 0, 0) / cvmGet(resmat, 2, 0);
	resy = cvmGet(resmat, 1, 0) / cvmGet(resmat, 2, 0);
	cvReleaseMat(&mat1ptr);
	cvReleaseMat(&resmat);
};

void transpic2(CvMat *transmat, IplImage *origin, IplImage *aftertrans)
{
	resetpic(aftertrans);
	drawfield(aftertrans);
	greenRecordLength2 = 0;
	redRecordLength2 = 0;
    resetpic(pFramenew3);
	for (int i = 0;i<origin->height;++i)
		for (int j = 0;j<origin->width;++j)
		{
			//forward窗口画点
			//画绿色的点
			if (ispuregreen(i, j, origin)) {
				int tmpx, tmpy;
				if (i + 14<origin->height) {
					transpoint(transmat, j, i + 14, tmpx, tmpy);
					greenRecord2[greenRecordLength2][0] = tmpx;
					greenRecord2[greenRecordLength2][1] = tmpy;
					greenRecordLength2++;
					Point center = Point(680-tmpx, 500-tmpy);
					int r = 8;
					//printsimbolgreen(tmpy, tmpx, aftertrans);

					cvCircle(aftertrans, center, r, Scalar(0, 255, 0), 6);
				}
			}
			//画红色的点
			else if (ispurered(i, j, origin)) {
				int tmpx, tmpy;
				if (i + 14<origin->height) {
					transpoint(transmat, j, i + 14, tmpx, tmpy);

					redRecord2[redRecordLength2][0] = tmpx;
					redRecord2[redRecordLength2][1] = tmpy;
					redRecordLength2++;
					Point center = Point(720 - tmpx, 476 - tmpy);
					int r = 8;
					//printsimbolred(tmpy, tmpx, aftertrans);

					cvCircle(aftertrans, center, r, Scalar(0, 0, 255), 6);
				}
			}
            else if (ispink(i, j, origin)) {
				int tmpx, tmpy;
				if (i<origin->height) {
					transpoint(transmat, j, i, tmpx, tmpy);
					Point center = Point(720 - tmpx, 476 - tmpy);
					int r = 3;

					cvCircle(aftertrans, center, r, Scalar(255, 255, 255), 3);

					cvCircle(pFramenew3, center, r, Scalar(255, 255, 255), 3);

				}
			}
		}

};
//============================================================================================================
void filtcolor(IplImage *origin, IplImage *diffImg, IplImage *cporigin, IplImage *cporigin2)//main processing function
{
	bool traceball = false;
	RgbImage matr(origin);
	RgbImage matr2(diffImg);
	resetpic(cporigin);
	RgbImage matr3(cporigin);
	RgbImage matr4(cporigin2);
	for (int i = 0;i<origin->height;++i)
		for (int j = 0;j<origin->width;++j)
		{
			if (i <= -0.127*(j - 14) + 170 || i >= (j - 14)*0.887 + 170 || i >= -0.864*(j - 421) + 529 || i <= 0.231*(j - 464) + 112) {
				//matr[i][j].r=0;matr[i][j].g=0;matr[i][j].b=0;
				continue;
			}

			else {
				//
				if (isgreen(i, j, matr) || isball(i, j, matr)) {//绿球员和球
					bool ispeople = false;
					int tmppix = 0;
					//  int tmpdifpix=0;
					for (int x = i - 2;x <= i + 14 && x >= 0 && x < origin->height;++x)
					{
						for (int y = j - 2;y <= j + 3 && y >= 0 && y < origin->width;++y)
						{
							if (isgreen(x, y, matr) || ispuregreen(x, y, matr))++tmppix;
							// if(!isblack(x,y,matr2))++tmpdifpix;
						}
					}
					//判断是个绿人
					if (tmppix >= 5
						&& blackBelowPeople(i,j,matr)//裤子是黑的
						&& j<700 && j > 20 && i < 520 && i > 40 //边上的去掉
						) {

						matr3[i][j].r = 0; matr3[i][j].g = 255; matr3[i][j].b = 0;//0 255 0
						memmat[i][j] = -1;
						for (int x = i - 4;x <= i + 4;++x)
							for (int y = j - 4;y <= j + 4;++y) {
								if (memmat[x][y] == 1)memmat[x][y] = 0;
							}
						for (int x = i - 2;x <= i + 14 && x >= 0 && x<origin->height;++x)
							for (int y = j - 2;y <= j + 3 && y >= 0 && y< origin->width;++y)
							{
								matr[x][y].r = 0; matr[x][y].g = 255; matr[x][y].b = 255;//0 255 255
							}
						ispeople = true;
					}

					if (ispeople == false) {
						int tmpdifpix = 0;
						for (int x = i - 2;x <= i + 2 && x >= 0 && x<origin->height;++x)
							for (int y = j - 2;y <= j + 2 && y >= 0 && y< origin->width;++y)
							{//if(isgreen(x,y,matr) || ispuregreen(x,y,matr))++tmppix;
								if (!isblack(x, y, matr2))++tmpdifpix;
							}
						if (tmpdifpix>5) {
							//position[pair<int,int>(i,j)]=3;
							matr3[i][j].r = 0; matr3[i][j].g = 0; matr3[i][j].b = 255;
							for (int x = i - 2;x <= i + 2 && x >= 0 && x<origin->height;++x)
								for (int y = j - 2;y <= j + 2 && y >= 0 && y< origin->width;++y)
								{
									matr[x][y].r = 0; matr[x][y].g = 0; matr[x][y].b = 255;
								}
						}
					}
				}

				//判断是红人
				else if (isred(i, j, matr)) {
					int tmppix = 0;


					for (int x = i - 2;x <= i + 14 && x >= 0 && x<origin->height;++x)
						for (int y = j - 2;y <= j + 2 && y >= 0 && y< origin->width;++y)
						{
							if (isred(x, y, matr) || ispurered(x, y, matr))++tmppix;
							//if(!isblack(x,y,matr2))++tmpdifpix;
						}
					if (tmppix >= 6) {
						matr3[i][j].r = 255; matr3[i][j].g = 0; matr3[i][j].b = 0;
						memmat[i][j] = -2;
						for (int x = i - 4;x <= i + 4;++x)
							for (int y = j - 4;y <= j + 4;++y) {
								if (memmat[x][y] == 2)memmat[x][y] = 0;
							}
						matr3[i][j].r = 255; matr3[i][j].g = 0; matr3[i][j].b = 0;
						for (int x = i - 2;x <= i + 14 && x >= 0 && x<origin->height;++x)
							for (int y = j - 2;y <= j + 3 && y >= 0 && y< origin->width;++y)
							{
								matr[x][y].r = 255; matr[x][y].g = 255; matr[x][y].b = 0;
							}
					}

				}
				//else {matr[i][j].r=0;matr[i][j].g=0;matr[i][j].b=0;}
			}
		}


	for (int i = 0;i<origin->height;++i)//member matrix for missed player
		for (int j = 0;j<origin->width;++j) {
			if (memmat[i][j] == -1)memmat[i][j] = 1;
			else if (memmat[i][j] == 1) {
				memmat[i][j] = 0;
				int maxx = 0;
				int maxy = 0;
				int maxpix = 0;
				for (int x = i - 4;x <= i + 4 && x >= 0 && x<origin->height;++x) {
					for (int y = j - 4;y <= j + 4 && y >= 0 && y< origin->width;++y) {

						int tmppix = 0;
						int tmpdiff = 0;


						for (int z = x - 1;z <= x + 14 && z >= 0 && z<origin->height;++z)
							for (int w = y - 1;w <= y + 1 && w >= 0 && w< origin->width;++w) {
								if (isgreen(z, w, matr) || ispuregreen(z, w, matr) || ispureblue(z, w, matr) || isball(z, w, matr))++tmppix;
								if (!isblack(z, w, matr2))++tmpdiff;
							}
						if (maxpix<tmppix + tmpdiff) { maxpix = tmppix + tmpdiff; maxx = x;maxy = y; }

					}
				};
				if (maxpix>25) {
					for (int x = i - 2;x <= i + 14 && x >= 0 && x<origin->height;++x)
						for (int y = j - 2;y <= j + 3 && y >= 0 && y< origin->width;++y)
						{
							matr[x][y].r = 0; matr[x][y].g = 255; matr[x][y].b = 255;
						}

					memmat[maxx][maxy] = 1;if (maxx>i || (maxx == i && maxy>j))memmat[maxx][maxy] = -1;
					matr3[maxx][maxy].r = 0; matr3[maxx][maxy].g = 255; matr3[maxx][maxy].b = 0;
				}
			}
			else if (memmat[i][j] == -2)memmat[i][j] = 2;
			else if (memmat[i][j] == 2) {

				memmat[i][j] = 0;
				int maxx = 0;
				int maxy = 0;
				int maxpix1 = 0;
				int maxpix2 = 0;
				for (int x = i - 4;x <= i + 4 && x >= 0 && x<origin->height;++x) {
					for (int y = j - 4;y <= j + 4 && y >= 0 && y< origin->width;++y) {

						int tmppix = 0;
						int tmpdiff = 0;


						for (int z = x - 2;z <= x + 14 && z >= 0 && z<origin->height;++z)
							for (int w = y - 2;w <= y + 2 && w >= 0 && w< origin->width;++w) {
								if (isred(z, w, matr) || ispurered(z, w, matr))++tmppix;
								if (!isblack(z, w, matr2))++tmpdiff;
							}
						if (maxpix1<tmppix) { maxpix1 = tmppix;maxpix2 = tmpdiff; maxx = x;maxy = y; }
						else if (maxpix1 == tmppix && maxpix2<tmpdiff) { maxpix2 = tmpdiff;maxx = x;maxy = y; }
					}
				};
				if (maxpix1>0 && maxpix2>10) {
					for (int x = i - 2;x <= i + 14 && x >= 0 && x<origin->height;++x)
						for (int y = j - 2;y <= j + 3 && y >= 0 && y< origin->width;++y)
						{
							matr[x][y].r = 255; matr[x][y].g = 255; matr[x][y].b = 0;
						}

					memmat[maxx][maxy] = 2;if (maxx>i || (maxx == i && maxy>j))memmat[maxx][maxy] = -2;
					matr3[maxx][maxy].r = 255; matr3[maxx][maxy].g = 0; matr3[maxx][maxy].b = 0;
				}
			}//以下是权值矩阵用来跟踪球，在视频一没有用到
/*
			else if (ispureblue(i, j, matr3)) {
				int tmpval = 10;

				for (int x = i - 5;x <= i + 5 && x >= 0 && x<origin->height;++x)
					for (int y = j - 5;y <= j + 5 && y >= 0 && y< origin->width;++y) {
						if (ballmat[x][y] != 0) {
							if (tmpval<ballmat[x][y]) { tmpval = ballmat[x][y]; }
							if (x == maxballx && y == maxbally) { tmpval += counter;++counter;traceball = true; }
							if (x != i || y != j)ballmat[x][y] = 0;
						}
					}
				ballmat[i][j] = tmpval + 3;

				for (int x = i - 15;x <= i + 3 && x >= 0 && x<origin->height;++x)
					for (int y = j - 1;y <= j + 1 && y >= 0 && y< origin->width;++y) {
						if (isindigo(x, y, matr))ballmat[i][j] -= 2;
						else if (isorange(x, y, matr))ballmat[i][j] -= 2;
						else if (ispureblue(x, y, matr3))ballmat[i][j] -= 4;
					}

			}*/

		}
	/*
	if (traceball == true) { ++counter;lostcounter = 0; }
	else if (traceball == false) { counter = 1;++lostcounter; }
	if (lostcounter>10) {
		lostcounter = 0;
		for (int i = 0;i<origin->height;++i)
			for (int j = 0;j<origin->width;++j)ballmat[i][j] = 0;
		return;
	}
	for (int i = 0;i<origin->height;++i)
		for (int j = 0;j<origin->width;++j)if (ballmat[i][j] >= 1)--ballmat[i][j];
	maxballval = 0;
	for (int i = 0;i<origin->height;++i)
		for (int j = 0;j<origin->width;++j) {
			if (maxballval<ballmat[i][j]) {
				maxballval = ballmat[i][j];
				maxballx = i;maxbally = j;
			}
		}
	if (abs(maxballx1 - maxballx) + abs(maxbally1 - maxbally)>6 && abs(maxballx1 - maxballx) + abs(maxbally1 - maxbally)<10 && traceball == true) {
		maxballx += (maxballx - maxballx1);
		maxballx1 = (maxballx + maxballx1) / 2;
		maxbally += (maxbally - maxbally1);
		maxbally1 = (maxbally + maxbally1) / 2;
	}
	else {
		maxballx1 = maxballx;
		maxbally1 = maxbally;
	}
	if (counter >= 2) {
		matr3[maxballx1][maxbally1].r = 255;matr3[maxballx1][maxbally1].g = 0;matr3[maxballx1][maxbally1].b = 255;
		for (int x = maxballx1 - 2;x <= maxballx1 + 2 && x >= 0 && x<origin->height;++x)
			for (int y = maxbally1 - 2;y <= maxbally1 + 2 && y >= 0 && y< origin->width;++y)
			{
				matr[x][y].r = 255; matr[x][y].g = 0; matr[x][y].b = 255;
			}
	}*/
	for(int i=0;i<origin->height;++i)//画标志
        for(int j=0;j<origin->width;++j){
            if(ispuregreen2(i,j,matr3))printsimbolgreen2(i+14,j,cporigin2);
            else if(ispurered2(i,j,matr3))printsimbolred2(i+14,j,cporigin2);

        }
};
//=======================================================================================
//程序2代码3
void filtcolor2(IplImage *origin, IplImage *diffImg, IplImage *cporigin, IplImage *cporigin2)
{//和程序1差不多，但是最后用权值矩阵识别球
    bool traceball=false;
    RgbImage matr(origin);
    RgbImage matr2(diffImg);
    resetpic(cporigin);
    RgbImage matr3(cporigin);
    RgbImage matr4(cporigin2);
    for(int i=0;i<origin->height;++i)
        for(int j=0;j<origin->width;++j)
    {
        if(i>=0.494*(j-6)+356 || i>=(j-650)*-0.6873+340 || i<=0.1051*(j-435)+233 || i<=-0.1584*(j-151)+263){
                matr[i][j].r=0;matr[i][j].g=0;matr[i][j].b=0;
                continue;
        }
        /*
        four vertices: -71.38, 94
                        23.35, 530.974
                        814.28, 193.2
                        273.02,72.77
       */
        //else
            {
            if(isgreen2(i,j,matr) || isball2(i,j,matr)){
                    bool ispeople=false;
                    int tmppix=0;
                  //  int tmpdifpix=0;
                    for(int x=i-2;x<=i+14 && x>=0 && x<origin->height;++x)
                    for(int y=j-2;y<=j+3 && y>=0 && y< origin->width;++y)
                    {if(isgreen2(x,y,matr) || ispuregreen2(x,y,matr))++tmppix;
                       // if(!isblack(x,y,matr2))++tmpdifpix;
                    }
                    if(tmppix>=10){
                        matr3[i][j].r=0; matr3[i][j].g=255; matr3[i][j].b=0;
                        memmat2[i][j]=-1;
                        for(int x=i-4;x<=i+4;++x)
                        for(int y=j-4;y<=j+4;++y){
                            if( memmat2[x][y]==1)memmat2[x][y]=0;
                        }
                        for(int x=i-2;x<=i+14 && x>=0 && x<origin->height;++x)
                        for(int y=j-2;y<=j+3 && y>=0 && y< origin->width;++y)
                        {matr[x][y].r=0; matr[x][y].g=255; matr[x][y].b=255;}
                        ispeople=true;}

                    if(ispeople==false){
                            int tmpdifpix=0;
                            for(int x=i-2;x<=i+2 && x>=0 && x<origin->height;++x)
                            for(int y=j-2;y<=j+2 && y>=0 && y< origin->width;++y)
                            {//if(isgreen(x,y,matr) || ispuregreen(x,y,matr))++tmppix;
                             if(!isblack(x,y,matr2))++tmpdifpix;
                             }
                            if(tmpdifpix>5){
                                //position[pair<int,int>(i,j)]=3;
                                matr3[i][j].r=0; matr3[i][j].g=0; matr3[i][j].b=255;
                                for(int x=i-2;x<=i+2 && x>=0 && x<origin->height;++x)
                                for(int y=j-2;y<=j+2 && y>=0 && y< origin->width;++y)
                                {matr[x][y].r=0; matr[x][y].g=0; matr[x][y].b=255;}
                            }
                    }
            }
            else if (isred2(i,j,matr)){
                    int tmppix=0;


                            for(int x=i-2;x<=i+14 && x>=0 && x<origin->height;++x)
                            for(int y=j-2;y<=j+2 && y>=0 && y< origin->width;++y)
                            {if (isred2(x,y,matr) || ispurered2(x,y,matr))++tmppix;
                            //if(!isblack(x,y,matr2))++tmpdifpix;
                            }
                    if(tmppix>=10){
                        matr3[i][j].r=255; matr3[i][j].g=0; matr3[i][j].b=0;
                        memmat2[i][j]=-2;
                        for(int x=i-4;x<=i+4;++x)
                        for(int y=j-4;y<=j+4;++y){
                            if(memmat2[x][y]==2)memmat2[x][y]=0;
                        }
                            matr3[i][j].r=255; matr3[i][j].g=0; matr3[i][j].b=0;
                            for(int x=i-2;x<=i+14 && x>=0 && x<origin->height;++x)
                            for(int y=j-2;y<=j+3 && y>=0 && y< origin->width;++y)
                            {matr[x][y].r=255; matr[x][y].g=255; matr[x][y].b=0;}
                        }

            }
            //else {matr[i][j].r=0;matr[i][j].g=0;matr[i][j].b=0;}
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////////////
    //******************************************************************************************//


    for(int i=0;i<origin->height;++i)
        for(int j=0;j<origin->width;++j){
            if(memmat2[i][j]==-1)memmat2[i][j]=1;
            else if(memmat2[i][j]==1){
                memmat2[i][j]=0;
                int maxx=0;
                int maxy=0;
                int maxpix=0;
                for(int x=i-4;x<=i+4 && x>=0 && x<origin->height;++x){
                for(int y=j-4;y<=j+4 && y>=0 && y< origin->width;++y){

                    int tmppix=0;
                    int tmpdiff=0;


                    for(int z=x-1;z<=x+14 && z>=0 && z<origin->height;++z)
                    for(int w=y-1;w<=y+1 && w>=0 && w< origin->width;++w){
                        if(isgreen2(z,w,matr) || ispuregreen2(z,w,matr) || ispureblue2(z,w,matr)||isball2(z,w,matr))++tmppix;
                        if(!isblack2(z,w,matr2))++tmpdiff;
                    }
                    if(maxpix<tmppix+tmpdiff){maxpix=tmppix+tmpdiff; maxx=x;maxy=y;}

                }};
                if(maxpix>10){
                    for(int x=maxx-2;x<=maxx+14 && x>=0 && x<origin->height;++x)
                        for(int y=maxy-2;y<=maxy+3 && y>=0 && y< origin->width;++y)
                        {matr[x][y].r=0; matr[x][y].g=255; matr[x][y].b=255;}

                memmat2[maxx][maxy]=1;if(maxx>i || (maxx==i && maxy>j))memmat2[maxx][maxy]=-1;
                matr3[maxx][maxy].r=0; matr3[maxx][maxy].g=255; matr3[maxx][maxy].b=0;
                }
            }
            else if(memmat2[i][j]==-2)memmat2[i][j]=2;
            else if(memmat2[i][j]==2){

                memmat2[i][j]=0;
                int maxx=0;
                int maxy=0;
                int maxpix1=0;
                int maxpix2=0;
                for(int x=i-4;x<=i+4 && x>=0 && x<origin->height;++x){
                for(int y=j-4;y<=j+4 && y>=0 && y< origin->width;++y){

                    int tmppix=0;
                    int tmpdiff=0;


                    for(int z=x-2;z<=x+14 && z>=0 && z<origin->height;++z)
                    for(int w=y-2;w<=y+2 && w>=0 && w< origin->width;++w){
                        if(isred2(z,w,matr) || ispurered2(z,w,matr))++tmppix;
                        if(!isblack2(z,w,matr2))++tmpdiff;
                    }
                    if(maxpix1<tmppix){maxpix1=tmppix;maxpix2=tmpdiff; maxx=x;maxy=y;}
                    else if(maxpix1==tmppix && maxpix2<tmpdiff){maxpix2=tmpdiff;maxx=x;maxy=y;}

                }};
                if(maxpix1+maxpix2>10){
                    for(int x=maxx-2;x<=maxx+14 && x>=0 && x<origin->height;++x)
                        for(int y=maxy-2;y<=maxy+3 && y>=0 && y< origin->width;++y)
                        {matr[x][y].r=255; matr[x][y].g=255; matr[x][y].b=0;}

                memmat2[maxx][maxy]=2;if(maxx>i || (maxx==i && maxy>j))memmat2[maxx][maxy]=-2;
                matr3[maxx][maxy].r=255; matr3[maxx][maxy].g=0; matr3[maxx][maxy].b=0;
                }
            }
        ///////////////////////////////////////////////////////////////////////////////////////////////
            else if(ispureblue(i,j,matr3)){//update weighted matrix for recognizing ball
                int tmpval=10;
                /*for(int x=i-4;x<=i+4 && x>=0 && x<origin->height;++x)
                for(int y=j-4;y<=j+4 && y>=0 && y< origin->width;++y){
                    if(ispureblue(x,y,matr3) && (x!=i || y!=j)){matr3[x][y].r=0;matr3[x][y].g=0;matr3[x][y].b=0;ballmat[i][j]-=4;}
                }*/
                for(int x=i-5;x<=i+5 && x>=0 && x<origin->height;++x)
                for(int y=j-5;y<=j+5 && y>=0 && y< origin->width;++y){
                    if(ballmat2[x][y]!=0){
                        if(tmpval<ballmat2[x][y]){tmpval=ballmat2[x][y];}
                        if(x==maxballx2 && y==maxbally2){tmpval+=counter2;++counter2;traceball=true;}//跟踪到了球体
                        if(x!=i || y!=j)ballmat2[x][y]=0;//周围清零
                    }
                }
                ballmat2[i][j]=tmpval+3;

                for(int x=i-15;x<=i+3 && x>=0 && x<origin->height;++x)
                for(int y=j-1;y<=j+1 && y>=0 && y< origin->width;++y){//调整权值
                    if(isindigo2(x,y,matr))ballmat2[i][j]-=2;
                    else if(isorange2(x,y,matr))ballmat2[i][j]-=2;
                    else if(ispureblue2(x,y,matr3))ballmat2[i][j]-=4;
                }

            }

        }
        //////////////////////////////////////////////////////////////////////////////////////////////////
        if(traceball==true){++counter2;lostcounter2=0;}
        else if(traceball==false){counter2=1;++lostcounter2;}
        if(lostcounter2>10){//误识别率过高则置零
            lostcounter2=0;
            for(int i=0;i<origin->height;++i)
            for(int j=0;j<origin->width;++j)ballmat2[i][j]=0;
            return;
        }
        for(int i=0;i<origin->height;++i)
        for(int j=0;j<origin->width;++j)if(ballmat2[i][j]>=1)--ballmat2[i][j];
        maxballval2=0;
        for(int i=0;i<origin->height;++i)
        for(int j=0;j<origin->width;++j){
            if(ispuregreen2(i,j,matr3))printsimbolgreen2(i+14,j,cporigin2);
            else if(ispurered2(i,j,matr3))printsimbolred2(i+14,j,cporigin2);
            if(maxballval2<ballmat2[i][j]){
                maxballval2=ballmat2[i][j];
                maxballx2=i;maxbally2=j;
            }
        }
        if(abs(maxballx12-maxballx2)+abs(maxbally12-maxbally2)>6 &&abs(maxballx12-maxballx2)+abs(maxbally12-maxbally2)<10 && traceball==true){
            maxballx2+=(maxballx2-maxballx12);//action prediction
            maxballx12=(maxballx2+maxballx12)/2;
            maxbally2+=(maxbally2-maxbally12);
            maxbally12=(maxbally2+maxbally12)/2;
        }
        else {
            maxballx12=maxballx2;
            maxbally12=maxbally2;
        }
        if(counter2>=2){matr3[maxballx12][maxbally12].r=255;matr3[maxballx12][maxbally12].g=0;matr3[maxballx12][maxbally12].b=255;
        printsimbolblue2(maxballx12,maxbally12,cporigin2);}
};

//==================================================================================================

bool noPointNearby(int x, int y, int list[][2], int length)//融合两个视频所用函数
{
	for (int i = 0; i < length; i++)
	{
		if (pow((list[i][0] - x), 2) + pow((list[i][1] - y), 2) < 5000)
			return false;
	}
	return true;
};

bool noPointInVerySmallRange(int x, int y, int list[][2], int length)
{
	for (int i = 0; i < length; i++)
	{
		if (pow((list[i][0] - x), 2) + pow((list[i][1] - y), 2) < 800)
			return false;
	}
	return true;
};

void MergeVideo(CvMat *transmat, IplImage *aftertrans)//融合主函数
{

	drawfield(aftertrans);
	int tmpx, tmpy;
	int tmpRecord1[100][2], tmpRecord2[100][2];
	int tmpLength1 = 0, tmpLength2 = 0;
	int tmpGreen[100][2];
	int tmpRed[100][2];
	int length1 = 0, length2 = 0;
	for (int i = 0; i < greenRecordLength1;i++)
	{

		tmpx = greenRecord1[i][0];
		tmpy = greenRecord1[i][1];
		if (noPointInVerySmallRange(tmpx, tmpy, tmpGreen, length1) && tmpx >15 && tmpx < 665 && tmpy > 15 && tmpy < 485)
		{
			tmpRecord1[tmpLength1][0] = tmpx;
			tmpRecord1[tmpLength1][1] = tmpy;
			tmpLength1++;
			tmpGreen[length1][0] = tmpx;
			tmpGreen[length1][1] = tmpy;
			length1++;
			Point center = Point(tmpx, tmpy);
			int r = 8;
			cvCircle(aftertrans, center, r, Scalar(0, 255, 0), 12);
		}

	}
	for (int i = 0; i < redRecordLength1;i++)
	{
		tmpx = redRecord1[i][0];
		tmpy = redRecord1[i][1];
		if (noPointInVerySmallRange(tmpx, tmpy, tmpRed, length2) && tmpx >15 && tmpx < 665 && tmpy > 15 && tmpy < 485)
		{
			tmpRecord2[tmpLength2][0] = tmpx;
			tmpRecord2[tmpLength2][1] = tmpy;
			tmpLength2++;
			tmpRed[length2][0] = tmpx;
			tmpRed[length2][1] = tmpy;
			length2++;
			Point center = Point(tmpx, tmpy);
			int r = 8;
			cvCircle(aftertrans, center, r, Scalar(0, 0, 255), 12);
		}
	}
	for (int i = 0; i < greenRecordLength2;i++)
	{
		tmpx = 680-greenRecord2[i][0];
		tmpy = 500-greenRecord2[i][1];
		if (noPointInVerySmallRange(tmpx, tmpy, tmpGreen, length1) && tmpx >15 && tmpx < 665 && tmpy > 15 && tmpy < 485)
		{
			if (noPointNearby(tmpx, tmpy, tmpRecord1, tmpLength1))
			{
				tmpGreen[length1][0] = tmpx;
				tmpGreen[length1][1] = tmpy;
				length1++;
				Point center = Point(tmpx,tmpy);
				int r = 8;
				cvCircle(aftertrans, center, r, Scalar(0, 255, 0), 12);
			}
		}
	}
	for (int i = 0; i < redRecordLength2;i++)
	{
		tmpx = 680-redRecord2[i][0];
		tmpy = 500-redRecord2[i][1];
		if (noPointInVerySmallRange(tmpx, tmpy, tmpRed, length2) && tmpx >15 && tmpx < 665 && tmpy > 15 && tmpy < 485)
		{
			if (noPointNearby(tmpx, tmpy, tmpRecord2, tmpLength2))
			{
				tmpRed[length2][0] = tmpx;
				tmpRed[length2][1] = tmpy;
				length2++;
				Point center = Point( tmpx, tmpy);
				int r = 8;
				cvCircle(aftertrans, center, r, Scalar(0, 0, 255), 12);
			}
		}
	}
}



int main()
{
	//声明IplImage指针
	int nFrmNum = 0;
	int nFrmNum2 = 0;
	char str[20];

	ori[0] = cvPoint2D32f(14, 170);//球场1四个点
	ori[1] = cvPoint2D32f(464, 112);
	ori[2] = cvPoint2D32f(421, 529);
	ori[3] = cvPoint2D32f(811, 192);
	newp[0] = cvPoint2D32f(0, 0);
	newp[1] = cvPoint2D32f(680, 0);
	newp[2] = cvPoint2D32f(0, 500);
	newp[3] = cvPoint2D32f(680, 500);

	ori2[0] = cvPoint2D32f(-97, 303);//球场2四个点
	ori2[1] = cvPoint2D32f(220, 254);
	ori2[2] = cvPoint2D32f(367, 534);
	ori2[3] = cvPoint2D32f(672, 325);
	newp2[0] = cvPoint2D32f(0, 0);
	newp2[1] = cvPoint2D32f(340, 0);
	newp2[2] = cvPoint2D32f(0, 500);
	newp2[3] = cvPoint2D32f(340, 500);




	//创建窗口
	cvGetPerspectiveTransform(ori, newp, transmat);
	cvGetPerspectiveTransform(ori2, newp2, transmat2);
	cvNamedWindow("video", 1);
	//cvNamedWindow("foreground", 1);
	cvNamedWindow("video2", 1);
	//cvNamedWindow("foreground2",1);
	cvNamedWindow("MergedWindow",1);
	//使窗口有序排列
	cvMoveWindow("video", 30, 0);
	cvMoveWindow("foreground", 690, 0);

	pCapture = cvCaptureFromFile("zuqiu2.MPG");

	pCapture2 = cvCaptureFromFile("zuqiu2.mp4");
	CvVideoWriter *outputvideo;

	while (true)
	{
//视频进行帧同步 to do
		if (nFrmNum < 8032+11780)
		{
			pFrame = cvQueryFrame(pCapture);
			nFrmNum++;
			continue;
		}
		if (nFrmNum2 < 4900+11780)
		{
			nFrmNum2++;
			pFrame2 = cvQueryFrame(pCapture2);
			continue;
		}

		//如果是第一帧，需要申请内存，并初始化

//第一共同帧处理 to do
		if (nFrmNum == 8032+11780 && nFrmNum2 == 4900+11780)
		{
			//Frame1的处理
			//cvSaveImage("G:\\cyf\\三年级下学期\\科创\\a.jpg",pFrame);
			//cvSaveImage("G:\\cyf\\三年级下学期\\科创\\b.jpg", pFrame2);
            outputvideo=cvCreateVideoWriter("out3.avi",CV_FOURCC('M','J','P','G'),
            25,cvSize(680,500),1);
			pBkImg = cvCreateImage(cvSize(pFrame->width, pFrame->height), IPL_DEPTH_8U, 3);
			pFrImg = cvCreateImage(cvSize(pFrame->width, pFrame->height), IPL_DEPTH_8U, 3);
			cpFrame = cvCreateImage(cvSize(pFrame->width, pFrame->height), IPL_DEPTH_8U, 3);
			cpFrame2 = cvCreateImage(cvSize(pFrame->width, pFrame->height), IPL_DEPTH_8U, 3);
			pBkMat = cvCreateMat(pFrame->height, pFrame->width, CV_32FC3);
			pFrMat = cvCreateMat(pFrame->height, pFrame->width, CV_32FC3);
			pFramenew = cvCreateImage(cvSize(680, 500), IPL_DEPTH_8U, 3);
			diffImg = cvCreateImage(cvSize(pFrame->width, pFrame->height), IPL_DEPTH_8U, 3);
			pFrameMat = cvCreateMat(pFrame->height, pFrame->width, CV_32FC3);
			g_pGrayImage = cvCreateImage(cvGetSize(diffImg), IPL_DEPTH_8U, 1);
			g_pBinaryImage = cvCreateImage(cvGetSize(g_pGrayImage), IPL_DEPTH_8U, 1);
			//转化成单通道图像再处理
			cvConvert(pFrame, pFrameMat);
			cvConvert(pFrame, pFrMat);
			cvConvert(pFrame, pBkMat);


			//Frame2的处理
			pBkImg2 = cvCreateImage(cvSize(pFrame2->width, pFrame2->height), IPL_DEPTH_8U, 3);
			pFrImg2 = cvCreateImage(cvSize(pFrame2->width, pFrame2->height), IPL_DEPTH_8U, 3);
			cpFrame21 = cvCreateImage(cvSize(pFrame2->width, pFrame2->height), IPL_DEPTH_8U, 3);
			cpFrame22 = cvCreateImage(cvSize(pFrame2->width, pFrame2->height), IPL_DEPTH_8U, 3);
			pBkMat2 = cvCreateMat(pFrame2->height, pFrame2->width, CV_32FC3);
			pFrMat2 = cvCreateMat(pFrame2->height, pFrame2->width, CV_32FC3);
			pFramenew2 = cvCreateImage(cvSize(680, 500), IPL_DEPTH_8U, 3);
			diffImg2 = cvCreateImage(cvSize(pFrame2->width, pFrame2->height), IPL_DEPTH_8U, 3);
			pFrameMat2 = cvCreateMat(pFrame2->height, pFrame2->width, CV_32FC3);
			g_pGrayImage2 = cvCreateImage(cvGetSize(diffImg2), IPL_DEPTH_8U, 1);
			g_pBinaryImage2 = cvCreateImage(cvGetSize(g_pGrayImage2), IPL_DEPTH_8U, 1);

			pFramenew3 = cvCreateImage(cvSize(680, 500), IPL_DEPTH_8U, 3);
			//转化成单通道图像再处理
			cvConvert(pFrame2, pFrameMat2);
			cvConvert(pFrame2, pFrMat2);
			cvConvert(pFrame2, pBkMat2);
		}
		//else if(nFrmNum==200)while(true);
		else
//其余帧处理
		{
			//视频1的处理
			cvCvtColor(pFrame, pFrImg, CV_BGR2HSV);
			cvConvert(pFrame, pFrameMat);
			//高斯滤波先，以平滑图像
			cvSmooth(pFrameMat, pFrameMat, CV_GAUSSIAN, 3, 0, 0);
			//当前帧跟背景图相减
			//cvConvert(pFrameMat, pFrame);
			cvAbsDiff(pFrameMat, pBkMat, pFrMat);
			//进行形态学滤波，去掉噪音
			cvErode(pFrImg, pFrImg, 0, 1);
			cvDilate(pFrImg, pFrImg, 0, 1);
			//更新背景
			cvRunningAvg(pFrameMat, pBkMat, 1, 0);
			//将背景转化为图像格式，用以显示
			cvConvert(pBkMat, pBkImg);
			cvConvert(pFrMat, diffImg);
			//显示图像

			cvCopy(pFrame, cpFrame2);
			filtcolor(pFrame, diffImg, cpFrame, cpFrame2);
			cvShowImage("video", cpFrame2);

			if (nFrmNum % 2 == 0) {
				transpic(transmat, cpFrame, pFramenew);
				//cvShowImage("foreground", pFramenew);
			}
			//============================================================
			//视频2的处理
		   cvCvtColor(pFrame2, pFrImg2, CV_BGR2HSV);
            cvConvert(pFrame2, pFrameMat2);
   //高斯滤波先，以平滑图像
                cvSmooth(pFrameMat2, pFrameMat2, CV_GAUSSIAN, 3, 0, 0);
   //当前帧跟背景图相减
   //cvConvert(pFrameMat, pFrame);
            cvAbsDiff(pFrameMat2, pBkMat2, pFrMat2);
   //二值化前景图
   //cvThreshold(pFrMat, pFrImg, 60, 255.0, CV_THRESH_BINARY);
   //进行形态学滤波，去掉噪音
            cvErode(pFrImg2, pFrImg2, 0, 1);
            cvDilate(pFrImg2, pFrImg2, 0, 1);
   //更新背景
            cvRunningAvg(pFrameMat2, pBkMat2, 1, 0);
   //将背景转化为图像格式，用以显示
            cvConvert(pBkMat2, pBkImg2);
            cvConvert(pFrMat2,diffImg2);
   //显示图像

   //cvCvtColor(diffImg, g_pGrayImage, CV_BGR2GRAY);

  // cvThreshold(g_pGrayImage, g_pBinaryImage, 10, 255, CV_THRESH_BINARY);

   //cvShowImage("video", diffImg);
        cvCopy(pFrame2,cpFrame22);
        filtcolor2(pFrame2,diffImg2,cpFrame21,cpFrame22);
        cvShowImage("video2", cpFrame22);

   //*************************************************************************************
    //*************************************************************************************




				transpic2(transmat2, cpFrame21, pFramenew2);
				//cvShowImage("foreground2", pFramenew2);
				MergeVideo(mergeTransmat, pFramenew3);
				cvShowImage("MergedWindow",pFramenew3);
				//cvWriteFrame(outputvideo,pFramenew3);


			//char h;
			//cin >> h;

			if (cvWaitKey(25) >= 0 ||nFrmNum2 > 4900+11780+550 )
				break;
		}
		nFrmNum++;
		nFrmNum2++;
		pFrame = cvQueryFrame(pCapture);
		pFrame2 = cvQueryFrame(pCapture2);
	}

	//销毁窗口
	cvDestroyWindow("video");
	cvDestroyWindow("foreground");
	//释放图像和矩阵
	cvReleaseImage(&pFrImg);
	cvReleaseImage(&pBkImg);
	cvReleaseMat(&pFrameMat);
	cvReleaseMat(&pFrMat);
	cvReleaseMat(&pBkMat);
	cvReleaseCapture(&pCapture);
	cvReleaseVideoWriter(&outputvideo);
	return 0;
}
