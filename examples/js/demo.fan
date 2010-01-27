#! /usr/bin/env fan
//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   12 Jun 09  Brian Frank  Creation
//

using util
using web
using webmod
using wisp
using compiler
using compilerJs

class JsDemo : AbstractMain
{
  @opt="http port"
  Int port := 8080

  override Int run()
  {
    wisp := WispService
    {
      it.port = this.port
      it.root = JsDemoMod(homeDir)
    }
    return runServices([wisp])
  }
}

const class JsDemoMod : WebMod
{
  new make(File dir) { scriptDir = dir }

  const File scriptDir

  override Void onGet()
  {
    name := req.modRel.path.first
    if (name == null)
      onIndex
    else if (name == "pod")
      onPodFile
    else if (name == "echo")
      onEcho
    else
      ShowScript(scriptDir + `$name`).onGet
  }

  override Void onPost()
  {
    name := req.modRel.path.first
    if (name == "echo") onEcho
    else super.onPost
  }

  Void onIndex()
  {
    res.headers["Content-Type"] = "text/html"
    out := res.out
    out.docType
    out.html
    out.head
      out.title.w("FWT Demo").titleEnd
    out.headEnd
    out.body
      out.h1.w("FWT Demo").h1End
      out.ul
      scriptDir.list.each |f|
      {
        if (f.ext == "fwt")
          out.li.a(`/$f.name`).w(f.name).aEnd.liEnd
      }
      out.ulEnd
    out.bodyEnd
    out.htmlEnd
  }

  Void onEcho()
  {
    c := req.method == "GET" ? "" : req.in.readAllStr
    s := "$req.method $req.uri
          $req.headers
          $c"
    buf := Buf().printLine(s)
    res.headers["Content-Length"] = buf.size.toStr
    res.headers["Content-Type"] = "text/plain"
    res.out.writeBuf(buf.flip)
  }

  Void onPodFile()
  {
    // serve up pod resources
    File file := ("fan:/sys" + req.uri).toUri.get
    if (!file.exists) { res.sendErr(404); return }
    FileWeblet(file).onService
  }
}

class ShowScript : Weblet
{
  new make(File f) { file = f }
  override Void onGet()
  {
    if (!file.exists) { res.sendErr(404); return }

    compile
    t := compiler.types[0]
    entryPoint := "fan.${t.pod}.${t.name}"

    res.headers["Content-Type"] = "text/html"
    out := res.out
    out.docType
    out.html
    out.head
      out.title.w("FWT Demo - $file.name").titleEnd
      out.includeJs(`/pod/sys/sys.js`)
      out.includeJs(`/pod/web/web.js`)
      out.includeJs(`/pod/dom/dom.js`)
      out.includeJs(`/pod/gfx/gfx.js`)
      out.includeJs(`/pod/fwt/fwt.js`)
      out.style.w(
       "body { font: 10pt Arial; }
        a { color: #00f; }
        ").styleEnd
      out.script.w(js).w(
       "var hasRun = false;
        var shell  = null;
        var doLoad = function()
        {
          // safari appears to have a problem calling this event
          // twice, so make sure we short-circuit if already run
          if (hasRun) return;
          hasRun = true;

          // load fresco
          fan.sys.UriPodBase = '/pod/';
          shell = ${entryPoint}.make();
          shell.open();
        }
        var doResize = function() { shell.relayout(); }
        if (window.addEventListener)
        {
          window.addEventListener('load', doLoad, false);
          window.addEventListener('resize', doResize, false);
        }
        else
        {
          window.attachEvent('onload', doLoad);
          window.attachEvent('onresize', doResize);
        }
        ").scriptEnd
    out.headEnd
    out.body
    out.bodyEnd
    out.htmlEnd
  }

  Void compile()
  {
    input := CompilerInput.make
    input.podName   = file.basename
    input.version   = Version("0")
    input.log.level = LogLevel.err
    input.isScript  = true
    input.srcStr    = file.readAllStr
    input.srcStrLoc = Loc.makeFile(file)
    input.mode      = CompilerInputMode.str
    input.output    = CompilerOutputMode.js

    this.compiler = Compiler(input)
    this.js = compiler.compile.js
  }

  File file
  Compiler? compiler
  Str? js
}

