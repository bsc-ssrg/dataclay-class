from dataclay import DataClayObject, dclayMethod


class Position(DataClayObject):
    """
    @ClassField x int
    @ClassField y int
    """

    @dclayMethod(x='int', y='int')
    def __init__(self, x, y):
        self.x = x
        self.y = y
        
    @dclayMethod(return_="str")
    def __str__(self):
        return "(%s,%s)" % (str(self.x), str(self.y))


class Event(DataClayObject):
    """
    @ClassField event_type int
    @ClassField timestamp str
    @ClassField position CityNS.classes.Position
    """

    @dclayMethod(event_type='int', timestamp='str', position='CityNS.classes.Position')
    def __init__(self, event_type, timestamp, position):
        self.event_type = event_type
        self.timestamp = timestamp
        self.position = position
    
    @dclayMethod(return_="str")
    def __str__(self):
        return "{EVENT at position=%s, type=%s, timestamp = %s}" % (self.position, str(self.event_type), self.timestamp);    


class AggregatedEvents(DataClayObject):
    """
    @ClassField total_events int
    """
    
    @dclayMethod()
    def __init__(self):
        self.total_events = 0

    @dclayMethod(delta="int")
    def increment_events(self, delta):
        self.total_events = self.total_events + delta
    

class City(DataClayObject):
    """
    @ClassField events list<CityNS.classes.Event>
    @ClassField aggregation CityNS.classes.AggregatedEvents
    """
    
    @dclayMethod()
    def __init__(self):
        self.events = list()
        self.aggregation = AggregatedEvents()
    
    @dclayMethod(new_events="list<CityNS.classes.Event>")
    def add_all_events(self, new_events):
        self.events.extend(new_events)
        
    @dclayMethod(return_="CityNS.classes.AggregatedEvents")
    def get_aggregation(self):
        return self.aggregation
    

class EventsInCar(DataClayObject):
    """
    @ClassField events dict<CityNS.classes.Position, CityNS.classes.Event>
    """

    @dclayMethod()
    def __init__(self):
        self.events = dict()

    @dclayMethod(new_event="CityNS.classes.Event")
    def add_event(self, new_event):
        self.events[new_event.position] = new_event

    @dclayMethod()  
    def when_federated(self):
        # This is executed in a city fog node. Since they are independent dataClays,
        # the alias can be fixed.
        print("Calling when federated in EventsInCar")
        city = City.get_by_alias("my-pycity");
        city.add_all_events(self.events.values());

    @dclayMethod(return_="str")
    def __str__(self):
        result = ["["]
        for event in self.events.values():
            result.append(" %s" % (event))
        result.append("]")
        return ",".join(result)
