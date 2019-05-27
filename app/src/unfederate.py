 #!/usr/bin/env python2
import traceback
import os
import datetime
from dataclay.api import init, finish, \
    get_external_dataclay_id, unfederate_all_objects_with_all_dcs

# Init dataClay session
init()

from CityNS.classes import EventsInCar, Position, Event

if __name__ == "__main__":

    try:
        # Unfederate all 
        unfederate_all_objects_with_all_dcs()
       
    except:
        traceback.print_exc()

    # Close session
    finish()
    exit(0)
