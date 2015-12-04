##
## Auto Generated makefile by CodeLite IDE
## any manual changes will be erased      
##
## Release
ProjectName            :=sifthesaff
ConfigurationName      :=Release
WorkspacePath          := "${HOME}/webstylix/code"
ProjectPath            := "${HOME}/webstylix/code/lib/sifthesaff"
IntermediateDirectory  :=./Release
OutDir                 := $(IntermediateDirectory)
CurrentFileName        :=
CurrentFilePath        :=
CurrentFileFullPath    :=
User                   :=Siriwat Kasamwattanarote
Date                   :=04/10/15
CodeLitePath           :="${HOME}/webstylix/configurations/.codelite"
LinkerName             :=g++
SharedObjectLinkerName :=g++ -shared -fPIC
ObjectSuffix           :=.o
DependSuffix           :=.o.d
PreprocessSuffix       :=.i
DebugSwitch            :=-g 
IncludeSwitch          :=-I
LibrarySwitch          :=-l
OutputSwitch           :=-o 
LibraryPathSwitch      :=-L
PreprocessorSwitch     :=-D
SourceSwitch           :=-c 
OutputFile             :=$(IntermediateDirectory)/lib$(ProjectName).a
Preprocessors          :=
ObjectSwitch           :=-o 
ArchiveOutputSwitch    := 
PreprocessOnlySwitch   :=-E
ObjectsFileList        :="sifthesaff.txt"
PCHCompileFlags        :=
MakeDirCommand         :=mkdir -p
LinkOptions            :=  
IncludePath            :=  $(IncludeSwitch). $(IncludeSwitch)${HOME}/local/include 
IncludePCH             := 
RcIncludePath          := 
Libs                   := 
ArLibs                 :=  
LibPath                := $(LibraryPathSwitch). $(LibraryPathSwitch)${HOME}/local/lib 

##
## Common variables
## AR, CXX, CC, AS, CXXFLAGS and CFLAGS can be overriden using an environment variables
##
AR       := ar rcu
CXX      := g++
CC       := gcc
CXXFLAGS :=  -O3 -fopenmp -std=c++11 $(Preprocessors)
CFLAGS   :=   $(Preprocessors)
ASFLAGS  := 
AS       := as


##
## User defined environment variables
##
CodeLiteDir:=/usr/share/codelite
Objects0=$(IntermediateDirectory)/AffineHessianDetector.cpp$(ObjectSuffix) $(IntermediateDirectory)/SIFThesaff.cpp$(ObjectSuffix) $(IntermediateDirectory)/affine.cpp$(ObjectSuffix) $(IntermediateDirectory)/helpers.cpp$(ObjectSuffix) $(IntermediateDirectory)/pyramid.cpp$(ObjectSuffix) $(IntermediateDirectory)/siftdesc.cpp$(ObjectSuffix) 



Objects=$(Objects0) 

##
## Main Build Targets 
##
.PHONY: all clean PreBuild PrePreBuild PostBuild MakeIntermediateDirs
all: $(IntermediateDirectory) $(OutputFile)

$(OutputFile): $(Objects)
	@$(MakeDirCommand) $(@D)
	@echo "" > $(IntermediateDirectory)/.d
	@echo $(Objects0)  > $(ObjectsFileList)
	$(AR) $(ArchiveOutputSwitch)$(OutputFile) @$(ObjectsFileList) $(ArLibs)
	@$(MakeDirCommand) "${HOME}/webstylix/code/.build-release"
	@echo rebuilt > "${HOME}/webstylix/code/.build-release/sifthesaff"

MakeIntermediateDirs:
	@test -d ./Release || $(MakeDirCommand) ./Release


./Release:
	@test -d ./Release || $(MakeDirCommand) ./Release

PreBuild:


##
## Objects
##
$(IntermediateDirectory)/AffineHessianDetector.cpp$(ObjectSuffix): AffineHessianDetector.cpp $(IntermediateDirectory)/AffineHessianDetector.cpp$(DependSuffix)
	$(CXX) $(IncludePCH) $(SourceSwitch) "AffineHessianDetector.cpp" $(CXXFLAGS) $(ObjectSwitch)$(IntermediateDirectory)/AffineHessianDetector.cpp$(ObjectSuffix) $(IncludePath)
$(IntermediateDirectory)/AffineHessianDetector.cpp$(DependSuffix): AffineHessianDetector.cpp
	@$(CXX) $(CXXFLAGS) $(IncludePCH) $(IncludePath) -MG -MP -MT$(IntermediateDirectory)/AffineHessianDetector.cpp$(ObjectSuffix) -MF$(IntermediateDirectory)/AffineHessianDetector.cpp$(DependSuffix) -MM "AffineHessianDetector.cpp"

$(IntermediateDirectory)/AffineHessianDetector.cpp$(PreprocessSuffix): AffineHessianDetector.cpp
	@$(CXX) $(CXXFLAGS) $(IncludePCH) $(IncludePath) $(PreprocessOnlySwitch) $(OutputSwitch) $(IntermediateDirectory)/AffineHessianDetector.cpp$(PreprocessSuffix) "AffineHessianDetector.cpp"

$(IntermediateDirectory)/SIFThesaff.cpp$(ObjectSuffix): SIFThesaff.cpp $(IntermediateDirectory)/SIFThesaff.cpp$(DependSuffix)
	$(CXX) $(IncludePCH) $(SourceSwitch) "SIFThesaff.cpp" $(CXXFLAGS) $(ObjectSwitch)$(IntermediateDirectory)/SIFThesaff.cpp$(ObjectSuffix) $(IncludePath)
