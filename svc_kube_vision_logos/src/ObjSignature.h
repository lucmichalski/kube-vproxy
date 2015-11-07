/*
Copyright (c) 2015, Michalski Luc
*/

#ifndef OBJSIGNATURE_H_
#define OBJSIGNATURE_H_

#include <opencv2/opencv.hpp>
#include <QtCore/QString>
#include <QtCore/QMultiMap>
#include <QtCore/QRect>
#include <QtCore/QDataStream>
#include <QtCore/QByteArray>

namespace find_object {

class ObjSignature {
public:
	ObjSignature() :
		id_(-1)
	{}
	ObjSignature(int id, const cv::Mat & image, const QString & filePath) :
		id_(id),
		image_(image),
		rect_(0,0,image.cols, image.rows),
		filePath_(filePath)
	{}
	virtual ~ObjSignature() {}

	void setData(const std::vector<cv::KeyPoint> & keypoints, const cv::Mat & descriptors)
	{
		keypoints_ = keypoints;
		descriptors_ = descriptors;
	}
	void setWords(const QMultiMap<int, int> & words) {words_ = words;}
	void setId(int id) {id_ = id;}
	void removeImage() {image_ = cv::Mat();}

	const QRect & rect() const {return rect_;}

	int id() const {return id_;}
	const QString & filePath() const {return filePath_;}
	const cv::Mat & image() const {return image_;}
	const std::vector<cv::KeyPoint> & keypoints() const {return keypoints_;}
	const cv::Mat & descriptors() const {return descriptors_;}
	const QMultiMap<int, int> & words() const {return words_;}

	void save(QDataStream & streamPtr) const
	{
		streamPtr << id_;
		streamPtr << filePath_;
		streamPtr << (int)keypoints_.size();
		for(unsigned int j=0; j<keypoints_.size(); ++j)
		{
				streamPtr << keypoints_.at(j).angle <<
								keypoints_.at(j).class_id <<
								keypoints_.at(j).octave <<
								keypoints_.at(j).pt.x <<
								keypoints_.at(j).pt.y <<
								keypoints_.at(j).response <<
								keypoints_.at(j).size;
		}

		qint64 dataSize = descriptors_.elemSize()*descriptors_.cols*descriptors_.rows;
		streamPtr << descriptors_.rows <<
						descriptors_.cols <<
						descriptors_.type() <<
						dataSize;
		streamPtr << QByteArray((char*)descriptors_.data, dataSize);

		streamPtr << words_;

		std::vector<unsigned char> bytes;
		cv::imencode(".png", image_, bytes);
		streamPtr << QByteArray((char*)bytes.data(), (int)bytes.size());

		streamPtr << rect_;
	}

	void load(QDataStream & streamPtr, bool ignoreImage)
	{
		int nKpts;
		streamPtr >> id_ >> filePath_ >> nKpts;
		keypoints_.resize(nKpts);
		for(int i=0;i<nKpts;++i)
		{
				streamPtr >>
				keypoints_[i].angle >>
				keypoints_[i].class_id >>
				keypoints_[i].octave >>
				keypoints_[i].pt.x >>
				keypoints_[i].pt.y >>
				keypoints_[i].response >>
				keypoints_[i].size;
		}

		int rows,cols,type;
		qint64 dataSize;
		streamPtr >> rows >> cols >> type >> dataSize;
		QByteArray data;
		streamPtr >> data;
		descriptors_ = cv::Mat(rows, cols, type, data.data()).clone();

		streamPtr >> words_;

		QByteArray image;
		streamPtr >> image;
		if(!ignoreImage)
		{
			std::vector<unsigned char> bytes(image.size());
			memcpy(bytes.data(), image.data(), image.size());
			image_ = cv::imdecode(bytes, cv::IMREAD_UNCHANGED);
		}

		streamPtr >> rect_;
	}

private:
	int id_;
	cv::Mat image_;
	QRect rect_;
	QString filePath_;
	std::vector<cv::KeyPoint> keypoints_;
	cv::Mat descriptors_;
	QMultiMap<int, int> words_; // <word id, keypoint indexes>
};

} // namespace find_object

#endif /* OBJSIGNATURE_H_ */
