package demo;

import dataclay.api.DataClay;
import model.City;

/**
 * Main class to create City.
 */
public class CreateCity {

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

			// Create the city
			final City city = new City();
			final String alias = "my-city";
			city.makePersistent(alias);
			System.out.println("City with alias " + alias + " created!");

		} catch (final Exception e) {
			e.printStackTrace();
			throw e;
		} finally {
			DataClay.finish();
		}
	}
}
