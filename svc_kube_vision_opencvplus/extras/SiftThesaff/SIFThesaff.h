/*
 * ins_offline.h
 *
 *  Created on: January 25, 2013
 *      Author: Siriwat Kasamwattanarote
 */
#pragma once

#include "version_lib.h"

#include "opencv2/core/core.hpp"
#include "opencv2/nonfree/features2d.hpp"
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/calib3d/calib3d.hpp"
#include "opencv2/imgproc/imgproc.hpp"

// Siriwat's header
#include "../alphautils/imtools.h"

#define SIFT_D 128
#define SIFT_HEADSIZE 5

using namespace std;
using namespace cv;
using namespace alphautils;
using namespace alphautils::imtools;

class SIFThesaff
{		
    bool check_file_exist;

    int colorspace;
    bool normalize_pt;
	bool RootSIFT;
	int g_numberOfPoints;
	int g_numberOfAffinePoints;

    // Memory management flag
    bool has_kp;
    bool has_desc;

public:	
	SIFThesaff(int Colorspace = RGB_SPACE, bool isNormalizePt = false, bool isRootSIFT = true, bool isCheckFile = true); // colorspace = 0 is rgb
	~SIFThesaff(void);
	void init(int Colorspace = RGB_SPACE, bool isNormalizePt = false, bool isRootSIFT = true, bool isCheckFile = true);
	static string version() { return siftlib_AutoVersion::siftlib_FULLVERSION_STRING; }; // Version
	static int GetSIFTD() { return SIFT_D; };
	static int GetSIFTHeadSize() { return SIFT_HEADSIZE; };

	vector<float*> kp; // x y a b c
	vector<float*> desc; // x-descriptors
	int num_kp;
	int width, height;
	struct HessianAffineParams;
	void exportKeypoints(const string& out, bool isBinary = true);
	bool importKeypoints(const string& in, bool isBinary = true);
	int checkNumKp(const string& in, bool isBinary = true);
	int extractPerdochSIFT(const string& imgPath);
	int extractPerdochSIFT(const Mat& img);
	void unlink_kp();
	void unlink_desc();
	void reset(void);
	void rgb2lab(const uchar R, const uchar G, const uchar B, uchar& Lv, uchar& av, uchar& bv);
	
	// SIFT drawing specific
	void draw_sifts(const string& in_img_path, const string& out_img_path, const string& sift_path, int draw_mode, int colorspace = RGB_SPACE, bool normpoint = true, bool rootsift = true, bool binary = true);
	void draw_sifts(const string& in_img_path, const string& out_img_path, const vector<INS_KP>& sift_keypoints, int draw_mode, int colorspace = RGB_SPACE, bool normpoint = true, bool rootsift = true);
	void draw_sifts(Mat& in_img, const string& sift_path, int draw_mode, int colorspace = RGB_SPACE, bool normpoint = true, bool rootsift = true, bool binary = true);
	float draw_a_sift(Mat& in_img, INS_KP in_keypoint, int draw_mode, bool normpoint = true);
};
//;)
