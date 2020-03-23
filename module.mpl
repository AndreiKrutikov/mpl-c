"module" module
"Owner" useModule
"String" useModule

resolveAndProcess: [
  splittedQualifiedPath:;
  relativePath:;
  processor:;

  pathSuffix: String;
  splittedQualifiedPath.getSize 1 - [
    (i splittedQualifiedPath @ "/") @pathSuffix.catMany
  ] times

  (splittedQualifiedPath.last ".mpl") @pathSuffix.catMany

  result: Int32 Int32 HashTable;
  splittedQualifiedPath.getSize 1 = [ splittedQualifiedPath.last "DEFINITIONS" =] && [
    0 0 @result.insert
  ] when

  tryLoad: [
    pathPrefix:;
    fullPath: (pathPrefix pathSuffix) assembleString;
    loadInputFileResult: fullPath loadString;
    loadInputFileResult.success [
      source: loadInputFileResult.data;
      fr: source processor.moduleContent2ModuleId.find;
      fr.success [
        fr.value processor.modules2.at.beingProcessed [
          ("module circular reference, " fullPath " module is already being processed") assembleString compilerError
        ] [
          fr.value result.find.success not [
            fr.value 0 @result.insert
          ] when
        ] if
      ] [
        @processor fullPath splitFullPath loadInputFileResult.data processModule
        compilable [
          moduleId:;
          moduleId result.find.success not [
            moduleId 0 @result.insert
          ] when
        ] [
          drop
        ] if
      ] if
    ] when
  ];

  options: processor.options;
  relativePath tryLoad
  options.includePaths [
    includePath:;
    compilable [
      includePath tryLoad
    ] when
  ] each

  uniqueResults: Int32 Array;
  result [
    .key copy @uniqueResults.pushBack
  ] each
  uniqueResults
];

processModule: [
  source:;
  moduleName:;
  modulePath:;
  processor:;

  parserResult: ParserResult;
  newModuleId: processor.modules2.getSize;
  @parserResult source makeStringView newModuleId parseString
  parserResult.success not [
    (modulePath moduleName "(" parserResult.errorInfo.position.line "," makeStringView parserResult.errorInfo.position.column "): syntax error, "
      parserResult.errorInfo.message) assembleString compilerError
  ] [
    newModule: Module;
    @modulePath move copy @newModule.!path
    @moduleName move copy @newModule.!name

    processor.options.debug [
      debugInfoId: newModuleId moduleFullPath addModuleDebugInfo;
      debugInfoId @newModule.@debugInfoId set
    ] when

    @newModule move @processor.@modules2.pushBack
    @parserResult optimizeLabels
    firstUnprocessedNode: @parserResult @processor.@multiParserResult appendParserResult;
    firstUnprocessedNode copy @processor.@multiParserResult [
      id:; name:;
      name makeNameInfo move owner @processor.@nameInfos.pushBack
      [id 1 + processor.nameInfos.dataSize =] "nameInfos size mismatch" assert
    ] optimizeNames

    topNodeIndex: firstUnprocessedNode newModuleId @processor processTopModuleNode;
    newModule: @processor.@modules2.last;
    source newModuleId copy @processor.@moduleContent2ModuleId.insert
    FALSE @newModule.!beingProcessed
    topNodeIndex copy @newModule.!topNodeIndex
  ] if

  newModuleId copy
];

processTopModuleNode: [
  processor:;
  newModuleId:;
  parserNodeId:;
  processorResult: @processor.@processorResult;
  cachedErrorInfoSize: @processor.@cachedErrorInfoSize;

  newModuleId copy @processor.!currentlyProcessedModule

  topModuleNode: parserNodeId processor.multiParserResult.nodes.at;
  rootPositionInfo: CompilerPositionInfo;
  1 dynamic @rootPositionInfo.@column set
  1 dynamic @rootPositionInfo.@line set
  0 dynamic @rootPositionInfo.@offset set
  newModuleId dynamic @rootPositionInfo.@moduleId set

  processorResult.globalErrorInfo.getSize @cachedErrorInfoSize set
  topNodeIndex: StringView 0 NodeCaseCode @processor topModuleNode rootPositionInfo CFunctionSignature astNodeToCodeNode;

  processorResult.success not [
    @processorResult.@errorInfo move @processorResult.@globalErrorInfo.pushBack
  ] when

  processorResult.globalErrorInfo.getSize 0 > [
    FALSE @processorResult.@success set
  ] when

  topNodeIndex copy
];

