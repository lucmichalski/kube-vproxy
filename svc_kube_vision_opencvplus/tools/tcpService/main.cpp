/*

	kubeVision - OpenCV (part of the KubeVision)
	Modified by: Luc Michalski - 2015
	New features: Web-service and distributed search
	Based on: Find-Object - Mathieu Labbe - IntRoLab - Universite de Sherbrooke
	URL: https://github.com/introlab/find-object

*/

#include <QtNetwork/QNetworkInterface>
#include <QtNetwork/QTcpSocket>
#include <QtCore/QCoreApplication>
#include <QtCore/QFile>
#include <QtCore/QFileInfo>
#include <QtCore/QTime>
#include <opencv2/opencv.hpp>
#include <find_object/TcpServer.h>

void showUsage()
{
	printf("\ntcpService [options] port\n"
			"  Options:\n"
			"    --add \"image.png\" #    Add object (file name + id). Set id=0\n"
			"                           will make the server generating an id.\n"
			"    --remove #             Remove object by ID.\n"
			"    --host #.#.#.#         Set host address.\n"
			"    --help                 Show this help.\n"
			"  Examples:\n"
			"     Add:    $ tcpService --add image.png 1 --host 127.0.0.1 4000\n"
			"     Remove: $ tcpService --remove 1 --host 127.0.0.1 4000\n");
	exit(-1);
}

int main(int argc, char * argv[])
{
	QString ipAddress;
	QString fileName;
	int addId = 0;
	int removeId = -1;
	quint16 port = 0;

	for(int i=1; i<argc-1; ++i)
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
		if(strcmp(argv[i], "--add") == 0 || strcmp(argv[i], "-add") == 0)
		{
			++i;
			if(i < argc-1)
			{
				fileName = argv[i];
				++i;
				if(i < argc)
				{
					addId = atoi(argv[i]);
				}
				else
				{
					printf("error parsing --add\n");
				}
			}
			else
			{
				printf("error parsing --add\n");
				showUsage();
			}
			continue;
		}
		if(strcmp(argv[i], "--remove") == 0 || strcmp(argv[i], "-remove") == 0)
		{
			++i;
			if(i < argc)
			{
				removeId = std::atoi(argv[i]);
			}
			else
			{
				printf("error parsing --remove\n");
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

	port = atoi(argv[argc-1]);

	if(fileName.isEmpty() && removeId == -1)
	{
		printf("Arguments --add or --remove should be set.\n");
		showUsage();
	}
	else if(port <=0)
	{
		printf("Port should be set!\n");
		showUsage();
	}

	if(ipAddress.isEmpty())
	{
		ipAddress = QHostAddress(QHostAddress::LocalHost).toString();
	}

	cv::Mat image;
	if(!fileName.isEmpty())
	{
		image = cv::imread(fileName.toStdString());
		if(image.empty())
		{
			printf("Cannot read image from \"%s\".\n", fileName.toStdString().c_str());
			showUsage();
		}
		fileName = QFileInfo(fileName).fileName();
	}

	QCoreApplication app(argc, argv);
	QTcpSocket request;

	QObject::connect(&request, SIGNAL(disconnected()), &app, SLOT(quit()));
	QObject::connect(&request, SIGNAL(error(QAbstractSocket::SocketError)), &app, SLOT(quit()));

	printf("Connecting to \"%s:%d\"...\n", ipAddress.toStdString().c_str(), port);
	request.connectToHost(ipAddress, port);

	if(!request.waitForConnected())
	{
		printf("Connecting to \"%s:%d\"... connection failed!\n", ipAddress.toStdString().c_str(), port);
		return -1;
	}
	else
	{
		printf("Connecting to \"%s:%d\"... connected!\n", ipAddress.toStdString().c_str(), port);
	}

	QByteArray block;
	QDataStream out(&block, QIODevice::WriteOnly);
	out.setVersion(QDataStream::Qt_4_0);
	out << (quint64)0;

	if(!image.empty())
	{
		// publish image
		std::vector<unsigned char> buf;
		cv::imencode(".png", image, buf);

		out << (quint32)find_object::TcpServer::kAddObject;
		out << addId;
		out << fileName;
		quint64 imageSize = buf.size();
		out << imageSize;
		out.writeRawData((char*)buf.data(), (int)buf.size());
		printf("Add object %d \"%s\"\n", addId, fileName.toStdString().c_str());
	}
	else if(removeId)
	{
		out << (quint32)find_object::TcpServer::kRemoveObject;
		out << removeId;
		printf("Remove object %d\n", removeId);
	}

	out.device()->seek(0);
	out << (quint64)(block.size() - sizeof(quint64));

	qint64 bytes = request.write(block);
	printf("Service published (%d bytes)!\n", (int)bytes);
	request.waitForBytesWritten();
	request.waitForReadyRead();

	return 0;
}

