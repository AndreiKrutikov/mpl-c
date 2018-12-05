"variable" module
"HashTable" includeModule
"String"    includeModule
"Variant"   includeModule
"Owner"     includeModule

Dirty:           [0n8 dynamic] func;
Dynamic:         [1n8 dynamic] func;
Weak:            [2n8 dynamic] func;
Static:          [3n8 dynamic] func;
Virtual:         [4n8 dynamic] func;

NameCaseInvalid:               [ 0n8 dynamic] func;
NameCaseBuiltin:               [ 1n8 dynamic] func;
NameCaseLocal:                 [ 2n8 dynamic] func;
NameCaseFromModule:            [ 3n8 dynamic] func;
NameCaseCapture:               [ 4n8 dynamic] func;

NameCaseSelfMember:            [ 5n8 dynamic] func;
NameCaseClosureMember:         [ 6n8 dynamic] func;
NameCaseSelfObject:            [ 7n8 dynamic] func;
NameCaseClosureObject:         [ 8n8 dynamic] func;
NameCaseSelfObjectCapture:     [ 9n8 dynamic] func;
NameCaseClosureObjectCapture:  [10n8 dynamic] func;

MemberCaseToObjectCase:        [2n8 +] func;
MemberCaseToObjectCaptureCase: [4n8 +] func;

ShadowReasonNo:      [0n8 dynamic] func;
ShadowReasonCapture: [1n8 dynamic] func;
ShadowReasonInput:   [2n8 dynamic] func;
ShadowReasonField:   [3n8 dynamic] func;
ShadowReasonPointee: [4n8 dynamic] func;

RefToVar: [{
  virtual REF_TO_VAR: ();
  varId: -1 dynamic;
  hostId: -1 dynamic;
  mutable: TRUE dynamic;
}] func;

=: ["REF_TO_VAR" has] [
  refsAreEqual
] pfunc;

hash: ["REF_TO_VAR" has] [
  refToVar:;
  refToVar.hostId 0n32 cast 67n32 * refToVar.varId 0n32 cast 17n32 * +
] pfunc;

NameInfoEntry: [{
  refToVar: RefToVar;
  startPoint: -1 dynamic; # id of node
  nameCase: NameCaseInvalid;
}] func;

Overload: [NameInfoEntry Array] func;

makeNameInfo: [{
  name: copy;
  stack: Overload Array;
}] func;

NameInfo: [String makeNameInfo] func;

VarInvalid: [ 0 static] func;
VarCond:    [ 1 static] func;
VarNat8:    [ 2 static] func;
VarNat16:   [ 3 static] func;
VarNat32:   [ 4 static] func;
VarNat64:   [ 5 static] func;
VarNatX:    [ 6 static] func;
VarInt8:    [ 7 static] func;
VarInt16:   [ 8 static] func;
VarInt32:   [ 9 static] func;
VarInt64:   [10 static] func;
VarIntX:    [11 static] func;
VarReal32:  [12 static] func;
VarReal64:  [13 static] func;
VarCode:    [14 static] func;
VarBuiltin: [15 static] func;
VarImport:  [16 static] func;
VarString:  [17 static] func;
VarRef:     [18 static] func;
VarStruct:  [19 static] func;
VarEnd:     [20 static] func;

Field: [{
  nameInfo: -1 dynamic; # NameInfo id
  nameOverload: -1 dynamic;
  refToVar: RefToVar;
}] func;

FieldArray: [Field Array] func;

Struct: [{
  fullVirtual:   FALSE dynamic;
  homogeneous:   FALSE dynamic;
  hasPreField:   FALSE dynamic;
  unableToDie:   FALSE dynamic;
  hasDestructor: FALSE dynamic;
  forgotten:     TRUE  dynamic;
  realFieldIndexes: Int32 Array;
  fields: FieldArray;
  structName: NameWithOverload; # for overloads
  structStorageSize: 0nx dynamic;
  structAlignment: 0nx dynamic;
}] func; #IDs of pointee vars

