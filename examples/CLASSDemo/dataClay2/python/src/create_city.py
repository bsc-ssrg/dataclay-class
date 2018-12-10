 #!/usr/bin/env python2
import traceback

from dataclay.api import init, finish

# Init dataClay session
init()

from CityNS.classes import City

if __name__ == "__main__":

    try:
        city = City()
        city.make_persistent("my-pycity")
        
    except:
        traceback.print_exc()

    # Close session
    finish()
    exit(0)
