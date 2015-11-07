/*
 * sifthesaff_extractor.cpp
 *
 *  Created on: January 25, 2013
 *      Author: Siriwat Kasamwattanarote
 */
#include <iostream>
#include <iomanip>
#include <string>
#include <sstream>
#include <fstream>
#include <vector>
#include <bitset>
#include <unistd.h> // usleep
#include <sys/types.h> // for checking exist file and dir
#include <sys/stat.h>

// Siriwat's header
#include "../alphautils/alphautils.h"
#include "../alphautils/imtools.h"
#include "SIFThesaff.h"
#include "version_exe.h"

using namespace std;
using namespace alphautils;
using namespace alphautils::imtools;

int main(int argc,char *argv[])
{
    cout << "SIFT extractor standalone version " << siftexe_AutoVersion::siftexe_FULLVERSION_STRING << endl;
    cout << "SIFT extractor library version " << SIFThesaff::version() << endl;
    cout << "Alpha Utilities library version " << alphautils::version() << endl;

	if(argc < 2)
	{
		cout << "Params must be \"sifthesaff_extractor -i input_image [-o output_sift] [-d input_sift(display)] [-m output_mode:b|t] [-c colorspace:r(rgb)|i(irgb)|l(lab)] [-n normpoint:1|0] [-r rootsift:1|0] [-v:a|p, draw overlay in only binary mode]\"" << endl;
		exit(1);
	}

	string input_image = "";
	string output_sift = "";
	string input_sift = "";
	string output_overlay_image = "";
	bool isBinary = false;
	int colorspace = RGB_SPACE;
	bool normpoint = true;
	bool rootsift = true;
	bool draw_mode = DRAW_AFFINE;

	if(argc > 2)
	{
		for(int count = 1; count < argc; count+=2)
		{
			char opt;
			if(argv[count][0] == '-')
				opt = argv[count][1];
			else
			{
				cout << "Incorrect parameter " << argv[count] << endl;
				exit(1);
			}

			switch(opt)
			{
			case 'i':
				input_image = string(argv[count + 1]);
				break;
			case 'o':
				output_sift = string(argv[count + 1]);
				break;
            case 'd':
                input_sift = string(argv[count + 1]);
                break;
			case 'm':
				if(argv[count + 1][0] == 'b')
					isBinary = true;
				break;
            case 'v':
                if (isBinary)
                {
                    output_overlay_image = input_image + "_overlay.png";
					if (argv[count + 1][0] == 'a')
						draw_mode = DRAW_AFFINE;
                    else if(argv[count + 1][0] == 'p')
                        draw_mode = DRAW_POINT;
					else if (argv[count + 1][0] == 'c')
						draw_mode = DRAW_CIRCLE;
                }
                break;
            case 'c':
                if (argv[count + 1][0] == 'i')
                    colorspace = IRGB_SPACE;
				if (argv[count + 1][0] == 'l')
					colorspace = LAB_SPACE;
                break;
            case 'n':
				if(argv[count + 1][0] == '0')
					normpoint = false;
                break;
			case 'r':
				if(argv[count + 1][0] == '0')
					rootsift = false;
				break;
			}
		}
	}

    //input_image = "/dev/shm/test.jpg";

    if (input_sift != "")
    {
        SIFThesaff sift_display;
        sift_display.importKeypoints(input_sift, isBinary);

        cout << sift_display.width << endl;
        cout << sift_display.height << endl;
        cout << SIFThesaff::GetSIFTD() << endl;
        cout << sift_display.num_kp << endl;

        for(int kp_idx = 0; kp_idx < sift_display.num_kp; kp_idx++)
        {
            cout << sift_display.kp[kp_idx][0] << " " << sift_display.kp[kp_idx][1] << " " << sift_display.kp[kp_idx][2] << " " << sift_display.kp[kp_idx][3] << " " << sift_display.kp[kp_idx][4] << " ";
            for(size_t desc_pos = 0; desc_pos < SIFT_D; desc_pos++)
                cout << sift_display.desc[kp_idx][desc_pos] << " ";
            cout << endl;
        }


        return EXIT_SUCCESS;
    }

	if(input_image == "")
	{
		cout << "Params must be \"sifthesaff_extractor -i input_image [-o output_sift] [-m output_mode:b|t] [-c colorspace:r(rgb)|l(lab)] [-n normpoint:1|0] [-r rootsift:1|0] [-v:a|p, draw overlay in only binary mode]\"" << endl;
		exit(1);
	}

	if(output_sift == "")
    {
        if (contain_path(input_image))
            output_sift = input_image + ".hesaff.rootsift";
        else
            output_sift = "./" + input_image + ".hesaff.rootsift";
    }

	SIFThesaff sifthesaff(colorspace, normpoint, rootsift);

	cout << "Extract sift..."; cout.flush();
	timespec startTime = CurrentPreciseTime();
	sifthesaff.extractPerdochSIFT(input_image);
	cout << "done! (in " << setprecision(4) << fixed << TimeElapse(startTime) << " s)" << endl;

	cout << "Exporting result ";
	if(isBinary) cout << "[binary mode]...";
	else cout << "[text mode]...";
	cout.flush();
    sifthesaff.exportKeypoints(output_sift, isBinary);
	cout << "OK!" << endl;

	if (output_overlay_image != "")
	{
        cout << "Drawing SIFT overlay...";
        cout.flush();
        sifthesaff.draw_sifts(input_image, output_overlay_image, output_sift, draw_mode);
        cout << "done" << endl;
    }

    cout << "== SIFT feature information ==" << endl;
    cout << "Total dimension: " << sifthesaff.GetSIFTD() << endl;
    cout << "Total keypoint: " << sifthesaff.num_kp << endl;


	return 0;
}
//;)
