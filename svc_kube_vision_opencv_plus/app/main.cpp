/*
Copyright (c) 2015, Michalski Luc
*/

#include <stdio.h>
#include <stdlib.h>

#include <QtGui/QApplication>
#include <QtCore/QCoreApplication>
#include <QtCore/QTime>
#include <QtCore/QObject>
#include <iostream>
#include <iomanip>
#include "find_object/Settings.h"
#include "find_object/FindObject.h"
#include "find_object/JsonWriter.h"
#include "crow/include/crow.h"
#include <opencv2/calib3d/calib3d.hpp> // for homography
#include <opencv2/opencv_modules.hpp>

// OpenCV stuff
bool running = true;

//using namespace std;
using namespace crow;
//using namespace cv;

static const std::string base64_chars =
"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
"abcdefghijklmnopqrstuvwxyz"
"0123456789+/";

static inline bool is_base64(unsigned char c) {
    return (isalnum(c) || (c == '+') || (c == '/'));
}

std::string base64_decode(std::string const& encoded_string) {
    int in_len = encoded_string.size();
    int i = 0;
    int j = 0;
    int in_ = 0;
    unsigned char char_array_4[4], char_array_3[3];
    std::string ret;

    while (in_len-- && (encoded_string[in_] != '=') && is_base64(encoded_string[in_])) {
        char_array_4[i++] = encoded_string[in_]; in_++;
        if (i == 4) {
            for (i = 0; i < 4; i++)
                char_array_4[i] = base64_chars.find(char_array_4[i]);

            char_array_3[0] = (char_array_4[0] << 2) + ((char_array_4[1] & 0x30) >> 4);
            char_array_3[1] = ((char_array_4[1] & 0xf) << 4) + ((char_array_4[2] & 0x3c) >> 2);
            char_array_3[2] = ((char_array_4[2] & 0x3) << 6) + char_array_4[3];

            for (i = 0; (i < 3); i++)
                ret += char_array_3[i];
            i = 0;
        }
    }

    if (i) {
        for (j = i; j < 4; j++)
            char_array_4[j] = 0;

        for (j = 0; j < 4; j++)
            char_array_4[j] = base64_chars.find(char_array_4[j]);

        char_array_3[0] = (char_array_4[0] << 2) + ((char_array_4[1] & 0x30) >> 4);
        char_array_3[1] = ((char_array_4[1] & 0xf) << 4) + ((char_array_4[2] & 0x3c) >> 2);
        char_array_3[2] = ((char_array_4[2] & 0x3) << 6) + char_array_4[3];

        for (j = 0; (j < i - 1); j++) ret += char_array_3[j];
    }

    return ret;
}

enum {mTotal, mInliers};

