'--------------------------------------------------------------
'                   Thomas Jensen | uCtrl.net
'--------------------------------------------------------------
'  file: AVR_FTU
'  date: 16/07/2006
'--------------------------------------------------------------
$regfile = "M8def.dat"
$crystal = 1000000
Config Watchdog = 1024
Config Portb.0 = Output
Config Portb.1 = Output
Config Portb.2 = Output
Config Portb.3 = Input
Config Portb.4 = Input
Config Portb.5 = Input
Config Portb.6 = Input
Config Portb.7 = Input
Dim Lifesignal As Integer
Dim W As Word , Volt As Word , Temp As Word
Dim C_vifte1 As Byte , C_vifte2 As Byte , Set_fan As Byte
Dim C_alarm1 As Byte , C_alarm2 As Byte , Set_alarm As Byte
Dim Alarmled As Integer , Cls_timer As Integer , Alarm_timer As Integer
Dim Eeprom_save As Integer , Eeprom_fan As Eram Byte , Eeprom_alarm As Eram Byte

Config Lcdpin = Pin , Db4 = Portd.3 , Db5 = Portd.2 , Db6 = Portd.1 , Db7 = Portd.0 , E = Portd.6 , Rs = Portd.7
Config Lcd = 16 * 2

Config Adc = Single , Prescaler = Auto , Reference = Avcc
Start Adc

Lifesignal = 21
Alarmled = 0
Eeprom_save = 0
C_vifte1 = 0
C_vifte2 = 0
C_alarm1 = 0
C_alarm2 = 0
Cls_timer = 50
Alarm_timer = 300

'get eeprom values
Set_fan = Eeprom_fan
If Set_fan > 50 Or Set_fan < 10 Then Set_fan = 30
Set_alarm = Eeprom_alarm
If Set_alarm > 50 Or Set_alarm < 10 Then Set_alarm = 32

Cls
Cursor Off
Deflcdchar 1 , 32 , 32 , 32 , 7 , 4 , 6 , 4 , 7             'e-sign
Deflcdchar 2 , 32 , 32 , 32 , 32 , 32 , 32 , 32 , 32        'blank

Locate 1 , 1
Lcd "Fan & Temp Unit!"
Locate 2 , 1
Lcd "by Thomas Jensen"
Waitms 2000
Cls
Locate 1 , 1
Lcd "FTU running"
Locate 2 , 1
Lcd "Reading temp..."
Waitms 1500
Cls
Locate 1 , 5
Lcd "F:"
Locate 1 , 11
Lcd "A:"

Start Watchdog

Main:
'cls timer
If Cls_timer > 0 Then Cls_timer = Cls_timer - 1
If Cls_timer = 0 Then
   Cls
   Locate 1 , 5
   Lcd "F:"
   Locate 1 , 11
   Lcd "A:"
   Cls_timer = 50
   End If

'check temp
W = Getadc(0)
Volt = W * 5
Temp = Volt / 10
Locate 1 , 1
Lcd Temp ; "C"
Locate 1 , 7
Lcd Set_fan ; "C"
Locate 1 , 13
Lcd Set_alarm ; "C"

'set fan
If Pinb.5 = 0 Then
   Portb.1 = 1
   Locate 2 , 1
   Lcd "Force fan"
   End If
If Temp > Set_fan Then Portb.1 = 1
If Temp < Set_fan And Pinb.5 = 1 Then Portb.1 = 0

'set fan temp
If Pinb.3 = 1 Then C_vifte1 = 0
If Pinb.3 = 0 And C_vifte1 = 0 Then
   C_vifte1 = 1
   Set_fan = Set_fan + 1
   Eeprom_save = 3000
   End If
If Pinb.4 = 1 Then C_vifte2 = 0
If Pinb.4 = 0 And C_vifte2 = 0 Then
   C_vifte2 = 1
   Set_fan = Set_fan - 1
   Eeprom_save = 3000
   End If

'set fan temp
If Pinb.6 = 1 Then C_alarm1 = 0
If Pinb.6 = 0 And C_alarm1 = 0 Then
   C_alarm1 = 1
   Set_alarm = Set_alarm + 1
   Eeprom_save = 3000
   End If
If Pinb.7 = 1 Then C_alarm2 = 0
If Pinb.7 = 0 And C_alarm2 = 0 Then
   C_alarm2 = 1
   Set_alarm = Set_alarm - 1
   Eeprom_save = 3000
   End If

'set main temp_alarm
If Temp >= Set_alarm And Alarm_timer < 300 Then Alarm_timer = Alarm_timer + 1
If Alarm_timer = 300 And Alarmled = 0 Then Alarmled = 6
If Temp < Set_alarm Then Alarm_timer = 0
If Alarm_timer > 0 Then
   Locate 2 , 14
   Lcd Alarm_timer
   End If

'alarmled
If Alarmled > 0 Then Alarmled = Alarmled - 1
If Alarmled = 4 Then Portb.2 = 1
If Alarmled = 1 Then Portb.2 = 0

'eeprom save
If Eeprom_save > 0 Then
   Eeprom_save = Eeprom_save - 1
   Locate 1 , 16
   Lcd Chr(1)
   End If
If Eeprom_save = 1 Then
   Eeprom_fan = Set_fan
   Eeprom_alarm = Set_alarm
   Locate 1 , 16
   Lcd Chr(2)
   End If

'lifesignal
If Lifesignal > 0 Then Lifesignal = Lifesignal - 1
If Lifesignal = 6 Then Portb.0 = 1
If Lifesignal = 1 Then Portb.0 = 0
If Lifesignal = 0 Then Lifesignal = 21

Reset Watchdog
Waitms 100
Goto Main
End