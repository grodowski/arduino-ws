ArduinoWeb
==========

Student project by Jan Grodowski - an asynchronous web server for processing commands and collecting data from a remote Arduino device.

Tasks
=====

Define parameters for Grape API (status: **started**)
---

All requests will be authenticated via HTTP Basic Auth and SSL, so that 3rd parties won't be able to send requests to the middleware server.

**Refresh the list of samples for a given unit id**

```
GET /:device_id/log
{since: '142045667'} # unix timestamp

[
	{temp_c: 22.3, temp_f: 73.8, created_at: 14588976},
	{temp_c: 26.2, temp_f: 80.8, created_at: 14588976},
	{temp_c: 22.3, temp_f: 73.8, created_at: 14588976}
]
```

**Fetch treshold settings for a given unit id**

```
GET /:device_id/tresholds

{
	alarm_min_c: -34.2,
	alarm_min_f: -70.2,
	alarm_max_c: 22.2,
	alarm_max_f: 34.4
}
```

**Set treshold for a given unit**

```
POST /:device_id/tresholds
# All parameters are optional
{
	alarm_min_c: 20,
	alarm_min_f: 70,
	alarm_max_c: 10,
	alarm_max_f: 100
}
```


DS18B20 digital thermomether Arduino setup (status: **unstarted**)
---

http://playground.arduino.cc/Learning/OneWire - 1-Wire protocol for the DS18B20
http://milesburton.com/Dallas_Temperature_Control_Library - Dallas Instruments control library for arduino

Arduino WS Client (status: **unstarted**)
---

Arduino Sketch for temperature logging (status: **unstarted**)
---

Data Model using ActiveRecord (status: **unstarted**)
---

Authentication (status: **unstarted**)
---

Client Application (Rails + JS or Rack rendering?) (status: **unstarted**)
---

Implement Arduino with Scheduler libraries (status: **unstarted**)
---

The Arduino single threaded model is not sufficient to provide full real-time operation of the thermomether. Need to implement I/O using a task scheduling algorithm.