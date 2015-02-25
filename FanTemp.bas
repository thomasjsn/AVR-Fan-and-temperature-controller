'--------------------------------------------------------------
'                   Thomas Jensen | uCtrl.net
'--------------------------------------------------------------
'  file: AVR_FTU_v_2.0
'  date: 15/03/2007
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
Dim Alarm_timer2 As Integer , Fan_speed As Byte , Temp_timer As Byte
Dim Fan_delay As Integer , Fan_delay2 As Integer
Dim Fan_timer As Integer , Fan_timer2 As Integer

Config Timer1 = Pwm , Pwm = 8 , Prescale = 1 , Compare A Pwm = Clear Up , Compare B Pwm = Clear Up
Ddrb.1 = 1
Ddrb.2 = 1
Pwm1a = 255
Pwm1b = 255

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
Alarm_timer = 0
Fan_speed = 0
Fan_delay = 0
Fan_timer = 0
Temp_timer = 10

'get eeprom values
Set_fan = Eeprom_fan
If Set_fan > 50 Or Set_fan < 10 Then Set_fan = 30
Set_alarm = Eeprom_alarm
If Set_alarm > 50 Or Set_alarm < 10 Then Set_alarm = 32

Cls
Cursor Off
Deflcdchar 1 , 32 , 32 , 32 , 7 , 4 , 6 , 4 , 7             'e-sign
Deflcdchar 2 , 32 , 32 , 32 , 32 , 32 , 32 , 32 , 32        'blank

'turn off alarm
Pwm1b = 0

Locate 1 , 1
Lcd "Fan & Temp Unit!"
Locate 2 , 5
Lcd "SW v.2.0"
Waitms 2000
Cls
Locate 1 , 1
Lcd "uCtrl.net"
Locate 2 , 1
Lcd "System start =)"
Waitms 2000
Cls
Locate 1 , 5
Lcd "F:"
Locate 1 , 11
Lcd "A:"
Locate 2 , 1
Lcd "Fan:"
Locate 1 , 1
Lcd "?C"

'turn off alarm
Pwm1b = 255

Start Watchdog

Main:
'cls timer
If Cls_timer > 0 Then Decr Cls_timer
If Cls_timer = 0 Then
   Cls
   Locate 1 , 1
   Lcd Temp ; "C"
   Locate 1 , 5
   Lcd "F:"
   Locate 1 , 11
   Lcd "A:"
   Locate 2 , 1
   Lcd "Fan:"
   Cls_timer = 50
   End If

'check temp
If Temp_timer > 0 Then Decr Temp_timer
If Temp_timer = 0 Then
   W = Getadc(0)
   Volt = W * 5
   Temp = Volt / 10
   Temp_timer = 100
   End If

'show set points
Locate 1 , 7
Lcd Set_fan ; "C"
Locate 1 , 13
Lcd Set_alarm ; "C"

'set fan
If Fan_delay = 0 Then Fan_speed = 0

If Temp < Set_fan Then
   If Fan_delay = 0 Then Fan_speed = 0
   Fan_timer = 0
   End If

If Temp = Set_fan And Fan_speed <> 3 Then
   Fan_speed = 1
   Fan_delay = 600
   If Fan_timer < 300 Then Incr Fan_timer
      If Fan_timer = 300 Then
      Fan_speed = 2
      Fan_delay = 600
      End If
   End If

If Temp > Set_fan Then
   Fan_speed = 3
   Fan_delay = 600
   Fan_timer = 300
   End If

'fan timers
If Fan_delay > 0 Then Decr Fan_delay

'set fan speed
If Pinb.5 = 0 Then Fan_speed = Fan_speed + 2
If Fan_speed > 3 Then Fan_speed = 3
If Fan_speed = 0 Then Pwm1a = 255
If Fan_speed = 1 Then Pwm1a = 170
If Fan_speed = 2 Then Pwm1a = 105
If Fan_speed = 3 Then Pwm1a = 0
Locate 2 , 5
Lcd Fan_speed
If Pinb.5 = 0 Then
   Locate 2 , 7
   Lcd "F"
   End If

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

'set alarm temp
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

'alarmled
If Alarmled > 0 Then Alarmled = Alarmled - 1
If Alarmled = 4 Then Pwm1b = 0
If Alarmled = 1 Then Pwm1b = 255

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

'show timers
Locate 2 , 15
Alarm_timer2 = Alarm_timer / 10
Lcd Alarm_timer2
Locate 2 , 9
Fan_delay2 = Fan_delay / 10
Lcd Fan_delay2
Locate 2 , 12
Fan_timer2 = Fan_timer / 10
Lcd Fan_timer2

'lifesignal
If Lifesignal > 0 Then Lifesignal = Lifesignal - 1
If Lifesignal = 6 Then Portb.0 = 1
If Lifesignal = 1 Then Portb.0 = 0
If Lifesignal = 0 Then Lifesignal = 21

Reset Watchdog
Waitms 100
Goto Main
End