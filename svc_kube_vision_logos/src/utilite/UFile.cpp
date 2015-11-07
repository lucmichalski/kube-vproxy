/*
Copyright (c) 2015, Michalski Luc
*/

#include "utilite/UFile.h"

#include <fstream>
#include "utilite/UStl.h"

bool UFile::exists(const std::string &filePath)
{
    bool fileExists = false;
    std::ifstream in(filePath.c_str(), std::ios::in);
    if (in.is_open())
    {
        fileExists = true;
        in.close();   
    }
    return fileExists;
}

long UFile::length(const std::string &filePath)
{
    long fileSize = 0;
    FILE* fp = 0;
#ifdef _MSC_VER
    fopen_s(&fp, filePath.c_str(), "rb");
#else
    fp = fopen(filePath.c_str(), "rb");
#endif
    if(fp == NULL)
    {
        return 0;
    }

    fseek(fp , 0 , SEEK_END);
    fileSize = ftell(fp);
    fclose(fp);

    return fileSize;
}

int UFile::erase(const std::string &filePath)
{
    return remove(filePath.c_str());
}

int UFile::rename(const std::string &oldFilePath,
                     const std::string &newFilePath)
{
    return ::rename(oldFilePath.c_str(), newFilePath.c_str());
}

std::string UFile::getName(const std::string & filePath)
{
	std::string fullPath = filePath;
	std::string name;
	for(int i=(int)fullPath.size()-1; i>=0; --i)
	{
		if(fullPath[i] == '/' || fullPath[i] == '\\')
		{
			break;
		}
		else
		{
			name.insert(name.begin(), fullPath[i]);
		}
	}
	return name;
}

std::string UFile::getExtension(const std::string &filePath)
{
	std::list<std::string> list = uSplit(filePath, '.');
	if(list.size())
	{
		return list.back();
	}
	return "";
}
