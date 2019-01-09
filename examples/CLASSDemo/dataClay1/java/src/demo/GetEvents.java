package demo;

import java.util.List;

import dataclay.api.DataClay;
import dataclay.commonruntime.ClientManagementLib;
import dataclay.exceptions.metadataservice.ObjectNotRegisteredException;
import model.City;
import model.EventsInCar;
import model.Event;

/**
 * Get Events main class.
 */
public class GetEvents {

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
			discoverDataClays();
			
			System.out.println("Checking if events in car are accessible");
			try { 
				EventsInCar.getByAlias("block1");
				System.out.println("Object with alias block1 found");
			} catch (final ObjectNotRegisteredException ex) { 
				System.out.println("Object with alias block1 not found");
			}
			try { 
				EventsInCar.getByAlias("block2");
				System.out.println("Object with alias block2 found");
			} catch (final ObjectNotRegisteredException ex) { 
				System.out.println("Object with alias block2 not found");
			}
			
			// Get my city
			final City city = City.getByAlias("my-city");

			// Get events
			final List<Event> cityEvents = city.getEvents();

			// Print events
			for (final Event event : cityEvents) {
				System.out.println(event.toString());
			}
			System.out.println("City aggregation: " + city.getAggregation().toString());

		} catch (final Exception e) {
			e.printStackTrace();
			throw e;
		} finally {
			DataClay.finish();
		}
	}

	/**
	 * Discover dataClays and register needed information.
	 */
	public static void discoverDataClays() {
		// The Discovery process will give us the IP of the "fog" machine
		final String dataClay1Host = System.getenv("DATACLAY1_IP");
		final int dataClay1Port = Integer.parseInt(System.getenv("DATACLAY1_PORT"));
		ClientManagementLib.registerExternalDataClay(dataClay1Host, dataClay1Port);
	}

}
