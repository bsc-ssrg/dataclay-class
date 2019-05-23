from dataclay import DataClayObject, dclayMethod
from dataclay.contrib.dummy_pycompss import *
from datetime import datetime

class DKB(DataClayObject):
    """
    @ClassField KB dict<str, list<CityNS.classes.ObjectKB>>
    @ClassField identifiedObjects list<CityNS.classes.Event>
    @ClassField objectsInOSM dict<CityNS.classes.Position, CityNS.classes.Event>
    @ClassField objectsInAllegro list<CityNS.classes.Event>
    """
    @dclayMethod()
    def __init__(self):
        self.KB = dict()
        self.identifiedObjects = []
        self.objectsInOSM = dict()
        self.objectsInAllegro = []

    @dclayMethod(subarea='str')
    def initSubArea(self, subarea):
        if subarea not in self.KB:
            self.KB[subarea] = []
            for i in range(7*60*24):
                self.KB[subarea].append(ObjectKB())

    @dclayMethod(event='CityNS.classes.Event', subarea='str')
    def aggregatte(self, event, subarea):
        try:
            minute = (event.dt.hour*60)+event.dt.minute
            day = event.dt.weekday()
            if subarea in self.KB:
                self.KB[subarea][(day*60*24)+minute].update(event)

            else:
                self.KB[subarea] = []
                for i in range(7*60*24):
                    self.KB[subarea].append(ObjectKB())
                self.KB[subarea][(day*60*24)+minute].update(event)
        except Exception as e:
            print "Some error: %s" % e
            print event.dt
            #Event datetime no reconocido"

    @dclayMethod(event='CityNS.classes.Event')
    def updateOSMObject(self, event):
        self.objectsInOSM[event.pos] = event

    @dclayMethod(return_='str')
    def __str__(self):
        string = ""
        for key, value in self.KB.items():
            string +='@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ \n'
            string += 'Sub-area: ' + key + '\n'
            for v in value:
                if v.toPrint == 1:
                    string += str(v) + '\n'
        #string += '\nIdentified Objects: \n'
        #for a in self.identifiedObjects:
        #    string += str(a) + ", "
        #string += '\nObjects in Allegro:\n'
        #for a in self.objectsInAllegro:
        #    string += str(a) + ", "
        return string

    @dclayMethod(events='anything', subarea='str')
    def updateKB(self, events, subarea):
        self.aggregatteEvents(events, subarea)
        self.appendIdentified(events)
        self.updateOSMObjects(events)
        self.updateAllegroObjects(events)

    @dclayMethod(events='anything', subarea='str')
    def aggregatteEvents(self, events, subarea):
        for event in events:
            self.aggregatte(event,subarea)


    @dclayMethod(events='anything')
    def appendIdentified(self, events):
        self.identifiedObjects.extend(events)

    @dclayMethod(events='anything')
    def updateOSMObjects(self,events):
        for event in events:
            self.updateOSMObject(event)
    
    @dclayMethod(events='anything')
    def updateAllegroObjects(self, events):
        self.objectsInAllegro = events 

    @dclayMethod()
    def resetDKB(self):
        self.KB = dict()
        self.identifiedObjects = []
        self.objectsInOSM = dict()
        self.objectsInAllegro = []

class ObjectKB(DataClayObject):
    """
    @ClassField dt anything
    @ClassField totalTrafficFlow int
    @ClassField trafficFlow dict<str, CityNS.classes.ObjectTrafficFlow>
    @ClassField pedestrianFlow int
    @ClassField toPrint int
    """
    @dclayMethod()
    def __init__(self):
        self.dt = None
        self.totalTrafficFlow = 0
        self.trafficFlow = dict()
        self.pedestrianFlow = 0
        self.toPrint= 0

    @dclayMethod(event = 'CityNS.classes.Event')
    def update(self, event):
        self.toPrint = 1
        self.dt = event.dt
        if isinstance(event.object, Vehicle):
            self.totalTrafficFlow += 1
            if event.object.type in self.trafficFlow:
                self.trafficFlow[event.object.type].update(event.object.speed)
            else:
                self.trafficFlow[event.object.type] = ObjectTrafficFlow(event.object.speed)
        elif isinstance(event.object, PedestrianFlow):
            self.pedestrianFlow += event.object.value
        else:
                print 'error: evento no reconocido durante la aggregacion'

    @dclayMethod(return_='str')
    def __str__(self):
        string = '########################################################### \n'
        string +=   'Hour: ' + str(self.dt.hour) + ' Minute: '+ str(self.dt.minute)
        string +='\n----------------------------------------------------------- \n'
        string+='Traffic Flow: \n Total vehicles registered: ' + str(self.totalTrafficFlow) +   '\n '
        for key, value in self.trafficFlow.items():
            string += '--> Vehicle Type: ' + key + ' ' + str(value) + '\n'
        string +='----------------------------------------------------------- \n'
        string += ' Pedestrian Flow: \n'
        string +=  '-->  Total Pedestrian Flow: ' + str(self.pedestrianFlow) + '\n'
        string += '########################################################### \n'
        return string