int main(int argc, char* argv[])
{

    crow::SimpleApp api;

    // Getting the default parameter for find object
	find_object::ParametersMap parameters = find_object::Settings::getDefaultParameters();

	// Overriding default parameters 
	find_object::ParametersMap customParameters;

    api.route_dynamic("/status")
    ([](){
     	crow::json::wvalue x;
        x["Results"] = "Status";
        return x;
    });

    api.route_dynamic("/add")
    ([](){
     	crow::json::wvalue x;
        x["Results"] = "Status";
        return x;
    });

    api.route_dynamic("/remove")
    ([](){
     	crow::json::wvalue x;
        x["Results"] = "Status";
        return x;
    });

    api.route_dynamic("/similarity")
    ([](const crow::request& req){
		std::string similarity_score = Similarity(req.url_params.get("sceneImgBase64"), req.url_params.get("objectImgBase64"));
     	crow::json::wvalue x;
        x["Results"] = similarity_score;
        return x;
    });

    api.route_dynamic("/batch")
    ([](){

		//bool imagesSaved = true;

		// Check for custom parameters:
		//	customParameters[find_object::Settings::kGeneral_vocabularyFixed()] = true;
		//	customParameters[find_object::Settings::kGeneral_invertedSearch()] = true;

		// Load settings, should be loaded before creating other objects
		//find_object::Settings::init(configPath);

		// Override custom parameters:
		/*for(find_object::ParametersMap::iterator iter= customParameters.begin(); iter!=customParameters.end(); ++iter)
		{
			find_object::Settings::setParameter(iter.key(), iter.value());
		}*/

	    // Create the visual dictionary
		// Create FindObject
		//find_object::FindObject * findObject = new find_object::FindObject(guiMode || imagesSaved);

		// Load objects if path is set
		//int objectsLoaded = 0;
		//!findObject->loadVocabulary(vocabularyPath))
		//findObject->loadSession(sessionPath))
		//objectsLoaded = findObject->objects().size();
		//objectsLoaded = findObject->loadObjects(objectsPath);
		//findObject->loadVocabulary(vocabularyPath))
		/*
		const find_object::ObjSignature * obj = findObject->addObject(objectPath);
		if(obj)
			{
				++objectsLoaded;
				findObject->updateObjects();
				findObject->updateVocabulary();
		*/
     	crow::json::wvalue x;
        x["Results"] = "Batch";
        return x;
    });

    api.route_dynamic("/query")
    ([](const crow::request& req){

        std::ostringstream os;
        os << "Params: " << req.url_params << "\n\n"; 
        os << "The key 'foo' was " << (req.url_params.get("foo") == nullptr ? "not " : "") << "found.\n";
        if(req.url_params.get("pew") != nullptr) {
            double countD = boost::lexical_cast<double>(req.url_params.get("pew"));
            os << "The value of 'pew' is " <<  countD << '\n';
        }
        auto count = req.url_params.get_list("count");
        os << "The key 'count' contains " << count.size() << " value(s).\n";
        for(const auto& countVal : count) {
            os << " - " << countVal << '\n';
        }

		cv::Mat scene;
		if(req.url_params.get("imgBase64"))
		{
		   	std::string encoded_string = "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";
		    std::string decoded_string = base64_decode(encoded_string);
		    std::vector<uchar> data(decoded_string.begin(), decoded_string.end());
			scene = cv::imdecode(data, cv::IMREAD_UNCHANGED);
			if(scene.empty()){
				//UERROR("Failed to load the base64 encoded scene");
			} else {
				//return crow::response{scene};
			}
		}
		/*
		if(!req.url_params.get("file"))
		{
			scene = cv::imdecode(data, IMREAD_UNCHANGED);
			if(scene.empty()){
				UERROR("Failed to load scene \"%s\"", scenePath.toStdString().c_str());
			} else {

			}
		}
		// Compare hte image to the dataset
		cv::Mat scene;
		if(!scenePath.isEmpty())
		{
			scene = cv::imread(scenePath.toStdString());
			if(scene.empty())
			{
				UERROR("Failed to load scene \"%s\"", scenePath.toStdString().c_str());
			}
		}
		// process the scene and exit
		QTime time;
		time.start();
		find_object::DetectionInfo info;
		findObject->detect(scene, info);
		if(info.objDetected_.size() > 1)
		{
			UINFO("%d objects detected! (%d ms)", (int)info.objDetected_.size(), time.elapsed());
		}
		else if(info.objDetected_.size() == 1)
		{
			UINFO("Object %d detected! (%d ms)", (int)info.objDetected_.begin().key(), time.elapsed());
		}
		else if(find_object::Settings::getGeneral_sendNoObjDetectedEvents())
		{
			UINFO("No objects detected. (%d ms)", time.elapsed());
		}

		if(!jsonPath.isEmpty())
		{
			find_object::JsonWriter::write(info, jsonPath);
			UINFO("JSON written to \"%s\"", jsonPath.toStdString().c_str());
		}
		*/
        return crow::response{os.str()};
//     	crow::json::wvalue x;
//        x["Results"] 	= "Query";
//        return x;
    });

    // ignore all log
    crow::logger::setLogLevel(crow::LogLevel::DEBUG);
    //crow::logger::setHandler(std::make_shared<ExampleLogHandler>());

    api.port(18080)
        .multithreaded()
        .run();


}

