/*

	kubeVision - OpenCV (part of the KubeVision)
	Modified by: Luc Michalski - 2015
	New features: Web-service and distributed search
	Based on: Find-Object - Mathieu Labbe - IntRoLab - Universite de Sherbrooke
	URL: https://github.com/introlab/find-object

*/

#include <QtNetwork/QNetworkInterface>
#include <QtCore/QCoreApplication>
#include <QtCore/QFile>
#include <QtCore/QTime>
#include <opencv2/opencv.hpp>
#include <find_object/TcpServer.h>
#include "TcpResponse.h"
#include "find_object/JsonWriter.h"

void showUsage()
{
	printf("\ntcpRequest [options] --scene image.png --out # --in #\n"
		   "\ntcpRequest [options] --scene image.png --port #\n"
			"  \"out\" is the port to which the image is sent.\n"
			"  \"in\" is the port from which the detection is received.\n"
			"  \"port\" is the bidirectional port from which the image is sent AND the detection is received.\n"
			"  Options:\n"
			"    --host #.#.#.#       Set host address.\n"
			"    --json \"path\"        Path to an output JSON file.\n"
			"    --help               Show this help.\n");
	exit(-1);
}

int main(int argc, char * argv[])
{
	QString ipAddress;
	QString scenePath;
	QString jsonPath;
	quint16 portOut = 0;
	quint16 portIn = 0;
	quint16 bidrectionalPort = 0;

	for(int i=1; i<argc; ++i)
	{
		if(strcmp(argv[i], "--host") == 0 || strcmp(argv[i], "-host") == 0)
		{
			++i;
			if(i < argc)
			{
				ipAddress = argv[i];
			}
			else
			{
				printf("error parsing --host\n");
				showUsage();
			}
			continue;
		}
		if(strcmp(argv[i], "--scene") == 0 || strcmp(argv[i], "-scene") == 0)
		{
			++i;
			if(i < argc)
			{
				scenePath = argv[i];
			}
			else
			{
				printf("error parsing --scene\n");
				showUsage();
			}
			continue;
		}
		if(strcmp(argv[i], "--out") == 0 || strcmp(argv[i], "-out") == 0)
		{
			++i;
			if(i < argc)
			{
				portOut = std::atoi(argv[i]);
			}
			else
			{
				printf("error parsing --out\n");
				showUsage();
			}
			continue;
		}
		if(strcmp(argv[i], "--in") == 0 || strcmp(argv[i], "-in") == 0)
		{
			++i;
			if(i < argc)
			{
				portIn = std::atoi(argv[i]);
			}
			else
			{
				printf("error parsing --in\n");
				showUsage();
			}
			continue;
		}
		if(strcmp(argv[i], "--port") == 0 || strcmp(argv[i], "-port") == 0)
		{
			++i;
			if(i < argc)
			{
				bidrectionalPort = std::atoi(argv[i]);
			}
			else
			{
				printf("error parsing --port\n");
				showUsage();
			}
			continue;
		}

		if(strcmp(argv[i], "--json") == 0 || strcmp(argv[i], "-json") == 0)
		{
			++i;
			if(i < argc)
			{
				jsonPath = argv[i];
			}
			else
			{
				printf("error parsing --json\n");
				showUsage();
			}
			continue;
		}

		if(strcmp(argv[i], "-help") == 0 ||
		   strcmp(argv[i], "--help") == 0)
		{
			showUsage();
		}

		printf("Unrecognized option: %s\n", argv[i]);
		showUsage();
	}

	if(bidrectionalPort == 0 && portOut == 0 && portIn == 0)
	{
		printf("Arguments --port or [--in and --out] should be set.\n");
		showUsage();
	}
	else if(portOut == 0 && bidrectionalPort == 0)
	{
		printf("Argument --out should be set.\n");
		showUsage();
	}
	else if(portIn == 0 && bidrectionalPort == 0)
	{
		printf("Argument --in should be set.\n");
		showUsage();
	}
	else if(scenePath.isEmpty())
	{
		printf("Argument --scene should be set.\n");
		showUsage();
	}

	if(ipAddress.isEmpty())
	{
		ipAddress = QHostAddress(QHostAddress::LocalHost).toString();
	}

	cv::Mat image = cv::imread(scenePath.toStdString());
	if(image.empty())
	{
		printf("Cannot read image from \"%s\".\n", scenePath.toStdString().c_str());
		showUsage();
	}

	QCoreApplication app(argc, argv);
	QTcpSocket request;
	TcpResponse response;

	QObject::connect(&response, SIGNAL(detectionReceived()), &app, SLOT(quit()));
	QObject::connect(&response, SIGNAL(disconnected()), &app, SLOT(quit()));
	QObject::connect(&response, SIGNAL(error(QAbstractSocket::SocketError)), &app, SLOT(quit()));

	QTcpSocket * requestPtr = &request;
	if(bidrectionalPort == 0)
	{
		QObject::connect(&request, SIGNAL(disconnected()), &app, SLOT(quit()));
		QObject::connect(&request, SIGNAL(error(QAbstractSocket::SocketError)), &app, SLOT(quit()));

		request.connectToHost(ipAddress, portOut);
		response.connectToHost(ipAddress, portIn);

		if(!request.waitForConnected())
		{
			printf("ERROR: Unable to connect to %s:%d\n", ipAddress.toStdString().c_str(), portOut);
			return -1;
		}
	}
	else
	{
		printf("Using bidirectional port\n");
		requestPtr = &response;
		response.connectToHost(ipAddress, bidrectionalPort);
	}


	if(!response.waitForConnected())
	{
		printf("ERROR: Unable to connect to %s:%d\n", ipAddress.toStdString().c_str(), bidrectionalPort?bidrectionalPort:portIn);
		return -1;
	}

	// publish image
	std::vector<unsigned char> buf;
	cv::imencode(".png", image, buf);

	QByteArray block;
	QDataStream out(&block, QIODevice::WriteOnly);
	out.setVersion(QDataStream::Qt_4_0);
	out << (quint64)0;
	if(bidrectionalPort)
	{
		out << (quint32)find_object::TcpServer::kDetectObject;
	}
	out.writeRawData((char*)buf.data(), (int)buf.size());
	out.device()->seek(0);
	out << (quint64)(block.size() - sizeof(quint64));

	qint64 bytes = requestPtr->write(block);
	printf("Image published (%d bytes), waiting for response...\n", (int)bytes);

	QTime time;
	time.start();

	// wait for response
	if(bidrectionalPort)
	{
		requestPtr->waitForBytesWritten();
		response.waitForReadyRead();
	}
	else
	{
		app.exec();
	}

	if(response.dataReceived())
	{
		printf("Response received! (%d ms)\n", time.elapsed());
		// print detected objects
		if(response.info().objDetected_.size())
		{
			QList<int> ids = response.info().objDetected_.uniqueKeys();
			for(int i=0; i<ids.size(); ++i)
			{
				int count = response.info().objDetected_.count(ids[i]);
				if(count == 1)
				{
					printf("Object %d detected.\n", ids[i]);
				}
				else
				{
					printf("Object %d detected %d times.\n", ids[i], count);
				}
			}
		}
		else
		{
			printf("No objects detected.\n");
		}
		// write json
		if(!jsonPath.isEmpty())
		{
			find_object::JsonWriter::write(response.info(), jsonPath);
			printf("JSON written to \"%s\"\n", jsonPath.toStdString().c_str());
		}
	}
	else
	{
		printf("Failed to receive a response...\n");
		return -1;
	}

	return 0;
}

