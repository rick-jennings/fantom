//
// Copyright (c) 2006, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   26 Mar 06  Brian Frank  Creation
//
package fan.sys;

/**
 * File represents a file or directory in a file system.
 */
public abstract class File
  extends FanObj
{

//////////////////////////////////////////////////////////////////////////
// Construction
//////////////////////////////////////////////////////////////////////////

  public static File make(Uri uri) { return make(uri, true); }
  public static File make(Uri uri, boolean checkSlash)
  {
    java.io.File f = LocalFile.uriToFile(uri);
    if (f.isDirectory() && !checkSlash && !uri.isDir())
      uri = uri.plusSlash();
    return new LocalFile(uri, f);
  }

  public static File os(String osPath)
  {
    return new LocalFile(new java.io.File(osPath));
  }

  public static List osRoots()
  {
    List list = new List(Sys.FileType);
    java.io.File[] roots = java.io.File.listRoots();
    for (int i=0; i<roots.length; ++i)
      list.add(new LocalFile(roots[i], true));
    return list;
  }

  public static File createTemp() { return createTemp(null, null, null); }
  public static File createTemp(String prefix) { return createTemp(prefix, null, null); }
  public static File createTemp(String prefix, String suffix) { return createTemp(prefix, suffix, null); }
  public static File createTemp(String prefix, String suffix, File dir)
  {
    if (prefix == null || prefix.length() == 0) prefix = "fan";
    if (prefix.length() == 1) prefix = prefix + "xx";
    if (prefix.length() == 2) prefix = prefix + "x";

    if (suffix == null) suffix = ".tmp";

    java.io.File d = null;
    if (dir != null)
    {
      if (!(dir instanceof LocalFile)) throw IOErr.make("Dir is not on local file system: " + dir).val;
      d = ((LocalFile)dir).file;
    }

    try
    {
      return new LocalFile(java.io.File.createTempFile(prefix, suffix, d));
    }
    catch (java.io.IOException e)
    {
      throw IOErr.make(e).val;
    }
  }

  protected File(Uri uri)
  {
    this.uri = uri;
  }

//////////////////////////////////////////////////////////////////////////
// Identity
//////////////////////////////////////////////////////////////////////////

  public final boolean equals(Object obj)
  {
    if (obj instanceof File)
    {
      return uri.equals(((File)obj).uri);
    }
    return false;
  }

  public final int hashCode() { return uri.hashCode(); }

  public final long hash() { return uri.hash(); }

  public final String toStr() { return uri.toStr(); }

  public Type type() { return Sys.FileType; }

//////////////////////////////////////////////////////////////////////////
// Uri
//////////////////////////////////////////////////////////////////////////

  public final Uri uri() { return uri; }

  public final boolean isDir() { return uri.isDir();   }

  public final List path() { return uri.path(); }

  public final String pathStr() { return uri.pathStr(); }

  public final String name() { return uri.name(); }

  public final String basename() { return uri.basename(); }

  public final String ext() { return uri.ext(); }

  public final MimeType mimeType() { return uri.mimeType(); }

//////////////////////////////////////////////////////////////////////////
// Access
//////////////////////////////////////////////////////////////////////////

  public abstract boolean exists();

  public abstract Long size();

  public abstract DateTime modified();
  public abstract void modified(DateTime time);

  public abstract String osPath();

  public abstract File parent();

  public abstract List list();

  public List listDirs()
  {
    List list = list();
    for (int i=list.sz()-1; i>=0; --i)
      if (!((File)list.get(i)).isDir())
        list.removeAt(i);
    return list;
  }

  public List listFiles()
  {
    List list = list();
    for (int i=list.sz()-1; i>=0; --i)
      if (((File)list.get(i)).isDir())
        list.removeAt(i);
    return list;
  }

  public void walk(Func c)
  {
    c.call1(this);
    if (isDir())
    {
      List list = list();
      for (int i=0; i<list.sz(); ++i)
        ((File)list.get(i)).walk(c);
    }
  }

  public abstract File normalize();

  public File plus(Uri uri) { return plus(uri, true); }
  public abstract File plus(Uri uri, boolean checkSlash);

  File plus(String uri) { return plus(Uri.fromStr(uri)); }

  File plusNameOf(File x)
  {
    String name = x.name();
    if (x.isDir()) name += "/";
    return plus(name);
  }

//////////////////////////////////////////////////////////////////////////
// Management
//////////////////////////////////////////////////////////////////////////

  public abstract File create();

  public File createFile(String name)
  {
    if (!isDir()) throw IOErr.make("Not a directory: " + this).val;
    return this.plus(Uri.fromStr(name)).create();
  }

  public File createDir(String name)
  {
    if (!isDir()) throw IOErr.make("Not a directory: " + this).val;
    if (!name.endsWith("/")) name = name + "/";
    return this.plus(Uri.fromStr(name)).create();
  }

  public abstract void delete();

  public abstract File deleteOnExit();

//////////////////////////////////////////////////////////////////////////
// Copy
//////////////////////////////////////////////////////////////////////////

  public final File copyTo(File to) { return copyTo(to, null); }
  public File copyTo(File to, Map options)
  {
    // sanity
    if (isDir() != to.isDir())
    {
      if (isDir())
        throw ArgErr.make("copyTo must be dir `" + to + "`").val;
      else
        throw ArgErr.make("copyTo must not be dir `" + to + "`").val;
    }

    // options
    Object exclude = null, overwrite = null;
    if (options != null)
    {
      exclude = options.get("exclude");
      overwrite = options.get("overwrite");
    }

    // recurse
    doCopyTo(to, exclude, overwrite);
    return to;
  }

  private void doCopyTo(File to, Object exclude, Object overwrite)
  {
    // check exclude
    if (exclude instanceof Regex)
    {
      if (((Regex)exclude).matches(uri.toStr())) return;
    }
    else if (exclude instanceof Func)
    {
      if (((Func)exclude).call1(this) == Boolean.TRUE) return;
    }

    // check for overwrite
    if (to.exists())
    {
      if (overwrite instanceof Boolean)
      {
        if (overwrite == Boolean.FALSE) return;
      }
      else if (overwrite instanceof Func)
      {
        if (((Func)overwrite).call1(this) == Boolean.FALSE) return;
      }
      else
      {
        throw IOErr.make("No overwrite policy for `" + to + "`").val;
      }
    }

    // copy directory
    if (isDir())
    {
      to.create();
      List kids = list();
      for (int i=0; i<kids.sz(); ++i)
      {
        File kid = (File)kids.get(i);
        kid.doCopyTo(to.plusNameOf(kid), exclude, overwrite);
      }
    }

    // copy file contents
    else
    {
      OutStream out = to.out();
      try
      {
        in().pipe(out);
      }
      finally
      {
        out.close();
      }
    }
  }

  public final File copyInto(File dir) { return copyInto(dir, null); }
  public File copyInto(File dir, Map options)
  {
    if (!dir.isDir())
      throw ArgErr.make("Not a dir: `" + dir + "`").val;

    return copyTo(dir.plusNameOf(this), options);
  }

//////////////////////////////////////////////////////////////////////////
// Move
//////////////////////////////////////////////////////////////////////////

  public abstract File moveTo(File to);

  public File moveInto(File dir)
  {
    if (!dir.isDir())
      throw ArgErr.make("Not a dir: `" + dir + "`").val;

    return moveTo(dir.plusNameOf(this));
  }

  public File rename(String newName)
  {
    if (isDir()) newName += "/";
    return moveTo(parent().plus(newName));
  }

//////////////////////////////////////////////////////////////////////////
// IO
//////////////////////////////////////////////////////////////////////////

  public final Buf open() { return open("rw"); }
  public abstract Buf open(String mode);

  public final Buf mmap() { return mmap("rw", 0L, null); }
  public final Buf mmap(String mode) { return mmap(mode, 0L, null); }
  public final Buf mmap(String mode, long pos) { return mmap(mode, pos, null); }
  public abstract Buf mmap(String mode, long pos, Long size);

  public final InStream in() { return in(FanInt.Chunk); }
  public abstract InStream in(Long bufSize);

  public final OutStream out() { return out(false, FanInt.Chunk); }
  public final OutStream out(boolean append) { return out(append, FanInt.Chunk); }
  public abstract OutStream out(boolean append, Long bufSize);

  public final Buf readAllBuf()
  {
    return in(FanInt.Chunk).readAllBuf();
  }

  public final List readAllLines()
  {
    return in(FanInt.Chunk).readAllLines();
  }

  public final void eachLine(Func f)
  {
    in(FanInt.Chunk).eachLine(f);
  }

  public final String readAllStr() { return readAllStr(true); }
  public final String readAllStr(boolean normalizeNewlines)
  {
    return in(FanInt.Chunk).readAllStr(normalizeNewlines);
  }

  public final Map readProps()
  {
    return in(FanInt.Chunk).readProps();
  }

  public final void writeProps(Map props)
  {
    out(false, FanInt.Chunk).writeProps(props, true);
  }

  public final Object readObj() { return readObj(null); }
  public final Object readObj(Map options)
  {
    InStream in = in();
    try
    {
      return in.readObj(options);
    }
    finally
    {
      in.close();
    }
  }

  public final void writeObj(Object obj) { writeObj(obj, null); }
  public final void writeObj(Object obj, Map options)
  {
    OutStream out = out();
    try
    {
      out.writeObj(obj, options);
    }
    finally
    {
      out.close();
    }
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  public static final String sep = java.io.File.separator;
  public static final String pathSep = java.io.File.pathSeparator;

  final Uri uri;
}