Variable: [{
  VARIABLE: ();

  mplNameId: -1 dynamic;
  irNameId: -1 dynamic;
  mplTypeId: -1 dynamic;
  irTypeId: -1 dynamic;
  storageStaticness: Static;
  staticness: Static;
  global: FALSE dynamic;
  temporary: TRUE dynamic;
  usedInHeader: FALSE dynamic;
  capturedAsMutable: FALSE dynamic;
  tref: TRUE dynamic;
  shadowReason: ShadowReasonNo;
  globalId: -1 dynamic;
  shadowBegin: RefToVar;
  shadowEnd: RefToVar;
  capturedHead: RefToVar;
  capturedTail: RefToVar;
  capturedPrev: RefToVar;
  realValue: RefToVar;
  globalDeclarationInstructionIndex: -1 dynamic;
  allocationInstructionIndex: -1 dynamic;
  getInstructionIndex: -1 dynamic;

  data: (
    Nat8             #VarInvalid
    Cond             #VarCond
    Nat64            #VarNat8
    Nat64            #VarNat16
    Nat64            #VarNat32
    Nat64            #VarNat64
    Nat64            #VarNatX
    Int64            #VarInt8
    Int64            #VarInt16
    Int64            #VarInt32
    Int64            #VarInt64
    Int64            #VarIntX
    Real64           #VarReal32
    Real64           #VarReal64
    Int32            #VarCode; id of node
    Int32            #VarBuiltin
    Int32            #VarImport
    String           #VarString
    RefToVar         #VarRef
    Struct Owner     #VarStruct
  ) Variant;

  INIT: [];
  DIE: [];
}] func;

# these functions require capture "processor"
variableIsDeleted: [
  refToVar:;
  refToVar.varId refToVar.hostId @processor.@nodes.at.get.@variables.at.assigned not
] func;

getVar: [
  refToVar:;

  [
    refToVar.hostId 0 < not [refToVar.hostId processor.nodes.dataSize <] && [
      node: refToVar.hostId @processor.@nodes.at.get;
      sz: node.variables.dataSize copy;
      refToVar.varId 0  < not [refToVar.varId sz <] && [
        refToVar.varId node.variables.at.assigned [
          TRUE
        ] [
          ("deleted var data=" refToVar.hostId ":" refToVar.varId) addLog
          FALSE
        ] if
      ] [
        ("invalid var id=" refToVar.varId " of " sz) addLog
        FALSE
      ] if
    ] [
      ("invalid host id=" refToVar.hostId " of " processor.nodes.dataSize) addLog
      FALSE
    ] if
  ] "Wrong refToVar!" assert

  refToVar.varId refToVar.hostId @processor.@nodes.at.get.@variables.at.get
] func;

getNameById: [processor.nameBuffer.at makeStringView] func;
getMplName: [getVar.mplNameId getNameById] func;
getIrName: [getVar.irNameId getNameById] func;
getMplType: [getVar.mplTypeId getNameById] func;
getIrType: [getVar.irTypeId getNameById] func;

deepPrintVar: [
  refToVar:;
  hasLogs [
    unprinted: (RefToVar 0) Array;
    (refToVar 0) @unprinted.pushBack
    [
      unprinted.dataSize 0 > [
        current: unprinted.last deref;
        curRef: 0n32 current @;
        curPad: 1n32 current @;
        @unprinted.popBack
        curVar: curRef getVar;
        curPad [" " stringMemory print] times
        ("ref is " makeStringView curRef.hostId 0 cast ":" makeStringView curRef.varId 0 cast "; tag=" makeStringView curVar.data.getTag 0 cast) printList printLF
        curVar.data.getTag VarRef = [
          (VarRef curVar.data.get curPad 1 +) @unprinted.pushBack
        ] [
          curVar.data.getTag VarStruct = [
            struct: VarStruct curVar.data.get.get;
            f: 0 dynamic;
            [
              f struct.fields.dataSize < [
                (f struct.fields.at.refToVar curPad 1 +) @unprinted.pushBack
                f 1 + @f set TRUE
              ] &&
            ] loop
          ] when
        ] if
        TRUE
      ] &&
    ] loop
  ] when
] func;

staticnessOfVar: [
  refToVar:;
  var: refToVar getVar;
  var.staticness copy
] func;

maxStaticness: [
  copy s1:;
  copy s2:;
  s1 s2 > [s1 copy][s2 copy] if
] func;

