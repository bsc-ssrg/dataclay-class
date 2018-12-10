 #!/usr/bin/env python2
import traceback
import os
import datetime
from dataclay.api import init, finish, \
    get_external_dataclay_id

# Init dataClay session
init()

from CityNS.classes import EventsInCar, Position, Event

if __name__ == "__main__":

    try:
        
        # Get dataClay 2 ID
        dataclay_id2 = get_external_dataclay_id(os.environ['DATACLAY2_IP'], int(os.environ['DATACLAY2_PORT']))
    
        # Unfederate 
        EventsInCar.get_by_alias("block1").unfederate(dataclay_id2)
        print("First block unfederated")
        EventsInCar.get_by_alias("block2").unfederate(dataclay_id2)
        print("Second block unfederated")
        
        # Check 
        print("Checking that events in car are not accessible")
        try:
            events_in_car = EventsInCar.get_by_alias("block1")
            print("ERROR: Object with alias block1 found")
        except:
            print("Object with alias block1 not found")
        try:
            events_in_car = EventsInCar.get_by_alias("block2")
            print("ERROR: Object with alias block2 found")
        except:
            print("Object with alias block2 not found")
    except:
        traceback.print_exc()

    # Close session
    finish()
    exit(0)
