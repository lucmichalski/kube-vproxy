#ifndef FINDOBJECT_H_
#define FINDOBJECT_H_

#include "find_object/FindObjectExp.h" // DLL export/import defines

#include "find_object/DetectionInfo.h"

#include <QtCore/QObject>
#include <QtCore/QString>
#include <QtCore/QMap>
#include <QtCore/QMultiMap>
#include <QtCore/QPair>
#include <QtCore/QVector>
#include <QtGui/QTransform>
#include <QtCore/QRect>
#include <opencv2/opencv.hpp>
#include <vector>

namespace find_object {

class ObjSignature;
class Vocabulary;
class Feature2D;

class FINDOBJECT_EXP FindObject : public QObject
{
	Q_OBJECT;
public:
	static void affineSkew(float tilt,
				float phi,
				const cv::Mat & image,
				cv::Mat & skewImage,
				cv::Mat & skewMask,
				cv::Mat & Ai);

public:
	FindObject(bool keepImagesInRAM_ = true, QObject * parent = 0);
	virtual ~FindObject();

	bool loadSession(const QString & path);
	bool saveSession(const QString & path);
	bool isSessionModified() const {return sessionModified_;}

	bool saveVocabulary(const QString & filePath) const;
	bool loadVocabulary(const QString & filePath);

	int loadObjects(const QString & dirPath, bool recursive = false); // call updateObjects()
	const ObjSignature * addObject(const QString & filePath);
	const ObjSignature * addObject(const cv::Mat & image, int id=0, const QString & filePath = QString());
	bool addObject(ObjSignature * obj); // take ownership when true is returned
	void removeObject(int id);
	void removeAllObjects();

	bool detect(const cv::Mat & image, find_object::DetectionInfo & info);

	void updateDetectorExtractor();
	void updateObjects(const QList<int> & ids = QList<int>());
	void updateVocabulary(const QList<int> & ids = QList<int>());

	const QMap<int, ObjSignature*> & objects() const {return objects_;}
	const Vocabulary * vocabulary() const {return vocabulary_;}

public Q_SLOTS:
	void addObjectAndUpdate(const cv::Mat & image, int id=0, const QString & filePath = QString());
	void removeObjectAndUpdate(int id);
	void detect(const cv::Mat & image); // emit objectsFound()

Q_SIGNALS:
	void objectsFound(const find_object::DetectionInfo &);

private:
	void clearVocabulary();

private:
	QMap<int, ObjSignature*> objects_;
	Vocabulary * vocabulary_;
	QMap<int, cv::Mat> objectsDescriptors_;
	QMap<int, int> dataRange_; // <last id of object's descriptor, id>
	Feature2D * detector_;
	Feature2D * extractor_;
	bool sessionModified_;
	bool keepImagesInRAM_;
};

} // namespace find_object

#endif /* FINDOBJECT_H_ */
