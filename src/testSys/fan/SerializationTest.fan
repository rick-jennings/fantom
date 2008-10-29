//
// Copyright (c) 2007, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   18 Aug 07  Brian Frank  Creation
//

**
** SerializationTest
**
class SerializationTest : Test
{

//////////////////////////////////////////////////////////////////////////
// Literals
//////////////////////////////////////////////////////////////////////////

  Void testLiterals()
  {
    // null literal
    verifySer("null", null)

    // Bool literals
    verifySer("true", true)
    verifySer("false", false)

    // Int literals
    verifySer("5", 5)
    verifySer("5_000", 5000)
    verifySer("0xabcd_0123_4567", 0xabcd_0123_4567)
    verifySer("9223372036854775807", 9223372036854775807)
    verifySer("-9223372036854775808", -9223372036854775807-1)
    verifySer("-987", -987)
    verifySer("'A'", 'A')
    verifySer("'\u0c45'", 0xc45)
    verifyErr(IOErr#) |,| { verifySer("0x", 0) }
    verifyErr(IOErr#) |,| { verifySer("9223372036854775808", 0) }
    verifyErr(IOErr#) |,| { verifySer("-9223372036854775809", 0) }

    // Float literals
    verifySer("3f", 3f)
    verifySer("-99f", -99f)
    verifySer("2.0F", 2.0f)
    verifySer("8.4f", 8.4f)
    verifySer("-0.123f", -0.123f)
    verifySer(".2f", .2f)
    verifySer("-.4f", -.4f)
    verifySer("2e10f", 2e10f)
    verifySer("-8e-9f", -8e-9f)
    verifySer("-8.4E-6F", -8.4E-6f)
    verifySer("sys::Float(\"NaN\")", Float.nan)
    verifySer("sys::Float(\"INF\")", Float.posInf)
    verifySer("sys::Float(\"-INF\")", Float.negInf)
    verifyErr(IOErr#) |,| { verifySer("3e", null) }
    verifyErr(IOErr#) |,| { verifySer("3eX", null) }

    // Decimal literals
    verifySer("7d", 7d)
    verifySer("-2d", -2d)
    verifySer("2.00", 2.00)
    verifySer("2.00d", 2.00d)
    verifySer("2.00D", 2.00D)
    verifySer("-2.00", -2.00d)
    verifySer("-0.07", -0.07D)
    verifySer("123_4567_890.123_456", 123_4567_890.123_456d)
    verifySer("-123_4567_890.123_456", -123_4567_890.123_456d)
    verifySer("7.9e28", 7.9e28)
    verifySer("9223372036854775800d", 9223372036854775800d)
    verifySer("9223372036854775809d", 9223372036854775809d)
    verifySer("92233720368547758091234d", 92233720368547758091234d)
    verifySer("-92233720368547758091234.678d", -92233720368547758091234.678d)

    // String literals
    verifySer("\"\"", "")
    verifySer("\"hi!\"", "hi!")
    verifySer("\"hi!\nthere\"", "hi!\nthere")
    verifySer("\"hi!\\nthere\"", "hi!\nthere")
    verifySer("\"a\u0dffb\t\"", "a\u0dffb\t")
    verifySer("\"one\\ntwo\\\$three\\\\four\\\"five\"", "one\ntwo\$three\\four\"five")

    // Duration literals
    verifySer("90ns", 90ns)
    verifySer("-8ms", -8ms)
    verifySer("1.23sec", 1.23sec)
    verifySer("0.5min", 0.5min)
    verifySer("24hr", 1day)
    verifySer("0.5day", 12hr)

    // Uri literals
    verifySer("`http://foo/path/file.txt#frag`", `http://foo/path/file.txt#frag`)
    verifySer("`../there`", `../there`)
    verifySer("`?a=b&c`", `?a=b&c`)
    verifySer("`a b`", `a b`)
    verifySer("`a\\tb`", `a\tb`)
    verifySer("`\\``", `\``)
    verifySer("`\\u025E\\n\\\$ \\`!\"`", `\u025E\n\$ \`!"`)

    // Type literals
    verifySer("sys::Num#", Num#)
    verifySer("testSys::SerializationTest#", type)
  }

//////////////////////////////////////////////////////////////////////////
// Simples
//////////////////////////////////////////////////////////////////////////

  Void testSimples()
  {
    now := DateTime.now

    verifySer("sys::Version(\"1.2.3\")", Version.make([1,2,3]))
    verifySer("sys::Depend(\"foo 1.2-3.4\")", Depend.fromStr("foo 1.2-3.4"))
    verifySer("sys::Locale(\"fr-CA\")", Locale.fromStr("fr-CA"))
    verifySer("sys::TimeZone(\"London\")", TimeZone.fromStr("London"))
    verifySer("sys::DateTime(\"$now\")", now)
    verifySer("sys::Charset(\"utf-8\")", Charset.utf8)
    verifySer("testSys::SerSimple(\"7,8\")", SerSimple.make(7,8))

    verifySer("testSys::EnumAbc(\"C\")", EnumAbc.C)
    verifySer("testSys::Suits(\"spades\")", Suits.spades)

    verifyErr(IOErr#) |,| { verifySer("sys::Version(x)", null) }
    verifyErr(IOErr#) |,| { verifySer("sys::Version(\"x\"", null) }
    verifyErr(ParseErr#) |,| { verifySer("sys::Version(\"x\")", null) }
  }

//////////////////////////////////////////////////////////////////////////
// Lists
//////////////////////////////////////////////////////////////////////////

  Void testLists()
  {
    verifySer("[,]", Obj?[,])
    verifySer("sys::Obj?[,]", Obj?[,])
    verifySer("sys::Obj[,]", Obj[,])
    verifySer("[null]", Obj?[null])
    verifySer("[null, null]", Obj?[null, null])
    verifySer("sys::Uri[,]", Uri[,])
    verifySer("sys::Int?[,]", Int?[,])
    verifySer("sys::Int?[null, 2]", Int?[null, 2])
    verifySer("[null, 3]", Int?[null, 3])
    verifySer("[3, null]", Int?[3, null])
    verifySer("[3, 2f]", Num[3, 2f])
    verifySer("[3, null, 2f]", Num?[3, null, 2f])
    verifySer("[1, 2, 3]", Int[1,2,3])
    verifySer("[1, null, 3]", Int?[1,null,3])
    verifySer("[1, 2f, 3]", [1,2f,3])
    verifySer("[1, 2f, 3.00,]", Num[1,2f,3.00])
    verifySer("[1, [7ns], \"3\"]", [1, [7ns], "3"])
    verifySer("sys::Num[1, 2, 3]", Num[1, 2, 3])
    verifySer("sys::Int[][sys::Int[1],sys::Int[2]]", sys::Int[][sys::Int[1],sys::Int[2]])
    verifySer("[[1],[2]]", [[1],[2]])
    verifySer("sys::Int[][,]", Int[][,])
    verifySer("sys::Str[][][,]", Str[][][,])
    verifySer("[[[\"x\"]]]", [[["x"]]])
    verifySer("sys::Str[][][[[\"x\"]]]", [[["x"]]])

    // errors
    verifyErr(IOErr#) |,| { verifySer("[", null) }
    verifyErr(IOErr#) |,| { verifySer("[,", null) }
    verifyErr(IOErr#) |,| { verifySer("[]", null) }
    verifyErr(IOErr#) |,| { verifySer("[3,", null) }
  }

//////////////////////////////////////////////////////////////////////////
// Maps
//////////////////////////////////////////////////////////////////////////

  Void testMaps()
  {
    verifySer("[:]", Obj:Obj?[:])
    verifySer("using sys\nObj:Obj[:]", Obj:Obj[:])
    verifySer("using sys\nObj:Obj?[:]", Obj:Obj?[:])
    verifySer("sys::Str:sys::Str[:]", Str:Str[:])
    verifySer("sys::Int:sys::Uri?[:]", Int:Uri?[:])
    verifySer("[sys::Int:sys::Uri][:]", Int:Uri[:])
    verifySer("[sys::Int:sys::Uri?][:]", Int:Uri?[:])
    verifySer("[1:1ns, 2:2ns]", [1:1ns, 2:2ns])
    verifySer("[\"1\":1, \"2\":2f]", ["1":1, "2":2f])
    verifySer("[\"1\":1, \"2\":2f,]", Str:Num["1":1, "2":2f])
    verifySer("sys::Str:sys::Num[\"1\":1, \"2\":2f]", Str:Num["1":1, "2":2f])
    verifySer("[sys::Str:sys::Num][\"1\":1, \"2\":2f]", Str:Num["1":1, "2":2f])
    verifySer("[0:sys::Str[,], 1:[\"x\"]]", [0:Str[,], 1:["x"]])
    verifySer("sys::Int:sys::Duration?[1:null]", Int:Duration?[1:null])
    verifySer("[1:null, 2:8ns]", Int:Duration?[1:null, 2:8ns])
    verifySer("[1:8ms, 2:null]", Int:Duration?[1:8ms, 2:null])
    verifySer("[1:null, 2:8ns, 3:3]", Int:Obj?[1:null, 2:8ns, 3:3])

    // various nested type/list type signatures
    verifySer("sys::Int:sys::Uri[,]", Int:Uri[,])
    verifySer("[sys::Int:sys::Uri][,]", [Int:Uri][,])
    verifySer("[sys::Int:sys::Uri][][,]", [Int:Uri][][,])
    verifySer("[sys::Int:sys::Uri][][][,]", [Int:Uri][][][,])
    verifySer("sys::Str:sys::Bool[][:]", Str:Bool[][:])
    verifySer("[sys::Str:sys::Bool[]][:]", [Str:Bool[]][:])
    verifySer("[sys::Str:sys::Bool[]][][,]", [Str:Bool[]][][,])
    verifySer("[sys::Int:sys::Bool[]][[2:[true]]]", [Int:Bool[]][[2:[true]]])
    verifySer("[sys::Int:sys::Bool[]][[sys::Int:sys::Bool[]][2:[true]]]", [Int:Bool[]][[2:[true]]])
    verifySer("[sys::Int:sys::Bool[]][sys::Int:sys::Bool[][2:[true]]]", [Int:Bool[]][[2:[true]]])
    verifySer("[sys::Int:sys::Int][sys::Int:sys::Int[2:20]]", [Int:Int][Int:Int[2:20]])
    verifySer("[sys::Int:sys::Int][[sys::Int:sys::Int][2:20]]", [Int:Int][Int:Int[2:20]])
    // TODO: need to fix nullable map inference...
    verifySer("sys::Version:sys::Int[sys::Version(\"1.2\"):1]", Version:Int[Version.fromStr("1.2"):1])
    verifySer("[sys::Version:sys::Int][sys::Version(\"1.2\"):1]", Version:Int[Version.fromStr("1.2"):1])
    verifySer("sys::Version:sys::Int[[sys::Version(\"1.2\"):1]]", [sys::Version:sys::Int][Version:Int[Version.fromStr("1.2"):1]])

    // errors
    verifyErr(IOErr#) |,| { verifySer("[:", null) }
    verifyErr(IOErr#) |,| { verifySer("[:3", null) }
    verifyErr(IOErr#) |,| { verifySer("[3:", null) }
    verifyErr(IOErr#) |,| { verifySer("[3:2", null) }
    verifyErr(IOErr#) |,| { verifySer("[3:2,", null) }
    verifyErr(IOErr#) |,| { verifySer("[3:2,4", null) }
    verifyErr(IOErr#) |,| { verifySer("[3:2,4:", null) }
    verifyErr(IOErr#) |,| { verifySer("[3:2,4]", null) }
  }

//////////////////////////////////////////////////////////////////////////
// Complex
//////////////////////////////////////////////////////////////////////////

  Void testComplex()
  {
    x := SerA.make
    verifySer("testSys::SerA", x)
    verifySer("testSys::SerA {}", x)

    x.i = 0xab77
    verifySer("testSys::SerA { i = 0xab77 }", x)
    verifySer("testSys::SerA { i = 0xab77; }", x)
    verifySer("testSys::SerA {\ni\n=\n0xab77\n}", x)

    x.b = false
    x.i = 69
    x.f = -3f
    x.d = 6min
    x.u = `foo.txt`
    verifySer(
    "testSys::SerA
     {
       b=false; i=69
       f=-3f
       d = 6min;
       u=`foo.txt`}", x)

    verifyErr(IOErr#) |,| { verifySer("testSys::SerA {", null) }
    verifyErr(IOErr#) |,| { verifySer("testSys::SerA {b", null) }
    verifyErr(IOErr#) |,| { verifySer("testSys::SerA {b}", null) }
    verifyErr(IOErr#) |,| { verifySer("testSys::SerA {b=", null) }
    verifyErr(IOErr#) |,| { verifySer("testSys::SerA {b=}", null) }
    verifyErr(IOErr#) |,| { verifySer("testSys::SerA {b=true", null) }
    verifyErr(IOErr#) |,| { verifySer("testSys::SerA {b=3}", null) }
    verifyErr(IOErr#) |,| { verifySer("testSys::SerA {b=true i=5}", null) }
    verifyErr(IOErr#) |,| { verifySer("testSys::SerA {xxx=3}", null) }

    verifyErr(IOErr#) |,| { OutStream.makeForStrBuf(StrBuf.make).writeObj(this) }
  }

  Void testComplexInferred()
  {
    x := SerA.make
    x.sList = Str[,]
    verifySer("testSys::SerA { sList = [,] }", x)
    verifySer("testSys::SerA { sList = sys::Str[,] }", x)

    x.nList = Num[,]
    verifySer(
     "testSys::SerA
      {
        sList = [,]
        nList = [,]
      }", x)

    x.nList = Num[4, 5, 6]
    verifySer(
     "testSys::SerA
      {
        sList = [,];
        nList = [4, 5, 6]
      }", x)

    x.isMap = Int:Str[:]
    verifySer(
     "testSys::SerA
      {
        sList = [,];
        nList = [4, 5, 6]
        isMap = [:]
      }", x)

    x.isMap = Int:Str[2:"two"]
    verifySer(
     "testSys::SerA
      {
        sList = [,];
        nList = [4, 5, 6]
        isMap = [2:\"two\"]
      }", x)

    x.isMap = Int:Str[2:"two"]
    verifySer(
     "testSys::SerA
      {
        sList = [,];
        nList = sys::Num[4, 5, 6]
        isMap = sys::Int:sys::Str[2:\"two\"]
      }", x)
  }

  Void testListMap()
  {
    x := SerListMap.make
    x.map["bar"] = 5
    x.map["foo"] = Str:Obj[:]
    SerListMap y := verifySer("testSys::SerListMap { map=[\"foo\":[sys::Str:sys::Obj][:], \"bar\":5] }", x)
    verifyEq(y.map["foo"].type, Str:Obj#)
  }

  Void testComplexCompound()
  {
    x := SerA.make
    x.kids = SerA[,]
    verifySer("testSys::SerA { kids  = [,] }", x)
    verifySer("testSys::SerA { kids  = testSys::SerA[,] }", x)

    x = SerA.make
    x.kids = [SerA.make]
    verifySer("testSys::SerA { kids  = [testSys::SerA {}] }", x)
    verifySer("testSys::SerA { kids  = [testSys::SerA] }", x)
    verifySer("testSys::SerA { kids  = testSys::SerA[testSys::SerA] }", x)
    verifySer("testSys::SerA { kids  = testSys::SerA[testSys::SerA {}] }", x)

    x = SerA.make
    x.kids = SerA[SerB.make]
    verifySer("testSys::SerA { kids = [testSys::SerB {}] }", x)
    verifySer("testSys::SerA { kids = [testSys::SerB] }", x)
    verifySer("testSys::SerA { kids = testSys::SerA[testSys::SerB] }", x)
    verifySer("testSys::SerA { kids = testSys::SerA[testSys::SerB {}] }", x)

    x = SerA.make
    x.kids = [SerA.make, SerA.make]
    verifySer("testSys::SerA { kids  = testSys::SerA[testSys::SerA {}, testSys::SerA {}] }", x)
    verifySer("testSys::SerA { kids  = testSys::SerA[testSys::SerA, testSys::SerA] }", x)
    verifySer("testSys::SerA { kids  = [testSys::SerA, testSys::SerA] }", x)
    verifySer("testSys::SerA { kids  = [testSys::SerA {}, testSys::SerA] }", x)

    x = SerA.make
    x.i = 1972
    x.kids = [SerB.make, SerA.make]
    x.kids[0].i  = 0xabcd
    x.kids[0]->z = '!'
    x.kids[1].i  = 2007
    verifySer("testSys::SerA { i=1972; kids=[testSys::SerB {i=0xabcd;z='!'}, testSys::SerA{i=2007}] }", x)
    verifySer("testSys::SerA { kids=[testSys::SerB {i=0xabcd;z='!'}, testSys::SerA{i=2007}]; i=1972 }", x)
    verifySer("testSys::SerA { kids=testSys::SerA[testSys::SerB {i=0xabcd;z='!'}, testSys::SerA{i=2007}]; i=1972 }", x)
  }

  Void testComplexOptions()
  {
    SerA x := InStream.makeForStr("testSys::SerA {}").readObj
    verifyEq(x.s, null)
    verifyEq(x.d, null)

    x = InStream.makeForStr("testSys::SerA {}").readObj(["makeArgs":["foo"]])
    verifyEq(x.s, "foo")
    verifyEq(x.d, null)

    x = InStream.makeForStr("testSys::SerA { s = \"!\" }").readObj(["makeArgs":["foo", 5min]])
    verifyEq(x.s, "!")
    verifyEq(x.d, 5min)
  }

  Void testComplexConst()
  {
    verifyComplexConst("testSys::SerConst", SerConst.make)
    verifyComplexConst("testSys::SerConst { a=7 }", SerConst.make(7))
    verifyComplexConst("testSys::SerConst { a=7; b=[2,3] }", SerConst.make(7, [2,3]))
    verifyComplexConst("testSys::SerConst { b=[7] }", SerConst.make(0, [7]))
    verifyComplexConst("testSys::SerConst { b=null; c=null }", SerConst.make)
    verifyComplexConst("testSys::SerConst { c=[[4],[5,6]] }", SerConst.make(0, null, [[4],[5,6]]))
    verifyComplexConst("testSys::SerConst { c=[sys::Int[,]] }", SerConst.make(0, null, [Int[,]]))
    verifyErr(IOErr#) |,| { verifyComplexConst("testSys::SerConst { c=5 }", SerConst.make) }

    // TODO
    //verifyErr(IOErr#) |,| { verifyComplexConst("testSys::SerConst { c=[5] }", SerConst.make) }
  }

  Void verifyComplexConst(Str s, SerConst x)
  {
    SerConst y := verifySer(s, x)
    verifyEq(x, y)
    if (y.b != null) verify(y.b.isImmutable)
  }

  Void testTransient()
  {
    x := SerA { skip = "foo" }
    doc := Buf.make.writeObj(x).flip.readAllStr
    SerA y := Buf.make.print(doc).flip.readObj
    verifyEq(x.skip, "foo")
    verifyEq(y.skip, "skip")
  }

//////////////////////////////////////////////////////////////////////////
// Collections
//////////////////////////////////////////////////////////////////////////

  Void testIntCollection()
  {
    x := SerIntCollection.make
    verifySer("testSys::SerIntCollection {}", x)

    x.list.add(3)
    verifySer("testSys::SerIntCollection {3}", x)

    x.list.add(4)
    verifySer("testSys::SerIntCollection {3; 4}", x)

    x.list.add(5)
    verifySer("testSys::SerIntCollection {3; 4\n5}", x)

    x.name = "hi"
    verifySer("testSys::SerIntCollection {name=\"hi\"; 3; 4\n5}", x)
    verifySer("testSys::SerIntCollection {3; 4\n5\nname=\"hi\"}", x)
  }

  Void testFolderCollection()
  {
    x := SerFolder.make
    verifySer("testSys::SerFolder{}", x)

    a := SerFolder.make
    x.list.add(a)
    verifySer("testSys::SerFolder { testSys::SerFolder{} }", x)

    x.name = "root"
    a.name = "a"
    a.add(SerFolder.make { name = "a.1" })
    a.add(SerFolder.make { name = "a.2" })
    verifySer(
     "testSys::SerFolder
      { name=\"root\"
        testSys::SerFolder
        {
          testSys::SerFolder{name=\"a.1\"}
          name=\"a\"
          testSys::SerFolder{name=\"a.2\"}
        }
      }", x)
  }

//////////////////////////////////////////////////////////////////////////
// Using
//////////////////////////////////////////////////////////////////////////

  Void testUsing()
  {
    verifySer(
      "using testSys
       SerFolder { name=\"foo\" }",
      SerFolder { name="foo" })

    verifySer(
      "using testSys::SerFolder
       SerFolder { name=\"foo\" }",
      SerFolder { name="foo" })

    verifySer(
      "using testSys::SerFolder as FooBar
       FooBar { name=\"foo\" }",
      SerFolder { name="foo" })

    verifySer(
      "using sys
       using testSys
       using sys::DateTime as DT
       Obj
       [
         Str[,],
         Int:SerFolder[:],
         DT#
       ]",
      [Str[,], Int:SerFolder[:], DateTime#])

    verifyErr(IOErr#) |,| { verifySer("using sys using testSys; SerFolder {}", null) }
    verifyErr(IOErr#) |,| { verifySer("using sys::Int using testSys; SerFolder {}", null) }
    verifyErr(IOErr#) |,| { verifySer("using sys::Int as Integer testSys::SerFolder {}", null) }
    verifyErr(IOErr#) |,| { verifySer("SerFolder {}", null) }
  }

//////////////////////////////////////////////////////////////////////////
// Comments
//////////////////////////////////////////////////////////////////////////

  Void testComments()
  {
    verifySer("// header\n8", 8)
    verifySer("// header\r\n8", 8)
    verifySer("// header\r8", 8)
    verifySer("8 // header", 8)
    verifySer("** header\n8", 8)
    verifySer("** header\r\n8", 8)
    verifySer("** header\r8", 8)
    verifySer("/* header*/8", 8)
  }

//////////////////////////////////////////////////////////////////////////
// Synthetics
//////////////////////////////////////////////////////////////////////////

  Void testSynthetics()
  {
    SerSynthetic? x := null

    x = verifySer("testSys::SerSynthetic {}", SerSynthetic.make)
    verifyEq(x.b, 4)

    x = verifySer("testSys::SerSynthetic { a = 6}", SerSynthetic.make(6))
    verifyEq(x.b, 7)
  }

//////////////////////////////////////////////////////////////////////////
// Pretty Printing
//////////////////////////////////////////////////////////////////////////

  Void testPrettyPrinting()
  {
    x := SerA.make
    verifyPrettyPrinting(x, "testSys::SerA")

    x.i = 12345
    verifyPrettyPrinting(x,
     "testSys::SerA
      {
        i=12345
      }")

    x.f = Float.posInf
    verifyPrettyPrinting(x,
     "testSys::SerA
      {
        i=12345
        f=sys::Float(\"INF\")
      }")

    x.nList = Num[,]
    verifyPrettyPrinting(x,
     "testSys::SerA
      {
        i=12345
        f=sys::Float(\"INF\")
        nList=[,]
      }")

    x.nList = Num[2,3]
    verifyPrettyPrinting(x,
     "testSys::SerA
      {
        i=12345
        f=sys::Float(\"INF\")
        nList=[2,3]
      }")

    x.kids = SerA[,]
    verifyPrettyPrinting(x,
     "testSys::SerA
      {
        i=12345
        f=sys::Float(\"INF\")
        nList=[2,3]
        kids=[,]
      }")

    x.kids.add(SerA.make)
    verifyPrettyPrinting(x,
     "testSys::SerA
      {
        i=12345
        f=sys::Float(\"INF\")
        nList=[2,3]
        kids=
        [
          testSys::SerA
        ]
      }")

    x.kids[0].d = 5min
    verifyPrettyPrinting(x,
     "testSys::SerA
      {
        i=12345
        f=sys::Float(\"INF\")
        nList=[2,3]
        kids=
        [
          testSys::SerA
          {
            d=5min
          }
        ]
      }")

    x.kids.add(SerB.make)
    x.kids.add(SerA.make)
    verifyPrettyPrinting(x,
     "testSys::SerA
      {
        i=12345
        f=sys::Float(\"INF\")
        nList=[2,3]
        kids=
        [
          testSys::SerA
          {
            d=5min
          },
          testSys::SerB,
          testSys::SerA
        ]
      }")

    x.kids[2].kids = [SerA.make]
    verifyPrettyPrinting(x,
     "testSys::SerA
      {
        i=12345
        f=sys::Float(\"INF\")
        nList=[2,3]
        kids=
        [
          testSys::SerA
          {
            d=5min
          },
          testSys::SerB,
          testSys::SerA
          {
            kids=
            [
              testSys::SerA
            ]
          }
        ]
      }")

  }

  Void verifyPrettyPrinting(Obj obj, Str expected)
  {
    opts := ["indent":2, "skipDefaults":true]
    actual := Buf.make.writeObj(obj, opts).flip.readAllStr
//echo("================")
//echo(actual)
    verifyEq(expected, actual)

    x := InStream.makeForStr(actual).readObj
    verifyEq(x, obj)

  }

//////////////////////////////////////////////////////////////////////////
// Skip Errors
//////////////////////////////////////////////////////////////////////////

  Void testSkipErrors()
  {
    verifySkipErrors(
       Obj?[SerA.make,this,SerA.make],
       "sys::Obj?[testSys::SerA,null /* Not serializable: ${type.qname} */,testSys::SerA]",
       Obj?[SerA.make,null,SerA.make])
  }

  Void verifySkipErrors(Obj obj, Str expectedStr, Obj expected)
  {
    verifyErr(IOErr#) |,| { Buf.make.writeObj(obj) }

    opts := ["skipDefaults":true, "skipErrors":true]
    actual := Buf.make.writeObj(obj, opts).flip.readAllStr
    verifyEq(expectedStr, actual)

    x := InStream.makeForStr(actual).readObj
    verifyEq(x, expected)
  }

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  Obj? verifySer(Str data, Obj? expected)
  {
//echo("===================")
//echo(data)
    // verify InStream
    x := InStream.makeForStr(data).readObj
//if (x != null) dump(x, expected)
    verifyEq(x, expected)

    // verify writeObj via round trip
    doc := Buf.make.writeObj(expected, ["indent":2]).flip.readAllStr
//Sys.out.printLine("-------------------")
//echo(doc)
    z := Buf.make.print(doc).flip.readObj
    verifyEq(z, expected)

    return x
  }

  static Void dump(Obj x, Obj y)
  {
    echo("--- Serialization Dump ---")
    echo("$x.type ?= $y.type")
    //echo("$x ?= $y  =>  ${x==y}")
    x.type.fields.each |Field f|
    {
      a := f.get(x)
      b := f.get(y)
      cond := a == b ? "==" : "!="
      at := a == null ? "null" : a.type.signature
      bt := b == null ? "null" : b.type.signature
      echo("$f.name $a $cond $b ($at $cond $bt)")
    }
  }

}

**************************************************************************
** SerA
**************************************************************************

@serializable
class SerA
{
  new make(Str? s := null, Duration? d := null)
  {
    this.s = s
    this.d = d
  }

  override Int hash()
  {
    return i.hash ^ f.hash
  }

  override Bool equals(Obj? obj)
  {
    if (this === obj) return true
    x := obj as SerA
    if (x == null) return false
    eq := b == x.b &&
          i == x.i &&
          f == x.f &&
          s == x.s &&
          d == x.d &&
          u == x.u &&
          sList == x.sList &&
          nList == x.nList &&
          isMap == x.isMap &&
          kids == x.kids
    // if (!eq) SerializationTest.dump(this, x)
    return eq
  }

  Bool b := true
  Int i := 7
  Float f := 5f
  Str? s
  Duration? d
  Uri? u
  Str[]? sList
  Num[]? nList
  [Int:Str]? isMap
  SerA[]? kids
  @transient Str skip := "skip"
}

**************************************************************************
** SerB
**************************************************************************

class SerB : SerA
{
  new make() : super.make(null, null) {}
  override Bool equals(Obj? obj)
  {
    x := obj as SerB
    if (x == null) return false
    if (!super.equals(obj)) return false
    eq := z == x.z
    return eq
  }

  Int z := 'x'
}

**************************************************************************
** SerConst
**************************************************************************

@serializable
const class SerConst
{
  new make(Int a := 0, Int[]? b := null, Int[][]? c := null)
  {
    this.a = a
    if (b != null) this.b = b.toImmutable
    if (c != null) this.c = c.toImmutable
  }

  override Int hash()
  {
    return a.hash
  }

  override Bool equals(Obj? obj)
  {
    x := obj as SerConst
    if (x == null) return false
    return x.a == a && x.b == b && x.c == c
  }

  override Str toStr()
  {
    return "a=$a b=$b c=$c"
  }

  const Int a
  const Int[]? b
  const Int[][]? c
}

**************************************************************************
** SerListMap
**************************************************************************

@serializable
class SerListMap
{
  override Int hash() { return map.hash }

  override Bool equals(Obj? obj)
  {
    x := obj as SerListMap
    if (x == null) return false
    return x.list == list && x.list.type == list.type &&
          x.map == map && x.map.type == map.type
  }

  override Str toStr()
  {
    return Buf.make.writeObj(this).flip.readAllStr
  }

  Int[] list := Int[,]
  Str:Obj map := Str:Obj[:]
}

**************************************************************************
** SerSimple
**************************************************************************

@simple
class SerSimple
{
  static SerSimple fromStr(Str s)
  {
    return make(s[0...s.index(",")].toInt, s[s.index(",")+1..-1].toInt)
  }
  new make(Int a, Int b) { this.a = a; this.b = b }
  override Str toStr() { return "$a,$b" }
  override Int hash() { return a ^ b }
  override Bool equals(Obj? obj) { return a == obj->a && b == obj->b }
  Int a
  Int b
}

**************************************************************************
** SerSynthetic
**************************************************************************

@serializable
class SerSynthetic
{
  new make(Int a := 3) { this.a = a }
  Int a
  once Int b() { return a + 1 }

  override Int hash() { return a }
  override Bool equals(Obj? obj) { return a == obj->a }
  override Str toStr() { return "a=$a" }
}

**************************************************************************
** SerIntCollection
**************************************************************************

@serializable
@collection
class SerIntCollection
{
  This add(Int i) { list.add(i); return this }
  Void each(|Int i| f) { list.each(f) }
  override Int hash() { return list.hash }
  override Bool equals(Obj? obj) { return name == obj->name && list == obj->list }
  override Str toStr() { return name + " " + list.toStr }
  Str name
  @transient Int[] list := Int[,]
}

**************************************************************************
** SerFolder
**************************************************************************

@serializable
@collection
class SerFolder
{
  Void add(SerFolder x) { list.add(x) }
  Void each(|SerFolder i| f) { list.each(f) }
  override Int hash() { return list.hash }
  override Bool equals(Obj? obj) { return name == obj->name && list == obj->list }
  override Str toStr() { return name + " " + list.toStr }
  Str name
  @transient SerFolder[] list := SerFolder[,]
}