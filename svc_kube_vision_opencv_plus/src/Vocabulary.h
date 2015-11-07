/*
Copyright (c) 2015, Michalski Luc
*/

#ifndef VOCABULARY_H_
#define VOCABULARY_H_

#include <QtCore/QMultiMap>
#include <QtCore/QVector>
#include <opencv2/opencv.hpp>

namespace find_object {

class Vocabulary {
public:
	Vocabulary();
	virtual ~Vocabulary();

	void clear();
	QMultiMap<int, int> addWords(const cv::Mat & descriptors, int objectId);
	void update();
	void search(const cv::Mat & descriptors, cv::Mat & results, cv::Mat & dists, int k);
	int size() const {return indexedDescriptors_.rows + notIndexedDescriptors_.rows;}
	int dim() const {return !indexedDescriptors_.empty()?indexedDescriptors_.cols:notIndexedDescriptors_.cols;}
	int type() const {return !indexedDescriptors_.empty()?indexedDescriptors_.type():notIndexedDescriptors_.type();}
	const QMultiMap<int, int> & wordToObjects() const {return wordToObjects_;}
	const cv::Mat & indexedDescriptors() const {return indexedDescriptors_;}

	void save(QDataStream & streamSessionPtr) const;
	void load(QDataStream & streamSessionPtr);
	bool save(const QString & filename) const;
	bool load(const QString & filename);

private:
	cv::flann::Index flannIndex_;
	cv::Mat indexedDescriptors_;
	cv::Mat notIndexedDescriptors_;
	QMultiMap<int, int> wordToObjects_; // <wordId, ObjectId>
	QVector<int> notIndexedWordIds_;
};

} // namespace find_object

#endif /* VOCABULARY_H_ */
