//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   17 Jul 09  Andy Frank  Creation
//

using compiler
using fandoc

**
** SymbolsGenerator generates the symbols file for a pod.
**
class SymbolsGenerator : HtmlGenerator
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  new make(DocCompiler compiler, Loc loc, OutStream out)
    : super(compiler, loc, out)
  {
    this.pod = compiler.pod
  }

//////////////////////////////////////////////////////////////////////////
// Generator
//////////////////////////////////////////////////////////////////////////

  override Str title()
  {
    return "$pod.name Meta"
  }

  override Void header()
  {
    out.print("<ul>\n")
    out.print("  <li><a href='../index.html'>$docHome</a></li>\n")
    out.print("  <li>&gt;</li>\n")
    out.print("  <li><a href='index.html'>$pod.name</a></li>\n")
    out.print("  <li>&gt;</li>\n")
    out.print("  <li><a href='pod-meta.html'>Meta</a></li>\n")
    out.print("</ul>\n")
  }

  override Void content()
  {
    out.print("<div class='type'>\n")
    out.print("<div class='overview'>\n")
    out.print("<h2>pod</h2>\n")
    out.print("<h1>$pod.name</h1>\n")
    out.print("</div>\n")
    out.print("</div>\n")
    writeFacets
    writeSymbols
  }

  Void writeFacets()
  {
/* TODO-FACETS
    if (pod.facets.isEmpty) return
    out.print("<h2 id='facets'>Pod Facets</h2>\n")
    out.print("<pre class='podFacets'>")
    facets(pod.facets, false, false)
    out.print("</pre>\n")
*/
  }

  Void writeSymbols()
  {
/* TODO-FACETS
    if (symbols.isEmpty) return
    out.print("<div class='slots'>\n")
    out.print("<div class='detail'>\n")
    out.print("<h2 id='symbols'>Symbols</h2>\n")
    out.print("<dl>\n")
    symbols.each |s|
    {
      out.print("<dt id='$s.name' class='symbol'>$s.name</dt>")
      out.print("<dd>\n")
      out.print("<p><code class='sig'>")
      meta := ApiToHtmlGenerator.parseMeta(s.doc)
      map := |Type x->Uri| { return compiler.uriMapper.map(x.qname, loc) }
      out.print(ApiToHtmlGenerator.makeTypeLink(s.type, map))
      out.print(" $s.name")
      def := meta["def"]
      out.print(" := $def")
      out.print("</code></p>\n")
      doc := ApiToHtmlGenerator.docBody(s.doc)
      if (doc != null)
      {
        // fandoc body
        ApiToHtmlGenerator.fandoc(this, s.qname, doc)
      }
      out.print("</dd>\n")
    }
    out.print("</dl>\n")
    out.print("</div>\n")
    out.print("</div>\n")
*/
  }

  override Void sidebar()
  {
/* TODO-FACETS
    if (symbols.isEmpty) return
    out.print("<h2>Symbols</h2>\n")
    out.print("<ul class='clean'>\n")
    symbols.each |s|
    {
      out.print("  <li><a href='#$s.name'>$s.name</a></li>\n")
    }
    out.print("</ul>\n")
*/
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  Pod pod

}