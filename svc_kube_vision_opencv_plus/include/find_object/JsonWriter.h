#ifndef JSONWRITER_H_
#define JSONWRITER_H_

#include "find_object/FindObjectExp.h" // DLL export/import defines

#include "find_object/DetectionInfo.h"

namespace find_object {

class FINDOBJECT_EXP JsonWriter
{
public:
	static void write(const DetectionInfo & info, const QString & path);
};

} // namespace find_object


#endif /* JSONWRITER_H_ */