refsAreEqual: [
  refToVar1:;
  refToVar2:;
  refToVar1.hostId refToVar2.hostId = [refToVar1.varId refToVar2.varId =] &&
] func;

variablesAreSame: [
  refToVar1:;
  refToVar2:;
  #refToVar1 getVar.mplType makeStringView refToVar2 getVar.mplType makeStringView stringCompare
  refToVar1 getVar.mplTypeId refToVar2 getVar.mplTypeId = # id compare better than string compare!
] func;

isInt: [
  var: getVar;
  var.data.getTag VarInt8 =
  [var.data.getTag VarInt16 =] ||
  [var.data.getTag VarInt32 =] ||
  [var.data.getTag VarInt64 =] ||
  [var.data.getTag VarIntX =] ||
] func;

isNat: [
  var: getVar;
  var.data.getTag VarNat8 =
  [var.data.getTag VarNat16 =] ||
  [var.data.getTag VarNat32 =] ||
  [var.data.getTag VarNat64 =] ||
  [var.data.getTag VarNatX =] ||
] func;

isAnyInt: [
  refToVar:;
  refToVar isInt
  [ refToVar isNat ] ||
] func;

isReal: [
  var: getVar;
  var.data.getTag VarReal32 =
  [var.data.getTag VarReal64 =] ||
] func;

isNumber: [
  refToVar:;
  refToVar isReal
  [refToVar isAnyInt] ||
] func;

isPlain: [
  refToVar:;
  refToVar isNumber [
    var: refToVar getVar;
    var.data.getTag VarCond =
  ] ||
] func;

isTinyArg: [
  refToVar:;
  refToVar isPlain [
    var: refToVar getVar;
    var.data.getTag VarRef =
    [var.data.getTag VarString =] ||
  ] ||
] func;

isStruct: [
  var: getVar;
  var.data.getTag VarStruct =
] func;

isAutoStruct: [
  refToVar:;
  var: refToVar getVar;
  var.data.getTag VarStruct =
  [VarStruct var.data.get.get.hasDestructor copy] &&
] func;

markAsUnableToDie: [
  refToVar:;
  var: refToVar getVar;
  var.data.getTag VarStruct = [TRUE VarStruct @var.@data.get.get.@unableToDie set] when
] func;

markAsAbleToDie: [
  refToVar:;
  var: refToVar getVar;
  var.data.getTag VarStruct = [FALSE VarStruct @var.@data.get.get.@unableToDie set] when
] func;

isSingle: [
  isStruct not
] func;

getSingleDataStorageSize: [
  var: getVar;
  var.data.getTag (
    VarCond    [1nx]
    VarInt8    [1nx]
    VarInt16   [2nx]
    VarInt32   [4nx]
    VarInt64   [8nx]
    VarIntX    [processor.options.pointerSize 8nx /]
    VarNat8    [1nx]
    VarNat16   [2nx]
    VarNat32   [4nx]
    VarNat64   [8nx]
    VarNatX    [processor.options.pointerSize 8nx /]
    VarReal32  [4nx]
    VarReal64  [8nx]
    VarRef     [processor.options.pointerSize 8nx /]
    VarString  [processor.options.pointerSize 8nx /]
    VarImport  [
      "functions dont have storageSize and alignment" compilerError
      0nx
    ]
    [0nx]
  ) case
] func;

isNonrecursiveType: [
  refToVar:;
  refToVar isPlain [
    var: refToVar getVar;
    var.data.getTag VarString =
    [var.data.getTag VarCode =] ||
    [var.data.getTag VarBuiltin =] ||
    [var.data.getTag VarImport =] ||
  ] ||
] func;

isSemiplainNonrecursiveType: [
  refToVar:;
  refToVar isPlain [
    var: refToVar getVar;
    var.data.getTag VarCode =
    [var.data.getTag VarBuiltin =] ||
    [var.data.getTag VarImport =] ||
  ] ||
] func;