class Event(DataClayObject):
    """
    @ClassField object anything
    @ClassField pos CityNS.classes.Position
    @ClassField dt anything
    @ClassField VOCid int
    """
    @dclayMethod(eventType='anything', pos='CityNS.classes.Position', dtime='anything', VOCid='int')
    def __init__(self,eventType, pos, dtime, VOCid):
        self.object = eventType
        self.pos = pos
        self.dt = dtime
        self.VOCid = VOCid
        print 'Init Event ' + str(dtime)

    @dclayMethod(return_='str')
    def __str__(self):
        return'Event Type: ' + self.object.__class__.__name__ + ', Position: [' + str(self.pos) + '], Datetime: ' +  str(self.dt) + ', VOCid: ' + str(self.VOCid) + '\n'

class Position(DataClayObject):
    """
    @ClassField lon anything
    @ClassField lat anything
    """
    @dclayMethod(lon='anything', lat='anything')
    def __init__(self, lon, lat):
        self.lon = lon
        self.lat = lat

    @dclayMethod(other='CityNS.classes.Position', return_='bool')
    def __eq__(self, other):
        return isinstance(other, self.__class__) and self.lon == other.lon and self.lat == other.lat

    @dclayMethod(return_='anything')
    def __hash__(self):
        return hash(self.lon) ^ hash(self.lat)

    @dclayMethod(return_='str')
    def __str__(self):
        return 'Longitude: ' + str(self.lon) + ', Latitude: ' + str(self.lat)


class Vehicle(DataClayObject):
    """
    @ClassField type str
    @ClassField speed float
    """
    @dclayMethod(vehicleType='str', speed='float')
    def __init__(self, vehicleType, speed):
        self.type = vehicleType
        self.speed = speed

class PedestrianFlow(DataClayObject):
    """
    @ClassField value int
    """
    @dclayMethod(value='int')
    def __init__(self, value):
        self.value = value

class ObjectTrafficFlow(DataClayObject):
    """
    @ClassField sum int
    @ClassField totalSpeed float
    @ClassField averageSpeed float
    """
    @dclayMethod(speed='float')
    def __init__(self, speed):
        self.sum = 1
        self.totalSpeed = speed
        self.averageSpeed = speed


    @dclayMethod(speed = 'float')
    def update(self, speed):
        self.sum+=1
        self.totalSpeed += speed
        self.averageSpeed = self.totalSpeed / float(self.sum)

    @dclayMethod(return_='str')
    def __str__(self):
        return 'Total Vehicles: ' + str(self.sum) + ' Average Speed: ' + str(self.averageSpeed)

class EventsInCar(DataClayObject):
    """
    @ClassField events list<CityNS.classes.Event>
    """

    @dclayMethod(new_events="anything")
    def __init__(self, new_events = []):
        self.events = new_events

    @dclayMethod(new_event="CityNS.classes.Event")
    def add_event(self, new_event):
        self.events.append(new_event)

    @dclayMethod(new_events="anything")
    def add_events(self, new_events):
        self.events.extend(new_events)
    
    @dclayMethod()  
    def when_federated(self):
        print("Calling when federated in EventsInCar")
        kb = DKB.get_by_alias("DKB");
        kb.updateKB(self.events, "roundabout");#provisional


    @dclayMethod()
    def when_undeferated(self):
        self.events = list()
    

    @dclayMethod()
    def delete(self):
        self.events = list()
