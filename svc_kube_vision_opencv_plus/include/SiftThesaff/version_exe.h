#ifndef siftexe_VERSION_H
#define siftexe_VERSION_H

namespace siftexe_AutoVersion{
	
	//Date Version Types
	static const char siftexe_DATE[] = "21";
	static const char siftexe_MONTH[] = "11";
	static const char siftexe_YEAR[] = "2014";
	static const char siftexe_UBUNTU_VERSION_STYLE[] =  "14.11";
	
	//Software Status
	static const char siftexe_STATUS[] =  "Alpha";
	static const char siftexe_STATUS_SHORT[] =  "a";
	
	//Standard Version Type
	static const long siftexe_MAJOR  = 1;
	static const long siftexe_MINOR  = 0;
	static const long siftexe_BUILD  = 52;
	static const long siftexe_REVISION  = 56;
	
	//Miscellaneous Version Types
	static const long siftexe_BUILDS_COUNT  = 14;
	#define siftexe_RC_FILEVERSION 1,0,52,56
	#define siftexe_RC_FILEVERSION_STRING "1, 0, 52, 56\0"
	static const char siftexe_FULLVERSION_STRING [] = "1.0.52.56";
	
	//These values are to keep track of your versioning state, don't modify them.
	static const long siftexe_BUILD_HISTORY  = 12;
	

}
#endif //siftexe_VERSION_H