getPlainDataIRType: [
  var: getVar;
  result: String;
  var.data.getTag (
    VarCond  ["i1" toString @result set]
    VarInt8  ["i8" toString @result set]
    VarInt16 ["i16" toString @result set]
    VarInt32 ["i32" toString @result set]
    VarInt64 ["i64" toString @result set]
    VarIntX  [
      processor.options.pointerSize 64nx = [
        "i64" toString @result set
      ] [
        "i32" toString @result set
      ] if
    ]
    VarNat8  ["i8" toString @result set]
    VarNat16 ["i16" toString @result set]
    VarNat32 ["i32" toString @result set]
    VarNat64 ["i64" toString @result set]
    VarNatX  [
      processor.options.pointerSize 64nx = [
        "i64" toString @result set
      ] [
        "i32" toString @result set
      ] if
    ]
    VarReal32 ["float" toString @result set]
    VarReal64 ["double" toString @result set]
    [
      ("Tag = " var.data.getTag) addLog
      [FALSE] "Unknown plain struct while getting IR type" assert
    ]
  ) case

  @result
] func;

getPlainDataMPLType: [
  var: getVar;
  result: String;
  var.data.getTag (
    VarCond   ["i1" toString @result set]
    VarInt8   ["i8" toString @result set]
    VarInt16  ["i16" toString @result set]
    VarInt32  ["i32" toString @result set]
    VarInt64  ["i64" toString @result set]
    VarIntX   ["ix" toString @result set]
    VarNat8   ["n8" toString @result set]
    VarNat16  ["n16" toString @result set]
    VarNat32  ["n32" toString @result set]
    VarNat64  ["n64" toString @result set]
    VarNatX   ["nx" toString @result set]
    VarReal32 ["r32" toString @result set]
    VarReal64 ["r64" toString @result set]
    [
      ("Tag = " var.data.getTag) addLog
      [FALSE] "Unknown plain struct MPL type" assert
    ]
  ) case

  @result
] func;

getNonrecursiveDataIRType: [
  refToVar:;
  refToVar isPlain [
    refToVar getPlainDataIRType
  ] [
    result: String;
    var: refToVar getVar;
    var.data.getTag VarString = [
      "i8*" toString @result set
    ] [
      var.data.getTag VarImport = [
        VarImport var.data.get getFuncIrType toString @result set
      ] [
        var.data.getTag VarCode = [var.data.getTag VarBuiltin =] ||  [
          "ERROR" toString @result set
        ] [
          "Unknown nonrecursive struct" makeStringView compilerError
        ] if
      ] if
    ] if
    @result
  ] if
] func;

getNonrecursiveDataMPLType: [
  refToVar:;
  refToVar isPlain [
    refToVar getPlainDataMPLType
  ] [
    result: String;
    var: refToVar getVar;
    var.data.getTag VarString = [
      "s" toString @result set
    ] [
      var.data.getTag VarCode = [
        "c" toString @result set
      ] [
        var.data.getTag VarBuiltin = [
          "b" toString @result set
        ] [
          var.data.getTag VarImport = [
            ("F" VarImport var.data.get getFuncMplType) assembleString @result set
          ] [
            "Unknown nonrecursive struct" makeStringView compilerError
          ] if
        ] if
      ] if
    ] if
    @result
  ] if
] func;

getStructStorageSize: [
  refToVar:;
  var: refToVar getVar;
  struct: VarStruct var.data.get.get;
  struct.structStorageSize copy
] func;

makeStructStorageSize: [
  refToVar:;
  result: 0nx;

  var: refToVar getVar;
  struct: VarStruct @var.@data.get.get;
  maxA: 1nx;
  j: 0;
  [
    j struct.fields.dataSize < [
      curField: j struct.fields.at;
      curField.refToVar isVirtual not [
        curS: curField.refToVar getStorageSize;
        curA: curField.refToVar getAlignment;
        result
        curA + 1nx - curA 1nx - not and
        curS +
        @result set

        curA maxA > [curA @maxA set] when
      ] when
      j 1 + @j set TRUE
    ] &&
  ] loop

  result
  maxA + 1nx - maxA 1nx - not and
  @result set

  result @struct.@structStorageSize set
] func;

getStorageSize: [
  refToVar:;
  refToVar isSingle [
    refToVar getSingleDataStorageSize
  ] [
    refToVar getStructStorageSize
  ] if
] func;

getStructAlignment: [
  refToVar:;
  var: refToVar getVar;
  struct: VarStruct var.data.get.get;
  struct.structAlignment copy
] func;

