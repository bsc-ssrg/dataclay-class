 #!/usr/bin/env python2
import traceback
import os
import datetime
from dataclay.api import init, finish, register_external_dataclay

# Init dataClay session
init()

from CityNS.classes import EventsInCar, Position, Event

if __name__ == "__main__":

    try:
        
        # Get dataClay 2 ID
        dataclay_id2 = register_external_dataclay(os.environ['DATACLAY2_IP'], int(os.environ['DATACLAY2_PORT']))
    
        # Create a dictionary of events to federate
        events_to_federate = EventsInCar()
    
        # Create an Event
        position = Position(0, 1)
        current_date = datetime.datetime.now().strftime("%d-%m-%Y %I:%M:%S")
        event_type = 1
        event = Event(event_type, current_date, position)
    
        # add event to car
        events_to_federate.add_event(event)
    
        # Federate events
        print("Events created: %s" % events_to_federate)
        events_to_federate.make_persistent("block1")
        events_to_federate.federate(dataclay_id2)
        
        # ==== New events ====
        events_to_federate = EventsInCar()
        position = Position(3, 2)
        current_date = datetime.datetime.now().strftime("%d-%m-%Y %I:%M:%S")
        event_type = 6
        event = Event(event_type, current_date, position)
    
        # add event to car
        events_to_federate.add_event(event)
    
        # Federate events
        print("Events created: %s" % events_to_federate)
        events_to_federate.make_persistent("block2")
        events_to_federate.federate(dataclay_id2)

    except:
        traceback.print_exc()

    # Close session
    finish()
    exit(0)
