//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   14 May 06  Brian Frank  Creation
//
package fan.sys;

/**
 * UnknownFacetErr indicates an attempt to access an undefined facet.
 */
public class UnknownFacetErr
  extends Err
{

//////////////////////////////////////////////////////////////////////////
// Fantom Constructors
//////////////////////////////////////////////////////////////////////////

  public static UnknownFacetErr make() { return make("", (Err)null); }
  public static UnknownFacetErr make(String msg) { return make(msg, (Err)null); }
  public static UnknownFacetErr make(String msg, Err cause)
  {
    UnknownFacetErr err = new UnknownFacetErr();
    make$(err, msg, cause);
    return err;
  }

  public static void make$(UnknownFacetErr self) { make$(self, null);  }
  public static void make$(UnknownFacetErr self, String msg) { make$(self, msg, null); }
  public static void make$(UnknownFacetErr self, String msg, Err cause) { Err.make$(self, msg, cause); }

//////////////////////////////////////////////////////////////////////////
// Java Constructors
//////////////////////////////////////////////////////////////////////////

  public UnknownFacetErr() {}

//////////////////////////////////////////////////////////////////////////
// Identity
//////////////////////////////////////////////////////////////////////////

  public Type typeof() { return Sys.UnknownFacetErrType; }

}