makeStructAlignment: [
  refToVar:;
  result: 0nx;

  var: refToVar getVar;
  struct: VarStruct @var.@data.get.get;
  j: 0;
  [
    j struct.fields.dataSize < [
      curField: j struct.fields.at;
      curField.refToVar isVirtual not [
        curA: curField.refToVar getAlignment;
        result curA < [curA @result set] when
      ] when
      j 1 + @j set TRUE
    ] &&
  ] loop
  result @struct.@structAlignment set
] func;

getAlignment: [
  refToVar:;
  refToVar isSingle [
    refToVar getSingleDataStorageSize
  ] [
    refToVar getStructAlignment
  ] if
] func;

isGlobal: [
  refToVar:;
  var: refToVar getVar;
  var.global copy
] func;

unglobalize: [
  refToVar:;
  var: refToVar getVar;
  var.global [
    FALSE @var.@global set
    -1 dynamic @var.@globalId set
    refToVar makeVariableIRName
  ] when
] func;

untemporize: [
  refToVar:;
  var: refToVar getVar;
  FALSE @var.@temporary set
] func;

fullUntemporize: [
  refToVar:;
  var: refToVar getVar;
  FALSE @var.@temporary set
  var.data.getTag VarStruct = [
    FALSE VarStruct @var.@data.get.get.@forgotten set
  ] when
] func;

isVirtualRef: [
  refToVar:;
  var: refToVar getVar;
  var.data.getTag VarRef = [var.staticness Virtual =] &&
] func;

isVirtualType: [
  refToVar:;

  var: refToVar getVar;
  var.data.getTag VarBuiltin =
  #[var.data.getTag VarImport =] ||
  [var.data.getTag VarCode =] ||
  [var.data.getTag VarStruct = [VarStruct var.data.get.get.fullVirtual copy] &&] ||
  [refToVar isVirtualRef] ||
] func;

isVirtual: [
  refToVar:;

  var: refToVar getVar;
  var.staticness Virtual =
  [refToVar isVirtualType] ||
] func;

noMatterToCopy: [
  refToVar:;
  refToVar isVirtual [refToVar isAutoStruct not] &&
  #ref r:; FALSE
] func;

isVirtualField: [
  refToVar:;

  var: refToVar getVar;
  var.staticness Virtual =
  [refToVar isVirtualType] ||
] func;

isForgotten: [
  refToVar:;
  var: refToVar getVar;
  var.data.getTag VarStruct = [
    VarStruct var.data.get.get.forgotten copy
  ] [
    FALSE
  ] if
] func;

getVirtualValue: [
  refToVar:;
  recursive
  var: refToVar getVar;
  result: String;
  var.data.getTag (
    VarStruct [
      "{" @result.cat
      struct: VarStruct var.data.get.get;

      struct.fields [
        pair:;
        pair.index 0 > ["," @result.cat] when
        pair.value.refToVar getVirtualValue @result.cat
      ] each
      "}" @result.cat
    ]

    VarString  [VarString var.data.get makeStringView getStringImplementation @result set]
    VarCode    [VarCode    var.data.get @result.cat]
    VarImport  [VarImport  var.data.get @result.cat]
    VarBuiltin [VarBuiltin var.data.get @result.cat]
    VarRef     ["."                     @result.cat]
    [
      refToVar isPlain [
        refToVar getPlainConstantIR @result.cat
      ] [
        ("Tag = " var.data.getTag) addLog
        [FALSE] "Wrong type for virtual value!" assert
      ] if
    ]
  ) case

  result
] func;

makeStringId: [
  string:;
  fr: string @processor.@nameTable.find;
  fr.success [
    fr.value copy
  ] [
    result: processor.nameBuffer.dataSize copy;
    string makeStringView result @processor.@nameTable.insert
    @string move @processor.@nameBuffer.pushBack
    result
  ] if
] func;

makeTypeAliasId: [
  irTypeName:;

  irTypeName.getTextSize 0 > [

    fr: irTypeName makeStringView @processor.@typeNames.find;
    fr.success [
      fr.value copy
    ] [
      newTypeName: ("%type." processor.lastTypeId) assembleString;
      processor.lastTypeId 1 + @processor.@lastTypeId set

      newTypeName irTypeName createTypeDeclaration
      result: @newTypeName makeStringId;
      @irTypeName move result @processor.@typeNames.insert
      result
    ] if
  ] [
    @irTypeName makeStringId
  ] if
] func;

