"module" module
"processor" useModule
"Owner" useModule
"variable" useModule

resolveAndProcess: [
  qualifiedPath:;
  realtivePath:;
  processor:;

  options: processor.options;
  result: Int32 Array;
  qualifiedPath "DEFINITIONS" = [
    0 @result.pushBack
  ] when
  result
];

processModule: [
  source:;
  moduleName:;
  modulePath:;
  processor:;

  parserResult: ParserResult;
  newModuleId: processor.modules2 fieldCount;
  @parserResult source makeStringView newModuleId parseString
  parserResult.success not [
    (modulePath moduleName "(" parserResult.errorInfo.position.line "," makeStringView parserResult.errorInfo.position.column "): syntax error, "
      parserResult.errorInfo.message) assembleString compilerError
  ] [
    newModule: Module;
    @modulePath move copy @newModule.!path
    @moduleName move copy @newModule.!name
    @newModule move @processor.@modules2.pushBack
    newModule: @processor.@modules2.last;

    processor.options.debug [
      debugInfoId: newModuleId moduleFullPath addModuleDebugInfo;
      debugInfoId @newModule.@debugInfoId set
    ] when

    @parserResult optimizeLabels
    firstUnprocessedNode: @parserResult @processor.@multiParserResult appendParserResult;
    firstUnprocessedNode copy @processor.@multiParserResult [
      id:; name:;
      name makeNameInfo move owner @processor.@nameInfos.pushBack
      [id 1 + processor.nameInfos.dataSize =] "nameInfos size mismatch" assert
    ] optimizeNames

    firstUnprocessedNode newModuleId @processor processTopModuleNode
    FALSE @newModule.!beingProcessed
  ] if

  newModuleId
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
];

