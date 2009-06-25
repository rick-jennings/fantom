//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   1 Jun 09  Andy Frank  Creation
//

/**
 * TextPeer.
 */
var fwt_TextPeer = sys_Obj.$extend(fwt_TextWidgetPeer);
fwt_TextPeer.prototype.$ctor = function(self) {}

fwt_TextPeer.prototype.text$get = function(self) { return this.text; }
fwt_TextPeer.prototype.text$set = function(self, val)
{
  this.text = val;
  if (this.elem != null && this.elem.firstChild != null)
    this.elem.firstChild.value = this.text;
}
fwt_TextPeer.prototype.text = "";

fwt_TextPeer.prototype.sync = function(self)
{
  var text = this.elem.firstChild;

  // do we need to create element?
  if (text == null)
  {
    if (self.multiLine) { text = document.createElement("textarea"); }
    else { text = document.createElement("input"); text.type = "text"; }
    this.elem.appendChild(text);
  }

  // sync control
  text.value = this.text;
  text.readOnly = !self.editable;
  if (self.multiLine)
  {

    // TODO - this differs a pixel or two by browser - so we'll need
    // to go back and fine tune
    text.style.width  = (this.size.w-6)+'px';
    text.style.height = (this.size.h-7)+'px';
  }
  else
  {
    // TODO - can we use CSS here for size??
    text.size  = self.prefCols;
  }
  text.onkeyup = function(event)
  {
    // IE-ness
    var target = event ? event.target : window.event.srcElement;
    var event  = event ? event : window.event;

    // sync control value to widget
    self.text$set(target.value);

    // fire onAction
    if (event.keyCode == 13 && self.onAction.size() > 0)
    {
      var ae = fwt_Event.make();
      ae.id = fwt_EventId.action;
      var list = self.onAction.list();
      for (var i=0; i<list.length; i++) list[i].call(ae);
    }

    // fire onModify
    if (self.onModify.size() > 0)
    {
      var me = fwt_Event.make();
      me.id = fwt_EventId.action;
      var list = self.onModify.list();
      for (var i=0; i<list.length; i++) list[i].call(me);
    }
  }
  fwt_WidgetPeer.prototype.sync.call(this, self);
}