getFuncIrType: [
  funcIndex:;
  node: funcIndex processor.nodes.at.get;
  resultId: node.signature toString makeStringId;
  resultId getNameById
] func;

getFuncMplType: [
  funcIndex:;
  result: String;
  node: funcIndex processor.nodes.at.get;

  catData: [
    args:;

    "[" @result.cat
    i: 0;
    [
      i args.dataSize < [
        current: i args.at.refToVar;
        current getMplType                                            @result.cat
        #current.mutable ["R" makeStringView]["C" makeStringView] if   @result.cat
        i 1 + args.getSize < [
          ","                                                         @result.cat
        ] when
        i 1 + @i set TRUE
      ] &&
    ] loop
    "]" @result.cat
  ] func;

  node.matchingInfo.inputs catData
  node.outputs catData

  resultId: @result makeStringId;
  resultId getNameById
] func;

makeDbgTypeId: [
  refToVar:;
  refToVar isVirtualType not [
    var: refToVar getVar;

    fr: var.mplTypeId @processor.@debugInfo.@typeIdToDbgId.find;
    fr.success not [
      var.mplTypeId refToVar getTypeDebugDeclaration @processor.@debugInfo.@typeIdToDbgId.insert
    ] when
  ] when
] func;

makeVariableType: [
  refToVar:;

  #fill info:

  #struct.homogeneous
  #struct.fullVirtual
  #struct.hasPreField
  #struct.hasDestructor
  #struct.realFieldIndexes
  #struct.structAlignment
  #struct.structStorageSize
  #irTypeId
  #mplTypeId
  #dbgTypeId

  var: refToVar getVar;

  resultIR: String;
  resultMPL: String;

  refToVar isNonrecursiveType [
    refToVar getNonrecursiveDataIRType @resultIR set
    refToVar getNonrecursiveDataMPLType @resultMPL set
  ] [
    var.data.getTag VarRef = [
      branch: VarRef var.data.get;
      pointee: branch getVar;

      branch getIrType @resultIR.cat
      "*"  @resultIR.cat

      branch getMplType @resultMPL.cat
      branch.mutable [
        "R" @resultMPL.cat
      ] [
        "C" @resultMPL.cat
      ] if
    ] [
      var.data.getTag VarStruct = [
        branch: VarStruct @var.@data.get.get;
        realFieldCount: 0;

        @branch.@realFieldIndexes.clear
        TRUE @branch.@homogeneous set
        TRUE @branch.@fullVirtual set
        FALSE @branch.@hasPreField set
        FALSE @branch.@hasDestructor set

        i: 0 dynamic;
        [
          i branch.fields.dataSize < [
            field0: 0 branch.fields.at;
            fieldi: i branch.fields.at;

            fieldi.nameInfo processor.preNameInfo = [
              TRUE @branch.@hasPreField set
            ] when

            fieldi.refToVar isVirtualField [
              -1 @branch.@realFieldIndexes.pushBack
            ] [
              FALSE @branch.@fullVirtual set
              realFieldCount @branch.@realFieldIndexes.pushBack
              realFieldCount 1 + @realFieldCount set
            ] if

            field0.refToVar fieldi.refToVar variablesAreSame not [
              FALSE @branch.@homogeneous set
            ] when

            fieldi.nameInfo processor.dieNameInfo = [fieldi.refToVar isAutoStruct] || [
              TRUE @branch.@hasDestructor set
            ] when

            i 1 + @i set TRUE
          ] &&
        ] loop

        branch.fullVirtual [
          # do nothing, empty IR type
        ] [
          branch.homogeneous [
            ("[" branch.fields.dataSize " x " 0 branch.fields.at.refToVar getIrType "]") assembleString @resultIR.cat
          ] [
            "{" @resultIR.cat

            firstGood: TRUE;
            i: 0 dynamic;
            [
              i branch.fields.dataSize < [
                fieldi: i branch.fields.at;
                fieldi.refToVar isVirtual not [
                  firstGood not [
                    ", "  @resultIR.cat
                  ] when
                  i branch.fields.at.refToVar getIrType @resultIR.cat
                  FALSE @firstGood set
                ] when
                i 1 + @i set TRUE
              ] &&
            ] loop
            "}" @resultIR.cat
          ] if
          #@resultIR makeTypeAlias
        ] if

        "{" @resultMPL.cat
        i: 0 dynamic;
        [
          i branch.fields.dataSize < [
            curField: i branch.fields.at;
            (
              curField.nameInfo processor.nameInfos.at.name ":"
              curField.refToVar getMplType ";") assembleString @resultMPL.cat
            i 1 + @i set TRUE
          ] &&
        ] loop
        "}" @resultMPL.cat

        refToVar makeStructAlignment
        refToVar makeStructStorageSize
      ] [
        [FALSE] "Unknown variable for IR type" assert
      ] if
    ] if
  ] if

  refToVar isVirtual [
    ir: refToVar getVirtualValue;
    "'" @resultMPL.cat
    ir @resultMPL.cat
  ] when

  var.data.getTag VarStruct = [var.data.getTag VarImport =] || [
    @resultIR makeTypeAliasId @var.@irTypeId set
  ] [
    @resultIR makeStringId @var.@irTypeId set
  ] if

  @resultMPL makeStringId @var.@mplTypeId set
  processor.options.debug [refToVar makeDbgTypeId] when
] func;

