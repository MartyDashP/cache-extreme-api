ROUTINE ExtremeAPI.general [Type=INC]

#Define E(%arg) %arg

#Define CollectSortedClassProperties(%props,%comClass) d $$$E(##class(ExtremeAPI.Functions).CollectSortedClassProperties(%props,%comClass))

#Define IsSupportedObjectTypeProperty(%arg) $$$E(##class(ExtremeAPI.Functions).IsSupportedObjectTypeProperty(%arg))

#Define IsDataTypeProperty(%arg) $$$E(##class(ExtremeAPI.Functions).IsDataTypeProperty(%arg))

#Define IsCollectionProperty(%arg) $$$E(##class(ExtremeAPI.Functions).IsCollectionProperty(%arg))
