package demo;

import dataclay.api.DataClay;
import dataclay.commonruntime.ClientManagementLib;
import dataclay.exceptions.metadataservice.ObjectNotRegisteredException;
import dataclay.util.ids.DataClayInstanceID;
import model.EventsInCar;

/**
 * Main class.
 */
public class Unfederate {


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
			
			// ====== UNFEDERATE ===== //
			EventsInCar.getByAlias("block1").unfederate(cityDataClayID);
			System.out.println("First block of events unfederated");
			EventsInCar.getByAlias("block2").unfederate(cityDataClayID);
			System.out.println("Second block of events unfederated");
			
			System.out.println("Checking that events in car are not accessible");
			try { 
				EventsInCar.getByAlias("block1");
				System.out.println("ERROR: Object with alias block1 found");
			} catch (final ObjectNotRegisteredException ex) { 
				System.out.println("Object with alias block1 not found");
			}
			try { 
				EventsInCar.getByAlias("block2");
				System.out.println("ERROR: Object with alias block2 found");
			} catch (final ObjectNotRegisteredException ex) { 
				System.out.println("Object with alias block2 not found");
			}
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
		return ClientManagementLib.getExternalDataClayID(dataClay2Host, dataClay2Port);
	}

}