bitView: [
  copy f:;
  buffer: f storageAddress (0n8 0n8 0n8 0n8 0n8 0n8 0n8 0n8) addressToReference;
  result: String;
  "0x" @result.cat
  hexToStr: (
    "0" makeStringView "1" makeStringView "2" makeStringView "3" makeStringView "4" makeStringView
    "5" makeStringView "6" makeStringView "7" makeStringView "8" makeStringView "9" makeStringView
    "A" makeStringView "B" makeStringView "C" makeStringView "D" makeStringView "E" makeStringView "F" makeStringView);
  i: 0 dynamic;
  [
    i 0ix cast 0nx cast f storageSize < [
      d: f storageSize 0ix cast 0 cast i - 1 - buffer @ 0n32 cast;
      d 4n32 rshift 0 cast @hexToStr @ @result.cat
      d 15n32 and 0 cast @hexToStr @ @result.cat
      i 1 + @i set TRUE
    ] &&
  ] loop

  result
] func;

cutValue: [
  copy tag:;
  copy value:;
  tag (
    VarNat8  [value  0n8 cast 0n64 cast]
    VarNat16 [value 0n16 cast 0n64 cast]
    VarNat32 [value 0n32 cast 0n64 cast]
    VarNatX  [value processor.options.pointerSize 32nx = [0n32 cast 0n64 cast][copy] if]
    VarInt8  [value 0i8 cast 0i64 cast]
    VarInt16 [value 0i16 cast 0i64 cast]
    VarInt32 [value 0i32 cast 0i64 cast]
    VarIntX  [value processor.options.pointerSize 32nx = [0i32 cast 0i64 cast][copy] if]
    [@value copy]
  ) case
] func;

checkValue: [
  copy tag:;
  copy value:;
  tag (
    VarNat8  [value 0xFFn64 >]
    VarNat16 [value 0xFFFFn64 >]
    VarNat32 [value 0xFFFFFFFFn64 >]
    VarNatX  [processor.options.pointerSize 32nx = [value 0xFFFFFFFFn64 >] &&]
    VarInt8  [value 0x7Fi64 > [value 0x80i64 neg <] ||]
    VarInt16 [value 0x7FFFi64 > [value 0x8000i64 neg <] ||]
    VarInt32 [value 0x7FFFFFFFi64 > [value 0x80000000i64 neg <] ||]
    VarIntX  [processor.options.pointerSize 32nx = [value 0x7FFFFFFFi64 > [value 0x80000000i64 neg <] ||] &&]
    [FALSE]
  ) case ["number constant overflow" compilerError] when
  @value
] func;

