/*

	kubeVision - OpenCV (part of the KubeVision)
	Modified by: Luc Michalski - 2015
	New features: Web-service and distributed search
	Based on: Find-Object - Mathieu Labbe - IntRoLab - Universite de Sherbrooke
	URL: https://github.com/introlab/find-object

*/

#ifndef TCPRESPONSE_H_
#define TCPRESPONSE_H_

#include "find_object/DetectionInfo.h"

#include <QtNetwork/QTcpSocket>
#include <QtCore/QMultiMap>
#include <QtGui/QTransform>
#include <QtCore/QRect>

class TcpResponse : public QTcpSocket
{
	Q_OBJECT;
public:
	TcpResponse(QObject * parent = 0);
	const find_object::DetectionInfo & info() const {return info_;}
	bool dataReceived() const {return dataReceived_;}

private Q_SLOTS:
	void readReceivedData();
	void displayError(QAbstractSocket::SocketError socketError);
	void connectionLost();

Q_SIGNALS:
	void detectionReceived();

private:
	quint16 blockSize_;
	find_object::DetectionInfo info_;
	bool dataReceived_;
};

#endif /* TCPCLIENT_H_ */
