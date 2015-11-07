/*
Copyright (c) 2015, Michalski Luc
*/

#include "find_object/JsonWriter.h"
#include "find_object/utilite/ULogger.h"

#include <QtCore/QFile>
#include <QtCore/QTextStream>
#include <QtCore/QFileInfo>

#include "json/json.h"

namespace find_object {

void JsonWriter::write(const DetectionInfo & info, const QString & path)
{
	if(!path.isEmpty())
	{
		Json::Value root;

		if(info.objDetected_.size())
		{
			Json::Value detections;

			QMultiMap<int, int>::const_iterator iterInliers = info.objDetectedInliersCount_.constBegin();
			QMultiMap<int, int>::const_iterator iterOutliers = info.objDetectedOutliersCount_.constBegin();
			QMultiMap<int, QSize>::const_iterator iterSizes = info.objDetectedSizes_.constBegin();
			QMultiMap<int, QString>::const_iterator iterFilePaths = info.objDetectedFilePaths_.constBegin();
			for(QMultiMap<int, QTransform>::const_iterator iter = info.objDetected_.constBegin(); iter!= info.objDetected_.end();)
			{
				char index = 'a';
				int id = iter.key();
				while(iter != info.objDetected_.constEnd() && id == iter.key())
				{
					QString name = QString("object_%1%2").arg(id).arg(info.objDetected_.count(id)>1?QString(index++):"");
					detections.append(name.toStdString());

					Json::Value homography;
					homography.append(iter.value().m11());
					homography.append(iter.value().m12());
					homography.append(iter.value().m13());
					homography.append(iter.value().m21());
					homography.append(iter.value().m22());
					homography.append(iter.value().m23());
					homography.append(iter.value().m31());  // dx
					homography.append(iter.value().m32());  // dy
					homography.append(iter.value().m33());
					root[name.toStdString()]["width"] = iterSizes.value().width();
					root[name.toStdString()]["height"] = iterSizes.value().height();
					root[name.toStdString()]["homography"] = homography;
					root[name.toStdString()]["inliers"] = iterInliers.value();
					root[name.toStdString()]["outliers"] = iterOutliers.value();
					root[name.toStdString()]["filepath"] = iterFilePaths.value().toStdString();
					QString filename;
					if(!iterFilePaths.value().isEmpty())
					{
						QFileInfo file(iterFilePaths.value());
						filename=file.fileName();
					}
					root[name.toStdString()]["filename"] = filename.toStdString();

					++iter;
					++iterInliers;
					++iterOutliers;
					++iterSizes;
					++iterFilePaths;
				}
			}
			root["objects"] = detections;
		}

		if(info.matches_.size())
		{
			Json::Value matchesValues;
			const QMap<int, QMultiMap<int, int> > & matches = info.matches_;
			for(QMap<int, QMultiMap<int, int> >::const_iterator iter = matches.constBegin();
				iter != matches.end();
				++iter)
			{
				QString name = QString("matches_%1").arg(iter.key());
				root[name.toStdString()] = iter.value().size();
				matchesValues.append(name.toStdString());
			}
			root["matches"] = matchesValues;
		}

		// write in a nice readible way
		Json::StyledWriter styledWriter;
		//std::cout << styledWriter.write(root);
		QFile file(path);
		file.open(QIODevice::WriteOnly | QIODevice::Text);
		QTextStream out(&file);
		out << styledWriter.write(root).c_str();
		file.close();
	}
}

} // namespace find_object