$(IntermediateDirectory)/SIFThesaff.cpp$(DependSuffix): SIFThesaff.cpp
	@$(CXX) $(CXXFLAGS) $(IncludePCH) $(IncludePath) -MG -MP -MT$(IntermediateDirectory)/SIFThesaff.cpp$(ObjectSuffix) -MF$(IntermediateDirectory)/SIFThesaff.cpp$(DependSuffix) -MM "SIFThesaff.cpp"

$(IntermediateDirectory)/SIFThesaff.cpp$(PreprocessSuffix): SIFThesaff.cpp
	@$(CXX) $(CXXFLAGS) $(IncludePCH) $(IncludePath) $(PreprocessOnlySwitch) $(OutputSwitch) $(IntermediateDirectory)/SIFThesaff.cpp$(PreprocessSuffix) "SIFThesaff.cpp"

$(IntermediateDirectory)/affine.cpp$(ObjectSuffix): affine.cpp $(IntermediateDirectory)/affine.cpp$(DependSuffix)
	$(CXX) $(IncludePCH) $(SourceSwitch) "affine.cpp" $(CXXFLAGS) $(ObjectSwitch)$(IntermediateDirectory)/affine.cpp$(ObjectSuffix) $(IncludePath)
$(IntermediateDirectory)/affine.cpp$(DependSuffix): affine.cpp
	@$(CXX) $(CXXFLAGS) $(IncludePCH) $(IncludePath) -MG -MP -MT$(IntermediateDirectory)/affine.cpp$(ObjectSuffix) -MF$(IntermediateDirectory)/affine.cpp$(DependSuffix) -MM "affine.cpp"

$(IntermediateDirectory)/affine.cpp$(PreprocessSuffix): affine.cpp
	@$(CXX) $(CXXFLAGS) $(IncludePCH) $(IncludePath) $(PreprocessOnlySwitch) $(OutputSwitch) $(IntermediateDirectory)/affine.cpp$(PreprocessSuffix) "affine.cpp"

$(IntermediateDirectory)/helpers.cpp$(ObjectSuffix): helpers.cpp $(IntermediateDirectory)/helpers.cpp$(DependSuffix)
	$(CXX) $(IncludePCH) $(SourceSwitch) "helpers.cpp" $(CXXFLAGS) $(ObjectSwitch)$(IntermediateDirectory)/helpers.cpp$(ObjectSuffix) $(IncludePath)
$(IntermediateDirectory)/helpers.cpp$(DependSuffix): helpers.cpp
	@$(CXX) $(CXXFLAGS) $(IncludePCH) $(IncludePath) -MG -MP -MT$(IntermediateDirectory)/helpers.cpp$(ObjectSuffix) -MF$(IntermediateDirectory)/helpers.cpp$(DependSuffix) -MM "helpers.cpp"

$(IntermediateDirectory)/helpers.cpp$(PreprocessSuffix): helpers.cpp
	@$(CXX) $(CXXFLAGS) $(IncludePCH) $(IncludePath) $(PreprocessOnlySwitch) $(OutputSwitch) $(IntermediateDirectory)/helpers.cpp$(PreprocessSuffix) "helpers.cpp"

$(IntermediateDirectory)/pyramid.cpp$(ObjectSuffix): pyramid.cpp $(IntermediateDirectory)/pyramid.cpp$(DependSuffix)
	$(CXX) $(IncludePCH) $(SourceSwitch) "pyramid.cpp" $(CXXFLAGS) $(ObjectSwitch)$(IntermediateDirectory)/pyramid.cpp$(ObjectSuffix) $(IncludePath)
$(IntermediateDirectory)/pyramid.cpp$(DependSuffix): pyramid.cpp
	@$(CXX) $(CXXFLAGS) $(IncludePCH) $(IncludePath) -MG -MP -MT$(IntermediateDirectory)/pyramid.cpp$(ObjectSuffix) -MF$(IntermediateDirectory)/pyramid.cpp$(DependSuffix) -MM "pyramid.cpp"

$(IntermediateDirectory)/pyramid.cpp$(PreprocessSuffix): pyramid.cpp
	@$(CXX) $(CXXFLAGS) $(IncludePCH) $(IncludePath) $(PreprocessOnlySwitch) $(OutputSwitch) $(IntermediateDirectory)/pyramid.cpp$(PreprocessSuffix) "pyramid.cpp"

$(IntermediateDirectory)/siftdesc.cpp$(ObjectSuffix): siftdesc.cpp $(IntermediateDirectory)/siftdesc.cpp$(DependSuffix)
	$(CXX) $(IncludePCH) $(SourceSwitch) "siftdesc.cpp" $(CXXFLAGS) $(ObjectSwitch)$(IntermediateDirectory)/siftdesc.cpp$(ObjectSuffix) $(IncludePath)
$(IntermediateDirectory)/siftdesc.cpp$(DependSuffix): siftdesc.cpp
	@$(CXX) $(CXXFLAGS) $(IncludePCH) $(IncludePath) -MG -MP -MT$(IntermediateDirectory)/siftdesc.cpp$(ObjectSuffix) -MF$(IntermediateDirectory)/siftdesc.cpp$(DependSuffix) -MM "siftdesc.cpp"

$(IntermediateDirectory)/siftdesc.cpp$(PreprocessSuffix): siftdesc.cpp
	@$(CXX) $(CXXFLAGS) $(IncludePCH) $(IncludePath) $(PreprocessOnlySwitch) $(OutputSwitch) $(IntermediateDirectory)/siftdesc.cpp$(PreprocessSuffix) "siftdesc.cpp"


-include $(IntermediateDirectory)/*$(DependSuffix)
##
## Clean
##
clean:
	$(RM) -r ./Release/


