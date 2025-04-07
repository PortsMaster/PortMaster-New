<?xml version="1.0" ?>
<!DOCTYPE bulletml SYSTEM "http://www.asahi-net.or.jp/~cs8k-cyu/bulletml/bulletml.dtd">

<bulletml type="vertical"
          xmlns="http://www.asahi-net.or.jp/~cs8k-cyu/bulletml">

<action label="top">
 <repeat> <times>8</times>
 <action>
  <actionRef label="fireCircle">
   <param>180-45+90*$rand</param>
  </actionRef>
  <wait>32</wait>
 </action>
 </repeat>
 <vanish/>
</action>

<action label="fireCircle">
<repeat> <times>6+$rank*12</times>
<action>
<fireRef label="circle">
 <param>360/(6+$rank*12)</param>
 <param>$1</param>
</fireRef>
</action>
</repeat>
</action>

<fire label="circle">
<direction type="sequence">$1</direction>
<speed>4</speed>
<bullet>
<action>
 <wait>3</wait>
 <fire>
  <direction type="absolute">$2</direction>
  <speed>0.6+$rank*1.0</speed>
  <bullet/>
 </fire>
 <vanish/>
</action>
</bullet>
</fire>

</bulletml>
