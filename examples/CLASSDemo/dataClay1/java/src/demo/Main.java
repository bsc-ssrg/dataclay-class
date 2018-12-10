package demo;

import java.text.SimpleDateFormat;
import java.util.Date;

import dataclay.api.DataClay;
import dataclay.commonruntime.ClientManagementLib;
import dataclay.util.ids.DataClayInstanceID;
import model.Event;
import model.EventsInCar;
import model.Position;

/**
 * Main class.
 */
public class Main {


	/**
	 * Main function.
	 * 
	 * @param args
	 *            Arguments <operation>
	 * @throws Exception
	 *             If some exception occurs
	 */
	public static void main(final String[] args) throws Exception {
		try {

			// Initialize dataClay
			DataClay.init();

			// Discover dataClays
			final DataClayInstanceID cityDataClayID = discoverDataClays();

			// Create a dictionary of events to federate
			EventsInCar eventsToFederate = new EventsInCar();

			// Create an Event
			Position position = new Position(0, 1);
			String currentDate = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss").format(new Date());
			int eventType = 1;
			Event event = new Event(eventType, currentDate, position);

			// add event to car
			eventsToFederate.addEvent(event);

			// Create another Event
			position = new Position(1, 2);
			currentDate = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss").format(new Date());
			eventType = 2;
			event = new Event(eventType, currentDate, position);

			// add second event to car
			eventsToFederate.addEvent(event);

			// Federate events
			System.out.println("First events created:" + eventsToFederate.toString());
			eventsToFederate.makePersistent("block1");
			eventsToFederate.federate(cityDataClayID);

			// ===== New events ===== //
			eventsToFederate = new EventsInCar();

			// Create another Event
			position = new Position(3, 2);
			currentDate = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss").format(new Date());
			eventType = 6;
			event = new Event(eventType, currentDate, position);

			// Add event
			eventsToFederate.addEvent(event);

			// Federate events
			System.out.println("Second events created:" + eventsToFederate.toString());
			eventsToFederate.makePersistent("block2");
			eventsToFederate.federate(cityDataClayID);

			
		} catch (final Exception e) {
			throw e;
		} finally {
			DataClay.finish();
		}
	}

	/**
	 * Discover dataClays and register needed information.
	 */
	public static DataClayInstanceID discoverDataClays() {
		// The Discovery process will give us the IP of the "fog" machine
		final String dataClay2Host = System.getenv("DATACLAY2_IP");
		final int dataClay2Port = Integer.parseInt(System.getenv("DATACLAY2_PORT"));
		return ClientManagementLib.registerExternalDataClay(dataClay2Host, dataClay2Port);
	}

}