zeroValue: [
  copy tag:;
  tag VarCond = [FALSE] [
    tag VarInt8 = [0i64] [
      tag VarInt16 = [0i64] [
        tag VarInt32 = [0i64] [
          tag VarInt64 = [0i64] [
            tag VarIntX = [0i64] [
              tag VarNat8 = [0n64] [
                tag VarNat16 = [0n64] [
                  tag VarNat32 = [0n64] [
                    tag VarNat64 = [0n64] [
                      tag VarNatX = [0n64] [
                        tag VarReal32 = [0.0r64] [
                          tag VarReal64 = [0.0r64] [
                            ("Tag = " makeStringView .getTag 0 cast) addLog
                            [FALSE] "Unknown plain struct while getting Zero value" assert
                          ] if
                        ] if
                      ] if
                    ] if
                  ] if
                ] if
              ] if
            ] if
          ] if
        ] if
      ] if
    ] if
  ] if
] func;

getPlainConstantIR: [
  var: getVar;
  result: String;
  var.data.getTag VarCond = [
    VarCond var.data.get ["true" toString] ["false" toString] if @result set
  ] [
    var.data.getTag VarInt8 = [VarInt8 var.data.get toString @result set] [
      var.data.getTag VarInt16 = [VarInt16 var.data.get toString @result set] [
        var.data.getTag VarInt32 = [VarInt32 var.data.get toString @result set] [
          var.data.getTag VarInt64 = [VarInt64 var.data.get toString @result set] [
            var.data.getTag VarIntX = [VarIntX var.data.get toString @result set] [
              var.data.getTag VarNat8 = [VarNat8 var.data.get toString @result set] [
                var.data.getTag VarNat16 = [VarNat16 var.data.get toString @result set] [
                  var.data.getTag VarNat32 = [VarNat32 var.data.get toString @result set] [
                    var.data.getTag VarNat64 = [VarNat64 var.data.get toString @result set] [
                      var.data.getTag VarNatX = [VarNatX var.data.get toString @result set] [
                        var.data.getTag VarReal32 = [VarReal32 var.data.get 0.0r32 cast 0.0r64 cast bitView @result set] [
                          var.data.getTag VarReal64 = [VarReal64 var.data.get bitView @result set] [
                            ("Tag = " makeStringView var.data.getTag 0 cast) addLog
                            [FALSE] "Unknown plain struct while getting IR value" assert
                          ] if
                        ] if
                      ] if
                    ] if
                  ] if
                ] if
              ] if
            ] if
          ] if
        ] if
      ] if
    ] if
  ] if

  result
] func;

# require captures "processor" and "codeNode"
generateVariableIRNameWith: [
  copy temporaryRegister:;
  copy hostId:;
  temporaryRegister not [currentNode.parent 0 =] && [
    ("@global." processor.globalVarCount) assembleString makeStringId
    processor.globalVarCount 1 + @processor.@globalVarCount set
  ] [
    hostNode: hostId @processor.@nodes.at.get;
    ("%var." hostNode.lastVarName) assembleString makeStringId
    hostNode.lastVarName 1 + @hostNode.@lastVarName set
  ] if
] func;

generateVariableIRName: [FALSE generateVariableIRNameWith] func;
generateRegisterIRName: [indexOfNode TRUE generateVariableIRNameWith] func;

makeVariableIRName: [
  refToVar:;
  var: refToVar getVar;

  refToVar.hostId refToVar isGlobal not generateVariableIRNameWith @var.@irNameId set
] func;

findFieldWithOverloadShift: [
  copy overloadShift:;
  refToVar:;
  copy fieldNameInfo:;

  var: refToVar getVar;

  result: {
    success: FALSE;
    index: -1;
  };

  var.data.getTag VarStruct = [
    struct: VarStruct var.data.get.get;
    i: struct.fields.dataSize copy dynamic;

    [
      i 0 > [
        i 1 - @i set

        i struct.fields.at .nameInfo fieldNameInfo = [
          overloadShift 0 = [
            TRUE @result.@success set
            i @result.@index set
            FALSE
          ] [
            overloadShift 1 - @overloadShift set
            TRUE
          ] if
        ] [
          TRUE
        ] if
      ] &&
    ] loop
  ] [
    (refToVar getMplType " is not combined") assembleString compilerError
  ] if

  result
] func;

findField: [0 dynamic findFieldWithOverloadShift] func;