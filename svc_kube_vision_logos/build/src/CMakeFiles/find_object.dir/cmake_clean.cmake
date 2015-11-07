file(REMOVE_RECURSE
  "../../bin/libfind_objectd.pdb"
  "../../bin/libfind_objectd.dylib"
)

# Per-language clean rules from dependency scanning.
foreach(lang )
  include(CMakeFiles/find_object.dir/cmake_clean_${lang}.cmake OPTIONAL)
endforeach()
