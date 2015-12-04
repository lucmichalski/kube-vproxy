#############################################################################
#                                                                           #
#  Crypto - C++ Crypto/SSL Framework                                        #
#                                                                           #
#  Copyright (c) 2012 Timo Röhling.                                         #
#                                                                           #
#  Permission is hereby granted, free of charge, to any person obtaining a  #
#  copy of this software and associated documentation files (the            #
#  "Software"), to deal in the Software without restriction, including      #
#  without limitation the rights to use, copy, modify, merge, publish,      #
#  distribute, sublicense, and/or sell copies of the Software, and to       #
#  permit persons to whom the Software is furnished to do so, subject to    #
#  the following conditions:                                                #
#                                                                           #
#  The above copyright notice and this permission notice shall be included  #
#  in all copies or substantial portions of the Software.                   #
#                                                                           #
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS  #
#  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF               #
#  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.   #
#  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY     #
#  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,     #
#  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE        #
#  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                   #
#                                                                           #
#############################################################################

GET_FILENAME_COMPONENT(_crypto_prefix "${CMAKE_CURRENT_LIST_FILE}" PATH)

INCLUDE(${_crypto_prefix}/crypto-targets.cmake)

GET_TARGET_PROPERTY(_crypto_type crypto TYPE)
SET(CRYPTO_DEFINITIONS)
IF(${_crypto_type} MATCHES "SHARED")
SET(CRYPTO_DEFINITIONS "-DCRYPTO_SHARED")
ENDIF(${_crypto_type} MATCHES "SHARED")

GET_FILENAME_COMPONENT(_crypto_prefix "${_crypto_prefix}" PATH)
GET_FILENAME_COMPONENT(_crypto_prefix "${_crypto_prefix}" PATH)
GET_FILENAME_COMPONENT(_crypto_prefix "${_crypto_prefix}" PATH)

SET(CRYPTO_INCLUDE_DIRS "${_crypto_prefix}/include")

UNSET(_crypto_prefix)
UNSET(_crypto_type)

