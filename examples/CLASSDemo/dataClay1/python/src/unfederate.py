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
        i = 0
        while i < 10:
            EventsInCar.get_by_alias("block%i" % i).unfederate(dataclay_id2)
            print("Block %i unfederated " % i)
            i = i + 1
    except:
        traceback.print_exc()

    # Close session
    finish()
    exit(0)
