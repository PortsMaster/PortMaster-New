# Copyright (c) Mathias Kaerlev 2012.

# This file is part of Anaconda.

# Anaconda is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# Anaconda is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with Anaconda.  If not, see <http://www.gnu.org/licenses/>.

"""
LacewingServer.mfx
Lacewing Server - Jamie McLaughlin (http://www.aquadasoft.com)
Copyright 2007-2010 Jamie McLaughlin

This extension is a full implementation of the Lacewing networking
protocol, acting as a server. More information is available at
http://lacewing.aquadasoft.com

Ported to Python by Mathias Kaerlev
"""

from mmfparser.player.extensions.common import UserExtension, HiddenObject
from mmfparser.player.event.actions.common import Action
from mmfparser.player.event.conditions.common import Condition
from mmfparser.player.event.expressions.common import Expression

# Actions

class Action0(Action):
    """
    Lacewing server->Host

    Parameters:
    0: Port (default 6121) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        port = self.evaluate_index(0) or 6121
        instance.objectPlayer.host(port)

class Action1(Action):
    """
    Lacewing server->Stop hosting
    """

    def execute(self, instance):
        instance.objectPlayer.stop()

class FactoryAction(Action):
    def execute(self, instance):
        factory = instance.objectPlayer.factory
        if factory is None:
            return
        self.handle_action(factory)
    
    def handle_action(self, factory):
        raise NotImplementedError()

class Action2(FactoryAction):
    """
    Set welcome message

    Parameters:
    0: Welcome message (EXPSTRING, ExpressionParameter)
    """

    def handle_action(self, factory):
        value = self.evaluate_index(0)
        factory.welcomeMessage = value

class EnableInteractiveAction(Action):
    def execute(self, instance):
        instance.objectPlayer.handlers[self.name].set_interactive()

class EnablePassiveAction(Action):
    def execute(self, instance):
        instance.objectPlayer.handlers[self.name].set_passive()

class Action3(EnableInteractiveAction):
    """
    Enable conditions->On connect request->Interactive
    """
    name = 'OnConnectRequest'

class Action4(EnablePassiveAction):
    """
    Enable conditions->On connect request->Passive (faster)
    """
    name = 'OnConnectRequest'

class Action5(EnableInteractiveAction):
    """
    Enable conditions->On disconnect->Interactive
    """
    name = 'OnDisconnect'

class Action6(EnablePassiveAction):
    """
    Enable conditions->On disconnect->Passive (faster)
    """
    name = 'OnDisconnect'

class Action7(EnableInteractiveAction):
    """
    Enable conditions->On message to server->Interactive
    """
    name = 'OnServerMessage'

class Action8(EnablePassiveAction):
    """
    Enable conditions->On message to server->Passive (faster)
    """
    name = 'OnServerMessage'

class Action9(EnableInteractiveAction):
    """
    Enable conditions->On message to channel->Interactive
    """
    name = 'OnChannelMessage'

class Action10(EnablePassiveAction):
    """
    Enable conditions->On message to channel->Passive (faster)
    """
    name = 'OnChannelMessage'

class Action11(EnableInteractiveAction):
    """
    Enable conditions->On message to peer->Interactive
    """
    name = 'OnPeerMessage'

class Action12(EnablePassiveAction):
    """
    Enable conditions->On message to peer->Passive (faster)
    """
    name = 'OnPeerMessage'

class Action13(EnableInteractiveAction):
    """
    Enable conditions->On channel join request->Interactive
    """
    name = 'OnChannelJoinRequest'

class Action14(EnablePassiveAction):
    """
    Enable conditions->On channel join request->Passive (faster)
    """
    name = 'OnChannelJoinRequest'

class Action15(EnableInteractiveAction):
    """
    Enable conditions->On channel leave request->Interactive
    """
    name = 'OnChannelLeaveRequest'

class Action16(EnablePassiveAction):
    """
    Enable conditions->On channel leave request->Passive (faster)
    """
    name = 'OnChannelLeaveRequest'

class Action17(EnableInteractiveAction):
    """
    Enable conditions->On set name request->Interactive
    """
    name = 'OnSetNameRequest'

class Action18(EnablePassiveAction):
    """
    Enable conditions->On set name request->Passive (faster)
    """
    name = 'OnSetNameRequest'

class Action19(Action):
    """
    On interactive condition->Deny (for on [..] request)
    """

    def execute(self, instance):
        instance.objectPlayer.denyValue = True

class Action20(Action):
    """
    On interactive condition->Change name (for name set/change request)

    Parameters:
    0: New name (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.eventValue = self.evaluate_expression(
            self.get_parameter(0))

class Action21(Action):
    """
    On interactive condition->Change channel name (for channel join request)

    Parameters:
    0: New name (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.eventValue = self.evaluate_expression(
            self.get_parameter(0))

class Action22(Action):
    """
    Channel->Close channel
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action23(Action):
    """
    Channel->Select the channel master
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action24(Action):
    """
    Channel->Select by name

    Parameters:
    0: Name (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        return

class Action25(Action):
    """
    Channel->Loop all channels
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action26(Action):
    """
    Client->Disconnect
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action27(Action):
    """
    Client->Loop client's channels
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action28(Action):
    """
    Client->Select by name

    Parameters:
    0: Name (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action29(Action):
    """
    Client->Select by ID

    Parameters:
    0: ID (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action30(Action):
    """
    Client->Loop all clients
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action31(Action):
    """
    Send->Text->To client

    Parameters:
    0: Subchannel (0-255) (EXPRESSION, ExpressionParameter)
    1: Text to send (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action32(Action):
    """
    Send->Text->To channel

    Parameters:
    0: Subchannel (0-255) (EXPRESSION, ExpressionParameter)
    1: Text to send (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action33(Action):
    """
    Send->Number->To client

    Parameters:
    0: Subchannel (0-255) (EXPRESSION, ExpressionParameter)
    1: Number to send (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action34(Action):
    """
    Send->Number->To channel

    Parameters:
    0: Subchannel (0-255) (EXPRESSION, ExpressionParameter)
    1: Number to send (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action35(Action):
    """
    Send->Stack->To client

    Parameters:
    0: Subchannel (0-255) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action36(Action):
    """
    Send->Stack->To channel

    Parameters:
    0: Subchannel (0-255) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action37(Action):
    """
    Blast->Text->To client

    Parameters:
    0: Subchannel (0-255) (EXPRESSION, ExpressionParameter)
    1: Text to send (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action38(Action):
    """
    Blast->Text->To channel

    Parameters:
    0: Subchannel (0-255) (EXPRESSION, ExpressionParameter)
    1: Text to send (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action39(Action):
    """
    Blast->Number->To client

    Parameters:
    0: Subchannel (0-255) (EXPRESSION, ExpressionParameter)
    1: Number to send (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action40(Action):
    """
    Blast->Number->To channel

    Parameters:
    0: Subchannel (0-255) (EXPRESSION, ExpressionParameter)
    1: Number to send (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action41(Action):
    """
    Blast->Stack->To client

    Parameters:
    0: Subchannel (0-255) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action42(Action):
    """
    Blast->Stack->To channel

    Parameters:
    0: Subchannel (0-255) (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action43(Action):
    """
    Send stack->Push byte->ASCII character

    Parameters:
    0: Byte (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action44(Action):
    """
    Send stack->Push byte->Integer value

    Parameters:
    0: Byte (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action45(Action):
    """
    Send stack->Push short

    Parameters:
    0: Short (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action46(Action):
    """
    Send stack->Push integer

    Parameters:
    0: Integer (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action47(Action):
    """
    Send stack->Push float

    Parameters:
    0: Float (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action48(Action):
    """
    Send stack->Push string->Without null terminator

    Parameters:
    0: String (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action49(Action):
    """
    Send stack->Push string->With null terminator

    Parameters:
    0: String (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action50(Action):
    """
    Send stack->Push binary

    Parameters:
    0: Address (EXPRESSION, ExpressionParameter)
    1: Size (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action51(Action):
    """
    Send stack->Push file

    Parameters:
    0: File to push (FILENAME, Filename)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action52(Action):
    """
    Send stack->Compress (ZLIB)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action53(Action):
    """
    Send stack->Clear
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action54(Action):
    """
    Received stack->Save to a file

    Parameters:
    0: Position (EXPRESSION, ExpressionParameter)
    1: Size (EXPRESSION, ExpressionParameter)
    2: Filename (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action55(Action):
    """
    Received stack->Append to a file

    Parameters:
    0: Position (EXPRESSION, ExpressionParameter)
    1: Size (EXPRESSION, ExpressionParameter)
    2: Filename (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action56(Action):
    """
    Received stack->Uncompress (ZLIB)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action57(Action):
    """
    Channel->Loop clients
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action58(Action):
    """
    On interactive condition->Drop message (for on message to channel/peer)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action59(Action):
    """
    Client->Select sender (for "on message to peer")
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action60(Action):
    """
    Client->Select receiver (for "on message to peer")
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action61(Action):
    """
    Channel->Loop all channels (with loop name)

    Parameters:
    0: Loop name (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action62(Action):
    """
    Client->Loop all clients (with loop name)

    Parameters:
    0: Loop name (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action63(Action):
    """
    Client->Loop client's channels (with loop name)

    Parameters:
    0: Loop name (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action64(Action):
    """
    Flash Player policy server->Host

    Parameters:
    0: XML policy file (FILENAME, Filename)
    1: - ((unknown -256))
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action65(Action):
    """
    Flash Player policy server->Stop hosting
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action66(Action):
    """
    Client->Set local client data

    Parameters:
    0: Key (EXPSTRING, ExpressionParameter)
    1: Value (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action67(Action):
    """
    Received stack->Move cursor

    Parameters:
    0: Position (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action68(Action):
    """
    Channel->Set local channel data

    Parameters:
    0: Key (EXPSTRING, ExpressionParameter)
    1: Value (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action69(Action):
    """
    Build #17 (DLL)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))


# Conditions

class Condition0(Condition):
    """
    On error
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition1(Condition):
    """
    Connection->On connect request
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition2(Condition):
    """
    Connection->On disconnect
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition3(Condition):
    """
    Channel->On join request
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition4(Condition):
    """
    Channel->On leave request
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition5(Condition):
    """
    Channel->On all channels loop
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition6(Condition):
    """
    Channel->On client's channels loop
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition7(Condition):
    """
    Client->On all clients loop
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition8(Condition):
    """
    Client->On channel clients loop
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition9(Condition):
    """
    Client->Client is the channel master
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition10(Condition):
    """
    Client->On name set request
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition11(Condition):
    """
    Message->Sent->On text message to server

    Parameters:
    0: Subchannel (-1 for any) (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition12(Condition):
    """
    Message->Sent->On number message to server

    Parameters:
    0: Subchannel (-1 for any) (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition13(Condition):
    """
    Message->Sent->On stack message to server

    Parameters:
    0: Subchannel (-1 for any) (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition14(Condition):
    """
    Message->Sent->On any message to server

    Parameters:
    0: Subchannel (-1 for any) (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition15(Condition):
    """
    Message->Sent->On text message to channel

    Parameters:
    0: Subchannel (-1 for any) (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition16(Condition):
    """
    Message->Sent->On number message to channel

    Parameters:
    0: Subchannel (-1 for any) (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition17(Condition):
    """
    Message->Sent->On stack message to channel

    Parameters:
    0: Subchannel (-1 for any) (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition18(Condition):
    """
    Message->Sent->On any message to channel

    Parameters:
    0: Subchannel (-1 for any) (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition19(Condition):
    """
    Message->Sent->On text message to peer

    Parameters:
    0: Subchannel (-1 for any) (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition20(Condition):
    """
    Message->Sent->On number message to peer

    Parameters:
    0: Subchannel (-1 for any) (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition21(Condition):
    """
    Message->Sent->On stack message to peer

    Parameters:
    0: Subchannel (-1 for any) (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition22(Condition):
    """
    Message->Sent->On any message to peer

    Parameters:
    0: Subchannel (-1 for any) (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition23(Condition):
    """
    Message->Blasted->On text message to server

    Parameters:
    0: Subchannel (-1 for any) (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition24(Condition):
    """
    Message->Blasted->On number message to server

    Parameters:
    0: Subchannel (-1 for any) (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition25(Condition):
    """
    Message->Blasted->On stack message to server

    Parameters:
    0: Subchannel (-1 for any) (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition26(Condition):
    """
    Message->Blasted->On any message to server

    Parameters:
    0: Subchannel (-1 for any) (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition27(Condition):
    """
    Message->Blasted->On text message to channel

    Parameters:
    0: Subchannel (-1 for any) (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition28(Condition):
    """
    Message->Blasted->On number message to channel

    Parameters:
    0: Subchannel (-1 for any) (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition29(Condition):
    """
    Message->Blasted->On stack message to channel

    Parameters:
    0: Subchannel (-1 for any) (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition30(Condition):
    """
    Message->Blasted->On any message to channel

    Parameters:
    0: Subchannel (-1 for any) (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition31(Condition):
    """
    Message->Blasted->On text message to peer

    Parameters:
    0: Subchannel (-1 for any) (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition32(Condition):
    """
    Message->Blasted->On number message to peer

    Parameters:
    0: Subchannel (-1 for any) (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition33(Condition):
    """
    Message->Blasted->On stack message to peer

    Parameters:
    0: Subchannel (-1 for any) (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition34(Condition):
    """
    Message->Blasted->On any message to peer

    Parameters:
    0: Subchannel (-1 for any) (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition35(Condition):
    """
    Channel->[With loop name] On all channels loop

    Parameters:
    0: Loop name (EXPSTRING, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition36(Condition):
    """
    Channel->[With loop name] On client's channels loop

    Parameters:
    0: Loop name (EXPSTRING, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition37(Condition):
    """
    Client->[With loop name] On all clients loop

    Parameters:
    0: Loop name (EXPSTRING, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition38(Condition):
    """
    Client->[With loop name] On channel clients loop

    Parameters:
    0: Loop name (EXPSTRING, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition39(Condition):
    """
    Client->[With loop name] On channel clients loop finished

    Parameters:
    0: Loop name (EXPSTRING, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition40(Condition):
    """
    Channel->[With loop name] On all channels loop finished

    Parameters:
    0: Loop name (EXPSTRING, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition41(Condition):
    """
    Channel->[With loop name] On client's channels loop finished

    Parameters:
    0: Loop name (EXPSTRING, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition42(Condition):
    """
    Client->On channel clients loop finished
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition43(Condition):
    """
    Channel->On all channels loop finished
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition44(Condition):
    """
    Client->[With loop name] On all clients loop finished
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition45(Condition):
    """
    Channel->On client's channels loop finished
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition46(Condition):
    """
    Lacewing server is hosting
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition47(Condition):
    """
    Flash Player policy server is hosting
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition48(Condition):
    """
    Channel->Channel is hidden from the channel list
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition49(Condition):
    """
    Channel->Channel is set to close automatically
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))


# Expressions

class Expression0(Expression):
    """
    Error string (for on error)
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression1(Expression):
    """
    Lacewing version string
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression2(Expression):
    """
    Send stack size
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression3(Expression):
    """
    Requested name (for name set/change request)
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression4(Expression):
    """
    Requested channel name (for channel join request)
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression5(Expression):
    """
    Channel->Name
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression6(Expression):
    """
    Channel->Client count
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression7(Expression):
    """
    Client->Name
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression8(Expression):
    """
    Client->ID
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression9(Expression):
    """
    Client->IP address
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression10(Expression):
    """
    Client->Connection time
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression11(Expression):
    """
    Client->Channel count
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression12(Expression):
    """
    Received->Get text
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression13(Expression):
    """
    Received->Get number
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression14(Expression):
    """
    Received->Get stack size
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression15(Expression):
    """
    Received->Get stack memory address
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression16(Expression):
    """
    Received->Get stack data->Byte->ASCII character

    Parameters:
    0: Index (Int)
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression17(Expression):
    """
    Received->Get stack data->Byte->Integer value->Unsigned

    Parameters:
    0: Index (Int)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression18(Expression):
    """
    Received->Get stack data->Byte->Integer value->Signed

    Parameters:
    0: Index (Int)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression19(Expression):
    """
    Received->Get stack data->Short->Unsigned

    Parameters:
    0: Index (Int)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression20(Expression):
    """
    Received->Get stack data->Short->Signed

    Parameters:
    0: Index (Int)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression21(Expression):
    """
    Received->Get stack data->Integer->Unsigned

    Parameters:
    0: Index (Int)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression22(Expression):
    """
    Received->Get stack data->Integer->Signed

    Parameters:
    0: Index (Int)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression23(Expression):
    """
    Received->Get stack data->Float

    Parameters:
    0: Index (Int)
    Return type: Float
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression24(Expression):
    """
    Received->Get stack data->String->With size

    Parameters:
    0: Index (Int)
    1: Size (Int)
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression25(Expression):
    """
    Received->Get stack data->String->Null terminated

    Parameters:
    0: Index (Int)
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression26(Expression):
    """
    Received->Get subchannel
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression27(Expression):
    """
    Channel->Number of channels on the server
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression28(Expression):
    """
    Client->Get local client data

    Parameters:
    0: Key (String)
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression29(Expression):
    """
    Received->Get stack data (with cursor)->Byte->ASCII character
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression30(Expression):
    """
    Received->Get stack data (with cursor)->Byte->Integer value->Unsigned
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression31(Expression):
    """
    Received->Get stack data (with cursor)->Byte->Integer value->Signed
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression32(Expression):
    """
    Received->Get stack data (with cursor)->Short->Unsigned
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression33(Expression):
    """
    Received->Get stack data (with cursor)->Short->Signed
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression34(Expression):
    """
    Received->Get stack data (with cursor)->Integer->Unsigned
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression35(Expression):
    """
    Received->Get stack data (with cursor)->Integer->Signed
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression36(Expression):
    """
    Received->Get stack data (with cursor)->Float
    Return type: Float
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression37(Expression):
    """
    Received->Get stack data (with cursor)->String->With size

    Parameters:
    0: Size (Int)
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression38(Expression):
    """
    Received->Get stack data (with cursor)->String->Null terminated
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression39(Expression):
    """
    Client->Get client protocol implementation
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression40(Expression):
    """
    Channel->Get local channel data

    Parameters:
    0: Key (String)
    Return type: String
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

from twisted.internet import reactor, protocol
from twisted.protocols import basic
from lacewing.server import (ServerProtocol, ServerDatagram, 
    ServerFactory)

class ExtensionProtocol(ServerProtocol):
    pass

class ExtensionFactory(ServerFactory):
    protocol = ExtensionProtocol

class FlashPolicyProtocol(basic.LineReceiver):
    delimiter = '\x00'
    MAX_LENGTH = 64

    def lineReceived(self, request):
        if request != '<policy-file-request/>':
            self.transport.loseConnection()
            return
        self.transport.write(self.factory.policyData)

class FlashPolicyFactory(protocol.ServerFactory):
    protocol = FlashPolicyProtocol
    policyData = None

    def __init__(self, data):
        self.policyData = data + '\x00'
    
class HandlerOption(object):
    passive = interactive = False
    
    def set_passive(self):
        self.interactive = False
        self.passive = True
    
    def set_interactive(self):
        self.passive = False
        self.interactive = True
    
    def __bool__(self):
        return self.passive or self.interactive

class DefaultObject(HiddenObject):
    clearStack = None
    isGlobal = None
    subApplicationGlobal = None
    globalIdentifier = None

    factory = None
    port = None
    udpPort = None
    
    policyPort = None
    
    # event stuff
    handlers = None
    denyValue = False
    eventValue = None
    def created(self, data):
        self.clearStack = bool(data.readByte())
        self.isGlobal = bool(data.readByte())
        self.subApplicationGlobal = bool(data.readByte())
        self.globalIdentifier = data.readString()
        self.handlers = {
            'OnConnectRequest' : HandlerOption(),
            'OnDisconnect' : HandlerOption(),
            'OnServerMessage' : HandlerOption(),
            'OnChannelMessage' : HandlerOption(),
            'OnPeerMessage' : HandlerOption(),
            'OnChannelJoinRequest' : HandlerOption(),
            'OnSetNameRequest' : HandlerOption()
        }
    
    def host(self, port = 6121):
        self.factory = newFactory = ExtensionFactory()
        self.port = reactor.listenTCP(port, newFactory)
        self.udpPort = reactor.listenUDP(port, ServerDatagram(newFactory))
        reactor.run()
    
    def stop(self):
        if self.port is None:
            return
        self.port.stopListening()
        self.udpPort.stopListening()
        self.factory = self.port = self.udpPort = None
    
    def host_policy(self, data):
        self.policyPort = reactor.listenTCP(843, FlashPolicyFactory(data))
        reactor.run()
        
    def stop_policy(self):
        if self.policyPort is None:
            return
        self.policyPort.stopListening()
        self.policyPort = None
    
    def on_detach(self):
        reactor.callFromThread(reactor.stop)

class LacewingServer(UserExtension):
    objectPlayer = DefaultObject
    
    actions = {
        0 : Action0,
        1 : Action1,
        2 : Action2,
        3 : Action3,
        4 : Action4,
        5 : Action5,
        6 : Action6,
        7 : Action7,
        8 : Action8,
        9 : Action9,
        10 : Action10,
        11 : Action11,
        12 : Action12,
        13 : Action13,
        14 : Action14,
        15 : Action15,
        16 : Action16,
        17 : Action17,
        18 : Action18,
        19 : Action19,
        20 : Action20,
        21 : Action21,
        25 : Action22,
        26 : Action23,
        27 : Action24,
        28 : Action25,
        29 : Action26,
        30 : Action27,
        31 : Action28,
        32 : Action29,
        33 : Action30,
        34 : Action31,
        35 : Action32,
        36 : Action33,
        37 : Action34,
        38 : Action35,
        39 : Action36,
        40 : Action37,
        41 : Action38,
        42 : Action39,
        43 : Action40,
        44 : Action41,
        45 : Action42,
        46 : Action43,
        47 : Action44,
        48 : Action45,
        49 : Action46,
        50 : Action47,
        51 : Action48,
        52 : Action49,
        53 : Action50,
        54 : Action51,
        55 : Action52,
        56 : Action53,
        57 : Action54,
        58 : Action55,
        59 : Action56,
        60 : Action57,
        61 : Action58,
        62 : Action59,
        63 : Action60,
        64 : Action61,
        65 : Action62,
        66 : Action63,
        68 : Action64,
        69 : Action65,
        70 : Action66,
        71 : Action67,
        72 : Action68,
        -1 : Action69,
    }
    
    conditions = {
        0 : Condition0,
        1 : Condition1,
        2 : Condition2,
        3 : Condition3,
        4 : Condition4,
        5 : Condition5,
        6 : Condition6,
        7 : Condition7,
        8 : Condition8,
        9 : Condition9,
        10 : Condition10,
        12 : Condition11,
        13 : Condition12,
        14 : Condition13,
        15 : Condition14,
        16 : Condition15,
        17 : Condition16,
        18 : Condition17,
        19 : Condition18,
        20 : Condition19,
        21 : Condition20,
        22 : Condition21,
        23 : Condition22,
        24 : Condition23,
        25 : Condition24,
        26 : Condition25,
        27 : Condition26,
        28 : Condition27,
        29 : Condition28,
        30 : Condition29,
        31 : Condition30,
        32 : Condition31,
        33 : Condition32,
        34 : Condition33,
        35 : Condition34,
        36 : Condition35,
        37 : Condition36,
        38 : Condition37,
        39 : Condition38,
        40 : Condition39,
        41 : Condition40,
        43 : Condition41,
        44 : Condition42,
        45 : Condition43,
        46 : Condition44,
        47 : Condition45,
        48 : Condition46,
        49 : Condition47,
        50 : Condition48,
        51 : Condition49,
    }
    
    expressions = {
        0 : Expression0,
        1 : Expression1,
        2 : Expression2,
        3 : Expression3,
        4 : Expression4,
        5 : Expression5,
        6 : Expression6,
        7 : Expression7,
        8 : Expression8,
        9 : Expression9,
        10 : Expression10,
        11 : Expression11,
        12 : Expression12,
        13 : Expression13,
        14 : Expression14,
        15 : Expression15,
        16 : Expression16,
        17 : Expression17,
        18 : Expression18,
        19 : Expression19,
        20 : Expression20,
        21 : Expression21,
        22 : Expression22,
        23 : Expression23,
        24 : Expression24,
        25 : Expression25,
        26 : Expression26,
        27 : Expression27,
        28 : Expression28,
        29 : Expression29,
        30 : Expression30,
        31 : Expression31,
        32 : Expression32,
        33 : Expression33,
        34 : Expression34,
        35 : Expression35,
        36 : Expression36,
        37 : Expression37,
        38 : Expression38,
        39 : Expression39,
        40 : Expression40,
    }

extension = LacewingServer()

def get_extension():
    return extension
