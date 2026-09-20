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
moogame.mfx

Ported to Python by Mathias Kaerlev
"""

from mmfparser.player.extensions.common import UserExtension, HiddenObject
from mmfparser.player.event.actions.common import Action
from mmfparser.player.event.conditions.common import Condition
from mmfparser.player.event.expressions.common import Expression

from twisted.internet import protocol, reactor
from lacewing.moo.client import MooClientProtocol
from lacewing.moo.packetloaders.message import *

# Actions

class Action0(Action):
    """
    Set Name

    Parameters:
    0: Set Name (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        instance.objectPlayer.set_name(self.evaluate_expression(
            self.get_parameter(0)))

class Action1(Action):
    """
    Connect

    Parameters:
    0: Connect (EXPSTRING, ExpressionParameter)
    1: Connect (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        ip = self.evaluate_index(0)
        port = self.evaluate_index(1)
        instance.objectPlayer.connect(ip, port)

class Action2(Action):
    """
    Disconnect
    """

    def execute(self, instance):
        raise NotImplementedError('Disconnect not implemented')

class ProtocolAction(Action):
    def execute(self, instance):
        protocol = instance.objectPlayer.protocol
        if protocol is None:
            return
        self.action(protocol)
    
    def action(self, protocol):
        pass

class Action3(ProtocolAction):
    """
    Sign On

    Parameters:
    0: Sign On (EXPSTRING, ExpressionParameter)
    """

    def action(self, protocol):
        name = self.evaluate_index(0)
        protocol.joinChannel(name)

class Action4(Action):
    """
    Sign Off
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action5(Action):
    """
    Send->Set Method->Send Guaranteed
    """

    def execute(self, instance):
        pass

class Action6(Action):
    """
    Send->Set Method->Send Non-Guaranteed
    """

    def execute(self, instance):
        pass

class Action7(Action):
    """
    Send->Set Recepient->Send to Channel
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action8(Action):
    """
    Send->Set Recepient->Send to User Id

    Parameters:
    0: Send to User Id (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action9(Action):
    """
    Send->Set Recepient->Send to Server
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

def send_message(protocol, value, subchannel, type):
    recipient = protocol.player.recipient
    try:
        if recipient == 'server':
            func = protocol.sendMessage
        elif recipient == 'channel':
            func = protocol.player.channel.sendMessage
        elif recipient == 'peer':
            func = protocol.player.peer.sendMessage
    except AttributeError:
        return
    print 'sending to %r: %r @ %r' % (recipient, value, subchannel)
    func(value, subchannel, type = type)

class Action10(ProtocolAction):
    """
    Send->Send String

    Parameters:
    0: Send String (EXPSTRING, ExpressionParameter)
    1: Send String (EXPRESSION, ExpressionParameter)
    """

    def action(self, protocol):
        value = self.evaluate_index(0)
        subchannel = self.evaluate_index(1)
        send_message(protocol, value, subchannel, STRING)

class Action11(ProtocolAction):
    """
    Send->Send Number

    Parameters:
    0: Send Number (EXPRESSION, ExpressionParameter)
    1: Send Number (EXPRESSION, ExpressionParameter)
    """

    def action(self, protocol):
        value = self.evaluate_index(0)
        subchannel = self.evaluate_index(1)
        send_message(protocol, value, subchannel, NUMBER)

class Action12(Action):
    """
    Send->Send Binary

    Parameters:
    0: Send Binary (EXPSTRING, ExpressionParameter)
    1: Send Binary (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        filename = self.evaluate_index(0)
        try:
            value = open(filename, 'rb').read()
        except IOError:
            return
        subchannel = self.evaluate_index(1)
        send_message(protocol, value, subchannel, BINARY)

class Action13(Action):
    """
    Send->Object Tracking->Send Object

    Parameters:
    0: Send Object (OBJECT, Object)
    1: Send Object (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        return

class Action14(Action):
    """
    Send->Object Tracking->Enable Sending of...->Enable X Coordinate
    """

    def execute(self, instance):
        return

class Action15(Action):
    """
    Send->Object Tracking->Enable Sending of...->Enable Y Coordinate
    """

    def execute(self, instance):
        return

class Action16(Action):
    """
    Send->Object Tracking->Enable Sending of...->Enable Direction
    """

    def execute(self, instance):
        return

class Action17(Action):
    """
    Send->Object Tracking->Enable Sending of...->Enable Speed
    """

    def execute(self, instance):
        return

class Action18(Action):
    """
    Dead Reckoning->Edit Settings->Direction Tracking->Linear Progression
    """

    def execute(self, instance):
        return

class Action19(Action):
    """
    Dead Reckoning->Edit Settings->Direction Tracking->Incremental Rotation
    """

    def execute(self, instance):
        return

class Action20(Action):
    """
    Send->Object Tracking->Enable Sending of...->Enable Animation Frame
    """

    def execute(self, instance):
        return

class Action21(Action):
    """
    Send->Object Tracking->Enable Sending of...->Enable Alterable Value A
    """

    def execute(self, instance):
        return

class Action22(Action):
    """
    Send->Object Tracking->Enable Sending of...->Enable Alterable Value B
    """

    def execute(self, instance):
        return

class Action23(Action):
    """
    Send->Object Tracking->Enable Sending of...->Enable Alterable Value C
    """

    def execute(self, instance):
        return

class Action24(Action):
    """
    Send->Object Tracking->Enable Sending of...->Enable Alterable Flags
    """

    def execute(self, instance):
        return

class Action25(Action):
    """
    Send->Object Tracking->Disable Sending of...->Disable X Coordinate
    """

    def execute(self, instance):
        return

class Action26(Action):
    """
    Send->Object Tracking->Disable Sending of...->Disable Y Coordinate
    """

    def execute(self, instance):
        return

class Action27(Action):
    """
    Send->Object Tracking->Disable Sending of...->Disable Direction
    """

    def execute(self, instance):
        return

class Action28(Action):
    """
    Send->Object Tracking->Disable Sending of...->Disable Speed
    """

    def execute(self, instance):
        return

class Action29(Action):
    """
    Send->Object Tracking->Disable Sending of...->Disable Animation Frame
    """

    def execute(self, instance):
        return

class Action30(Action):
    """
    Send->Object Tracking->Disable Sending of...->Disable Alterable Value A
    """

    def execute(self, instance):
        return

class Action31(Action):
    """
    Send->Object Tracking->Disable Sending of...->Disable Alterable Value B
    """

    def execute(self, instance):
        return

class Action32(Action):
    """
    Send->Object Tracking->Disable Sending of...->Disable Alterable Value C
    """

    def execute(self, instance):
        return

class Action33(Action):
    """
    Send->Object Tracking->Disable Sending of...->Disable Alterable Flags
    """

    def execute(self, instance):
        return

class Action34(Action):
    """
    Receive->Load Binary

    Parameters:
    0: Load Binary (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action35(Action):
    """
    Receive->Load Object

    Parameters:
    0: Load Object (OBJECT, Object)
    """

    def execute(self, instance):
        return

class Action36(Action):
    """
    Server Side INI->Set Filename

    Parameters:
    0: Set Filename (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action37(Action):
    """
    Server Side INI->Set Group

    Parameters:
    0: Set Group (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action38(Action):
    """
    Server Side INI->Set Item

    Parameters:
    0: Set Item (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action39(Action):
    """
    Server Side INI->Set Value

    Parameters:
    0: Set Value (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action40(Action):
    """
    Server Side INI->Set String

    Parameters:
    0: Set String (EXPSTRING, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action41(Action):
    """
    Server Side INI->Load Value
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action42(Action):
    """
    Server Side INI->Load String
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action43(Action):
    """
    Dead Reckoning->Edit Settings->Smoothing Algorithm->Use Point to Point
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action44(Action):
    """
    Dead Reckoning->Edit Settings->Smoothing Algorithm->Use Linear Motion
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action45(Action):
    """
    Dead Reckoning->Edit Settings->Smoothing Algorithm->Use Quadratic Motion
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action46(Action):
    """
    Dead Reckoning->Edit Settings->Smoothing Algorithm->Use Cubic Splines
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action47(Action):
    """
    Dead Reckoning->Select Object

    Parameters:
    0: Select Object (OBJECT, Object)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action48(Action):
    """
    Dead Reckoning->Input Tracking

    Parameters:
    0: Input Tracking (EXPRESSION, ExpressionParameter)
    1: Input Tracking (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action49(Action):
    """
    Dead Reckoning->Output Tracking

    Parameters:
    0: Output Tracking (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action50(Action):
    """
    Dead Reckoning->Remove Tracking
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action51(Action):
    """
    Dead Reckoning->Pause Tracking

    Parameters:
    0: Pause Tracking (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action52(Action):
    """
    Dead Reckoning->Resume Tracking

    Parameters:
    0: Resume Tracking (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action53(Action):
    """
    Dead Reckoning->Edit Settings->Set Frame Delay

    Parameters:
    0: Set Frame Delay (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action54(Action):
    """
    Dead Reckoning->Edit Settings->Set Threshold

    Parameters:
    0: Set Threshold (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action55(Action):
    """
    Dead Reckoning->Edit Settings->Packet Routing->Favor Delivery Speed
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action56(Action):
    """
    Dead Reckoning->Edit Settings->Packet Routing->Favor Bandwidth Size
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action57(Action):
    """
    Send->Object Tracking->Enable Sending of...->Enable All
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action58(Action):
    """
    Send->Object Tracking->Enable Sending of...->Enable Position
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action59(Action):
    """
    Send->Object Tracking->Enable Sending of...->Enable Velocity
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action60(Action):
    """
    Send->Object Tracking->Enable Sending of...->Enable Alterable Values
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action61(Action):
    """
    Send->Object Tracking->Disable Sending of...->Disable All
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action62(Action):
    """
    Send->Object Tracking->Disable Sending of...->Disable Position
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action63(Action):
    """
    Send->Object Tracking->Disable Sending of...->Disable Velocity
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action64(Action):
    """
    Send->Object Tracking->Disable Sending of...->Disable Alterable Values
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action65(Action):
    """
    Dead Reckoning->Edit Settings->Set Projection Frames

    Parameters:
    0: Set Projection Frames (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action66(Action):
    """
    Dead Reckoning->Edit Settings->Set Smoothing Frames

    Parameters:
    0: Set Smoothing Frames (EXPRESSION, ExpressionParameter)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action67(Action):
    """
    Dead Reckoning->Edit Default Settings
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action68(Action):
    """
    Dead Reckoning->Edit Object Settings
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action69(Action):
    """
    Dead Reckoning->Edit Settings->Packet Type->Use Non-Guaranteed Packets
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Action70(Action):
    """
    Dead Reckoning->Edit Settings->Packet Type->Use Guaranteed Packets (DEBUG)
    """

    def execute(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

# Conditions

class TriggeredCondition(Condition):
    handler = None
    iterateObjects = False
    instance = None
    
    def created(self):
        self.add_handlers(**{self.handler : self.on_trigger})
    
    def on_trigger(self, instance):
        print 'on_trigger:', self.handler
        self.generate()

    def check(self):
        return True

class Condition0(Condition):
    """
    Connection Status->Is Connected
    """

    def check(self, instance):
        return instance.objectPlayer.connected()

class OnConnect(TriggeredCondition):
    """
    Connection Status->On Connect
    """
    handler = 'on_connect'

class OnDisconnect(TriggeredCondition):
    """
    Connection Status->On Disconnect
    """
    handler = 'on_disconnect'

class Condition3(Condition):
    """
    Channel Status->Is Signed On
    """

    def check(self, instance):
        return instance.objectPlayer.signed_on()

class OnSignOn(TriggeredCondition):
    """
    Channel Status->On Sign On
    """
    handler = 'on_sign_on'

class OnSignOff(TriggeredCondition):
    """
    Channel Status->On Sign Off
    """
    handler = 'on_sign_off'

class Condition6(Condition):
    """
    Channel Status->Is Channel Master
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition7(Condition):
    """
    Message Received->On String Message

    Parameters:
    0: On String Message (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition8(Condition):
    """
    Message Received->On Number Message

    Parameters:
    0: On Number Message (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition9(Condition):
    """
    Message Received->On Binary Message

    Parameters:
    0: On Binary Message (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition10(Condition):
    """
    Message Received->On Object Message

    Parameters:
    0: On Object Message (EXPRESSION, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition11(Condition):
    """
    Users->On User Is Here
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition12(Condition):
    """
    Users->On User Joined
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition13(Condition):
    """
    Users->On User Left
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition14(Condition):
    """
    Users->On User Name Changed
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition15(Condition):
    """
    Users->Is User Name Here

    Parameters:
    0: Is User Name Here (EXPSTRING, ExpressionParameter)
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition16(Condition):
    """
    Server Side INI->On Value Loaded
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition17(Condition):
    """
    Server Side INI->On String Loaded
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Condition18(Condition):
    """
    Error Occurred
    """

    def check(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))


# Expressions

class Expression0(Expression):
    """
    Get Id
    Return type: Int
    """

    def get(self, instance):
        protocol = instance.objectPlayer.protocol
        if protocol is None:
            return 0
        return protocol.id or 0

class Expression1(Expression):
    """
    Get Name
    Return type: Int
    """

    def get(self, instance):
        protocol = instance.objectPlayer.protocol
        if protocol is None:
            return
        return protocol.name or ''

class Expression2(Expression):
    """
    Get IP Address
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression3(Expression):
    """
    Channel->Get Id
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression4(Expression):
    """
    Channel->Get Name
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression5(Expression):
    """
    Channel->Get User Count
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression6(Expression):
    """
    Channel->Users->Get Id from List

    Parameters:
    0: (not found) (Int)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression7(Expression):
    """
    Channel->Users->Get Name from List

    Parameters:
    0: (not found) (Int)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression8(Expression):
    """
    Channel->Users->Get Name using Id

    Parameters:
    0: (not found) (Int)
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression9(Expression):
    """
    Channel->Users->Get Channel Master Id
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression10(Expression):
    """
    Get Message->Get String
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression11(Expression):
    """
    Get Message->Get Value
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression12(Expression):
    """
    Get Message->Get Sender's ID
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression13(Expression):
    """
    Get Message->Get Sender's Name
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression14(Expression):
    """
    Get Message->Get Sender's IP Address
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression15(Expression):
    """
    Join/Left User->Get User's ID
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression16(Expression):
    """
    Join/Left User->Get User's Name
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression17(Expression):
    """
    Join/Left User->Get User's IP Address
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression18(Expression):
    """
    Join/Left User->Get User's Old Name
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression19(Expression):
    """
    Errors->Get Error Number
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression20(Expression):
    """
    Errors->Get Error Message
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression21(Expression):
    """
    Server Status->Get Message of the Day
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression22(Expression):
    """
    Server Status->Get Version
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression23(Expression):
    """
    Server Status->Get IP Address
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression24(Expression):
    """
    Server Side INI->Get Value
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression25(Expression):
    """
    Server Side INI->Get String
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression26(Expression):
    """
    Stats->Get Runtime
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression27(Expression):
    """
    Stats->Totals->Packets->Get Total Packet Count
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression28(Expression):
    """
    Stats->Totals->Packets->Get Incoming Packet Count
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression29(Expression):
    """
    Stats->Totals->Packets->Get Outgoing Packet Count
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression30(Expression):
    """
    Stats->Totals->Bytes->Get Total Byte Count
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression31(Expression):
    """
    Stats->Totals->Bytes->Get Incoming Byte Count
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression32(Expression):
    """
    Stats->Totals->Bytes->Get Outgoing Byte Count
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression33(Expression):
    """
    Stats->Averages->Packet Size->Get Average Packet Size
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression34(Expression):
    """
    Stats->Averages->Packet Size->Get Average Incoming Packet Size
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression35(Expression):
    """
    Stats->Averages->Packet Size->Get Average Outgoing Packet Size
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression36(Expression):
    """
    Stats->Averages->Throughput->Get Average Throughput
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression37(Expression):
    """
    Stats->Averages->Throughput->Get Average Incoming Throughput
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression38(Expression):
    """
    Stats->Averages->Throughput->Get Average Outgoing Throughput
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression39(Expression):
    """
    Stats->Maximums->Packet Size->Get Biggest Packet Size
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression40(Expression):
    """
    Stats->Maximums->Packet Size->Get Biggest Incoming Packet Size
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression41(Expression):
    """
    Stats->Maximums->Packet Size->Get Biggest Outgoing Packet Size
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression42(Expression):
    """
    Stats->Maximums->Throughput->Get Highest Throughput
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression43(Expression):
    """
    Stats->Maximums->Throughput->Get Highest Incoming Throughput
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression44(Expression):
    """
    Stats->Maximums->Throughput->Get Highest Outgoing Throughput
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression45(Expression):
    """
    Stats->Minimums->Packet Size->Get Smallest Packet Size
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression46(Expression):
    """
    Stats->Minimums->Packet Size->Get Smallest Incoming Packet Size
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression47(Expression):
    """
    Stats->Minimums->Packet Size->Get Smallest Outgoing Packet Size
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression48(Expression):
    """
    Stats->Minimums->Throughput->Get Lowest Throughput
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression49(Expression):
    """
    Stats->Minimums->Throughput->Get Lowest Incoming Throughput
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression50(Expression):
    """
    Stats->Minimums->Throughput->Get Lowest Outgoing Throughput
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression51(Expression):
    """
    Stats->Sampling->Current Throughput Reading->Get Current Throughput
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression52(Expression):
    """
    Stats->Sampling->Current Throughput Reading->Get Current Incoming Throughput
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression53(Expression):
    """
    Stats->Sampling->Current Throughput Reading->Get Current Outgoing Throughput
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression54(Expression):
    """
    Stats->Sampling->Last Throughput Reading->Get Last Throughput
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression55(Expression):
    """
    Stats->Sampling->Last Throughput Reading->Get Last Incoming Throughput
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression56(Expression):
    """
    Stats->Sampling->Last Throughput Reading->Get Last Outgoing Throughput
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression57(Expression):
    """
    Stats->Sampling->Last Packet Size->Get Last Packet Size
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression58(Expression):
    """
    Stats->Sampling->Last Packet Size->Get Last Incoming Packet Size
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression59(Expression):
    """
    Stats->Sampling->Last Packet Size->Get Last Outgoing Packet Size
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class Expression60(Expression):
    """
    Dead Reckoning->Get Number of Updates
    Return type: Int
    """

    def get(self, instance):
        raise NotImplementedError('%s not implemented' % (
            str(self)))

class ExtensionProtocol(MooClientProtocol):
    def __init__(self, player, *arg, **kw):
        self.player = player
        player.protocol = self
        self.name = player.name
        MooClientProtocol.__init__(self, *arg, **kw)

    def connectionAccepted(self):
        self.fireHandler('on_connect')
    
    def channelJoined(self, channel):
        self.player.select_channel(channel)
        self.fireHandler('on_sign_on')
    
    def fireHandler(self, name, *arg, **kw):
        self.player.fire_handler(name, *arg, **kw)

class DefaultObject(HiddenObject):
    protocol = None
    name = 'MooGame'
    
    # event stuff
    channel = None
    user = None

    recipient = 'server'

    def created(self, data):
        self.clientFactory = protocol.ClientCreator(reactor, ExtensionProtocol,
            self)
    
    def set_name(self, name):
        self.name = name
        if self.protocol is not None:
            self.protocol.changeName(name)
    
    def connect(self, ip, port):
        self.clientFactory.connectTCP(ip, port)
        reactor.enable()
    
    def set_recipient(self, value):
        self.recipient = value
    
    def select_channel(self, channel):
        self.channel = channel
        self.set_recipient('channel')
    
    def signed_on(self):
        return self.channel is not None
    
    def connected(self):
        return self.protocol is not None

class moogame(UserExtension):
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
        22 : Action22,
        23 : Action23,
        24 : Action24,
        25 : Action25,
        26 : Action26,
        27 : Action27,
        28 : Action28,
        31 : Action29,
        32 : Action30,
        33 : Action31,
        34 : Action32,
        35 : Action33,
        36 : Action34,
        37 : Action35,
        38 : Action36,
        39 : Action37,
        40 : Action38,
        41 : Action39,
        42 : Action40,
        43 : Action41,
        44 : Action42,
        45 : Action43,
        46 : Action44,
        47 : Action45,
        48 : Action46,
        49 : Action47,
        50 : Action48,
        51 : Action49,
        52 : Action50,
        53 : Action51,
        54 : Action52,
        55 : Action53,
        56 : Action54,
        57 : Action55,
        58 : Action56,
        59 : Action57,
        60 : Action58,
        61 : Action59,
        62 : Action60,
        63 : Action61,
        64 : Action62,
        65 : Action63,
        66 : Action64,
        67 : Action65,
        68 : Action66,
        69 : Action67,
        70 : Action68,
        71 : Action69,
        72 : Action70,
    }
    
    conditions = {
        0 : Condition0,
        1 : OnConnect,
        2 : OnDisconnect,
        3 : Condition3,
        4 : OnSignOn,
        5 : OnSignOff,
        6 : Condition6,
        7 : Condition7,
        8 : Condition8,
        9 : Condition9,
        10 : Condition10,
        11 : Condition11,
        12 : Condition12,
        13 : Condition13,
        14 : Condition14,
        15 : Condition15,
        16 : Condition16,
        17 : Condition17,
        18 : Condition18,
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
        41 : Expression41,
        42 : Expression42,
        43 : Expression43,
        44 : Expression44,
        45 : Expression45,
        46 : Expression46,
        47 : Expression47,
        48 : Expression48,
        49 : Expression49,
        50 : Expression50,
        51 : Expression51,
        52 : Expression52,
        53 : Expression53,
        54 : Expression54,
        55 : Expression55,
        56 : Expression56,
        57 : Expression57,
        58 : Expression58,
        59 : Expression59,
        60 : Expression60,
    }

extension = moogame()

def get_extension():
    return extension
