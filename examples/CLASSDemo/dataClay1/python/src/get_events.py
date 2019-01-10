 #!/usr/bin/env python2
import traceback

from dataclay.api import init, finish

# Init dataClay session
init()

from CityNS.classes import City, EventsInCar

if __name__ == "__main__":

    try:
        
        # Check 
        print("Checking if events in car are accessible")
        try:
            events_in_car = EventsInCar.get_by_alias("block1")
            print("Object with alias block1 found")
        except:
            print("Object with alias block1 not found")
        try:
            events_in_car = EventsInCar.get_by_alias("block2")
            print("Object with alias block2 found")
        except:
            print("Object with alias block2 not found")
        
        city = City.get_by_alias("my-pycity")

        # Print events
        for event in city.events:
            print(str(event))
        
        print("City aggregation: %s" % str(city.get_aggregation()))
        
    except:
        traceback.print_exc()

    # Close session
    finish()
    exit(0)
