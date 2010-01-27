//
// Copyright (c) 2008, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   22 Dec 08  Andy Frank  Creation
//

using compiler

**
** Fantom source to JavaScript source compiler - this class is
** plugged into the compiler pipeline by the compiler::CompileJs step.
**
class CompileJsPlugin : CompilerStep
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  new make(Compiler c) : super(c) {}

//////////////////////////////////////////////////////////////////////////
// Pipeline
//////////////////////////////////////////////////////////////////////////

  override Void run()
  {
    buf := StrBuf()
    jsPod = JsPod(this, pod, types)
    jsPod.write(JsWriter(buf.out))
    compiler.js =  buf.toStr
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  JsPod? jsPod  // JsPod AST

}