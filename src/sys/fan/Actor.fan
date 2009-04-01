//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   26 Mar 09  Brian Frank  Creation
//

**
** Actor is a worker who processes messages asynchronously.
**
const class Actor
{
  **
  ** Create an actor whose execution is controlled by the given ActorGroup.
  ** If receive is non-null, then it is used to process messages sent to
  ** this actor.  If receive is specified then it must be an immutable
  ** function (it cannot capture state from the calling thread), otherwise
  ** NotImmutableErr is thrown.  If receive is null, then you must subclass
  ** Actor and override the `receive` method.
  **
  new make(ActorGroup group, |Context,Obj? -> Obj?|? receive := null)

  **
  ** Create an actor with a coalescing message loop.  This constructor
  ** follows the same semantics as `make`, but has the ability to coalesce
  ** the messages pending in the thread's message queue.  Coalesced
  ** messages are merged into a single pending message with a shared
  ** Future.
  **
  ** The 'toKey' function is used to derive a key for each message,
  ** or if null then the message itself is used as the key.  If the 'toKey'
  ** function returns null, then the message is not considered for coalescing.
  ** Internally messages are indexed by key for efficient coalescing.
  **
  ** If an incoming message has the same key as a pending message
  ** in the queue, then the 'coalesce' function is called to coalesce
  ** the messages into a new merged message.  If 'coalesce' is null,
  ** then we use the incoming message (last one wins).  The coalesced
  ** message occupies the same position in the queue as the original
  ** and reuses the original message's Future instance.
  **
  ** Both the 'toKey' and 'coalesce' functions are called while holding
  ** an internal lock on the queue.  So the functions must be efficient
  ** and never attempt to interact with other actors.
  **
  new makeCoalescing(ActorGroup group,
                     |Obj? msg->Obj?|? toKey,
                     |Obj? orig, Obj? incoming->Obj?|? coalesce,
                     |Context,Obj? -> Obj?|? receive := null)

  **
  ** The group used to control execution of this actor.
  **
  ActorGroup group()

  **
  ** Asynchronously send a message to this actor for processing.
  ** If msg is not immutable or serializable, then IOErr is thrown.
  ** Throw Err if this actor's group has been stopped.  Return
  ** a future which may be used to obtain the result once it the
  ** actor has processed the message.  If the message is coalesced
  ** then this method returns the original message's future reference.
  ** Also see `sendLater` and `sendWhenDone`.
  **
  Future send(Obj? msg)

  **
  ** Schedule a message for delivery after the specified period of
  ** duration has elapsed.  Once the period has elapsed the message is
  ** appended to the end of this actor's queue.  Accuracy of scheduling
  ** is dependent on thread coordination and pending messages in the queue.
  ** Scheduled messages are not guaranteed to be processed if the
  ** actor's grouped is stopped.  Scheduled messages are never coalesced.
  ** Also see `send` and `sendWhenDone`.
  **
  Future sendLater(Duration d, Obj? msg)

  **
  ** Schedule a message for delivery after the given future has completed.
  ** Completion may be due to the future returning a result, throwing an
  ** exception, or cancellation.  Send when done messages are never
  ** coalesced.  Also see `send` and `sendLater`.
  **
  Future sendWhenDone(Future f, Obj? msg)

  **
  ** The receive behavior for this actor is handled by overriding
  ** this method or by passing a function to the constructor.  Return
  ** the result made available by the Future.  If an exception
  ** is raised by this method, then it is raised by 'Future.get'.
  **
  protected virtual Obj? receive(Context cx, Obj? msg)

}