int Similarity(std::string sceneImgBase64, std::string objectImgBase64) {

	bool quiet = false;
	int method = mTotal; //total matches

	// Decode and Read the scene
    std::string sceneImgDecoded = base64_decode(sceneImgBase64);
    std::vector<uchar> data(sceneImgDecoded.begin(), sceneImgDecoded.end());
	cv::Mat sceneImg = cv::imread(sceneImgDecoded, cv::IMREAD_GRAYSCALE);

	// Decode and Read the object to recognize in the scene
    std::string objectImgDecoded = base64_decode(objectImgBase64);
    std::vector<uchar> data(objectImgDecoded.begin(), objectImgDecoded.end());
	cv::Mat objectImg = cv::imread(objectImgDecoded, cv::IMREAD_GRAYSCALE);

	int value = 0;
	if(!objectImg.empty() && !sceneImg.empty())
	{
		std::vector<cv::KeyPoint> objectKeypoints;
		std::vector<cv::KeyPoint> sceneKeypoints;
		cv::Mat objectDescriptors;
		cv::Mat sceneDescriptors;

#if CV_MAJOR_VERSION < 3
		////////////////////////////
		// EXTRACT KEYPOINTS
		////////////////////////////
		cv::SIFT sift;
		sift.detect(objectImg, objectKeypoints);
		sift.detect(sceneImg, sceneKeypoints);

		////////////////////////////
		// EXTRACT DESCRIPTORS
		////////////////////////////
		sift.compute(objectImg, objectKeypoints, objectDescriptors);
		sift.compute(sceneImg, sceneKeypoints, sceneDescriptors);
#else
		////////////////////////////
		// EXTRACT KEYPOINTS
		////////////////////////////
		cv::Ptr<cv::xfeatures2d::SIFT> sift = cv::xfeatures2d::SIFT::create();
		sift->detect(objectImg, objectKeypoints);
		sift->detect(sceneImg, sceneKeypoints);

		////////////////////////////
		// EXTRACT DESCRIPTORS
		////////////////////////////
		sift->compute(objectImg, objectKeypoints, objectDescriptors);
		sift->compute(sceneImg, sceneKeypoints, sceneDescriptors);
#endif
		////////////////////////////
		// NEAREST NEIGHBOR MATCHING USING FLANN LIBRARY (included in OpenCV)
		////////////////////////////
		cv::Mat results;
		cv::Mat dists;
		std::vector<std::vector<cv::DMatch> > matches;
		int k=2; // find the 2 nearest neighbors

		// Create Flann KDTree index
		cv::flann::Index flannIndex(sceneDescriptors, cv::flann::KDTreeIndexParams(), cvflann::FLANN_DIST_EUCLIDEAN);
		results = cv::Mat(objectDescriptors.rows, k, CV_32SC1); // Results index
		dists = cv::Mat(objectDescriptors.rows, k, CV_32FC1); // Distance results are CV_32FC1

		// search (nearest neighbor)
		flannIndex.knnSearch(objectDescriptors, results, dists, k, cv::flann::SearchParams() );

		////////////////////////////
		// PROCESS NEAREST NEIGHBOR RESULTS
		////////////////////////////

		// Find correspondences by NNDR (Nearest Neighbor Distance Ratio)
		float nndrRatio = 0.6f;
		std::vector<cv::Point2f> mpts_1, mpts_2; // Used for homography
		std::vector<int> indexes_1, indexes_2; // Used for homography
		std::vector<uchar> outlier_mask;  // Used for homography
		// Check if this descriptor matches with those of the objects

		for(int i=0; i<objectDescriptors.rows; ++i)
		{
			// Apply NNDR
			if(dists.at<float>(i,0) <= nndrRatio * dists.at<float>(i,1))
			{
				mpts_1.push_back(objectKeypoints.at(i).pt);
				indexes_1.push_back(i);

				mpts_2.push_back(sceneKeypoints.at(results.at<int>(i,0)).pt);
				indexes_2.push_back(results.at<int>(i,0));
			}
		}

		if(method == mInliers)
		{
			// FIND HOMOGRAPHY
			unsigned int minInliers = 8;
			if(mpts_1.size() >= minInliers)
			{
				cv::Mat H = findHomography(mpts_1,
						mpts_2,
						cv::RANSAC,
						1.0,
						outlier_mask);
				int inliers=0, outliers=0;
				for(unsigned int k=0; k<mpts_1.size();++k)
				{
					if(outlier_mask.at(k))
					{
						++inliers;
					}
					else
					{
						++outliers;
					}
				}
				if(!quiet)
					printf("Total=%d Inliers=%d Outliers=%d\n", (int)mpts_1.size(), inliers, outliers);
				value = (inliers*100) / (inliers+outliers);
			}
		}
		else
		{
			value = (int)mpts_1.size();
		}
	}
	else
	{
		printf("Images are not valid!\n");
	}
	if(!quiet)
		printf("Similarity = %d\n", value);

	// Return the value in JSON format
	return value;
}
